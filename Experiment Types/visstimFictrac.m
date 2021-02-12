% visstimFictrac.m
%
% Trial Type Function 
% Presents visual stimulus on G3 panels, records FicTrac behavior data
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

function [rawData, inputParams, rawOutput] = visstimFictrac(settings, ...
    duration)

    % EXPERIMENT-SPECIFIC PARAMETERS
    inputParams.exptCond = 'visstimFictrac'; % name of trial type
    
    % which input and output data streams used in this experiment
    inputParams.aInCh = {'ficTracHeading', 'ficTracIntX', 'ficTracIntY',...
        'panelsDAC0X', 'panelsDAC1Y'};
    inputParams.aOutCh = {};
    inputParams.dInCh = {'ficTracCamFrames'};
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
    visstimParams = visstimUserPrompts(settings);
    
    % send information to visual panels
    initalizeVisualPanels(visstimParams, settings);
    
    % merge visual stimulus parameters into inputParams struct
    inputParams = mergeStructs(inputParams, visstimParams);
    
    % get time stamp of approximate experiment start
    inputParams.startTimeStamp = datestr(now, 'HH:MM:SS');
    
    disp('Starting visstimFictrac acquisition');
    % start visual panels
    Panel_com('start');
    
    % acquire data (in foreground)
    rawData = userDAQ.startForeground();
    
    % stop visual panels
    Panel_com('stop');

    disp('Data acquired');
end