% visstimEphys.m
%
% Trial Type Function 
% Presents visual stimuli on G3 panels. Records electrophysiology data. No
%  current/voltage injection
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
%       different channel (this is here because trial type functions follow
%       this format, but there is no rawOutput for this type)
%
% CREATED: 2/11/21 - HHY
%
% UPDATED: 
%   2/11/21 - HHY
%

function [rawData, inputParams, rawOutput] = visstimEphys(settings, ...
    duration)

    % EXPERIMENT-SPECIFIC PARAMETERS
    inputParams.exptCond = 'visstimEphys'; % name of trial type
    
    % which input and output data streams used in this experiment
    inputParams.aInCh = {'ampScaledOut', 'ampI', ...
        'amp10Vm', 'ampGain', 'ampFreq', 'ampMode', 'panelsDAC0X',...
        'panelsDAC1Y'};
    inputParams.aOutCh = {};
    inputParams.dInCh = {};
    inputParams.dOutCh = {};
    
    % output matrix - empty for this trial type (there are no output
    %  channels initialized for DAQ; no current injection, triggers, etc)
    % placeholder for different trial types
    rawOutput = [];
    
    % save trial duration here into inputParams
    inputParams.trialDuration = duration; 

    % initialize DAQ, including channels
    [userDAQ, ~, ~, ~, ~] = initUserDAQ(settings, ...
        inputParams.aInCh, inputParams.aOutCh, inputParams.dInCh, ...
        inputParams.dOutCh);
    
    % set duration of acquisition
    userDAQ.DurationInSeconds = duration;
    
    % Prompt user for visual stimulus input variables
    
    % prompt user for whether to run visual stimuli in open or closed loop
    prompt = ['Select the mode the visual stimulus should run in \n' ...
        'Closed loop, X only (cx)\nClosed loop, Y only (cy)\n' ...
        'Closed loop, X and Y (cxy)\nOpen loop (o)\n'];
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
    disp('Select a pattern');
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
        disp('Select an X function');
        % loop until user selects an x function
        while ~xFuncSelected
            [xFuncIndex, xFuncSelected] = listdlg('ListString', ...
                funcList, 'PromptString', 'Select an X function', ...
                'SelectionMode', 'single');
        end
        % prompt user for Y function
        yFuncSelected = 0;
        disp('Select a Y function');
        while ~yFuncSelected
            [yFuncIndex, yFuncSelected] = listdlg('ListString', ...
                funcList, 'PromptString', 'Select a Y function', ...
                'SelectionMode', 'single');
        end
        % save function names and indices
        inputParams.xFuncName = funcList(xFuncIndex);
        inputParams.xFuncIndex = xFuncIndex;
        inputParams.yFuncName = funcList(yFuncIndex);
        inputParams.yFuncIndex = yFuncIndex;
    end
    
    % send information to visual panels
    initalizeVisualPanels(inputParams, settings);
    
    % get time stamp of approximate experiment start
    inputParams.startTimeStamp = datestr(now, 'HH:MM:SS');
    
    disp('Starting visstimEphys acquisition');
    
    % start visual panels
    Panel_com('start');
    
    % acquire data (in foreground)
    rawData = userDAQ.startForeground();
    
    % stop visual panels
    Panel_com('end');

    disp('Data acquired');
end