function [exp, answer1, answer2] = practice(exp)
%PRACTICE a loop to display all 
for i = 1:numel(exp.practice.texts)
    WaitSecs(.15);
    text = exp.practice.texts(i);
    displayTextUntillClick(exp, exp.screen.w, text{1})
end
question1 = exp.practice.questions{1,1}{1};
options1 = exp.practice.questions{1,2}{1};
correct1 = exp.practice.questions{1,3};
SetMouse(exp.screen.hCenter, exp.screen.vCenter, exp.screen.w); % set Mouse to center
answer1 = radioButton(question1, options1, exp.screen, exp.font, exp.quest.conf);

if (answer1 ~= correct1)
    disp(answer1);
    disp(correct1);
    disp('Answer 1 FALSE');
end

question2 = exp.practice.questions{2,1}{1};
options2 = exp.practice.questions{2,2}{1};
correct2 = exp.practice.questions{2,3};
SetMouse(exp.screen.hCenter, exp.screen.vCenter, exp.screen.w); % set Mouse to center
answer2 = radioButton(question2, options2, exp.screen, exp.font, exp.quest.conf);

if (answer2 ~= correct2)
    disp(answer2);
    disp(correct2);
    disp('Answer 2 FALSE');
end
end