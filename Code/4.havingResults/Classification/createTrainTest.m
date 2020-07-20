%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desarrollado por | Developed by:                     %
% University Carlos III of Madrid PhD Researchers      %
% Daniel Amigo Herrero    mailto: damigo@inf.uc3m.es   %
% David Sanchez Pedroche  mailto: davsanch@inf.uc3m.es %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Divide los datos en entrenamiento y test segun distintos criterios
%  Divide the data into training and test according to different criteria
function [DataTrain, DataTest, ClassesTableTrain, ClassesTableTest] = ...
    createTrainTest(DataMatrix, ClassesTable, trainTestType, selectedClass, nonSelectedClasses)

    rng(1); % For reproducibility
    n = height(ClassesTable);
    idxTrain = false(n, 1); % The 1s to use for training are noted

    if trainTestType == 1 && selectedClass > 2 && selectedClass < 13 %  Division with 70% training 30% test for each binary class
        nonSelectedClasses(end+1) = selectedClass;
        for i=1:length(nonSelectedClasses)
            entriesThisClass = find(ClassesTable{:,nonSelectedClasses(i)} == 1);            
            selected = randsample(entriesThisClass, round(0.7 * length(entriesThisClass)) ); % Entries to get of this class
            auxIdxTrain = false(n, 1);                                                       % Selected ones as 1
            auxIdxTrain(selected) = true;
            %disp("Selected "+ num2str(length(find(auxIdxTrain == 1)/length(entriesThisClass))+ "% of the class "+nonSelectedClasses(i)+" to train");
            idxTrain = or(auxIdxTrain, idxTrain);                                            % Se unen al resto de seleccionados
        end
        
    elseif trainTestType == 1 && selectedClass > 12 % Division with 70% training 30% test for multiclass. 70% - 30% each possible value
        uniq = unique(ClassesTable{:,selectedClass});
        for i=1:length(uniq)
            entriesThisClass = find(ismember(ClassesTable{:,selectedClass}, uniq(i)));      
            selected = randsample(entriesThisClass, round(0.7 * length(entriesThisClass)) );
            auxIdxTrain = false(n, 1);                                                      
            auxIdxTrain(selected) = true;
            %disp("Selected "+ num2str(length(find(auxIdxTrain == 1))/length(entriesThisClass))+ "% of the class "+uniq(i)+" to train");
            idxTrain = or(auxIdxTrain, idxTrain);                                           
        end
        
    elseif trainTestType == 2 % Division with 70-30 for all at once
        selected = randsample(n, round(0.7 * n));
        idxTrain(selected) = true;
    end

    % marked all as train, test are the rest ones
    idxTest = idxTrain == false;
    
    
    %% The data matrix and classes table are splitted
    DataTrain = DataMatrix(idxTrain,:);
    DataTest  = DataMatrix(idxTest,:);
    ClassesTableTrain = ClassesTable(idxTrain,:);
    ClassesTableTest  = ClassesTable(idxTest,:);
    
    %disp("Check percentages: "+ num2str(length(find(auxIdxTrain == 1)/n)+ "% for train");
end