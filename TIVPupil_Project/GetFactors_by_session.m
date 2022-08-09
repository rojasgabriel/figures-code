function [group_info_cell, factorTime_cell] = GetFactors_by_session(overall_PCAmatrix_backup, ...
    trialData_cell, trialNum_cell, timespan_cell, coordinate_cell, labelNum_cell)
%% Get factor information

temp = reshape(overall_PCAmatrix_backup, [trialNum_cell, timespan_cell*coordinate_cell*labelNum_cell]);
variableList = {'optotype', 'stimulus', 'outcome', 'responseside', 'formeroutcome', 'formerresponseside'};
for a = 1 : length(variableList)
    temp = GroupData_MouseGRB(temp, variableList{a}, trialData_cell);
end

group_info_cell = temp(:, end-length(variableList)+1:end);

clear a temp

%% Get factor times

factorTime_cell = zeros(trialNum_cell, timespan_cell, 8);    %8 task variables
% Optotype = 1 starts together with the stimulus. Usually it covers the first 0.5 s of the stimulus but depending on the session, it might stay on until the end of the delay period.
% Optotype = 2 starts at the end of the stimulus period (begin of delay period)
% Optotype = 3 starts at the end of the delay period (begin of response period)
% Optotype = 4 starts in the later part of the stimulus period and ends with the stimulus
% Optotype = 5 starts 0.5s before the stimulus and ends with stimulus onset
% rawdata.optoDur to check how long the stimulation lasted. In sessions where 5 types were used, it should always be 0.5s

if ~isfield(trialData_cell, 'optoDur')
    disp('Please notice this session does not contain any optogenetic trials!');
    trialData_cell.optoDur = [0,1];  % for running the following part.
end


if length(unique(trialData_cell.optoDur(~isnan(trialData_cell.optoDur)))) == 2
    for a = 1 : size(group_info_cell, 1)
        % optotype (not using this -GRB)
        if group_info_cell(a,1) == 1
            factorTime_cell(a, 15:29, 1) = 1;
        elseif group_info_cell(a,1) == 2
            factorTime_cell(a, 45:59, 1) = 1;
        elseif group_info_cell(a,1) == 3
            factorTime_cell(a, 60:74, 1) = 1;
        elseif group_info_cell(a,1) == 4
            factorTime_cell(a, 30:44, 1) = 1;
        elseif group_info_cell(a,1) == 5
            factorTime_cell(a, 1:14, 1) = 1;
        end

        % stimulus 
        factorTime_cell(a, 1:end, 2) = group_info_cell(a, 2);

        % outcome
            %if group_info(a,2) == 1
        factorTime_cell(a, 60:end, 3) = group_info_cell(a, 3);
            %end

        % responseside
        factorTime_cell(a, :, 4) = group_info_cell(a,4);

        % interaction between responseside and outcome (trial n)
        if group_info_cell(a,4) == 1 && group_info_cell(a, 3) == 1
            factorTime_cell(a,  60:end, 5) = 1;    % left choice & correct
        elseif group_info_cell(a,4) == 2 && group_info_cell(a, 3) == 1
            factorTime_cell(a,  60:end, 5) = -1;    % right choice & correct
        elseif group_info_cell(a,4) == 1 && group_info_cell(a, 3) == 2
            factorTime_cell(a,  60:end, 5) = 2;    % left choice & wrong
        elseif group_info_cell(a,4) == 2 && group_info_cell(a, 3) == 2
            factorTime_cell(a,  60:end, 5) = -2;    % right choice & wrong
        end

        % formeroutcome
            %if group_info(a,4) == 1
        factorTime_cell(a, :, 6) = group_info_cell(a,5);
            %end

        %formerresponseside
        factorTime_cell(a, :, 7) = group_info_cell(a,6);

        % interaction between responside and outcome (trial n-1)
        if group_info_cell(a,6) == 1 && group_info_cell(a, 5) == 1
            factorTime_cell(a, :, 8) = 1;   
        elseif group_info_cell(a,6) == 2 && group_info_cell(a, 5) == 1
            factorTime_cell(a, :, 8) = -1;   
        elseif group_info_cell(a,6) == 1 && group_info_cell(a, 5) == 2
            factorTime_cell(a, :, 8) = 2;  
        elseif group_info_cell(a,6) == 2 && group_info_cell(a, 5) == 2
            factorTime_cell(a, :, 8) = -2;   
        end

    end

else
    fprintf('There are trials containing long opto stimulation.');
    return
end

clear a




fprintf('%s\n', 'Proceeding to build linear regression model')