function exp = checkAbortKey(exp)
[ pressed, firstPress]=KbQueueCheck();

% If the user has pressed a key, then display its code number and name.
if pressed
    if firstPress(exp.key.abort)
        DrawFormattedText(exp.screen.w, 'Do you want to quit? Press "y" for yes', exp.screen.textOffset, 'center', exp.color.black);
        Screen('Flip', exp.screen.w);
        WaitSecs(0.2);
        [~, keyCode, ~] = KbWait();
        if exp.key.y == find(keyCode)
            error('You aborted the experiment');
        end
    end
end
end

