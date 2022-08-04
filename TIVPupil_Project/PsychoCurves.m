function [stim_intensities, psycho_matrix] = PsychoCurves(trialData)
% THIS IS A WORK IN PROGRESS. NOT FINISHED YET.
%%

%To-Do:
% 1) separate sessions since they have different proportions of difficulty
% 2) fit the curve to an accumulated gaussian function(?)
% 3) see if you can calculate bias and sensitivity

global mousename

stim_intensities = unique(trialData.stim_intensity);

neg30LeftChoice = numel(find(trialData.stim_intensity(1:428) == -30 & trialData.choice(1:428) == 1))/numel(find(trialData.stim_intensity(1:428) == -30));
pos30LeftChoice = numel(find(trialData.stim_intensity(1:428) == 30 & trialData.choice(1:428) == 1))/numel(find(trialData.stim_intensity(1:428) == 30));

neg24LeftChoice = numel(find(trialData.stim_intensity(1:428) == -24 & trialData.choice(1:428) == 1))/numel(find(trialData.stim_intensity(1:428) == -24));
pos24LeftChoice = numel(find(trialData.stim_intensity(1:428) == 24 & trialData.choice(1:428) == 1))/numel(find(trialData.stim_intensity(1:428) == 24));  

neg18LeftChoice = numel(find(trialData.stim_intensity(1:428) == -18 & trialData.choice(1:428) == 1))/numel(find(trialData.stim_intensity(1:428) == -18));
pos18LeftChoice = numel(find(trialData.stim_intensity(1:428) == 18 & trialData.choice(1:428) == 1))/numel(find(trialData.stim_intensity(1:428) == 18));

neg12LeftChoice = numel(find(trialData.stim_intensity(1:428) == -12 & trialData.choice(1:428) == 1))/numel(find(trialData.stim_intensity(1:428) == -12));
pos12LeftChoice = numel(find(trialData.stim_intensity(1:428) == 12 & trialData.choice(1:428) == 1))/numel(find(trialData.stim_intensity(1:428) == 12));

psycho_matrix = [neg30LeftChoice; neg24LeftChoice; neg18LeftChoice; neg12LeftChoice;...
    pos12LeftChoice; pos18LeftChoice; pos24LeftChoice; pos30LeftChoice];

figure();
scatter(stim_intensities, psycho_matrix, 'r', 'filled');
title(['Psychometric curves for ', mousename, '-03072022'])
xlabel('StimIntensity');
ylabel('P(Left)');
ylim([0 1]);
yticks([0 0.2 0.4 0.6 0.8 1]);


% These commented lines below are for calculating the probability with
% percentages

% neg30LeftChoice = (numel(find(trialData.stim_intensity == -30 & trialData.choice == 1))/numel(find(trialData.stim_intensity == -30))*100);
% pos30LeftChoice = (numel(find(trialData.stim_intensity == 30 & trialData.choice == 1))/numel(find(trialData.stim_intensity == 30))*100);
% 
% neg24LeftChoice = (numel(find(trialData.stim_intensity == -24 & trialData.choice == 1))/numel(find(trialData.stim_intensity == -24))*100);
% pos24LeftChoice = (numel(find(trialData.stim_intensity == 24 & trialData.choice == 1))/numel(find(trialData.stim_intensity == 24))*100);  
% 
% neg18LeftChoice = (numel(find(trialData.stim_intensity == -18 & trialData.choice == 1))/numel(find(trialData.stim_intensity == -18))*100);
% pos18LeftChoice = (numel(find(trialData.stim_intensity == 18 & trialData.choice == 1))/numel(find(trialData.stim_intensity == 18))*100);
% 
% neg12LeftChoice = (numel(find(trialData.stim_intensity == -12 & trialData.choice == 1))/numel(find(trialData.stim_intensity == -12))*100);
% pos12LeftChoice = (numel(find(trialData.stim_intensity == 12 & trialData.choice == 1))/numel(find(trialData.stim_intensity == 12))*100);
