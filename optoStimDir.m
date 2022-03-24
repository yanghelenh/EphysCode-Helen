% optoStimDir.m
%
% Quick function that specifies folder where opto stim functions live.
% Optogenetic stimulation through control of shutter in front of Hg lamp.
% Ideally, would have been part of ephysSettings.m, but too awkward to
%  change now
%
% INPUTS: none
%
% OUTPUTS:
%   iPath - full path to folder containing optostim protocols
%
% CREATED: 2/20/22 - HHY
%
% UPDATED:
%   2/20/22 - HHY
%
function oPath = optoStimDir()
    % Determine which computer this code is running on
    comptype = computer; % get the string describing the computer type
    PC_STRING = 'PCWIN64';  % string for PC on 2P rig
    MAC_STRING = 'MACI64'; %string for macbook

    %  Set the paths according to whether we are on the MAC or PC
    if strcmp(comptype, PC_STRING) % WINDOWS path
        oPath = ...
            'C:\Users\WilsonLab\Documents\HelenExperimentalCode\EphysCode-Helen\Experiment Types\OptoStim';
        addpath(oPath);
    elseif strcmp(comptype, MAC_STRING) % MACBOOK PRO path
        oPath = '/Users/hyang/Documents/EphysCode-Helen/Experiment Types/OptoStim';     
        addpath(oPath);
    else 
        % if neither computer types throw error
        error('ERROR: optostim folder not found that matches this computer type');
    end
end