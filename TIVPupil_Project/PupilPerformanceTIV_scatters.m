%% Simple scatters between pupil diameter and performance/TIV

figure(6)
tiledlayout('flow')
nexttile
scatter(norm_averagedPupil, CorrectRate)
xlabel('Normalized Pupil Diameter (z-score)')
ylabel('Correct Rate')

nexttile
scatter(norm_averagedPupil, Residual)
xlabel('Normalized Pupil Diameter (z-score)')
ylabel('TIV')

%% Creating deleted by session variable for subsequent analysis

deleted_by_session = cell(length(trialData_backup), 1);

for a = 1:length(trialData_backup)
    for b = 1:length(trialData_backup(a).rewarded)
        if a == 1
            deleted_by_session{a}(b) = deleted(b);
        elseif a == 2
            deleted_by_session{a}(b) = deleted(b+428);
        elseif a == 3
            deleted_by_session{a}(b) = deleted(b+428+552);
        elseif a == 4
            deleted_by_session{a}(b) = deleted(b+428+552+487);
        end
    end
end

for i = 1:length(deleted_by_session)
    deleted_by_session{i} = reshape(deleted_by_session{i}, [length(deleted_by_session{i}), 1]);
end

%% Calculating pupil and performance by session for subsequent analysis

for i = 1:length(norm_pupil_by_session)
    norm_pupil_by_session{i} = smoothdata(norm_pupil_by_session{i}, 'movmean', smooth_window);
    norm_pupil_by_session{i}(deleted_by_session{i}) = [];
end

CorrectRate_by_session = cell(size(trialData_backup));
for i = 1:length(CorrectRate_by_session)
    CorrectRate_by_session{i} = trialData_backup(i).rewarded;
    CorrectRate_by_session{i} = smoothdata(CorrectRate_by_session{i}, 'movmean', smooth_window);
    CorrectRate_by_session{i}(deleted_by_session{i}) = [];
end

%% Plotting pupil-performance scatter plots for each session

figure(7)
scatter(norm_averagedPupil, CorrectRate)
xlabel('Normalized Pupil Diameter (z-score)')
ylabel('Correct Rate')
ylim([0.5 1])

figure(8)
for i = 1:length(norm_pupil_by_session)
    scatter(norm_pupil_by_session{i}, CorrectRate_by_session{i})
    hold on
end
xlabel('Normalized Pupil Diameter (z-score)')
ylabel('Correct Rate')
ylim([0.5 1])
legend({'S1', 'S2', 'S3', 'S4'})

titles = {'S1', 'S2', 'S3', 'S4'};
figure(9)
tiledlayout('flow')
for i = 1:length(norm_pupil_by_session)
    nexttile
    scatter(norm_pupil_by_session{i}, CorrectRate_by_session{i})
    title(titles{i})
    xlabel('Normalized Pupil Diameter (z-score)')
    ylabel('Correct Rate')
    ylim([0.5 1])
end
