% makeDiscImgSeries.m
%
% Function that generates series of disc images centered at
%  user-specified center. Returns images and their corresponding sizes, in
%  degrees
% For generating discs for looming stimuli on visual panels. User
%  specifies dimensions of panels, in LED pixels, and the conversion factor
%  to degrees. Use 1 indexing into pixel locations
% All discs output are unique. Specified disc diameter is minimum diameter
%  in degrees to yield that pattern
% Resolution at which discs are computed is 1/10th of degPerPx
%
% INPUTS:
%   numPxHoriz - number of LED pixels in horizontal dimension
%   numPxVert - number of LED pixels in vertical dimension
%   degPerPx - degrees of visual space spanned by single LED pixel
%   hCenterDeg - horizontal coordinate of disc center, in degrees
%   vCenterDeg - vertical coordinate of disc center, in degrees
%   minDiscDiamDeg - minimum disc diameter, in degrees
%   maxDiscDiamDeg - maximum disc diameter, in degrees
%
% OUTPUTS:
%   discImgs - 3D array of disc images [v,h,numDiscs]; each [v,h] is
%     single disc; circles go from min to max size; 1 for part of disc, 0
%     for not part of disc, as logical array
%  	discDiams - vector of length numDiscs that specifies diameter of each
%  	  disc (represents minimum diameter, to resolution 1/10th of degPerPx)
%
% CREATED: 2/16/21 - HHY
%
% UPDATED:
%   2/16/21 - HHY
%   2/18/21 - HHY - output discImgs to logical
%

function [discImgs, discDiams] = makeDiscImgSeries(numPxHoriz, ...
    numPxVert, degPerPx, hCenterDeg, vCenterDeg, minDiscDiamDeg, ...
    maxDiscDiamDeg)

    % initial spacing in deg of disc diameters
    upsampFactor = 10; % calculate discs at 10X resolution of LEDs
    changeDiamDeg = degPerPx / upsampFactor; % difference disc to disc
    % all diameters
    discDiamsAll = minDiscDiamDeg:changeDiamDeg:maxDiscDiamDeg;
    numDiscsAll = length(discDiamsAll);
    
    % preallocate disc imgs(will become smaller as only unique imgs kept)
    discImgs = zeros(numPxVert, numPxHoriz, numDiscsAll);
    % array to indicate whether that disc is unique - initialize at 0 and
    %  flip to 1 when not unique
    nonUniqueDisc = false(numDiscsAll,1);
    
    % loop through all disc diameters
    for i = 1:numDiscsAll
        % for each (v,h) coordinate, check if it's within current discDiam
        %  of center
        for v = 1:numPxVert
            % convert pixel coordinate v into degrees
            vDeg = degPerPx * v - degPerPx/2;
            for h = 1:numPxHoriz
                % convert pixel coordinate h into degrees
                hDeg = degPerPx * h - degPerPx/2;
                
                % equation of circle centered at (a,b) with radius r
                % (x-a)^2 + (y-b)^2 = r^2
                % squared distance of this point from center point
                sqDistCenter = (vDeg - vCenterDeg)^2 + ...
                    (hDeg - hCenterDeg)^2;
                % squared radius
                sqRadius = (discDiamsAll(i)/2)^2;
                
                % check if point is within circle; if so, flip to 1 from 0
                if (sqDistCenter <= sqRadius)
                    discImgs(v,h,i) = 1;
                end
            end
        end
        
        % check if this disc image is the same as the previous image
        if (i > 1) % only after 1st image
            prevImg = discImgs(:,:,i-1);
            % if this image is the same as the previous image, note that
            %  this disc image isn't unique
            if (isequal(prevImg, discImgs(:,:,i)))
                nonUniqueDisc(i) = true;
            end
        end
    end
    
    % remove non-unique disc images
    discImgs(:,:,nonUniqueDisc) = [];
    discImgs = logical(discImgs);
    
    % get corresponding diameters
    discDiams = discDiamsAll;
    discDiams(nonUniqueDisc) = [];
end