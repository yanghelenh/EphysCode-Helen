% initTempProbe.m
%
% Function to initalize National Instruments USB-TC01 device (thermocouple
%  temperature probe)
%
% Input:
%   settings - struct from twoPhotonSettings() containing all DAQ settings
%
% Output:
%   tempDAQ - handle to temperature DAQ
%   tcCh - handle to thermocouple analog acquisition channel
%
% Created: 8/2/18
% Updated: 8/2/18
%

function [tempDAQ, tcCh] = initTempProbe(settings)
    
    disp('Initalizing Temperature Probe');

    % start DAQ session
    tempDAQ = daq.createSession(settings.devVendor);
    
    % Add thermocouple channel
    tcCh = tempDAQ.addAnalogInputChannel(settings.temp.devID, ...
        settings.temp.aiChUsed, settings.temp.aiMeasType);
    tcCh.ThermocoupleType = settings.temp.tcType;

end