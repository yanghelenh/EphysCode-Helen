% rampVInj.m
%
% Voltage Injection Function for testing visaul panels. 
% Delivers linear voltage ramp between user specified values for user 
%  specified duration. Repeats until end of trial. 
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
% CREATED: 2/11/21 - HHY
%
% UPDATED:
%   2/11/21 - HHY
%

function [vInjOut, vInjParams] = rampVInj(settings, durScans)

    % prompt user for input parameters, as dialog box
    inputParams = {'Start voltage (V):', 'End voltage (V):', ...
        'Ramp duration (s):'};
    dlgTitle = 'Enter parameter values';
    dlgDims = [1 35]; % dimensions of dialog box input fields
    
    % dialog box
    dlgAns = inputdlg(inputParams, dlgTitle, dlgDims);
    
    % convert user input into actual variables
    startV = str2double(dlgAns{1});
    endV = str2double(dlgAns{2});
    rampDur = str2double(dlgAns{3});
    
    % convert duration to DAQ scans
    rampDurScans = round(rampDur * settings.bob.sampRate);
    
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