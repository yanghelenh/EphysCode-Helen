% appendDateLegVidFiles.m
%
% Function that goes through all the video files in a date folder and 
%  appends the date in front of the video file names
%
% INPUTS:
%   none, but prompts user to select date folder through gui
%
% OUTPUTS:
%   none, but renames the video files
%
% CREATED: 3/24/22 - HHY
%
% UPDATED:
%   3/24/22 - HHY
%
function appendDateLegVidFiles()

    % load ephys settings
    [dataDir, ~, ~] = ephysSettings();

    % prompt user for date directory
    disp('Select date directory');
    dateDirPath = uigetdir(dataDir, 'Select date directory');
    [~, dateDirName, ~] = fileparts(dateDirPath); 
    
    % contents of date directory
    dateDirContents = dir(dateDirPath);
    
    % get fly folders
    flyDirs = dateDirContents(contains({dateDirContents.name},'fly'));
    
    for i = 1:length(flyDirs)
        flyDirPath = [flyDirs(i).folder filesep flyDirs(i).name];

        % get cell folders
        flyDirContents = dir(flyDirPath);
        cellDirs = flyDirContents(contains({flyDirContents.name}, 'cell'));

        % loop over all cell folders
        for j = 1:length(cellDirs)
            cellDirPath = [cellDirs(j).folder filesep cellDirs(j).name];

            % go to cell folder
            cd(cellDirPath);

            % get leg video files in cell folder
            dirLegVidSearch = [cellDirPath filesep '*_legVid.mp4'];
            legVidFiles = dir(dirLegVidSearch);
            
            % loop over all leg video files
            for k = 1:length(legVidFiles)
                thisFileName = legVidFiles(k).name;
                
                % new file name of leg video file with date appended
                newFileName = [dateDirName '_' thisFileName];
                
                % rename file
                movefile(thisFileName, newFileName);
            end
        end
    end
    
end