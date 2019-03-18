function exp = trialLoop(exp, stimuli, useEyetracker, saveResults)
%TRIALLOOP is the experimental loop
% EXP experiment variable
% STIMULI table with all stimuli
% USEEYETRACKER if 1 uses eyetracker, if 0 no eyetracker
% SAVERESULTS if 1 results are saved locally, if 0 no results are saved

numTrials = size(stimuli,1);
nth_text = 0;

if useEyetracker
    [width, ~]=Screen('WindowSize', exp.screen.w);
    cal_size=round(exp.el.calibrationtargetsize/100*width);
    halfSize=cal_size/2;
    marginDriftLeft = 193 + halfSize;
    marginDriftTop = 240 + halfSize;
end

for trial = 1:numTrials
    exp.data.trialIdx = exp.data.trialIdx + 1;
    label = stimuli.filename{exp.data.trialIdx};
    condition =  stimuli.condition{exp.data.trialIdx};
    text_ID =  stimuli.text_ID(exp.data.trialIdx);
    paragraph_ID =  stimuli.paragraph_ID(exp.data.trialIdx);
    imgfile= char([label, '.bmp']);
    
    if mod(exp.data.trialIdx, 6) == 1
        nth_text = nth_text + 1;
        displayTextFor(exp, exp.screen.w, ['Begin van tekst ', num2str(nth_text)], 2);
    end
    
    switch condition
        case 'N'
            exp.aois = exp.AOIs_N;
        case 'H'
            exp.aois = exp.AOIs_H;
        case 'C'
            exp.aois = exp.AOIs_C;
        otherwise
            error('This cannot happen!')
    end
    
    if useEyetracker
        Eyelink('Message', 'START_TRIAL');
        Eyelink('Message', 'PARTICIPANT_CODE %s', exp.part.code); % participant code
        Eyelink('Message', 'SEQUENCEID %d', exp.data.trialIdx); % sequence ID
        Eyelink('Message', 'TEXT_ID %d', text_ID); % trial ID
        Eyelink('Message', 'PARAGRAPH_ID %d', paragraph_ID); % paragraph ID
        Eyelink('Message', 'COND %s', condition);
        
        % This supplies the title at the bottom of the eyetracker display
        Eyelink('Command', 'record_status_message "TRIAL %d/%d  %s"', exp.data.trialIdx, numTrials, imgfile);
        % Before recording, we place reference graphics on the exp.host display
        % Must be offline to draw to EyeLink screen
        Eyelink('Command', 'set_idle_mode');
        % clear tracker display and draw box at center
        Eyelink('Command', 'clear_screen 0')
        % Eyelink('command', 'draw_box %d %d %d %d 15', exp.screen.width/2-50, exp.screen.height/2-50, exp.screen.width/2+50, exp.screen.height/2+50);
        
        %transfer image to exp.host
        transferimginfo=imfinfo(['images/', imgfile]);
        
        fprintf('img file name is %s\n',transferimginfo.Filename);
        
        
        % image file should be 24bit or 32bit bitmap
        % parameters of ImageTransfer:
        % imagePath, xPosition, yPosition, width, height, trackerXPosition, trackerYPosition, xferoptions
        transferStatus =  Eyelink('ImageTransfer',transferimginfo.Filename,0,0,transferimginfo.Width,transferimginfo.Height,exp.screen.width/2-transferimginfo.Width/2 ,exp.screen.height/2-transferimginfo.Height/2,1);
        if transferStatus ~= 0
            fprintf('*****Image transfer Failed*****-------\n');
        end
        
        WaitSecs(0.1);
        
        % STEP 7.3
        % start recording eye position (preceded by a short pause so that
        % the tracker can finish the mode transition)
        % The paramerters for the 'StartRecording' call controls the
        % file_samples, file_events, link_samples, link_events availability
        Eyelink('Command', 'set_idle_mode');
        WaitSecs(0.05);
        
        EyelinkDoDriftCorrection(exp.el, marginDriftLeft, marginDriftTop);
        WaitSecs(0.05); % wait 50 ms
    end
    
    % This is our drawing loop
    imageTexture = Screen('MakeTexture', exp.screen.w, imread(['images/', imgfile]));
    Priority(exp.screen.topPriorityLevel);
    if useEyetracker
        checkAbortKey(exp);
        Eyelink('StartRecording');
        
        % record a few samples before we actually start displaying
        % otherwise you may lose a few msec of data
        WaitSecs(0.1);
    end
    
    Screen('DrawTexture', exp.screen.w, imageTexture, [], [], 0); % display image!
    
    tStart = Screen('Flip', exp.screen.w, exp.screen.vbl + (exp.screen.waitframes - 0.5) * exp.screen.ifi);
    
    if useEyetracker
        % write out a message to indicate the time of the picture onset
        % this message can be used to create an interest period in EyeLink
        % Data Viewer.
        
        Eyelink('Message', 'START_REC');
        % Send an integration message so that an image can be loaded as
        % overlay backgound when performing Data Viewer analysis.  This
        % message can be placed anywhere within the scope of a trial (i.e.,
        % after the 'TRIALID' message and before 'TRIAL_RESULT')
        % See "Protocol for EyeLink Data to Viewer Integration -> Image
        % Commands" section of the EyeLink Data Viewer User Manual.
        Eyelink('Message', '!V IMGLOAD CENTER %s %d %d', imgfile, exp.screen.width, exp.screen.height);
    end
    
    MousePress=0; %initializes flag to indicate no response
    while    ( MousePress==0) %checks for completion
        [~,~,buttons]=GetMouse();  %waits for a key-press
        MousePress=any(buttons); %sets to 1 if a button was pressed
        WaitSecs(.01); % put in small interval to allow other system events
    end
    
    tEnd = GetSecs;
    exp.screen.vbl = tStart;
    
    
    % Clear the display
    Screen('FillRect', exp.screen.w, exp.screen.background);
    Screen('Flip', exp.screen.w);
    rt = tEnd - tStart;
    if useEyetracker
        Eyelink('Message', 'END_REC');
        Eyelink('Message', ['RT_PARAGRAPH', num2str(paragraph_ID), ' ', num2str(rt)]);
        % adds 100 msec of data to catch final events
        WaitSecs(0.1);
        % stop the recording of eye-movements for the current trial
        Eyelink('StopRecording');
        
        % STEP 7.7
        % Send out necessary integration messages for data analysis
        % Send out interest area information for the trial
        % See "Protocol for EyeLink Data to Viewer Integration-> Interest
        % Area Commands" section of the EyeLink Data Viewer User Manual
        % IMPORTANT! Don't send too many messages in a very short period of
        % time or the EyeLink tracker may not be able to write them all
        % to the EDF file.
        % Consider adding a short delay every few messages.
        
        % Please note that  floor(A) is used to round A to the nearest
        % integers less than or equal to A
        
        WaitSecs(0.001);
        idx = exp.AOIlookupTable{exp.AOIlookupTable.text_lookup == text_ID & exp.AOIlookupTable.paragraph_lookup == paragraph_ID, 1};
        
        for w = 1: numel(idx)
            disp(idx(w))
            disp(w);
            word = exp.aois{idx(w)};
            if ischar(word.name) == 0
                word.name = join(word.name, '');
                word.name = word.name{1};
            end
            disp(word);
            Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 2, floor(word.size(1)), floor(word.size(2)), floor(word.size(3)), floor(word.size(4)), word.name);
        end
        
        % Send messages to report trial condition information
        % Each message may be a pair of trial condition variable and its
        % corresponding value follwing the '!V TRIAL_VAR' token message
        % See "Protocol for EyeLink Data to Viewer Integration-> Trial
        % Message Commands" section of the EyeLink Data Viewer User Manual
        WaitSecs(0.001);
        % Eyelink('Message', '!V TRIAL_VAR index %d', i)
        % Eyelink('Message', '!V TRIAL_VAR imgfile %s', imgfile)
        
        % STEP 7.8
        % Sending a 'TRIAL_RESULT' message to mark the end of a trial in
        % Data Viewer. This is different than the end of recording message
        % END that is logged when the trial recording ends. The viewer will
        % not parse any messages, events, or samples that exist in the data
        % file after this message.
        % Eyelink('Message', 'TRIAL_RESULT 0')
    end
    
    % Switch to low priority for after trial tasks
    Priority(0);
    
    if mod(exp.data.trialIdx, 6) == 0
        %% Present question
        questions = struct2table(exp.quest.questions{text_ID}.questions{1});
        question1 = questions{1,1}{1};
        options1 = questions{1,2}{1};
        correct1 = questions{1,3};
        
        SetMouse(exp.screen.hCenter, exp.screen.vCenter, exp.screen.w); % set Mouse to center
        answer1 = radioButton(question1, options1, exp.screen, exp.font, exp.quest.conf);
        
        
        question2 = questions{2,1}{1};
        options2 = questions{2,2}{1};
        correct2 = questions{2,3};
        
        SetMouse(exp.screen.hCenter, exp.screen.vCenter, exp.screen.w); % set Mouse to center
        answer2 = radioButton(question2, options2, exp.screen, exp.font, exp.quest.conf);
        
        if useEyetracker
            Eyelink('Message', ['TRIAL_RAW_ANSWER1 ', num2str(answer1)]);
            Eyelink('Message', ['TRIAL_ANSWER1 ', num2str(answer1 == correct1)]);
            Eyelink('Message', ['TRIAL_RAW_ANSWER2 ', num2str(answer2)]);
            Eyelink('Message', ['TRIAL_ANSWER2 ', num2str(answer2 == correct2)]);
            
        end
        displayTextFor(exp, exp.screen.w, ['Einde van tekst ', num2str(nth_text)], 2);
        
        if nth_text == 3
            for i = 0:59
                remaining = 60 - i;
                displayTextFor(exp, exp.screen.w, ['U heeft een pauze van minimaal één minuut (', num2str(remaining), ')'], 1);
            end
            displayTextUntillClick(exp, exp.screen.w, 'Klik op de muis als u verder wilt gaan');
           
            if useEyetracker
                EyelinkDoTrackerSetup(exp.el);
            end
        end
    end
    if saveResults
        %% Save results
        exp.data.labels(exp.data.trialIdx) = cellstr(label);
        exp.data.conditions(exp.data.trialIdx) = cellstr(condition);
        exp.data.rts(exp.data.trialIdx) = num2cell(rt);
        if mod(exp.data.trialIdx, 6) == 0
            exp.data.answer1(exp.data.trialIdx) = num2cell(answer1);
            exp.data.answer2(exp.data.trialIdx) = num2cell(answer2);
        end
    end
    if useEyetracker
        Eyelink('Message', 'END_TRIAL');
    end
    checkAbortKey(exp);
end % end trial loop

end