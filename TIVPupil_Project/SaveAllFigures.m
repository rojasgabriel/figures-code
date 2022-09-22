function SaveAllFigures(figuresDir)
% Original code from: https://www.mathworks.com/matlabcentral/answers/386880-how-can-i-save-instantaneously-all-plots-of-a-script

% To-Do: find a way to not have the figure title text be cropped

AllFigH = allchild(groot);
    for iFig = 1:numel(AllFigH)
      fig = AllFigH(iFig);
    %   FileName = [fig.Title, '.png'];
      FileName = sprintf('Figure%03d.pdf', iFig);
      saveas(fig, fullfile(figuresDir, FileName));
    end
end