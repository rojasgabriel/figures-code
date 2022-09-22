function [Residual, Explained, CorrectRate, Corre_Matrix] = TIVandPerformance...
    (trialData, overall_PCAmatrix, Fitted, deleted, numTrialsDeleted)

global trialNum smooth_window mousename

trialData.nTrials = sum(trialData.nTrials);
borders = trialData.nTrials; % for plotting session borders
ttt = [0, cumsum(trialData.nTrials)];
for i = 1 : length(trialData.nTrials)
    borders(i) = borders(i) - sum(deleted((ttt(i)+1) : ttt(i+1)));
end


% Frame 1 to 59, removing the response window 
% because the animals would naturally get more variance when there's no reward
% Residual = overall_PCAmatrix - Fitted;
Residual = overall_PCAmatrix(:,1:59,:,:) - Fitted(:,1:59,:,:);
Residual_backup = Residual;

% ----------- Getting task-independent variance ---------------------------
% Residual = Residual(:, 1:14, :, :);
% Residual = reshape(Residual, [trialNum - sum(deleted), 14*coordinate*labelNum]);
Residual = reshape(Residual, (trialNum - sum(deleted)), []);
Residual = mean(abs(Residual), 2, 'omitnan');
Residual = smoothdata(Residual, 'movmean', smooth_window);
Residual(length(deleted) - length(numTrialsDeleted),:) = [];

% ----------- Getting task explained variance -----------------------------
mean_overall_PCAmatrix = mean(overall_PCAmatrix, 1);
mean_overall_PCAmatrix = repmat(mean_overall_PCAmatrix,[size(overall_PCAmatrix,1),1,1,1]);
SStot = overall_PCAmatrix - mean_overall_PCAmatrix;
SStot = SStot(:,1:59,:,:);
SStot = SStot.^2;
SSreg = Residual_backup.^2;
SStot = reshape(SStot, (trialNum - sum(deleted)), []);
SSreg = reshape(SSreg, (trialNum - sum(deleted)), []);
SStot = mean(SStot, 2);
SSreg = mean(SSreg, 2);
Explained = ones(trialNum - sum(deleted), 1) - SSreg./SStot;
Explained = smoothdata(Explained, 'movmean', smooth_window);
Explained(length(deleted) - length(numTrialsDeleted), :) = [];

% ----------- Getting reaction speed --------------------------------------
% aligned_frametimes.response_times(deleted) = [];
% ResponseTime = smoothdata(aligned_frametimes.response_times,  'movmean', smooth_window);
% ResponseTime(end,:) = [];

% ----------- Getting animal performance ----------------------------------
CorrectRate = trialData.rewarded;
CorrectRate(deleted) = [];
CorrectRate = smoothdata(CorrectRate, 'movmean', smooth_window);
CorrectRate(length(deleted) - length(numTrialsDeleted),:) = [];


% ----------- Calculating correlation & plotting --------------------------
% Corre_Matrix = [CorrectRate, Explained, Residual, ResponseTime];
Corre_Matrix = [CorrectRate, Explained, Residual];
%Corre_Matrix(end-smooth_window:end, :) = [];  % The first and last tens of trials are not so stabel
%Corre_Matrix(1:smooth_window, :) = [];


figure(2);
% heatmap({'CorrectRate', 'R Squared', 'Residual', 'Response Time'}, {'CorrectRate', 'R Squared', 'Residual', 'Response Time'}, corrcoef(Corre_Matrix));
heatmap({'CorrectRate', 'R Squared', 'Residual'}, {'CorrectRate', 'R Squared', 'Residual'}, corrcoef(Corre_Matrix));


figure(3);
plot(Corre_Matrix(:,3));
hold on
ylabel('Variance');
yyaxis right
plot(Corre_Matrix(:,1));
ylabel('Correct Rate');
ylim([0.5 1.0])
xlim([0 length(Corre_Matrix)])
[sss, p_value] = corrcoef(Corre_Matrix(:,1),Corre_Matrix(:,3));
title(['Correlation between Variance & Animal Performance,', mousename])
subtitle(['Smooth Window: ', num2str(smooth_window), ', Corrcoef: ', num2str(sss(1,2)),...
    ', p value: ', num2str(p_value(1,2))]);
xlabel('Trial Number');

borders = cumsum(borders) - smooth_window;
borders(end) = borders(end) - smooth_window;
if length(borders) > 1
    for i = 1 : (length(borders)-1) % plotting session borders
        line([borders(i) borders(i)], [0.5 1], 'Color','black','LineStyle','--');
    end
end
legend({'Task-Independent Variance', 'Correct Rate'});
set(gca,'box','off');
set(gca,'tickdir','out');
hold off

clear SStot SSreg mean_overall_PCAmatrix deleted_fur variableList i sss p_value