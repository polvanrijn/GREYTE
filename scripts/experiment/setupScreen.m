function exp = setupScreen(exp)
%SETUPSCREEN sets up the screen with the settings defined in the EXP
%variable

HideCursor;
%% Setup screen
PsychDefaultSetup(2); % Setup PTB with some default values
if exp.debugging && exp.host == 2
    exp.screen.size = [0 0 1200 800];
elseif exp.debugging == 0 && exp.host == 2
    exp.screen.size = [0 0 1920 1080];
end

% open screen
[exp.screen.w, exp.screen.wRect] = PsychImaging('OpenWindow', exp.screen.number, exp.color.white, exp.screen.size, 32, 2);
exp.screen.ifi = Screen('GetFlipInterval', exp.screen.w);% Query the frame duration
exp.screen.waitframes = 1; % Numer of frames to wait before re-drawing

% Query the maximum priority level
exp.screen.topPriorityLevel = MaxPriority(exp.screen.w);

%% Text settings
% calculate left offset
exp.screen.textOffset = exp.screen.textOffset * exp.screen.wRect(3);

% Set the text size
Screen('TextSize', exp.screen.w, exp.font.size);

 exp.screen.width = exp.screen.wRect(3);
exp.screen.height = exp.screen.wRect(4);
exp.screen.hCenter = exp.screen.width/2;
exp.screen.vCenter = exp.screen.height/2;

% Set the blend funciton for the screen
Screen('BlendFunction', exp.screen.w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

end