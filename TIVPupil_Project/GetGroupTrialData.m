function [trialData, aligned_frametimes, eventFrames] = ...
    GetGroupTrialData(h5names, DLC_LateralNoLabelsData)
trialData = cell(size(DLC_LateralNoLabelsData,1), 1);
aligned_frametimes = cell(size(DLC_LateralNoLabelsData,1), 1);
eventFrames = cell(size(DLC_LateralNoLabelsData,1), 1);

for i = 1:size(DLC_LateralNoLabelsData, 1)
    h5filename = string(h5names{i});
    correct_side = h5read(h5filename, '/correct_side');
    choice = h5read(h5filename, '/choice');
    frame_times = h5read(h5filename, '/frame_times');
    pupil_diameter = h5read(h5filename, '/pupil_diameter');
    reward_times = h5read(h5filename, '/reward_times');
    stim_duration = h5read(h5filename, '/stim_duration');
    stim_onsets = h5read(h5filename, '/stim_onsets');
    timeout_times = h5read(h5filename, '/timeout_times');
    trialstart_times = h5read(h5filename, '/trialstart_times');
    rewarded = h5read(h5filename, '/rewarded');
    response_time = h5read(h5filename, '/response_time');
    stim_intensity = h5read(h5filename, '/stim_intensity');
    camera_framerate = mode(1./diff(frame_times));

    trialframe_length = zeros(length(trialstart_times),1);
    for itrial = 1:length(trialstart_times)-1
        trial_duration = trialstart_times(itrial+1)-trialstart_times(itrial);
        nframes_to_extract = floor(trial_duration*camera_framerate);
        trialframe_length(itrial,:) = nframes_to_extract; %doesn't include the last trial; is in frames
    end
    %have to find a way to label the frame which each trial ended without
    %going back to 0

    reward_frames = zeros(length(trialstart_times),1); % converting time to frames while importing for event markers
    trialstart_frames = zeros(length(trialstart_times),1); 
    stim_onsets_frames = zeros(length(trialstart_times),1);
    trialend_frames = zeros(length(trialstart_times),1);
    responseonset_frames = zeros(length(trialstart_times),1);
    response2end_length = zeros(length(trialstart_times),1); % length in frames between response period onset and trial end
    noChoice = zeros(length(trialstart_times),1); % flags as 1 the trials where no choice occurred
    for itrial = 1:length(trialstart_times)
        %reward_frames(itrial,:) = floor((reward_times(itrial)-trialstart_times(itrial,:))*camera_framerate);
        reward_frames(itrial,:) = floor(reward_times(itrial)*camera_framerate); % getting absolute values instead of relative to trial start such as in the above line
        trialstart_frames(itrial,:) = floor(trialstart_times(itrial)*camera_framerate);
        stim_onsets_frames(itrial,:) = floor(stim_onsets(itrial)*camera_framerate);
        trialend_frames(itrial,:) = trialstart_frames(itrial) + trialframe_length(itrial); %sometimes they end when the next trial starts, maybe an issue
        if choice(itrial,:) ~= 0
            noChoice(itrial,:) = 0;
        else
            noChoice(itrial,:) = 1;
        end
        responseonset_frames(itrial) = stim_onsets_frames(itrial) + 30;
        response2end_length(itrial) = trialend_frames(itrial) - responseonset_frames(itrial);
    end

    nTrials = length(trialstart_frames);
    clear on itrial nframes_to_extract trial_duration
    
    pupil_trial = zeros(length(trialstart_frames), mode(trialframe_length)); 
    pupil_stimulus_window = zeros(length(trialstart_frames), 30);
    pupil_delay_window = zeros(length(trialstart_frames), 30);
    for itrial = 1:length(trialstart_frames) 
        if itrial ~= length(trialstart_frames)
            pupil_trial(itrial) = pupil_diameter(trialstart_frames(itrial));
            for b = 1:mode(trialframe_length)
                pupil_trial(itrial,b+1) = pupil_diameter(trialstart_frames(itrial)+b);
            end
            pupil_stimulus_window(itrial, :) = pupil_trial(itrial, 10:39);
            pupil_delay_window(itrial, :) = pupil_trial(itrial, 40:69);
        end
    end
    
%     pupil_trial(nTrials, :) = [];
%     pupil_stimulus_window(nTrials, :) = [];
%     pupil_delay_window(nTrials, :) = [];
    
    clear itrial b camera_framerate h5filename
    
    trialData{i} = struct('correct_side', {correct_side}, 'pupil_diameter', {pupil_diameter}, 'pupil_trial', {pupil_trial}, 'pupil_stim_window', {pupil_stimulus_window}, 'pupil_delay_window', {pupil_delay_window}, 'stim_duration', {stim_duration}, 'stim_intensity', {stim_intensity}, 'choice', {choice}, 'rewarded', {rewarded}, 'noChoice', {noChoice}, 'nTrials', {nTrials});
    aligned_frametimes{i} = struct('frame_times', {frame_times}, 'reward_times', {reward_times}, 'stim_onsets', {stim_onsets}, 'trialstart_times', {trialstart_times}, 'timeout_times', {timeout_times}, 'response_times', {response_time});
    eventFrames{i} = struct('trialstart_frames', {trialstart_frames}, 'trialend_frames', {trialend_frames}, 'stim_onsets_frames', {stim_onsets_frames}, 'responseonset_frames', {responseonset_frames}, 'reward_frames', {reward_frames}, 'trialframe_length', {trialframe_length}, 'response2end_length', {response2end_length});

    clear correct_side pupil_diameter pupil_trial pupil_stimulus_window pupil_delay_window stim_duration choice noChoice rewarded frame_times reward_times stim_onsets stim_onsets_frames stim_intensity reward_delivered trialframe_length reward_frames timeout_times trialstart_times trialstart_frames trialend_frames responseonset_frames response2end_length response_time
    
    fprintf('%s\n', 'Trial data loaded')
end