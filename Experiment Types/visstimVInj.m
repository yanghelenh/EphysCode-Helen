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
    
    % Prompt user for visual stimulus input variables
    visstimParams = visstimUserPrompts(settings);
    
    % send information to visual panels
    initalizeVisualPanels(visstimParams, settings);
    
    % merge visual stimulus parameters into inputParams struct
    inputParams = mergeStructs(inputParams, visstimParams);
    
    % select correct analog output channels depending on which type of
    %  closed loop
    switch inputParams.visstimMode
        case 'closedLoopX'
            inputParams.aOutCh = {'ampExtCmdIn'};
        case 'closedLoopY'
            inputParams.aOutCh ={'aOut1'};
        case 'closedLoopXY'
            inputParams.aOutCh = {'ampExtCmdIn', 'aOut1'};
        case 'openLoop'
            inputParams.aOutCh = {};
    end
    
    % initialize DAQ, including channels
    % here b/c which channels to initialize depends on open/closed loop
    [userDAQ, ~, ~, ~, ~] = initUserDAQ(settings, ...
        inputParams.aInCh, inputParams.aOutCh, inputParams.dInCh, ...
        inputParams.dOutCh);
    
    % trial duration in scans
    durScans = duration * userDAQ.Rate;
  
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
    else
        userDAQ.DurationInSeconds = duration;
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