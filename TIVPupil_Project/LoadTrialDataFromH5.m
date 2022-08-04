%% 'LoadTrialDataFromH5' by Gabriel Rojas Bowe
% Load camera aligned trial data from h5 file. Made to work with Joao
% Cuto's trial structures. If more information is needed to be imported,
% refer to a Jupyter Notebook (currently in another folder) with a script for extracting more data onto
% the h5 file to be imported.

function [trialData, aligned_frametimes, eventFrames,b] = LoadTrialDataFromH5(h5filename, mousename, session_date)
% filename = 'JC072_20220307_110327.session_for_matlab.h5';

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
%stim_rates = h5read(h5filename, '/stim_rates');

clear h5filename

%% Get trial end frames

% TO-DO: get the duration of the last trial from the states variable

camera_framerate = mode(1./diff(frame_times));

trialframe_length = zeros(length(trialstart_times),1);
for itrial = 1:length(trialstart_times)-1
    trial_duration = trialstart_times(itrial+1)-trialstart_times(itrial);
    nframes_to_extract = floor(trial_duration*camera_framerate);
    trialframe_length(itrial,:) = nframes_to_extract; %doesn't include the last trial, is in frames
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
for itrial = 1:length(trialstart_times)-1
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

%% Get pupil data by trial

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

pupil_trial(nTrials, :) = [];
pupil_stimulus_window(nTrials, :) = [];
pupil_delay_window(nTrials, :) = [];

%% Create trial data structures

trialData = struct('correct_side', {correct_side}, 'pupil_diameter', {pupil_diameter}, 'pupil_trial', {pupil_trial}, 'pupil_stim_window', {pupil_stimulus_window}, 'pupil_delay_window', {pupil_delay_window}, 'stim_duration', {stim_duration}, 'stim_intensity', {stim_intensity}, 'choice', {choice}, 'rewarded', {rewarded}, 'noChoice', {noChoice}, 'nTrials', {nTrials});
aligned_frametimes = struct('frame_times', {frame_times}, 'reward_times', {reward_times}, 'stim_onsets', {stim_onsets}, 'trialstart_times', {trialstart_times}, 'timeout_times', {timeout_times}, 'response_times', {response_time});
eventFrames = struct('trialstart_frames', {trialstart_frames}, 'trialend_frames', {trialend_frames}, 'stim_onsets_frames', {stim_onsets_frames}, 'responseonset_frames', {responseonset_frames}, 'reward_frames', {reward_frames}, 'trialframe_length', {trialframe_length}, 'response2end_length', {response2end_length});

clear correct_side pupil_diameter pupil_trial pupil_stimulus_window pupil_delay_window stim_duration choice noChoice rewarded frame_times reward_times stim_onsets stim_onsets_frames stim_intensity reward_delivered trialframe_length reward_frames timeout_times trialstart_times trialstart_frames trialend_frames responseonset_frames response2end_length response_time
