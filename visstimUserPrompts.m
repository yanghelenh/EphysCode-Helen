% visstimUserPrompts.m
%
% Function to wrap all the user prompts to get the input parameters for
%  presenting visual stimuli (on the G3 arena system)
%
% INPUTS:
%   settings - struct of ephys setup settings, from ephysSettings()
%
% OUTPUTS:
%   visstimParams - struct with fields containing all parameters:
%       visstimMode - name of mode (closed loop, open loop)
%       panelMode - panel parameter for set_mode, as [x,y]
%       patternName - name of pattern
%       patternIndex - index of pattern, parameter for set_pattern_id
%       initPatternPos - initial pattern position, as [x,y]; parameter for
%           set_position
%       xFuncName - name of position function for X, when in open loop
%       xFuncIndex - index of position function for X, when in open loop;
%           parameter for set_posfunc_id
%       yFuncName - name of position function for Y, when in open loop
%       yFuncIndex - index of position function for Y, when in open loop;
%           parameter for set_posfunc_id
%
% CREATED: 2/11/21 - HHY
%
% UPDATED:
%   2/11/21 - HHY
%

function visstimParams = visstimUserPrompts(settings)

    % prompt user for whether to run visual stimuli in open or closed loop
    prompt = ['Select the mode the visual stimulus should run in \n' ...
        'Closed loop, X only (cx)\nClosed loop, Y only (cy)\n' ...
        'Closed loop, X and Y (cxy)\nOpen loop (o)\n'];
    modeAns = input(prompt, 's');
    % set the mode, record it
    % NOTE: check the setting for only 1 channel in closed loop!!
    switch modeAns
        case 'cx'
            visstimParams.visstimMode = 'closedLoopX';
            visstimParams.panelMode = [settings.visstim.closedloopMode, ...
                settings.visstim.intfuncMode];
        case 'cy'
            visstimParams.visstimMode = 'closedLoopY';
            visstimParams.panelMode = [settings.visstim.intfuncMode, ...
                settings.visstim.closedloopMode];
        case 'cxy'
            visstimParams.visstimMode = 'closedLoopXY';
            visstimParams.panelMode = [settings.visstim.closedloopMode, ...
                settings.visstim.closedloopMode];
        case 'o'
            visstimParams.visstimMode = 'openLoop';
            visstimParams.panelMode = [settings.visstim.openloopMode, ...
                settings.visstim.openloopMode];
        otherwise
            disp('Improper input, defaulting to open loop');
            visstimParams.visstimMode = 'openLoop';
            visstimParams.panelMode = [settings.visstim.openloopMode, ...
                settings.visstim.openloopMode];
    end
    
    % prompt for pattern, by selecting from list
    % get list of patterns (from list of files in pattern directory)
    patternFiles = dir(vsPatternsDir());
    patternList = {patternFiles.name};
    patternList = patternList(3:end); % remove . and .. from list
    % boolean for whether user has selected a pattern, initialize at 0
    patternSelected = 0;
    disp('Select a pattern');
    % loop until user selects pattern
    while ~patternSelected
        [patternIndex, patternSelected] = listdlg('ListString', ...
            patternList, 'PromptString', 'Select a pattern', ...
            'SelectionMode', 'single');
    end
    % save pattern name and index
    visstimParams.patternName = patternList(patternIndex);
    visstimParams.patternIndex = patternIndex;
    
    % prompt user for initial pattern position, as [X,Y]
    prompt = 'Initial pattern position [x,y]: ';
    initPatternPos = str2num(input(prompt, 's'));
    visstimParams.initPatternPos = initPatternPos;
    
    % if open loop, prompt user for X and Y functions
    if (strcmp(visstimParams.visstimMode,'openLoop'))
        % prompt for X function, by selecting from list
        % get list of visual stimuli functions (from list of files in
        %  function directory)
        funcFiles = dir(vsFunctionsDir());
        funcList = {funcFiles.name};
        funcList = funcList(3:end); % remove . and .. from list
        % boolean for whether user has selected an X function, initialize
        xFuncSelected = 0;
        disp('Select an X function');
        % loop until user selects an x function
        while ~xFuncSelected
            [xFuncIndex, xFuncSelected] = listdlg('ListString', ...
                funcList, 'PromptString', 'Select an X function', ...
                'SelectionMode', 'single');
        end
        % prompt user for Y function
        yFuncSelected = 0;
        disp('Select a Y function');
        while ~yFuncSelected
            [yFuncIndex, yFuncSelected] = listdlg('ListString', ...
                funcList, 'PromptString', 'Select a Y function', ...
                'SelectionMode', 'single');
        end
        % save function names and indices
        visstimParams.xFuncName = funcList(xFuncIndex);
        visstimParams.xFuncIndex = xFuncIndex;
        visstimParams.yFuncName = funcList(yFuncIndex);
        visstimParams.yFuncIndex = yFuncIndex;
    end
end