% makeFunctionsScript.m
%
% Script for making all the functions, ordered in numerical order
%
% CREATED: 2/14/21 - HHY
%
% UPDATED:
%   2/15/21 - HHY
%

%% Some constants

% load ephysSettings
[~, ~, settings] = ephysSettings();

% how long functions usually are, in frames, set by panels
defaultLength = 1000;

degPerLED = 2.8; % angular size of LED, given arena diameter of 12 cm

% size of arena, in panels
numHorizPanels360 = 12; % number of panels, if arena were full 360
numHorizPanels270 = 9; % number of panels, wrapping 270 to 360
numVertPanels = 2; % number of vertical panels

LEDsPerPanel = 8; % number of LEDs per panel

% size of arena, in LEDs
numHorizLEDs360 = numHorizPanels360 * LEDsPerPanel;
numHorizLEDs270 = numHorizPanels270 * LEDsPerPanel;
numVertLEDs = numVertPanels * LEDsPerPanel;

%% Function 001 - static
% default function, nothing changes, all 0

% function name
funcName = 'position_function_001_static';

func = zeros(1, defaultLength);

% save pattern
save([vsFunctionsDir() filesep funcName '.mat'], 'func');

%% Functions 002 and 003 - X and Y functions for optomotor stimulus
% gray, static grating, moving grating at 4 different speeds (both
%  directions); pseudorandom sequence
% pairs with patterns 9 and 10

XFuncName = 'position_function_002_X_grayStaticRotatingGrating20-60-180-300';
YFuncName = 'position_function_002_Y_grayStaticRotatingGrating20-60-180-300';


% velocities of grating, in degrees per second
gratingSpds = [20 60 180 300];

% duration, in seconds of each part of trial
grayDur = 0.5;
staticDur = 0.5;
moveDur = 0.5;

% number of repeats to encode in this function
numReps = 5; 

% start position (in X), zero indexing
startPos = 0;

% Y indicies for on, off, gray (-1 from patterns indicies, b/c zero
%  indexing)
yBarDisp = 0;
yMeanLum = 1;
yAllOff = 2;

% convert inputs into pixels and frames
% speed in pixels per frame
spdPxFr = gratingSpds .* (1/degPerLED) .* (1/settings.visstim.funcfreq);
% duration spent on each pixel, in frames (rounded to nearest whole frame)
durFrPx = round(1./spdPxFr);

% durations, in frames
grayDurFr = round(grayDur * settings.visstim.funcfreq);
staticDurFr = round(staticDur * settings.visstim.funcfreq);
moveDurFr = round(moveDur * settings.visstim.funcfreq);

% build X function: gray and static treated the same
% generate pseduorandom sequence, without repeats, of velocities to present
numSpds = length(gratingSpds);
numVels = 2*numSpds; % both directions

velSeq = zeros(1,numVels*numReps); % initialize
% for each repetition, randomize velocities, indicated by index 1:numVels
for i = 1:numReps
    startInd = (i-1)*numVels + 1;
    endInd = i*numVels;
    % random order of integers 1:numVels, no repeats
    velSeq(startInd:endInd) = randperm(numVels);
end

% number of trials (each velocity is a trial)
numTrials = length(velSeq);

% number of frames in full sequence
seqDurFr = numTrials * (grayDurFr + staticDurFr + moveDurFr);
% number of frames in one trial
trialDurFr = grayDurFr + staticDurFr + moveDurFr;

% preallocate vector
xFunc = zeros(1, seqDurFr);

% basis vector for increasing position values
incPosBasis = 0:(numHorizLEDs360 - 1);
% basis vector for decreasing position values
decPosBasis = (numHorizLEDs360 - 1):-1:0;
% shift decreasing position basis vector to also start at zero
decPosBasis = circshift(decPosBasis, 1);

% turn indicies into position sequence
for i = 1:numTrials
    % indicies into full sequence for this trial
    startInd = (i-1) * trialDurFr + 1; % start of trial
    % end of static period
    staticEndInd = startInd + grayDurFr + staticDurFr - 1; 
    moveStartInd = staticEndInd + 1; % start of move period
    endInd = i*trialDurFr; % end of trial
    
    % build gray and static portion of trial
    % grating at start postion, unmoving
    xFunc(startInd:staticEndInd) = startPos;
    
    % build moving portion of trial
    % determine which velocity
    % indicies corresponding to increasing X position values (move left)
    if velSeq(i) <= numSpds
        spdInd = velSeq(i); % index into which speed
        % number of frames to dwell at each position, given this speed
        dwellFr = durFrPx(spdInd);
        % generate move sequence for this velocity by repeating elements of
        %  basis vector
        repEleSeq = repelem(incPosBasis, dwellFr);
               
    % indicies corresponding to decreasing X position values (move right)    
    else
        spdInd = velSeq(i) - numSpds; % index into which speed
        % number of frames to dwell at each position, given this speed
        dwellFr = durFrPx(spdInd);
        % generate move sequence for this velocity by repeating elements of
        %  basis vector
        repEleSeq = repelem(decPosBasis, dwellFr);
        
    end
    
    % check if this sequence is too short for trial duration and needs
    % to be repeated
    if (length(repEleSeq) < moveDurFr)
        % figure out number of repeats
        numSeqReps = ceil(moveDurFr/length(repEleSeq));
        % generate that vector of sufficient length
        longSeq = repmat(repEleSeq,1,numSeqReps);
    % sequence already long enough, no need to repeat
    else
        longSeq = repEleSeq;
    end

    % add to full position function vector, clip move sequence to right
    %  length
    xFunc(moveStartInd:endInd) = longSeq(1:moveDurFr); 
end

% build Y function

% generate Y sequence for 1 trial (gray static move) = (gray on on)
oneYTrial = [(ones(1, grayDurFr) * yMeanLum), ...
    (ones(1, staticDurFr + moveDurFr) * yBarDisp)];

% repeat this for all trials
yFunc = repmat(oneYTrial, 1, numTrials);

% save X and Y functions
func = xFunc;
save([vsFunctionsDir() filesep XFuncName '.mat'], 'func');
func = yFunc;
save([vsFunctionsDir() filesep YFuncName '.mat'], 'func');
