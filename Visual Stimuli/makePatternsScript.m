% makePatternsScript.m
%
% Script for making all the patterns, ordered in numerical order
%
% CREATED: 2/14/21 - HHY
%
% UPDATED:
%   2/14/21 - HHY
%   3/10/21 - HHY
%   1/7/24 - HHY

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
%
% Last Updated: 2/21/21

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
%
% Last Updated: 2/21/21

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
%
% Last Updated: 2/21/21

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
%
% Last Updated: 2/21/21

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
%
% Last Updated: 2/21/21

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
%
% Last Updated: 2/21/21

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
%
% Last Updated: 2/21/21

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
%
% Last Updated: 2/21/21

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
%
% Last Updated: 2/21/21

% Pattern Name
patternName = 'Pattern_009_4pxLightDarkSquareGrating360Reg';

stripeWidth = 4; % number of LED dots wide each light/dark stripe is

% indicies for Y options
yGratingDisp1 = 1;
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
    Pats(:,:,i,yGratingDisp1) = ShiftMatrix(gratingPattern, i-1, ...
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
%
% Last Updated: 2/21/21

% Pattern Name
patternName = 'Pattern_010_4pxLightDarkSquareGrating360Inv';

stripeWidth = 4; % number of LED dots wide each light/dark stripe is

% indicies for Y options
yGratingDisp1 = 1;
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
    Pats(:,:,i,yGratingDisp1) = ShiftMatrix(gratingPattern, i-1, ...
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
%
% Last Updated: 2/21/21

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

%% Pattern 12: 2 LED wide light vertical bar in X, 4 LED wide grating in Y,
%  360 deg arena, regular direction
% Bar position encoded in X
% Y encodes dark, gray, all grating positions
% Meant for closed loop bar, open loop optomotor grating
%
% Last Updated: 3/4/21

% Pattern Name
patternName = 'Pattern_012_2pxLightVertBarX_4pxLightDarkSquareGratingY_360Reg';

% Parameters
barWidth = 2; % number of LED dots wide
stripeWidth = 4; % number of LED dots wide each light/dark stripe is

% indicies for Y options
yBarDisp = 1;
yMeanLum = 2;
yAllOff = 3;
% one period of grating is 2X width of single stripe; start indicies after
%  other options
yGratingInd = (1:(stripeWidth * 2)) + yAllOff;

% Pattern basic info
pattern.x_num = numHorizLEDs360; 
pattern.y_num = yGratingInd(end); % end index is number of options

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

% make grating pattern, start with dark
% single dark, light stripe pair
onePeriod = ones(numVertLEDs, 2*stripeWidth);
onePeriod(:,1:stripeWidth) = darkLum;
onePeriod(:,(stripeWidth+1):(stripeWidth*2)) = lightLum;

% repeat single period to fill whole arena
numReps = numHorizLEDs360 / (2*stripeWidth);
gratingPattern = repmat(onePeriod, 1, numReps);

% loop over all X
for i = 1:numHorizLEDs360
    % shift bar pattern 1 LED to left
    Pats(:,:,i,yBarDisp) = ShiftMatrix(barPattern, i-1, horizShiftReg,'y');
    
    % loop over all grating Y values for this X
    for j = 1:length(yGratingInd)
        thisYInd = yGratingInd(j);
        % shift grating pattern 1 LED to left, to make full period
        Pats(:,:,i,thisYInd) = ShiftMatrix(gratingPattern, j-1, ...
            horizShiftReg, 'y');
    end  
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

%% Pattern 13: 2 LED wide light vertical bar in X, 4 LED wide grating in Y,
%  360 deg arena, inverted direction
% Bar position encoded in X
% Y encodes dark, gray, all grating positions
% Meant for closed loop bar, open loop optomotor grating
%
% Last Updated: 3/4/21

% Pattern Name
patternName = 'Pattern_013_2pxLightVertBarX_4pxLightDarkSquareGratingY_360Inv';

% Parameters
barWidth = 2; % number of LED dots wide
stripeWidth = 4; % number of LED dots wide each light/dark stripe is

% indicies for Y options
yBarDisp = 1;
yMeanLum = 2;
yAllOff = 3;
% one period of grating is 2X width of single stripe; start indicies after
%  other options
yGratingInd = (1:(stripeWidth * 2)) + yAllOff;

% Pattern basic info
pattern.x_num = numHorizLEDs360; 
pattern.y_num = yGratingInd(end); % end index is number of options

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

% make grating pattern, start with dark
% single dark, light stripe pair
onePeriod = ones(numVertLEDs, 2*stripeWidth);
onePeriod(:,1:stripeWidth) = darkLum;
onePeriod(:,(stripeWidth+1):(stripeWidth*2)) = lightLum;

% repeat single period to fill whole arena
numReps = numHorizLEDs360 / (2*stripeWidth);
gratingPattern = repmat(onePeriod, 1, numReps);

% loop over all X
for i = 1:numHorizLEDs360
    % shift bar pattern 1 LED to left
    Pats(:,:,i,yBarDisp) = ShiftMatrix(barPattern, i-1, horizShiftInv,'y');
    
    % loop over all grating Y values for this X
    for j = 1:length(yGratingInd)
        thisYInd = yGratingInd(j);
        % shift grating pattern 1 LED to left, to make full period
        Pats(:,:,i,thisYInd) = ShiftMatrix(gratingPattern, j-1, ...
            horizShiftInv, 'y');
    end  
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

%% Pattern 14: 2 LED wide light vertical bar in X, dark loom disc in Y
%  regular direction (for bar), 360 deg arena
% Azimuthal locations for discs, LEDs: 12 (left side), 36 (front), 60 
%  (right); all discs centered at elevation midline
% Meant for closed loop bar, open loop loom
%
% Last Updated: 3/4/21

% Pattern Name
patternName = 'Pattern_014_2pxLightVertBarX_darkDiscLoomY_2-16px_L-F-R_mid_360Reg';

% Parameters
barWidth = 2; % number of LED dots wide

% indicies for Y options
yBarDisp = 1;

% loom start positions in azimuth, in LED pixels, 1 indexing
loomDirPx = [12, 36, 60];
numLoomDir = length(loomDirPx);

% loom start position, elevation
loomElePx = 8; % midline

% minimum disc diameter, in pixels
minDiscDiamPx = 2;
% maximum disc diameter, in pixels
maxDiscDiamPx = 16;


% Pattern basic info
pattern.x_num = numHorizLEDs360; 

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


% initialize discImgsAll as logical array of all zeros (for first Y index,
% where there is no disc)
discImgsAll = false(numVertLEDs,numHorizLEDs360);

% call makeDiscImgSeries() for each loom direction
for i = 1:numLoomDir
    [discImgs, discDiams] = makeDiscImgSeries(numHorizLEDs360, ...
        numVertLEDs, degPerPxFull, loomDirDeg(i), loomEleDeg, ...
        minDiscDiamDeg, maxDiscDiamDeg);
    
    % concatenate to growing array    
    discImgsAll = cat(3, discImgsAll, discImgs);
end

% length of each disc image series
oneDiscImgLen = length(discDiams);


% Y size is 3rd dimension of discImgsAll
pattern.y_num = oneDiscImgLen * numLoomDir + 1;

% initialize array, gray
Pats = ones(numVertLEDs, numHorizLEDs360, pattern.x_num, ...
    pattern.y_num) * meanLum;

% bar pattern for 1 X,Y
% initalize full screen at mean luminance
barPattern = ones(numVertLEDs, numHorizLEDs360) * meanLum;
% add bar at smallest v coordinates
barStartPos = 1;
barPattern(:, barStartPos:(barWidth + barStartPos - 1)) = lightLum;

% loop over all Y
for i = 1:pattern.y_num
    % loop over all x
    for j = 1:numHorizLEDs360
        % generate bar pattern for this X
        thisPattern = ShiftMatrix(barPattern, j-1, horizShiftReg,'y');
        
        % add loom to this bar
        thisPattern(discImgsAll(:,:,i)) = darkLum;
        
        % add to Pats
        Pats(:,:,j,i) = thisPattern;
    end
    
end

% put data in structure
pattern.Pats = Pats; 	

% convert into appropriate format for panels
pattern.BitMapIndex = process_panel_map(pattern);
pattern.data = Make_pattern_vector(pattern);

% save pattern
save([vsPatternsDir() filesep patternName '.mat'], 'pattern');

%% Pattern 15: 2 LED wide light vertical bar in X, dark loom disc in Y
%  inverted direction (for bar), 360 deg arena
% Azimuthal locations for discs, LEDs: 12 (left side), 36 (front), 60 
%  (right); all discs centered at elevation midline
% Meant for closed loop bar, open loop loom
%
% Last Updated: 3/4/21

% Pattern Name
patternName = 'Pattern_015_2pxLightVertBarX_darkDiscLoomY_2-16px_L-F-R_mid_360Inv';

% Parameters
barWidth = 2; % number of LED dots wide

% indicies for Y options
yBarDisp = 1;

% loom start positions in azimuth, in LED pixels, 1 indexing
loomDirPx = [60, 36, 12]; % inverted from pattern 14, b/c of left right flip
numLoomDir = length(loomDirPx);

% loom start position, elevation
loomElePx = 8; % midline

% minimum disc diameter, in pixels
minDiscDiamPx = 2;
% maximum disc diameter, in pixels
maxDiscDiamPx = 16;


% Pattern basic info
pattern.x_num = numHorizLEDs360; 

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


% initialize discImgsAll as logical array of all zeros (for first Y index,
% where there is no disc)
discImgsAll = false(numVertLEDs,numHorizLEDs360);

% call makeDiscImgSeries() for each loom direction
for i = 1:numLoomDir
    [discImgs, discDiams] = makeDiscImgSeries(numHorizLEDs360, ...
        numVertLEDs, degPerPxFull, loomDirDeg(i), loomEleDeg, ...
        minDiscDiamDeg, maxDiscDiamDeg);
    
    % concatenate to growing array    
    discImgsAll = cat(3, discImgsAll, discImgs);
end

% length of each disc image series
oneDiscImgLen = length(discDiams);


% Y size is 3rd dimension of discImgsAll
pattern.y_num = oneDiscImgLen * numLoomDir + 1;

% initialize array, gray
Pats = ones(numVertLEDs, numHorizLEDs360, pattern.x_num, ...
    pattern.y_num) * meanLum;

% bar pattern for 1 X,Y
% initalize full screen at mean luminance
barPattern = ones(numVertLEDs, numHorizLEDs360) * meanLum;
% add bar at smallest v coordinates
barStartPos = 1;
barPattern(:, barStartPos:(barWidth + barStartPos - 1)) = lightLum;

% loop over all Y
for i = 1:pattern.y_num
    % loop over all x
    for j = 1:numHorizLEDs360
        % generate bar pattern for this X
        thisPattern = ShiftMatrix(barPattern, j-1, horizShiftInv,'y');
        
        % add loom to this bar
        thisPattern(discImgsAll(:,:,i)) = darkLum;
        
        % add to Pats
        Pats(:,:,j,i) = thisPattern;
    end
    
end

% put data in structure
pattern.Pats = Pats; 	

% convert into appropriate format for panels
pattern.BitMapIndex = process_panel_map(pattern);
pattern.data = Make_pattern_vector(pattern);

% save pattern
save([vsPatternsDir() filesep patternName '.mat'], 'pattern');

%% Pattern 16: 4 LED wide grating with front 8 LEDs gray
% X encodes rotation, Y encodes front-to-back motion of grating
% regular direction, 360 deg arena
%
% Meant to be used in closed loop for X and Y, or closed loop for X and
%  open loop for Y, to provide optic flow
%
% Last Updated: 3/4/21

% Pattern Name
patternName = 'Pattern_016_4pxLightDarkSquareGrating_XRot_YFtB_360Reg';

% Parameters
stripeWidth = 4; % number of LED dots wide each light/dark stripe is
grayLEDs = 33:40; % indices of front 8 LEDs to keep gray, 1 indexing 
% horiz indicies of left and right fields, 1 indexing
indLeftField = [1:36, 85:96];
indRightField = [37:84];

numBallRevPerArenadiam = 2;

% Pattern basic info
pattern.x_num = numHorizLEDs360;

% compute number of grating periods to include in Y
% depends on mapping ball revolutions to arena diameter, needs to be full
%  number of periods to loop w/o gaps
% NOTE: this code isn't checking for integer values, check this yourself
numPeriods = (numHorizLEDs360/2) / (stripeWidth * 2);

% number of Y elements is number of periods for 1 ball revolution times the
%  number of positions required for a full period
pattern.y_num = (numPeriods / numBallRevPerArenadiam) * (stripeWidth * 2);


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

% loop over all X
for i = 1:numHorizLEDs360
    % for each X, shift pattern 1 LED to left
    thisXPattern = ShiftMatrix(gratingPattern, i-1, ...
        horizShiftReg,'y');
    
    % loop over all Y, adding in front-to-back shifts
    for j = 1:pattern.y_num
        % shift each half of grating, opposite directions
        leftHalf = circshift(thisXPattern(:,indLeftField), -1* (j-1), 2);
        rightHalf = circshift(thisXPattern(:,indRightField), j-1, 2);
        
        % merge into full pattern
        thisXYPattern = thisXPattern; % initialize
        thisXYPattern(:,indLeftField) = leftHalf;
        thisXYPattern(:,indRightField) = rightHalf;
        
        % gray out front panels
        thisXYPattern(:,grayLEDs) = meanLum;

        % add to Pats
        Pats(:,:,i,j) = thisXYPattern;
    end
end

% put data in structure
pattern.Pats = Pats; 	

% convert into appropriate format for panels
pattern.BitMapIndex = process_panel_map(pattern);
pattern.data = Make_pattern_vector(pattern);

% save pattern
save([vsPatternsDir() filesep patternName '.mat'], 'pattern');

%% Pattern 17: 4 LED wide grating with front 8 LEDs gray
% X encodes rotation, Y encodes front-to-back motion of grating
% inverted direction (for X, rotation), 360 deg arena
%
% Meant to be used in closed loop for X and Y, or closed loop for X and
%  open loop for Y, to provide optic flow
%
% Last Updated: 3/4/21

% Pattern Name
patternName = 'Pattern_017_4pxLightDarkSquareGrating_XRot_YFtB_360Inv';

% Parameters
stripeWidth = 4; % number of LED dots wide each light/dark stripe is
grayLEDs = 33:40; % indices of front 8 LEDs to keep gray, 1 indexing 
% horiz indicies of left and right fields, 1 indexing
indLeftField = [1:36, 85:96];
indRightField = [37:84];

numBallRevPerArenadiam = 2;

% Pattern basic info
pattern.x_num = numHorizLEDs360;

% compute number of grating periods to include in Y
% depends on mapping ball revolutions to arena diameter, needs to be full
%  number of periods to loop w/o gaps
% NOTE: this code isn't checking for integer values, check this yourself
numPeriods = (numHorizLEDs360/2) / (stripeWidth * 2);

% number of Y elements is number of periods for 1 ball revolution times the
%  number of positions required for a full period
pattern.y_num = (numPeriods / numBallRevPerArenadiam) * (stripeWidth * 2);


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

% loop over all X
for i = 1:numHorizLEDs360
    % for each X, shift pattern 1 LED to left
    thisXPattern = ShiftMatrix(gratingPattern, i-1, ...
        horizShiftInv,'y');
    
    % loop over all Y, adding in front-to-back shifts
    for j = 1:pattern.y_num
        % shift each half of grating, opposite directions
        leftHalf = circshift(thisXPattern(:,indLeftField), -1* (j-1), 2);
        rightHalf = circshift(thisXPattern(:,indRightField), j-1, 2);
        
        % merge into full pattern
        thisXYPattern = thisXPattern; % initialize
        thisXYPattern(:,indLeftField) = leftHalf;
        thisXYPattern(:,indRightField) = rightHalf;
        
        % gray out front panels
        thisXYPattern(:,grayLEDs) = meanLum;

        % add to Pats
        Pats(:,:,i,j) = thisXYPattern;
    end
end

% put data in structure
pattern.Pats = Pats; 	

% convert into appropriate format for panels
pattern.BitMapIndex = process_panel_map(pattern);
pattern.data = Make_pattern_vector(pattern);

% save pattern
save([vsPatternsDir() filesep patternName '.mat'], 'pattern');

%% Pattern 18: 2 LED wide light bar in X, 4 LED wide grating with front 8 
%   LEDs gray in Y
% X encodes rotation, Y encodes front-to-back motion of grating
% regular direction, 360 deg arena
%
% Meant to be used in closed loop for X and open loop for Y, to provide 
%  front-to-back/back-to-front optic flow
%
% Last Updated: 3/7/21

% Pattern Name
patternName = 'Pattern_018_2pxLightBarX_4pxLightDarkSquareGratingY_XRot_YFtB_360Reg';

% Parameters
barWidth = 2; % number of LED dots wide for bar

stripeWidth = 4; % number of LED dots wide each light/dark stripe is
grayLEDs = 33:40; % indices of front 8 LEDs to keep gray, 1 indexing 
% horiz indicies of left and right fields, 1 indexing
indLeftField = [1:36, 85:96];
indRightField = [37:84];

numBallRevPerArenadiam = 2;

% indicies for Y options
yBarDisp = 1;

% Pattern basic info
pattern.x_num = numHorizLEDs360;

% compute number of grating periods to include in Y
% depends on mapping ball revolutions to arena diameter, needs to be full
%  number of periods to loop w/o gaps
% NOTE: this code isn't checking for integer values, check this yourself
numPeriods = (numHorizLEDs360/2) / (stripeWidth * 2);

% number of Y elements is number of periods for 1 ball revolution times the
%  number of positions required for a full period plus 1 for when only bar
%  is displayed
pattern.y_num = (numPeriods / numBallRevPerArenadiam) * ...
    (stripeWidth * 2) + 1;


% Build Pattern

% initialize array
Pats = zeros(numVertLEDs, numHorizLEDs360, pattern.x_num, pattern.y_num);

% for Y index = 1, just bar
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

% for bar + grating

% make grating pattern logical - false for dark, true for light
onePeriod = false(numVertLEDs, 2*stripeWidth);
onePeriod(:,(stripeWidth+1):(stripeWidth*2)) = true;

% repeat single period to fill whole arena
numReps = numHorizLEDs360 / (2*stripeWidth);
gratingPattern = repmat(onePeriod, 1, numReps);

% bar pattern for 1 X,Y
% logical true for bar, false for background
barPattern = false(numVertLEDs, numHorizLEDs360);
% add bar at smallest v coordinates
barStartPos = 1;
barPattern(:, barStartPos:(barWidth + barStartPos - 1)) = true;

% loop over all X
for i = 1:numHorizLEDs360
    % for each X, shift pattern 1 LED to left
    thisXPattern = ShiftMatrix(barPattern, i-1, horizShiftReg,'y');
    
    % loop over all Y, adding in front-to-back shifts
    for j = 2:pattern.y_num
        % shift each half of grating, opposite directions
        leftHalf = circshift(gratingPattern(:,indLeftField), -1* (j-2), 2);
        rightHalf = circshift(gratingPattern(:,indRightField), j-2, 2);
        
        % merge into full pattern
        thisGratingPattern = thisXPattern; % initialize
        thisGratingPattern(:,indLeftField) = leftHalf;
        thisGratingPattern(:,indRightField) = rightHalf;
        thisXYPattern = thisGratingPattern | thisXPattern;
        
        % convert from logical to luminance values
        % initialize at dark lum
        thisXYPatternLum = ones(size(thisXYPattern)) * darkLum;
        % convert logical true to light lum;
        thisXYPatternLum(thisXYPattern) = lightLum;
        
        % gray out front panels
        thisXYPatternLum(:,grayLEDs) = meanLum;

        % add to Pats
        Pats(:,:,i,j) = thisXYPatternLum;
    end
end

% put data in structure
pattern.Pats = Pats; 	

% convert into appropriate format for panels
pattern.BitMapIndex = process_panel_map(pattern);
pattern.data = Make_pattern_vector(pattern);

% save pattern
save([vsPatternsDir() filesep patternName '.mat'], 'pattern');

%% Pattern 19: 2 LED wide light bar in X, 4 LED wide grating with front 8 
%   LEDs gray in Y
% X encodes rotation, Y encodes front-to-back motion of grating
% inverted direction, 360 deg arena
%
% Meant to be used in closed loop for X and open loop for Y, to provide 
%  front-to-back/back-to-front optic flow
%
% Last Updated: 3/7/21

% Pattern Name
patternName = 'Pattern_019_2pxLightBarX_4pxLightDarkSquareGratingY_XRot_YFtB_360Inv';

% Parameters
barWidth = 2; % number of LED dots wide for bar

stripeWidth = 4; % number of LED dots wide each light/dark stripe is
grayLEDs = 33:40; % indices of front 8 LEDs to keep gray, 1 indexing 
% horiz indicies of left and right fields, 1 indexing
indLeftField = [1:36, 85:96];
indRightField = [37:84];

numBallRevPerArenadiam = 2;

% indicies for Y options
yBarDisp = 1;

% Pattern basic info
pattern.x_num = numHorizLEDs360;

% compute number of grating periods to include in Y
% depends on mapping ball revolutions to arena diameter, needs to be full
%  number of periods to loop w/o gaps
% NOTE: this code isn't checking for integer values, check this yourself
numPeriods = (numHorizLEDs360/2) / (stripeWidth * 2);

% number of Y elements is number of periods for 1 ball revolution times the
%  number of positions required for a full period plus 1 for when only bar
%  is displayed
pattern.y_num = (numPeriods / numBallRevPerArenadiam) * ...
    (stripeWidth * 2) + 1;


% Build Pattern

% initialize array
Pats = zeros(numVertLEDs, numHorizLEDs360, pattern.x_num, pattern.y_num);

% for Y index = 1, just bar
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

% for bar + grating

% make grating pattern logical - false for dark, true for light
onePeriod = false(numVertLEDs, 2*stripeWidth);
onePeriod(:,(stripeWidth+1):(stripeWidth*2)) = true;

% repeat single period to fill whole arena
numReps = numHorizLEDs360 / (2*stripeWidth);
gratingPattern = repmat(onePeriod, 1, numReps);

% bar pattern for 1 X,Y
% logical true for bar, false for background
barPattern = false(numVertLEDs, numHorizLEDs360);
% add bar at smallest v coordinates
barStartPos = 1;
barPattern(:, barStartPos:(barWidth + barStartPos - 1)) = true;

% loop over all X
for i = 1:numHorizLEDs360
    % for each X, shift pattern 1 LED to left
    thisXPattern = ShiftMatrix(barPattern, i-1, horizShiftInv,'y');
    
    % loop over all Y, adding in front-to-back shifts
    for j = 2:pattern.y_num
        % shift each half of grating, opposite directions
        leftHalf = circshift(gratingPattern(:,indLeftField), -1* (j-2), 2);
        rightHalf = circshift(gratingPattern(:,indRightField), j-2, 2);
        
        % merge into full pattern
        thisGratingPattern = thisXPattern; % initialize
        thisGratingPattern(:,indLeftField) = leftHalf;
        thisGratingPattern(:,indRightField) = rightHalf;
        thisXYPattern = thisGratingPattern | thisXPattern;
        
        % convert from logical to luminance values
        % initialize at dark lum
        thisXYPatternLum = ones(size(thisXYPattern)) * darkLum;
        % convert logical true to light lum;
        thisXYPatternLum(thisXYPattern) = lightLum;
        
        % gray out front panels
        thisXYPatternLum(:,grayLEDs) = meanLum;

        % add to Pats
        Pats(:,:,i,j) = thisXYPatternLum;
    end
end

% put data in structure
pattern.Pats = Pats; 	

% convert into appropriate format for panels
pattern.BitMapIndex = process_panel_map(pattern);
pattern.data = Make_pattern_vector(pattern);

% save pattern
save([vsPatternsDir() filesep patternName '.mat'], 'pattern');

%% Pattern 020: 6 LED wide, light/dark square-wave grating, 360deg arena, 
%   regular direction
%
% X encodes position of grating
% Y encodes: 1 - grating displayed, 2 - all panels mean lum, 3 - all panels
%  dark
%
% Last Updated: 1/7/24

% Pattern Name
patternName = 'Pattern_020_6pxLightDarkSquareGrating360Reg';

stripeWidth = 6; % number of LED dots wide each light/dark stripe is

% indicies for Y options
yGratingDisp1 = 1;
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
    Pats(:,:,i,yGratingDisp1) = ShiftMatrix(gratingPattern, i-1, ...
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

%% Pattern 021: 8 LED wide, light/dark square-wave grating, 360deg arena, 
%   regular direction
%
% X encodes position of grating
% Y encodes: 1 - grating displayed, 2 - all panels mean lum, 3 - all panels
%  dark
%
% Last Updated: 1/7/24

% Pattern Name
patternName = 'Pattern_021_8pxLightDarkSquareGrating360Reg';

stripeWidth = 8; % number of LED dots wide each light/dark stripe is

% indicies for Y options
yGratingDisp1 = 1;
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
    Pats(:,:,i,yGratingDisp1) = ShiftMatrix(gratingPattern, i-1, ...
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

%% Pattern 022: 6 LED wide, light/dark square-wave grating, 360deg arena, 
%   regular direction, 2 Y values for grating
%
% X encodes position of grating
% Y encodes: 1 - grating displayed, 2 - grating displayed (same as 1), 
%  2 - all panels mean lum, 3 - all panels dark
%
% Last Updated: 1/26/24

% Pattern Name
patternName = 'Pattern_022_6pxLightDarkSquareGrating360RegSepY';

stripeWidth = 6; % number of LED dots wide each light/dark stripe is

% indicies for Y options
yGratingDisp1 = 1;
yGratingDisp2 = 2;
yMeanLum = 3;
yAllOff = 4;

% Pattern basic info
pattern.x_num = numHorizLEDs360; 
pattern.y_num = 4; % for 4 possible Y values

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
    % grating Y = 1
    Pats(:,:,i,yGratingDisp1) = ShiftMatrix(gratingPattern, i-1, ...
        horizShiftReg,'y');
    % grating Y = 2
    Pats(:,:,i,yGratingDisp2) = ShiftMatrix(gratingPattern, i-1, ...
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


%% Pattern  - 2 LED wide light vertical bar, starfield on gray,
% regular direction
% Bar position encoded in X, starfield moves front to back in Y, frontal
%  region (1 panel, 30 deg) gray with no stars

% Pattern Name
patternName = 'Pattern_0_2pxLightVertBarStarfieldOnGray360Reg';

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




