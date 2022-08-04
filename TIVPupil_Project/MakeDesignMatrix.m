function [overall_PCAmatrix_backup, overall_PCAmatrix, trialData_backup, trialData, label_num,...
    temp4norm, endpoint] = MakeDesignMatrix(DLC_LateralNoLabelsData, DLC_BottomNoLabelsData,...
    aligned_frametimes, eventFrames, trialData)

endpoint = cell(4,1); % this and the following loop are for testing purposes only; I'm trying to concatenate the sessions together
for i = 1:size(DLC_LateralNoLabelsData, 1)
    endpoint{i} = 137;
end

label_num = cell(size(DLC_LateralNoLabelsData,1), 1);
overall_PCAmatrix = cell(size(DLC_LateralNoLabelsData,1), 1);

for i = 1:size(DLC_LateralNoLabelsData, 1)
    %endpoint{i} = min([events_time_lateral{i}(:,3)-events_time_lateral{i}(:,1); events_time_bottom{i}(:,3)-events_time_bottom{i}(:,1)]);
    label_num{i} = size(DLC_LateralNoLabelsData{i},2)/3 + size(DLC_BottomNoLabelsData{i},2)/3;
    overall_PCAmatrix{i} = zeros((length(aligned_frametimes{i}.trialstart_times)), endpoint{i}, 2, label_num{i}); % trialNum*timespan*(x&y coordinates)*labelNum (units are frames for timespan)

    for a = 1 : length(aligned_frametimes{i}.trialstart_times) %trial number
        lateral_stimOn = eventFrames{i}.stim_onsets_frames(a,1); 
        bottom_stimOn = eventFrames{i}.stim_onsets_frames(a,1);

        for b = 1 : endpoint{i} %label number
            lateral_frame_ind = lateral_stimOn + b;
            bottom_frame_ind = bottom_stimOn + b;

            for c = 1 : label_num{i}
                if c <= size(DLC_LateralNoLabelsData{i}, 2)/3
                    overall_PCAmatrix{i}(a,b,1,c) = DLC_LateralNoLabelsData{i}(lateral_frame_ind, c*3-2);
                    overall_PCAmatrix{i}(a,b,2,c) = DLC_LateralNoLabelsData{i}(lateral_frame_ind, c*3-1);
                else
                    overall_PCAmatrix{i}(a,b,1,c) = DLC_BottomNoLabelsData{i}(bottom_frame_ind, (c-14)*3-2);
                    overall_PCAmatrix{i}(a,b,2,c) = DLC_BottomNoLabelsData{i}(bottom_frame_ind, (c-14)*3-1);
                end
            end
        end
    end
end
clear a b c lateral_stimOn bottom_stimOn lateral_frame_ind bottom_frame_ind

overall_PCAmatrix_backup = overall_PCAmatrix;
overall_PCAmatrix = vertcat(overall_PCAmatrix{1}, overall_PCAmatrix{2}, overall_PCAmatrix{3}, overall_PCAmatrix{4});

% the following lines are pure shame and sloppyness -GRB
trialData = vertcat(trialData{1}, trialData{2}, trialData{3}, trialData{4});

correct_side = vertcat(trialData.correct_side);
pupil_diameter = vertcat(trialData.pupil_diameter);

temp4norm = cell(length(trialData), 1);
for i = 1:length(trialData)
    temp4norm{i} = trialData(i).pupil_trial(1:end, 1:endpoint{i});
end
pupil4norm = cell2mat(temp4norm);
pupil_trial = vertcat(pupil4norm);

pupil_stim_window = vertcat(trialData.pupil_stim_window);
pupil_delay_window = vertcat(trialData.pupil_delay_window);
stim_duration = vertcat(trialData.stim_duration);
stim_intensity = vertcat(trialData.stim_intensity);
choice = vertcat(trialData.choice);
rewarded = vertcat(trialData.rewarded);
noChoice = vertcat(trialData.noChoice);
nTrials = vertcat(trialData.nTrials);
trialData_backup = trialData;
trialData = struct('correct_side', {correct_side}, 'pupil_diameter', {pupil_diameter}, 'pupil_trial', {pupil_trial},...
    'pupil_stim_window', {pupil_stim_window}, 'pupil_delay_window', {pupil_delay_window}, 'stim_duration', {stim_duration},...
    'stim_intensity', {stim_intensity}, 'choice', {choice}, 'rewarded', {rewarded}, 'noChoice', {noChoice}, 'nTrials', {nTrials});