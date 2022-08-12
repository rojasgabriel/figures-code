%% This function is written to do more detailed analyses about the relationship between performance and TIV.
%% 3 analyses are done here:
% 1. Linearly shift the correct rate array and TIV array. Test if the correlation coefficient drops as the shift going
% 2. Show the performance-TIV correlation coefficient of each session.
% 3. Look at the general trend of performance and TIV changes within each session.

function TIVanalysis(correctRate, TIV, session_borders)

%% 1st, Linear shift test (+-200 trials)
corre_shift = nan(1, 401);
for i = 1 : 401
    a = corrcoef(TIV(201 : end-200), correctRate(i :  end-(401-i)));
    corre_shift(i) = a(1,2);   
end

figure('Name', 'TIV analyses');

subplot(2,2,1);
hold on
plot(corre_shift);
xlim([1 401]);
xticks([1 101 201 301 401]);
xticklabels({'-200','-100','0','100','200'});
line([201 201], ylim, 'Color','black','LineStyle','--');
xlabel('Trial Shift');
ylabel('Correlation Coefficient');
hold off
clear i a



%% 2nd, Performance-TIV correlation per session
coeff_session = nan(1, length(session_borders));
ttt = [1, session_borders];

for i = 1 : length(session_borders)
    a = correctRate(ttt(i): ttt(i+1)-1);
    b = TIV(ttt(i): ttt(i+1)-1);
    
    x = corrcoef(a, b);
    coeff_session(i) = x(1,2);
end

subplot(2,2,2);
hold on

bar(1, mean(coeff_session),'FaceColor',[.7 .7 .7],'EdgeColor',[.3 .3 .3],'LineWidth',1); 
xticks([1]);
set(gca,'xticklabel',{'All Sessions'});
xtickangle(45); 
ylabel('Correlation Coefficient');

scatter(ones(1,length(coeff_session)), coeff_session, 20, [0 0 0.9], 'filled');

er = errorbar(1,mean(coeff_session),std(coeff_session),std(coeff_session));    
er.Color = [0 0 0];                            
er.LineStyle = 'none';  

set(gca,'box','off');
set(gca,'tickdir','out');
hold off

clear i a b x er ttt




%% 3rd, Trend of performance and TIV changes within each session
% We normalize all sessions with more than 300 trials to 500-trial long.
ttt = [1, session_borders];
correctRate_sessions = [];
TIV_sessions = [];

for i = 1 : length(session_borders)
    a = correctRate(ttt(i): ttt(i+1)-1);
    b = TIV(ttt(i): ttt(i+1)-1);
    
    if length(a) > 300 && length(a) == length(b)
        zoom = 1:500/length(a):500;
        if length(zoom) < length(a)   % sometimes you get an array 1 element shorter than array a.
            zoom = [zoom, 500];
        end
        
        a_adjusted = interp1(zoom, a, 1:500, 'linear');    
        b_adjusted = interp1(zoom, b, 1:500, 'linear');
        
        correctRate_sessions = [correctRate_sessions; a_adjusted];
        TIV_sessions = [TIV_sessions; b_adjusted];
        
    end
    
end


correctRate_sessions(:, end) = [];
subplot(2,2,3);
hold on
for i = 1 : size(correctRate_sessions, 1)
    plot(correctRate_sessions(i, :), 'Color', [0.4 0.4 0.4]);
end
xticks([1 250 500]);
xticklabels({'Session Beginning','Session Middle','Session End'});
ylabel('Correct Rate');

autocorrelation = (sum(sum(corrcoef(correctRate_sessions'))) - size(correctRate_sessions,1)) / ...
    (size(correctRate_sessions,1)*(size(correctRate_sessions,1)-1));
title(['Auto correlation coeff: ', num2str(autocorrelation)]);





TIV_sessions(:, end) = [];
subplot(2,2,4);
hold on
for i = 1 : size(TIV_sessions, 1)
    plot(TIV_sessions(i, :), 'Color', [0.4 0.4 0.4]);
end
xticks([1 250 500]);
xticklabels({'Session Beginning','Session Middle','Session End'});
ylabel('Task Independent Variance');

autocorrelation = (sum(sum(corrcoef(TIV_sessions'))) - size(TIV_sessions,1)) / ...
    (size(TIV_sessions,1)*(size(TIV_sessions,1)-1));
title(['Auto correlation coeff: ', num2str(autocorrelation)]);


end