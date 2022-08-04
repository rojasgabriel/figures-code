figure(10)
histogram(norm_averagedPupil)
title('Frequency of trial averaged pupil diameters');
ylabel('Frequency');
xlabel('Normalized pupil diameter (z-score)');

quantiles = quantile(norm_averagedPupil, 3);

p1 = [];
p2 = [];
p3 = [];
p4 = [];

for i = 1:length(norm_averagedPupil)
    if norm_averagedPupil(i) <= quantiles(1)
        p1 = [p1; CorrectRate(i)];
    elseif norm_averagedPupil(i) <= quantiles(2)
        p2 = [p2; CorrectRate(i)];
    elseif norm_averagedPupil(i) <= quantiles(3)
        p3 = [p3; CorrectRate(i)];
    elseif norm_averagedPupil(i) > quantiles(3)
        p4 = [p4; CorrectRate(i)];
    end
end

lim = min([length(p1), length(p2), length(p3), length(p4)]);

p1 = p1(1:lim);
p2 = p2(1:lim);
p3 = p3(1:lim);
p4 = p4(1:lim);
p_means = [mean(p1), mean(p2), mean(p3), mean(p4)];

p1_sem = std(p1);%/sqrt(length(p1));
p2_sem = std(p2);%/sqrt(length(p2));
p3_sem = std(p3);%/sqrt(length(p3));
p4_sem = std(p4);%/sqrt(length(p4));
p_errors = [p1_sem, p2_sem, p3_sem, p4_sem];

%performance by pupil quartile
figure(11)
errorbar(p_means, p_errors)
hold on
plot(1, p1, 'o')
hold on
plot(2, p2, 'o')
hold on
plot(3, p3, 'o')
hold on
plot(4, p4, 'o')
x = categorical({'Q1','Q2', 'Q3', 'Q4'});
set(gca, 'XTick', 1:4, 'XTickLabel', x)
title('Performance by pupil quartile')
grid on; box off
ylabel('averaged Correct Rate per trial w/ std')

%histogram of performance by quartile
figure(12)
histogram(p1, 'facealpha', 0.5)
hold on
histogram(p2, 'facealpha', 0.5)
hold on
histogram(p3, 'facealpha', 0.5)
hold on
histogram(p4, 'facealpha', 0.5)
legend;
box off;
title('Frequency histogram of performance by quartile')
ylabel('Frequency')
xlabel('Correct Rate');
legend('Q1', 'Q2', 'Q3', 'Q4')

%tiled layout for histograms above
figure(13)
tiledlayout('flow')
nexttile
histogram(p1, 'facealpha', 0.5, 'binwidth', 0.025)
title('Q1')
box off; grid on
ylabel('Frequency')
xlabel('Correct Rate');
xlim([0.6 1])
ylim([0 225])

nexttile
histogram(p2, 'facealpha', 0.5, 'binwidth', 0.025)
title('Q2')
box off; grid on
ylabel('Frequency')
xlabel('Correct Rate');
xlim([0.6 1])
ylim([0 225])

nexttile
histogram(p3, 'facealpha', 0.5, 'binwidth', 0.025)
title('Q3')
box off; grid on
ylabel('Frequency')
xlabel('Correct Rate');
xlim([0.6 1])
ylim([0 225])

nexttile
histogram(p4, 'facealpha', 0.5, 'binwidth', 0.025)
title('Q4')
box off; grid on
ylabel('Frequency')
xlabel('Correct Rate');
xlim([0.6 1])
ylim([0 225])

