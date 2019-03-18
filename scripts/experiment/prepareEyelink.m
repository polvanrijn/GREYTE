function exp = prepareEyelink(exp)
%PREPAREYELINK prepares the eyetracker for recording
if exp.host == 2
    edfFile = ['CAPT', num2str(exp.part.number)];
    
    % Provide Eyelink with details about the graphics environment
    % and perform some initializations
    exp.el=EyelinkInitDefaults(exp.screen.w);
    
    % Initialization of the connection with the Eyelink Gazetracker.
    % exit program if this fails.
    dummymode = 0;
    if ~EyelinkInit(dummymode)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end
    
    % the following code is used to check the version of the eye tracker
    % and version of the exp.host software
    sw_version = 0;
    
    [v vs]=Eyelink('GetTrackerVersion');
    
    % open file to record data to
    i = Eyelink('Openfile', edfFile);
    if i~=0
        fprintf('Cannot create EDF file ''%s'' ', edfFile);
        Eyelink('Shutdown');
        Screen('CloseAll');
        return;
    end
    
    Eyelink('command', 'add_file_preamble_text ''Recorded by EyelinkToolbox demo-experiment''');
    
    % SET UP TRACKER CONFIGURATION
    % Setting the proper recording resolution, proper calibration type,
    % as well as the data file content;
    Eyelink('Command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, exp.screen.width-1, exp.screen.height-1);
    Eyelink('Message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, exp.screen.width-1, exp.screen.height-1);
    Eyelink('Command', 'calibration_type = HV9'); % calibration type, may also be changed
    % set parser (conservative saccade thresholds)
    
    % set EDF file contents using the file_sample_data and
    % file-event_filter commands
    % set link data thtough link_sample_data and link_event_filter
    Eyelink('Command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
    Eyelink('Command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
    
    % check the software version
    % add "HTARGET" to record possible target data for EyeLink Remote
    if sw_version >=4
        Eyelink('Command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,HTARGET,GAZERES,STATUS,INPUT');
        Eyelink('Command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,HTARGET,STATUS,INPUT');
    else
        Eyelink('Command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT');
        Eyelink('Command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT');
    end
    
    % allow to use the big button on the eyelink gamepad to accept the
    % calibration/drift correction target
    Eyelink('Command', 'button_function 5 "accept_target_fixation"');
    
    
    % make sure we're still connected.
    if Eyelink('IsConnected')~=1 && dummymode == 0
        fprintf('not connected, clean up\n');
        Eyelink('Shutdown');
        Screen('CloseAll');
        return;
    end
    
    
    
    % STEP 6
    % Calibrate the eye tracker
    % setup the proper calibration foreground and background colors
    exp.el.backgroundcolour = exp.screen.background;
    exp.el.calibrationtargetcolour = exp.screen.textColor;
   
    % parameters are in frequency, volume, and duration
    % set the second value in each line to 0 to turn off the sound
    exp.el.cal_target_beep=[600 0 0.05];
    exp.el.drift_correction_target_beep=[600 0 0.05];
    exp.el.calibration_failed_beep=[400 0 0.25];
    exp.el.calibration_success_beep=[800 0 0.25];
    exp.el.drift_correction_failed_beep=[400 0 0.25];
    exp.el.drift_correction_success_beep=[800 0 0.25];
    exp.el.helptext = 'Een moment geduld';
    % you must call this function to apply the changes from above
    EyelinkUpdateDefaults(exp.el);
    
    % Hide the mouse cursor;
    Screen('HideCursorHelper', exp.screen.w);
end

end