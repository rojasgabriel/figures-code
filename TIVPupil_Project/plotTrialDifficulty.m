function [b] = plotTrialDifficulty(trialData, mousename, session_date)

    easy_trials = length(find(or(trialData.stim_intensity == -30, trialData.stim_intensity == 30)));
    mediumeasy_trials = length(find(or(trialData.stim_intensity == -24, trialData.stim_intensity == 24)));
    mediumhard_trials = length(find(or(trialData.stim_intensity == -18, trialData.stim_intensity == 18)));
    hard_trials = length(find(or(trialData.stim_intensity == -12, trialData.stim_intensity == 12)));
    
    difficulty_spread = [easy_trials, mediumeasy_trials, mediumhard_trials, hard_trials];
    
    figure;
    b = bar(difficulty_spread);
    b.FaceColor = '#80B3FF';
    b.EdgeColor = '#80B3FF';
    set(gca, 'xticklabel', {'easy' 'medium-easy  ' '  medium-hard' 'hard'})
    title('Distribution of trial difficulty ')
    subtitle(['Trial n = ', num2str(trialData.nTrials), ', ',mousename, ' ', session_date])
