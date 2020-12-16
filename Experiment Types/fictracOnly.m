% fictracOnly.m
%
% Trial Type Function 
% Only records FicTrac channels
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
% CREATED: 10/9/20 - HHY
% UPDATED: 
%   10/9/20 - HHY
%

function [rawData, inputParams, rawOutput] = fictracOnly(settings, ...
    duration)

    % EXPERIMENT-SPECIFIC PARAMETERS
    inputParams.exptCond = 'fictracOnly'; % name of trial type
    
    % which input and output data streams used in this experiment
    inputParams.aInCh = {'ficTracHeading', 'ficTracIntX', 'ficTracIntY'};
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
    
    % get time stamp of approximate experiment start
    inputParams.startTimeStamp = datestr(now, 'HH:MM:SS');
    
    disp('Acquiring FicTrac behavior only');
    % acquire data (in foreground)
    rawData = userDAQ.startForeground();

    disp('FicTrac data acquired');
end