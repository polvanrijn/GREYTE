function selectedOption = radioButton(question, answerOptions, screen, font, confirmation)
%RADIOBUTTON creates a radio button with a question and asks the user to
%answer using the mouse click; the user must confirm his answer
% QUESTION the question that is being displayed
% ANSWEROPTIONS the options the used can pick
% SCREEN window pointer
% FONT you can specify a custom font, but it must be UTF-8 compatible
% CONFIRMATION structure containing information for the confirmation button

% set missing params
if nargin < 5
    confirmation.text = 'Confirm';
    confirmation.background = [128, 128, 128];
    confirmation.padding = [10 10 10 10];
    confimation.marginTop = 20;
end

font.lineHeight = 1.5;
Screen('TextColor', screen.w, 0.4);

% show arrow cursor
ShowCursor('Arrow');

if isempty(find (strcmp(listfonts,'Arial Unicode MS'),1))
    error('The font Arial Unicode MS must be installed. Please download it from https://github.com/aaronlidman/Toner-for-Tilemill/tree/master/toner4tilemill/fonts')
end


selectedOption = 0; % set default values
check = 10003;
square = 9109;

while 1
    if selectedOption == 0
        %% INITIAL DRAWING
        % calculate the top of the first textbox; the whole is always centered
        % vertically on the screen
        top = (screen.wRect(4) - ((numel(answerOptions) + 2)*font.size))/2;
        textBounds = cell(numel(answerOptions), 1);
        % draw question
        Screen('TextFont', screen.w, 'Garamond');
        DrawFormattedText(screen.w, question, screen.textOffset, top, font.color);
        oldTop = top;
        for i = 1:numel(answerOptions)
            top = top + (font.lineHeight *font.size);
            if ~IsWin
                Screen('TextFont', screen.w, 'Garamond');
                [~, ~, textBounds{i,1}] = DrawFormattedText(screen.w, [char(square), ' ', answerOptions{i}], screen.textOffset, oldTop, font.color);
            else
                Screen('TextFont', screen.w, 'Arial Unicode MS');
                Screen('DrawText', screen.w, square, screen.textOffset, oldTop, 0);
                Screen('TextFont', screen.w, 'Garamond');
                [~, ~, textBounds{i,1}] = DrawFormattedText(screen.w, ['    ', answerOptions{i}], screen.textOffset, top, font.color);
            end
            textBounds{i,1}(1) = 0;
            textBounds{i,1}(3) = screen.wRect(3);
            oldTop = top;
        end
        % flip screen
        Screen('Flip', screen.w);
        
        backupScreen=Screen('GetImage', screen.w);
        
        % calculate button width & height and margin to text
        buttonWidth = numel(confirmation.text) * font.size;
        margin = (font.size*font.lineHeight)/2;
        buttonTop = top + (font.lineHeight *font.size) + confirmation.marginTop;
        buttonPosition = [screen.textOffset, buttonTop, (screen.textOffset + buttonWidth), (margin*4+ buttonTop)];
    else
        %% Draw screen
        Screen('PutImage', screen.w, backupScreen); % restore old screen
        
        % draw check mark
        Screen('TextFont', screen.w, 'Arial Unicode MS');
        curRect = textBounds{selectedOption};
        if ~IsWin
            Screen('TextSize', screen.w, floor(font.size*1.25)); % increase font size
            position = (curRect(2) + margin);
            DrawFormattedText(screen.w, [char(check), ' '], screen.textOffset, position, font.color);
            Screen('TextSize', screen.w, font.size); % reset font size
        else
            position = curRect(2);
            Screen('DrawText', screen.w, check, screen.textOffset, position, 0);
        end

        % add confirmation button
        Screen('TextFont', screen.w, 'Garamond');
        Screen('FillRect', screen.w, rgbConverter([200 200 200]), buttonPosition);
        DrawFormattedText(screen.w, confirmation.text, 'center', buttonPosition(2) + 60, font.color, [], [],[],[],[], buttonPosition);
        Screen('Flip', screen.w);
    end
    %% Get clicks
    [~,x,y,~] = GetClicks(screen.w);
    
    %% Verify input
    % check if someone picked another option
    for i = 1:numel(answerOptions)
        if checkClick(x,y,textBounds{i})
            selectedOption = i;
        end
    end
    if selectedOption~= 0 && checkClick(x,y,buttonPosition)
        break;
    end
end

HideCursor;


% function selectedOption = radioButton(question, answerOptions, screen, font, confirmation)
% %RADIOBUTTON creates a radio button with a question and asks the user to
% %answer using the mouse click; the user must confirm his answer
% % QUESTION the question that is being displayed
% % ANSWEROPTIONS the options the used can pick
% % SCREEN window pointer
% % FONT you can specify a custom font, but it must be UTF-8 compatible
% % CONFIRMATION structure containing information for the confirmation button
% 
% % set missing params
% if nargin < 5
%     confirmation.text = 'Confirm';
%     confirmation.background = [128, 128, 128];
%     confirmation.padding = [10 10 10 10];
%     confimation.marginTop = 20;
% end
% 
% % show arrow cursor
% ShowCursor('Arrow');
% 
% if isempty(find (strcmp(listfonts,'Arial Unicode MS'),1))
%     error('The font Arial Unicode MS must be installed. Please download it from https://github.com/aaronlidman/Toner-for-Tilemill/tree/master/toner4tilemill/fonts')
% end
% Screen('TextFont', screen.w, 'Arial Unicode MS');
% 
% selectedOption = 0; % set default values
% check = 10003;
% square = 9109;
% 
% while 1
%     if selectedOption == 0
%         %% INITIAL DRAWING
%         % calculate the top of the first textbox; the whole is always centered
%         % vertically on the screen
%         top = (screen.wRect(4) - ((numel(answerOptions) + 2)*font.size))/2;
%         textBounds = cell(numel(answerOptions), 1);
%         % draw question
%         Screen('TextFont', screen.w, 'Garamond');
%         DrawFormattedText(screen.w, question, screen.textOffset, 0, font.color, [],[], 1);
%         oldTop = top;
%         for i = 1:numel(answerOptions)
%             top = top + (font.lineHeight *font.size);
%             if ~IsWin
%                 [~, ~, textBounds{i,1}] = DrawFormattedText(screen.w, [char(square), ' ', answerOptions{i}], screen.textOffset, oldTop, font.color);
%             else
%                 Screen('TextFont', screen.w, 'Arial Unicode MS');
%                 Screen('DrawText', screen.w, square, screen.textOffset, oldTop, 0);
%                 Screen('TextFont', screen.w, 'Garamond');
%                 [~, ~, textBounds{i,1}] = DrawFormattedText(screen.w, ['    ', answerOptions{i}], screen.textOffset, top, font.color);
%             end
%             textBounds{i,1}(1) = 0;
%             textBounds{i,1}(3) = screen.wRect(3);
%             oldTop = top;
%         end
%         % flip screen
%         Screen('Flip', screen.w);
%         
%         backupScreen=Screen('GetImage', screen.w);
%         
%         % calculate button width & height and margin to text
%         buttonWidth = numel(confirmation.text) * font.size;
%         margin = (font.size*font.lineHeight)/2;
%         buttonTop = top + (font.lineHeight *font.size) + confirmation.marginTop;
%         buttonPosition = [screen.textOffset, buttonTop, (screen.textOffset + buttonWidth), (margin*4+ buttonTop)];
%     else
%         %% Draw screen
%         Screen('PutImage', screen.w, backupScreen); % restore old screen
%         
%         % draw check mark
%         curRect = textBounds{selectedOption};
%         if ~IsWin
%             Screen('TextSize', screen.w, floor(font.size*1.25)); % increase font size
%             position = (curRect(2) + margin);
%             Screen('TextFont', screen.w, 'Arial Unicode MS');
%             DrawFormattedText(screen.w, [char(check), ' '], screen.textOffset, position, font.color);
%             Screen('TextSize', screen.w, font.size); % reset font size
%         else
%             position = curRect(2);
%             Screen('TextFont', screen.w, 'Arial Unicode MS');
%             Screen('DrawText', screen.w, check, screen.textOffset, position, 0);
%         end
% 
%         % add confirmation button
%         Screen('TextFont', screen.w, 'Garamond');
%         Screen('FillRect', screen.w, rgbConverter([200 200 200]), buttonPosition);
%         DrawFormattedText(screen.w, confirmation.text, 'center', buttonPosition(2) + 60, font.color, [], [],[],[],[], buttonPosition);
%         Screen('Flip', screen.w);
%     end
%     %% Get clicks
%     [~,x,y,~] = GetClicks(screen.w);
%     
%     %% Verify input
%     % check if someone picked another option
%     for i = 1:numel(answerOptions)
%         if checkClick(x,y,textBounds{i})
%             selectedOption = i;
%         end
%     end
%     if selectedOption~= 0 && checkClick(x,y,buttonPosition)
%         break;
%     end
% end
% 
% HideCursor;
