addpath('../../settings')
try
    %% Settings
    exp = setSettings(); % use official settings file, to not get out of sync
    
    % position
    screenWidth                         = 1920;
    screenHeight                        = 1080;
    
    % Modifications:
    exp.font.lineHeight                 = 5;
    
    textLeftOffset                      = 2*exp.screen.textOffset*screenWidth; % in pixels
    imageDir                            = '../../../images';
    resolution                          = [screenWidth, screenHeight];
    
    filename_prefix                     = '';
    
    
    
    %% READ STIMULI
    % stimuli source
    fname = 'texts.json';
    val = jsondecode(fileread(fname));
    texts = struct2table(val.texts);
    
    %% READ NPs
    % Read NPs
    % UNCOMMENT IF YOU WANT TO USE XLSX INSTEAD
    raw = readtable('AOI_description.csv', 'Encoding', 'UTF-8');
    NPs = raw;
    %[num, txt, raw] = xlsread('AOI_description.xlsx', 2);
    %NPs = cell2table(raw);
    NPs(:,1) = [];
    %headers = NPs(1,:);
    %NPs(1,:) = [];
    %NPs.Properties.VariableNames = table2cell(headers);
    %NPs.start_idx = cell2mat(NPs.start_idx);
    %NPs.end_idx = cell2mat(NPs.end_idx);
    %NPs.start_token_idx = cell2mat(NPs.start_token_idx);
    %NPs.end_token_idx = cell2mat(NPs.end_token_idx);
    %NPs.text_ID = cell2mat(NPs.text_ID);
    %NPs.paragraph_idx = cell2mat(NPs.paragraph_idx);
    
    count = 0;
    
    for i = 1:numel(NPs.POS)
        count = count + numel(split(NPs.POS{i}, ', '));
    end
    
    AOIs_N = cell(1, count);
    AOIs_C = cell(1, count);
    AOIs_H = cell(1, count);
    
    indexes_lookup = zeros(count, 1);
    text_lookup = zeros(count, 1);
    paragraph_lookup = zeros(count, 1);
    count = 0;
    for i = 1:numel(NPs.POS)
        t = NPs.text_ID(i) + 1;
        p = NPs.paragraph_idx(i) + 1;
        for j = 1:numel(split(NPs.POS{i}, ', '))
            count = count + 1;
            indexes_lookup(count) =count;
            text_lookup(count) = t;
            paragraph_lookup(count) = p;
        end
    end
    writetable(table(indexes_lookup, text_lookup, paragraph_lookup), 'AOI_lookup.txt');
    
    %% CREATE STIMULI
    screenNumber = max(Screen('Screens'));
    
    % No sync tests needed for stimuli generation
    Screen('Preference','SkipSyncTests', 1);
    
    % open window
    [window, winRect] = Screen('OpenWindow', screenNumber, [255, 255, 255], [0 0 resolution], 32,2,[],[],[],[], [0 0 (resolution)], [0 0 resolution]);
    
    % Set font & text size
    Screen('TextSize', window, exp.font.size);
    Screen('TextFont', window, 'Garamond');
    
    % enable transparency
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    % Create image dir, if it doesn't exist yet
    if exist(imageDir, 'dir') < 1
        mkdir(imageDir);
    end
    gray =  [0, 0, 0, 153];
    % go trough each text
    word_count = 1; % Matlab starts counting at 1
    for t = 1:size(texts, 1)
        paragraphs = vertcat(texts(t,:).title, texts(t,:).paragraphs{:});
        for p = 1:numel(paragraphs)
            nouns = [];
            last_word_count = word_count;
            paragraph = paragraphs{p};
            
            %% NORMAL CONDITION
            [~, ~, ~, wordbounds] = DrawFormattedText(window, paragraph, 'justifytomax', textLeftOffset + exp.font.lineHeight*exp.font.size/2, gray, 99, 0, 0, exp.font.lineHeight, 0, [textLeftOffset textLeftOffset (resolution - textLeftOffset)]);
            words = split(paragraph, ' ');
            [word_limits, num_words] = computeAOIs(wordbounds, exp);
            word_count =+ num_words;
            
            relevant_AOIs = NPs(NPs.paragraph_idx == p-1 & NPs.text_ID == t-1, :);
            idx = cell2mat(cellfun(@(x)any(isnan(x)),relevant_AOIs.valid,'UniformOutput',false));
            invalid_AOIs = relevant_AOIs(~idx, :);
            currentColor = [230, 25, 75, 128];
            last_idx = find(~cellfun(@isempty,AOIs_N));
            if (isempty(last_idx))
                AOI_start_idx = 1;
            else
                AOI_start_idx = max(last_idx) +1;
            end
            [AOIs_N, n] = displayAOIs('N', invalid_AOIs, word_limits, window, AOIs_N, currentColor);
            nouns = [nouns n];
            
            valid_AOIs = relevant_AOIs(idx, :);
            [AOIs_N, n] = displayAOIs('N', valid_AOIs, word_limits, window, AOIs_N);
            nouns = [nouns n];
            
            last_idx = find(~cellfun(@isempty,AOIs_N));
            AOI_end_idx = max(last_idx);
            
            
            
            Screen('Flip', window);
            imwrite(Screen('GetImage', window), [imageDir, '/', filename_prefix 'N_t', num2str(t), '_p', num2str(p),'.bmp']);
            
            %% CAPITALIZED CONDITION
            no_nouns = setdiff(1:num_words, nouns);
            paragraph_split = split(paragraph, ' ');
            for i = nouns
                word = paragraph_split{i};
                word(1) = upper(word(1));
                paragraph_split{i} = word;
            end
            paragraph = join(paragraph_split, ' ');
            [~, ~, ~, wordbounds] = DrawFormattedText(window, paragraph{1}, 'justifytomax', textLeftOffset + exp.font.lineHeight*exp.font.size/2, gray, 99, 0, 0, exp.font.lineHeight, 0, [textLeftOffset textLeftOffset (resolution - textLeftOffset)]);
            [word_limits, ~] = computeAOIs(wordbounds, exp);
            [AOIs_C, ~] = displayAOIs('C', invalid_AOIs, word_limits, window, AOIs_C, currentColor);
            [AOIs_C, ~] = displayAOIs('C',valid_AOIs, word_limits, window, AOIs_C);
            Screen('Flip', window);
            imwrite(Screen('GetImage', window), [imageDir, '/', filename_prefix 'C_t', num2str(t), '_p', num2str(p),'.bmp']);
            
            %% HIGHLIGHTED CONDITION
            [~, ~, ~, wordbounds] = DrawFormattedText(window, paragraphs{p}, 'justifytomax', textLeftOffset + exp.font.lineHeight*exp.font.size/2, exp.color.black, 99, 0, 0, exp.font.lineHeight, 0, [textLeftOffset textLeftOffset (resolution - textLeftOffset)]);
            [word_limits, ~] = computeAOIs(wordbounds, exp);
            for n = no_nouns
                Screen('FillRect', window, [255, 255, 255, 102], word_limits{n});
            end
            [AOIs_H, ~] = displayAOIs('H',invalid_AOIs, word_limits, window, AOIs_H, currentColor);
            [AOIs_H, ~] = displayAOIs('H', valid_AOIs, word_limits, window, AOIs_H);
            
            Screen('Flip', window);
            imwrite(Screen('GetImage', window), [imageDir, '/', filename_prefix 'H_t', num2str(t), '_p', num2str(p),'.bmp']);
            
        end      
    end

    save('aois_N.mat', 'AOIs_N');
    save('aois_C.mat', 'AOIs_C');
    save('aois_H.mat', 'AOIs_H');
    sca;
    Screen('Preference','SkipSyncTests', 0); % reset synctest
    
    
    % show AOIs to test
    %displayAOIs(stimuli, AOIs, [0, 0, screenWidth, screenHeight]);
    
    
catch e
    sca;
    %closeScreen(exp);
    getReport(e)     % print cause
end

function [word_limits, num_words] = computeAOIs(wordbounds, exp)
num_words = size(wordbounds, 1);
word_limits = cell(1, num_words);
left = wordbounds(1,1); % will be corrected later in the process
top = wordbounds(1,2);
distance2NextWord = 0;
for w = 1:num_words
    width = wordbounds(w,3) -  wordbounds(w,1);
    if w < num_words
        distance2Lastword = distance2NextWord;
        distance2NextWord = wordbounds((w+1),1)-wordbounds(w,3);
    end
    
    last_word_on_line = w == num_words || wordbounds(w,2) ~= wordbounds(w + 1, 2);
    
    if last_word_on_line
        right = left + width + distance2Lastword;
    else
        right = left + width + (distance2NextWord/2) + (distance2Lastword/2);
    end
    
    y_border = ((exp.font.lineHeight * exp.font.size) - exp.font.size)/2;
    word_limits{w} = [left, top-y_border, right, top+y_border + exp.font.size];
    
    left = right;
    if w ~= num_words && last_word_on_line
        top = wordbounds(w+1, 2);
        left = wordbounds(1,1);
        distance2NextWord = 0;
    end
end
end

function [AOIs, nouns] = displayAOIs(condition, NPs, word_limits, window, AOIs, currentColor)
display_AOIs = 0;
nouns = [];
if ~exist('currentColor', 'var') || isempty(currentColor)
    keySet = {'DET, NOUN', 'NOUN', 'DET, ADJ, NOUN', 'NUM, NOUN', 'ADJ, NOUN', 'PRON, NOUN'};
    opacity = 128;
    valueSet = {[60, 180, 75, opacity], [240, 50, 230, opacity], [0, 130, 200, opacity], [245, 130, 48, opacity], [145, 30, 180, opacity],  [70, 240, 240, opacity]};
    colors = containers.Map(keySet,valueSet);
    backup = [255, 225, 25, opacity];
    custom_color = 0;
else
    custom_color = 1;
end

for a = 1:size(NPs,1)
    row = NPs(a,:);
    idx = row.start_token_idx:row.end_token_idx;
    
    disp(row);
    for i = 1 : numel(idx)
        
        if idx(i) > numel(word_limits)
            disp();
        end
        disp(row);
        POS = row.POS;
        if ~contains(POS, ', ')
            POS = {POS};
        else
            POS = split(POS, ', ');
        end
        disp(POS);
        
        cur_POS = POS{i};
        if cur_POS == "NOUN"
            nouns = [nouns idx(i)];
        end
        AOISize = word_limits{idx(i)}; % size of the current AOI
        
        last_idx = find(~cellfun(@isempty,AOIs));
        if (isempty(last_idx))
            AOI_idx = 1;
        else
            AOI_idx = max(last_idx) + 1;
        end
        
        type = strrep(row.POS, ', ', '_');
        type = type{1};
        AOIs{AOI_idx}.name = [cur_POS, '|' type, '|', condition];
        AOIs{AOI_idx}.size = AOISize;
        
        %disp([words{i}, '_', POS{i}, '_', num2str(idx(i)), '_', num2str(a)]);
        if ~custom_color
            POS = row.POS{:};
            if isKey(colors,POS)
                currentColor = colors(POS);
            else
                currentColor = backup;
            end
        end
        if display_AOIs
            Screen('FillRect', window, currentColor, AOISize)% draw AOI
        end
    end
end
end