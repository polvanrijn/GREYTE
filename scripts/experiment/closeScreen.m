function closeScreen(exp)
%CLOSESCREEN closes screen and shuts down eyetracker if it is enabled
Screen('CloseAll');
if exp.host == 2
    Eyelink('ShutDown');
end

end