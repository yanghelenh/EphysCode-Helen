% vInjDir.m
%
% Quick function that specifies folder where voltage injection protocol
%  functions live.
% Ideally, would have been part of ephysSettings.m, but too awkward to
%  change now
%
% INPUTS: none
%
% OUTPUTS:
%   vPath - full path to folder containing current injection protocols
%
% CREATED: 2/11/21 - HHY
%
% UPDATED:
%   2/11/21 - HHY
%
function vPath = vInjDir()
    % Determine which computer this code is running on
    comptype = computer; % get the string describing the computer type
    PC_STRING = 'PCWIN64';  % string for PC on 2P rig
    MAC_STRING = 'MACI64'; %string for macbook

    %  Set the paths according to whether we are on the MAC or PC
    if strcmp(comptype, PC_STRING) % WINDOWS path
        vPath = ...
            'C:\Users\WilsonLab\Documents\HelenExperimentalCode\EphysCode-Helen\Experiment Types\Voltage Protocols';
        addpath(vPath);
    elseif strcmp(comptype, MAC_STRING) % MACBOOK PRO path
        vPath = '/Users/hyang/Documents/EphysCode-Helen/Experiment Types/Voltage Protocols';     
        addpath(vPath);
    else 
        % if neither computer types throw error
        error('ERROR: voltage injection folder not found that matches this computer type');
    end
end