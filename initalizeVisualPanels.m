% initalizeVisualPanels.m
%
% Code that takes in all parameters for initalizing visual panels and calls
%  the appropriate PControl commands.
%
% INPUTS:
%   panelParams - struct containing all parameter values for initalizing
%       visual panels appropriately. Fields are:
%       panelMode - [X,Y] representing closed/open loop mode for each
%           channel
%       patternIndex - index of pattern on SD card
%       initPatternPos - [X,Y] representing initial pattern position, uses
%           0 indexing
%       xFuncIndex - index for X function on SD card, for open loop only
%       yFuncIndex - index for Y function on SD card, for open loop only
%       xGain - gain for X channel as multiplicative factor, for closed
%           loop only
%       yGain - gain for Y channel as multiplicative factor, for closed
%           loop only
%   settings - output struct of ephysSettings(), has defaults/constants
%
% OUTPUTS:
%   none, but initializes everything on visual panels
%
% CREATED: 2/10/21 - HHY
%
% UPDATED:
%   2/10/21 - HHY
%   2/11/21 - HHY - fix typos
%

function initalizeVisualPanels(panelParams, settings)
        
    % set pattern ID number
    Panel_com('set_pattern_id', panelParams.patternIndex);
    pause(.03);

    % set initial position of pattern 
    % + 1 to account for 0 indexing
    Panel_com('set_position', panelParams.initPatternPos + 1);
    pause(.03);

    % set controller mode (for open vs. closed loop)
    Panel_com('set_mode', panelParams.panelMode);
    pause(.03);

    % set function frequencies for X and Y channels
    Panel_com('set_funcx_freq', settings.visstim.funcfreqX);
    pause(.03);
    Panel_com('set_funcy_freq', settings.visstim.funcfreqX);
    pause(.03);

    % set position functions for X and Y channels
    % if there is a specified X position function
    if isfield(panelParams, 'xFuncIndex')
        Panel_com('set_posfunc_id', ...
            [settings.visstim.chNumX, panelParams.xFuncIndex]);
        pause(.03);
    % otherwise, use default X position function
    else
        Panel_com('set_posfunc_id', ...
            [settings.visstim.chNumX, settings.visstim.defaultXFunc]);
        pause(.03);
    end
    % if there is a specified Y position function
    if isfield(panelParams, 'yFuncIndex')
        Panel_com('set_posfunc_id', ...
            [settings.visstim.chNumY, panelParams.yFuncIndex]);
        pause(.03);
    % otherwise, use default Y position function
    else
        Panel_com('set_posfunc_id', ...
            [settings.visstim.chNumY, settings.visstim.defaultYFunc]);
        pause(.03);
    end

    % set gain and bias for X and Y channels
    % if there is a specified xGain
    if isfield(panelParams, 'xGain')
        xGain = panelParams.xGain * settings.visstim.gainFactor;
    % otherwise, use default
    else
        xGain = settings.visstim.defaultGain * settings.visstim.gainFactor;
    end
    if isfield(panelParams, 'yGain')
        yGain = panelParams.yGain * settings.visstim.gainFactor;
    else
        yGain = settings.visstim.defaultGain * settings.visstim.gainFactor;
    end
    % for now (2/10/21), no option for bias except default
    bias = settings.visstim.defaultBias * settings.visstim.biasFactor;

    Panel_com('send_gain_bias', [xGain, bias, yGain, bias]);
    pause(.03);

end