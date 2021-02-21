% runVisStim.m
%
% Function to run visual stimulus for specified duration (or until key
%  press). User selects pattern and mode (closed loop X, Y, both; open
%  loop).
% Does not acquire any data. Meant to play between calls of runEphysExpt()
%  to acclimate fly to closed loop on a ball
%
% INPUTS:
%   none, but prompts user for which pattern, type of closed loop, duration
%     of run
%
% OUTPUTS:
%   none
%
% CREATED: 2/19/21 - HHY
%
% UPDATED:
%   2/19/21 - HHY
%
function runVisStim()
    
    % call settings
    [~, ~, settings] = ephysSettings();
    
    % prompt user for duration
    prompt = 'Duration to play visual stimulus (s): ';
    dur = input(prompt, 's');
    % convert duration to datetime format
    durSec = seconds(dur);
    
    % prompt user for visual stimulus parameters
    visstimParams = visstimUserPrompts(settings);
    
    % send information to visual panels
    initalizeVisualPanels(visstimParams, settings);
    
    % experiment start time
    startTime = datetime('now');
    % experiment end time (based on duration
    endTime = startTime + durSec;
    
    % start visual panels
    Panel_com('start');
    
    % loop that allows check for key press
    while 1
        % if any key on keyboard is pressed, initialize stopping of
        %  acquisition; or if specified duration of acquisition is reached
        if ((KbCheck) || (endTime < datetime('now')))
            disp('Stopping visual stimulus with key press');
            break; % stop loop            
        end
        % this loop doesn't need to go that quickly to register keyboard
        %  presses
        pause(0.2);
    end
    
    % stop visual panels
    Panel_com('stop');
    
    disp('Stopped visual stimulus');
end