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

fullLEDSizeDeg = 360 / numHorizLEDs360;

%% Function 001 - static
% default function, nothing changes, all 0
%
% Last Updated: 2/21/21

% function name
funcName = 'position_function_001_static';

func = zeros(1, defaultLength);

% save pattern
save([vsFunctionsDir() filesep funcName '.mat'], 'func');

%% Functions 002 and 003 - X and Y functions for optomotor stimulus
% gray, static grating, moving grating at 4 different speeds (both
%  directions); pseudorandom sequence
% pairs with patterns 9 and 10
%
% Last Updated: 3/8/21 - change LED size to include edges (2.8 to 3.75)

XFuncName = 'position_function_002_X_grayStaticRotatingGrating20-60-180-300';
YFuncName = 'position_function_003_Y_grayStaticRotatingGrating20-60-180-300';


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
spdPxFr = gratingSpds .* (1/fullLEDSizeDeg) .* ...
    (1/settings.visstim.funcfreq);
% duration spent on each pixel, in frames (rounded to nearest whole frame)
durFrPx = round(1./spdPxFr);

% durations, in frames
barDurFr = round(grayDur * settings.visstim.funcfreq);
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
seqDurFr = numTrials * (barDurFr + staticDurFr + moveDurFr);
% number of frames in one trial
trialDurFr = barDurFr + staticDurFr + moveDurFr;

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
    staticEndInd = startInd + barDurFr + staticDurFr - 1; 
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
oneYTrial = [(ones(1, barDurFr) * yMeanLum), ...
    (ones(1, staticDurFr + moveDurFr) * yBarDisp)];

% repeat this for all trials
yFunc = repmat(oneYTrial, 1, numTrials);

% save X and Y functions
func = xFunc;
save([vsFunctionsDir() filesep XFuncName '.mat'], 'func');
func = yFunc;
save([vsFunctionsDir() filesep YFuncName '.mat'], 'func');

%% Functions 004 and 005 - X and Y functions for dark looming disc
% gray, disc on static (small), disc loom, disc on static (big), gray
% psuedorandom sequence of loom speeds (different r/v ratios) and loom
%  directions
% pairs with pattern 11
%
% Last Updated: 2/21/21

XFuncName = 'position_function_004_X_darkLoom_allDir_rv10-70-130-310-550';
YFuncName = 'position_function_005_Y_darkLoom_allDir_rv10-70-130-310-550';


% r/v ratios, in seconds
rvRatios = [.010 .070 .130 .310 .550];
numRVs = length(rvRatios);

% loom directions (0 indexing into Y dimension of pattern 11)
numLoomDirs = 5;
loomDirs = 0:(numLoomDirs - 1);

% Y indicies for all gray, all dark
yMeanLum = numLoomDirs;
yAllOff = numLoomDirs + 1;

% deg per pixel, with gap
degPerPxFull = 360 / numHorizLEDs360;

% loom start positions in azimuth, in LED pixels, 1 indexing
loomDirPx = [12, 24, 36, 48, 60];
% loom start position, elevation
loomElePx = 8; % midline
% loom start position, in degrees
loomDirDeg = loomDirPx .* degPerPxFull;
loomEleDeg = loomElePx * degPerPxFull;

% minimum disc diameter, in pixels
minDiscDiamPx = 2;
% maximum disc diameter, in pixels
maxDiscDiamPx = 16;
% disc min and max diameter, in degrees
minDiscDiamDeg = minDiscDiamPx * degPerPxFull;
maxDiscDiamDeg = maxDiscDiamPx * degPerPxFull;

% number of repeats to encode in this function
numReps = 5; 

% duration of gray and static periods, in seconds
durGrayStart = 0.5;
durStaticStart = 0.5;
durStaticEnd = 0.2;
durGrayEnd = 0.5;

% durations in frames
durGrayStartFr = round(durGrayStart * settings.visstim.funcfreq);
durStaticStartFr = round(durStaticStart * settings.visstim.funcfreq);
durStaticEndFr = round(durStaticEnd * settings.visstim.funcfreq);
durGrayEndFr = round(durGrayEnd * settings.visstim.funcfreq);

% call same makeDiscImgSeries() function as patterns, need discDiams for
%  each img in X
[~, discDiams] = makeDiscImgSeries(numHorizLEDs360, ...
    numVertLEDs, degPerPxFull, loomDirDeg(1), loomEleDeg, ...
    minDiscDiamDeg, maxDiscDiamDeg);

% min X index, accounting for 0 indexing
minYInd = 0;

% max X index, accounting for 0 indexing
maxYInd = length(discDiams) - 1;


% initialize - position function for each r/v, dir pair into cell array,
%  for later randomization
xFunc = {};
yFunc = {};

% initialize counter for total number of frames across all trials
numFrames = 0;

% loop through all r/v ratios, all directions
for i = 1:numRVs
    
    % for this r/v ratio, determine disc size in degrees at each time point
    [discSizeTime, ~] = findDiscSizesLoom(rvRatios(i), minDiscDiamDeg, ...
        maxDiscDiamDeg, 1/settings.visstim.funcfreq);
    
    % flip discSizeTime, as it's in time before collision and therefore
    %  starts with biggest disc
    discSizeTime = fliplr(discSizeTime);
    
    % preallocate
    discXInd = zeros(1, length(discSizeTime));
    
    % using discDiams for each image in X, determine indexing into X for
    %  this time series
    for l = 1:length(discSizeTime)
        % index of disc that is closest in size, rounding down (to update
        %  disc, has to be larger)
        ind = find(discSizeTime(l) >= discDiams, 1, 'last'); 
        
        % account for 0 indexing
        discXInd(l) = ind - 1;  
    end
    
    % loop through all loom directions, generate position function sequence
    for j = 1:numLoomDirs
        % gray at start of trial
        xThisTrial = ones(1, durGrayStartFr) * minYInd;
        yThisTrial = ones(1, durGrayStartFr) * yMeanLum;
        
        % static disc, min size
        xThisTrial = [xThisTrial (ones(1, durStaticStartFr) * minYInd)];
        yThisTrial = [yThisTrial (ones(1, durStaticStartFr) * loomDirs(j))];
        
        % looming disc
        xThisTrial = [xThisTrial discXInd];
        yThisTrial = [yThisTrial (ones(1, length(discXInd)) * loomDirs(j))];
        
        % static disc, max size
        xThisTrial = [xThisTrial (ones(1, durStaticEndFr) * maxYInd)];
        yThisTrial = [yThisTrial (ones(1, durStaticEndFr) * loomDirs(j))];
        
        % gray at end of trial
        xThisTrial = [xThisTrial (ones(1, durGrayEndFr) * maxYInd)];
        yThisTrial = [yThisTrial (ones(1,durGrayEndFr) * yMeanLum)];
        
        % save these into cell array
        xFunc = [xFunc {xThisTrial}]; % {xFunc{:} xThisTrial};
        yFunc = [yFunc {yThisTrial}]; % {yFunc{:} yThisTrial};
        
        % increment numFrames counter
        numFrames = numFrames + length(xThisTrial);
    end
end

% generate position function by making one array withpseudorandom order of 
%  these trials
numTrialsPerRep = length(xFunc);

% preallocate
xFuncArray = zeros(1, numFrames * numReps);
yFuncArray = zeros(1, numFrames * numReps);

% counter to keep track of start index of trial
trialStartInd = 1;

for i = 1:numReps
    % generate random ordering of trial indicies
    trialOrder = randperm(numTrialsPerRep);
    
    % append each trial to position function vector
    for j = 1:length(trialOrder)
        % end index of trial depends on trial length
        trialEndInd = trialStartInd + length(xFunc{trialOrder(j)}) - 1;
        
        % add to position vector
        xFuncArray(trialStartInd:trialEndInd) = xFunc{trialOrder(j)};
        yFuncArray(trialStartInd:trialEndInd) = yFunc{trialOrder(j)};
        
        % update start index for next trial
        trialStartInd = trialEndInd + 1;
    end
end

% save X and Y functions
func = xFuncArray;
save([vsFunctionsDir() filesep XFuncName '.mat'], 'func');
func = yFuncArray;
save([vsFunctionsDir() filesep YFuncName '.mat'], 'func');

%% Function 006 - Y function for optomotor stimulus
% closed loop bar in X, static grating, moving grating at 2 different
%   speeds (both directions); pseudorandom sequence
% pairs with patterns 12 and 13
%
% Last Updated: 3/8/21

YFuncName = 'position_function_006_Y_barStaticRotatingGrating60-300';


% velocities of grating, in degrees per second
gratingSpds = [60 300];

% duration, in seconds of each part of trial
barDur = 7;
staticDur = 0.5;
moveDur = 0.5;

% number of repeats to encode in this function
numReps = 10; 

% Y indicies for on, off, gray (-1 from patterns indicies, b/c zero
%  indexing)
stripeWidth = 4; % number of LED dots wide each light/dark stripe is

% indicies for Y options
yBarDisp = 0;
yMeanLum = 1;
yAllOff = 2;
% one period of grating is 2X width of single stripe; start indicies after
%  other options
yGratingInd = (1:(stripeWidth * 2)) + yAllOff;

% convert inputs into pixels and frames
% speed in pixels per frame
spdPxFr = gratingSpds .* (1/fullLEDSizeDeg) .* ...
    (1/settings.visstim.funcfreq);
% duration spent on each pixel, in frames (rounded to nearest whole frame)
durFrPx = round(1./spdPxFr);

% durations, in frames
barDurFr = round(barDur * settings.visstim.funcfreq);
staticDurFr = round(staticDur * settings.visstim.funcfreq);
moveDurFr = round(moveDur * settings.visstim.funcfreq);

% build Y function: gray and static treated the same
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
seqDurFr = numTrials * (barDurFr + staticDurFr + moveDurFr);
% number of frames in one trial
trialDurFr = barDurFr + staticDurFr + moveDurFr;

% preallocate vector
yFunc = zeros(1, seqDurFr);

% basis vector for increasing position values
incPosBasis = yGratingInd;
% basis vector for decreasing position values
decPosBasis = fliplr(yGratingInd);
% shift decreasing position basis vector to start at same point
decPosBasis = circshift(decPosBasis, 1);

% turn indicies into position sequence
for i = 1:numTrials
    % indicies into full sequence for this trial
    startInd = (i-1) * trialDurFr + 1; % start of trial
    % end of bar period
    barEndInd = startInd + barDurFr - 1;
    % start of static period
    staticStartInd = barEndInd + 1;
    % end of static period
    staticEndInd = startInd + barDurFr + staticDurFr - 1; 
    moveStartInd = staticEndInd + 1; % start of move period
    endInd = i*trialDurFr; % end of trial
    
    % build bar portion of trial
    yFunc(startInd:barEndInd) = yBarDisp;
    % build static grating portion of trial
    yFunc(staticStartInd:staticEndInd) = yGratingInd(1);
    
    % build moving portion of trial
    % determine which velocity
    % indicies corresponding to increasing Y position values (move left)
    if velSeq(i) <= numSpds
        spdInd = velSeq(i); % index into which speed
        % number of frames to dwell at each position, given this speed
        dwellFr = durFrPx(spdInd);
        % generate move sequence for this velocity by repeating elements of
        %  basis vector
        repEleSeq = repelem(incPosBasis, dwellFr);
               
    % indicies corresponding to decreasing Y position values (move right)    
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
    yFunc(moveStartInd:endInd) = longSeq(1:moveDurFr); 
end

% % save function
func = yFunc;
save([vsFunctionsDir() filesep YFuncName '.mat'], 'func');

%% Function 007 - Y function for disc loom, while closed loop bar in X
% Y: closed loop bar (X controls), disc on static (small), disc loom, disc 
%  on static (big)
% psuedorandom sequence of loom directions; only 1 loom speed r/v = 0.310 
% pairs with patterns 14 and 15
%
% Last Updated: 3/8/21

YFuncName = 'position_function_007_Y_darkLoom_allDir_rv310';


% r/v ratios, in seconds
rvRatios = [.310];
numRVs = length(rvRatios);

% loom directions (0 indexing into Y dimension of patterns 14 and 15)
numLoomDirs = 3;
loomDirs = 0:(numLoomDirs - 1);

% Y indicies for bar on, loom off
yBarOn = 0;

% deg per pixel, with gap
degPerPxFull = 360 / numHorizLEDs360;

% loom start positions in azimuth, in LED pixels, 1 indexing
loomDirPx = [12, 36, 60];
% loom start position, elevation
loomElePx = 8; % midline
% loom start position, in degrees
loomDirDeg = loomDirPx .* degPerPxFull;
loomEleDeg = loomElePx * degPerPxFull;

% minimum disc diameter, in pixels
minDiscDiamPx = 2;
% maximum disc diameter, in pixels
maxDiscDiamPx = 16;
% disc min and max diameter, in degrees
minDiscDiamDeg = minDiscDiamPx * degPerPxFull;
maxDiscDiamDeg = maxDiscDiamPx * degPerPxFull;

% number of repeats to encode in this function
numReps = 5; 

% duration of bar on, static periods
durBarOn = 45; % time of bar, no loom, in seconds
durStaticStart = 0.5;
durStaticEnd = 0.2;

% durations in frames
durBarOnStartFr = round(durBarOn * settings.visstim.funcfreq);
durStaticStartFr = round(durStaticStart * settings.visstim.funcfreq);
durStaticEndFr = round(durStaticEnd * settings.visstim.funcfreq);

% call same makeDiscImgSeries() function as patterns, need discDiams for
%  each img in Y
[~, discDiams] = makeDiscImgSeries(numHorizLEDs360, ...
    numVertLEDs, degPerPxFull, loomDirDeg(1), loomEleDeg, ...
    minDiscDiamDeg, maxDiscDiamDeg);

% in Y, discDiams repeats for each loom direction
discDiamsAllDirs = repmat(discDiams,1,3);

% length of one discDiams repeat
lenDiscDiams = length(discDiams);


% min Y index, accounting for 0 indexing
minYInd = 0;

% max Y index, accounting for 0 indexing (-1), but +1 for index 0, bar only
maxYInd = length(discDiamsAllDirs);


% initialize - position function for each r/v, dir pair into cell array,
%  for later randomization
yFunc = {};

% initialize counter for total number of frames across all trials
numFrames = 0;

% loop through all r/v ratios, all directions
for i = 1:numRVs
    
    % for this r/v ratio, determine disc size in degrees at each time point
    [discSizeTime, ~] = findDiscSizesLoom(rvRatios(i), minDiscDiamDeg, ...
        maxDiscDiamDeg, 1/settings.visstim.funcfreq);
    
    % flip discSizeTime, as it's in time before collision and therefore
    %  starts with biggest disc
    discSizeTime = fliplr(discSizeTime);
    
    % preallocate
    discYInd = zeros(1, length(discSizeTime));
    
    % using discDiams for each image in X, determine indexing into X for
    %  this time series
    for l = 1:length(discSizeTime)
        % index of disc that is closest in size, rounding down (to update
        %  disc, has to be larger)
        ind = find(discSizeTime(l) >= discDiams, 1, 'last'); 
        
        % accounts for 0 indexing (but +1 for bar only)
        discYInd(l) = ind;  
    end
    
    % loop through all loom directions, generate position function sequence
    for j = 1:numLoomDirs
        % gray at start of trial
        yThisTrial = ones(1, durBarOnStartFr) * yBarOn;
        
        % static disc, min size
        yStartInd = (j-1) * lenDiscDiams + 1; % index for this disc
        yThisTrial = [yThisTrial (ones(1, durStaticStartFr) * yStartInd)];
        
        % looming disc
        yThisTrial = [yThisTrial (discYInd + yStartInd)];
        
        % static disc, max size
        yEndInd = j * lenDiscDiams;
        xThisTrial = [yThisTrial (ones(1, durStaticEndFr) * yEndInd)];

        % save these into cell array
        yFunc = [yFunc {yThisTrial}]; % {yFunc{:} yThisTrial};
        
        % increment numFrames counter
        numFrames = numFrames + length(yThisTrial);
    end
end

% generate position function by making one array withpseudorandom order of 
%  these trials
numTrialsPerRep = length(yFunc);

% preallocate
yFuncArray = zeros(1, numFrames * numReps);

% counter to keep track of start index of trial
trialStartInd = 1;

for i = 1:numReps
    % generate random ordering of trial indicies
    trialOrder = randperm(numTrialsPerRep);
    
    % append each trial to position function vector
    for j = 1:length(trialOrder)
        % end index of trial depends on trial length
        trialEndInd = trialStartInd + length(yFunc{trialOrder(j)}) - 1;
        
        % add to position vector
        yFuncArray(trialStartInd:trialEndInd) = yFunc{trialOrder(j)};
        
        % update start index for next trial
        trialStartInd = trialEndInd + 1;
    end
end

% save function
func = yFuncArray;
save([vsFunctionsDir() filesep YFuncName '.mat'], 'func');

%% Function 008: Y for front-to-back motion of grating, X is closed loop
% closed loop rotating grating in X, moving grating front to back and
%  back to front, alternating
% pairs with patterns 16 and 17
%
% Last Updated: 3/8/21

YFuncName = 'position_function_008_Y_GratingX_FtBBtFGrating_0.5revPerSec';

% Parameters

% number of ball revolutions per second: ball circumference is ~20 mm
numBallRevsPerSec = 0.5; % so, ~10mm/sec FtB/BtF optic flow

% mapping of pattern to ball revolutions (full length of Y dim moves
%  pattern 1/2 of the arena)
numBallRevPerArenadiam = 2;

% duration of optic flow, in sec
moveDur = 1; 

% duration of closed loop X only, no external Y
durXOnly = 7; % in seconds

% pattern build parameters
stripeWidth = 4; % number of LED dots wide each light/dark stripe is
numPeriods = (numHorizLEDs360/2) / (stripeWidth * 2);
% number of Y elements is number of periods for 1 ball revolution times the
%  number of positions required for a full period
numYEle = (numPeriods / numBallRevPerArenadiam) * (stripeWidth * 2);

% convert inputs into pixels and frames
% speed in pixels per frame
% 1 arena diameter covers half the number of horiz LEDs
spdPxFr = (numHorizLEDs360 / 2) * numBallRevsPerSec / ...
    numBallRevPerArenadiam * (1/settings.visstim.funcfreq);
% duration spent on each pixel, in frames (rounded to nearest whole frame)
durFrPx = round(1./spdPxFr);

% basis vector for increasing Y position values
incPosBasis = 0:(numYEle - 1);
% basis vector for decreasing position values
decPosBasis = (numYEle - 1):-1:0;
% shift decreasing position basis vector to also start at zero
decPosBasis = circshift(decPosBasis, 1);

% duration in frames
moveDurFr = round(moveDur * settings.visstim.funcfreq);
durXOnlyFr = round(durXOnly * settings.visstim.funcfreq);


% build position sequence, 1X front-to-back, 1X back-to-front

% preallocate
yFunc = zeros(1, 2 * (moveDurFr + durXOnlyFr));

% first X only closed loop, no change in Y
yFunc(1:durXOnlyFr) = 0; % when only X, use Y = 0;
% change in Y: front-to-back
moveStartInd = durXOnlyFr + 1;
moveEndInd = moveStartInd + moveDurFr - 1;
% sequence for change in Y
ftbMotion = repelem(incPosBasis, durFrPx);
% if sequence long enough
if (length(ftbMotion) >= moveDurFr)
    % just clip and add to function
    yFunc(moveStartInd:moveEndInd) = ftbMotion(1:moveDurFr);
else % otherwise, repeat sequence
    % figure out number of repeats
    numSeqReps = ceil(moveDurFr/length(ftbMotion));
    % generate that vector of sufficient length
    longSeq = repmat(ftbMotion,1,numSeqReps);
    yFunc(moveStartInd:moveEndInd) = longSeq(1:moveDurFr);
end

% second X only closed loop, no change in Y
XOnlyStartInd = moveEndInd + 1;
XOnlyEndInd = XOnlyStartInd + durXOnlyFr - 1;
yFunc(XOnlyStartInd:XOnlyEndInd) = 0;

% change in Y: back-to=front
moveStartInd = XOnlyEndInd + 1;
moveEndInd = moveStartInd + moveDurFr - 1;
% sequence for change in Y
btfMotion = repelem(decPosBasis, durFrPx);
% if sequence long enough
if (length(btfMotion) >= moveDurFr)
    % just clip and add to function
    yFunc(moveStartInd:moveEndInd) = btfMotion(1:moveDurFr);
else % otherwise, repeat sequence
    % figure out number of repeats
    numSeqReps = ceil(moveDurFr/length(btfMotion));
    % generate that vector of sufficient length
    longSeq = repmat(btfMotion,1,numSeqReps);
    yFunc(moveStartInd:moveEndInd) = longSeq(1:moveDurFr);
end
 
% save function
func = yFunc;
save([vsFunctionsDir() filesep YFuncName '.mat'], 'func');
    
%% Function 009: Y for front-to-back motion of grating, X is closed loop
% closed loop bar in X, static grating, moving grating front to back and
%  back to front, alternating
% pairs with patterns 18 and 19 (index 1 for bar only)
%
% Last Updated: 3/8/21

YFuncName = 'position_function_009_Y_barStaticFtBBtFGrating_0.5revPerSec';

% Parameters

% number of ball revolutions per second: ball circumference is ~20 mm
numBallRevsPerSec = 0.5; % so, ~10mm/sec FtB/BtF optic flow

% mapping of pattern to ball revolutions (full length of Y dim moves
%  pattern 1/2 of the arena)
numBallRevPerArenadiam = 2;

% duration of optic flow, in sec
moveDur = 1; 

% duration of closed loop X only, no external Y
durXOnly = 7; % in seconds

% duration of static grating
staticDur = 0.5;

% index of bar only
yBarInd = 0;

% pattern build parameters
stripeWidth = 4; % number of LED dots wide each light/dark stripe is
numPeriods = (numHorizLEDs360/2) / (stripeWidth * 2);
% number of Y elements is number of periods for 1 ball revolution times the
%  number of positions required for a full period
numYEle = (numPeriods / numBallRevPerArenadiam) * (stripeWidth * 2);

% convert inputs into pixels and frames
% speed in pixels per frame
% 1 arena diameter covers half the number of horiz LEDs
spdPxFr = (numHorizLEDs360 / 2) * numBallRevsPerSec / ...
    numBallRevPerArenadiam * (1/settings.visstim.funcfreq);
% duration spent on each pixel, in frames (rounded to nearest whole frame)
durFrPx = round(1./spdPxFr);

% basis vector for increasing Y position values, starts at 1 b/c index 0 is
%  for bar only
incPosBasis = 1:(numYEle);
% basis vector for decreasing position values
decPosBasis = numYEle:-1:1;
% shift decreasing position basis vector to also start at zero
decPosBasis = circshift(decPosBasis, 1);

% duration in frames
moveDurFr = round(moveDur * settings.visstim.funcfreq);
durXOnlyFr = round(durXOnly * settings.visstim.funcfreq);
staticDurFr = round(staticDur * settings.visstim.funcfreq);


% build position sequence, 1X front-to-back, 1X back-to-front

% preallocate
yFunc = zeros(1, 2 * (moveDurFr + durXOnlyFr + staticDurFr));

% first X only closed loop, no change in Y
yFunc(1:durXOnlyFr) = yBarInd; % when only X, use Y = 0;

% static grating
staticStartInd = durXOnlyFr + 1;
staticEndInd = staticStartInd + staticDurFr - 1;
% first grating element in Y
yFunc(staticStartInd:staticEndInd) = incPosBasis(1);

% change in Y: front-to-back
moveStartInd = staticEndInd + 1;
moveEndInd = moveStartInd + moveDurFr - 1;
% sequence for change in Y
ftbMotion = repelem(incPosBasis, durFrPx);
% if sequence long enough
if (length(ftbMotion) >= moveDurFr)
    % just clip and add to function
    yFunc(moveStartInd:moveEndInd) = ftbMotion(1:moveDurFr);
else % otherwise, repeat sequence
    % figure out number of repeats
    numSeqReps = ceil(moveDurFr/length(ftbMotion));
    % generate that vector of sufficient length
    longSeq = repmat(ftbMotion,1,numSeqReps);
    yFunc(moveStartInd:moveEndInd) = longSeq(1:moveDurFr);
end

% second X only closed loop, no change in Y
XOnlyStartInd = moveEndInd + 1;
XOnlyEndInd = XOnlyStartInd + durXOnlyFr - 1;
yFunc(XOnlyStartInd:XOnlyEndInd) = yBarInd;

% static grating
staticStartInd = XOnlyEndInd + 1;
staticEndInd = staticStartInd + staticDurFr - 1;
yFunc(staticStartInd:staticEndInd) = decPosBasis(1);

% change in Y: back-to=front
moveStartInd = staticEndInd + 1;
moveEndInd = moveStartInd + moveDurFr - 1;
% sequence for change in Y
btfMotion = repelem(decPosBasis, durFrPx);
% if sequence long enough
if (length(btfMotion) >= moveDurFr)
    % just clip and add to function
    yFunc(moveStartInd:moveEndInd) = btfMotion(1:moveDurFr);
else % otherwise, repeat sequence
    % figure out number of repeats
    numSeqReps = ceil(moveDurFr/length(btfMotion));
    % generate that vector of sufficient length
    longSeq = repmat(btfMotion,1,numSeqReps);
    yFunc(moveStartInd:moveEndInd) = longSeq(1:moveDurFr);
end
 
% save function
func = yFunc;
save([vsFunctionsDir() filesep YFuncName '.mat'], 'func');


