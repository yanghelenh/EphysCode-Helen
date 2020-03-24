% preExptRoutine.m
%
% Function that measures pipette resistance, seal resistance, cell attached
%  spikes, access resistance, and resting Vm as the early part of the 
%  patching process. Gives option to run or not run each of these.
%
% INPUT:
%   settings - struct of ephys setup settings, from ephysSettings()
%
% OUTPUT:
%   preExptData - struct of pre-experimental data, with fields:
%       pipetteResistance
%       sealResistance
%       initialHoldingCurrent
%       initialAccessResistance
%       initialInputResistance
%       initialRestingVoltage
%
% CREATED: 11/4/19
% UPDATED: 11/4/19 - HHY
%   2/27/20 - HHY
%   3/11/20 - HHY
%

function preExptData = preExptRoutine(settings)

    preExptFolderName = 'preExptTrials';
    
    % make preExptTrials folder if it does't already exist
    if ~isfolder(preExptFolderName)
        mkdir(preExptFolderName);
    end
    
    % go to preExptFolder
    cd(preExptFolderName);
    
    preExptPath = pwd;
    
    %% Measure pipette resistance loops until 'no' selected
    while 1
        contAns = input(...
            '\nMeasure pipette resistance? (y/enter = yes, n = no) ',...
            's');
        if strcmpi(contAns,'y') || strcmpi(contAns,'') % 'y' or enter
            type = 'pipette';
            preExptData.pipetteResistance = measurePipetteResistance(...
                settings, type);

            printVariable(preExptData.pipetteResistance, ...
                'Pipette Resistance', ' MOhms');

            contA = input(...
                '\nMeasure pipette resistance AGAIN? (y = yes, n/enter = no) ',...
                's');
            if  strcmpi(contA,'n') || strcmpi(contA,'')
                break;
            end
        else
            break
        end
    end

    %% Measure seal resistance
    contAns = input(...
        '\nMeasure seal resistance? (y/enter = yes, n = no) ','s');
    if strcmpi(contAns,'y') || strcmpi(contAns,'') 
        type = 'seal';
        preExptData.sealResistance = measurePipetteResistance(...
                settings, type);

        % function returns MOhms, divide by 1000 to report GOhms
        printVariable(preExptData.sealResistance/1000 , ...
            'Seal Resistance', ' GOhms');
    end

    %% Measure voltage trial to look at cell attached spikes
    contAns = input(...
        '\nRun a trial in V-clamp to measure cell attached spikes? ',...
        's');
    if strcmpi(contAns,'y') || strcmpi(contAns,'')
        % get trial duration as user input
        duration = input('\nDuration in sec of trial: ');
        
        % acquire trial
        [rawData, inputParams, rawOutput] = ephysRecording(settings, ...
            duration);
        
        % process recording snippet
        [daqData, daqOutput, daqTime] = preprocessUserDaq(inputParams, ...
            rawData, rawOutput, settings);
        [ephysData, ephysMeta] = preprocessEphysData(daqData, daqOutput, ...
            daqTime, inputParams, settings);

        % TO DO: Add in calculation of spike rate here.

        % Save cellAttachedTrial trial in preExptTrials folder
        save('cellAttachedTrial.mat', 'ephysData', 'ephysMeta', '-v7.3');
    end


    %% Measure access and input resistance and holding current
    contAns = input('\nMeasure access resistance? ','s');
    if strcmpi(contAns,'y') || strcmpi(contAns,'')
        [preExptData.initialHoldingCurrent, ...
            preExptData.initialAccessResistance, ...
            preExptData.initialInputResistance] = ...
            measureAccessResistance(settings);

        printVariable(preExptData.initialHoldingCurrent, ...
            'Holding Current', ' pA');
        printVariable(preExptData.initialAccessResistance, ...
            'Access Resistance', ' MOhms');
        printVariable(preExptData.initialInputResistance, ...
            'Input Resistance', ' MOhms');

    end

    %% Measure resting voltage (I = 0)
    contAns = input('\nRun a trial in I=0? ','s');
    if strcmpi(contAns,'y') || strcmpi(contAns,'')
        % duration to get resting voltage same as seal test duration
        duration = settings.sealTestDur;
        
        % acquire trial
        [rawData, inputParams, rawOutput] = ephysRecording(settings, ...
            duration);
        
        % process recording snippet
        [daqData, daqOutput, daqTime] = preprocessUserDaq(inputParams, ...
            rawData, rawOutput, settings);
        [ephysData, ephysMeta] = preprocessEphysData(daqData, daqOutput, ...
            daqTime, inputParams, settings);

        preExptData.initialRestingVoltage = mean(ephysData.voltage);

        printVariable(preExptData.initialRestingVoltage, ...
            'Resting Voltage', 'mV');

        % Save resting voltage trial
        save('restingVoltageTrial.mat','ephysData','ephysMeta', '-v7.3');
    end


    %% Check if preExptData was created
    if ~exist( 'preExptData', 'var')
        disp('WARNING: preExptData varible is empty!!');
        % create an empty struct as a place holder
        preExptData = struct;
    end
    
    cd .. % go back to previous folder, not preExptFolder
end

%% Helper Functions
function printVariable(value, label, unit)
    fprintf(['\n' label, ' = ', num2str(value), unit]);
end


