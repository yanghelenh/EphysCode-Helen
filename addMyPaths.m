% addMyPaths.m
% 
% function to add relevant paths for running ephys experiments, including 
%  subfolders
%
% Users: change the following paths to match those on your local computer

function addMyPaths()    
    % Determine which computer this code is running on
    comptype = computer; % get the string describing the computer type
    PC_STRING = 'PCWIN64';  % string for PC on 2P rig
    MAC_STRING = 'MACI64'; %string for macbook

    %  Set the paths according to whether we are on the MAC or PC
    if strcmp(comptype, PC_STRING) % WINDOWS path
        % visual panel code
%         addpath(genpath(...
%             'C:\Users\WilsonLab\Documents\HelenExperimentalCode\panels-matlab\'));
        addpath(genpath(...
            'C:\Users\WilsonLab\Documents\HelenExperimentalCode\panels\'));
    elseif strcmp(comptype, MAC_STRING) % MACBOOK PRO path
        % visual panel code
%         addpath(genpath('/Users/hyang/Documents/panels-matlab/'));
        addpath(genpath('/Users/hyang/Documents/panels/'));
    else 
        % if neither computer types throw error
        error('ERROR: computer type not found');
    end

end