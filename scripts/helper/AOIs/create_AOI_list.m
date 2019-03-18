T = readtable('AOI_lookup.txt');
number = size(T,1);
conditions = {'aois_N', 'aois_C', 'aois_H'};
for c = 1:numel(conditions)
    condition = conditions{c};
    load([condition, '.mat']); % imports the pregenerated AOIs variable
    condition(1:3) = 'AOI';
    AOI = eval(condition);
    
    X1 = zeros (number, 1);
    X2 = zeros (number, 1);
    Y1 = zeros (number, 1);
    Y2 = zeros (number, 1);
    labels = cell (number, 1);
    
    for i = 1:number
        if iscell(AOI{i}.name)
            AOI{i}.name = join(AOI{i}.name, '');
        end
        labels{i} = AOI{i}.name;
        AOI_size = AOI{i}.size;
        X1(i) = AOI_size(1);
        Y1(i) = AOI_size(2);
        X2(i) = AOI_size(3);
        Y2(i) = AOI_size(4);
    end
    AOI_table = table(T.text_lookup, T.paragraph_lookup, labels, X1, Y1, X2, Y2);
    AOI_table.Properties.VariableNames = {'text', 'paragraph', 'label', 'X1', 'Y1', 'X2', 'Y2'};
    writetable(AOI_table, [condition, '.txt'])
end