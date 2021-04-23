% visstimLegFictracEphysIInj.m
%
% Experimental Function
% For simultaneous presentation of visual stimuli on G3 panels and 
%  acquisition of leg video, FicTrac, and electrophysiology recording.
% Uses background acquisition on DAQ
% Does current injection
%
% INPUTS:
%   settings - struct of ephys setup settings, from ephysSettings()
%   duration - duration of trial, in seconds
%
% OUTPUTS:
%   rawData - raw data measured by DAQ, matrix where each column is data
%       from a different channel
%   inputParams - parameters for this experiment type
%   rawOutput - raw output sent by DAQ, matrix where each column is
%       different channel
%
% CREATED: 4/23/21 - HHY
%
% UPDATED:
%   4/23/21
%
function [rawData, inputParams, rawOutput] = visstimLegFictracEphysIInj(...
    settings, duration)

    % Initialize global variable for raw data collection
    global daqData
    % Initialize global variable for knowing when to prompt for
    %  starting acquisition on leg camera (i.e. only first time leg video
    %  is acquired for cell)
    global firstLegVidTrial
    
    % first time leg video is acquired is when this variable is first
    %  initiated
    if isempty(firstLegVidTrial)
        firstLegVidTrial = 1; % yes, this is first trial
    else
        firstLegVidTrial = 0; % no, this is not first trial
    end
    
    % binary variable for whether DAQ should be stopped; used in nested
    %  function queueLegTrig()
    acqStopBin = 0; % starts as 0 (no)
    
    % start index (in scans) of output
    % will count up every time DataRequired event is called
    whichOutScan = 1; % start at 1

    % EXPERIMENT-SPECIFIC PARAMETERS
    inputParams.exptCond = 'visstimLegFictracEphys'; % name of trial type
    % leg tracking camera frame rate - make sure it's a whole number of
    %  DAQ scans
    legCamFrameRate = settings.leg.frameRate; % in Hz
    legCamFrameRateScans = round(settings.bob.sampRate / legCamFrameRate);
    inputParams.legCamFrameRate = settings.bob.sampRate / ...
        legCamFrameRateScans;
    
    % which input and output data streams used in this experiment
    inputParams.aInCh = {'ampScaledOut', 'ampI', ...
        'amp10Vm', 'ampGain', 'ampFreq', 'ampMode', ...
        'ficTracHeading', 'ficTracIntX', 'ficTracIntY', 'panelsDAC0X',...
        'panelsDAC1Y'};
    inputParams.aOutCh = {'ampExtCmdIn'};
    inputParams.dInCh = {'ficTracCamFrames', 'legCamFrames'};
    inputParams.dOutCh = {'legCamFrameStartTrig'};
    
    % index for output channels: analog before digital
    iInjChInd = 1;
    legTrigChInd = 2;
    totNumOutCh = 2; % total number of output channels
    
    % initialize DAQ, including channels
    [userDAQ, ~, ~, ~, ~] = initUserDAQ(settings, ...
        inputParams.aInCh, inputParams.aOutCh, inputParams.dInCh, ...
        inputParams.dOutCh);
    % make DAQ acquisition continuous (runs until stopped)
    userDAQ.IsContinuous = true;
    
    % pre-allocate global variables
    % maximum number of scans in acquisition, with 5 second buffer
    maxNumScans = round((duration + 5) * userDAQ.Rate);
    % number of channels data is being acquired on
    numInCh = length(inputParams.aInCh) + length(inputParams.dInCh);
    % pre-allocate global variable for data acquired
    daqData = zeros(maxNumScans, numInCh);
    % number of channels data is being output on
    numOutCh = length(inputParams.aOutCh) + length(inputParams.dOutCh);
    % pre-allocate variable for data output
    daqOutput = zeros(maxNumScans, numOutCh);
    
    
    % GET FULL CURRENT INJECTION OUTPUT VECTOR
    % path to current injection protocol functions
    iPath = iInjDir();
    
    % remind user to flip ext. command switch on amplifier
    disp('Flip Ext. Command switch on 200B to ON');
    
    % prompt user to enter function call to current injection function
        % prompt user to select an experiment
    iInjSelected = 0;
    disp('Select a current injection protocol');
    while ~iInjSelected
        iInjTypeFileName = uigetfile('*.m', ...
            'Select a current injection protocol', iPath);
        % if user cancels or selects valid file
        if (iInjTypeFileName == 0)
            disp('Selection cancelled');
            iInjSelected = 1; % end loop
        elseif (contains(iInjTypeFileName, '.m'))
            disp(['Protocol: ' iInjTypeFileName]);
            iInjSelected = 1; % end loop
        else
            disp('Select a current injection .m file or cancel');
            iInjSelected = 0;
        end
    end

    % if user cancels at this point 
    if (iInjTypeFileName == 0)
        % throw error message; ends run of this function
        error('No current injection protocol was run. Ending ephysIInj()');
    end
    
    % convert selected experiment file into function handle
    % get name without .m
    iInjTypeName = extractBefore(iInjTypeFileName, '.');
    iInjFn = str2func(iInjTypeName);

    % run current injection function to get output vector
    try
        [iInjOut, iInjParams] = iInjFn(settings, maxNumScans); 
    catch %errMes
        % rethrow(errMes);
        error('Invalid current injection function. Ending ephysIInj()');
    end
    
    % save info into returned variables
    % record current injection function name
    inputParams.iInjProtocol = iInjTypeName; 
    inputParams.iInjParams = iInjParams; % current injection parameters
    
    
    % experiment timing info
    % delay start of acquisition on other hardware by 0.5 sec to ensure 
    %  user DAQ starts first and captures everything
    startDelay = 0.5; % in seconds
    startDelayScans = round(startDelay * userDAQ.Rate); % in scans
    % save actual into inputParams
    inputParams.startDelay = startDelayScans / userDAQ.Rate;
    
    % amount of data in seconds to queue each time DataRequired event is
    %  fired
    queuedLen = 1; 
    % queue in scans
    queuedScans = round(queuedLen * userDAQ.Rate);
    % adjust so that leg camera frames divide evenly into queue, so that
    %  triggers line up across different calls of DataRequired
    queuedScans = round(queuedScans / legCamFrameRateScans)...
        * legCamFrameRateScans;
    % save actual queued length into inputParams
    inputParams.queuedLen = queuedScans / userDAQ.Rate;
    
    % DataRequired event fires whenever queued data falls below threshold -
    %  use default here of 0.5 sec
    inputParams.queuedBelow = userDAQ.NotifyWhenScansQueuedBelow ...
        / userDAQ.Rate;
    
    % how often to fire DataAvailable event for background acquisition (0.5
    %  sec)
    dataAvailExceeds = 0.5; % in seconds
    dataAvailExceedsScans = round(dataAvailExceeds * userDAQ.Rate); % in scans
    % save actual into inputParams
    inputParams.dataAvailExceeds = dataAvailExceedsScans / userDAQ.Rate;
    % set value on DAQ
    userDAQ.NotifyWhenDataAvailableExceeds = dataAvailExceedsScans;
    
    % delay end of acquisition on user DAQ by queue length * 2 
    %  plus threshold of DataRequired event to ensure user DAQ captures 
    %  everything
    inputParams.endDelay = inputParams.queuedLen * 2 + ...
        inputParams.queuedBelow;
    
    % save initial experiment duration here into inputParams
    inputParams.initialExptDuration = duration; 

    
    % QUEUE INITIAL OUTPUT - leg camera frame triggers and current inj
    % number of scans to queue initially - delay + initial bout of data
    numScans = startDelayScans + queuedScans;
    
    outputInit = zeros(numScans, totNumOutCh); % preallocate
    legCamStartInd = startDelayScans + 1;
    
    % current injection output: delay and then start protocol
    outputInit((startDelayScans+1):numScans, iInjChInd) = ...
        iInjOut(1:(numScans-startDelayScans));

    % generate trigger pattern for leg camera - starts with 0 for start
    %  delay time, then a 1 at leg camera frame rate
    outputInit(legCamStartInd:legCamFrameRateScans:end, legTrigChInd) = 1;
    
    % queue output on DAQ
    userDAQ.queueOutputData(outputInit);
    
    % save queued output into daqOutput
    lengthOut = size(outputInit, 1);
    daqOutput(whichOutScan:(whichOutScan + lengthOut - 1),:) = ...
        outputInit;
    % update whichOutScan for next iteration
    whichOutScan = whichOutScan + lengthOut;
    
    % generate leg camera trigger pattern (to be queued after intial set)
    legCamTrig = zeros(queuedScans, 1);
    % trigger pattern for leg camera
    legCamTrig(1:legCamFrameRateScans:end) = 1;
       
    % output matrix preallocate
    outputMatrix = zeros(queuedScans, totNumOutCh);
    
    % output matrix of all zeros, for end
    outputMatrixEnd = zeros(queuedScans, totNumOutCh);
    
    % nested function for queuing more leg camera trigger outputs; called
    %  by event listener for DataRequired
    function queueOut(src, event)
        if ~acqStopBin
            % add leg camera triggers to output matrix
            outputMatrix(:, legTrigChInd) = legCamTrig;
            % grab next set of output from current injection
            iInjStartInd = whichOutScan - startDelayScans;
            iInjEndInd = whichOutScan + queuedScans - startDelayScans - 1;
            outputMatrix(:, iInjChInd) = iInjOut(iInjStartInd:iInjEndInd);
            
            queueOutputData(src, outputMatrix);
            
            % save queued output into daqOutput
            lenOut = size(outputMatrix, 1);
            daqOutput(whichOutScan:(whichOutScan + lenOut - 1),:) = ...
                outputMatrix;
        else % when DAQ acquisition is stopped
            queueOutputData(src, outputMatrixEnd);
            
            % save queued output into daqOutput
            lenOut = size(outputMatrixEnd, 1);
            daqOutput(whichOutScan:(whichOutScan + lenOut - 1),:) = ...
                outputMatrixEnd;
        end
        % update whichOutScan for next iteration
        whichOutScan = whichOutScan + lenOut;
    end
    
    % create listeners for DataAvailable and DataRequired events
    dataAvailLh = addlistener(userDAQ, 'DataAvailable', @collectData);
    dataReqLh = addlistener(userDAQ, 'DataRequired', @queueOut);
    
    
    % Prompt user for visual stimulus input variables
    visstimParams = visstimUserPrompts(settings);
    
    % send information to visual panels
    initalizeVisualPanels(visstimParams, settings);
    
    % merge visual stimulus parameters into inputParams struct
    inputParams = mergeStructs(inputParams, visstimParams);
    
    % first time leg video is acquired for cell
    %  set up folder for saving leg video, prompt to set up camera
    %  appropriately
    if firstLegVidTrial 
        % make folder for raw images
        mkdir('rawLegVid');
        % raw leg video full path
        legVidFileName = sprintf('%s%srawLegVid%slegVid', pwd, filesep, ... 
            filesep);
        % copy path to clipboard
        clipboard('copy', legVidFileName);
        % prompt user to copy path into spinview
        prompt = ['Leg Video Acquisition. \n'...
            'Press RECORD button and paste directory from system clipboard '...
            'into the *Filename* section. \n Set *Image Format* to Tiff ' ... 
            'and *Compression Method* to Rle. Then press Start Recording.' ...
            '\n Make sure camera is acquiring (green play button). \n' ...
            'Press Enter when done with these steps.'];
        input(prompt, 's');
    end
    
    % prompt user for current number of leg vid frames grabbed
    prompt = 'Enter current number of leg video frames grabbed: ';
    inputParams.startLegVidNum = str2double(input(prompt, 's'));

    % get time stamp of approximate experiment start
    inputParams.startTimeStamp = datestr(now, 'HH:MM:SS');
    fprintf('Start time: %s \n', inputParams.startTimeStamp);
    disp('Starting visstimLegFictracEphys acquisition');
    
    % ACQUIRE IN BACKGROUND
    userDAQ.startBackground();
    
    % start visual panels
    Panel_com('start');
    
    % total number of scans (less than maxNumScans, which has 5 sec buffer
    totNumScans = round(duration * userDAQ.Rate);
    % loop that allows acquisition to stop smoothly 
    while 1
        % if any key on keyboard is pressed, initialize stopping of
        %  acquisition; or if specified duration of acquisition is reached
        if ((KbCheck) || (userDAQ.ScansAcquired > totNumScans))
            % binary, will stop triggering leg camera through
            %  queueLegTrig function
            acqStopBin = 1;
            disp('Stopping acquisition, please wait');
            % pause to give DAQ enough time to stop triggering leg camera
            %  and acquire all data
            pause(inputParams.endDelay);
            break; % stop loop            
        end
        % this loop doesn't need to go that quickly to register keyboard
        %  presses
        pause(0.2);
    end
    
    % stop visual panels
    Panel_com('stop');
    
    % once looping stops, stop acquisition
    userDAQ.stop();
    disp('Acquisition stopped');
    fprintf('End time: %s \n', datestr(now, 'HH:MM:SS'));
    
    % save actual experiment duration into inputParams
    inputParams.actualExptDuration = userDAQ.ScansAcquired / userDAQ.Rate;
    
    % only keep data and output up until point when acquisition stopped
    daqData = daqData(1:userDAQ.ScansAcquired, :);
    daqOutput = daqOutput(1:userDAQ.ScansAcquired, :);
    
    % display number of leg video frames triggered 
    numLegVidTrigs = sum(daqOutput(:,legTrigChInd));
    fprintf('%d leg video frames triggered.\n', numLegVidTrigs);
    
    % prompt user for current number of leg video frames grabbed
    prompt = 'Enter current number of leg video frames grabbed: ';
    inputParams.endLegVidNum = str2double(input(prompt, 's'));
    
    % display total number of leg video frames acquired
    numLegVidAcq = inputParams.endLegVidNum - inputParams.startLegVidNum;
    fprintf('%d leg video frames grabbed. \n', numLegVidAcq);
    
    % save global variables into variables returned by this function
    rawData = daqData;
    rawOutput = daqOutput;
    
    % delete global variable
    clear global daqData
    
    % delete listeners
    delete(dataAvailLh);
    delete(dataReqLh);
end
