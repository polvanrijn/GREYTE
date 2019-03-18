function displayTextUntillClick(exp, window, string, minDuration)
%DISPLAYTEXTUNTILLCLICK displays a text untill the user clicks a mouse key
% EXP contains experiment information, e.g. key-settings
% WINDOW window pointer
% STRING is text that should be displayed
% MINDURATION is the minimal duration a text is displayed, default is 0
if nargin < 4
    minDuration = 0; % default
end
style =Screen('TextStyle', window);
Screen('TextFont', window, exp.font.family);
start = drawJustifiedText(window, string, 'left', exp.font.size, style, exp.font.lineHeight, 0.8, 0.75, exp.font.family, exp.font.color);
MousePress=0; %initializes flag to indicate no response
while    ( MousePress==0 && (GetSecs - start)>= minDuration) %checks for completion
    [~,~,buttons]=GetMouse();  %waits for a key-press
    MousePress=any(buttons); %sets to 1 if a button was pressed
    checkAbortKey(exp);
    WaitSecs(.01); % put in small interval to allow other system events
end

end