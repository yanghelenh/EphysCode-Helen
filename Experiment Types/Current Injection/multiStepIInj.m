% multiStepIInj.m
%
% DO NOT USE AS OF 1/5/24. NEVER FINISHED WRITING AND DOES NOT WORK
%
% Current Injection Function. Injects square current steps of user 
%  specified amplitudes of user specified durations. Durations can be 
%  different among steps. Has option to randomize amplitudes or not. User 
%  specified step duration and time between steps. User specified space 
%  amplitude.
% Returns vector of to feed to output of DAQ (i.e. appropriately scaled to
%  be read directly by amplifier)
% Starts with space
% User specifies actual amplitudes in pA
%
% INPUTS:
%   settings - struct returned by ephysSettings()
%   durScans - duration of trial in scans
%
% OUTPUTS:
%   iInjOut - col vector of current injection output, of length durScans
%   iInjParams -struct with all user specified parameter values
%
% CREATED: 7/23/20 - HHY
%
% UPDATED:
%   7/24/20 - HHY
%   1/5/24 - HHY - discovered that this was never finished
%

function [iInjOut, iInjParams] = multiStepIInj(settings, durScans)

    % prompt user for input parameters, as dialog box
    inputParams = {'Step Amplitudes (pA):', 'Step Durations (s):', ...
        'Space Amplitude (pA):', 'Space Duration (s):', ...
        'Randomize steps? y/n'};
    dlgTitle = 'Enter parameter values';
    dlgDims = [1 35]; % dimensions of dialog box input fields
    
    % dialog box
    dlgAns = inputdlg(inputParams, dlgTitle, dlgDims);
    
    % convert user input into actual variables
    stepAmps = str2double(dlgAns{1});
    stepDurs = str2double(dlgAns{2});
    spaceAmp = str2double(dlgAns{3});
    spaceDur = str2double(dlgAns{4});
    randomize = dlgAns{5};
    
    % standarize randomize; defaults to no if input isn't y or Y
    if strcmpi(randomize,'y')
        randomize = 'y';
    else
        randomize = 'n';
    end
    
   
    % convert user input into correct units for output (amplitude in volts,
    %  duration in scans); compensate for non-zero output from DAQ when
    %  zero commanded
    allStepAmpsV = (stepAmps - settings.VOut.zeroI) .* ...
        settings.VOut.IConvFactor;
    stepDurScans = round(stepDurs .* settings.bob.sampRate);
    spaceAmpV = (spaceAmp - settings.VOut.zeroI) * ...
        settings.VOut.IConvFactor;
    spaceDurScans = round(spaceDur * settings.bob.sampRate);
    
    % save user input into parameters struct (convert duration to actual
    %  duration delivered, if rounded)
    iInjParams.allStepAmps = stepAmps;
    iInjParams.stepDur = stepDurScans ./ settings.bob.sampRate;
    iInjParams.spaceAmp = spaceAmp;
    iInjParams.spaceDur = spaceDurScans / settings.bob.sampRate;
    iInjParams.randomize = randomize;
    
    % each stimulus as a column, in order from min to max; starts with
    %  space, ends with step
    spaceMatrix = ones(spaceDurScans, numScans) * spaceAmpV;
    stepMatrix = ones(stepDurScans, numScans) .* allStepAmpsV;
    stimMatrix = [spaceMatrix; stepMatrix];
    
    % number of full repeats
    numFullReps = floor(durScans / (spaceDurScans + stepDurScans));
    
    % number of scans in remainder
    numScansLeft = mod(durScans, (spaceDurScans + stepDurScans));
    
    % generate stimulus, depends on whether or not to randomize
    if strcmpi(randomize, 'y')
        % initialize iInjOut
        iInjOut = ones(durScans, 1);
        
        % generate random order of steps, index numbers into columns
        stepOrderInd = randi(numSteps, numFullReps+1, 1); 
       
        % loop and index into stimMatrix to pull appropriate stimuli
        for i = 1:numFullReps
            startInd = 1 + (spaceDurScans + stepDurScans) * (i - 1);
            endInd = (spaceDurScans + stepDurScans) * i;
            
            iInjOut(startInd:endInd) = stimMatrix(:, stepOrderInd(i));        
        end
        
        % if there is a remainder, add in appropriate part of last stimulus
        if numScansLeft
            iInjOut((end-numScansLeft+1):end) = ...
                stimMatrix(1:numScansLeft, stepOrderInd(end));
        end

    else % in order from min to max
        % reshape stim matrix to single column vector
        oneRepStim = reshape(stimMatrix, numel(stimMatrix), 1);
        
        % generate output
        iInjOut = repmat(oneRepStim, numFullReps, 1);
        
        % if there is a remainder, concatenate onto end
        if numScansLeft
            iInjOut = [iInjOut; oneRepStim(1:numScansLeft)];
        end  
    end
end