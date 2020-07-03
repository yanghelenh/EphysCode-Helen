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
    
    % contents of date directory
    dateDirContents = dir(dateDirPath);
    
    % get fly folders
    flyDirs = dateDirContents(contains({dateDirContents.name},'fly'));
    
    % create scripts folder if it doesn't exist
    if (sum(strcmpi({dateDirContents.name},'scripts')))
        mkdir(dateDirPath, 'scripts');
    end
    % full path to scripts folder
    scriptsPath = [dateDirPath filesep 'scripts'];
    
    % loop over all fly directories
    for i = 1:length(flyDirs)
        flyDirPath = [flyDirs(i).path filesep flyDirs(i).name];
        
        % get cell folders
        flyDirContents = dir(flyDirPath);
        cellDirs = flyDirContents(contains({flyDirContents.name}, 'cell'));
        
        % loop over all cell folders
        for j = 1:length(cellDirs)
            cellDirPath = [cellDirs(j).path filesep cellDirs(j).name];
            
            % go to cell folder
            cd(cellDirPath);
            
            % get trial files
            cellDirContents = dir(cellDirPath);
            trialFiles = cellDirContents(contains({cellDirContents.name}, ...
                'trial'));
            
            % loop over all trials
            for k = 1:length(trialFiles)
                trialPath = [trialFiles(k).path filesep trialFiles(k).name];
                % load inputParams from trial file (has impt metadata)
                load(trialPath, 'inputParams');
                      
                % only execute leg video processing on trials with leg vid
                if (contains(inputParams.exptCond, 'legVid'))
                    % raw leg vid folder
                    rawLegVidPath = [cellDirPath filesep 'rawLegVid'];
                    
                    % current number of frames grabbed same as start index
                    %  for new video with zero indexing
                    startFrame = inputParams.startLegVidNum;
                    % total number of frames grabbed for this trial
                    totFrames = inputParams.endLegVidNum - ...
                        inputParams.startLegVidNum;
                    
                    
                    
                    
                end
                
            end
            
            
        end
    end
end
