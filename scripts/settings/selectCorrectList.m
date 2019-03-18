function [participantNb, participantCode, currentList, stimuli] = selectCorrectList(participantNb,participantCode)
%SELECTCORRECTLIST selects the correct list based on the participant number
%and session id

if isempty(participantNb)
    participantNb = str2num(input('Participant number: ', 's')); % participant number
end
while isempty(participantNb)
    participantNb = str2num(input('Enter a valid participant code!: ', 's'));
end

if isempty(participantCode)
    participantCode = input('Particpant code ("LLDDLLDD"): ', 's');
end
while isempty(participantCode)
    participantCode = input('Error! Enter a participant code": ', 's');
end
currentList = ['list', num2str(participantNb)];
stimuli = readtable(['lists/', currentList, '.csv'], 'Encoding', 'UTF-8');
end