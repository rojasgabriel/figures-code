x = norm_averagedPupil;
y = CorrectRate;
[Cxy, F] = mscohere(x,y);

figure(1);
tiledlayout('flow');
nexttile;
plot(x);
title('Normalized Pupil')
xlabel('Trial #')
ylabel('Pupil Diameter (z-score)')
box off
nexttile;
plot(y);
title('Performance')
xlabel('Trial #')
ylabel('Correct Rate')
box off
nexttile;
plot(F, Cxy);
title('MS Coherence between Normalized Pupil and Performance');
xlabel('Frequency (Hz)')
box off

x = Residual;
y = CorrectRate;
[Cxy, F] = mscohere(x,y);

figure(2);
tiledlayout('flow');
nexttile;
plot(x);
title('TIV')
xlabel('Trial #')
ylabel('TIV')
box off
nexttile;
plot(y);
title('CorrectRate')
xlabel('Trial #')
ylabel('CorrectRate')
box off
nexttile;
plot(F, Cxy);
title('MS Coherence between TIV and Performance');
xlabel('Frequency (Hz)')
box off