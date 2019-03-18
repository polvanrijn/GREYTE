function displayTextFor(exp, window, string, duration)
%DISPLAYTEXTUNTILLCLICK displays a text untill the user clicks a mouse key
% EXP contains experiment information, e.g. key-settings
% WINDOW window pointer
% STRING is text that should be displayed
% URATION is the duration text is displayed in seconds, default is 0
style =Screen('TextStyle', window);
Screen('TextFont', window, exp.font.family);
drawJustifiedText(window, string, 'left', exp.font.size, style, exp.font.lineHeight, 0.8, 0.75, exp.font.family, exp.font.color);
WaitSecs(duration); % put in small interval to allow other system events

end