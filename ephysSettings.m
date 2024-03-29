% ephysSettings.m
%
% Function that returns all the CONSTANTS for an electrophysiology
%  experiment
%
% Modification of twoPhotonSettings.m, which is modification of
%  ephysSettings.m from Yvette
%
% OUTPUT:
%   dataDir - name of base data directory
%   exptFnDir - name of folder containing all experiment functions
%   settings - struct of settings
%
% Created: 11/3/19
%
% Updated: 
%   1/21/20 - HHY
%   7/22/20 - HHY - add zero values for zero current/voltage command from
%       DAQ, to compensate for standing voltage delivered
%   2/11/21 - HHY - updates for visual stimulus presentation
%   2/15/21 - HHY - visual stimuli function frequency, only 1 value (same
%       for X and Y)
%   3/10/21 - HHY - visual stimuli function frequency changed to 150 Hz
%       from 200 Hz b/c 200 Hz gives bug with closed loop 1 channel, open
%       loop with position function for other channel
%   4/23/21 - HHY - add leg camera frame rate as setting
%   2/20/22 - HHY - remove ScanImage digital I/O channels from output, add
%       channels to control Hg lamp shutter
%

function [dataDir, exptFnDir, settings] = ephysSettings()

    MV_PER_V = 1000; % millivolts per volts
    
    % Data folder
    % Determine which computer this code is running on
    comptype = computer; % get the string describing the computer type
    PC_STRING = 'PCWIN64';  % string for PC on 2P rig
    MAC_STRING = 'MACI64'; %string for macbook

    %  Set the paths according to whether we are on the MAC or PC
    if strcmp(comptype, PC_STRING) % WINDOWS path
%         dataDir = 'D:\Data\Helen';
        dataDir = 'F:\Data\Helen';
        % path to folder containing all experiment defining functions
        exptFnDir = 'C:\Users\WilsonLab\Documents\HelenExperimentalCode\EphysCode-Helen\Experiment Types';
        % add experiment function path
        addpath(exptFnDir);
    elseif strcmp(comptype, MAC_STRING) % MACBOOK PRO path
        dataDir = '/Users/hyang/Documents/'; % TBD
        exptFnDir = '/Users/hyang/Documents/EphysCode-Helen/Experiment Types';
        % add experiment function path
        addpath(exptFnDir);        
    else 
        % if neither computer types throw error
        error('ERROR: dataDir not found that matches this computer type');
    end

    % DAQ settings

    % Devices
    settings.devVendor = 'ni';
    settings.bob.devID = 'PXI1Slot5';
    settings.temp.devID = 'Dev1';

    % Sampling Rate
    settings.bob.sampRate  = 20e3; % 20 kHz, same as Yvette
%     % Sampling rate for measuring access resistance
%     % NI 6361 DAQ max for 6 ephys channels 166 kHz (1MS/s)
%     settings.bob.sampRateRacc = 10e4; % 100 kHz 
    

    % Break out box, channel assignments
    % which analog input channels are used
    settings.bob.aInChUsed  = [0:5 8:12];
    % which digital input channels are used (matrix each row is channel, column
    %  1 is port number, column 2 is line number)
    settings.bob.dInChUsed = [0 5; 0 6; 0 7];
    % which analog output channels are used (currently, none)
    settings.bob.aOutChUsed = [0:1];
    % which digital output channels are used (notation as above)
    settings.bob.dOutChUsed = [0 0; 0 3; 0 4];

    % to decode which column in raw data output from data acquisition
    %  corresponds to what information; ordered by order channels will be added
    %  to DAQ session; add analog before digital
    settings.bob.aInChAssign = {'ampScaledOut', 'ampI', ...
        'amp10Vm', 'ampGain', 'ampFreq', 'ampMode', ...
        'ficTracHeading', 'ficTracIntX', 'ficTracIntY', 'panelsDAC0X',...
        'panelsDAC1Y'};
    settings.bob.dInChAssign = {'ficTracCamFrames', ...
        'HgLampShutterSyncOut', 'legCamFrames'};
    settings.bob.inChAssign = [settings.bob.aInChAssign ...
        settings.bob.dInChAssign];
    % output channel assignments (notation like input, above)
    settings.bob.aOutChAssign = {'ampExtCmdIn', 'aOut1'};
    settings.bob.dOutChAssign = {'HgLampShutterPulseIn', ...
        'legCamFrameStartTrig', 'ficTracCamStartTrig'};
    settings.bob.outChAssign = [settings.bob.aOutChAssign ...
        settings.bob.dOutChAssign];

    % Analog input channel settings
    % analog input type 'SingleEnded' as opposed to 'Differential' (no
    %  comparisons across 2 BNCs of break out box; switch on SE)
    settings.bob.aiMeasType = 'Voltage';
    settings.bob.aiInType = 'SingleEnded'; 
    % voltage range - for channels, in order in aInChAssign
    settings.bob.aiRange = [-10 10; -10 10; -10 10; -10 10; -10 10; ...
        -10 10; -10 10; -10 10; -10 10; -10 10; -10 10];

    % Digital input channel settings
    % digital input type - 'InputOnly', not 'Bidirectional'
    settings.bob.diType = 'InputOnly'; 
    
    % Analog output channel settings
    % analog output can be 'Voltage' or 'Current'
    settings.bob.aoMeasType = 'Voltage';
    % analog output as 'SingleEnded'
    settings.bob.aoOutType = 'SingleEnded';
    % voltage range - for channels, in order of aOutChAssign
%     settings.bob.aoRange = [-5 5];
    settings.bob.aoRange = [-10 10; -10 10]; % just for testing
    
    % Digital output channel settings
    % digital output type - 'OutputOnly', not 'Bidirectional'
    settings.bob.doType = 'OutputOnly';
    
    % Thermocouple (USB-TC01) only channel
    settings.temp.aiChUsed = 'ai0';
    settings.temp.aiMeasType = 'Thermocouple';
    settings.temp.tcType = 'J'; % thermocouple type
    
    
    % Static conversion factors on ephys channels
    settings.amp.beta = 1; % beta value for Axopatch 200B, whole cell
    
    % Current (beta mV/pA)
    settings.I.sigCondGain = 1; % signal conditioner not currently in use
    settings.I.sigCondFreq = nan; % LP filter, in kHz, sig cond not in use
    settings.I.ampGain = 1; % has option in back for this to be 100
    % conversion from V reading from DAQ to pA measured
    settings.I.softGain = MV_PER_V / (settings.I.sigCondGain * ...
        settings.amp.beta * settings.I.ampGain);
    
    % Voltage (10 Vm)
    settings.Vm.sigCondGain = 1; % signal conditioner not currently in use
    settings.Vm.sigCondFreq = nan; % LP filter, in kHz, sig cond not in use
    settings.Vm.ampGain = 10; % amp gain
    % conversion from V reading from DAQ to mV measured
    settings.Vm.softGain = MV_PER_V / (settings.Vm.sigCondGain * ...
        settings.Vm.ampGain);
    
    % Voltage Output (V Clamp 20 mV/V, I Clamp 2/beta nA/V)
    settings.VOut.vDivGain = 1; % currently, no voltage divider
    settings.VOut.ampVCmdGain = 20; % 20 mV/V
    settings.VOut.VConvFactor = 1 / (settings.VOut.ampVCmdGain * ...
        settings.VOut.vDivGain);
    settings.VOut.zeroV = -0.012880558953762; % mV, measured 7/23/20 - HHY
    settings.VOut.ampICmdGain = 2000 / settings.amp.beta; % 2000/beta pA/V
    settings.VOut.IConvFactor = 1 / (settings.VOut.ampICmdGain * ...
        settings.VOut.vDivGain);
    settings.VOut.zeroI = -0.965853722646187; % pA, measured 7/23/20 - HHY
    
    
    % Some static parameters for testing pipette/seal/access resistances
    % duration of recording for pipette/seal resistances measurements in
    %  pre-expt routine
    settings.sealTestDur = 2; % in sec
    
    
    % Visual Panels (G3) 
    % indicies into X and Y channels of pattern
    settings.visstim.chNumX = 1;
    settings.visstim.chNumY = 2;
    % panels function frequency for X and Y, should be multiple of 50, max
    %  500; only 50 Hz works consistently for closed loop X, open loop Y
    settings.visstim.funcfreq = 50;
    
    % modes for different types of control of pattern
    settings.visstim.openloopMode = 4;
    settings.visstim.closedloopMode = 3;
    settings.visstim.intfuncMode = 0;
    
    % defaults for gain and bias
    % gain values multiplied by 10 for 'send_gain_bias'
    settings.visstim.gainFactor = 10; 
    % bias values multiplied by 20 for 'send_gain_bias'
    settings.visstim.biasFactor = 20;
    % default values, not scaled for 'send_gain_bias'
    settings.visstim.defaultGain = 1; % as a multiplicative factor
    settings.visstim.defaultBias = 0; % in V
    
    % defaults for X and Y functions, when they're not being used
    settings.visstim.defaultXFunc = 1; % static
    settings.visstim.defaultYFunc = 1; % static
    
    % leg camera frame rate
    settings.leg.frameRate = 250; % frame rate in Hz
    
    % FicTrac camera frame rate (when acquiring FicTrac video)
    settings.fictrac.frameRate = 150; % in Hz
    
end
