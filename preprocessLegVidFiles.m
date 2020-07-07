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
                
                % go to raw leg vid folder
                cd(rawLegVidPath)
                
                % generate Powershell script to rename legVid files
                renameScriptFname = [flyDirs(i).name '_' ...
                    cellDirs(j).name '_legVidRenameScript.ps1'];
                renameScriptPath = [scriptsPath filesep renameScriptFname];
                renameScriptFID = fopen(renameScriptPath, 'w');

                % write command to go to right folder
                fprintf(renameScriptFID, 'cd "%s"\n', rawLegVidPath);
                % write rename command
                fprintf(renameScriptFID, ...
                    'get-childitem legVid* | rename-item -newname{[string] ($_.name).substring(21) -replace "-", "legVid-"}');

                % close file
                fclose(renameScriptFID);
                
                % call script to do renaming                    
                renameCmd = sprintf(...
                    'Powershell -NoProfile -ExecutionPolicy Bypass -Command "%s"', ...
                    renameScriptPath);
                renameStatus = system(renameCmd);
                
                if ~(renameStatus)
                    disp('Leg vid images renamed successfully!');
                else
                    disp('Error renaming leg vid images');
                    return; % end function here; this is a problem
                end
                
                % go to cell folder
                cd(cellDirPath);
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
                    
                    % current number of frames grabbed same as start index
                    %  for new video with zero indexing
                    startFrame = inputParams.startLegVidNum;
                    % total number of frames grabbed for this trial
                    totFrames = inputParams.endLegVidNum - ...
                        inputParams.startLegVidNum;
                    frameRate = inputParams.legCamFrameRate;
                    
                    % zip file name and path
                    legVidZipFname = [flyDirs(i).name '_' ...
                        cellDirs(j).name '_' trialName '_legVid.zip'];
                    legVidZipPath = [cellDirPath filesep legVidZipFname];
                    
                    % generate filelist file for images to put in zip file
                    filelistFname = [flyDirs(i).name '_' ...
                        cellDirs(j).name '_' trialName '_filelist.txt'];
                    filelistPath = [scriptsPath filesep filelistFname];
                    filelistFID = fopen(filelistPath, 'w');
                    
                    % loop over all frame numbers to include, write to file
                    for r = startFrame:(startFrame + totFrames - 1)
                        fprintf(filelistFID, '%s%slegVid-%d.tiff\n', ...
                            rawLegVidPath, filesep, r);
                    end
                    
                    % close file
                    fclose(filelistFID);
                    
                    % generate powershell script file for zipping
                    zipScriptFname = [flyDirs(i).name '_' ...
                        cellDirs(j).name '_' trialName '_zipScript.ps1'];
                    zipScriptPath = [scriptsPath filesep zipScriptFname];
                    zipScriptFID = fopen(zipScriptPath, 'w');
                    
%                     % add this zip script path to cell array of them
%                     % (for writing to batch file later)
%                     allZipScriptPaths = {allZipScriptPaths{:} ...
%                         zipScriptPath};
                    
                    % write constant portions of script
                    fprintf(zipScriptFID, '$7zipPath = "%s"\n', PATH_7ZIP);
                    fprintf(zipScriptFID, 'Set-Alias 7zip $7zipPath\n');
                    
                    % write variable portions of script: zip file path, 
                    %  filelist path
                    fprintf(zipScriptFID, '$Target = "%s"\n', ...
                        legVidZipPath); % target is zip file
                    fprintf(zipScriptFID, '$Source = "@%s"\n', filelistPath);
                    
                    % write line to actually do zipping
                    fprintf(zipScriptFID, '7zip a $Target $Source');
                    
                    % close file
                    fclose(zipScriptFID);
                    
                    % file name for leg vid mp4
                    legVidFName = [flyDirs(i).name '_' ...
                        cellDirs(j).name '_' trialName ...
                        '_legVid.mp4'];
                    legVidPath = [cellDirPath filesep legVidFName];
                    
                    % generate command for creating ffmpeg video
                    vidCmd = ...
                        sprintf('ffmpeg -f image2 -r %.2f -start_number %d -i %s%slegVid-%%d.tiff -vframes %d -pix_fmt yuv420p -r %.2f -b:v 17000k -c:v libx264 %s', ...
                        frameRate, startFrame, rawLegVidPath, filesep, ...
                        totFrames, frameRate, legVidPath);
                    % run command for creating ffmpeg video
                    createVidStatus = system(vidCmd);
                    
                    % display whether video file generated successfully
                    if ~(createVidStatus)
                        fprintf('%s created successfully! \n', legVidFName);
                    else
                        fprintf('Error creating %s. \n', legVidFName);
                    end
                    
                    % generate command for calling powershell script for
                    %  zipping
                    zipCmd = ...
                        sprintf('Powershell -NoProfile -ExecutionPolicy Bypass -Command "%s" \n', ...
                        zipScriptPath);
                    % run command to zip files
                    zipStatus = system(zipCmd);
                    
                    % display whether zipping happened successfully
                    if ~(zipStatus)
                        fprintf('%s zipped succesfully!\n', ...
                            [flyDirs(i).name '_' cellDirs(j).name '_'...
                            trialName]);
                    else
                        fprintf('Error zipping %s.\n', ...
                            [flyDirs(i).name '_' cellDirs(j).name '_'...
                            trialName]);
                    end
                        
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
