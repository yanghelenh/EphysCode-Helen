% preprocessLegVidFiles.m
%
% Function to preprocess raw leg video .tiff files. Call after running
%  Powershell script(s) to rename all leg video files.
% Call on date folder.
% Does command line call to ffmpeg to generate .mp4 video file for each
%  trial with leg video data.
% Generates powershell script and filelist file for zipping .tiff files, 1
%  zip file for each trial. Generates .bat file for running all powershell
%  scripts for all trials in date folder
%
% INPUTS:
%   none, but prompts user to select date folder through gui
%
% OUTPUTS:
%   none, but generates a bunch of files as side effect (see above)
%
% CREATED: 7/2/20 - HHY
%
% UPDATED:
%   7/2/20 - HHY
%

function preprocessLegVidFiles()

    % load ephys settings
    [dataDir, ~, ~] = ephysSettings();

    % prompt user for date directory
    disp('Select date directory');
    dateDirPath = uigetdir(dataDir, 'Select date directory');
    
    % get fly folders
    dateDirContents = dir(dateDirPath);
    flyDirs = dateDirContents(contains({dateDirContents.name},'fly'));
    
    
end
