% visstimVInj.m
%
% Trial Type Function 
% Plays visual stimulus in closed loop, with voltage signal coming from DAQ
%  itself. Records visual controller output
% For testing closed loop
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
% CREATED: 2/11/21 - HHY
%
% UPDATED: 
%   2/11/21 - HHY
%

function [rawData, inputParams, rawOutput] = visstimVInj(settings, ...
    duration)

    % EXPERIMENT-SPECIFIC PARAMETERS
    inputParams.exptCond = 'visstimVInj'; % name of trial type
    
    % which input and output data streams used in this experiment
    inputParams.aInCh = {'panelsDAC0X', 'panelsDAC1Y'};
    inputParams.dInCh = {};
    inputParams.dOutCh = {};
    
    % save trial duration here into inputParams
    inputParams.trialDuration = duration; 
     
    % prompt user to select visual stimulus
    
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
            inputParams.aOutCh = {'ampExtCmdIn'};
        case 'cy'
            inputParams.visstimMode = 'closedLoopY';
            inputParams.panelMode = [settings.visstim.intfuncMode, ...
                settings.visstim.closedloopMode];
            inputParams.aOutCh ={'aOut1'};
        case 'cxy'
            inputParams.visstimMode = 'closedLoopXY';
            inputParams.panelMode = [settings.visstim.closedloopMode, ...
                settings.visstim.closedloopMode];
            inputParams.aOutCh = {'ampExtCmdIn', 'aOut1'};
        case 'o'
            inputParams.visstimMode = 'openLoop';
            inputParams.panelMode = [settings.visstim.openloopMode, ...
                settings.visstim.openloopMode];
            inputParams.aOutCh = {};
        otherwise
            disp('Improper input, defaulting to closedLoopXY');
            inputParams.visstimMode = 'closedLoopXY';
            inputParams.panelMode = [settings.visstim.closedloopMode, ...
                settings.visstim.closedloopMode];
            inputParams.aOutCh = {'ampExtCmdIn', 'aOut1'};
    end
    
    % initialize DAQ, including channels
    % here b/c which channels to initialize depends on open/closed loop
    [userDAQ, ~, ~, ~, ~] = initUserDAQ(settings, ...
        inputParams.aInCh, inputParams.aOutCh, inputParams.dInCh, ...
        inputParams.dOutCh);
    
    % trial duration in scans
    durScans = duration * userDAQ.Rate;
    
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
    
    % initialize visual panels
    initalizeVisualPanels(inputParams, settings);
        
    % path to current injection protocol functions
    vPath = vInjDir();
    
    if (contains(inputParams.visstimMode, 'closedLoop'))
       if (contains(inputParams.visstimMode, 'X'))
            % prompt user to enter function call to voltage function, for X
                % prompt user to select an experiment
            vInjSelected = 0;
            disp('Select a voltage protocol for X');
            while ~vInjSelected
                vInjTypeFileNameX = uigetfile('*.m', ...
                    'Select a voltage protocol', vPath);
                % if user cancels or selects valid file
                if (vInjTypeFileNameX == 0)
                    disp('Selection cancelled');
                    vInjSelected = 1; % end loop
                elseif (contains(vInjTypeFileNameX, '.m'))
                    disp(['Protocol: ' vInjTypeFileNameX]);
                    vInjSelected = 1; % end loop
                else
                    disp('Select a voltage injection .m file or cancel');
                    vInjSelected = 0;
                end
            end

            % if user cancels at this point 
            if (vInjTypeFileNameX == 0)
                % throw error message; ends run of this function
                error('No voltage injection protocol was run. Ending visstimVInj()');
            end

            % convert selected experiment file into function handle
            % get name without .m
            vInjTypeNameX = extractBefore(vInjTypeFileNameX, '.');
            vInjFnX = str2func(vInjTypeNameX);

            % run voltage injection function to get output vector
            try
                [vInjOutX, vInjParamsX] = vInjFnX(settings, durScans); 
            catch %errMes
                % rethrow(errMes);
                error('Invalid voltage injection function. Ending visstimVInj()');
            end
            
            % record voltage injection name and parameters
            inputParams.vInjProtocolX = vInjTypeNameX; 
            inputParams.vInjParamsX = vInjParamsX;
       end
       if (contains(inputParams.visstimMode, 'Y'))
            % prompt user to enter function call to voltage function, for Y
                % prompt user to select an experiment
            vInjSelected = 0;
            disp('Select a voltage protocol for Y');
            while ~vInjSelected
                vInjTypeFileNameY = uigetfile('*.m', ...
                    'Select a voltage protocol', vPath);
                % if user cancels or selects valid file
                if (vInjTypeFileNameY == 0)
                    disp('Selection cancelled');
                    vInjSelected = 1; % end loop
                elseif (contains(vInjTypeFileNameY, '.m'))
                    disp(['Protocol: ' vInjTypeFileNameY]);
                    vInjSelected = 1; % end loop
                else
                    disp('Select a voltage injection .m file or cancel');
                    vInjSelected = 0;
                end
            end

            % if user cancels at this point 
            if (vInjTypeFileNameY == 0)
                % throw error message; ends run of this function
                error('No voltage injection protocol was run. Ending visstimVInj()');
            end

            % convert selected experiment file into function handle
            % get name without .m
            vInjTypeNameY = extractBefore(vInjTypeFileNameY, '.');
            vInjFnY = str2func(vInjTypeNameY);

            % run voltage injection function to get output vector
            try
                [vInjOutY, vInjParamsY] = vInjFnY(settings, durScans); 
            catch %errMes
                % rethrow(errMes);
                error('Invalid voltage injection function. Ending visstimVInj()');
            end
            
            % record voltage injection name and parameters
            inputParams.vInjProtocolY = vInjTypeNameY;
            inputParams.vInjParamsY = vInjParamsY;
        end
    end
    
    % output command
    if (exist('vInjOutX', 'var') && exist('vInjOutY', 'var'))
        vInjOut = [vInjOutX vInjOutY];
    elseif (exist('vInjOutX', 'var'))
        vInjOut = vInjOutX;
    elseif (exist('vInjOutY', 'var'))
        vInjOut = vInjOutY;
    else
        vInjOut = [];
    end
    
    % save info into returned variables
    rawOutput = vInjOut; % output commanded into rawOutput
    
    if (~isempty(vInjOut))
        % queue current injection output
        userDAQ.queueOutputData(vInjOut);
    end
    
    % get time stamp of approximate experiment start
    inputParams.startTimeStamp = datestr(now, 'HH:MM:SS');
    
    disp('Starting visstimVInj experiment');
    % start visual panels
    Panel_com('start');
    
    % acquire data (in foreground)
    rawData = userDAQ.startForeground();
    
    % stop visual panels
    Panel_com('stop');

    disp('Data acquired');
end