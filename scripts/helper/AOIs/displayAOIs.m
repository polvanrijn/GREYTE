function displayAOIs()
Screen('Preference', 'SkipSyncTests', 1);
KbName('UnifyKeyNames');
%DISPLAYAOIS displays the pregenerated images and the AOIs to check
%visually if there is any overlap between the AOIs and if the AOIs are
%positioned properly
% This script assumes a certain structure of the input table, you can
% compare the names in the csv-files and in this script
addpath(genpath('../../..'));
% define color arrays
red = [230, 25, 75];
green = [60, 180, 75];
yellow = [255, 225, 25];
blue = [0, 130, 200];
orange = [245, 130, 48];
purple = [145, 30, 180];
cyan = [70, 240, 240];
magenta = [240, 50, 230];
teal = [0, 128, 128];
navy= [0, 0, 128];
colorArray = {red,green, yellow, blue, orange, purple, cyan, magenta, teal, navy};

resolution = [0 0 1920 1080];

screenNumber = max(Screen('Screens'));

[window, ~] = PsychImaging('OpenWindow', screenNumber, 1, [], 32, 2);

spaceKey = KbName('space');
escapeKey = KbName('ESCAPE');
RestrictKeysForKbCheck([spaceKey escapeKey]);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

stimuli = readtable('../../../lists/list1.csv');
% go trough each sentence
for i = 1:size(stimuli, 1)
    paragraph_ID = stimuli{i,2};
    text_ID = stimuli{i,3};
    filename = stimuli{i,4}{1}
    condition = stimuli{i,5}{1}
    AOIs = readtable(['AOIs_', condition, '.txt']);
    AOIs = AOIs(AOIs.text == text_ID & AOIs.paragraph == paragraph_ID, :)
    % load image!
    imageTexture = Screen('MakeTexture', window, imread(['../../../images/', filename, '.bmp']));
    Screen('DrawTexture', window, imageTexture, [], [], 0); % display image!
    for w = 1:size(AOIs, 1)
        AOISize = AOIs{w, 4:end}; % size of the current AOI
        currentColor= [colorArray{mod(w, numel(colorArray))+1}, 128];
        Screen('FillRect', window, currentColor, AOISize)% draw AOI
    end
    
    Screen('Flip', window);
    WaitSecs(0.2);
    [~, keyCode, ~] =KbWait;
    if keyCode(KbName('ESCAPE')) == 1
        sca;
        disp('*** Experiment terminated ***');
        return
    elseif keyCode(KbName('SPACE')) == 1
        continue ; 
    else
        break;
    end
end
sca;
end
