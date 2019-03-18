function exp = saveResults(exp, a1, a2)
%SAVERESULTS saves local results and downloads eyetracker data when
%possible
% go to results dir
cd('results');

% save eyetracker file
if exp.host == 2
    % set to idle and close file
    Eyelink('Command', 'set_idle_mode');
    WaitSecs(0.5);
    Eyelink('CloseFile');
    
    % download data file
    try
        status=Eyelink('ReceiveFile');
        if status > 0
        end
        if 2==exist(edfFile, 'file')
            system(['edf2asc ', exp.part.code, '.edf ', exp.part.code, '.asc'])
        end
    catch
        fprintf('Problem receiving data file \n' );
    end
end

% save practice answers
answers = [a1;a2];
writetable(table(answers), [exp.part.code, '_practice.txt'])

% save reaction times
resultsMatrix = table(exp.data.labels, exp.data.conditions, exp.data.rts, exp.data.answer1, exp.data.answer2);
writetable(resultsMatrix, [exp.part.code, '.txt']); % save the results

end