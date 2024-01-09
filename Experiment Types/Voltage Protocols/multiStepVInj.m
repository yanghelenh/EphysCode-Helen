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
%   vInjParams - struct with all user specified parameter values
%
% CREATED: 1/5/24 - HHY
%
% UPDATED:
%   1/7/24 - HHY
%   1/8/24 - HHY - confirmed, works
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
    stepAmps = eval(dlgAns{1});
    stepDurs = eval(dlgAns{2});
    randomize = dlgAns{3};
    
    % convert step durations to DAQ scans
    stepDursScans = round(stepDurs .* settings.bob.sampRate);
    
    % number of different steps
    numSteps = length(stepAmps);
    
    % generate vector of output, approach is different depending on
    %  whether the sequence is randomized or not
    if strcmpi(randomize,'y')
        randomize = 'y'; % standardize randomize
        
        curNumScans = 0; % counter for total number of scans generated
        vInjOut = []; % initialize output vector
        
        % generate output, loops while total number of scans is not reached
        while (curNumScans < durScans)
            % get random step index
            thisStepInd = randi(numSteps);
            
            % generate column vector for this step
            % value is amp, number of elements determined by duration in
            %  scans
            thisStepVector = ones(stepDursScans(thisStepInd),1) .* ...
                stepAmps(thisStepInd);
            
            % add this vector to output 
            vInjOut = [vInjOut; thisStepVector];
            % update num scans counter
            curNumScans = curNumScans + length(thisStepVector);
        end
    else
        randomize = 'n'; % standardize randomize
        
        % generate one repeat of all steps, in order they appear in
        % stepAmps
        oneRepVector = [];
        for i = 1:numSteps
            % column vector for this step
            thisStepVector = ones(stepDursScans(i),1) .* stepAmps(i);
            
            % add to 1 repeat vector
            oneRepVector = [oneRepVector; thisStepVector];
        end
        
        % repeat vector of all steps 
        % number of times to repeat vector, always round up so vector isn't
        %  prematurely cut off
        numReps = ceil(durScans / length(oneRepVector));
        
        vInjOut = repmat(oneRepVector, numReps, 1);
    end
    
    % clip end of output vector to match requested number of scans
    % (happens since steps/reps are added whole)
    vInjOut = vInjOut(1:durScans);
    

    % save user input into parameters struct (convert durations to actual
    %  duration delivered, if rounded)
    vInjParams.stepAmps = stepAmps;
    vInjParams.stepDurs = stepDursScans ./ settings.bob.sampRate;
    vInjParams.randomize = randomize;   
end