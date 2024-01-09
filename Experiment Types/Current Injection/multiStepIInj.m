% multiStepIInj.m
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
%   1/7/24 - HHY - fixed, probably
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
    stepAmps = eval(dlgAns{1});
    stepDurs = eval(dlgAns{2});
    spaceAmp = str2double(dlgAns{3});
    spaceDur = str2double(dlgAns{4});
    randomize = dlgAns{5};
    
    % number of steps
    numSteps = length(stepAmps);
     
    % convert user input into correct units for output (amplitude in volts,
    %  duration in scans); compensate for non-zero output from DAQ when
    %  zero commanded
    allStepAmpsV = (stepAmps - settings.VOut.zeroI) .* ...
        settings.VOut.IConvFactor;
    stepDurScans = round(stepDurs .* settings.bob.sampRate);
    spaceAmpV = (spaceAmp - settings.VOut.zeroI) * ...
        settings.VOut.IConvFactor;
    spaceDurScans = round(spaceDur * settings.bob.sampRate);
    
    % output vector, for one space
    spaceOutVector = ones(spaceDurScans,1) .* spaceAmpV;
          
    % generate vector of output, approach is different depending on
    %  whether the sequence is randomized or not
    if strcmpi(randomize,'y')
        randomize = 'y'; % standardize
           
        curNumScans = 0; % counter for total number of scans generated
        iInjOut = []; % initialize output vector
        
        % generate output, loops while total number of scans is not reached
        while (curNumScans < durScans)
            % get random step index
            thisStepInd = randi(numSteps);
            
            % generate column vector for this step
            % value is amp, number of elements determined by duration in
            %  scans
            thisStepVector = ones(stepDurScans(thisStepInd),1) .* ...
                allStepAmpsV(thisStepInd);
            
            % add this vector to output, also, space vector
            iInjOut = [iInjOut; spaceOutVector; thisStepVector];
            % update num scans counter
            curNumScans = curNumScans + length(thisStepVector) + ...
                length(spaceOutVector);
        end
    else
        randomize = 'n'; % standarize
        
        % generate one repeat of all steps, in order they appear in
        % stepAmps
        oneRepVector = [];
        for i = 1:numSteps
            % column vector for this step
            thisStepVector = ones(stepDurScans(i),1) .* allStepAmpsV(i);
            
            % add to 1 repeat vector, also add space
            oneRepVector = [oneRepVector; spaceOutVector; thisStepVector];
        end
        
        % repeat vector of all steps 
        % number of times to repeat vector, always round up so vector isn't
        %  prematurely cut off
        numReps = ceil(durScans / length(oneRepVector));
        
        iInjOut = repmat(oneRepVector, numReps, 1);
    end
    
    % clip end of output vector to match requested number of scans
    % (happens since steps/reps are added whole)
    iInjOut = iInjOut(1:durScans);
    
    % save user input into parameters struct (convert duration to actual
    %  duration delivered, if rounded)
    iInjParams.allStepAmps = stepAmps;
    iInjParams.stepDur = stepDurScans ./ settings.bob.sampRate;
    iInjParams.spaceAmp = spaceAmp;
    iInjParams.spaceDur = spaceDurScans / settings.bob.sampRate;
    iInjParams.randomize = randomize;
end