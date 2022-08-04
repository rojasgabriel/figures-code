%% Individual_PupilAnalysis by Gabriel Rojas Bowe

% The following script is for extracting pose estimation behavioral data from 
% DeepLabCut (DLC), importing trial data from Joao Cuto's experiments, performing
% a linear regression analysis using task variables as factors, and assesing the relationship between
% Task-Independent Variance (TIV), Performance, and Pupil Diameter. The
% following functions are adaptations from Chaoqun Yin's MATLAB functions, as 
% well as some original functions by Gabriel Rojas Bowe. This was done as part of Gabriel's rotation
% project in the Churchland Lab in Spring 2022.

% To run the script, you only need to specify the lateralFile, bottomFile,
% mousename, h5filename, and smooth_window. There will be 3 figures that
% pop up: 
%    1) R squared across the trial for each DLC label
%    2) Correlation matrix for Correct Rate, Variance explained by task
%      variables, TIV, and Response Time
%    3) 4 plots showing the relationship between TIV, Performance, and averaged pupil diameter.
%      The upper two show the relationship between pupil diameter and
%      performance, while the bottom two show the relationship between pupil
%      diameter and TIV. The two on the left correspond to the averaged pupil
%      diameter throughout the whole trial, whereas the two on the right
%      correspond to the averaged pupil diameter only during the stimulus
%      window.

%% 1st: Import DLC data

mousename = 'JC072';
session_date = '20220310'; %format: YYYMMDD

lateralFile = 'JC072_20220310_142347_cam0_00000000DLC_resnet50_JC072Apr1shuffle1_200000.csv';
bottomFile = 'JC072_20220310_142347_cam1_00000000DLC_resnet50_JC072Apr6shuffle1_200000.csv';

[DLC_LateralNoLabelsData, DLC_BottomNoLabelsData] = ImportIndividualDLCSession(lateralFile, bottomFile, mousename);

%% 2nd: Load trial data from h5 file and plot trial difficulty

h5filename = 'JC072_20220310_142347_cam0_00000000.session_for_matlab.h5';
[trialData, aligned_frametimes, eventFrames] = LoadTrialDataFromH5(h5filename);
[b] = plotTrialDifficulty(trialData, mousename, session_date);

%% 3rd: Create DLC design matrix for linear regression

[events_time_lateral, events_time_bottom, endpoint, label_num, overall_PCAmatrix] = getDLC_designMatrix(aligned_frametimes, eventFrames, DLC_LateralNoLabelsData, DLC_BottomNoLabelsData);

%% 4th: Perform linear regression and TIV analyses

smooth_window = 50;
[R_squared, Residual, Fit_result, Corre_Matrix, averagedPupil] = LinearRegressionGRB(overall_PCAmatrix, endpoint, trialData, aligned_frametimes, smooth_window, session_date);
