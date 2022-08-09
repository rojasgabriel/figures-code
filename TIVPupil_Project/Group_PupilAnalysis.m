%% Group_PupilAnalysis by Gabriel Rojas Bowe

% The following script extracts behavioral data analyzed in DeepLabCut from
% multiple sessions by the same animal, as well as pupil recordings and task performance,
% and uses it to observe the relationships between performance,
% Task-Independent Variance (TIV), and pupil diameter.

% To-Do:
% 1) Make so that the code can get import session data from multiple
% animals
% 2) Add a function for psychometric curve analyses (PsychoCurves.m in
% progress)
% 3) Get deleted count for each session

clear, clc, close all

global mousename smooth_window block_len

mousename = 'JC047';
smooth_window = 50;
block_len = 10;

projectDir = 'C:\Users\Anne\figures-code\TIVPupil_Project'; %this is the path to the MATLAB dir with all the functions
animalDir = string(strcat('C:\Users\Anne\data\', mousename));
d = dir(animalDir);
d = d(~ismember({d(:).name},{'.','..'}));
session_figs = string(d(1).name);
figuresDir = string(strcat(animalDir, '\', session_figs, '\', 'figures'));
saved_dataDir = string(strcat(animalDir, '\', session_figs, '\', 'saved_data'));

%% Load session data
[mousename, lateral_csvnames, bottom_csvnames, h5names] = LoadAllSessions(mousename, projectDir, animalDir);

%% Import DLC data - make sure the number of labels is correct in the ImportDLC functions
[DLC_LateralData, DLC_BottomData, DLC_LateralNoLabelsData, DLC_BottomNoLabelsData] = ...
    ImportMultipleDLCSessions(lateral_csvnames, bottom_csvnames);

%if you're getting a fopen() error, make sure the data is in the MATLAB
%path

%% Get group trial data
[trialData, aligned_frametimes, eventFrames] = GetGroupTrialData(h5names, DLC_LateralNoLabelsData);

clear animalDir bottom_csvnames lateral_csvnames h5names

%% Align frames with event times
[events_time_lateral, events_time_bottom] = AlignFrameTimes(DLC_LateralNoLabelsData, aligned_frametimes, eventFrames);

%% Making design matrix for regression
[overall_PCAmatrix_backup, overall_PCAmatrix, trialData_backup, trialData, label_num,...
    temp4norm, endpoint] = MakeDesignMatrix(DLC_LateralNoLabelsData, DLC_BottomNoLabelsData,...
    aligned_frametimes, eventFrames, trialData);

%% Perform linear regression

global trialNum timespan coordinate labelNum

[trialNum, timespan, coordinate, labelNum] = size(overall_PCAmatrix);

% [group_info, factorTime] = GetFactors(overall_PCAmatrix, DLC_LateralNoLabelsData, ...
%     trialData);

[group_info, factorTime, overall_PCAmatrix] = GetFactors(overall_PCAmatrix, trialData);

[Fit_result, R_squared, Fitted, mdl, label_count, overall_PCAmatrix,...
    numTrialsDeleted, deleted] = GroupRegression(factorTime, overall_PCAmatrix,...
    group_info, endpoint);

%% Analyses

[Residual, Explained, CorrectRate, Corre_Matrix] = TIVandPerformance...
    (trialData, overall_PCAmatrix, Fitted, deleted, numTrialsDeleted);

[norm_averagedPupil, norm_pupil_by_session, flipped_pupil] = TIVandPupil(trialData, trialData_backup, ...
    temp4norm, Corre_Matrix, deleted);

[pupil_avg, performance_avg] = blockavg_no_overlap(norm_averagedPupil, CorrectRate);

%% Saving data into folders

filename = string(strcat(mousename, '_analyzed_data.mat'));
cd(saved_dataDir)
if isfile(filename)
    prompt = input('Do you want to overwrite the previously saved data for this animal? yes/no (use commas): ');
    if  strcmp('yes', prompt)
        disp('Overwriting data')
        save(filename);
        SaveAllFigures(figuresDir);
        cd(projectDir)
    else
        disp('Data not overwritten');
        cd(projectDir)
    end
else
    save(filename);
    SaveAllFigures(figuresDir);
    cd(projectDir)
    disp(string(strcat(mousename, ' data and figures saved to .mat file.')))
end


