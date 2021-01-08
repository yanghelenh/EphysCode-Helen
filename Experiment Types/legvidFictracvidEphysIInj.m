% legFictracvidEphysIInj.m
%
% Experimental Function
% For simultaneous acquisition of leg video, FicTrac video, 
%  electrophysiology recording, and current injection
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
% CREATED: 3/11/20 - HHY
%
% UPDATED:
%   3/11/20 - HHY
%   3/23/20 - HHY
%   9/3/20 - HHY - fixed startDelay, dataAvailExceeds,
%       actualExperimentDuration fields of inputParams (multiplied instead
%       of divided by scan rate); changed leg video frame rate to 225 Hz
%   12/16/20 - HHY - made this function as modificiation of
%       legvidFictracEphys
%   1/7/21 - HHY - modify this code to accomodate code being run on both
%       computers (experimental running this and FicTrac computer)
%   1/7/21 - HHY - modify this code from legFictracvidEphys, adding current
%       injection
%   1/8/21 - HHY - prompt user to record number of FicTrac video frames
%       grabbed through functions run on FicTrac computer
%

function [rawData, inputParams, rawOutput] = legvidFictracvidEphysIInj(...
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
    inputParams.exptCond = 'legvidFictracvidEphys'; % name of trial type
    % leg tracking camera frame rate - make sure it's a whole number of
    %  DAQ scans
    legCamFrameRate = 250; % in Hz
    legCamFrameRateScans = round(settings.bob.sampRate / legCamFrameRate);
    inputParams.legCamFrameRate = settings.bob.sampRate / ...
        legCamFrameRateScans;
    
    % FicTrac camera frame rate - make sure it's a whole number of DAQ
    %  scans
    ftCamFrameRate = 150; % in Hz
    ftCamFrameRateScans = round(settings.bob.sampRate / ftCamFrameRate);
    inputParams.ftCamFrameRate = settings.bob.sampRate / ...
        ftCamFrameRateScans;
    
    % which input and output data streams used in this experiment
    inputParams.aInCh = {'ampScaledOut', 'ampI', ...
        'amp10Vm', 'ampGain', 'ampFreq', 'ampMode'};
    inputParams.aOutCh = {};
    inputParams.dInCh = {'ficTracCamFrames', 'legCamFrames'};
    inputParams.dOutCh = {'legCamFrameStartTrig', 'ficTracCamStartTrig'};
    
    % index for output channels: analog before digital
    iInjChInd = 1;
    legTrigChInd = 2;
    ftTrigChInd = 3;
    totNumOutCh = 3; % total number of output channels
    
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
    
    % timing for triggers to leg camera
    % amount of data in seconds to queue each time DataRequired event is
    %  fired
    camTrigQueuedLen = 1; 
    % queue in scans
    camTrigQueuedScans = round(camTrigQueuedLen * userDAQ.Rate);
    % adjust so that leg camera frames and FicTrac camera frames both 
    %  divide evenly into queue, so that triggers line up across differen
    %  calls of DataRequired
    % get least common multiple of leg and FicTrac camera frame rates
    lcmCamFrameRates = lcm(legCamFrameRateScans, ftCamFrameRateScans);
    % use LCM to determine amount of data to queue (in scans)
    camTrigQueuedScans = round(camTrigQueuedScans / lcmCamFrameRates)...
        * lcmCamFrameRates;
    % save actual queued length into inputParams
    inputParams.legTrigQueuedLen = camTrigQueuedScans / userDAQ.Rate;
    
    % DataRequired event fires whenever queued data falls below threshold -
    %  use default here of 0.5 sec
    inputParams.legTrigQueuedBelow = userDAQ.NotifyWhenScansQueuedBelow ...
        / userDAQ.Rate;
    
    % how often to fire DataAvailable event for background acquisition (0.5
    %  sec)
    dataAvailExceeds = 0.5; % in seconds
    dataAvailExceedsScans = round(dataAvailExceeds * userDAQ.Rate); % in scans
    % save actual into inputParams
    inputParams.dataAvailExceeds = dataAvailExceedsScans / userDAQ.Rate;
    % set value on DAQ
    userDAQ.NotifyWhenDataAvailableExceeds = dataAvailExceedsScans;
    
    % delay end of acquisition on user DAQ by leg trigger queue length * 2 
    %  plus threshold of DataRequired event to ensure user DAQ captures 
    %  everything
    inputParams.endDelay = inputParams.legTrigQueuedLen * 2 + ...
        inputParams.legTrigQueuedBelow;
    
    % save initial experiment duration here into inputParams
    inputParams.initialExptDuration = duration; 

    
    % QUEUE INITIAL OUTPUT - leg camera frame triggers
    % number of scans to queue initially - delay + initial bout of data
    numScans = startDelayScans + camTrigQueuedScans;
    
    legCamTrigInit = zeros(numScans, 1);
    ftCamTrigInit = zeros(numScans, 1);
    bothCamStartInd = startDelayScans + 1;
    
    % current injection output: delay and then start protocol
    outputInit((startDelayScans+1):numScans, iInjChInd) = ...
        iInjOut(1:(numScans-startDelayScans));

    % generate trigger pattern for leg camera - starts with 0 for start
    %  delay time, then a 1 at leg camera frame rate
    legCamTrigInit(bothCamStartInd:legCamFrameRateScans:end) = 1;
    
    % generate trigger pattern for FicTrac camera
    ftCamTrigInit(bothCamStartInd:ftCamFrameRateScans:end) = 1;
    
    % combine trigger patterns into output matrix
    trigOutput = [legCamTrigInit ftCamTrigInit];
    
    % queue output on DAQ
    userDAQ.queueOutputData(trigOutput);
    
    % save queued output into daqOutput
    lengthOut = size(trigOutput,1);
    daqOutput(whichOutScan:(whichOutScan + lengthOut - 1),:) = trigOutput;
    % update whichOutScan for next iteration
    whichOutScan = whichOutScan + lengthOut;
    
    % generate leg camera trigger pattern (to be queued after intial set)
    legCamTrig = zeros(camTrigQueuedScans, 1);
    % trigger pattern for leg camera
    legCamTrig(1:legCamFrameRateScans:end) = 1;
    % generate FicTrac camera trigger pattern
    ftCamTrig = zeros(camTrigQueuedScans, 1);
    ftCamTrig(1:ftCamFrameRateScans:end) = 1;
    
    % output matrix preallocate
    outputMatrix = zeros(camTrigQueuedScans, totNumOutCh);
    
    % output matrix of all zeros, for end
    outputMatrixEnd = zeros(camTrigQueuedScans, totNumOutCh);
    
    % nested function for queuing more leg camera trigger outputs; called
    %  by event listener for DataRequired
    function queueOut(src, event)
        if ~acqStopBin
            % add leg camera triggers to output matrix
            outputMatrix(:, legTrigChInd) = legCamTrig;
            % add FicTrac camera triggers to output matrix
            outputMatrix(:, ftTrigChInd) = ftCamTrig;
            % grab next set of output from current injection
            iInjStartInd = whichOutScan - startDelayScans;
            iInjEndInd = whichOutScan + camTrigQueuedScans - ...
                startDelayScans - 1;
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
    dataReqLh = addlistener(userDAQ, 'DataRequired', @queueCamTrig);
    
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
        disp('Make sure the same is set up on the FicTrac computer');
    end
    
    % prompt user for current number of leg vid frames grabbed
    prompt = 'Enter current number of leg video frames grabbed: ';
    inputParams.startLegVidNum = str2double(input(prompt, 's'));
    
    % prompt user to run saveFictracImgCount() on FicTrac computer
    prompt = ['On FicTrac computer, run saveFictracImgCount(). \n' ...
        'Press Enter when done'];
    input(prompt, 's');
    
    % get time stamp of approximate experiment start
    inputParams.startTimeStamp = datestr(now, 'HH:MM:SS');
    fprintf('Start time: %s \n', inputParams.startTimeStamp);
    disp('Starting legvidFictracvidEphysIInj acquisition');
    
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
    disp('Acquisition stopped');
    fprintf('End time: %s \n', datestr(now, 'HH:MM:SS'));
    
    % save actual experiment duration into inputParams
    inputParams.actualExptDuration = userDAQ.ScansAcquired / userDAQ.Rate;
    
    % only keep data and output up until point when acquisition stopped
    daqData = daqData(1:userDAQ.ScansAcquired, :);
    daqOutput = daqOutput(1:userDAQ.ScansAcquired, :);
    
    % display number of leg video frames triggered 
    numLegVidTrigs = sum(daqOutput(:,1));
    fprintf('%d leg video frames triggered.\n', numLegVidTrigs);
    % display number of FicTrac video frames triggered
    numFtVidTrigs = sum(daqOutput(:,2));
    fprintf('%d FicTrac video frames triggered.\n', numFtVidTrigs);
    disp('Make sure to record number of FicTrac video frames grabbed');
    
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