% preprocessFictracVidFiles.m
%
% Function to preprocess raw FicTrac video .tiff files.
% Call on date folder.
% Generates Powershell script to rename individual .tiff files. Does 
%  command line call to ffmpeg to generate .mp4 video file for each
%  trial with leg video data.
% Generates powershell script and filelist file for zipping .tiff files, 1
%  zip file for each trial. Generates .bat file for running all powershell
%  scripts for all trials in date folder
% Modification of preprocessLegVidFiles.m
%
% INPUTS:
%   none, but prompts user to select date folder through gui
%
% OUTPUTS:
%   none, but generates a bunch of files as side effect (see above)
%
% CREATED: 12/16/20 - HHY
%
% UPDATED:
%   12/16/20 - HHY
%   1/7/21 - HHY
%

function preprocessFictracVidFiles()

    % prompt user for date directory
    disp('Select date directory');
    dateDirPath = uigetdir('Select date directory');
    [~, dateDirName, ~] = fileparts(dateDirPath); 
    
    % contents of date directory
    dateDirContents = dir(dateDirPath);
    
    % get fly folders
    flyDirs = dateDirContents(contains({dateDirContents.name},'fly'));
    
    % create scripts folder if it doesn't exist
    if ~(sum(strcmpi({dateDirContents.name},'scripts')))
        mkdir(dateDirPath, 'scripts');
    end
    % full path to scripts folder
    scriptsPath = [dateDirPath filesep 'scripts'];
    
%     % initialize list of zip script paths (for writing batch file later)
%     allZipScriptPaths = {};
    
    % initialize list of all rawFictracVid folder paths (for writing file
    %  to delete all later)
    allRawFictracVidPaths = {};
    
    % loop over all fly directories - generate Powershell scripts and
    %  filelist files for zipping, call and run ffmpeg to generate videos
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
            
            % get contents of cell folder
            cellDirContents = dir(cellDirPath);
                    
            % if rawFictracVid folder exists (i.e. there are video files)
            if (sum(contains({cellDirContents.name}, 'rawFictracVid')))
                % raw FicTrac vid folder
                rawFictracVidPath = [cellDirPath filesep 'rawFictracVid'];
                
                % save rawFictracVid folder path to list (for later script)
                allRawFictracVidPaths = {allRawFictracVidPaths{:} ...
                    rawFictracVidPath};
                
                % perform renaming
                renameStatus = renameFictracVid(rawFictracVidPath, ...
                    scriptsPath, flyDirs(i).name, cellDirs(j).name);
                
                % if renaming failed, end function here
                if renameStatus
                    fprintf('Renaming FicTrac vid files failed on %s %s\n', ...
                        flyDirs(i).name, cellDirs(j).name);
                    return;
                end
            end
            
            % get trial files (trial#.mat files and cellAttachedTrial.mat)
            trialFiles = cellDirContents(contains({cellDirContents.name}, ...
                'trial', 'IgnoreCase', true));
            
            % loop over all trials
            for k = 1:length(trialFiles)
                trialPath = [trialFiles(k).folder filesep trialFiles(k).name];
                % load inputParams from trial file (has impt metadata)
                load(trialPath, 'inputParams');
                % get trial name without .mat apended
                trialName = trialFiles(k).name;
                trialName = trialName(1:(end-4)); % .mat is set 4 characters
                     
                % generate .mp4 and .zip files for trial
                zipFfmpegFictracVid(inputParams, scriptsPath, ...
                    cellDirPath, rawFictracVidPath, flyDirs(i).name, ...
                    cellDirs(j).name,trialName);
                        
            end
        end
    end
    
%     % create batch file to run all powershell scripts
%     batchZipFName = [dateDirName '_batchZip.bat'];
%     batchZipPath = [scriptsPath filesep batchZipFName];
%     batchZipFID = fopen(batchZipPath, 'w');
%     
%     % write constant lines
%     fprintf(batchZipFID, '@ECHO OFF\n'); % so batch file contents not printed
%     
%     % write one call to Powershell for each zip script
%     for i = 1:length(allZipScriptPaths)
%         fprintf(batchZipFID, ...
%             'Powershell -NoProfile -ExecutionPolicy Bypass -Command "%s" \n',...
%             allZipScriptPaths{i});
%     end
%     
%     % close batch file
%     fclose(batchZipFID);
    
    % create powershell script that deletes all rawFictracVid folders 
    deleteRFtVscriptFName = [dateDirName '_deleteRawFictracVid.ps1'];
    deleteRFtVscriptPath  = [scriptsPath filesep deleteRFtVscriptFName];
    deleteRFtVscriptFID = fopen(deleteRFtVscriptPath, 'w');
    
    % write line to delete each rawLegVid folder
    for i = 1:length(allRawFictracVidPaths)
        fprintf(deleteRFtVscriptFID, 'Remove-Item "%s" -Recurse\n', ...
            allRawFictracVidPaths{i});
    end
    
    % close file
    fclose(deleteRFtVscriptFID);
    
    % create batch file that wraps this powershell script
    batchDeleteRFtVfName = [dateDirName '_deleteRawFictracVid.bat'];
    batchDeleteRFtVpath = [scriptsPath filesep batchDeleteRFtVfName];
    batchDeleteRFtVfid = fopen(batchDeleteRFtVpath, 'w');
    
    % write constant lines
    fprintf(batchDeleteRFtVfid, '@ECHO OFF\n'); % so batch file contents not printed
    
    % write call to Powershell
    fprintf(batchDeleteRFtVfid, ...
        'Powershell -NoProfile -ExecutionPolicy Bypass -Command "%s" \n',...
        deleteRFtVscriptPath);
    
    % close file
    fclose(batchDeleteRFtVfid);
    
end
