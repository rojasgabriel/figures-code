function [pupil_avg, performance_avg] = blockavg_no_overlap(norm_averagedPupil, CorrectRate)

global block_len mousename %num of values to include in each block

pupil_avg = accumarray(ceil((1:numel(norm_averagedPupil))/block_len)',norm_averagedPupil(:),[],@mean);
performance_avg = accumarray(ceil((1:numel(CorrectRate))/block_len)',CorrectRate(:),[],@mean);

figure;
scatter(pupil_avg, performance_avg)
xlabel('Normalized Pupil Diameter (z-score)')
ylabel('Correct Rate')
title(mousename)