%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desarrollado por | Developed by:                     %
% University Carlos III of Madrid PhD Researchers      %
% Daniel Amigo Herrero    mailto: damigo@inf.uc3m.es   %
% David Sanchez Pedroche  mailto: davsanch@inf.uc3m.es %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Se realiza todo el proceso del articulo. Desde los ficheros RAW: limpiado, filtrado, segmentacion, extraccion de caracteristicas y clasificacion
% The whole process of the paper is carried out. From the RAW AIS files: cleaning, filtering, segmentation, feature extraction and classification

try
    clear
    clc
    close all
    
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                    COMBINATIONS OF EACH PROCESS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Days selected of AIS Denmark to process
    days = ["Day25", "Day26", "Day27"]; %
    
    % Cleaned 
    cleanNoiseLatLon = [0 1];
    numCombinations = length(cleanNoiseLatLon);
    cleanedCombs = cell(numCombinations, 1);
    cnt = 1;
    for i=1:length(cleanNoiseLatLon)
        cleanedCombs{cnt}.cleanNoiseLatLon = cleanNoiseLatLon(i);
        cnt = cnt + 1;
    end
    
    % Timestamped
    %maxPeriod         = [Inf 11]; % seconds
    %minNumTracks      = [2 50];   % entries
    timestampedTypes  = [0 1 2];
    maxPeriod         = [11];      % seconds
    minNumTracks      = [50];      % entries
    thresholdMovement = [10];      % entries
    % Create all the combinations
    numCombinations = length(timestampedTypes)*length(maxPeriod)*length(minNumTracks)*length(thresholdMovement);
    timestampedCombs = cell(numCombinations, 1);
    cnt = 1;
    for i=1:length(timestampedTypes)
        for j=1:length(maxPeriod)
            for k=1:length(minNumTracks)
                for l=1:length(thresholdMovement)
                    timestampedCombs{cnt}.type              = timestampedTypes(i);
                    timestampedCombs{cnt}.maxPeriod         = maxPeriod(j);
                    timestampedCombs{cnt}.minNumTracks      = minNumTracks(k);
                    timestampedCombs{cnt}.thresholdMovement = thresholdMovement(l);
                    cnt = cnt + 1;
                end
            end
        end
    end
    
    % Filtered
    immConfs = ["IMM_SP999_10"];
    filteredTypes = [0 1];
    % Create all the combinations
    numCombinations = length(immConfs)*length(filteredTypes);
    filteredCombs = cell(numCombinations, 1);
    cnt = 1;
    for i=1:length(immConfs)
        for j=1:length(filteredTypes)
            filteredCombs{cnt}.immConf = immConfs(i);
            filteredCombs{cnt}.type    = filteredTypes(j);
            cnt = cnt + 1;
        end
    end
    
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                       CLEANED PROCESS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i=1:length(days)
        for j=1:length(cleanedCombs)
            % mmsiToCleaned(days(i), cleanedCombs{j});
        end
    end
    telegramMessage("END CLEANEDS");
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                       TIMESTAMPED PROCESS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i=1:length(days)
        for j=1:length(cleanedCombs)
            for k=1:length(timestampedCombs)
                % cleanedToTimestamp(days(i), cleanedCombs{j}, timestampedCombs{k});
            end
        end
    end
    telegramMessage("END TIMESTAMPEDS");
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                       FILTRO IMM
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i=1:length(days)
        for j=1:length(cleanedCombs)
            for k=1:length(timestampedCombs)
                for l=1:length(filteredCombs)
                    % timestampFolderToFilter(days(i), cleanedCombs{j}, timestampedCombs{k}, filteredCombs{l});
                end
            end
        end
    end
    telegramMessage("END FILTEREDS");
    
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                       UNION
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    doneUnion = true; % not to redo the process again
    folderToMerge =  "Filtered";
    originalFolders = strings(length(immConfs), length(days));
    newFolder = strings(0,1);
    nameUnion = strings(0,1);

    % Create the names and perform the copy
    for j=1:length(cleanedCombs)
        for k=1:length(timestampedCombs)
            for l=1:length(filteredCombs)
                c = strcat("C", "_", num2str(cleanedCombs{j}.cleanNoiseLatLon));
                t = strcat("T", "_", num2str(timestampedCombs{k}.type), "_", num2str(timestampedCombs{k}.maxPeriod), "_", num2str(timestampedCombs{k}.minNumTracks), "_", num2str(timestampedCombs{k}.thresholdMovement));
                f = strcat("F", "_", num2str(filteredCombs{l}.immConf), "_", num2str(filteredCombs{l}.type));
                
                % Folders names
                nameUnion(end+1) = strcat("Union", "_", c, "_", t, "_", f);
                newFolder(end+1) = strcat("Data", "/", nameUnion(end), "/", folderToMerge, "/");
                
                if doneUnion == false % Copy the files if activated
                    if ~exist(newFolder(end), 'dir')  % Timestamped
                        mkdir(newFolder(end))
                    else
                        dinfo = dir(newFolder(end));
                        dinfo([dinfo.isdir]) = [];
                        filenames = fullfile(newFolder(end), {dinfo.name});
                        if size(filenames) > 0
                            delete( filenames{:} );
                        end
                    end
                    for i=1:length(days)
                        aux = strcat("Data", "/", days(i), "/", folderToMerge, "/", c, "_", t, "_", f);
                        copyfile(aux, newFolder(end));
                    end
                end
            end
        end
    end
    telegramMessage("END UNION");
    
    % In some experiments is necessary to fix it
    newFolder = ["Union_C_1_T_2_11_50_10_F_IMM_SP999_10_1"];
    nameUnion = ["Union_C_0_T_2_11_50_10_F_IMM_SP999_10_0"];
    % nameUnion = "";
    % newFolder = strcat("");
    
    for i=1:length(nameUnion)
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                    SEGMENTATION PROCESS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % performs the segmentation according to the selected algorithm and its parameters
        %%%%%%% segmentationAlgorithm.id
        % 1  - uniformSampling
        % 2  - openingWindow  
        % 3  - topDown        
        % 4  - bottomUp       
        % 5  - squish-e       
        % 6  - DOTS           
        % 7  - MRPA           
        % 8  - Nose           
        % 9  - deadReckoning  
        % 10 - STTrace        
        % 11 - Angular        
        % 12 - SP             
        % 13 - SQUISH         
        % 14 - CDR            
        % 15 - BQS            
        % 16 - OPERB          
        % 17 - Intersect
        % 18 - OLDCAT
        % 19 - SPM
        % 20 - TPMF
        % 21 - ErrorSearch
        % 22 - SpanSearch
        % 23 - SWAB
        % 24 - TraClus
        % 25 - Bellman
        % 26 - Opheim
        % 27 - ReumannWitkam
        % 28 - Radial
        % 29 - Lang
        % 30 - Visvalingam
        % 31 - Latecki
        % 32 - Zhao-Saalfeld
        % 33 - Anagnostopoulos 
        % 34 - HESAVE
        % 35 - Interval
        % 36 - KAA
        % 37 - FSW
        % 38 - Persistence
        % 39 - IC MBR
        % 40 - GRTS
        % 41 - ESTC-EDP
        % 42 - NaTS
        % 43 - Thresholds
        % 44 - TS
        % 45 - Simlarity
        % 46 - Min-Error
        % 47 - AACAT
        % 48 - CBSMoT
        % 49 - GRASPUTS
        % 50 - RGRASPSemTS
        % 51 - OWS
        % 52 - SMOT
        % 53 - SPD
        % 54 - SWS
        % 55 - WKMeans
        % 56 - WSII
        % 57 - SetraStream
        % 58 - SAS
        % 59 - SAOTS
        % 60 - 
        % 61 - 
        % 62 - 
        % 63 - 
        % 64 - 
        % 65 - 
        % 66 - 
        % 67 - 
        % 68 - 
        % 69 - 
        % xx - IMMsegmentation
        
        segmentationAlgorithms = cell(0,1);
%         segmentationAlgorithms{end+1} = struct('id', 1, 'done', [0 0 0], 'name', "uniformEntries_inf", 'functionCriteria', 0, 'valueCriteria', 0);
%         segmentationAlgorithms{end+1} = struct('id', 1, 'done', [0 0 0], 'name', "uniformEntries_50", 'functionCriteria', 1, 'valueCriteria', 50);
%         segmentationAlgorithms{end+1} = struct('id', 1, 'done', [0 0 0], 'name', "uniformEntries_20", 'functionCriteria', 1, 'valueCriteria', 20);
%         segmentationAlgorithms{end+1} = struct('id', 1, 'done', [0 0 0], 'name', "uniformEntries_10", 'functionCriteria', 1, 'valueCriteria', 10);
%         segmentationAlgorithms{end+1} = struct('id', 2, 'done', [0 0 0], 'name', "OPW_0_1_20_0_0_20",   'fncSelectedPoint', 0, 'fncSpatialError', 1, 'spatialError', 20, 'speedError', 0, 'angleError', 0, 'minSize', 20);
%         segmentationAlgorithms{end+1} = struct('id', 2, 'done', [0 0 0], 'name', "OPW_1_1_20_0_0_20",   'fncSelectedPoint', 1, 'fncSpatialError', 1, 'spatialError', 20, 'speedError', 0, 'angleError', 0, 'minSize', 20);
%         segmentationAlgorithms{end+1} = struct('id', 2, 'done', [0 0 0], 'name', "OPWTR_0_2_20_0_0_20", 'fncSelectedPoint', 0, 'fncSpatialError', 2, 'spatialError', 20, 'speedError', 0, 'angleError', 0, 'minSize', 20);
%         segmentationAlgorithms{end+1} = struct('id', 2, 'done', [0 0 0], 'name', "OPWTR_0_2_20_0_0_10", 'fncSelectedPoint', 0, 'fncSpatialError', 2, 'spatialError', 20, 'speedError', 0, 'angleError', 0, 'minSize', 10);
%         segmentationAlgorithms{end+1} = struct('id', 2, 'done', [0 0 0], 'name', "OPWTR_0_2_30_0_0_50", 'fncSelectedPoint', 0, 'fncSpatialError', 2, 'spatialError', 30, 'speedError', 0, 'angleError', 0, 'minSize', 50);
%         segmentationAlgorithms{end+1} = struct('id', 2, 'done', [0 0 0], 'name', "OPWTR_0_2_20_0_0_2",  'fncSelectedPoint', 0, 'fncSpatialError', 2, 'spatialError', 20, 'speedError', 0, 'angleError', 0, 'minSize', 2);
%         segmentationAlgorithms{end+1} = struct('id', 2, 'done', [0 0 0], 'name', "OPWTR_1_2_20_0_0_20", 'fncSelectedPoint', 1, 'fncSpatialError', 2, 'spatialError', 20, 'speedError', 0, 'angleError', 0, 'minSize', 20);
%         segmentationAlgorithms{end+1} = struct('id', 2, 'done', [0 0 0], 'name', "OPWTR_1_2_20_0_0_10", 'fncSelectedPoint', 1, 'fncSpatialError', 2, 'spatialError', 20, 'speedError', 0, 'angleError', 0, 'minSize', 10);
%         segmentationAlgorithms{end+1} = struct('id', 2, 'done', [0 0 0], 'name', "OPWTR_1_2_30_0_0_50", 'fncSelectedPoint', 1, 'fncSpatialError', 2, 'spatialError', 20, 'speedError', 0, 'angleError', 0, 'minSize', 50);
%         segmentationAlgorithms{end+1} = struct('id', 2, 'done', [0 0 0], 'name', "OPWTR_1_2_20_0_0_2",  'fncSelectedPoint', 1, 'fncSpatialError', 2, 'spatialError', 20, 'speedError', 0, 'angleError', 0, 'minSize', 2);
%         segmentationAlgorithms{end+1} = struct('id', 3, 'done', [0 0 0], 'name', "DPhull_Prueba",   'fncSpatialError', 4, 'spatialError', 20, 'speedError', 0, 'angleError', 0, 'minSize', 0);
%         segmentationAlgorithms{end+1} = struct('id', 3, 'done', [0 0 0], 'name', "DP_1_20_0_0_10",   'fncSpatialError', 1, 'spatialError', 20, 'speedError', 0, 'angleError', 0, 'minSize', 10);
%         segmentationAlgorithms{end+1} = struct('id', 3, 'done', [0 0 0], 'name', "TDTR_2_20_0_0_10", 'fncSpatialError', 2, 'spatialError', 20, 'speedError', 0, 'angleError', 0, 'minSize', 10);
%         segmentationAlgorithms{end+1} = struct('id', 3, 'done', [0 0 0], 'name', "TDTR_2_30_0_0_50", 'fncSpatialError', 2, 'spatialError', 30, 'speedError', 0, 'angleError', 0, 'minSize', 50);
%         segmentationAlgorithms{end+1} = struct('id', 3, 'done', [0 0 0], 'name', "TDTR_2_20_0_0_2",  'fncSpatialError', 2, 'spatialError', 20, 'speedError', 0, 'angleError', 0, 'minSize', 2);
%         segmentationAlgorithms{end+1} = struct('id', 3, 'done', [0 0 0], 'name', "DP_1_20_0_0_20",   'fncSpatialError', 1, 'spatialError', 20, 'speedError', 0, 'angleError', 0, 'minSize', 20);
%         segmentationAlgorithms{end+1} = struct('id', 3, 'done', [0 0 0], 'name', "DP_1_20_0_0_50",   'fncSpatialError', 1, 'spatialError', 20, 'speedError', 0, 'angleError', 0, 'minSize', 50);
%         segmentationAlgorithms{end+1} = struct('id', 3, 'done', [0 0 0], 'name', "TDTR_2_20_0_0_20", 'fncSpatialError', 2, 'spatialError', 30, 'speedError', 0, 'angleError', 0, 'minSize', 20);
%         segmentationAlgorithms{end+1} = struct('id', 3, 'done', [0 0 0], 'name', "DPDP",   'fncSpatialError', 1, 'spatialError', 0, 'speedError', 0, 'angleError', 40, 'minSize', 3);
%         segmentationAlgorithms{end+1} = struct('id', 4, 'done', [0 0 0], 'name', "bottomUp_1_20_0_0_10", 'fncSpatialError', 1, 'spatialError', 20, 'speedError', 0, 'angleError', 0, 'minSize', 20);
%         segmentationAlgorithms{end+1} = struct('id', 4, 'done', [0 0 0], 'name', "bottomUp_1_30_0_0_50", 'fncSpatialError', 1, 'spatialError', 30, 'speedError', 0, 'angleError', 0, 'minSize', 50);
%         segmentationAlgorithms{end+1} = struct('id', 4, 'done', [0 0 0], 'name', "bottomUp_1_20_0_0_2",  'fncSpatialError', 1, 'spatialError', 20, 'speedError', 0, 'angleError', 0, 'minSize', 2);
%         segmentationAlgorithms{end+1} = struct('id', 4, 'done', [0 0 0], 'name', "bottomUp_1_20_0_0_20", 'fncSpatialError', 1, 'spatialError', 20, 'speedError', 0, 'angleError', 0, 'minSize', 20);
%         segmentationAlgorithms{end+1} = struct('id', 5, 'done', [0 0 0], 'name', "SQUISHE_1_20",  'compRatio', 1,  'spatialError', 20);
%         segmentationAlgorithms{end+1} = struct('id', 5, 'done', [0 0 0], 'name', "SQUISHE_5_20",  'compRatio', 5,  'spatialError', 20);
%         segmentationAlgorithms{end+1} = struct('id', 5, 'done', [0 0 0], 'name', "SQUISHE_10_30", 'compRatio', 10, 'spatialError', 30);
%         segmentationAlgorithms{end+1} = struct('id', 5, 'done', [0 0 0], 'name', "SQUISHE_10_20", 'compRatio', 10, 'spatialError', 20);
%         segmentationAlgorithms{end+1} = struct('id', 5, 'done', [0 0 0], 'name', "SQUISHE_1_30",  'compRatio', 1,  'spatialError', 30);
%         segmentationAlgorithms{end+1} = struct('id', 6, 'done', [0 0 0], 'name', "DOTS_100", 'lssdThreshold', 100);
%         segmentationAlgorithms{end+1} = struct('id', 6, 'done', [0 0 0], 'name', "DOTS_500", 'lssdThreshold', 500);
%         segmentationAlgorithms{end+1} = struct('id', 7, 'done', [0 0 0], 'name', "MRPA_100_2_1", 'lssdThreshold', 100, 'c', 2, 'shiftv', 1);
%         segmentationAlgorithms{end+1} = struct('id', 7, 'done', [0 0 0], 'name', "MRPA_500_2_1", 'lssdThreshold', 500, 'c', 2, 'shiftv', 1);
%         segmentationAlgorithms{end+1} = struct('id', 9, 'done', [0 0 0], 'name', "DeadReckoning_Prueba", 'angleThreshold', 20);
%         segmentationAlgorithms{end+1} = struct('id', 10,'done', [0 0 0], 'name', "STTrace_Prueba", 'compRatio', 10);
%         segmentationAlgorithms{end+1} = struct('id', 11,'done', [0 0 0], 'name', "Angular_Prueba", 'error_t', 0.3);
%         segmentationAlgorithms{end+1} = struct('id', 12,'done', [0 0 0], 'name', "SP_Prueba", 'error_t', 45);
%         segmentationAlgorithms{end+1} = struct('id', 13,'done', [0 0 0], 'name', "SQUISH_1", 'compRatio', 10);
%         segmentationAlgorithms{end+1} = struct('id', 14,'done', [0 0 0], 'name', "CDR_Prueba", 'accBound', 0.1);
%         segmentationAlgorithms{end+1} = struct('id', 15,'done', [0 0 0], 'name', "BQS_Prueba",  'eps', 2);
%         segmentationAlgorithms{end+1} = struct('id', 16,'done', [0 0 0], 'name', "OPERB_Prueba", 'threshold', 0.0002);
%         segmentationAlgorithms{end+1} = struct('id', 17,'done', [0 0 0], 'name', "Intersect_Prueba", 'error_t', 0.3);
%         segmentationAlgorithms{end+1} = struct('id', 18,'done', [0 0 0], 'name', "OLDCAT_Prueba", "minDist", 10, "maxTime", 10, "maxDist", 50, "minAngle", 10);
%         segmentationAlgorithms{end+1} = struct('id', 19,'done', [0 0 0], 'name', "SPM_Prueba", "spatialError", 20);
%         segmentationAlgorithms{end+1} = struct('id', 20,'done', [0 0 0], 'name', "TPMF_Prueba", "radiusThreshold", 20, "timeThreshold", 20, "speedThreshold", 1, "angleThreshold", 20, "distanceThreshold", 20);
%         segmentationAlgorithms{end+1} = struct('id', 21,'done', [0 0 0], 'name', "ErrorSearch_Prueba", "W", 20);
%         segmentationAlgorithms{end+1} = struct('id', 25,'done', [0 0 0], 'name', "Bellman_Prueba",  'C', 2);
%         segmentationAlgorithms{end+1} = struct('id', 26,'done', [0 0 0], 'name', "Opheim_Prueba",  'tolerance', 15, 'maxDist', 100);
%         segmentationAlgorithms{end+1} = struct('id', 27,'done', [0 0 0], 'name', "ReumannWitkam_Prueba",  'tolerance', 10);
%         segmentationAlgorithms{end+1} = struct('id', 28,'done', [0 0 0], 'name', "Radial_Prueba",  'tolerance', 50);
%         segmentationAlgorithms{end+1} = struct('id', 29,'done', [0 0 0], 'name', "Lang_Prueba",  'tolerance', 10, 'lookup', 20);
%         segmentationAlgorithms{end+1} = struct('id', 30,'done', [0 0 0], 'name', "Visvalingam_Prueba",  'tolerance', 20);
%         segmentationAlgorithms{end+1} = struct('id', 32,'done', [0 0 0], 'name', "ZhaoSaalfeld_Prueba",  'degree', 20, 'lookAhead', 20);
%         segmentationAlgorithms{end+1} = struct('id', 33,'done', [0 0 0], 'name', "Anagnostopoulos_Prueba");
%         segmentationAlgorithms{end+1} = struct('id', 34,'done', [0 0 0], 'name', "HESAVE_Prueba", "samplingRatio", 3, "sizeWindow", 10);
%         segmentationAlgorithms{end+1} = struct('id', 35,'done', [0 0 0], 'name', "Interval_Prueba");
%         segmentationAlgorithms{end+1} = struct('id', 36,'done', [0 0 0], 'name', "KAA_Prueba");
%         segmentationAlgorithms{end+1} = struct('id', 37,'done', [0 0 0], 'name', "FSW_Prueba");
%         segmentationAlgorithms{end+1} = struct('id', 38,'done', [0 0 0], 'name', "Persistence_Prueba", 'useCascade', 0, 'minimumDistance', 100);
%         segmentationAlgorithms{end+1} = struct('id', 39,'done', [0 0 0], 'name', "ICMBR_Prueba");
%         segmentationAlgorithms{end+1} = struct('id', 40,'done', [0 0 0], 'name', "GRTS_Prueba");
%         segmentationAlgorithms{end+1} = struct('id', 41,'done', [0 0 0], 'name', "ESTCEDP_Prueba");
%         segmentationAlgorithms{end+1} = struct('id', 42,'done', [0 0 0], 'name', "NaTS_Prueba");
%         segmentationAlgorithms{end+1} = struct('id', 43,'done', [0 0 0], 'name', "Thresholds_Prueba");
%         segmentationAlgorithms{end+1} = struct('id', 44,'done', [0 0 0], 'name', "TS_Prueba");
%         segmentationAlgorithms{end+1} = struct('id', 45,'done', [0 0 0], 'name', "Similarity_Prueba");
%         segmentationAlgorithms{end+1} = struct('id', 46,'done', [0 0 0], 'name', "MinError_Prueba");
%         segmentationAlgorithms{end+1} = struct('id', 47,'done', [0 0 0], 'name', "AACAT_Prueba");
         segmentationAlgorithms{end+1} = struct('id', 48,'done', [0 0 0], 'name', "CBSMoT_Prueba", "max_dist", 100, "area", 0.5, "min_time", 15, "time_tolerance", 60, "merge_tolerance", 100);
%         segmentationAlgorithms{end+1} = struct('id', 49,'done', [0 0 0], 'name', "GRASPUTS_Prueba");
%         segmentationAlgorithms{end+1} = struct('id', 50,'done', [0 0 0], 'name', "RGRASPSemTS_Prueba");
%         segmentationAlgorithms{end+1} = struct('id', 51,'done', [0 0 0], 'name', "OWS_Prueba");
%         segmentationAlgorithms{end+1} = struct('id', 52,'done', [0 0 0], 'name', "SMOT_Prueba");
%         segmentationAlgorithms{end+1} = struct('id', 53,'done', [0 0 0], 'name', "SPD_Prueba", "theta_distance", 100, "theta_time", 60);
%         segmentationAlgorithms{end+1} = struct('id', 54,'done', [0 0 0], 'name', "SWS_Prueba", "interpolation_kernel", 'linear', "window_size", 7, "epsilon", 100, "percentile", 1);
%         segmentationAlgorithms{end+1} = struct('id', 55,'done', [0 0 0], 'name', "WKMeans_Prueba", "ratioClusters", 20, "threshold", 1);
%         segmentationAlgorithms{end+1} = struct('id', 56,'done', [0 0 0], 'name', "WSII_Prueba", "window_size", 7, "majority_vote_degree", 0.9, "binary_classifier", "RandomForestClassifier", "kernel", "Random Walk");
%         segmentationAlgorithms{end+1} = struct('id', 57,'done', [0 0 0], 'name', "SetraStream_Prueba");
%         segmentationAlgorithms{end+1} = struct('id', 58,'done', [0 0 0], 'name', "SAS_Prueba");
%         segmentationAlgorithms{end+1} = struct('id', 59,'done', [0 0 0], 'name', "SAOTS_Prueba");
%         segmentationAlgorithms{end+1} = struct('id', 60,'done', [0 0 0], 'name', "_Prueba");
        %segmentationAlgorithms{end+1} = struct('id', 8, 'done', [1 1 1], 'name', "IMMsegmentator", 'minimumSizeSplit', 20, 'confFrontIMM', "segmentation_95_3_5", 'confBackIMM', "segmentation_95_5_10", 'limitIMM', 0.4);
        
        % The folder name of each of the algorithms is created
        namesSegAlg = strings(length(segmentationAlgorithms), 1);
        for k=1:length(segmentationAlgorithms)
            % The name for the folder of this algorithm is defined
            if ~strcmp(namesSegAlg, segmentationAlgorithms{k}.name) % To avoid repeating names
                namesSegAlg(k) = segmentationAlgorithms{k}.name;
            end
        end
        
        % Segmentations are executed
        for k=1:length(segmentationAlgorithms)
            if segmentationAlgorithms{k}.done(1) == 0 % Skip the ones indicated as finished
                filteredToSplitted(nameUnion(i), segmentationAlgorithms{k});
            end
        end
    end
    telegramMessage("END SEGMENTING");
    

    for i=1:length(nameUnion)
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                   FEATURE EXTRACTION PROCESS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        for k=1:length(segmentationAlgorithms)
            if segmentationAlgorithms{k}.done(2) == 0 % Skip the ones indicated as finished
                mainFeaturesExtractionProcess(nameUnion(i), namesSegAlg(k));
            end
        end
    end
    telegramMessage("END PREPROCESSING");
    

    for i=1:length(nameUnion)
        if contains(nameUnion(i), "_T_0_")
            continue;
        else
            disp("OK");
        end
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     CLASSIFICATION PROCESS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%% removeVars.
        %  0 - All variables, with ship dimensions
        %  2 - Only total variables, with ship dimensions
        %  3 - Without quartiles
        %  4 - Without mode
        %  5 - Without sum
        %  6 - Without minimum
        %  7 - Without IMM modes information
        %  8 - Without maximum
        %  9 - Without speedVariation
        % 10 - Without speed
        % 11 - Without distance
        % 12 - Without directionVariation
        % 13 - Without timeGap
        % 14 - Without IMM information nor ship dimensions
        % 15 - All with ships dimensions
        % 16 - Selected for MSAW19 (speedVariation, directionVariation, timeGap) without ship dimensions
        % 17 - Selected for MSAW19 (speedVariation, directionVariation, timeGap) with ship dimensions
        % 18 - Selected for this paper = no timeGap, minimum, mode, sum nor ship dimensions
        % 19 - Importance variables = no timeGap, minimum, mode nor sum. With ship dimensions
        % 20 - Importance variables = no timeGap, minimum, mode, sum, speedVariation, distance, nor ship dimensions
        % 21 - Importance variables = no timeGap, minimum, mode, sum, speedVariation, nor distance. With ship dimensions
        
        % PredictClass
        %  1                2                3          4           5           6         7
        % ["ClassShiptype", "ClassManeuver", "Cargo", "Fishing", "Passenger", "Tanker", "OtherShip", "EngagedFishing", "Restricted", "Sailing", "Engine", "OtherManeuver"];
        
        %%%%%%%% BalanceType
        % 0 - None
        % 1 - Half of the selected one, the other half keeping the type of distribution of the other classes
        % 2 - Half of the selected one, the other half balanced with respect to the demas (if they fit)
        % 3 - Random Undersampling
        % 4 - SMOTE only with the selected class
        
        filesPreclassifier = cell(0, 1);
        for j=1:length(namesSegAlg)
            if segmentationAlgorithms{j}.done(3) == 0 % Skip the ones indicated as finished
                filesPreclassifier{end+1} = namesSegAlg(j);
            end
        end
        
        % The following configuration is used to generate ONLY Matlab Workspace initial files
        selectedClass      = {3};
        removeVars         = {14};
        classifiers        = {1};
        balanceTypes       = {0};
        normalize          = {1};
        trainTestTypes     = {1};
        importanceVars     = {1};
        doVector           = {0};
        
        
        % This paper's configuration
        selectedClass      = {4};
        removeVars         = {18,19,20,21};
        classifiers        = {1,2};
        balanceTypes       = {0,3,4};
        normalize          = {1};
        trainTestTypes     = {1};
        importanceVars     = {1};
        doVector           = {0};

        % To generate the Neighbours files for SMOTE
        selectedClass      = {4};
        removeVars         = {14,18,19,20,21};
        classifiers        = {1};
        balanceTypes       = {4};
        normalize          = {1};
        trainTestTypes     = {1};
        importanceVars     = {1};
        doVector           = {0};
        
        % All combinations are generated
        numCombinations = length(filesPreclassifier) * ...
            length(selectedClass)      * ...
            length(removeVars)         * ...
            length(classifiers)        * ...
            length(balanceTypes)       * ...
            length(normalize)          * ...
            length(trainTestTypes)     * ...
            length(importanceVars)     * ...
            length(doVector);
        combinationsToClassify = cell(numCombinations, 1);
        
        cntCombinations = 1;
        for j=1:length(selectedClass)
            for k=1:length(removeVars)
                for l=1:length(classifiers)
                    for m=1:length(balanceTypes)
                        for n=1:length(normalize)
                            for o=1:length(trainTestTypes)
                                for p=1:length(importanceVars)
                                    for q=1:length(doVector)
                                        for r=1:length(filesPreclassifier)
                                            if balanceTypes{m} > 0 && (selectedClass{j} == 0 || selectedClass{j} == 1)     % It skips the balancing if it's a multiclass
                                            elseif classifiers{l} == 1 && (selectedClass{j} == 0 || selectedClass{j} == 1) % Skip the SVM with multiclass
                                            else
                                                combinationsToClassify{cntCombinations}.selectedClass  = selectedClass{j};
                                                combinationsToClassify{cntCombinations}.removeVars     = removeVars{k};
                                                combinationsToClassify{cntCombinations}.classifier     = classifiers{l};
                                                combinationsToClassify{cntCombinations}.balanceType    = balanceTypes{m};
                                                combinationsToClassify{cntCombinations}.normalize      = normalize{n};
                                                combinationsToClassify{cntCombinations}.trainTestType  = trainTestTypes{o};
                                                combinationsToClassify{cntCombinations}.importanceVars = importanceVars{p};
                                                combinationsToClassify{cntCombinations}.doVector       = doVector{q};
                                                combinationsToClassify{cntCombinations}.featureExtraction  = filesPreclassifier{r};
                                                cntCombinations = cntCombinations + 1;
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        message = strcat("START classification process");
        telegramMessage(message);
        
        %% The combinations are executed in parallel
        useParfor = false;
        if useParfor == true
            pool = gcp();
            if isempty(pool)
                pool = parpool('local', 24);
            end
            opts = parforOptions(pool', 'RangePartitionMethod', 'fixed', 'SubrangeSize', 1);
            
            parfor (j=1:length(combinationsToClassify), opts)
                message = strcat("STARTING number ", num2str(j), " of ", nameUnion(i), ": ", num2str(length(combinationsToClassify)));
                telegramMessage(message);
                
                a = combinationsToClassify{j};
                mainClassifyProcess(nameUnion(i), a.selectedClass, a.removeVars, a.classifier, a.balanceType, a.normalize, a.trainTestType, a.importanceVars, a.doVector, a.featureExtraction);
                
                message = strcat("FINISHING number ", num2str(j), " of ", nameUnion(i), ": ", num2str(length(combinationsToClassify)));
                telegramMessage(message);
            end
            
        else
            for j=1:length(combinationsToClassify)
                message = strcat("STARTING number ", num2str(j), " of ", nameUnion(i), ": ", num2str(length(combinationsToClassify)));
                telegramMessage(message);
                
                a = combinationsToClassify{j};
                mainClassifyProcess(nameUnion(i), a.selectedClass, a.removeVars, a.classifier, a.balanceType, a.normalize, a.trainTestType, a.importanceVars, a.doVector, a.featureExtraction);
                
                message = strcat("FINISHING number ", num2str(j), " of ", nameUnion(i), ": ", num2str(length(combinationsToClassify)));
                telegramMessage(message);
            end
        end
    end

    % Save the classification results on a UNION file
    namesSegUsed = strings(0,1);
    for j=1:length(namesSegAlg)
        if segmentationAlgorithms{j}.done(3) == 0
            %if contains(nameUnion(i), "") == 0 % To skip some combinations
                namesSegUsed(end+1) = segmentationAlgorithms{j}.name;
            %end
        end
    end
    mergeFiles(nameUnion, namesSegUsed, true);
    

    message = strcat("SCRIPT END!");
    telegramMessage(message);
    
catch ME
    message = strcat("Error: ", ME.identifier, ". On: ", ME.stack(1).name, ", line: ", num2str(ME.stack(1).line) );
    telegramMessage(message);
    rethrow(ME);
end


%% Une los resultados de todos los procesos de clasificacion en un mismo fichero, para facilitar el posterior analisis
%  It joins the results of all the classification processes in the same file, to make easier the later analysis
function [] = mergeFiles(nameUnions, namesSegAlg, mergeUnions)
    if mergeUnions == true
        pathCSVUnion = strcat("Data", "/", "csvUnion.csv");
    else
        pathCSVUnion = strcat("Data", "/", nameUnion, "/", namesSegAlg, "/", "csvUnion.csv");
    end
    if isfile(pathCSVUnion)
        delete(pathCSVUnion);
    end
    
    for i=1:length(nameUnions)
        for j=1:length(namesSegAlg)
            pathCSVFiles = strcat("Data", "/", nameUnions{i}, "/", namesSegAlg(j), "/", "ClassifiedCSV");
            
            allFiles = dir(strcat(pathCSVFiles,'/*.*'));
            allFiles([allFiles.isdir]) = [];   %skip directories
            
            for k=1:length(allFiles)
                fileNameCSV = allFiles(k).name;
                pathFileNameCSV = strcat(pathCSVFiles, "/", fileNameCSV);
                [TableCSV] = readWriteFunctions.readClassificationResults(pathFileNameCSV);
                
                % Se escribe en nuestro CSV union
                if i == 1 && j == 1 && k == 1
                    readWriteFunctions.writeUnionClassificationResults(pathCSVUnion, TableCSV, nameUnions{i}, namesSegAlg(j), true); % First one with header
                else
                    readWriteFunctions.writeUnionClassificationResults(pathCSVUnion, TableCSV, nameUnions{i}, namesSegAlg(j), false);
                end
            end
        end
    end
    end