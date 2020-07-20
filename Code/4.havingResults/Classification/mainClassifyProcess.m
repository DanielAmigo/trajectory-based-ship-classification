%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desarrollado por | Developed by:                     %
% University Carlos III of Madrid PhD Researchers      %
% Daniel Amigo Herrero    mailto: damigo@inf.uc3m.es   %
% David Sanchez Pedroche  mailto: davsanch@inf.uc3m.es %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Script que realiza la clasificacion de trayectorias utilizando las features extraidas
%  Script that performs track classification using the extracted features
function mainClassifyProcess(nameUnion, predictClass, deleteVarsType, classifierType, balanceType, normalizeType, trainTestType, importanceVars, doVector, featureExtraction)

%% Preparation of folders and files of this process
extensionCSV         = '.csv';
extensionMAT         = '.mat';
folderRead           = strcat('Data', '/', nameUnion, '/', 'Preclassifier');
folderWorkspaceRead  = strcat('Data', '/', nameUnion, '/', 'PreclassifierMAT');
folderWorkspaceNN    = strcat('Data', '/', nameUnion, '/', featureExtraction, '/', 'NeighboursMAT');
folderWorkspaceWrite = strcat('Data', '/', nameUnion, '/', featureExtraction, '/', 'ClassifiedMAT');
folderWrite          = strcat('Data', '/', nameUnion, '/', featureExtraction, '/', 'ClassifiedCSV');
folderVectorsWrite   = strcat('Data', '/', nameUnion, '/', featureExtraction, '/', 'VectorsCSV');
folderImportance     = strcat('Data', '/', nameUnion, '/', featureExtraction, '/', 'Importance');
if ~exist(folderWorkspaceWrite, 'dir')% Folder for the result's workspace
    mkdir(folderWorkspaceWrite)
end
if ~exist(folderWrite, 'dir')         % Folder for the result's CSV
    mkdir(folderWrite)
end
if ~exist(folderVectorsWrite, 'dir')  % Folder for the result's vector workspace
    mkdir(folderVectorsWrite)
end
if ~exist(folderWorkspaceRead, 'dir') % Folder for auxiliar workspaces
    mkdir(folderWorkspaceRead)
end
if ~exist(folderWorkspaceNN, 'dir')   % Folder for auxiliar workspaces
    mkdir(folderWorkspaceNN)
end
if ~exist(folderWorkspaceNN, 'dir')   % Folder for auxiliar workspaces
    mkdir(folderWorkspaceNN)
end
if ~exist(folderImportance, 'dir')    % Folder for importance analysis of variables
    mkdir(folderImportance)
end

% auxiliar variables
auxUnion = split(nameUnion, '_');
tipoSP           = auxUnion(2);
tipoSigma        = auxUnion(3);

% The values of both classes to be used (both actual and aggregated) are identified
predictClassArray = ["ClassShiptype", "ClassManeuver", "Cargo", "Fishing", "Passenger", "Tanker", "OtherShip", "EngagedFishing", "Restricted", "Sailing", "Engine", "OtherManeuver", "isClassShiptype4Major", "isClassShiptype5Major", "isClassManeuver4Major"];
binaryClassesShipType = ["Cargo", "Fishing", "Passenger", "Tanker", "OtherShip"];
binaryClassesManeuver = ["EngagedFishing", "Restricted", "Sailing", "Engine", "OtherManeuver"];

% CSV and Workspace results names
resultName = strcat(                  ...
    num2str(predictClass),       '_', ...
    num2str(deleteVarsType),     '_', ...
    num2str(classifierType),     '_', ...
    num2str(balanceType),        '_', ...
    num2str(normalizeType),      '_', ...
    num2str(trainTestType),      '_', ...
    num2str(importanceVars),     '_', ...
    num2str(doVector),           '_', ...
    nameUnion,                   '_', ...
    featureExtraction                     ...
    );

% Neighbour file name (for SMOTE balance algorithm)
neighbourName = strcat(               ...
    "neighbour",                 "_", ...
    num2str(predictClass),       '_', ...
    num2str(deleteVarsType),         '_', ...
    num2str(tipoSP),             '_', ...
    num2str(tipoSigma),          '_', ...
    num2str(trainTestType));

fullFileRead           = strcat(folderRead,           '/', featureExtraction, extensionCSV);  % 
fileWorkspaceRead      = strcat(folderWorkspaceRead,  '/', featureExtraction, extensionMAT);  % 
resultCSVFileWrite     = strcat(folderWrite,          '/', resultName, extensionCSV);     % 
resultMATFileWrite     = strcat(folderWorkspaceWrite, '/', resultName, extensionMAT);     % 
pathFileVectors        = strcat(folderVectorsWrite,   '/', resultName, extensionCSV);     % 
fileWorkspaceNeighbour = strcat(folderWorkspaceNN,    '/', neighbourName, extensionMAT);  % 
fileImportanceVars     = strcat(folderImportance,     '/', resultName, extensionCSV);     % 


%% Start the process
if isfile(resultMATFileWrite)     % if both CSV and Workspace files exist, it do not process anything
    if isfile(resultCSVFileWrite)
        return
    end
    load(resultMATFileWrite); % Read the Workspace file, but do not process
else
    % the process is not performed, read the features (CSV or Workspace)
    if isfile(fileWorkspaceRead)
        load(fileWorkspaceRead, 'DataTable', 'ClassesTable');
        
    else
        [DataTable, ClassesTable] = readWriteFunctions.readExtractedFeatures(fullFileRead);
        [ClassesTable] = createAuxClasses(ClassesTable, binaryClassesShipType, binaryClassesManeuver);
        save(fileWorkspaceRead);
    end
    
    % return % Done if only want to generate the Workspace auxiliar files 
    
    %% Create the auxiliar class types and select the one (if binary process)
    selectedClass = 0;
    nonSelectedClasses  = [];
    ClassesTable.Properties.VariableNames;
    isManeuver = find(ismember(binaryClassesManeuver, predictClassArray(predictClass)));
    isShipType = find(ismember(binaryClassesShipType, predictClassArray(predictClass)));
    
    if isManeuver > 0     % maneuver is a binary class
        posThisClass = find( strcmp(ClassesTable.Properties.VariableNames,  predictClassArray(predictClass)));
        if posThisClass > 0
            ClassName = strcat("is", predictClassArray(predictClass)); % create it
            clasePredictMatrix = ClassesTable.(ClassName);
        end
        selectedClass       = posThisClass; % Select the one
        % the other ones to the non selected classes
        for i=1:length(binaryClassesManeuver)
            if ~strcmp(predictClassArray(predictClass), binaryClassesManeuver(i))
                isClass = strcat("is", binaryClassesManeuver(i));
                nonSelectedClasses(end+1) = find( strcmp(ClassesTable.Properties.VariableNames, isClass) );
            end
        end
        
    elseif isShipType > 0 % the same process with the ship type
        ClassName = strcat("is", predictClassArray(predictClass));
        posThisClass = find( strcmp(ClassesTable.Properties.VariableNames, ClassName));
        if posThisClass > 0
            clasePredictMatrix = ClassesTable.(ClassName);
        end
        selectedClass       = posThisClass;
        
        for i=1:length(binaryClassesShipType)
            if ~strcmp(predictClassArray(predictClass), binaryClassesShipType(i))
                isClass = strcat("is", binaryClassesShipType(i)); % isCargo, is...
                nonSelectedClasses(end+1) = find( strcmp(ClassesTable.Properties.VariableNames, isClass) );
            end
        end
        
    else                  % Is a multiclass
        auxClassName = predictClassArray(predictClass);
        ClassName = strcat(auxClassName);
        posThisClass = find( strcmp(ClassesTable.Properties.VariableNames, auxClassName));
        if posThisClass > 0
            clasePredictMatrix = ClassesTable.(auxClassName);
        end
        selectedClass = posThisClass;
    end
    
    %% Apply the selected process
    %DataTableOriginal = DataTable; % save the original table, if necessary
    
    %%%%%%%%%%%%%%%%%%%%%%%% REMOVING VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    originalVars = DataTable.Properties.VariableNames; % Se apuntan las variables originales de la tabla
    DataTable = deleteSomeVars(DataTable, deleteVarsType);
    selectedVars = DataTable.Properties.VariableNames; % Se apuntan las variables seleccionadas tras eliminar alguna
    DataMatrix = DataTable{:,:};    % Tiene todo menos MMSI y los tiempos en posix
    DataTableHeaders = DataTable.Properties.VariableNames;
    DataTable = []; % Para limpiar memoria
    
    %%%%%%%%%%%%%%%%%%%%%%% TRAIN-TEST SPLITTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [DataTrain, DataTest, ClassesTableTrain, ClassesTableTest] = createTrainTest(DataMatrix, ClassesTable, trainTestType, selectedClass, nonSelectedClasses);
    
    %%%%%%%%%%%%%%%%%%%%%%%%% BALANCING CLASSES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [DataTrain, ClassesTableTrain] = balancerProcess(DataTrain, balanceType, ClassesTableTrain, selectedClass, nonSelectedClasses, fileWorkspaceNeighbour);
    
    %%%%%%%%%%%%%%%%%%%%%%% NORMALIZING VALUES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if normalizeType == 1
        [m,n] = size(DataTrain);
        for i=1:n                   % Getting the maximum value of this column
            DataTrain(:,i) = normalize(DataTrain(:,i),'range');
        end
        [m,n] = size(DataTest); % Normalizing each column
        for i=1:n                   
            DataTest(:,i) = normalize(DataTest(:,i),'range');
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%% CLASSIFYING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [accuracyTest, confusionMatrix, labels, classifier, avgVector] = ...
    classifiersProcess(DataTrain, DataTest, ClassesTableTrain.(ClassName), ClassesTableTest.(ClassName), classifierType, predictClass, DataTableHeaders, resultName, doVector);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% EXTRA PROCESSES %%%%%%%%%%%%%%%%%%%%%%%%%%%
    getImportanceVarsOnClassify(fileImportanceVars, importanceVars, classifierType, classifier, originalVars, selectedVars);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SAVING RESULTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    save(resultMATFileWrite);

end

% Writing resuls on a CSV
readWriteFunctions.writeClassificationResults(resultCSVFileWrite, labels, confusionMatrix, DataMatrix, tipoSP, tipoSigma, predictClass, deleteVarsType, classifierType, balanceType, normalizeType, trainTestType, importanceVars, doVector, accuracyTest);

% Perform the vector process
if doVector == true
    if isfile(pathFileVectors)
        delete(pathFileVectors);
    end
    readWriteFunctions.writeClassificationVectorHeaders(pathFileVectors, DataTableHeaders);
    readWriteFunctions.writeClassificationVector(pathFileVectors, avgVector, classifierType, predictClass);
end

end