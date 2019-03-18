function experimentCAPT(participantNr, participantCode)
close all;
commandwindow;
addpath(genpath('scripts'));

Screen('Preference', 'SkipSyncTests', 0); % Peform sync tests

if nargin < 2
    participantCode = [];
end
if nargin < 1
    participantNr = [];
end
%% Settings
exp = setSettings(); % set settings for experiment
exp = loadTexts(exp); % load default questions for questionnaire
[exp.part.number, exp.part.code, exp.part.list, exp.stimuli] = selectCorrectList(participantNr, participantCode);

load('scripts/helper/AOIs/aois_N.mat'); % imports the pregenerated AOIs variable
load('scripts/helper/AOIs/aois_C.mat'); % imports the pregenerated AOIs variable
load('scripts/helper/AOIs/aois_H.mat'); % imports the pregenerated AOIs variable

exp.AOIs_N = AOIs_N;
exp.AOIs_C = AOIs_C;
exp.AOIs_H = AOIs_H;
exp.AOIlookupTable = readtable('scripts/helper/AOIs/AOI_lookup.txt');

exp.debugging = 0; % 1 = debugging, 0 = for real experiment

try
    HideCursor;
    exp.part.code
    %% Setup screen
    exp = setupScreen(exp);
    
    %% Condition Matrix
    exp = createCondMatrix(exp);
    
    %% Prepare fixation cross
    exp.screen.vbl = Screen('Flip', exp.screen.w);
    
    %% Prepare eyetracker
    exp = prepareEyelink(exp);
    
    %% display instructions
    exp = displayInstructions(exp);
    
    [exp, answer1, answer2] = practice(exp);
    
    %% trial loop
    exp.data.trialIdx = 0; % reset counter for trials
    displayTextFor(exp, exp.screen.w, 'Begin calibratie.', 2); % at least 30 secs
    
    EyelinkDoTrackerSetup(exp.el);
    exp = trialLoop(exp, exp.stimuli, 1, 1); % first block: with eyetracker, save results
    displayTextFor(exp, exp.screen.w, 'Einde van het experiment. Bedankt voor uw deelname!\nAlle gegevens zijn opgeslagen. U kunt de computer verlaten.', 30);
    %% save results
    exp = saveResults(exp, answer1, answer2);
    closeScreen(exp);
catch e
    closeScreen(exp);
    getReport(e)     % print cause
end