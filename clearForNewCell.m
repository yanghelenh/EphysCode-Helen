% clearForNewCell.m
%
% Function to clear persistent and global variables used in runEphysExpt()
%  so that a new cell starts fresh
%
% CREATED: 3/11/20 - HHY
%
% UPDATED: 
%   3/11/20 - HHY
%

function clearForNewCell()

    clear runEphysExpt % has persistent variable cellDirPath
    clear collectData % has persistent variable whichInScan
end