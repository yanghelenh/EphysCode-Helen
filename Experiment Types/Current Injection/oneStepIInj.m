% oneStepIInj.m
%
% Current Injection Function. Injects square step of current of user
%  specified amplitude for user specified duration. Repeats until end of
%  trial with user specified space duration and amplitude between steps.
% Returns vector of to feed to output of DAQ (i.e. appropriately scaled to
%  be read directly by amplifier)
% Starts with space
% User specifies actual amplitude of current step delivered
%
% INPUTS:
%   settings - struct returned by ephysSettings()
%   durScans - duration of trial in scans
%
% OUTPUTS:
%   iInjOut - col vector of current injection output, of length durScans
%   iInjParams -struct with all user specified parameter values
%
% CREATED: 7/22/20 - HHY
%
% UPDATED:
%   7/22/20 - HHY
%

function [iInjOut, iInjParams] = oneStepIInj(settings, durScans)

    % prompt user for input parameters, as dialog box
    inputParams = {'Step Amplitude (pA):', 'Step Duration (s):', ...
        'Space Amplitude (pA):', 'Space Duration (s):'};
    dlgTitle = 'Enter parameter values';
    dlgDims = [1 35]; % dimensions of dialog box input fields
    
    % dialog box
    dlgAns = inputdlg(inputParams, dlgTitle, dlgDims);
    
    % convert user input into actual variables
    stepAmp = str2double(dlgAns{1});
    stepDur = str2double(dlgAns{2});
    spaceAmp = str2double(dlgAns{3});
    spaceDur = str2double(dlgAns{4});
    
    % convert user input into correct units for output (amplitude in volts,
    %  duration in scans); compensate for non-zero output from DAQ when
    %  zero commanded
    stepAmpV = (stepAmp - settings.VOut.zeroI) * settings.VOut.IConvFactor;
    stepDurScans = round(stepDur * settings.bob.sampRate);
    spaceAmpV = (spaceAmp - settings.VOut.zeroI) * ...
        settings.VOut.IConvFactor;
    spaceDurScans = round(spaceDur * settings.bob.sampRate);
    
    % save user input into parameters struct (convert duration to actual
    %  duration delivered, if rounded)
    iInjParams.stepAmp = stepAmp;
    iInjParams.stepDur = stepDurScans / settings.bob.sampRate;
    iInjParams.spaceAmp = spaceAmp;
    iInjParams.spaceDur = spaceDurScans / settings.bob.sampRate;
    
    % 1 repeat of space then step
    oneSpaceStep = [(spaceAmpV * ones(spaceDurScans,1)); ...
        (stepAmpV * ones(stepDurScans,1))];
    lenOneSpaceStep = length(oneSpaceStep);
    
    % number of full repeats
    numFullReps = floor(durScans / lenOneSpaceStep);
    
    % number of scans in remainder
    numScansLeft = mod(durScans, lenOneSpaceStep);
    
    % generate output
    iInjOut = repmat(oneSpaceStep, numFullReps, 1);
    
    % if there is a remainder, concatenate onto end
    if numScansLeft
        iInjOut = [iInjOut; oneSpaceStep(1:numScansLeft)];
    end   
end