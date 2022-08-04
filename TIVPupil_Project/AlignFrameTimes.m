function [events_time_lateral, events_time_bottom] = ...
    AlignFrameTimes(DLC_LateralNoLabelsData, aligned_frametimes, eventFrames)
events_time_lateral = cell(size(DLC_LateralNoLabelsData,1), 1);
events_time_bottom = cell(size(DLC_LateralNoLabelsData,1), 1);

for i = 1:size(DLC_LateralNoLabelsData, 1)
    events_time_lateral{i} = zeros(length(aligned_frametimes{i}.trialstart_times), 3);
    events_time_bottom{i} = zeros(length(aligned_frametimes{i}.trialstart_times), 3);

    for a = 1:length(aligned_frametimes{i}.trialstart_times)
        events_time_lateral{i}(a,1) = eventFrames{i}.stim_onsets_frames(a,1);       % visual sitmulus on frame
        events_time_lateral{i}(a,2) = eventFrames{i}.reward_frames(a,1);     % reward being delivered
        events_time_lateral{i}(a,3) = eventFrames{i}.trialend_frames(a,1);   % trial end frame

        events_time_bottom{i}(a,1) = eventFrames{i}.stim_onsets_frames(a,1);
        events_time_bottom{i}(a,2) = eventFrames{i}.reward_frames(a,1);
        events_time_bottom{i}(a,3) = eventFrames{i}.trialend_frames(a,1);
    end

    events_time_lateral{i}(end,:) = []; % To-Do: see if this is still necessary or not
    events_time_bottom{i}(end,:) = [];
end