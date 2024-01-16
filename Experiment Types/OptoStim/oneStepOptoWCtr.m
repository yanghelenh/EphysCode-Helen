% oneStepOptoWCtrl.m
%
% Optogenetic Stimulation Function. Opens up shutter in front of mercury 
%  lamp for duration specified by user on X% of repeats. Other (100-X)% of
%  repeats, shutter doesn't open. Which repeat shutter opens is random.
% Specify duration before and after steps when shutter is not open.
% Returns vector of to feed to digital output of DAQ (series of 0 and 1s)
% Starts with space
%
% INPUTS:
%   settings - struct returned by ephysSettings()
%   durScans - duration of trial in scans
%
% OUTPUTS:
%   optoStimOut - col vector of opto stim output, of length durScans
%   optoStimParams -struct with all user specified parameter values
%
% CREATED: 1/8/24
%
% UPDATED:
%   1/8/24 - HHY - confirmed, works
%   1/16/24 - HHY - add fraction shutter closed to output
%

function [optoStimOut, optoStimParams] = oneStepOptoWCtr(settings, ...
    durScans)

    % prompt user for input parameters, as dialog box
    inputParams = {'ND filters (total OD):', 'Stim BP filter', ...
        'Stim Duration (s):', 'Duration before stim (s):', ...
        'Duration after stim (s)', ...
        'Fraction repeats, shutter closed (0-1):'};
    dlgTitle = 'Enter parameter values';
    dlgDims = [1 35]; % dimensions of dialog box input fields
    
    % dialog box
    dlgAns = inputdlg(inputParams, dlgTitle, dlgDims);
    
    % convert user input into actual variables
    ndFilter = str2double(dlgAns{1});
    stimBPfilter = dlgAns{2};
    stimDur = str2double(dlgAns{3}); 
    durBfStims = str2double(dlgAns{4});
    durAfStims = str2double(dlgAns{5});
    fracShutterClosed = str2double(dlgAns{6});
    
    % convert duration in seconds to scans
    stepDurScans = round(stimDur * settings.bob.sampRate);
    bfDurScans = round(durBfStims * settings.bob.sampRate);
    afDurScans = round(durAfStims * settings.bob.sampRate);
    
    % save user input into parameters struct (convert duration to actual
    %  duration delivered, if rounded)
    optoStimParams.ndFilter = ndFilter;
    optoStimParams.stimBPfilter = stimBPfilter;
    optoStimParams.allStimDurs = stepDurScans / settings.bob.sampRate;
    optoStimParams.durBfStims = bfDurScans / settings.bob.sampRate;
    optoStimParams.durAfStims = afDurScans / settings.bob.sampRate;
    optoStimParams.fracShutterClosed = fracShutterClosed;
    
    % generate stimulus
    % total scans, one repetiton (off before, on, off after)
    totRepScans = stepDurScans + bfDurScans + afDurScans;
    
    % number of repeats, round up
    numReps = ceil(durScans / totRepScans);
    
    % initialize one rep with shutter open/closed, column vector
    oneRepOn = zeros(totRepScans, 1);
    oneRepOff = zeros(totRepScans, 1);
    
    % flip stim on block to 1's within oneRepOn
    %  off, on, off
    oneRepOn((bfDurScans+1):(bfDurScans+1+stepDurScans)) = 1;
    
    % initialize output
    optoStimOut = [];
    
    % generate output
    for i = 1:numReps
        % draw random number between 0 and 1, for determining whether
        %  shutter is open or closed
        thisRandNum = rand;
        
        % shutter is closed if random number is less than fraction shutter
        %  closed
        % use oneRepOff
        if (thisRandNum < fracShutterClosed)
            optoStimOut = [optoStimOut; oneRepOff];
        else % use oneRepOn
            optoStimOut = [optoStimOut; oneRepOn];
        end
    end
    
    % clip output to match durScans (since repeats added whole)
    optoStimOut = optoStimOut(1:durScans);
end