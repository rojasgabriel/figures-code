%% 'getDLC_designMatrix' by Gabriel Rojas Bowe
% modified from Chaoqun Yin's original 'Mice_DimensionReduction' function
%
% This function creates a 4D matrix that contains the following
% information: [trial number, timespan for each trial, number of
% coordinates, number of DLC labels]. This matrix is needed to run the
% linear regression afterwards.

function [events_time_lateral, events_time_bottom, endpoint, label_num, overall_PCAmatrix] = getDLC_designMatrix(aligned_frametimes, eventFrames, DLC_LateralNoLabelsData, DLC_BottomNoLabelsData)
%% 1st, aligning all frames to the stimulus-on time point
events_time_lateral = zeros(length(aligned_frametimes.trialstart_times), 3);
events_time_bottom = zeros(length(aligned_frametimes.trialstart_times), 3);

for a = 1:length(aligned_frametimes.trialstart_times)
    events_time_lateral(a,1) = eventFrames.stim_onsets_frames(a,1);       % visual sitmulus on frame
    events_time_lateral(a,2) = eventFrames.reward_frames(a,1);     % reward being delivered
    events_time_lateral(a,3) = eventFrames.trialend_frames(a,1);   % trial end frame
    
    events_time_bottom(a,1) = eventFrames.stim_onsets_frames(a,1);
    events_time_bottom(a,2) = eventFrames.reward_frames(a,1);
    events_time_bottom(a,3) = eventFrames.trialend_frames(a,1);
end

events_time_lateral(end,:) = [];
events_time_bottom(end,:) = [];

%% 2nd, making the matrix for PCA and doing overall PCA (last part not working)

endpoint = min([events_time_lateral(:,3)-events_time_lateral(:,1); events_time_bottom(:,3)-events_time_bottom(:,1)]);
label_num = size(DLC_LateralNoLabelsData,2)/3 + size(DLC_BottomNoLabelsData,2)/3;
overall_PCAmatrix = zeros((length(aligned_frametimes.trialstart_times)), endpoint, 2, label_num); % trialNum*timespan*(x&y coordinates)*labelNum (units are frames for timespan)

for a = 1 : length(aligned_frametimes.trialstart_times) %trial number
    lateral_stimOn = eventFrames.stim_onsets_frames(a,1); 
    bottom_stimOn = eventFrames.stim_onsets_frames(a,1);
    
    for b = 1 : endpoint %label number
        lateral_frame_ind = lateral_stimOn + b;
        bottom_frame_ind = bottom_stimOn + b;
        
        for c = 1 : label_num
            if c <= size(DLC_LateralNoLabelsData, 2)/3
                overall_PCAmatrix(a,b,1,c) = DLC_LateralNoLabelsData(lateral_frame_ind, c*3-2);
                overall_PCAmatrix(a,b,2,c) = DLC_LateralNoLabelsData(lateral_frame_ind, c*3-1);
            else
                overall_PCAmatrix(a,b,1,c) = DLC_BottomNoLabelsData(bottom_frame_ind, (c-14)*3-2);
                overall_PCAmatrix(a,b,2,c) = DLC_BottomNoLabelsData(bottom_frame_ind, (c-14)*3-1);
            end
        end
    end
end
clear a b c lateral_stimOn bottom_stimOn lateral_frame_ind bottom_frame_ind


% plot_index = [1,0,0,0]; %check what this is
% divide_mode = 'responseside';   % what're available: 'stimulus', 'opto', 'optotype', 'outcome', 'responseside', 'formeroutcome', 'formerresponseside', 'random'
% overall_PCAmatrix_backup = overall_PCAmatrix;
% overall_PCAmatrix = reshape(overall_PCAmatrix, [length(aligned_frametimes.trialstart_times)-1, endpoint*2*label_num]);
% overall_PCAmatrix = GroupData_MouseGRB(overall_PCAmatrix, divide_mode, trialData);
% trial_markers = overall_PCAmatrix(:,end);
% overall_PCAmatrix(:,end) = [];
% % 
% % 
% [PCA_bases,PCA_result,latent,tsquared,explained,~] = pca(overall_PCAmatrix);
% % 
% PCA_result = [PCA_result, trial_markers];
% DR_visualization_Mouse(PCA_result, explained, size(overall_PCAmatrix,1), 'movement', divide_mode, plot_index);
