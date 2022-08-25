session_borders = zeros(length(CorrectRate_cell), 1);
len = zeros(length(CorrectRate_cell), 1);

for i = 1:length(CorrectRate_cell)
    len(i) = length(CorrectRate_cell{i});
    session_borders(i) = len(i);
end

session_borders = cumsum(session_borders);
session_borders = transpose(session_borders);
% session_borders(end) = session_borders(end)+1;

TIVanalysis(CorrectRate, Residual, session_borders)
TIVanalysis(CorrectRate, norm_averagedPupil, session_borders)