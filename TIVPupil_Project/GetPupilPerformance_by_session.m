function [deleted_cell, CorrectRate_cell, norm_averagedPupil_cell] = ...
    GetPupilPerformance_by_session(overall_PCAmatrix_backup, trialData_backup, temp4norm)
%% Obtain group_info variable

global smooth_window

trialNum_cell = cell(size(overall_PCAmatrix_backup));
timespan_cell = cell(size(overall_PCAmatrix_backup));
coordinate_cell = cell(size(overall_PCAmatrix_backup));
labelNum_cell = cell(size(overall_PCAmatrix_backup));

for i = 1:length(overall_PCAmatrix_backup)
    trialNum_cell{i} = size(overall_PCAmatrix_backup{i}, 1);
    timespan_cell{i} = size(overall_PCAmatrix_backup{i}, 2);
    coordinate_cell{i} = size(overall_PCAmatrix_backup{i}, 3);
    labelNum_cell{i} = size(overall_PCAmatrix_backup{i}, 4);
end

trialDataS1 = trialData_backup(1);
trialDataS2 = trialData_backup(2);
trialDataS3 = trialData_backup(3);
trialDataS4 = trialData_backup(4);

trialData_cell = cell([4 1]);
trialData_cell{1} = trialDataS1;
trialData_cell{2} = trialDataS2;
trialData_cell{3} = trialDataS3;
trialData_cell{4} = trialDataS4;

group_info_cell = cell([4 1]);
factorTime_cell = cell([4 1]);

for i = 1:length(trialData_cell)
    [group_info_cell{i}, factorTime_cell{i}] = GetFactors_by_session(overall_PCAmatrix_backup{i},...
        trialData_cell{i}, trialNum_cell{i}, timespan_cell{i}, coordinate_cell{i}, labelNum_cell{i});
end

%% Calculating deleted trials

deleted_cell = cell([4 1]);
numTrialsDeleted_cell = cell([4 1]);

for i = 1:length(trialData_cell)
    factorTime_cell{i}(:,:,1) = []; % removes the opto variable from factorTime
    % In terms of the complex influence of optogenetics, we don't use the opto trials here though we recorded opto variables
    % x = a1*stimulus + a2*outcome + a3*responseside + a4*interaction(trial n) + a5*formeroutcome + a6*formerresponseside + a7*interaction(trial n-1) + b
    % y is the same

    deleted_cell{i} = logical((group_info_cell{i}(:,4) == 0) + (group_info_cell{i}(:,6) == 0) + (group_info_cell{i}(:,1) ~= 0));
    factorTime_cell{i}(deleted_cell{i}, :, :) = [];
    overall_PCAmatrix_backup{i}(deleted_cell{i}, :, :, :) = [];
    numTrialsDeleted_cell{i} = find(deleted_cell{i} == 1);
end

%% Deleting trials from pupil and performance data

%Performance
CorrectRate_cell = cell([4 1]);

for i = 1:length(trialData_cell)
    CorrectRate_cell{i} = trialData_cell{i}.rewarded;
    CorrectRate_cell{i}(deleted_cell{i}) = [];
    CorrectRate_cell{i} = smoothdata(CorrectRate_cell{i}, 'movmean', smooth_window);
    CorrectRate_cell{i}(length(deleted_cell{i}) - length(numTrialsDeleted_cell{i}),:) = [];
end

%Pupil diameter
averagedPupil = cell(length(temp4norm), 1);
norm_averagedPupil = cell(length(temp4norm), 1);

for i = 1:length(trialData_backup)
    averagedPupil{i} = zeros(trialData_backup(i).nTrials, 1);
    averagedPupil{i} = mean(temp4norm{i}, 2, 'omitnan');
    norm_averagedPupil{i} = normalize(averagedPupil{i});
end

norm_averagedPupil_cell = norm_averagedPupil;
for i = 1:length(trialData_backup)
    norm_averagedPupil_cell{i}(deleted_cell{i}) = [];
    norm_averagedPupil_cell{i}(end) = [];
end

