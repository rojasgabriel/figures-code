%% 'GroupData_MouseGRB' by Gabriel Rojas Bowe
% Modified from Chaoqun Yin's original 'GroupData_Mouse' function.
%
% This function divides trials into different plotting groups based on
% divide_mode. It is also necessary for performing the linear regression as
% it creates a structure to store the variables to be included in the
% regression analysis.

function [InputMatrix] = GroupData_MouseGRB(InputMatrix, divide_mode, trialData)

InputMatrix(:, end+1) = 0;   % Mark for dividing trials

%% 'stimulus' 1
if isequal(divide_mode, 'stimulus') == 1
    for a = 1 : length(trialData.correct_side)
        InputMatrix(a, end) = trialData.correct_side(a); 
    end


% %% 'opto'
% elseif isequal(divide_mode, 'opto')
%     if isfield(trialData, 'optoType') == 1
%         for a = 1 : length(trialData.optoType)
%             if ~isnan(trialData.optoType(a))
%                 InputMatrix(a, end) = 1;
%             else
%                 InputMatrix(a, end) = 0;
%             end
%         end
%         
%     else
%         InputMatrix(:, end) = 0;
%     end
% 
% 
% %% 'optotype'
% elseif isequal(divide_mode, 'optotype')
%     if isfield(raw_data, 'optoType') == 1
%         for a = 1 : length(trialData.optoType)
%             if ~isnan(trialData.optoType(a))
%                 InputMatrix(a, end) = trialData.optoType(a);
%             else
%                 InputMatrix(a, end) = 0;    % No opto stimulation
%             end
%         end
%         
%     else
%         InputMatrix(:, end) = 0;
%     end
%     
%     
%% 'outcome' 2
elseif isequal(divide_mode, 'outcome') == 1
    for a = 1 : length(trialData.noChoice)
        if trialData.noChoice(a) == 1
            InputMatrix(a, end) = 0;	% No response
        elseif trialData.noChoice(a) == 0 && trialData.rewarded(a) == 1
            InputMatrix(a, end) = 1;    % Correct
        elseif trialData.noChoice(a) == 0 && trialData.rewarded(a) == 0
            InputMatrix(a, end) = 2;    % Wrong
        end
    end
    
%% 'responseside' 3
elseif isequal(divide_mode, 'responseside') == 1
    for a = 1 : length(trialData.choice)
        if trialData.choice(a) == 0
            InputMatrix(a, end) = 0;	% No response
        elseif ~isnan(trialData.choice(a)) && trialData.choice(a) == 1
            InputMatrix(a, end) = 1;    
        elseif ~isnan(trialData.choice(a)) && trialData.choice(a) == 2
            InputMatrix(a, end) = 2;    
        end
    end
    
    
%% 'formeroutcome' 4
elseif isequal(divide_mode, 'formeroutcome') == 1
    InputMatrix(1, end) = 0;    % this 1st trial doesn't have a former trial. Setting is as 'no response'
    for a = 2 : length(trialData.rewarded) %check logic for this
        if trialData.noChoice(a-1) == 1
            InputMatrix(a, end) = 0;	% No response
        elseif trialData.noChoice(a-1) == 0 && trialData.rewarded(a-1) == 1
            InputMatrix(a, end) = 1;    % Correct
        elseif trialData.noChoice(a-1) == 0 && trialData.rewarded(a-1) == 0
            InputMatrix(a, end) = 2;    % Wrong
        end
    end
    
    
%% 'formerresponseside' 5
elseif isequal(divide_mode, 'formerresponseside') == 1
    InputMatrix(1, end) = 0;    % this 1st trial doesn't have a former trial. Setting is as 'no response'
    for a = 2 : length(trialData.choice)
        if trialData.choice(a-1) == 0
            InputMatrix(a, end) = 0;	% No response
        elseif ~isnan(trialData.choice(a-1)) && trialData.choice(a-1) == 1
            InputMatrix(a, end) = 1;    
        elseif ~isnan(trialData.choice(a-1)) && trialData.choice(a-1) == 2
            InputMatrix(a, end) = 2;    
        end
    end

    
%% 'random' 6
elseif isequal(divide_mode, 'random') == 1
    for a = 1 : size(InputMatrix, 1)
        if rand < 0.5
            InputMatrix(a,end) = 0;
        else
            InputMatrix(a,end) = 1;
        end
    end

    
%% 'optotype_classifier'    This is especially designed for function "LinearClassifierPlus"
% elseif isequal(divide_mode, 'optotype_classifier') == 1
%     for a = 1 : length(raw_data.optoType)
%         if ~isnan(raw_data.optoType(a))
%             InputMatrix(a, end) = raw_data.optoType(a)*raw_data.optoArea(a);      
%         else
%             InputMatrix(a, end) = raw_data.optoArea(a);    % No opto stimulation
%         end
%     end
%     
% end
%     
end


