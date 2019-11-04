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
% Updated: 11/3/19 - HHY
%

function runEphysExpt()
    % clean up
    close all
    
    % load constant settings
    [dataDir, exptFnDir, settings] = ephysSettings();
    
    % set up folder structure for organizing data 
    % prompts for date directory; start from data directory in
    %  twoPhotonSettings
    disp('Select date directory');
    dateDir = uigetdir(dataDir, 'Select date directory'); 
    [~, dateDirName, ~] = fileparts(dateDir); % get just name of directory
    cd(dateDir);
    
    % creates fly folder in date directory
    % figure out which fly we're on in the date directory
    dateDirContents = dir(dateDir);
    currFlyDirs = dateDirContents(...
        contains({dateDirContents.name},'fly'));
    flyNum = length(currFlyDirs) + 1;
    flyDirName = sprintf('fly%02d',flyNum); % fly folder name 
    mkdir(flyDirName); % make fly folder
    cd(flyDirName);
    flyDirPath = pwd;
    
    % request fly metadata
    flyData = getFlyMetadata(dateDirName, flyDirName);
    
    % loop through trials
    flyDone = 'n'; % boolean for whether fly is complete
    
    while (~strcmpi(flyDone, 'y'))
        % asks whether this is new field of view
        newFOV = input('New FOV? (y/n): ','s');
        
        flyDirContents = dir(flyDirPath);
        currFOVDirs = flyDirContents(...
            contains({flyDirContents.name},'fov'));
        % if new field of view, make new fov folder
        if (strcmpi(newFOV, 'y'))
            % works even if this is the first
            fovNum = length(currFOVDirs) + 1; 
            fovDirName = sprintf('fov%02d',fovNum); % fov folder name
            mkdir(fovDirName); % make fov folder
        else
            fovNum = length(currFOVDirs);
            fovDirName = sprintf('fov%02d',fovNum); % fov folder name
            if (~isfolder(fovDirName))
                newFOV = 'y'; % change this to yes, this is new FOV
                disp('This is the first FOV for this fly. Creating FOV folder');
                fovNum = length(currFOVDirs) + 1; 
                fovDirName = sprintf('fov%02d',fovNum); % fov folder name
                mkdir(fovDirName); % make fov folder    
            end
        end

        % go to field of view folder
        cd(fovDirName);
        fovDirPath = pwd;
        
        % create new trial folder
        fovDirContents = dir(fovDirPath);
        currTrialDirs = fovDirContents(...
            contains({fovDirContents.name},'trial'));
        trialNum = length(currTrialDirs) + 1;
        trialDirName = sprintf('trial%02d',trialNum); % trial folder name
        mkdir(trialDirName);
        cd(trialDirName); % go to trial folder
        trialDirPath = pwd;
        
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
            cd(fovDirPath) % move up out of trial folder into fov folder
            rmdir(trialDirName); % delete this trial folder
            % if this was a new field of view, delete that folder as well
            if (strcmpi(newFOV, 'y'))
                cd(flyDirPath) % move up out of fov folder into fly folder
                rmdir(fovDirName)
            end
            % ask user whether to end fly
            flyDone = input('End fly? (y/n): ', 's');
            if (strcmpi(flyDone, 'y'))
                disp('Ending fly.');
            end
            % restarts loop without running anything (or ends fly 
            %  completely)
            continue 
        end
        % prompt user for experiment duration
        exptDuration = input(...
            'Experiment duration in seconds. Enter 0 to end fly: ');
        % to end fly at this stage
        if (exptDuration == 0)
            disp('Ending fly.');
            cd(fovDirPath) % move up out of trial folder
            rmdir(trialDirName); % delete this trial folder
            % if this was a new field of view, delete that folder as well
            if (strcmpi(newFOV, 'y'))
                cd(flyDirPath) % move up out of fov folder
                rmdir(fovDirName)
            end
            flyDone = 'y';
            % will end looping
            continue
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
            exptReturn = exptFn(settings, flyData, exptDuration); 
        catch
            disp('Invalid Experimental Function');
            % undo folder creation
            cd(fovDirPath) % move up out of trial folder
            rmdir(trialDirName); % delete this trial folder
            % if this was a new field of view, delete that folder as well
            if (strcmpi(newFOV, 'y'))
                cd(fovDirPath) % move up out of fov folder
                rmdir(fovDirName)
            end
        end
        
        % if experiment ran to completeion without errors
        if (exptReturn == 1)
            disp('Experiment complete!');
        end
        
        % prompt user to run another trial or end fly
        flyDone = input('End fly? (y/n): ','s');
        
        cd(flyDirPath);
    end
end
