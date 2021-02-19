% findDiscSizesLoom.m
%
% Function that takes in r/v (ratio of stimulus radius to approach speed),
%  minimum disc size, maximum disc size, and size of time steps to
%  return the disc's size over time.
% For generating position function to apply to disc patterns to generate
%  looming stimulus on G3 visual panels.
% 
% INPUTS:
%   rvRatio - r/v, ratio of disc radius to approach speed; describes speed
%       of loom
%   minDiscSize - minimum disc size, in degrees (i.e. starting size)
%   maxDiscSize - maximum disc size, in degrees (i.e. ending size)
%   ifi - interframe interval; size of time steps, in seconds
%
% OUTPUTS:
%   discSizeTime - vector of disc sizes (diameter, in degrees) over time
%   t - times before collision, in seconds, corresponding to each element
%       of discSizeTime
%
% CREATED: 2/17/21 - HHY
%   
% UPDATED:
%   2/17/21 - HHY
%
function [discSizeTime, t] = findDiscSizesLoom(rvRatio, minDiscSize, ...
    maxDiscSize, ifi)

    % time to collision of disc at maximum size (is minimum time)
    minCollTime = rvRatio / tand(maxDiscSize/2);
    % time to collision of disc at minimum size (is max time)
    maxCollTime = rvRatio / tand(minDiscSize/2);
    
    % time vector, as times before collision, in sec; sampled at frame rate
    t = -minCollTime:-ifi:-maxCollTime;
    
    % disc sizes
    discSizeTime = 2*atan2d(rvRatio, abs(t));

end