% ephysIInj.m
%
% Trial Type Function 
% Records ephys channels, performs current injection
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
% CREATED: 7/17/20 - HHY
% UPDATED: 
%   7/17/20 - HHY
%   7/23/20 - HHY - prevent it from constantly outputting last analog
%       output value, if non-zero
%

function [rawData, inputParams, rawOutput] = ephysIInj(settings, ...
    duration)

    % EXPERIMENT-SPECIFIC PARAMETERS
    inputParams.exptCond = 'ephysIInj'; % name of trial type
    
    % which input and output data streams used in this experiment
    inputParams.aInCh = {'ampScaledOut', 'ampI', ...
        'amp10Vm', 'ampGain', 'ampFreq', 'ampMode'};
    inputParams.aOutCh = {'ampExtCmdIn'};
    inputParams.dInCh = {};
    inputParams.dOutCh = {};
    
    % save trial duration here into inputParams
    inputParams.trialDuration = duration; 

    % initialize DAQ, including channels
    [userDAQ, ~, ~, ~, ~] = initUserDAQ(settings, ...
        inputParams.aInCh, inputParams.aOutCh, inputParams.dInCh, ...
        inputParams.dOutCh);
    
    % trial duration in scans
    durScans = duration * userDAQ.Rate;
    
    % path to current injection protocol functions
    iPath = iInjDir();
    
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
        [iInjOut, iInjParams] = iInjFn(settings, durScans); 
    catch % errMes
        error('Invalid current injection function. Ending ephysIInj()');
    end
    
    % save info into returned variables
    rawOutput = iInjOut; % output commanded into rawOutput
    % record current injection function name
    inputParams.iInjProtocol = iInjTypeName; 
    inputParams.iInjParams = iInjParams; % current injection parameters
    
    % queue current injection output
    userDAQ.queueOutputData(iInjOut);
    
    % get time stamp of approximate experiment start
    inputParams.startTimeStamp = datestr(now, 'HH:MM:SS');
    
    disp('Acquiring ephys recording');
    % acquire data (in foreground)
    rawData = userDAQ.startForeground();
    
    % to stop it from presenting non-zero values if current injection
    %  protocol ends on non-zero value
    userDAQ.outputSingleScan(0);

    disp('Ephys recording with current injection acquired');
end