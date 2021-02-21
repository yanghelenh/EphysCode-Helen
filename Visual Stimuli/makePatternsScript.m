% makePatternsScript.m
%
% Script for making all the patterns, ordered in numerical order
%
% CREATED: 2/14/21 - HHY
%
% UPDATED:
%   2/14/21 - HHY
%

%% Some constants
gsVal = 3; % for pattern.gs_val, means 8 possible pixel vlaues
% luminance levels
meanLum = 3;
darkLum = 0;
lightLum = 7;

% arena diameter, in cm
arenaDiam = 12;

% angular size of LED, given arena diameter of 12 cm; does not account for
%  gap between LEDs
degPerLED = 2.8; 

% size of arena, in panels
numHorizPanels360 = 12; % number of panels, if arena were full 360
numHorizPanels270 = 9; % number of panels, wrapping 270 to 360
numVertPanels = 2; % number of vertical panels

LEDsPerPanel = 8; % number of LEDs per panel

% size of arena, in LEDs
numHorizLEDs360 = numHorizPanels360 * LEDsPerPanel;
numHorizLEDs270 = numHorizPanels270 * LEDsPerPanel;
numVertLEDs = numVertPanels * LEDsPerPanel;

% shift directions for ShiftMatrix, when starting with pattern at X=1
% for regular vs. inverted closed loop
horizShiftReg = 'l';
horizShiftInv = 'r';


% panel map for fictive 360deg arena (panels 19-24 are fictive)
pattern.Panel_map = [9, 12, 13, 15, 17, 14, 16, 18, 8 , 19, 20, 21; ...
    1, 5, 2, 6, 10, 3, 7, 11, 4, 22, 23, 24]; 

%% Pattern 001: 2 LED wide, vertical light bar on gray, 360deg arena, 
%   regular direction
%
% X encodes position of bar
% Y encodes: 1 - bar displayed, 2 - all panels mean lum, 3 - all panels
%  dark

% Pattern Name
patternName = 'Pattern_001_2pxLightVertBarOnGray360Reg';

barWidth = 2; % number of LED dots wide

% indicies for Y options
yBarDisp = 1;
yMeanLum = 2;
yAllOff = 3;

% Pattern basic info
pattern.x_num = numHorizLEDs360; 
pattern.y_num = 3; % for 3 possible Y values

pattern.num_panels = numHorizPanels360 * numVertPanels;
pattern.gs_val = gsVal;

% Build Pattern

% initialize array
Pats = zeros(numVertLEDs, numHorizLEDs360, pattern.x_num, pattern.y_num);

% bar pattern for 1 X,Y
% initalize full screen at mean luminance
barPattern = ones(numVertLEDs, numHorizLEDs360) * meanLum;
% add bar at smallest v coordinates
barStartPos = 1;
barPattern(:, barStartPos:(barWidth + barStartPos - 1)) = lightLum;

% generate shifted pattern for all X
for i = 1:numHorizLEDs360
    % shift pattern 1 LED to left
    Pats(:,:,i,yBarDisp) = ShiftMatrix(barPattern, i-1, horizShiftReg,'y');
    
end

% Set pattern values for other Y options
Pats(:,:,:,yMeanLum) = meanLum;
Pats(:,:,:,yAllOff) = darkLum;

% put data in structure
pattern.Pats = Pats; 		 

% convert into appropriate format for panels
pattern.BitMapIndex = process_panel_map(pattern);
pattern.data = Make_pattern_vector(pattern);

% save pattern
save([vsPatternsDir() filesep patternName '.mat'], 'pattern');

%% Pattern 002: 2 LED wide, vertical light bar, 360 deg arena, 
%   inverted direction
%
% X encodes position of bar
% Y encodes: 1 - bar displayed, 2 - all panels mean lum, 3 - all panels
%  dark

% Pattern Name
patternName = 'Pattern_002_2pxLightVertBarOnGray360Inv';

barWidth = 2; % number of LED dots wide

% indicies for Y options
yBarDisp = 1;
yMeanLum = 2;
yAllOff = 3;

% Pattern basic info
pattern.x_num = numHorizLEDs360; 
pattern.y_num = 3; % for 3 possible Y values

pattern.num_panels = numHorizPanels360 * numVertPanels;
pattern.gs_val = gsVal;

% Build Pattern

% initialize array
Pats = zeros(numVertLEDs, numHorizLEDs360, pattern.x_num, pattern.y_num);

% bar pattern for 1 X,Y
% initalize full screen at mean luminance
barPattern = ones(numVertLEDs, numHorizLEDs360) * meanLum;
% add bar at smallest v coordinates
barStartPos = 1;
barPattern(:, barStartPos:(barWidth + barStartPos - 1)) = lightLum;

% generate shifted pattern for all X
for i = 1:numHorizLEDs360
    % shift pattern 1 LED to left
    Pats(:,:,i,yBarDisp) = ShiftMatrix(barPattern, i-1, horizShiftInv,'y');
    
end

% Set pattern values for other Y options
Pats(:,:,:,yMeanLum) = meanLum;
Pats(:,:,:,yAllOff) = darkLum;

% put data in structure
pattern.Pats = Pats; 		 

% convert into appropriate format for panels
pattern.BitMapIndex = process_panel_map(pattern);
pattern.data = Make_pattern_vector(pattern);

% save pattern
save([vsPatternsDir() filesep patternName '.mat'], 'pattern');

%% Pattern 003: 2 LED wide, vertical light bar on dark, 360deg arena, 
%   regular direction
%
% X encodes position of bar
% Y encodes: 1 - bar displayed, 2 - all panels dark

% Pattern Name
patternName = 'Pattern_003_2pxLightVertBarOnDark360Reg';

barWidth = 2; % number of LED dots wide

% indicies for Y options
yBarDisp = 1;
yAllOff = 2;

% Pattern basic info
pattern.x_num = numHorizLEDs360; 
pattern.y_num = 3; % for 3 possible Y values

pattern.num_panels = numHorizPanels360 * numVertPanels;
pattern.gs_val = gsVal;

% Build Pattern

% initialize array
Pats = zeros(numVertLEDs, numHorizLEDs360, pattern.x_num, pattern.y_num);

% bar pattern for 1 X,Y
% initalize full screen at dark luminance
barPattern = ones(numVertLEDs, numHorizLEDs360) * darkLum;
% add bar at smallest v coordinates
barStartPos = 1;
barPattern(:, barStartPos:(barWidth + barStartPos - 1)) = lightLum;

% generate shifted pattern for all X
for i = 1:numHorizLEDs360
    % shift pattern 1 LED to left
    Pats(:,:,i,yBarDisp) = ShiftMatrix(barPattern, i-1, horizShiftReg,'y');
    
end

% Set pattern values for other Y options
Pats(:,:,:,yAllOff) = darkLum;

% put data in structure
pattern.Pats = Pats; 		 

% convert into appropriate format for panels
pattern.BitMapIndex = process_panel_map(pattern);
pattern.data = Make_pattern_vector(pattern);

% save pattern
save([vsPatternsDir() filesep patternName '.mat'], 'pattern');

%% Pattern 004: 2 LED wide, vertical light bar on dark, 360deg arena, 
%   inverted direction
%
% X encodes position of bar
% Y encodes: 1 - bar displayed, 2 - all panels dark

% Pattern Name
patternName = 'Pattern_004_2pxLightVertBarOnDark360Inv';

barWidth = 2; % number of LED dots wide

% indicies for Y options
yBarDisp = 1;
yAllOff = 2;

% Pattern basic info
pattern.x_num = numHorizLEDs360; 
pattern.y_num = 3; % for 3 possible Y values

pattern.num_panels = numHorizPanels360 * numVertPanels;
pattern.gs_val = gsVal;

% Build Pattern

% initialize array
Pats = zeros(numVertLEDs, numHorizLEDs360, pattern.x_num, pattern.y_num);

% bar pattern for 1 X,Y
% initalize full screen at dark luminance
barPattern = ones(numVertLEDs, numHorizLEDs360) * darkLum;
% add bar at smallest v coordinates
barStartPos = 1;
barPattern(:, barStartPos:(barWidth + barStartPos - 1)) = lightLum;

% generate shifted pattern for all X
for i = 1:numHorizLEDs360
    % shift pattern 1 LED to left
    Pats(:,:,i,yBarDisp) = ShiftMatrix(barPattern, i-1, horizShiftInv,'y');
    
end

% Set pattern values for other Y options
Pats(:,:,:,yAllOff) = darkLum;

% put data in structure
pattern.Pats = Pats; 		 

% convert into appropriate format for panels
pattern.BitMapIndex = process_panel_map(pattern);
pattern.data = Make_pattern_vector(pattern);

% save pattern
save([vsPatternsDir() filesep patternName '.mat'], 'pattern');

%% Pattern 005: 2 LED wide, vertical dark bar on gray, 360deg arena, 
%   regular direction
%
% X encodes position of bar
% Y encodes: 1 - bar displayed, 2 - all panels mean lum, 3 - all panels
%  dark

% Pattern Name
patternName = 'Pattern_005_2pxDarkVertBarOnGray360Reg';

barWidth = 2; % number of LED dots wide

% indicies for Y options
yBarDisp = 1;
yMeanLum = 2;
yAllOff = 3;

% Pattern basic info
pattern.x_num = numHorizLEDs360; 
pattern.y_num = 3; % for 3 possible Y values

pattern.num_panels = numHorizPanels360 * numVertPanels;
pattern.gs_val = gsVal;

% Build Pattern

% initialize array
Pats = zeros(numVertLEDs, numHorizLEDs360, pattern.x_num, pattern.y_num);

% bar pattern for 1 X,Y
% initalize full screen at mean luminance
barPattern = ones(numVertLEDs, numHorizLEDs360) * meanLum;
% add bar at smallest v coordinates
barStartPos = 1;
barPattern(:, barStartPos:(barWidth + barStartPos - 1)) = darkLum;

% generate shifted pattern for all X
for i = 1:numHorizLEDs360
    % shift pattern 1 LED to left
    Pats(:,:,i,yBarDisp) = ShiftMatrix(barPattern, i-1, horizShiftReg,'y');
    
end

% Set pattern values for other Y options
Pats(:,:,:,yMeanLum) = meanLum;
Pats(:,:,:,yAllOff) = darkLum;

% put data in structure
pattern.Pats = Pats; 		 

% convert into appropriate format for panels
pattern.BitMapIndex = process_panel_map(pattern);
pattern.data = Make_pattern_vector(pattern);

% save pattern
save([vsPatternsDir() filesep patternName '.mat'], 'pattern');

%% Pattern 006: 2 LED wide, vertical dark bar on gray, 360deg arena, 
%   inverted direction
%
% X encodes position of bar
% Y encodes: 1 - bar displayed, 2 - all panels mean lum, 3 - all panels
%  dark

% Pattern Name
patternName = 'Pattern_006_2pxDarkVertBarOnGray360Inv';

barWidth = 2; % number of LED dots wide

% indicies for Y options
yBarDisp = 1;
yMeanLum = 2;
yAllOff = 3;

% Pattern basic info
pattern.x_num = numHorizLEDs360; 
pattern.y_num = 3; % for 3 possible Y values

pattern.num_panels = numHorizPanels360 * numVertPanels;
pattern.gs_val = gsVal;

% Build Pattern

% initialize array
Pats = zeros(numVertLEDs, numHorizLEDs360, pattern.x_num, pattern.y_num);

% bar pattern for 1 X,Y
% initalize full screen at mean luminance
barPattern = ones(numVertLEDs, numHorizLEDs360) * meanLum;
% add bar at smallest v coordinates
barStartPos = 1;
barPattern(:, barStartPos:(barWidth + barStartPos - 1)) = darkLum;

% generate shifted pattern for all X
for i = 1:numHorizLEDs360
    % shift pattern 1 LED to left
    Pats(:,:,i,yBarDisp) = ShiftMatrix(barPattern, i-1, horizShiftInv,'y');
    
end

% Set pattern values for other Y options
Pats(:,:,:,yMeanLum) = meanLum;
Pats(:,:,:,yAllOff) = darkLum;

% put data in structure
pattern.Pats = Pats; 		 

% convert into appropriate format for panels
pattern.BitMapIndex = process_panel_map(pattern);
pattern.data = Make_pattern_vector(pattern);

% save pattern
save([vsPatternsDir() filesep patternName '.mat'], 'pattern');

%% Pattern 007: 4 LED wide, vertical dark bar on gray, 360deg arena, 
%   regular direction
%
% X encodes position of bar
% Y encodes: 1 - bar displayed, 2 - all panels mean lum, 3 - all panels
%  dark

% Pattern Name
patternName = 'Pattern_007_4pxDarkVertBarOnGray360Reg';

barWidth = 4; % number of LED dots wide

% indicies for Y options
yBarDisp = 1;
yMeanLum = 2;
yAllOff = 3;

% Pattern basic info
pattern.x_num = numHorizLEDs360; 
pattern.y_num = 3; % for 3 possible Y values

pattern.num_panels = numHorizPanels360 * numVertPanels;
pattern.gs_val = gsVal;

% Build Pattern

% initialize array
Pats = zeros(numVertLEDs, numHorizLEDs360, pattern.x_num, pattern.y_num);

% bar pattern for 1 X,Y
% initalize full screen at mean luminance
barPattern = ones(numVertLEDs, numHorizLEDs360) * meanLum;
% add bar at smallest v coordinates
barStartPos = 1;
barPattern(:, barStartPos:(barWidth + barStartPos - 1)) = darkLum;

% generate shifted pattern for all X
for i = 1:numHorizLEDs360
    % shift pattern 1 LED to left
    Pats(:,:,i,yBarDisp) = ShiftMatrix(barPattern, i-1, horizShiftReg,'y');
    
end

% Set pattern values for other Y options
Pats(:,:,:,yMeanLum) = meanLum;
Pats(:,:,:,yAllOff) = darkLum;

% put data in structure
pattern.Pats = Pats; 		 

% convert into appropriate format for panels
pattern.BitMapIndex = process_panel_map(pattern);
pattern.data = Make_pattern_vector(pattern);

% save pattern
save([vsPatternsDir() filesep patternName '.mat'], 'pattern');

%% Pattern 008: 4 LED wide, vertical dark bar on gray, 360deg arena, 
%   inverted direction
%
% X encodes position of bar
% Y encodes: 1 - bar displayed, 2 - all panels mean lum, 3 - all panels
%  dark

% Pattern Name
patternName = 'Pattern_008_4pxDarkVertBarOnGray360Inv';

barWidth = 4; % number of LED dots wide

% indicies for Y options
yBarDisp = 1;
yMeanLum = 2;
yAllOff = 3;

% Pattern basic info
pattern.x_num = numHorizLEDs360; 
pattern.y_num = 3; % for 3 possible Y values

pattern.num_panels = numHorizPanels360 * numVertPanels;
pattern.gs_val = gsVal;

% Build Pattern

% initialize array
Pats = zeros(numVertLEDs, numHorizLEDs360, pattern.x_num, pattern.y_num);

% bar pattern for 1 X,Y
% initalize full screen at mean luminance
barPattern = ones(numVertLEDs, numHorizLEDs360) * meanLum;
% add bar at smallest v coordinates
barStartPos = 1;
barPattern(:, barStartPos:(barWidth + barStartPos - 1)) = darkLum;

% generate shifted pattern for all X
for i = 1:numHorizLEDs360
    % shift pattern 1 LED to left
    Pats(:,:,i,yBarDisp) = ShiftMatrix(barPattern, i-1, horizShiftInv,'y');
    
end

% Set pattern values for other Y options
Pats(:,:,:,yMeanLum) = meanLum;
Pats(:,:,:,yAllOff) = darkLum;

% put data in structure
pattern.Pats = Pats; 		 

% convert into appropriate format for panels
pattern.BitMapIndex = process_panel_map(pattern);
pattern.data = Make_pattern_vector(pattern);

% save pattern
save([vsPatternsDir() filesep patternName '.mat'], 'pattern');

%% Pattern 009: 4 LED wide, light/dark square-wave grating, 360deg arena, 
%   regular direction
%
% X encodes position of grating
% Y encodes: 1 - grating displayed, 2 - all panels mean lum, 3 - all panels
%  dark

% Pattern Name
patternName = 'Pattern_009_4pxLightDarkSquareGrating360Reg';

stripeWidth = 4; % number of LED dots wide each light/dark stripe is

% indicies for Y options
yGratingDisp = 1;
yMeanLum = 2;
yAllOff = 3;

% Pattern basic info
pattern.x_num = numHorizLEDs360; 
pattern.y_num = 3; % for 3 possible Y values

pattern.num_panels = numHorizPanels360 * numVertPanels;
pattern.gs_val = gsVal;

% Build Pattern

% initialize array
Pats = zeros(numVertLEDs, numHorizLEDs360, pattern.x_num, pattern.y_num);

% make grating pattern, start with dark
% single dark, light stripe pair
onePeriod = ones(numVertLEDs, 2*stripeWidth);
onePeriod(:,1:stripeWidth) = darkLum;
onePeriod(:,(stripeWidth+1):(stripeWidth*2)) = lightLum;

% repeat single period to fill whole arena
numReps = numHorizLEDs360 / (2*stripeWidth);
gratingPattern = repmat(onePeriod, 1, numReps);

% generate shifted pattern for all X
for i = 1:numHorizLEDs360
    % shift pattern 1 LED to left
    Pats(:,:,i,yGratingDisp) = ShiftMatrix(gratingPattern, i-1, ...
        horizShiftReg,'y');
    
end

% Set pattern values for other Y options
Pats(:,:,:,yMeanLum) = meanLum;
Pats(:,:,:,yAllOff) = darkLum;

% put data in structure
pattern.Pats = Pats; 		 

% convert into appropriate format for panels
pattern.BitMapIndex = process_panel_map(pattern);
pattern.data = Make_pattern_vector(pattern);

% save pattern
save([vsPatternsDir() filesep patternName '.mat'], 'pattern');

%% Pattern 010: 4 LED wide, light/dark square-wave grating, 360deg arena, 
%   inverted direction
%
% X encodes position of grating
% Y encodes: 1 - grating displayed, 2 - all panels mean lum, 3 - all panels
%  dark

% Pattern Name
patternName = 'Pattern_010_4pxLightDarkSquareGrating360Inv';

stripeWidth = 4; % number of LED dots wide each light/dark stripe is

% indicies for Y options
yGratingDisp = 1;
yMeanLum = 2;
yAllOff = 3;

% Pattern basic info
pattern.x_num = numHorizLEDs360; 
pattern.y_num = 3; % for 3 possible Y values

pattern.num_panels = numHorizPanels360 * numVertPanels;
pattern.gs_val = gsVal;

% Build Pattern

% initialize array
Pats = zeros(numVertLEDs, numHorizLEDs360, pattern.x_num, pattern.y_num);

% make grating pattern, start with dark
% single dark, light stripe pair
onePeriod = ones(numVertLEDs, 2*stripeWidth);
onePeriod(:,1:stripeWidth) = darkLum;
onePeriod(:,(stripeWidth+1):(stripeWidth*2)) = lightLum;

% repeat single period to fill whole arena
numReps = numHorizLEDs360 / (2*stripeWidth);
gratingPattern = repmat(onePeriod, 1, numReps);

% generate shifted pattern for all X
for i = 1:numHorizLEDs360
    % shift pattern 1 LED to left
    Pats(:,:,i,yGratingDisp) = ShiftMatrix(gratingPattern, i-1, ...
        horizShiftInv,'y');
    
end

% Set pattern values for other Y options
Pats(:,:,:,yMeanLum) = meanLum;
Pats(:,:,:,yAllOff) = darkLum;

% put data in structure
pattern.Pats = Pats; 		 

% convert into appropriate format for panels
pattern.BitMapIndex = process_panel_map(pattern);
pattern.data = Make_pattern_vector(pattern);

% save pattern
save([vsPatternsDir() filesep patternName '.mat'], 'pattern');

%% Pattern 11: Dark looming disc off of gray, 2 px to 16 px diameter
% X encodes disc size, Y encodes azimuthal angle (all discs centered at
%  elevation midline)
% To pair with open loop position function for different loom speeds
% Azimuthal locations, LEDs: 12 (left side), 24 (front left), 36 (front), 
%  48 (front right), 60 (right)

% Pattern Name
patternName = 'Pattern_011_darkDiscLoom_2-16px_L-FL-F-FR-R_mid';

% Parameters
% loom start positions in azimuth, in LED pixels, 1 indexing
loomDirPx = [12, 24, 36, 48, 60];
numLoomDir = length(loomDirPx);

% loom start position, elevation
loomElePx = 8; % midline

% minimum disc diameter, in pixels
minDiscDiamPx = 2;
% maximum disc diameter, in pixels
maxDiscDiamPx = 16;

% Y indicies
yMeanLum = numLoomDir + 1;
yAllOff = numLoomDir + 2;

% Pattern basic info
% all start positions, plus one for fully gray and one for fully dark
pattern.y_num = numLoomDir + 2; 

pattern.num_panels = numHorizPanels360 * numVertPanels;
pattern.gs_val = gsVal;


% Build pattern


% conversion from LED pixels to degrees, including gaps
degPerPxFull = 360 / numHorizLEDs360;

% loom start position, in degrees
loomDirDeg = loomDirPx .* degPerPxFull;
loomEleDeg = loomElePx * degPerPxFull;

% disc min and max diameter, in degrees
minDiscDiamDeg = minDiscDiamPx * degPerPxFull;
maxDiscDiamDeg = maxDiscDiamPx * degPerPxFull;

% call makeDiscImgSeries() once; get disc diameters, number of imgs
[discImgs, discDiams] = makeDiscImgSeries(numHorizLEDs360, numVertLEDs,...
    degPerPxFull, loomDirDeg(1), loomEleDeg, minDiscDiamDeg, ...
    maxDiscDiamDeg);
% number of images determines size X
pattern.x_num = length(discDiams);

% initialize array, gray
Pats = ones(numVertLEDs, numHorizLEDs360, pattern.x_num, ...
    pattern.y_num) * meanLum;


% generate disc pattern for each start position
for i = 1:numLoomDir
    
    tempPat = ones(numVertLEDs, numHorizLEDs360, pattern.x_num, 1) * ...
        meanLum;

    % returns whether each location is part of disc or not
    [discImgs, ~] = makeDiscImgSeries(numHorizLEDs360, numVertLEDs,...
        degPerPxFull, loomDirDeg(i), loomEleDeg, minDiscDiamDeg, ...
        maxDiscDiamDeg);
    
    tempPat(discImgs) = darkLum;
    
    Pats(:,:,:,i) = tempPat;
end

% add gray and dark patterns
Pats(:,:,:,yMeanLum) = meanLum;
Pats(:,:,:,yAllOff) = darkLum;

% put data in structure
pattern.Pats = Pats; 		 

% convert into appropriate format for panels
pattern.BitMapIndex = process_panel_map(pattern);
pattern.data = Make_pattern_vector(pattern);

% save pattern
save([vsPatternsDir() filesep patternName '.mat'], 'pattern');

%% Pattern 12 - 2 LED wide light vertical bar, starfield on gray,
% regular direction
% Bar position encoded in X, starfield moves front to back in Y, frontal
%  region (1 panel, 30 deg) gray with no stars

% Pattern Name
patternName = 'Pattern_012_2pxLightVertBarStarfieldOnGray360Reg';

% Parameters
ballDiam = 0.646; % diameter of FicTrac ball, in cm

barWidth = 2; % in LEDs
starSize = [1, 2]; % star size, in LEDs [v,h]
starDensity = 0.25; % density of stars, as percentage of field
% horiz LED coordinates of front gray area, 1 indexing
frontGrayInd = [33 40]; 
% horiz indicies of left and right fields, 1 indexing
indLeftField = [1 36];
indRightField = [37 72];

% luminances of different portions
bkgdLum = meanLum;
starLum = lightLum;
barLum = lightLum;

