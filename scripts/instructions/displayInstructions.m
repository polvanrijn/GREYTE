function exp = displayInstructions(exp)
%DISPLAYINSTRUCTIONS a loop to display all 
for instruction = 1:numel(exp.instr)
    WaitSecs(.15);
    inst = table2cell(exp.instr(instruction, 1));
    displayTextUntillClick(exp, exp.screen.w, inst{1})
end
end