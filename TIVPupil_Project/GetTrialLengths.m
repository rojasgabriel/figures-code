function [trialLengths] = GetTrialLengths(trialData, aligned_frametimes)

trialLengths = cell(length(trialData), 1);
for i = 1:length(trialLengths)
    trialLengths{i} = zeros(trialData{i}.nTrials, 1);
end

for a = 1:length(trialData)
    for b = 1:trialData{a}.nTrials
        if b == trialData{a}.nTrials
            break
        else
           trialLengths{a}(b) = aligned_frametimes{a, 1}.trialstart_times(b+1) - ...
           aligned_frametimes{a, 1}.trialstart_times(b);
        end
    end
    trialLengths{a}(end) = [];
end

%trialLengths = cell2mat(trialLengths);
