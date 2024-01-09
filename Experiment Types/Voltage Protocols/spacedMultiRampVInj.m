% spacedMultiRampVInj.m
%
% Voltage Injection Function for visual panels. 
% Delivers linear voltage ramp(s) between user specified values for user 
%  specified duration(s). Ramps are separated by constant voltage for user
%  specified duration. Multiple ramps of different parameters are possible.
%  Order is randomized or fixed in user specified order. Repeats until end 
%  of trial. 
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
% CREATED: 1/7/24 - HHY
%
% UPDATED:
%   1/7/24 - HHY
%   1/8/24 - HHY - confirmed, works
%

function [vInjOut, vInjParams] = spacedMultiRampVInj(settings, durScans)

    % prompt user for input parameters, as dialog box
    inputParams = {'Ramp(s) start voltage(s) (V):', ...
        'Ramp(s) end voltage(s) (V):', ...
        'Ramp duration(s) (s):', ...
        'Space voltage (V)', 'Space duration (s)', ...
        'Randomize ramps? y/n'};
    dlgTitle = 'Enter parameter values';
    dlgDims = [1 35]; % dimensions of dialog box input fields
    
    % dialog box
    dlgAns = inputdlg(inputParams, dlgTitle, dlgDims);
    
    % convert user input into actual variables
    startV = eval(dlgAns{1});
    endV = eval(dlgAns{2});
    rampDur = eval(dlgAns{3});
    spaceV = str2double(dlgAns{4});
    spaceDur = str2double(dlgAns{5});
    randomize = dlgAns{6};
    
    % number of different ramps
    numRamps = length(startV);
    
    % convert durations to DAQ scans
    rampDurScans = round(rampDur .* settings.bob.sampRate);
    spaceDurScans = round(spaceDur * settings.bob.sampRate);
    
    % space vector
    oneSpaceVector = ones(spaceDurScans,1) .* spaceV;
    
    
    % generate vector of output, approach is different depending on
    %  whether the sequence is randomized or not
    if strcmpi(randomize,'y')
        randomize = 'y'; % standardize randomize
        
        curNumScans = 0; % counter for total number of scans generated
        vInjOut = []; % initialize output vector
        
        % generate output, loops while total number of scans is not reached
        while (curNumScans < durScans)
            % get random ramp index
            thisRampInd = randi(numRamps);
            
            % generate column vector for this ramp
            % linear between start and end voltages, 
            % number of elements determined by duration in scans
            thisRamp = linspace(startV(thisRampInd), endV(thisRampInd), ...
                rampDurScans(thisRampInd))';
            
            % add this vector to output 
            vInjOut = [vInjOut; oneSpaceVector; thisRamp];
            % update num scans counter
            curNumScans = curNumScans + length(oneSpaceVector) + ...
                length(thisRamp);
        end
    else
        randomize = 'n'; % standardize randomize
        
        % generate one repeat of all ramps, in order they appear in
        % start/end V
        oneRepVector = [];
        for i = 1:numRamps
            % column vector for this ramp
            thisRamp = linspace(startV(i), endV(i), rampDurScans(i))';
            
            % add to 1 repeat vector (with space)
            oneRepVector = [oneRepVector; oneSpaceVector; thisRamp];
        end
        
        % repeat vector of all ramps
        % number of times to repeat vector, always round up so vector isn't
        %  prematurely cut off
        numReps = ceil(durScans / length(oneRepVector));
        
        vInjOut = repmat(oneRepVector, numReps, 1);
    end
    
    % clip end of output vector to match requested number of scans
    % (happens since steps/reps are added whole)
    vInjOut = vInjOut(1:durScans);
    
    % save user input into parameters struct (convert duration to actual
    %  duration delivered, if rounded)
    vInjParams.startV = startV;
    vInjParams.endV = endV;
    vInjParams.rampDur = rampDurScans ./ settings.bob.sampRate;
    vInjParams.spaceV = spaceV;
    vInjParams.spaceDur = spaceDurScans / settings.bob.sampRate;
    vInjParams.randomize = randomize;
end