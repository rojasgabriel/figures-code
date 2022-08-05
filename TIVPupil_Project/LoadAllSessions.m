function [mousename, lateral_csvnames, bottom_csvnames, h5names] = ...
    LoadAllSessions(mousename, projectDir, animalDir)

fprintf('%s\n', 'Loading sessions')

d = dir(animalDir);
d = d(~ismember({d(:).name},{'.','..'}));
sessionID = {d.name}.';

% Getting .csv file names
lateral_csvnames = cell(length(sessionID), 1);
bottom_csvnames = cell(length(sessionID), 1);
for i = 1:length(d)
    targetdir = string(strcat(animalDir, '\', sessionID(i), '\', 'dlc_analysis'));
    cd(targetdir)
    temp = dir('*.csv');
    csv_filenames = {temp.name}.'; % first value is cam_0 (lateral) and second value is cam_1 (bottom)
    lateral_csvnames(i) = csv_filenames(1); % 1 because cam_0 corresponds to lateral
    bottom_csvnames(i) = csv_filenames(2); % 2 because cam_1 corresponds to bottom
end

% Getting .h5 file names
h5names = cell(length(sessionID), 1);
for i = 1:length(d)
    targetdir = string(strcat(animalDir, '\', sessionID(i), '\', 'analysis'));
    cd(targetdir)
    temp = dir('*session_for_matlab.h5');
    h5names{i} = {temp.name}.';
end

clear temp csv_filenames targetdir sessionID d i
cd(projectDir)

fprintf('%s\n', 'Sessions loaded')