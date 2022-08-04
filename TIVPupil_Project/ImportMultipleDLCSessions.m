function [DLC_LateralData, DLC_BottomData, DLC_LateralNoLabelsData, DLC_BottomNoLabelsData] = ...
    ImportMultipleDLCSessions(lateral_csvnames, bottom_csvnames)

fprintf('%s\n', 'Importing DLC data')

DLC_LateralNoLabelsData = cell(length(lateral_csvnames), 1);
DLC_BottomNoLabelsData = cell(length(bottom_csvnames), 1);

for i = 1:length(lateral_csvnames)
    lateralFile = string(lateral_csvnames(i));
    bottomFile = string(bottom_csvnames(i));
    DLC_LateralNoLabelsData{i} = ImportDLC_Lateral(lateralFile); %normalize x and y values (ignore normalized likelihood)
    DLC_BottomNoLabelsData{i} = ImportDLC_Bottom(bottomFile);
    
    %subtract mean from each column row-wise
    DLC_LateralNoLabelsData{i} = DLC_LateralNoLabelsData{i} - mean(DLC_LateralNoLabelsData{i}, 1);
    DLC_BottomNoLabelsData{i} = DLC_BottomNoLabelsData{i} - mean(DLC_BottomNoLabelsData{i}, 1);
    
    DLC_LateralNoLabelsData{i} = normalize(DLC_LateralNoLabelsData{i}, 1);
    DLC_BottomNoLabelsData{i} = normalize(DLC_BottomNoLabelsData{i}, 1);
end

DLC_LateralData = cell2mat(DLC_LateralNoLabelsData); %concatenate sessions
DLC_BottomData = cell2mat(DLC_BottomNoLabelsData);

fprintf('%s\n', 'DLC data imported')

% DLC_LateralNoLabelsData = cell(length(lateral_csvnames), 1);
% DLC_BottomNoLabelsData = cell(length(bottom_csvnames), 1);
% for i = 1:length(lateral_csvnames)
%     lateralFile = string(lateral_csvnames(i));
%     bottomFile = string(bottom_csvnames(i));
%     DLC_LateralNoLabelsData{i} = normalize(ImportDLC_Lateral(lateralFile)); %normalize x and y values (ignore normalized likelihood)
%     DLC_BottomNoLabelsData{i} = normalize(ImportDLC_Bottom(bottomFile));
% end
% 
% DLC_LateralData = cell2mat(DLC_LateralNoLabelsData);
% DLC_BottomData = cell2mat(DLC_BottomNoLabelsData);
