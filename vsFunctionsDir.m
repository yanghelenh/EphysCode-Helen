% vsFunctionsDir.m
%
% Quick function that specifies folder where visual stimuli functions live,
%  for G3 visual arena.
% Ideally, would have been part of ephysSettings.m, but too awkward to
%  change now
%
% INPUTS: none
%
% OUTPUTS:
%   vspPath - full path to folder containing visual stimuli functions
%
% CREATED: 2/8/21 - HHY
%
% UPDATED:
%   2/8/21 - HHY
%
function vspPath = vsFunctionsDir()
    % Determine which computer this code is running on
    comptype = computer; % get the string describing the computer type
    PC_STRING = 'PCWIN64';  % string for PC on 2P rig
    MAC_STRING = 'MACI64'; %string for macbook

    %  Set the paths according to whether we are on the MAC or PC
    if strcmp(comptype, PC_STRING) % WINDOWS path
        vspPath = ...
            'C:\Users\WilsonLab\Documents\HelenExperimentalCode\EphysCode-Helen\Visual Stimuli\Functions';
        addpath(vspPath);
    elseif strcmp(comptype, MAC_STRING) % MACBOOK PRO path
        vspPath = '/Users/hyang/Documents/EphysCode-Helen/Visual Stimuli/Functions';     
        addpath(vspPath);
    else 
        % if neither computer types throw error
        error('ERROR: current injection folder not found that matches this computer type');
    end
end