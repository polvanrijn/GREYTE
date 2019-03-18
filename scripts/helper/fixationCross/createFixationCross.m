function exp = createFixationCross(exp)
%CREATEFIXATIONCROSS creates a fixation cross, that will used in each trail
Screen('TextSize', exp.screen.w, 60);
Screen('TextStyle', exp.screen.w, 2);

DrawFormattedText(exp.screen.w, '+', exp.screen.textOffset, 'center');
exp.screen.vbl = Screen('Flip', exp.screen.w);

exp.fixation=Screen('GetImage',  exp.screen.w);
Screen('TextSize', exp.screen.w, exp.font.size);
Screen('TextStyle', exp.screen.w, 0);

end

