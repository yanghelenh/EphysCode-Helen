% visstimLegFictracEphys.m
%
% Experimental Function
% For simultaneous presentation of visual stimuli on G3 panels and 
%  acquisition of leg video, FicTrac, and electrophysiology recording.
% Uses background acquisition on DAQ
% No current injection; use visstimLegFictracEphysIInj() instead
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
% CREATED: 2/8/21 - HHY
%
% UPDATED:
%   2/8/21
%
function [rawData, inputParams, rawOutput] = visstimLegFictracEphys(...
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
    legCamFrameRate = 250; % in Hz
    legCamFrameRateScans = round(settings.bob.sampRate / legCamFrameRate);
    inputParams.legCamFrameRate = settings.bob.sampRate / ...
        legCamFrameRateScans;
    
    % which input and output data streams used in this experiment
    inputParams.aInCh = {'ampScaledOut', 'ampI', ...
        'amp10Vm', 'ampGain', 'ampFreq', 'ampMode', ...
        'ficTracHeading', 'ficTracIntX', 'ficTracIntY', 'panelsDAC0X',...
        'panelsDAC1Y'};
    inputParams.aOutCh = {};
    inputParams.dInCh = {'ficTracCamFrames', 'legCamFrames'};
    inputParams.dOutCh = {'legCamFrameStartTrig'};
    
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
    legTrigQueuedLen = 1; 
    % queue in scans
    legTrigQueuedScans = round(legTrigQueuedLen * userDAQ.Rate);
    % adjust so that leg camera frames divide evenly into queue, so that
    %  triggers line up across different calls of DataRequired
    legTrigQueuedScans = round(legTrigQueuedScans / legCamFrameRateScans)...
        * legCamFrameRateScans;
    % save actual queued length into inputParams
    inputParams.legTrigQueuedLen = legTrigQueuedScans / userDAQ.Rate;
    
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
    numScans = startDelayScans + legTrigQueuedScans;
    
    legCamTrigInit = zeros(numScans, 1);
    legCamStartInd = startDelayScans + 1;

    % generate trigger pattern for leg camera - starts with 0 for start
    %  delay time, then a 1 at leg camera frame rate
    legCamTrigInit(legCamStartInd:legCamFrameRateScans:end) = 1;
    
    % queue output on DAQ
    userDAQ.queueOutputData(legCamTrigInit);
    
    % save queued output into daqOutput
    lengthOut = length(legCamTrigInit);
    daqOutput(whichOutScan:(whichOutScan + lengthOut - 1)) = ...
        legCamTrigInit;
    % update whichOutScan for next iteration
    whichOutScan = whichOutScan + lengthOut;
    
    % generate leg camera trigger pattern (to be queued after intial set)
    legCamTrig = zeros(legTrigQueuedScans, 1);
    % trigger pattern for leg camera
    legCamTrig(1:legCamFrameRateScans:end) = 1;
    
    % generate leg camera trigger pattern of all zeros (for end)
    legCamTrigEnd = zeros(legTrigQueuedScans, 1);
    
    % nested function for queuing more leg camera trigger outputs; called
    %  by event listener for DataRequired
    function queueLegTrig(src, event)
        if ~acqStopBin
            queueOutputData(src, legCamTrig);
            
            % save queued output into daqOutput
            lenOut = length(legCamTrig);
            daqOutput(whichOutScan:(whichOutScan + lenOut - 1)) = ...
                legCamTrig;
        else % when DAQ acquisition is stopped
            queueOutputData(src, legCamTrigEnd);
            
            % save queued output into daqOutput
            lenOut = length(legCamTrigEnd);
            daqOutput(whichOutScan:(whichOutScan + lenOut - 1)) = ...
                legCamTrigEnd;
        end
        % update whichOutScan for next iteration
        whichOutScan = whichOutScan + lenOut;
    end
    
    % create listeners for DataAvailable and DataRequired events
    dataAvailLh = addlistener(userDAQ, 'DataAvailable', @collectData);
    dataReqLh = addlistener(userDAQ, 'DataRequired', @queueLegTrig);
    
    
    % Prompt user for visual stimulus input variables
    
    % prompt user for whether to run visual stimuli in open or closed loop
    prompt = ['Select the mode the visual stimulus should run in \n' ...
        'Closed loop, X only (cx)\n Closed loop, Y only (cy)\n' ...
        'Closed loop, X and Y (cxy)\n Open loop (o)\n'];
    modeAns = input(prompt, 's');
    % set the mode, record it
    % NOTE: check the setting for only 1 channel in closed loop!!
    switch modeAns
        case 'cx'
            inputParams.visstimMode = 'closedLoopX';
            inputParams.panelMode = [settings.visstim.closedloopMode, ...
                settings.visstim.intfuncMode];
        case 'cy'
            inputParams.visstimMode = 'closedLoopY';
            inputParams.panelMode = [settings.visstim.intfuncMode, ...
                settings.visstim.closedloopMode];
        case 'cxy'
            inputParams.visstimMode = 'closedLoopXY';
            inputParams.panelMode = [settings.visstim.closedloopMode, ...
                settings.visstim.closedloopMode];
        case 'o'
            inputParams.visstimMode = 'openLoop';
            inputParams.panelMode = [settings.visstim.openloopMode, ...
                settings.visstim.openloopMode];
        otherwise
            disp('Improper input, defaulting to open loop');
            inputParams.visstimMode = 'openLoop';
            inputParams.panelMode = [settings.visstim.openloopMode, ...
                settings.visstim.openloopMode];
    end
    
    % prompt for pattern, by selecting from list
    % get list of patterns (from list of files in pattern directory)
    patternFiles = dir(vsPatternsDir());
    patternList = {patternFiles.name};
    patternList = patternList(3:end); % remove . and .. from list
    % boolean for whether user has selected a pattern, initialize at 0
    patternSelected = 0;
    % loop until user selects pattern
    while ~patternSelected
        [patternIndex, patternSelected] = listdlg('ListString', ...
            patternList, 'PromptString', 'Select a pattern', ...
            'SelectionMode', 'single');
    end
    % save pattern name and index
    inputParams.patternName = patternList(patternIndex);
    inputParams.patternIndex = patternIndex;
    
    % prompt user for initial pattern position, as [X,Y]
    prompt = 'Initial pattern position [x,y]: ';
    initPatternPos = str2num(input(prompt, 's'));
    inputParams.initPatternPos = initPatternPos;
    
    % if open loop, prompt user for X and Y functions
    if (strcmp(inputParams.visstimMode,'openLoop'))
        % prompt for X function, by selecting from list
        % get list of visual stimuli functions (from list of files in
        %  function directory)
        funcFiles = dir(vsFunctionsDir());
        funcList = {funcFiles.name};
        funcList = funcList(3:end); % remove . and .. from list
        % boolean for whether user has selected an X function, initialize
        xFuncSelected = 0;
        % loop until user selects an x function
        while ~xFuncSelected
            [xFuncIndex, xFuncSelected] = listdlg('ListString', ...
                funcList, 'PromptString', 'Select a function', ...
                'SelectionMode', 'single');
        end
        % prompt user for Y function
        yFuncSelected = 0;
        while ~yFuncSelected
            [yFuncIndex, yFuncSelected] = listdlg('ListString', ...
                funcList, 'PromptString', 'Select a function', ...
                'SelectionMode', 'single');
        end
        % save function names and indices
        inputParams.xFuncName = funcList(xFuncIndex);
        inputParams.xFuncIndex = xFuncIndex;
        inputParams.yFuncName = funcList(yFuncIndex);
        inputParams.yFuncIndex = yFuncIndex;
    end
    
    % if closed loop, prompt user for gain
    if (contains(inputParams.visstimMode, 'closedLoop'))
       if (contains(inputParams.visstimMode, 'X'))
           prompt = 'Gain for X: ';
           xGain = str2num(input(prompt,'s'));
           inputParams.xGain = xGain;
       end
       if (contains(inputParams.visstimMode, 'Y'))
           prompt = 'Gain for Y: ';
           yGain = str2num(input(prompt, 's'));
           inputParams.yGain = yGain;
       end
    end
    
    % send information to visual panels
    initalizeVisualPanels(panelParams, settings);
    
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
    disp('Starting legFictracEphys acquisition');
    
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
    numLegVidTrigs = sum(daqOutput);
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