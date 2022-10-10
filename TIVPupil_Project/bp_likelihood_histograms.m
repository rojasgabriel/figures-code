% Plot high/low likelihood coordinate histograms for a specified bodypart
% Pending: make into function
% -GRB

tongue = data(:, (41:43)); %data is imported DLC output (pending)

tongue_low = zeros(length(data), 2);
tongue_high = zeros(length(data), 2);

for i = 1:length(data)
    if tongue(i,3) > 0.8 %pending: have this be an input to the function
        tongue_high(i, :) = tongue(i, [1 2]);
    else
        tongue_low(i, :) = tongue(i, [1 2]);
    end
end

tongue_high = tongue_high(any(tongue_high, 2), :);
tongue_low = tongue_low(any(tongue_low, 2), :);

%draw 8000 random samples - this number will depend on the bodypart
%(pending)
index = randsample(1:length(tongue_high), 8000);
tongue_high_sampled = tongue_high(index,:);

index = randsample(1:length(tongue_low), 8000);
tongue_low_sampled = tongue_low(index,:);

figure;
hist3(tongue_low_sampled, 'CDataMode','auto','FaceColor','r');
t = xlim;
tt = ylim;
xbin = floor(diff(t)/25);
ybin = floor(diff(tt)/25);
hist3(tongue_low_sampled, 'nbins', [xbin, ybin], 'CDataMode','auto','FaceColor','r');
xlabel('x')
ylabel('y')
title('Low likelihood')
xlim([400 1200]) %pending
ylim([200 800])

figure;
hist3(tongue_high_sampled,'CDataMode','auto','FaceColor','g');
m = xlim;
mm = ylim;
xbin = floor(diff(m)/25);
ybin = floor(diff(mm)/25);
hist3(tongue_high_sampled, 'nbins', [xbin, ybin], 'CDataMode','auto','FaceColor','g');
xlabel('x')
ylabel('y')
title('High likelihood')
xlim([400 1200])
ylim([200 800])
