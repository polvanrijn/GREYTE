function exp = setSettings()
%SETSETTINGS sets the default settings for the experiment.
% it uses a structure called EXP. It contains the 'levels' COLOR for colors,
% FONT for font settings (e.g. font sizes, line-height), SCREEN contains
% settings for the screen (e.g. left screen offset), KEY contains all
% settings for the keys, QUEST is used in the questionnaire, HOST is used
% for device specific settings


% colors
exp.color.white         = 1;
exp.color.black         = 0;

% fonts
exp.font.size           = 30; 
exp.font.family         = 'Garamond';
exp.font.color          = [103, 103, 103];
exp.font.lineHeight     = 5;
%exp.font.color          = exp.color.black;

% background
exp.screen.background   = exp.color.white;
exp.screen.textColor    = 0.6;
exp.screen.textOffset   = 0.05; % relative value, % of screen, 0.1 = 10%

% set settings for the confirmation box
exp.quest.conf.background = [128, 128, 128];
exp.quest.conf.padding    = [10 10 10 10];
exp.quest.conf.marginTop  = 20;

% screen
exp.screen.number       = max(Screen('Screens'));
[~, hostname] = system('hostname');

if contains(hostname, 'E6230')
    % test computer
    exp.host = 1;
    [width, height]=Screen('WindowSize',exp.screen.number);
    if width >= 1920 && height >= 1080
        exp.screen.size     = [0, 0, 1920, 1080];
    else
        exp.screen.size     = [30, 30, 1000 500]; % dummy mode only
    end
elseif contains(hostname, 'DESKTOP-MIM60AK')
    % eyetracker comp
    exp.host = 2;
else
    exp.host = 3;
end

if exp.host ~= 1
    exp.screen.size     = []; % full screen
end



% Enable unified mode of KbName, so KbName accepts identical key names on
% all operating systems:
KbName('UnifyKeyNames');
KbQueueCreate();
while KbCheck; end % Wait until all keys are released.
KbQueueStart();
exp.key.abort = KbName('DELETE'); % define abort key
exp.key.y = KbName('y'); % define y key

end