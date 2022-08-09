%% Getting deleted by session in process

all_trialNum = cell(size(overall_PCAmatrix_backup));
all_timespan = cell(size(overall_PCAmatrix_backup));
all_coordinate = cell(size(overall_PCAmatrix_backup));
all_labelNum = cell(size(overall_PCAmatrix_backup));

for i = 1:length(overall_PCAmatrix_backup)
    all_trialNum{i} = size(overall_PCAmatrix_backup{i}, 1);
    all_timespan{i} = size(overall_PCAmatrix_backup{i}, 2);
    all_coordinate{i} = size(overall_PCAmatrix_backup{i}, 3);
    all_labelNum{i} = size(overall_PCAmatrix_backup{i}, 4);
end
    