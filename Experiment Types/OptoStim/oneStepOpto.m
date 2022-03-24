% oneStepOpto.m
%
% Optogenetic Stimulation Function. Opens up shutter in front of mercury 
%  lamp for one duration specified by user, with shutter closed duration
%  b/w steps also user specified
% Returns vector of to feed to digital output of DAQ (series of 0 and 1s)
% Starts with space
%
% INPUTS:
%   settings - struct returned by ephysSettings()
%   durScans - duration of trial in scans
%
% OUTPUTS:
%   optoStimOut - col vector of opto stim output, of length durScans
%   optoStimParams - struct with all user specified parameter values
%
% CREATED: 2/21/22 - HHY
%
% UPDATED:
%   2/21/22 - HHY - confirmed, works
%

function [optoStimOut, optoStimParams] = oneStepOpto(settings, ...
    durScans)

    % prompt user for input parameters, as dialog box
    inputParams = {'ND filters (total OD):', 'Stim BP filter', ...
        'Stim Duration (s):', 'Duration between Stims (s):'};
    dlgTitle = 'Enter parameter values';
    dlgDims = [1 35]; % dimensions of dialog box input fields
    
    % dialog box
    dlgAns = inputdlg(inputParams, dlgTitle, dlgDims);
    
    % convert user input into actual variables
    ndFilter = str2double(dlgAns{1});
    stimBPfilter = dlgAns{2};
    stimDur = str2double(dlgAns{3}); 
    durBwStims = str2double(dlgAns{4});
    
    % convert duration in seconds to scans
    stepDurScans = round(stimDur * settings.bob.sampRate);
    bwDurScans = round(durBwStims * settings.bob.sampRate);
    
    % save user input into parameters struct (convert duration to actual
    %  duration delivered, if rounded)
    optoStimParams.ndFilter = ndFilter;
    optoStimParams.stimBPfilter = stimBPfilter;
    optoStimParams.stimDur = stepDurScans / settings.bob.sampRate;
    optoStimParams.durBwStims = bwDurScans / settings.bob.sampRate;
    
    % generate stimulus
    % total scans, one repetiton (off, on)
    totRepScans = stepDurScans + bwDurScans;
    
    % number of full repeats of stimulus, all steps
    numFullReps = floor(durScans / totRepScans);
    % remaining scans
    numScansLeft = mod(durScans, totRepScans);
    
    % initialize one rep, column vector
    oneRep = zeros(totRepScans, 1);
    
    % flip stim on block to 1's within oneRep (starts with off, then on)
    oneRep((bwDurScans+1):end) = 1;
    
    % generate output
    optoStimOut = repmat(oneRep, numFullReps, 1);

    % if there is a remainder, concatenate onto end
    if numScansLeft
        optoStimOut = [optoStimOut; oneRep(1:numScansLeft)];
    end  
end