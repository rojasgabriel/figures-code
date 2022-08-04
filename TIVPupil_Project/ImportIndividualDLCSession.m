%% 'ImportDLCdata' by Gabriel Rojas Bowe
% Imports DLC .csv output onto a numerical matrix in MATLAB. Uses
% two functions by Chaoqun Yin: 'ImportDLC_Bottom' and 'ImportDLC_Lateral'.

function [DLC_LateralNoLabelsData, DLC_BottomNoLabelsData] = ImportIndividualDLCSession(lateralFile, bottomFile, mousename)

global mouse_name
mouse_name = mousename;

%% Creating lateral and bottom data matrix
DLC_LateralNoLabelsData = normalize(ImportDLC_Lateral(lateralFile)); %normalize x and y values (ignore normalized likelihood)
DLC_BottomNoLabelsData = normalize(ImportDLC_Bottom(bottomFile));

clear lateralFile bottomFile