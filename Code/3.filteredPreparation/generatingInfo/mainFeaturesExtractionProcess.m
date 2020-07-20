%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desarrollado por | Developed by:                     %
% University Carlos III of Madrid PhD Researchers      %
% Daniel Amigo Herrero    mailto: damigo@inf.uc3m.es   %
% David Sanchez Pedroche  mailto: davsanch@inf.uc3m.es %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Script para clasificar trazas IMM - pre-etiquetadas

function mainFeaturesExtractionProcess(unionName, SegAlgName)

message = strcat("START featureExtractionmainExtractInfo ", unionName, " ", SegAlgName);
telegramMessage(message);

% feature extraction using IMM mode probabilities. Threshold to count the entries on each mode. Works only with 2 modes
threshold.TopMode1 = 0.9;
threshold.BottomMode1   = 0.6;
threshold.BottomMode2 = 0.4;
threshold.TopMode2   = 0.1;

% create the files and folders names
extension = '.csv';
folderWrite = strcat('Data/', unionName, "/", "Preclassifier");
if ~exist(folderWrite, 'dir')  % Los Preclassifier
    mkdir(folderWrite)
end
folderRead = strcat('Data/', unionName, "/", "Splitted", "/", SegAlgName, "/");
aux = split(unionName,'_');
sp = aux(2);
errorValue = aux(3);
nameFileWrite = strcat(folderWrite,'/', SegAlgName, extension);    % Fichero de escritura
nameFileMAT = strcat(folderWrite,'/', SegAlgName, ".mat");    % Fichero de escritura
nameFileWrite = nameFileWrite{1};


if ~isfile(nameFileWrite) % if the file exists, this process was done previously
    
    allFiles = dir(strcat(folderRead,'/*.*'));
    allFiles([allFiles.isdir]) = [];   %skip directories
    
    % initialize all the vectors to work on parallel mode
    preAllocateFeaturesArrays;
    
    parfor k=1:length(allFiles)
    %for k=300:310 %length(allFiles) 
        nameFileRead = allFiles(k,1).name;
        fullFileRead = strcat(folderRead,'/',nameFileRead);
        nameTime = split(nameFileRead,'_split');
        nameTime = string(nameTime{1});
        disp("start " + k + " " + nameFileRead);
        
        [Data] = readWriteFunctions.readFiltered(fullFileRead); % Read the values
        
        if height(Data) == 1 % If the track has only 1 entry
            continue
        elseif height(Data) == 2
            %disp("HOLA");
        end
        
        % Extracts all the features per mode
        [speedVariation, speed, distance, directionVariation, timeGap, HighMode1, LowMode1, SwitchingMode, HighMode2, LowMode2, thisMMSI, thisFirstTimeConsecutive, thisFirstTimeManeuver, thisTotalTime, thisClassShiptype, thisClassManeuver, thisShipWidth, thisShipLength] = ...
            featuresExtractionProcess(Data, nameTime, threshold);
        
        %% Store each feature using its statistic values
        speedVariationTotalSum(k,1)             = sum(speedVariation.Total);          % Sum
        speedTotalSum(k,1)                      = sum(speed.Total);
        distanceTotalSum(k,1)                   = sum(distance.Total);
        directionVariationTotalSum(k,1)         = sum(directionVariation.Total);
        timeGapTotalSum(k,1)                    = sum(timeGap.Total);
        speedVariationHighMode1Sum(k,1)         = sum(speedVariation.HighMode1);
        speedHighMode1Sum(k,1)                  = sum(speed.HighMode1);
        distanceHighMode1Sum(k,1)               = sum(distance.HighMode1);
        directionVariationHighMode1Sum(k,1)     = sum(directionVariation.HighMode1);
        timeGapHighMode1Sum(k,1)                = sum(timeGap.HighMode1);
        speedVariationLowMode1Sum(k,1)          = sum(speedVariation.LowMode1);
        speedLowMode1Sum(k,1)                   = sum(speed.LowMode1);
        distanceLowMode1Sum(k,1)                = sum(distance.LowMode1);
        directionVariationLowMode1Sum(k,1)      = sum(directionVariation.LowMode1);
        timeGapLowMode1Sum(k,1)                 = sum(timeGap.LowMode1);
        speedVariationSwitchingModeSum(k,1)     = sum(speedVariation.SwitchingMode);
        speedSwitchingModeSum(k,1)              = sum(speed.SwitchingMode);
        distanceSwitchingModeSum(k,1)           = sum(distance.SwitchingMode);
        directionVariationSwitchingModeSum(k,1) = sum(directionVariation.SwitchingMode);
        timeGapSwitchingModeSum(k,1)            = sum(timeGap.SwitchingMode);
        speedVariationLowMode2Sum(k,1)          = sum(speedVariation.LowMode2);
        speedLowMode2Sum(k,1)                   = sum(speed.LowMode2);
        distanceLowMode2Sum(k,1)                = sum(distance.LowMode2);
        directionVariationLowMode2Sum(k,1)      = sum(directionVariation.LowMode2);
        timeGapLowMode2Sum(k,1)                 = sum(timeGap.LowMode2);
        speedVariationHighMode2Sum(k,1)         = sum(speedVariation.HighMode2);
        speedHighMode2Sum(k,1)                  = sum(speed.HighMode2);
        distanceHighMode2Sum(k,1)               = sum(distance.HighMode2);
        directionVariationHighMode2Sum(k,1)     = sum(directionVariation.HighMode2);
        timeGapHighMode2Sum(k,1)                = sum(timeGap.HighMode2);
        speedVariationTotalMax(k,1)             = max(speedVariation.Total);          % Maximum values
        speedTotalMax(k,1)                      = max(speed.Total);
        distanceTotalMax(k,1)                   = max(distance.Total);
        directionVariationTotalMax(k,1)         = max(directionVariation.Total);
        timeGapTotalMax(k,1)                    = max(timeGap.Total);
        speedVariationHighMode1Max(k,1)         = max(speedVariation.HighMode1);
        speedHighMode1Max(k,1)                  = max(speed.HighMode1);
        distanceHighMode1Max(k,1)               = max(distance.HighMode1);
        directionVariationHighMode1Max(k,1)     = max(directionVariation.HighMode1);
        timeGapHighMode1Max(k,1)                = max(timeGap.HighMode1);
        speedVariationLowMode1Max(k,1)          = max(speedVariation.LowMode1);
        speedLowMode1Max(k,1)                   = max(speed.LowMode1);
        distanceLowMode1Max(k,1)                = max(distance.LowMode1);
        directionVariationLowMode1Max(k,1)      = max(directionVariation.LowMode1);
        timeGapLowMode1Max(k,1)                 = max(timeGap.LowMode1);
        speedVariationSwitchingModeMax(k,1)     = max(speedVariation.SwitchingMode);
        speedSwitchingModeMax(k,1)              = max(speed.SwitchingMode);
        distanceSwitchingModeMax(k,1)           = max(distance.SwitchingMode);
        directionVariationSwitchingModeMax(k,1) = max(directionVariation.SwitchingMode);
        timeGapSwitchingModeMax(k,1)            = max(timeGap.SwitchingMode);
        speedVariationLowMode2Max(k,1)          = max(speedVariation.LowMode2);
        speedLowMode2Max(k,1)                   = max(speed.LowMode2);
        distanceLowMode2Max(k,1)                = max(distance.LowMode2);
        directionVariationLowMode2Max(k,1)      = max(directionVariation.LowMode2);
        timeGapLowMode2Max(k,1)                 = max(timeGap.LowMode2);
        speedVariationHighMode2Max(k,1)         = max(speedVariation.HighMode2);
        speedHighMode2Max(k,1)                  = max(speed.HighMode2);
        distanceHighMode2Max(k,1)               = max(distance.HighMode2);
        directionVariationHighMode2Max(k,1)     = max(directionVariation.HighMode2);
        timeGapHighMode2Max(k,1)                = max(timeGap.HighMode2);
        speedVariationTotalMin(k,1)             = min(speedVariation.Total);          % Minimum values
        speedTotalMin(k,1)                      = min(speed.Total);
        distanceTotalMin(k,1)                   = min(distance.Total);
        directionVariationTotalMin(k,1)         = min(directionVariation.Total);
        timeGapTotalMin(k,1)                    = min(timeGap.Total);
        speedVariationHighMode1Min(k,1)         = min(speedVariation.HighMode1);
        speedHighMode1Min(k,1)                  = min(speed.HighMode1);
        distanceHighMode1Min(k,1)               = min(distance.HighMode1);
        directionVariationHighMode1Min(k,1)     = min(directionVariation.HighMode1);
        timeGapHighMode1Min(k,1)                = min(timeGap.HighMode1);
        speedVariationLowMode1Min(k,1)          = min(speedVariation.LowMode1);
        speedLowMode1Min(k,1)                   = min(speed.LowMode1);
        distanceLowMode1Min(k,1)                = min(distance.LowMode1);
        directionVariationLowMode1Min(k,1)      = min(directionVariation.LowMode1);
        timeGapLowMode1Min(k,1)                 = min(timeGap.LowMode1);
        speedVariationSwitchingModeMin(k,1)     = min(speedVariation.SwitchingMode);
        speedSwitchingModeMin(k,1)              = min(speed.SwitchingMode);
        distanceSwitchingModeMin(k,1)           = min(distance.SwitchingMode);
        directionVariationSwitchingModeMin(k,1) = min(directionVariation.SwitchingMode);
        timeGapSwitchingModeMin(k,1)            = min(timeGap.SwitchingMode);
        speedVariationLowMode2Min(k,1)          = min(speedVariation.LowMode2);
        speedLowMode2Min(k,1)                   = min(speed.LowMode2);
        distanceLowMode2Min(k,1)                = min(distance.LowMode2);
        directionVariationLowMode2Min(k,1)      = min(directionVariation.LowMode2);
        timeGapLowMode2Min(k,1)                 = min(timeGap.LowMode2);
        speedVariationHighMode2Min(k,1)         = min(speedVariation.HighMode2);
        speedHighMode2Min(k,1)                  = min(speed.HighMode2);
        distanceHighMode2Min(k,1)               = min(distance.HighMode2);
        directionVariationHighMode2Min(k,1)     = min(directionVariation.HighMode2);
        timeGapHighMode2Min(k,1)                = min(timeGap.HighMode2);
        speedVariationTotalMean(k,1)            = mean(speedVariation.Total);        % Mean
        speedTotalMean(k,1)                     = mean(speed.Total);
        distanceTotalMean(k,1)                  = mean(distance.Total);
        directionVariationTotalMean(k,1)        = mean(directionVariation.Total);
        timeGapTotalMean(k,1)                   = mean(timeGap.Total);
        speedVariationHighMode1Mean(k,1)        = mean(speedVariation.HighMode1);
        speedHighMode1Mean(k,1)                 = mean(speed.HighMode1);
        distanceHighMode1Mean(k,1)              = mean(distance.HighMode1);
        directionVariationHighMode1Mean(k,1)    = mean(directionVariation.HighMode1);
        timeGapHighMode1Mean(k,1)               = mean(timeGap.HighMode1);
        speedVariationLowMode1Mean(k,1)         = mean(speedVariation.LowMode1);
        speedLowMode1Mean(k,1)                  = mean(speed.LowMode1);
        distanceLowMode1Mean(k,1)               = mean(distance.LowMode1);
        directionVariationLowMode1Mean(k,1)     = mean(directionVariation.LowMode1);
        timeGapLowMode1Mean(k,1)                = mean(timeGap.LowMode1);
        speedVariationSwitchingModeMean(k,1)    = mean(speedVariation.SwitchingMode);
        speedSwitchingModeMean(k,1)             = mean(speed.SwitchingMode);
        distanceSwitchingModeMean(k,1)          = mean(distance.SwitchingMode);
        directionVariationSwitchingModeMean(k,1)= mean(directionVariation.SwitchingMode);
        timeGapSwitchingModeMean(k,1)           = mean(timeGap.SwitchingMode);
        speedVariationLowMode2Mean(k,1)         = mean(speedVariation.LowMode2);
        speedLowMode2Mean(k,1)                  = mean(speed.LowMode2);
        distanceLowMode2Mean(k,1)               = mean(distance.LowMode2);
        directionVariationLowMode2Mean(k,1)     = mean(directionVariation.LowMode2);
        timeGapLowMode2Mean(k,1)                = mean(timeGap.LowMode2);
        speedVariationHighMode2Mean(k,1)        = mean(speedVariation.HighMode2);
        speedHighMode2Mean(k,1)                 = mean(speed.HighMode2);
        distanceHighMode2Mean(k,1)              = mean(distance.HighMode2);
        directionVariationHighMode2Mean(k,1)    = mean(directionVariation.HighMode2);
        timeGapHighMode2Mean(k,1)               = mean(timeGap.HighMode2);
        speedVariationTotalStd(k,1)             = std(speedVariation.Total);          % Standard deviation
        speedTotalStd(k,1)                      = std(speed.Total);
        distanceTotalStd(k,1)                   = std(distance.Total);
        directionVariationTotalStd(k,1)         = std(directionVariation.Total);
        timeGapTotalStd(k,1)                    = std(timeGap.Total);
        speedVariationHighMode1Std(k,1)         = std(speedVariation.HighMode1);
        speedHighMode1Std(k,1)                  = std(speed.HighMode1);
        distanceHighMode1Std(k,1)               = std(distance.HighMode1);
        directionVariationHighMode1Std(k,1)     = std(directionVariation.HighMode1);
        timeGapHighMode1Std(k,1)                = std(timeGap.HighMode1);
        speedVariationLowMode1Std(k,1)          = std(speedVariation.LowMode1);
        speedLowMode1Std(k,1)                   = std(speed.LowMode1);
        distanceLowMode1Std(k,1)                = std(distance.LowMode1);
        directionVariationLowMode1Std(k,1)      = std(directionVariation.LowMode1);
        timeGapLowMode1Std(k,1)                 = std(timeGap.LowMode1);
        speedVariationSwitchingModeStd(k,1)     = std(speedVariation.SwitchingMode);
        speedSwitchingModeStd(k,1)              = std(speed.SwitchingMode);
        distanceSwitchingModeStd(k,1)           = std(distance.SwitchingMode);
        directionVariationSwitchingModeStd(k,1) = std(directionVariation.SwitchingMode);
        timeGapSwitchingModeStd(k,1)            = std(timeGap.SwitchingMode);
        speedVariationLowMode2Std(k,1)          = std(speedVariation.LowMode2);
        speedLowMode2Std(k,1)                   = std(speed.LowMode2);
        distanceLowMode2Std(k,1)                = std(distance.LowMode2);
        directionVariationLowMode2Std(k,1)      = std(directionVariation.LowMode2);
        timeGapLowMode2Std(k,1)                 = std(timeGap.LowMode2);
        speedVariationHighMode2Std(k,1)         = std(speedVariation.HighMode2);
        speedHighMode2Std(k,1)                  = std(speed.HighMode2);
        distanceHighMode2Std(k,1)               = std(distance.HighMode2);
        directionVariationHighMode2Std(k,1)     = std(directionVariation.HighMode2);
        timeGapHighMode2Std(k,1)                = std(timeGap.HighMode2);
        speedVariationTotalMode(k,1)            = mode(speedVariation.Total);        % Mode
        speedTotalMode(k,1)                     = mode(speed.Total);
        distanceTotalMode(k,1)                  = mode(distance.Total);
        directionVariationTotalMode(k,1)        = mode(directionVariation.Total);
        timeGapTotalMode(k,1)                   = mode(timeGap.Total);
        speedVariationHighMode1Mode(k,1)        = mode(speedVariation.HighMode1);
        speedHighMode1Mode(k,1)                 = mode(speed.HighMode1);
        distanceHighMode1Mode(k,1)              = mode(distance.HighMode1);
        directionVariationHighMode1Mode(k,1)    = mode(directionVariation.HighMode1);
        timeGapHighMode1Mode(k,1)               = mode(timeGap.HighMode1);
        speedVariationLowMode1Mode(k,1)         = mode(speedVariation.LowMode1);
        speedLowMode1Mode(k,1)                  = mode(speed.LowMode1);
        distanceLowMode1Mode(k,1)               = mode(distance.LowMode1);
        directionVariationLowMode1Mode(k,1)     = mode(directionVariation.LowMode1);
        timeGapLowMode1Mode(k,1)                = mode(timeGap.LowMode1);
        speedVariationSwitchingModeMode(k,1)    = mode(speedVariation.SwitchingMode);
        speedSwitchingModeMode(k,1)             = mode(speed.SwitchingMode);
        distanceSwitchingModeMode(k,1)          = mode(distance.SwitchingMode);
        directionVariationSwitchingModeMode(k,1)= mode(directionVariation.SwitchingMode);
        timeGapSwitchingModeMode(k,1)           = mode(timeGap.SwitchingMode);
        speedVariationLowMode2Mode(k,1)         = mode(speedVariation.LowMode2);
        speedLowMode2Mode(k,1)                  = mode(speed.LowMode2);
        distanceLowMode2Mode(k,1)               = mode(distance.LowMode2);
        directionVariationLowMode2Mode(k,1)     = mode(directionVariation.LowMode2);
        timeGapLowMode2Mode(k,1)                = mode(timeGap.LowMode2);
        speedVariationHighMode2Mode(k,1)        = mode(speedVariation.HighMode2);
        speedHighMode2Mode(k,1)                 = mode(speed.HighMode2);
        distanceHighMode2Mode(k,1)              = mode(distance.HighMode2);
        directionVariationHighMode2Mode(k,1)    = mode(directionVariation.HighMode2);
        timeGapHighMode2Mode(k,1)               = mode(timeGap.HighMode2);
        speedVariationTotalQ1(k,1)              = prctile(speedVariation.Total,25);        % First quartile
        speedTotalQ1(k,1)                       = prctile(speed.Total,25);
        distanceTotalQ1(k,1)                    = prctile(distance.Total,25);
        directionVariationTotalQ1(k,1)          = prctile(directionVariation.Total,25);
        timeGapTotalQ1(k,1)                     = prctile(timeGap.Total,25);
        speedVariationHighMode1Q1(k,1)          = prctile(speedVariation.HighMode1,25);
        speedHighMode1Q1(k,1)                   = prctile(speed.HighMode1,25);
        distanceHighMode1Q1(k,1)                = prctile(distance.HighMode1,25);
        directionVariationHighMode1Q1(k,1)      = prctile(directionVariation.HighMode1,25);
        timeGapHighMode1Q1(k,1)                 = prctile(timeGap.HighMode1,25);
        speedVariationLowMode1Q1(k,1)           = prctile(speedVariation.LowMode1,25);
        speedLowMode1Q1(k,1)                    = prctile(speed.LowMode1,25);
        distanceLowMode1Q1(k,1)                 = prctile(distance.LowMode1,25);
        directionVariationLowMode1Q1(k,1)       = prctile(directionVariation.LowMode1,25);
        timeGapLowMode1Q1(k,1)                  = prctile(timeGap.LowMode1,25);
        speedVariationSwitchingModeQ1(k,1)      = prctile(speedVariation.SwitchingMode,25);
        speedSwitchingModeQ1(k,1)               = prctile(speed.SwitchingMode,25);
        distanceSwitchingModeQ1(k,1)            = prctile(distance.SwitchingMode,25);
        directionVariationSwitchingModeQ1(k,1)  = prctile(directionVariation.SwitchingMode,25);
        timeGapSwitchingModeQ1(k,1)             = prctile(timeGap.SwitchingMode,25);
        speedVariationLowMode2Q1(k,1)           = prctile(speedVariation.LowMode2,25);
        speedLowMode2Q1(k,1)                    = prctile(speed.LowMode2,25);
        distanceLowMode2Q1(k,1)                 = prctile(distance.LowMode2,25);
        directionVariationLowMode2Q1(k,1)       = prctile(directionVariation.LowMode2,25);
        timeGapLowMode2Q1(k,1)                  = prctile(timeGap.LowMode2,25);
        speedVariationHighMode2Q1(k,1)          = prctile(speedVariation.HighMode2,25);
        speedHighMode2Q1(k,1)                   = prctile(speed.HighMode2,25);
        distanceHighMode2Q1(k,1)                = prctile(distance.HighMode2,25);
        directionVariationHighMode2Q1(k,1)      = prctile(directionVariation.HighMode2,25);
        timeGapHighMode2Q1(k,1)                 = prctile(timeGap.HighMode2,25);
        speedVariationTotalQ2(k,1)              = prctile(speedVariation.Total,50);        % Second quartile
        speedTotalQ2(k,1)                       = prctile(speed.Total,50);
        distanceTotalQ2(k,1)                    = prctile(distance.Total,50);
        directionVariationTotalQ2(k,1)          = prctile(directionVariation.Total,50);
        timeGapTotalQ2(k,1)                     = prctile(timeGap.Total,50);
        speedVariationHighMode1Q2(k,1)          = prctile(speedVariation.HighMode1,50);
        speedHighMode1Q2(k,1)                   = prctile(speed.HighMode1,50);
        distanceHighMode1Q2(k,1)                = prctile(distance.HighMode1,50);
        directionVariationHighMode1Q2(k,1)      = prctile(directionVariation.HighMode1,50);
        timeGapHighMode1Q2(k,1)                 = prctile(timeGap.HighMode1,50);
        speedVariationLowMode1Q2(k,1)           = prctile(speedVariation.LowMode1,50);
        speedLowMode1Q2(k,1)                    = prctile(speed.LowMode1,50);
        distanceLowMode1Q2(k,1)                 = prctile(distance.LowMode1,50);
        directionVariationLowMode1Q2(k,1)       = prctile(directionVariation.LowMode1,50);
        timeGapLowMode1Q2(k,1)                  = prctile(timeGap.LowMode1,50);
        speedVariationSwitchingModeQ2(k,1)      = prctile(speedVariation.SwitchingMode,50);
        speedSwitchingModeQ2(k,1)               = prctile(speed.SwitchingMode,50);
        distanceSwitchingModeQ2(k,1)            = prctile(distance.SwitchingMode,50);
        directionVariationSwitchingModeQ2(k,1)  = prctile(directionVariation.SwitchingMode,50);
        timeGapSwitchingModeQ2(k,1)             = prctile(timeGap.SwitchingMode,50);
        speedVariationLowMode2Q2(k,1)           = prctile(speedVariation.LowMode2,50);
        speedLowMode2Q2(k,1)                    = prctile(speed.LowMode2,50);
        distanceLowMode2Q2(k,1)                 = prctile(distance.LowMode2,50);
        directionVariationLowMode2Q2(k,1)       = prctile(directionVariation.LowMode2,50);
        timeGapLowMode2Q2(k,1)                  = prctile(timeGap.LowMode2,50);
        speedVariationHighMode2Q2(k,1)          = prctile(speedVariation.HighMode2,50);
        speedHighMode2Q2(k,1)                   = prctile(speed.HighMode2,50);
        distanceHighMode2Q2(k,1)                = prctile(distance.HighMode2,50);
        directionVariationHighMode2Q2(k,1)      = prctile(directionVariation.HighMode2,50);
        timeGapHighMode2Q2(k,1)                 = prctile(timeGap.HighMode2,50);
        speedVariationTotalQ3(k,1)              = prctile(speedVariation.Total,75);        % Third quartile
        speedTotalQ3(k,1)                       = prctile(speed.Total,75);
        distanceTotalQ3(k,1)                    = prctile(distance.Total,75);
        directionVariationTotalQ3(k,1)          = prctile(directionVariation.Total,75);
        timeGapTotalQ3(k,1)                     = prctile(timeGap.Total,75);
        speedVariationHighMode1Q3(k,1)          = prctile(speedVariation.HighMode1,75);
        speedHighMode1Q3(k,1)                   = prctile(speed.HighMode1,75);
        distanceHighMode1Q3(k,1)                = prctile(distance.HighMode1,75);
        directionVariationHighMode1Q3(k,1)      = prctile(directionVariation.HighMode1,75);
        timeGapHighMode1Q3(k,1)                 = prctile(timeGap.HighMode1,75);
        speedVariationLowMode1Q3(k,1)           = prctile(speedVariation.LowMode1,75);
        speedLowMode1Q3(k,1)                    = prctile(speed.LowMode1,75);
        distanceLowMode1Q3(k,1)                 = prctile(distance.LowMode1,75);
        directionVariationLowMode1Q3(k,1)       = prctile(directionVariation.LowMode1,75);
        timeGapLowMode1Q3(k,1)                  = prctile(timeGap.LowMode1,75);
        speedVariationSwitchingModeQ3(k,1)      = prctile(speedVariation.SwitchingMode,75);
        speedSwitchingModeQ3(k,1)               = prctile(speed.SwitchingMode,75);
        distanceSwitchingModeQ3(k,1)            = prctile(distance.SwitchingMode,75);
        directionVariationSwitchingModeQ3(k,1)  = prctile(directionVariation.SwitchingMode,75);
        timeGapSwitchingModeQ3(k,1)             = prctile(timeGap.SwitchingMode,75);
        speedVariationLowMode2Q3(k,1)           = prctile(speedVariation.LowMode2,75);
        speedLowMode2Q3(k,1)                    = prctile(speed.LowMode2,75);
        distanceLowMode2Q3(k,1)                 = prctile(distance.LowMode2,75);
        directionVariationLowMode2Q3(k,1)       = prctile(directionVariation.LowMode2,75);
        timeGapLowMode2Q3(k,1)                  = prctile(timeGap.LowMode2,75);
        speedVariationHighMode2Q3(k,1)          = prctile(speedVariation.HighMode2,75);
        speedHighMode2Q3(k,1)                   = prctile(speed.HighMode2,75);
        distanceHighMode2Q3(k,1)                = prctile(distance.HighMode2,75);
        directionVariationHighMode2Q3(k,1)      = prctile(directionVariation.HighMode2,75);
        timeGapHighMode2Q3(k,1)                 = prctile(timeGap.HighMode2,75);
        
        % continue in the same filter mode
        continueSameMode(k,1)            = HighMode1.HighMode1 + LowMode1.LowMode1 + SwitchingMode.SwitchingMode + LowMode2.LowMode2 + HighMode2.HighMode2;
        % switching from the previous mode
        HighMode1Out(k,1)                = LowMode1.HighMode1 + SwitchingMode.HighMode1 + LowMode2.HighMode1 + HighMode2.HighMode1;
        LowMode1Out(k,1)                 = HighMode1.LowMode1 + SwitchingMode.LowMode1 + LowMode2.LowMode1 + HighMode2.LowMode1;
        SwitchingModeOut(k,1)            = HighMode1.SwitchingMode    + LowMode1.SwitchingMode + LowMode2.SwitchingMode    + HighMode2.SwitchingMode;
        LowMode2Out(k,1)                 = HighMode1.LowMode2 + LowMode1.LowMode2 + SwitchingMode.LowMode2 + HighMode2.LowMode2;
        HighMode2Out(k,1)                = HighMode1.HighMode2 + LowMode1.HighMode2 + SwitchingMode.HighMode2 + LowMode2.HighMode2;
        % switching into that filter mode
        HighMode1In(k,1)                 = HighMode1.LowMode1 + HighMode1.SwitchingMode + HighMode1.HighMode2 + HighMode1.LowMode2;
        LowMode1In(k,1)                  = LowMode1.HighMode1 + LowMode1.SwitchingMode + LowMode1.HighMode2 + LowMode1.LowMode2;
        SwitchingModeIn(k,1)             = SwitchingMode.HighMode1 + SwitchingMode.LowMode1 + SwitchingMode.HighMode2 + SwitchingMode.LowMode2;
        LowMode2In(k,1)                  = LowMode2.HighMode1 + LowMode2.LowMode1 + LowMode2.SwitchingMode + LowMode2.HighMode2;
        HighMode2In(k,1)                 = HighMode2.HighMode1 + HighMode2.LowMode1 + HighMode2.SwitchingMode + HighMode2.LowMode2;
        % switching into that filter mode plus continuing on it
        HighMode1InPlusContinue(k,1)     = HighMode1.HighMode1 + HighMode1.LowMode1 + HighMode1.SwitchingMode + HighMode1.HighMode2 + HighMode1.LowMode2;
        LowMode1InPlusContinue(k,1)      = LowMode1.HighMode1 + LowMode1.LowMode1 + LowMode1.SwitchingMode + LowMode1.HighMode2 + LowMode1.LowMode2;
        SwitchingModeInPlusContinue(k,1) = SwitchingMode.HighMode1 + SwitchingMode.LowMode1 + SwitchingMode.SwitchingMode + SwitchingMode.HighMode2 + SwitchingMode.LowMode2;
        LowMode2InPlusContinue(k,1)      = LowMode2.HighMode1 + LowMode2.LowMode1 + LowMode2.SwitchingMode + LowMode2.HighMode2 + LowMode2.LowMode2;
        HighMode2InPlusContinue(k,1)     = HighMode2.HighMode1 + HighMode2.LowMode1 + HighMode2.SwitchingMode + HighMode2.HighMode2 + HighMode2.LowMode2;
        % counters
        HighMode1AHighMode1(k,1)         = HighMode1.HighMode1;
        HighMode1ALowMode1(k,1)          = HighMode1.LowMode1;
        HighMode1ASwitchingMode(k,1)     = HighMode1.SwitchingMode;
        HighMode1AHighMode2(k,1)         = HighMode1.HighMode2;
        HighMode1ALowMode2(k,1)          = HighMode1.LowMode2;
        LowMode1AHighMode1(k,1)          = LowMode1.HighMode1;
        LowMode1ALowMode1(k,1)           = LowMode1.LowMode1;
        LowMode1ASwitchingMode(k,1)      = LowMode1.SwitchingMode;
        LowMode1AHighMode2(k,1)          = LowMode1.HighMode2;
        LowMode1ALowMode2(k,1)           = LowMode1.LowMode2;
        SwitchingModeAHighMode1(k,1)     = SwitchingMode.HighMode1;
        SwitchingModeALowMode1(k,1)      = SwitchingMode.LowMode1;
        SwitchingModeASwitchingMode(k,1) = SwitchingMode.SwitchingMode;
        SwitchingModeAHighMode2(k,1)     = SwitchingMode.HighMode2;
        SwitchingModeALowMode2(k,1)      = SwitchingMode.LowMode2;
        HighMode2AHighMode1(k,1)         = HighMode2.HighMode1;
        HighMode2ALowMode1(k,1)          = HighMode2.LowMode1;
        HighMode2ASwitchingMode(k,1)     = HighMode2.SwitchingMode;
        HighMode2AHighMode2(k,1)         = HighMode2.HighMode2;
        HighMode2ALowMode2(k,1)          = HighMode2.LowMode2;
        LowMode2AHighMode1(k,1)          = LowMode2.HighMode1;
        LowMode2ALowMode1(k,1)           = LowMode2.LowMode1;
        LowMode2ASwitchingMode(k,1)      = LowMode2.SwitchingMode;
        LowMode2AHighMode2(k,1)          = LowMode2.HighMode2;
        LowMode2ALowMode2(k,1)           = LowMode2.LowMode2;
        % Auxiliar variables
        MMSI(k,1)                 = thisMMSI;
        FirstTimeConsecutive(k,1) = thisFirstTimeConsecutive;
        FirstTimeManeuver(k,1)    = thisFirstTimeManeuver;
        TotalTime(k,1)            = thisTotalTime;
        ClassShipType(k,1)        = thisClassShiptype;
        ClassManeuver(k,1)        = thisClassManeuver;
        shipWidth(k,1)            = thisShipWidth;
        shipLength(k,1)           = thisShipLength;
        
        %disp("end " + k + " " + nameFileRead);
    end % next file
    
    %% Once the loop is finished, the processed parts of the table are joined
    featuresToFinalTable;
    
    % All the entries that had only 1 entry, are empty, so them are cleaned now of the table
    idx = find(ClassificationData.TotalTime == 0);
    ClassificationData(idx,:) = [];
    
    % The results are saved
    save(nameFileMAT, 'ClassificationData', '-v7.3');                 % on a MAT file
    %readWriteFunctions.writeExtractedFeaturesHeader(nameFileWrite); % On a CSV file
    %readWriteFunctions.writeExtractedFeatures(ClassificationData, nameFileWrite);
    
    message = strcat("END featureExtractionmainExtractInfo ", unionName, " ", SegAlgName);
    telegramMessage(message);
end

end