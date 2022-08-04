%% 'LinearRegressionGRB' by Gabriel Rojas Bowe
% Modified from Chaoqun Yin's original 'LinearRegression' function. Many
% things remain the same, except for those things that needed to be changed
% in order to work with Joao Cuto's dataset. Chaoqun Yin's original
% description for the function remains untouched below:

% Recruiting linear regression to get the residue (Task-Independent Vaiance, TIV) of Mouse face pattern
% Asumming only 6 factors influence animal face movement: 'opto', 'stimulus', 'outcome', 'responseside', 'formeroutcome', 'formerresponseside'
% These 5 factors could explain about 50% of the total variance

function [R_squared, Residual, Fit_result, Corre_Matrix, averagedPupil] = LinearRegressionGRB(overall_PCAmatrix, endpoint, trialData, aligned_frametimes, smooth_window, session_date)

global mouse_name
mousename = mouse_name;
[trialNum, timespan, coordinate, labelNum] = size(overall_PCAmatrix);

global Original_OrderIdx
original_OrderIdx = Original_OrderIdx;


%% Getting the factor information in each trial
temp = reshape(overall_PCAmatrix, [trialNum, timespan*coordinate*labelNum]);
variableList = {'optotype', 'stimulus', 'outcome', 'responseside', 'formeroutcome', 'formerresponseside'};
for a = 1 : length(variableList)
    temp = GroupData_MouseGRB(temp, variableList{a}, trialData{i});
end

group_info = temp(:, end-length(variableList)+1:end);
clear a temp


%% Getting the time of all factors
factorTime = zeros(trialNum, timespan, 8);    %8 task variables
% Optotype = 1 starts together with the stimulus. Usually it covers the first 0.5 s of the stimulus but depending on the session, it might stay on until the end of the delay period.
% Optotype = 2 starts at the end of the stimulus period (begin of delay period)
% Optotype = 3 starts at the end of the delay period (begin of response period)
% Optotype = 4 starts in the later part of the stimulus period and ends with the stimulus
% Optotype = 5 starts 0.5s before the stimulus and ends with stimulus onset
% rawdata.optoDur to check how long the stimulation lasted. In sessions where 5 types were used, it should always be 0.5s

if ~isfield(trialData, 'optoDur')
    disp('Please notice this session does not contain any optogenetic trials!');
    trialData.optoDur = [0,1];  % for running the following part.
end


if length(unique(trialData.optoDur(~isnan(trialData.optoDur)))) == 2
    for a = 1 : size(group_info, 1)
        % optotype (not using this -GRB)
        if group_info(a,1) == 1
            factorTime(a, 15:29, 1) = 1;
        elseif group_info(a,1) == 2
            factorTime(a, 45:59, 1) = 1;
        elseif group_info(a,1) == 3
            factorTime(a, 60:74, 1) = 1;
        elseif group_info(a,1) == 4
            factorTime(a, 30:44, 1) = 1;
        elseif group_info(a,1) == 5
            factorTime(a, 1:14, 1) = 1;
        end
        
        % stimulus 
        factorTime(a, 1:end, 2) = group_info(a, 2);
        
        % outcome
            %if group_info(a,2) == 1
        factorTime(a, 60:end, 3) = group_info(a, 3);
            %end
        
        % responseside
        factorTime(a, :, 4) = group_info(a,4);
        
        % interaction between responseside and outcome (trial n)
        if group_info(a,4) == 1 && group_info(a, 3) == 1
            factorTime(a,  60:end, 5) = 1;    % left choice & correct
        elseif group_info(a,4) == 2 && group_info(a, 3) == 1
            factorTime(a,  60:end, 5) = -1;    % right choice & correct
        elseif group_info(a,4) == 1 && group_info(a, 3) == 2
            factorTime(a,  60:end, 5) = 2;    % left choice & wrong
        elseif group_info(a,4) == 2 && group_info(a, 3) == 2
            factorTime(a,  60:end, 5) = -2;    % right choice & wrong
        end
        
        % formeroutcome
            %if group_info(a,4) == 1
        factorTime(a, :, 6) = group_info(a,5);
            %end
        
        %formerresponseside
        factorTime(a, :, 7) = group_info(a,6);
        
        % interaction between responside and outcome (trial n-1)
        if group_info(a,6) == 1 && group_info(a, 5) == 1
            factorTime(a, :, 8) = 1;   
        elseif group_info(a,6) == 2 && group_info(a, 5) == 1
            factorTime(a, :, 8) = -1;   
        elseif group_info(a,6) == 1 && group_info(a, 5) == 2
            factorTime(a, :, 8) = 2;  
        elseif group_info(a,6) == 2 && group_info(a, 5) == 2
            factorTime(a, :, 8) = -2;   
        end
        
    end
    
else
    fprintf('There are trials containing long opto stimulation.');
    return
end

clear a


%% Doing regression
factorTime(:,:,1) = [];
% In terms of the complex influence of optogenetics, we don't use the opto trials here though we recorded opto variables
% x = a1*stimulus + a2*outcome + a3*responseside + a4*interaction(trial n) + a5*formeroutcome + a6*formerresponseside + a7*interaction(trial n-1) + b
% y is the same

% removing no-reponses trials and opto trials in case they are outliers
trialIdx = 1 : size(overall_PCAmatrix, 1);
deleted = logical((group_info(:,4) == 0) + (group_info(:,6) == 0) + (group_info(:,1) ~= 0));
deleted(length(trialData.nTrials),:) = [];
numTrialsDeleted = find(deleted == 1);
factorTime(deleted, :, :) = [];
overall_PCAmatrix(deleted, :, :, :) = [];
trialIdx(deleted) = [];
%original_OrderIdx.OrderIdx(deleted) = [];


Fit_result = zeros(labelNum, coordinate, timespan, 8);  
R_squared = zeros(labelNum, coordinate, timespan);
Fitted = zeros(trialNum - sum(deleted), timespan, coordinate, labelNum);

for a = 1 : labelNum 
    for b = 1 : coordinate          
        for c = 1 : timespan      
            y = overall_PCAmatrix(:, c, b, a);
            X = reshape(factorTime(:, c, :), [], 7);
            mdl = fitlm(X, y);
            
            Fit_result(a,b,c,:) = mdl.Coefficients.Estimate;
            R_squared(a,b,c) = mdl.Rsquared.Adjusted;
            Fitted(:,c,b,a) = mdl.Fitted;
            
            clear y X mdl
        end
    end
end
clear a b c


plot_R = squeeze(mean(R_squared, 2));
figure(1);
hold on
for i = 1:30 %label numbers 1-30 to plot; if wanting to plot just one label, change i to be the ID of label of interest
    plot(plot_R(i, :));
end
ylabel('R squared');
ylim([0 1]);
xlim([0 endpoint]);
xline(1, '-', {'Stimulus Onset'})
xline(31, '-', {'Stimulus Offset'})
xline(60, '-', {'Response Onset'})
title(['The Averaged R squared for all labels, ', mousename, ' ', session_date]);
xlabel('Frame Number');
set(gca,'box','off');
set(gca,'tickdir','out');
hold off



%% 1st Analysis: The relation between task-independent variance, explained variance, reaction speed, and animal performance
borders = trialData.nTrials; % for plotting session borders
ttt = [0, cumsum(trialData.nTrials)];
for i = 1 : length(trialData.nTrials)
    borders(i) = borders(i) - sum(deleted((ttt(i)+1) : ttt(i+1)));
end

% smooth_window = 50;

% Frame 1 to 59, removing the response window 
% because the animals would naturally get more variance when there's no reward
% Residual = overall_PCAmatrix - Fitted;
Residual = overall_PCAmatrix(:,1:59,:,:) - Fitted(:,1:59,:,:);
Residual_backup = Residual;

% ----------- Getting task-independent variance ---------------------------
% Residual = Residual(:, 1:14, :, :);
% Residual = reshape(Residual, [trialNum - sum(deleted), 14*coordinate*labelNum]);
Residual = reshape(Residual, (trialNum - sum(deleted)), []);
Residual = mean(abs(Residual), 2);
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
aligned_frametimes.response_times(deleted) = [];
ResponseTime = smoothdata(aligned_frametimes.response_times,  'movmean', smooth_window);
ResponseTime(end,:) = [];

% ----------- Getting animal performance ----------------------------------
CorrectRate = trialData.rewarded;
CorrectRate(deleted) = [];

CorrectRate = smoothdata(CorrectRate, 'movmean', smooth_window);
CorrectRate(length(deleted) - length(numTrialsDeleted),:) = [];


% ----------- Calculating correlation & plotting --------------------------
Corre_Matrix = [CorrectRate, Explained, Residual, ResponseTime];
%Corre_Matrix(end-smooth_window:end, :) = [];  % The first and last tens of trials are not so stabel
%Corre_Matrix(1:smooth_window, :) = [];


figure(2);
heatmap({'CorrectRate', 'R Squared', 'Residual', 'Response Time'}, {'CorrectRate', 'R Squared', 'Residual', 'Response Time'}, corrcoef(Corre_Matrix));

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
title(['Correlation between Variance & Animal Performance, ', ...
    mousename, ' ', session_date, ', Smooth Window: ', num2str(smooth_window), ', Corrcoef: ', num2str(sss(1,2)), ', p value: ', num2str(p_value(1,2))]);
% legend({'R Squared', 'Task-Independent Variance', 'Correct Rate'});
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



%% 2nd Analsysis: The correlation between TIV and pupil diameter
if length(trialData.pupil_stim_window) == length(deleted)
    trialData.pupil_stim_window(deleted, :) = [];
    trialData.pupil_delay_window(deleted, :) = [];
end

if length(trialData.pupil_trial) == length(deleted)
    trialData.pupil_trial(deleted,:) = [];
end

%averagedPupil_stim = sum(diff(cell2mat(trialData.pupil_stim_window),1), 1); 
% averagedPupil_stim = nanmean(cell2mat(fillPupil.StimuWindow), 1); 
% Usually the averaged pupil diameters are pretty simialr in stimulus and delay windows
% averagedPupil_delay = nanmean(cell2mat(fillPupil.DelayWindow), 1);
% averagedPupil_stim = mean(trialData.pupil_stim_window, 2, 'omitnan');
% averagedPupil_delay = mean(trialData.pupil_delay_window, 2, 'omitnan');
averagedPupil = mean(trialData.pupil_trial, 2, 'omitnan');
maxPupil = max(averagedPupil);
norm_averagedPupil = zeros(size(averagedPupil));
for itrial = 1:length(averagedPupil)
    norm_averagedPupil(itrial) = averagedPupil(itrial)/maxPupil;
end

% averagedPupil_stim = smooth(averagedPupil_stim, smooth_window);
% averagedPupil_delay = smooth(averagedPupil_delay, smooth_window);
norm_averagedPupil = smooth(averagedPupil, smooth_window);

% averagedPupil_stim(end-smooth_window:end, :) = [];
% averagedPupil_stim(1:smooth_window, :) = [];
% averagedPupil_delay(end-smooth_window:end, :) = [];
% averagedPupil_delay(1:smooth_window, :) = [];
% norm_averagedPupil(end-smooth_window:end, :) = [];
% norm_averagedPupil(1:smooth_window, :) = [];

figure(4);
plot(Corre_Matrix(:,3));
hold on
ylabel('Variance');
yyaxis right
plot(norm_averagedPupil);
ylabel('Normalized Pupil Diameter');
[sss, p_value] = corrcoef(norm_averagedPupil,Corre_Matrix(:,3));
title(['Correlation between TIV & Pupil Diameter, ', ...
    mousename, ' ', session_date, ', Smooth Window: ', num2str(smooth_window), ', Corrcoef: ', num2str(sss(1,2)), ', p value: ', num2str(p_value(1,2))]);
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
    mousename, ' ', session_date, ', Smooth Window: ', num2str(smooth_window), ', Corrcoef: ', num2str(sss(1,2)), ', p value: ', num2str(p_value(1,2))]);
xlabel('Trial Number');
xlim([0 length(Corre_Matrix)])
set(gca,'box','off');
set(gca,'tickdir','out');
hold off


% %% 3rd Analsysis: Looking into the task engagement of low/high condition-indepdent variance trials
% trialIdx(1 : smooth_window) = [];
% trialIdx(end-smooth_window : end) = [];
% Residual(1 : smooth_window) = [];
% Residual(end-smooth_window : end) = [];
% original_OrderIdx.OrderIdx(1 : smooth_window) = [];
% original_OrderIdx.OrderIdx(end-smooth_window : end) = [];
% 
% [B, sortOrder] = sort(Residual);
% 
% Group_LowVariance = sortOrder(1 : floor(length(B)/3));
% Group_HighVariance = sortOrder((end - floor(length(B)/3)+1) : end);
% 
% [original_OrderIdx] =  TrialSorting(original_OrderIdx, Group_LowVariance, Group_HighVariance);
% original_OrderIdx.SmoothWindow = smooth_window;
% Original_OrderIdx = original_OrderIdx;
% 
% Group_LowVariance = trialIdx(Group_LowVariance);    % after this step, you will get the raw_data idx of trials with low/high condition-independetn variance
% Group_HighVariance = trialIdx(Group_HighVariance);
% 
% 
% % To look at animal's engagement, we'll analyze how reward and trial
% % history affect animal's choice in current trial.
% % The presumption here is that the animal relied more on choice and reward history in unengaged trials. 
% % Here, we use the choice and reward history from trial n-1 to trial n-4 (The last 4 choices, the last 4 trials' reward outcome).
% % Logistic regression is used here.
% 
% [LM_Low, C_Low, LM_High, C_High] = MatrixforLogisticReg(trialData, Group_LowVariance, Group_HighVariance);
% [Weights_Low, dev_Low, stats_Low] = mnrfit(LM_Low, C_Low);
% [Weights_High, dev_High, stats_High] = mnrfit(LM_High, C_High);
% 
% % Signi_Low = strings(1,10);
% % Signi_High = strings(1,10);
% % Signi_Low(stats_Low.p<=0.05) = "*";
% % Signi_Low(stats_Low.p<=0.01) = "**";
% % Signi_Low(stats_Low.p<=0.001) = "***";
% % Signi_Low(stats_Low.p>0.05) = "none";
% % Signi_High(stats_High.p<=0.05) = "*";
% % Signi_High(stats_High.p<=0.01) = "**";
% % Signi_High(stats_High.p<=0.001) = "***";
% % Signi_High(stats_High.p>0.05) = "none";
% 
% figure;
% b = bar([Weights_Low,Weights_High]);
% % text(b(1).XData,b(1).YData,Signi_Low);
% % text(b(2).XData,b(2).YData,Signi_High);
% set(gca,'xtick',[1:10],'xticklabel',{'Intercept','Stimulus','Choice n-1','Choice n-2','Choice n-3','Choice n-4','Reward n-1','Reward n-2','Reward n-3','Reward n-4'});
% legend({'Low Cndition-independent Variance', 'High Cndition-independent Variance'});
% ylabel('Weights');
% title(['Logistic Regressin Coefficient, ', mousename]);
% set(gca,'box','off')
% set(gca,'tickdir','out')
% hold off
% 
% clear LM_Low C_Low LM_High C_High Weights_Low Weights_High dev_Low dev_High stats_Low stats_High B sortOrder trialIdx

end








% %% Auxillary functions
% %%
% function [Logistic_matrix_Low, Choice_Low, Logistic_matrix_High, Choice_High] = MatrixforLogisticReg(raw_data, Group_LowVariance, Group_HighVariance)
% 
% Logistic_matrix_Low = nan(size(Group_LowVariance,2), 9);
% Choice_Low = nan(size(Group_LowVariance,2), 1);
% Logistic_matrix_High = nan(size(Group_HighVariance,2), 9);
% Choice_High = nan(size(Group_HighVariance,2), 1);
% 
% 
% for a = 1 : length(Group_LowVariance)
%     Choice_Low(a) = raw_data.ResponseSide(Group_LowVariance(a));
%     
%     Logistic_matrix_Low(a, 1) = raw_data.CorrectSide(Group_LowVariance(a));
%     Logistic_matrix_Low(a, 2) = raw_data.ResponseSide(Group_LowVariance(a)-1);
%     Logistic_matrix_Low(a, 3) = raw_data.ResponseSide(Group_LowVariance(a)-2);
%     Logistic_matrix_Low(a, 4) = raw_data.ResponseSide(Group_LowVariance(a)-3);
%     Logistic_matrix_Low(a, 5) = raw_data.ResponseSide(Group_LowVariance(a)-4);
%     
%     % for reward history, I assume right-correct is equal to left-wrong
%     if raw_data.ResponseSide(Group_LowVariance(a)-1) == 1 && raw_data.Rewarded(Group_LowVariance(a)-1) == 1
%         Logistic_matrix_Low(a, 6) = 1;
%     elseif raw_data.ResponseSide(Group_LowVariance(a)-1) == 2 && raw_data.Rewarded(Group_LowVariance(a)-1) == 0
%         Logistic_matrix_Low(a, 6) = 1;
%     elseif raw_data.ResponseSide(Group_LowVariance(a)-1) == 2 && raw_data.Rewarded(Group_LowVariance(a)-1) == 1
%         Logistic_matrix_Low(a, 6) = 2;
%     elseif raw_data.ResponseSide(Group_LowVariance(a)-1) == 1 && raw_data.Rewarded(Group_LowVariance(a)-1) == 0
%         Logistic_matrix_Low(a, 6) = 2;
%     end
%     
%     if raw_data.ResponseSide(Group_LowVariance(a)-2) == 1 && raw_data.Rewarded(Group_LowVariance(a)-2) == 1
%         Logistic_matrix_Low(a, 7) = 1;
%     elseif raw_data.ResponseSide(Group_LowVariance(a)-2) == 2 && raw_data.Rewarded(Group_LowVariance(a)-2) == 0
%         Logistic_matrix_Low(a, 7) = 1;
%     elseif raw_data.ResponseSide(Group_LowVariance(a)-2) == 2 && raw_data.Rewarded(Group_LowVariance(a)-2) == 1
%         Logistic_matrix_Low(a, 7) = 2;
%     elseif raw_data.ResponseSide(Group_LowVariance(a)-2) == 1 && raw_data.Rewarded(Group_LowVariance(a)-2) == 0
%         Logistic_matrix_Low(a, 7) = 2;
%     end
%     
%     if raw_data.ResponseSide(Group_LowVariance(a)-3) == 1 && raw_data.Rewarded(Group_LowVariance(a)-3) == 1
%         Logistic_matrix_Low(a, 8) = 1;
%     elseif raw_data.ResponseSide(Group_LowVariance(a)-3) == 2 && raw_data.Rewarded(Group_LowVariance(a)-3) == 0
%         Logistic_matrix_Low(a, 8) = 1;
%     elseif raw_data.ResponseSide(Group_LowVariance(a)-3) == 2 && raw_data.Rewarded(Group_LowVariance(a)-3) == 1
%         Logistic_matrix_Low(a, 8) = 2;
%     elseif raw_data.ResponseSide(Group_LowVariance(a)-3) == 1 && raw_data.Rewarded(Group_LowVariance(a)-3) == 0
%         Logistic_matrix_Low(a, 8) = 2;
%     end
%     
%     if raw_data.ResponseSide(Group_LowVariance(a)-4) == 1 && raw_data.Rewarded(Group_LowVariance(a)-4) == 1
%         Logistic_matrix_Low(a, 9) = 1;
%     elseif raw_data.ResponseSide(Group_LowVariance(a)-4) == 2 && raw_data.Rewarded(Group_LowVariance(a)-4) == 0
%         Logistic_matrix_Low(a, 9) = 1;
%     elseif raw_data.ResponseSide(Group_LowVariance(a)-4) == 2 && raw_data.Rewarded(Group_LowVariance(a)-4) == 1
%         Logistic_matrix_Low(a, 9) = 2;
%     elseif raw_data.ResponseSide(Group_LowVariance(a)-4) == 1 && raw_data.Rewarded(Group_LowVariance(a)-4) == 0
%         Logistic_matrix_Low(a, 9) = 2;
%     end
%     
% end
% 
% for a = 1 : length(Group_HighVariance)
%     Choice_High(a) = raw_data.ResponseSide(Group_HighVariance(a));
%     
%     Logistic_matrix_High(a, 1) = raw_data.CorrectSide(Group_HighVariance(a));
%     Logistic_matrix_High(a, 2) = raw_data.ResponseSide(Group_HighVariance(a)-1);
%     Logistic_matrix_High(a, 3) = raw_data.ResponseSide(Group_HighVariance(a)-2);
%     Logistic_matrix_High(a, 4) = raw_data.ResponseSide(Group_HighVariance(a)-3);
%     Logistic_matrix_High(a, 5) = raw_data.ResponseSide(Group_HighVariance(a)-4);
%     
%     % for reward history, I assume right-correct is equal to left-wrong
%     if raw_data.ResponseSide(Group_HighVariance(a)-1) == 1 && raw_data.Rewarded(Group_HighVariance(a)-1) == 1
%         Logistic_matrix_High(a, 6) = 1;
%     elseif raw_data.ResponseSide(Group_HighVariance(a)-1) == 2 && raw_data.Rewarded(Group_HighVariance(a)-1) == 0
%         Logistic_matrix_High(a, 6) = 1;
%     elseif raw_data.ResponseSide(Group_HighVariance(a)-1) == 2 && raw_data.Rewarded(Group_HighVariance(a)-1) == 1
%         Logistic_matrix_High(a, 6) = 2;
%     elseif raw_data.ResponseSide(Group_HighVariance(a)-1) == 1 && raw_data.Rewarded(Group_HighVariance(a)-1) == 0
%         Logistic_matrix_High(a, 6) = 2;
%     end
%     
%     if raw_data.ResponseSide(Group_HighVariance(a)-2) == 1 && raw_data.Rewarded(Group_HighVariance(a)-2) == 1
%         Logistic_matrix_High(a, 7) = 1;
%     elseif raw_data.ResponseSide(Group_HighVariance(a)-2) == 2 && raw_data.Rewarded(Group_HighVariance(a)-2) == 0
%         Logistic_matrix_High(a, 7) = 1;
%     elseif raw_data.ResponseSide(Group_HighVariance(a)-2) == 2 && raw_data.Rewarded(Group_HighVariance(a)-2) == 1
%         Logistic_matrix_High(a, 7) = 2;
%     elseif raw_data.ResponseSide(Group_HighVariance(a)-2) == 1 && raw_data.Rewarded(Group_HighVariance(a)-2) == 0
%         Logistic_matrix_High(a, 7) = 2;
%     end
%     
%     if raw_data.ResponseSide(Group_HighVariance(a)-3) == 1 && raw_data.Rewarded(Group_HighVariance(a)-3) == 1
%         Logistic_matrix_High(a, 8) = 1;
%     elseif raw_data.ResponseSide(Group_HighVariance(a)-3) == 2 && raw_data.Rewarded(Group_HighVariance(a)-3) == 0
%         Logistic_matrix_High(a, 8) = 1;
%     elseif raw_data.ResponseSide(Group_HighVariance(a)-3) == 2 && raw_data.Rewarded(Group_HighVariance(a)-3) == 1
%         Logistic_matrix_High(a, 8) = 2;
%     elseif raw_data.ResponseSide(Group_HighVariance(a)-3) == 1 && raw_data.Rewarded(Group_HighVariance(a)-3) == 0
%         Logistic_matrix_High(a, 8) = 2;
%     end
%     
%     if raw_data.ResponseSide(Group_HighVariance(a)-4) == 1 && raw_data.Rewarded(Group_HighVariance(a)-4) == 1
%         Logistic_matrix_High(a, 9) = 1;
%     elseif raw_data.ResponseSide(Group_HighVariance(a)-4) == 2 && raw_data.Rewarded(Group_HighVariance(a)-4) == 0
%         Logistic_matrix_High(a, 9) = 1;
%     elseif raw_data.ResponseSide(Group_HighVariance(a)-4) == 2 && raw_data.Rewarded(Group_HighVariance(a)-4) == 1
%         Logistic_matrix_High(a, 9) = 2;
%     elseif raw_data.ResponseSide(Group_HighVariance(a)-4) == 1 && raw_data.Rewarded(Group_HighVariance(a)-4) == 0
%         Logistic_matrix_High(a, 9) = 2;
%     end
%     
% end
% 
% end
% 
% 
% 
% 
% %%
% % This sub-function is designed to find the index of each highTIV or lowTIV tiral in its original SessionData
% function [original_OrderIdx] = TrialSorting(original_OrderIdx, Group_LowVariance, Group_HighVariance)
% 
% SessionIdx = diff(original_OrderIdx.OrderIdx);
% ttt = find(SessionIdx < 0);
% ttt = [0, ttt, length(original_OrderIdx.OrderIdx)];
% 
% for i = 1 : (length(ttt) - 1)
%     SessionIdx((ttt(i)+1) : ttt(i+1)) = i; 
% end
% clear ttt i
% 
% 
% original_OrderIdx.Trials_HighTIV = original_OrderIdx.OrderIdx(Group_HighVariance);
% original_OrderIdx.Trials_HighTIV = [original_OrderIdx.Trials_HighTIV; SessionIdx(Group_HighVariance)];
% 
% original_OrderIdx.Trials_LowTIV = original_OrderIdx.OrderIdx(Group_LowVariance);
% original_OrderIdx.Trials_LowTIV = [original_OrderIdx.Trials_LowTIV; SessionIdx(Group_LowVariance)];
% 
% 
% end




