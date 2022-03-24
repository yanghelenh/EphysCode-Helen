% legFictracOpto.m
%
% Experimental Function
% For simultaneous acquisition of leg video and FicTrac behavior data while
%  providing optogenetic stimulation by controlling the shutter in front of
%  the mercury lamp for the scope (light through objective)
% Uses background acquisition on DAQ
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
% CREATED: 2/20/22 - HHY
%
% UPDATED:
%   2/20/22 - HHY - modification of legFictracEphysIInj
%   2/21/22 - HHY - confirmed, works
%

function [rawData, inputParams, rawOutput] = legFictracOpto(settings, ...
    duration)

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
    inputParams.exptCond = 'legFictracOpto'; % name of trial type
    % leg tracking camera frame rate - make sure it's a whole number of
    %  DAQ scans
    legCamFrameRate = settings.leg.frameRate; % in Hz
    legCamFrameRateScans = round(settings.bob.sampRate / legCamFrameRate);
    inputParams.legCamFrameRate = settings.bob.sampRate / ...
        legCamFrameRateScans;
    
    % which input and output data streams used in this experiment
    inputParams.aInCh = {'ficTracHeading', 'ficTracIntX', 'ficTracIntY'};
    inputParams.aOutCh = {};
    inputParams.dInCh = {'ficTracCamFrames', 'HgLampShutterSyncOut', ...
        'legCamFrames'};
    inputParams.dOutCh = {'HgLampShutterPulseIn', 'legCamFrameStartTrig'};
    
    % index for output channels
    shutterChInd = 1;
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
    
    
    % GET FULL SHUTTER COMMAND VECTOR    
    % path to optostim protocol functions
    oPath = optoStimDir();
    
    % remind user to make sure shutter on scope open, right objective
    %  chosen, right ND filter
    disp('Check configuration on scope for opto stim');
    
    % prompt user to enter function call to optostim function
        % prompt user to select an experiment
    oStimSelected = 0;
    disp('Select an optogenetic stimulation protocol');
    while ~oStimSelected
        oStimTypeFileName = uigetfile('*.m', ...
            'Select an optogenetic stimulation protocol', oPath);
        % if user cancels or selects valid file
        if (oStimTypeFileName == 0)
            disp('Selection cancelled');
            oStimSelected = 1; % end loop
        elseif (contains(oStimTypeFileName, '.m'))
            disp(['Protocol: ' oStimTypeFileName]);
            oStimSelected = 1; % end loop
        else
            disp('Select an optogenetic stimulation .m file or cancel');
            oStimSelected = 0;
        end
    end

    % if user cancels at this point 
    if (oStimTypeFileName == 0)
        % throw error message; ends run of this function
        error('No optogenetic stimulation protocol was run. Ending legFictracOpto()');
    end
    
    % convert selected experiment file into function handle
    % get name without .m
    oStimTypeName = extractBefore(oStimTypeFileName, '.');
    optoStimFn = str2func(oStimTypeName);

    % run optogenetic stimulation function to get output vector
    try
        [optoStimOut, optoStimParams] = optoStimFn(settings, maxNumScans); 
    catch %errMes
        % rethrow(errMes);
        error('Invalid optogenetic stimulation function. Ending legFictracOpto()');
    end
    
    % save info into returned variables
    % record optostim function name
    inputParams.optoStimProtocol = oStimTypeName; 
    inputParams.optoStimParams = optoStimParams; % optoStim parameters
    
    
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
    
    
    % QUEUE INITIAL OUTPUT - leg camera frame triggers and optostim
    % number of scans to queue initially - delay + initial bout of data
    numScans = startDelayScans + queuedScans;
    
    outputInit = zeros(numScans, totNumOutCh); % preallocate
    legCamStartInd = startDelayScans + 1;
    
    % optostim output: delay and then start protocol
    outputInit((startDelayScans+1):numScans, shutterChInd) = ...
        optoStimOut(1:(numScans-startDelayScans));

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
    
    % nested function for queuing more outputs; called
    %  by event listener for DataRequired
    function queueOut(src, event)
        if ~acqStopBin
            % add leg camera triggers to output matrix
            outputMatrix(:, legTrigChInd) = legCamTrig;
            % grab next set of output from opto stim
            oStimStartInd = whichOutScan - startDelayScans;
            oStimEndInd = whichOutScan + queuedScans - startDelayScans - 1;
            outputMatrix(:, shutterChInd) = optoStimOut(oStimStartInd:oStimEndInd);
            
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
    disp('Starting legFictracOpto acquisition');
    
    % ACQUIRE IN BACKGROUND
    
    userDAQ.startBackground();
    
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
    
    % once looping stops, stop acquisition
    userDAQ.stop();
    % to stop it from presenting non-zero values if optostim
    %  protocol ends on non-zero value
    userDAQ.outputSingleScan([0, 0]);
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