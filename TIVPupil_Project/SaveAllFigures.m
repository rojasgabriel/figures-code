function SaveAllFigures(figuresDir)

% To-Do: find a way to not have the figure title text be cropped

AllFigH = allchild(groot);
    for iFig = 1:numel(AllFigH)
      fig = AllFigH(iFig);
    %   FileName = [fig.Title, '.png'];
      FileName = sprintf('Figure%03d.png', iFig);
      saveas(fig, fullfile(figuresDir, FileName));
    end
end