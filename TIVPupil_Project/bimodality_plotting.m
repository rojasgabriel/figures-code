% clc, clear, close all

%% load the test data
data = [p1 p2 p3 p4];

%% calculate the bimodality coefficient
[BF, BC] = bimodalitycoeff(data);

%% plot the histograms
figure(14)
for m = 1:size(data, 2)
    % plot the histograms
    subplot(2, 2, m)
    histogram(data(:, m), 'FaceColor', 'b', 'binwidth', 0.02)
%     set(gca, 'FontName', 'Times New Roman', 'FontSize', 14)
    xlabel('Value')
    ylabel('Frequency')
    ylim([0 200])
    xlim([0.65 0.95])
    if m == 1
        title(['Q1 - Bimodality coeff. = ' num2str(BC(m), 2) '; n = ' num2str(numel(data(:,1))) ' trials'])
    elseif m == 2
        title(['Q2 - Bimodality coeff. = ' num2str(BC(m), 2) '; n = ' num2str(numel(data(:,2))) ' trials'])
    elseif m == 3
        title(['Q3 - Bimodality coeff. = ' num2str(BC(m), 2) '; n = ' num2str(numel(data(:,3))) ' trials'])
    else
        title(['Q4 - Bimodality coeff. = ' num2str(BC(m), 2) '; n = ' num2str(numel(data(:,4))) ' trials'])
    end
    % set axes background in green or red depending on BF
    % - green for bimodality and red for non-bimodality
    if BF(m)
        set(gca, 'Color', 'g')
    else
        set(gca, 'Color', 'r')
    end
end