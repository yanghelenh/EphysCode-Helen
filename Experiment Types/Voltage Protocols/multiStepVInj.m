% multiStepVInj.m
%
% Voltage Injection Function for visual panels. 
% Delivers square voltage step of user-specified amplitudes and duration.
%  Durations can be different among steps. Steps can be randomized or they
%  can repeat in the user-specified order until the end of the trial
% Voltage values are not scaled, as they are not meant to be sent to the
%  amplifier.
%
% INPUTS:
%   settings - struct returned by ephysSettings()
%   durScans - duration of trial in scans
%
% OUTPUTS:
%   vInjOut - col vector of current injection output, of length durScans
%   vInjParams -struct with all user specified parameter values
%
% CREATED: 1/5/24 - HHY
%
% UPDATED:
%   1/5/24 - HHY
%

function [vInjOut, vInjParams] = multiStepVInj(settings, durScans)

    % prompt user for input parameters, as dialog box
    inputParams = {'Step Amplitudes (V):', 'Step Durations (s):', ...
        'Randomize steps? y/n'};
    dlgTitle = 'Enter parameter values';
    dlgDims = [1 35]; % dimensions of dialog box input fields
    
    % dialog box
    dlgAns = inputdlg(inputParams, dlgTitle, dlgDims);
    
    % convert user input into actual variables
    stepAmps = str2double(dlgAns{1});
    stepDurs = str2double(dlgAns{2});
    randomize = dlgAns{3};
    
    % standarize randomize; defaults to no if input isn't y or Y
    if strcmpi(randomize,'y')
        randomize = 'y';
    else
        randomize = 'n';
    end
    
    % convert step durations to DAQ scans
    stepDurScans = round(stepDurs .* settings.bob.sampRate);
    
    % save user input into parameters struct (convert duration to actual
    %  duration delivered, if rounded)
    vInjParams.startV = startV;
    vInjParams.endV = endV;
    vInjParams.rampDur = rampDurScans / settings.bob.sampRate;
    
    % 1 repeat of ramp
    oneRamp = linspace(startV, endV, rampDurScans)';
    
    % number of full repeats
    numFullReps = floor(durScans / rampDurScans);
    
    % number of scans in remainder
    numScansLeft = mod(durScans, rampDurScans);
    
    % generate output
    vInjOut = repmat(oneRamp, numFullReps, 1);
    
    % if there is a remainder, concatenate onto end
    if numScansLeft
        vInjOut = [vInjOut; oneRamp(1:numScansLeft)];
    end   
end