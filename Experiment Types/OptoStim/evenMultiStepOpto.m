% evenMultiStepOpto.m
%
% Optogenetic Stimulation Function. Opens up shutter in front of mercury 
%  lamp for n durations spaced linearly betweeen min and max as specified 
%  by the user. 
%  Has option to randomize durations or not. User specified step
%  duration and time between steps. 
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
% CREATED: 2/21/22 - HHY
%
% UPDATED:
%   2/21/22 - HHY - confirmed, works
%

function [optoStimOut, optoStimParams] = evenMultiStepOpto(settings, ...
    durScans)

    % prompt user for input parameters, as dialog box
    inputParams = {'ND filters (total OD):', 'Stim BP filter', ...
        'Min Stim Duration (s):', ...
        'Max Stim Duration (s):', 'Number of Different Durations:', ...
        'Duration between Stims (s):', 'Randomize durations? y/n'};
    dlgTitle = 'Enter parameter values';
    dlgDims = [1 35]; % dimensions of dialog box input fields
    
    % dialog box
    dlgAns = inputdlg(inputParams, dlgTitle, dlgDims);
    
    % convert user input into actual variables
    ndFilter = str2double(dlgAns{1});
    stimBPfilter = dlgAns{2};
    minStimDur = str2double(dlgAns{3});
    maxStimDur = str2double(dlgAns{4});
    numDurs = str2double(dlgAns{5});
    durBwStims = str2double(dlgAns{6});
    randomize = dlgAns{7};
    
    % standarize randomize; defaults to no if input isn't y or Y
    if strcmpi(randomize,'y')
        randomize = 'y';
    else
        randomize = 'n';
    end
    
    % get durations of stim on steps
    allStimDurs = linspace(minStimDur, maxStimDur, numDurs);
    
    % convert duration in seconds to scans
    stepDurScans = round(allStimDurs * settings.bob.sampRate);
    bwDurScans = round(durBwStims * settings.bob.sampRate);
    
    % save user input into parameters struct (convert duration to actual
    %  duration delivered, if rounded)
    optoStimParams.ndFilter = ndFilter;
    optoStimParams.stimBPfilter = stimBPfilter;
    optoStimParams.allStimDurs = stepDurScans / settings.bob.sampRate;
    optoStimParams.durBwStims = bwDurScans / settings.bob.sampRate;
    optoStimParams.randomize = randomize;
      
    % generate stimulus, depends on whether or not to randomize
    if strcmpi(randomize, 'y')
        
        % initialize output
        optoStimOut = zeros(durScans, 1);
        
        % initialize counter for which scan we're on
        currScan = 1;
        
        % loop until optoStimOut filled out
        while (currScan < durScans)
            % pick a random duration from stepDurScans
            thisDurScans = randsample(stepDurScans, 1);
            
            % start and end indices of stim block
            stimStartInd = currScan + bwDurScans;
            stimEndInd = stimStartInd + thisDurScans - 1;
            
            % check that stimStartInd and stimEndInd are within bounds of
            % optoStimOut
            % stim block doesn't fit at all, don't change anything and end
            %  on next loop
            if (stimStartInd > durScans)
                currScan = stimEndInd; 
            % part of stim block doesn't fit; just stim until end     
            elseif (stimEndInd > durScans)
                optoStimOut(stimStartInd:durScans) = 1;
                % update currScan
                currScan = stimEndInd; % will end on next loop iteration
            % change stim output to 1 for whole stim block
            % update currScan for next loop
            else
                optoStimOut(stimStartInd:stimEndInd) = 1;
                currScan = stimEndInd + 1;
            end
        end

    else % in order from min to max duration
        % number of full repeats of stimulus, all steps
        % total number of scans, all stimulation blocks
        totStimScans = sum(stepDurScans);
        % total number of scans, space b/w stim blocks
        totBwScans = bwDurScans * numDurs;
        % total number of scans, 1 full repeat
        totRepScans = totStimScans + totBwScans;
        
        % number of full repeats of stimulus, all steps
        numFullReps = floor(durScans / totRepScans);
        % remaining scans
        numScansLeft = mod(durScans, totRepScans);
        
        % one rep, with all stim blocks (column vector)
        oneRep = zeros(totRepScans, 1); % initialize, all 0 (closed)
        
        % current scan counter
        currScan = 1;
        
        % loop through all stim blocks, generate one rep (starts with off
        %  block)
        for i = 1:numDurs
            % start and end indices of stim block for this stim duration
            stimStartInd = currScan + bwDurScans;
            stimEndInd = stimStartInd + stepDurScans(i) - 1;
            
            % stim = output = 1
            oneRep(stimStartInd:stimEndInd) = 1;
            
            % update scan counter
            currScan = stimEndInd + 1;
        end
        
        % generate output
        optoStimOut = repmat(oneRep, numFullReps, 1);
        
        % if there is a remainder, concatenate onto end
        if numScansLeft
            optoStimOut = [optoStimOut; oneRep(1:numScansLeft)];
        end  
    end
end