function [group_info, factorTime, overall_PCAmatrix] = GetFactors(overall_PCAmatrix, DLC_LateralNoLabelsData, ...
    trialData)
%% Get factor information

global trialNum timespan coordinate labelNum

for i = 1:size(DLC_LateralNoLabelsData, 1) 
    temp = reshape(overall_PCAmatrix, [trialNum, timespan*coordinate*labelNum]);
    variableList = {'optotype', 'stimulus', 'outcome', 'responseside', 'formeroutcome', 'formerresponseside'};
    for a = 1 : length(variableList)
        temp = GroupData_MouseGRB(temp, variableList{a}, trialData);
    end

    group_info = temp(:, end-length(variableList)+1:end);
end
clear a temp

%% Get factor times
for i = 1:size(DLC_LateralNoLabelsData, 1)
    factorTime = zeros(trialNum, timespan, 8);    %8 task variables
    % Optotype = 1 starts together with the stimulus. Usually it covers the first 0.5 s of the stimulus but depending on the session, it might stay on until the end of the delay period.
    % Optotype = 2 starts at the end of the stimulus period (begin of delay period)
    % Optotype = 3 starts at the end of the delay period (begin of response period)
    % Optotype = 4 starts in the later part of the stimulus period and ends with the stimulus
    % Optotype = 5 starts 0.5s before the stimulus and ends with stimulus onset
    % rawdata.optoDur to check how long the stimulation lasted. In sessions where 5 types were used, it should always be 0.5s

    if ~isfield(trialData, 'optoDur')
        disp('Please notice this session does not contain any optogenetic trials!');
        trialData.optoDur = [0,1];  % for running the following part.
    end


    if length(unique(trialData.optoDur(~isnan(trialData.optoDur)))) == 2
        for a = 1 : size(group_info, 1)
            % optotype (not using this -GRB)
            if group_info(a,1) == 1
                factorTime(a, 15:29, 1) = 1;
            elseif group_info(a,1) == 2
                factorTime(a, 45:59, 1) = 1;
            elseif group_info(a,1) == 3
                factorTime(a, 60:74, 1) = 1;
            elseif group_info(a,1) == 4
                factorTime(a, 30:44, 1) = 1;
            elseif group_info(a,1) == 5
                factorTime(a, 1:14, 1) = 1;
            end

            % stimulus 
            factorTime(a, 1:end, 2) = group_info(a, 2);

            % outcome
                %if group_info(a,2) == 1
            factorTime(a, 60:end, 3) = group_info(a, 3);
                %end

            % responseside
            factorTime(a, :, 4) = group_info(a,4);

            % interaction between responseside and outcome (trial n)
            if group_info(a,4) == 1 && group_info(a, 3) == 1
                factorTime(a,  60:end, 5) = 1;    % left choice & correct
            elseif group_info(a,4) == 2 && group_info(a, 3) == 1
                factorTime(a,  60:end, 5) = -1;    % right choice & correct
            elseif group_info(a,4) == 1 && group_info(a, 3) == 2
                factorTime(a,  60:end, 5) = 2;    % left choice & wrong
            elseif group_info(a,4) == 2 && group_info(a, 3) == 2
                factorTime(a,  60:end, 5) = -2;    % right choice & wrong
            end

            % formeroutcome
                %if group_info(a,4) == 1
            factorTime(a, :, 6) = group_info(a,5);
                %end

            %formerresponseside
            factorTime(a, :, 7) = group_info(a,6);

            % interaction between responside and outcome (trial n-1)
            if group_info(a,6) == 1 && group_info(a, 5) == 1
                factorTime(a, :, 8) = 1;   
            elseif group_info(a,6) == 2 && group_info(a, 5) == 1
                factorTime(a, :, 8) = -1;   
            elseif group_info(a,6) == 1 && group_info(a, 5) == 2
                factorTime(a, :, 8) = 2;  
            elseif group_info(a,6) == 2 && group_info(a, 5) == 2
                factorTime(a, :, 8) = -2;   
            end

        end

    else
        fprintf('There are trials containing long opto stimulation.');
        return
    end

    clear a
    
    
end

fprintf('%s\n', 'Proceeding to build linear regression model')