% createFictracVidPath.m
%
% Function to create folder system for FicTrac video. Matches folder
%  structure for runEphysExpt. Also, creates full path to copy and paste
%  into SpinView for saving video.
% Run once for each new cell.
%
% INPUTS:
%   none, but prompts user to select date folder
%
% OUTPUTS:
%   none, but creates folders for saving FicTrac video and generates path
%       for copying and pasting
%
% CREATED: 12/31/20 - HHY
%
% UPDATED:
%   12/31/20 - HHY
%   1/8/21 - HHY - update for FicTrac data path
%
function createFictracVidPath()

    % set up folder structure for organizing data 
    % prompts for date directory; start from data directory in
    %  ephysSettings()
    disp('Select date directory');
    dateDirPath = uigetdir(ftDataDir(), 'Select date directory');
    cd(dateDirPath);

    % figure out which fly we're on in the date directory
    dateDirContents = dir(dateDirPath);
    currFlyDirs = dateDirContents(...
        contains({dateDirContents.name},'fly'));

    % Asks whether this is a new fly
    newFly = input('\nNew Fly? (y/n): ', 's');
    if (strcmpi(newFly, 'n')) % NOT A NEW FLY 
        flyNum = length(currFlyDirs);

        if (flyNum == 0)
            flyNum = 1;
            flyDirName = sprintf('fly%02d',flyNum); % fly folder name 
            mkdir(flyDirName);
        else
            flyDirName = sprintf('fly%02d',flyNum); % fly folder name 
        end

    else % NEW FLY (this is default)
        flyNum = length(currFlyDirs) + 1;
        flyDirName = sprintf('fly%02d',flyNum); % fly folder name 

        % creates fly folder in date directory            
        mkdir(flyDirName); % make fly folder
    end

    % go to fly directory
    cd(flyDirName);
    flyDirPath = pwd;

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
    
    % make folder for raw images
    mkdir('rawFictracVid');
    % raw FicTrac video full path
    fictracVidFileName = sprintf('%s%srawFictracVid%sfictracVid', pwd, ...
        filesep, filesep);
    % copy path to clipboard
    clipboard('copy', fictracVidFileName);
    % prompt user to copy path into spinview
    prompt = ['FicTrac Video Acquisition. \n'...
        'Press RECORD button and paste directory from system clipboard '...
        'into the *Filename* section. \n Set *Image Format* to Tiff ' ... 
        'and *Compression Method* to Rle. Then press Start Recording.' ...
        '\n Make sure camera is acquiring (green play button). \n' ...
        'Make sure the buffer stream is set to oldest first, \n'...
        'manual, and 100000. \n'];
    input(prompt, 's');
end