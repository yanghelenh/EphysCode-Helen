% saveFictracImgCount.m
%
% Function to run on FicTrac computer to record the start and end frame
%  numbers for FicTrac video.
% Saves start and end frame counts into .mat file named with corresponding
%  trial names (user specified, should match trial names from main
%  experimental code (runEphysExpt() calls)
% Also saves triggered FicTrac camera frame rate.
%
% INPUTS:
%   none, but prompts user for data folder and trial name, and start and
%       end frame counts
%
% OUTPUTS:
%   none, but saves frame counts into .mat file
%
% CREATED: 1/7/21 - HHY
%
% UPDATED:
%   1/7/21 - HHY
%
function saveFictracImgCount()

    % load ephys settings
    [~, ~, settings] = ephysSettings();

    % FicTrac camera frame rate - make sure it's a whole number of DAQ
    %  scans
    ftCamFrameRate = 150; % in Hz
    ftCamFrameRateScans = round(settings.bob.sampRate / ftCamFrameRate);
    inputParams.ftCamFrameRate = settings.bob.sampRate / ...
        ftCamFrameRateScans;
    
    % get folder to save .mat file into
    disp('Select data directory');
    dataDirPath = uigetdir(dataDir, 'Select data directory');
    cd(dataDirPath);
    
    % ask user for trial name
    prompt = 'Trial name: ';
    trialName = input(prompt, 's');
    
    % prompt user for current number of FicTrac video frames grabbed
    prompt = 'Enter current number of FicTrac video frames grabbed: ';
    inputParams.startFtVidNum = str2double(input(prompt, 's'));
    
    disp('When trial acquisition is finished');
    % prompt user for end number of FicTrac video frames grabbed
    prompt = 'Enter current number of FicTrac video frames grabbed: ';
    inputParams.endFtVidNum = str2double(input(prompt, 's'));
    
    % display number of frames acquired in this trial
    numFtVidAcq = inputParams.endFtVidNum - inputParams.startFtVidNum;
    fprintf('%d FicTrac video frames grabbed. \n', numFtVidAcq);
    
    % save start and end img counts into .mat file
    fullSavePath = [dataDirPath filesep trialName '.mat'];
    save(fullSavePath, 'inputParams', '-v7.3');
    
end