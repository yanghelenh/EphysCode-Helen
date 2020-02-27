% preprocessEphys.m
%
% Function that takes data passed through preprocessUserDaq, with named
%  fields and preprocesses electrophysiology data. I.e. scales output
%  channels, decodes telegraphed output.
%
% INPUTS:
%   daqData - struct of data collected on daq, with fields labeled
%   daqTime - timing vector for daqData
%
% OUTPUTS:
%   ephysData - struct of processed ephys data, with fields:
%       voltage - 10 Vm channel
%       current - current channel
%       scaledOut - scaled output channel
%       telOut - telegraphed output struct
%           gain
%           freq
%           mode
%
% CREATED: 1/23/20
% UPDATED: 1/23/20 - HHY
%   2/27/20 - HHY - incomplete and made obsolete by preprocessEphysData
%

function ephysData = preprocessEphys(daqData, daqTime)

    % decode telegraphed output
    ephysData.telOut.gain = decodeTelegraphedOutput(...
        daqData.ampGain, 'gain');
    ephysData.telOut.freq = decodeTelegraphedOutput(...
        daqData.ampFreq, 'freq');
    ephysData.telOut.mode = decodeTelegraphedOutput(...
        daqData.ampMode, 'mode');

end

