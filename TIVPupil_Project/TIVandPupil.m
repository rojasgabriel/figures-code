function [norm_averagedPupil, norm_pupil_by_session, flipped_pupil] = TIVandPupil(trialData, trialData_backup, ...
    temp4norm, Corre_Matrix, deleted)

global smooth_window mousename

if length(trialData.pupil_stim_window) == length(deleted)
    trialData.pupil_stim_window(deleted, :) = [];
    trialData.pupil_delay_window(deleted, :) = [];
end

if length(trialData.pupil_trial) == length(deleted)
    trialData.pupil_trial(deleted,:) = [];
end

%% Calculating
averagedPupil = cell(length(temp4norm), 1);
norm_averagedPupil = cell(length(temp4norm), 1);

for i = 1:length(trialData_backup)
    averagedPupil{i} = zeros(trialData_backup(i).nTrials, 1);
end

for i = 1:length(averagedPupil)
    averagedPupil{i} = mean(temp4norm{i}, 2, 'omitnan');
    norm_averagedPupil{i} = normalize(averagedPupil{i});
end

norm_pupil_by_session = norm_averagedPupil;
norm_averagedPupil = cell2mat(norm_averagedPupil);
norm_averagedPupil = smoothdata(norm_averagedPupil, 'movmean', smooth_window);
norm_averagedPupil(deleted) = [];
norm_averagedPupil(end) = [];
flipped_pupil = flip(norm_averagedPupil);


%% Plotting
figure(4);
plot(Corre_Matrix(:,3));
hold on
ylabel('Variance');
yyaxis right
plot(norm_averagedPupil);
ylabel('Normalized Pupil Diameter');
[sss, p_value] = corrcoef(norm_averagedPupil,Corre_Matrix(:,3));
% title(['Correlation between TIV & Pupil Diameter, ', ...
%     mousename, ' ', session_date, ', Smooth Window: ', num2str(smooth_window), ', Corrcoef: ',...
%     num2str(sss(1,2)), ', p value: ', num2str(p_value(1,2))]);
title(['Correlation between TIV & Pupil Diameter, ', ...
    mousename, ' ', 'Smooth Window: ', num2str(smooth_window), ', Corrcoef: ',...
    num2str(sss(1,2)), ', p value: ', num2str(p_value(1,2))]);
xlabel('Trial Number');
xlim([0 length(Corre_Matrix)])
set(gca,'box','off');
set(gca,'tickdir','out');
hold off

figure(5);
plot(Corre_Matrix(:,1));
hold on
ylabel('Correct Rate');
yyaxis right
plot(norm_averagedPupil);
ylabel('Normalized Pupil Diameter');
[sss, p_value] = corrcoef(norm_averagedPupil,Corre_Matrix(:,1));
title(['Correlation between Performance & Pupil Diameter, ', ...
    mousename, ' ', 'Smooth Window: ', num2str(smooth_window), ', Corrcoef: ',...
    num2str(sss(1,2)), ', p value: ', num2str(p_value(1,2))]);
xlabel('Trial Number');
xlim([0 length(Corre_Matrix)])
set(gca,'box','off');
set(gca,'tickdir','out');
hold off

figure;
plot(Corre_Matrix(:,3));
hold on
ylabel('Variance');
yyaxis right
plot(flipped_pupil);
ylabel('Normalized Pupil Diameter (flipped)');
[sss, p_value] = corrcoef(flipped_pupil,Corre_Matrix(:,3));
% title(['Correlation between TIV & Pupil Diameter, ', ...
%     mousename, ' ', session_date, ', Smooth Window: ', num2str(smooth_window), ', Corrcoef: ',...
%     num2str(sss(1,2)), ', p value: ', num2str(p_value(1,2))]);
title(['Correlation between TIV & Flipped Pupil Diameter, ', ...
    mousename, ' ', 'Smooth Window: ', num2str(smooth_window), ', Corrcoef: ',...
    num2str(sss(1,2)), ', p value: ', num2str(p_value(1,2))]);
xlabel('Trial Number');
xlim([0 length(Corre_Matrix)])
set(gca,'box','off');
set(gca,'tickdir','out');
hold off

figure;
plot(Corre_Matrix(:,1));
hold on
ylabel('Correct Rate');
yyaxis right
plot(flipped_pupil);
ylabel('Normalized Pupil Diameter (flipped)');
[sss, p_value] = corrcoef(flipped_pupil,Corre_Matrix(:,1));
title(['Correlation between Performance & Flipped Pupil Diameter, ', ...
    mousename, ' ', 'Smooth Window: ', num2str(smooth_window), ', Corrcoef: ',...
    num2str(sss(1,2)), ', p value: ', num2str(p_value(1,2))]);
xlabel('Trial Number');
xlim([0 length(Corre_Matrix)])
set(gca,'box','off');
set(gca,'tickdir','out');
hold off