function [Fit_result, R_squared, Fitted, mdl, label_count, overall_PCAmatrix,...
    numTrialsDeleted, deleted] = GroupRegression(factorTime, overall_PCAmatrix,...
    group_info, endpoint)
global trialNum timespan coordinate labelNum

factorTime(:,:,1) = []; % removes the opto variable from factorTime
% In terms of the complex influence of optogenetics, we don't use the opto trials here though we recorded opto variables
% x = a1*stimulus + a2*outcome + a3*responseside + a4*interaction(trial n) + a5*formeroutcome + a6*formerresponseside + a7*interaction(trial n-1) + b
% y is the same

% removing no-reponse trials and opto trials in case they are outliers
trialIdx = 1 : size(overall_PCAmatrix, 1);
deleted = logical((group_info(:,4) == 0) + (group_info(:,6) == 0) + (group_info(:,1) ~= 0));
% deleted(length(trialData.nTrials),:) = [];
numTrialsDeleted = find(deleted == 1);
factorTime(deleted, :, :) = [];
overall_PCAmatrix(deleted, :, :, :) = [];
trialIdx(deleted) = [];
%original_OrderIdx.OrderIdx(deleted) = [];


Fit_result = zeros(labelNum, coordinate, timespan, 8);  
R_squared = zeros(labelNum, coordinate, timespan);
Fitted = zeros(trialNum - sum(deleted), timespan, coordinate, labelNum);

for a = 1 : labelNum 
%     if a == 30 %penis doesn't track well for JC047
%         continue
%     else
        for b = 1 : coordinate          
            for c = 1 : timespan      
                y = overall_PCAmatrix(:, c, b, a);
                X = reshape(factorTime(:, c, :), [], 7);
                mdl = fitlm(X, y);

                Fit_result(a,b,c,:) = mdl.Coefficients.Estimate;
                R_squared(a,b,c) = mdl.Rsquared.Adjusted;
                Fitted(:,c,b,a) = mdl.Fitted;

                clear y X
            end
%         end
    end
end
clear a b c


plot_R = squeeze(mean(R_squared, 2));
figure(1);
hold on
label_count = 0;
for i = 1:labelNum %label numbers 1-31 to plot; if wanting to plot just one label, change i to be the ID of label of interest
%     if i == 15 %port label 1
%         continue
%     elseif i == 16 %port label 2
%         continue
%     else
        plot(plot_R(i, :));
        label_count = label_count + 1;
%     end
end
ylabel('R squared');
ylim([0 1]);
xlim([0 endpoint{1}]);
xline(1, '-', {'Stimulus Onset'})
xline(31, '-', {'Stimulus Offset'})
xline(60, '-', {'Response Onset'})
title('The Averaged R squared for all labels');
xlabel('Frame Number');
set(gca,'box','off');
set(gca,'tickdir','out');
hold off