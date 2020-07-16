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
%   7/3/20 - HHY
%   7/6/20 - HHY - everything but deleting indiv images now happens with
%       call to this function
%   7/10/20 - HHY - print more status updates to screen
%

function preprocessLegVidFiles()

    % some constants
    PATH_7ZIP = 'C:\Program Files\7-Zip\7z.exe';

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
    
    % create scripts folder if it doesn't exist
    if ~(sum(strcmpi({dateDirContents.name},'scripts')))
        mkdir(dateDirPath, 'scripts');
    end
    % full path to scripts folder
    scriptsPath = [dateDirPath filesep 'scripts'];
    
%     % initialize list of zip script paths (for writing batch file later)
%     allZipScriptPaths = {};
    
    % initialize list of all rawLegVid folder paths (for writing file to
    %  delete all later)
    allRawLegVidPaths = {};
    
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
            
            % if rawLegVid folder exists (i.e. there are video files)
            if (sum(contains({cellDirContents.name}, 'rawLegVid')))
                % raw leg vid folder
                rawLegVidPath = [cellDirPath filesep 'rawLegVid'];
                
                % save rawLegVid folder path to list (for later script)
                allRawLegVidPaths = {allRawLegVidPaths{:} rawLegVidPath};
                
                % perform renaming
                renameStatus = renameLegVid(rawLegVidPath, scriptsPath, ...
                    flyDirs(i).name, cellDirs(j).name);
                
                % if renaming failed, end function here
                if renameStatus
                    return;
                end
            end
            
            % get trial files
            trialFiles = cellDirContents(contains({cellDirContents.name}, ...
                'trial'));
            
            % loop over all trials
            for k = 1:length(trialFiles)
                trialPath = [trialFiles(k).folder filesep trialFiles(k).name];
                % load inputParams from trial file (has impt metadata)
                load(trialPath, 'inputParams');
                % get trial name without .mat apended
                trialName = trialFiles(k).name;
                trialName = trialName(1:(end-4)); % .mat is set 4 characters
                      
                % only execute leg video processing on trials with leg vid
                if (contains(inputParams.exptCond, 'leg'))
                    
                    % generate .mp4 and .zip files for trial
                    zipFfmpegLegVid(inputParams, scriptsPath, ...
                        flyDirs(i).name, cellDirs(j).name, trialName);
                        
                end
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
    
    % create powershell script that deletes all rawLegVid folders 
    deleteRLVscriptFName = [dateDirName '_deleteRawLegVid.ps1'];
    deleteRLVscriptPath  = [scriptsPath filesep deleteRLVscriptFName];
    deleteRLVscriptFID = fopen(deleteRLVscriptPath, 'w');
    
    % write line to delete each rawLegVid folder
    for i = 1:length(allRawLegVidPaths)
        fprintf(deleteRLVscriptFID, 'Remove-Item "%s" -Recurse\n', ...
            allRawLegVidPaths{i});
    end
    
    % close file
    fclose(deleteRLVscriptFID);
    
    % create batch file that wraps this powershell script
    batchDeleteRLVfName = [dateDirName '_deleteRawLegVid.bat'];
    batchDeleteRLVpath = [scriptsPath filesep batchDeleteRLVfName];
    batchDeleteRLVfid = fopen(batchDeleteRLVpath, 'w');
    
    % write constant lines
    fprintf(batchDeleteRLVfid, '@ECHO OFF\n'); % so batch file contents not printed
    
    % write call to Powershell
    fprintf(batchDeleteRLVfid, ...
        'Powershell -NoProfile -ExecutionPolicy Bypass -Command "%s" \n',...
        deleteRLVscriptPath);
    
    % close file
    fclose(batchDeleteRLVfid);
    
end
