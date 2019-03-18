function exp = loadTexts(exp)
%LOADTEXTS loads all texts, except for the stimuli, used in the experiment
exp.quest.conf.text = 'Bevestigen';
afterPracTxt = readtable('text/afterPractice.csv', 'Encoding', 'UTF-8', 'Delimiter', 'tab');
exp.afterPrac = char(table2cell(afterPracTxt(1, 1)));
exp.goodbye = 'Einde van experiment. Bedankt voor uw deelname';

% define instructions
exp.instr = readtable('text/instructions.csv', 'Encoding', 'UTF-8', 'Delimiter', 'tab');

val = jsondecode(fileread('scripts/helper/AOIs/texts.json'));
texts = struct2table(val.texts);

exp.quest.questions = cell(size(texts, 1), 1);
for t = 1:size(texts, 1)
    exp.quest.questions{t} = texts(t,4);
end

exp.practice.texts = cell(6, 1);
exp.practice.texts{1} = val.practice.title;
for i = 2:6
    exp.practice.texts{i} = val.practice.paragraphs{i-1};
end
exp.practice.questions = struct2table(val.practice.questions);

end

