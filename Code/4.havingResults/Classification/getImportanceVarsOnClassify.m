%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desarrollado por | Developed by:                     %
% University Carlos III of Madrid PhD Researchers      %
% Daniel Amigo Herrero    mailto: damigo@inf.uc3m.es   %
% David Sanchez Pedroche  mailto: davsanch@inf.uc3m.es %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Segun el clasificador, se crea un fichero que indica la importancia de cada variable sobre la clasificacion
%  Depending on the classifier, the importance of each variable on the classification is indicated and stored in a file
function [] = getImportanceVarsOnClassify(fileImportanceVars, importanceVars, classifierType, classifier, originalVars, selectedVars)

% It creates the array that will store the importance of each variable, selected or not
originalImportance = strings(length(originalVars), 1);
originalImportance(:) = "-"; % If this variable is not selected, put a - (which allows the sum in Excel between numbers)

%% Using predictorImportance over a tree
if importanceVars == 1 && classifierType == 1
    
    selectedImportance = predictorImportance(classifier);
    
    for i=1:length(selectedVars)
        pos = find(ismember(originalVars, selectedVars(i))); % Checks and finds the position of the current selected variable
        if pos > 0
            if selectedImportance(i) == 0 % If it's exactly zero, it write exactly '0'
                originalImportance(pos) = num2str(selectedImportance(i));
            else                          % Otherwise, write the number with 15 decimals
                originalImportance(pos) = num2str(selectedImportance(i), "%.15f");
            end
        end
    end
        
end

% Once finished, write the results in the fileImportanceVars
readWriteFunctions.writeImportanceVariables(fileImportanceVars, originalImportance, originalVars);
end