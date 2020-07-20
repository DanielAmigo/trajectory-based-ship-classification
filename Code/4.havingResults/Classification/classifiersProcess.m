%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desarrollado por | Developed by:                     %
% University Carlos III of Madrid PhD Researchers      %
% Daniel Amigo Herrero    mailto: damigo@inf.uc3m.es   %
% David Sanchez Pedroche  mailto: davsanch@inf.uc3m.es %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Aplica un clasificador sobre los datos y clases (entrenamiento y test), devolviendo el clasificador, resultados y metricas
%  Apply a classifier over the data and classes (training and test), returning the classifier, results and metrics
function [testAccuracy, confusionMatrix, labels, classifier, sumVector] = ...
    classifiersProcess(DataTrain, DataTest, ClassesTableTrain, ClassesTableTest, typeClassifier, predictClass, DataTableHeaders, resultFileName, doVector)

%% %%%%%%%%%%% Binary tree %%%%%%%%%%%%
if typeClassifier == 1
    
    % The classifier is generated with the training set
    Mdl = fitctree(DataTrain, ClassesTableTrain);   % 'MaxDepth',X  'Prune','off'    'PruneCriterion','impurity'
    classifier = Mdl;
    
    % The scores of the test set are calculated
    [labelPredictTest, score] = predict(Mdl, DataTest);
    
    % It generates a column of zeros / text result depending on whether it is for multiclass or binary. With what you are going to compare. The result of the test
    scores = 0;
    for i=1:length(ClassesTableTest)
        if isnumeric(ClassesTableTest(i)) == 1             % If the class is numerical, it is binary
            if labelPredictTest(i) == ClassesTableTest(i)
                scores = scores + 1;
            end
        else                                                 % If the class is String, it's a multiclass
            if strcmp(labelPredictTest(i), ClassesTableTest(i)) == 1
                scores = scores + 1;
            end
        end
    end
    
    testAccuracy = (scores / length(labelPredictTest)) * 100; % Bug when its multiclass
    [C,labels] = confusionmat(logical(ClassesTableTest), logical(labelPredictTest));
    confusionMatrix = C;
    
    %% %%%%%%%%%%% SVM %%%%%%%%%%%%
elseif typeClassifier == 2
    
    % The classifier is generated with the training set
    Mdl = fitcsvm(DataTrain, ClassesTableTrain);
    classifier = Mdl;
    
    % The scores of the test set are calculated
    [labelPredictTest, score] = predict(Mdl, DataTest);
    
    % It generates a column of zeros / text result depending on whether it is for multiclass or binary. With what you are going to compare. The result of the test
    scores = 0;
    for i=1:length(ClassesTableTest)
        if isnumeric(ClassesTableTest(i)) == 1             % If the class is numerical, it is binary
            if labelPredictTest(i) == ClassesTableTest(i)
                scores = scores + 1;
            end
        else                                                 % If the class is String, it's a multiclass
            if strcmp(labelPredictTest(i), ClassesTableTest(i)) == 1
                scores = scores + 1;
            end
        end
    end

    testAccuracy = (scores / length(labelPredictTest)) * 100; % Bug when its multiclass
    [C, labels] = confusionmat(logical(ClassesTableTest), logical(labelPredictTest));
    confusionMatrix = C;
    
end

%% Calculation of the average for each variable classified as each class
j=1;
[m,n] = size(DataTest);
sumVector = zeros(n,2);
if doVector == true % Bug when train and test are separated variables
    count=0;
    count2=0;
    valuesHistogram = zeros(length(labelPredictTest),n);
    
    for i=1:length(idxTest)
        if idxTest(i) == 1
            if isnumeric(clasePredictMatrix) == 1
                if labelPredictTest(j) == 1
                    for k=1:n
                        sumVector(k,1)=sumVector(k,1)+DataMatrix(i,k);
                    end
                    count = count + 1;
                    valuesHistogram(count,:) = DataMatrix(i,:);
                else
                    for k=1:n
                        sumVector(k,2)=sumVector(k,2)+DataMatrix(i,k);
                    end
                    count2=count2+1;
                end
            else
                disp('It does not work for multiclass');
            end
            j = j + 1;
        end
    end
    if count==0
        disp('Empty class');
    else
        for k=1:n
            sumVector(k,1)=sumVector(k,1)/count;
            sumVector(k,2)=sumVector(k,2)/count2;
        end
    end
end

%% It generates a histogram of the distribution of that class.
createHistogram = false;
if createHistogram == true
    for k=1:n
        % Create the figure title
        if k == 1
            YesNO = 'Si';
        elseif k == 0
            YesNO = 'No';
        end
        if predictClass == 2
            predictClassLabel = 'Cargo';
        elseif predictClass == 3
            predictClassLabel = 'Fishing';
        elseif predictClass == 4
            predictClassLabel = 'Passenger';
        elseif predictClass == 5
            predictClassLabel = 'Tanker';
        elseif predictClass == 6
            predictClassLabel = 'Engaged in fishing';
        elseif predictClass == 7
            predictClassLabel = 'Restricted';
        elseif predictClass == 8
            predictClassLabel = 'Sailing';
        elseif predictClass == 9
            predictClassLabel = 'Engine';
        end
        
        label = DataTableHeaders{k};
        
        h = histogram(valuesHistogram(k,:));
        title(['Histogram : ', YesNO, ' ', predictClassLabel, ' ', label]);
        
        path = strcat('Resultados/Capturas/',union,'/'); % path
        if ~exist(path, 'dir')
            mkdir(path)
        end
        saveas(h,strcat( path,'Histogram_', YesNO, '_', predictClassLabel, '_', label, '.png' ) ); % will create FIG1, FIG2,...
        %close
    end
end

end