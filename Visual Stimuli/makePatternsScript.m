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
