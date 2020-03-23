% runEphysExpt.m
%
% Top level function for running electrophysiology experiments on the 
%  updated 2P deux two-photon scope.
% Sets up folder structure for organizing data (date/fly/cell), 
%  prompts whether this is new cell or additional trial(s) for cell. For 
%  new cell, prompts for experimental condition, asks to run pre-expt 
%  routines (pipette resistance, seal test, etc.), and runs through
%  experimental trials until no more new trials. For same cell (in case
%  previous run of runEphysExpt stopped unexpectedly), can run additional
%  trials.
%
% Adapted from run2PExpt
%
% USE: runEphysExpt()
%
% Created: 11/3/19
% Updated: 3/23/20 - HHY
%

function runEphysExpt()
    % clean up
    close all
    
    % initialize persistent variables
    persistent cellDirPath trialNum;
    
    % load constant settings
    [dataDir, exptFnDir, settings] = ephysSettings();
    
    % Asks whether this is a new cell
    newCell = input('New Cell? (y/n): ', 's');
    
    % NEW CELL
    if (strcmpi(newCell, 'y'))
        % set up folder structure for organizing data 
        % prompts for date directory; start from data directory in
        %  ephysSettings()
        disp('Select date directory');
        dateDirPath = uigetdir(dataDir, 'Select date directory');
        % get just name of directory
        [~, dateDirName, ~] = fileparts(dateDirPath); 
        cd(dateDirPath);
        
        % figure out which fly we're on in the date directory
        dateDirContents = dir(dateDirPath);
        currFlyDirs = dateDirContents(...
            contains({dateDirContents.name},'fly'));
        
        % Asks whether this is a new fly
        newFly = input('New Fly? (y/n): ', 's');
        if (strcmpi(newFly, 'n')) % NOT A NEW FLY 
            flyNum = length(currFlyDirs);
            
            if (flyNum == 0)
                flyNum = 1;
                flyDirName = sprintf('fly%02d',flyNum); % fly folder name 
                mkdir(flyDirName);
            else
                flyDirName = sprintf('fly%02d',flyNum); % fly folder name 
            end
            
            % go to fly directory
            cd(flyDirName);
            flyDirPath = pwd;
            
            % load fly metadata from previous cell
            flyDirContents = dir(flyDirPath);
            currCellDirs = flyDirContents(...
                contains({flyDirContents.name}, 'cell'));
            % path to metadata file of last cell for this fly
            metaDatPath = [currCellDirs.folder filesep ...
                currCellDirs.name filesep 'metaDat.mat'];
            % load fly metadata
            load(metaDatPath, 'flyData');
        else % NEW FLY (this is default)
            flyNum = length(currFlyDirs) + 1;
            flyDirName = sprintf('fly%02d',flyNum); % fly folder name 
            
            % creates fly folder in date directory            
            mkdir(flyDirName); % make fly folder
            
            % go to fly directory
            cd(flyDirName);
            flyDirPath = pwd;
            
            % request fly metadata
            flyData = getFlyMetadata(dateDirName, flyDirName);
        end

        % create new cell folder
        % existing cells for this fly
        flyDirContents = dir(flyDirPath);
        currCellDirs = flyDirContents(...
            contains({flyDirContents.name}, 'cell'));
        cellNum = length(currCellDirs) + 1;
        cellDirName = sprintf('cell%02d', cellNum); % cell folder name
        % create cell folder
        mkdir(cellDirName);
        
        % go to cell directory
        cd(cellDirName);
        cellDirPath = pwd;
        
        % generate basic experimental info struct
        exptInfo.dateDir = dateDirName;
        exptInfo.flyDir = flyDirName;
        exptInfo.cellDir = cellDirName;
        exptInfo.exptDate = datestr(now, 'yymmdd');
        exptInfo.exptStartTime = datestr(now, 'HH:MM:SS');
        
        % Save settings, fly metadata, experimental info to file
        save('metaDat.mat', 'flyData', 'settings', 'exptInfo', '-v7.3');
        
        % **ASKS TO RUN PRE-EXPT ROUTINES**
        while 1
            runPERout = input('\n\nRun pre-experimental routines? (y/n): ', 's');
            if strcmpi(runPERout, 'y')
                preExptData = preExptRoutine(settings);
                
                % asks about running pre-experimental routine again (e.g.
                %  fail to patch cell, try again, at stage past measuring
                %  pipette resistance, but trying for same cell)
                runPERagain = input(...
                    '\n\nRun pre-experimental routines again? (y/n): ', ...
                    's');
                if ~strcmpi(runPERagain, 'y')
                    disp('Did not run pre-experimental routines again.');
                    break;
                end
                
            else
                disp('Pre-experimental routine was not run.');
                break;
            end
        end
 
    % NOT A NEW CELL    
    elseif (strcmpi(newCell, 'n'))
        cd(cellDirPath) % make sure we're in the cell directory
        
        % **CONTINUES WITH NEXT TRIAL**        
        % prompt user to select an experiment
        exptSelected = 0;
        disp('Select an experiment');
        while ~exptSelected
            exptTypeFileName = uigetfile('*.m', 'Select an experiment',...
                exptFnDir);
            % if user cancels or selects valid file
            if (exptTypeFileName == 0)
                disp('Selection cancelled');
                exptSelected = 1; % end loop
            elseif (contains(exptTypeFileName, '.m'))
                disp(['Experiment: ' exptTypeFileName]);
                exptSelected = 1; % end loop
            else
                disp('Select an experimental .m file or cancel');
                exptSelected = 0;
            end
        end
        
        % if user cancels at this point 
        if (exptTypeFileName == 0)
            disp('No experiment was run. Ending runEphysExpt()');
            % ends run of this function
            return;
        end
        
        % prompt user for experiment duration
        exptDuration = input(...
            'Experiment duration in seconds. Enter 0 to end trial: ');
        % to end trial at this stage
        if (exptDuration == 0)
            disp('No experiment was run. Ending runEphysExpt()');
            % ends run of this function
            return;
        end
        
        % run experiment
        % convert selected experiment file into function handle
        % get name without .m
        exptTypeName = extractBefore(exptTypeFileName, '.');
        exptFn = str2func(exptTypeName);

        % display this experiment's path
        disp(pwd);

        % run actual experiment code
        try
            [rawData, inputParams, rawOutput] = exptFn(...
                settings, exptDuration); 
        catch errMes
            disp('Invalid Experimental Function. Ending runEphysExpt()');
            rethrow(errMes);
            % ends run of epxeriment
            return;
        end
        
        % get which trial number this is (only after trial is run
        if isempty(trialNum)
            trialNum = 1;
        else
            trialNum = trialNum + 1;
        end
        
        % save data
        trialFileName = sprintf('trial%02d.mat', trialNum); % file name
        save(trialFileName, 'rawData', 'rawOutput', 'inputParams', '-v7.3');
        fprintf('Data for trial %02d saved! \n', trialNum);
        
    
    % INVALID INPUT, DON'T DO ANYTHING
    else
        disp('Invalid input. Ending runEphysExpt()');
        return;
    end
    
end