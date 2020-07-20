%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desarrollado por | Developed by:                     %
% University Carlos III of Madrid PhD Researchers      %
% Daniel Amigo Herrero    mailto: damigo@inf.uc3m.es   %
% David Sanchez Pedroche  mailto: davsanch@inf.uc3m.es %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% este script recibe una carpeta con trayectorias filtradas y las divide en N partes, segun el algoritmo de segmentacion utilizado
%  this script have as an input a folder with filtered tracks and creates another with all the tracks splitted using a selected segmentation algorithm
function [] = filteredToSplitted(unionName, alg)

message = strcat("START filteredToSplitted ", alg.name);
telegramMessage(message);

%% Creates the folders and files for input/output
extension = '.csv';
nameAlgorithm = alg.name;
folderRead    = strcat('Data/', unionName, "/", "Filtered");
folderWrite   = strcat('Data/', unionName, "/", 'Splitted',       '/', nameAlgorithm);
folderMetrics = strcat('Data/', unionName, "/", 'Splitted',       '/', nameAlgorithm, "_metrics");
folderImages  = strcat('Data/', unionName, "/", 'SplittedImages', '/', nameAlgorithm);

if ~exist(folderWrite, 'dir')
    mkdir(folderWrite)
else
    %return
    dinfo = dir(folderWrite);
    dinfo([dinfo.isdir]) = [];
    filenames = fullfile(folderWrite, {dinfo.name});
    if size(filenames) > 0
        % delete( filenames{:} );
    end
end
if ~exist(folderImages, 'dir')
    mkdir(folderImages)
else
    dinfo = dir(folderImages);
    dinfo([dinfo.isdir]) = [];
    filenames = fullfile(folderImages, {dinfo.name});
    if size(filenames) > 0
        delete( filenames{:} );
    end
end
if ~exist(folderMetrics, 'dir')
    mkdir(folderMetrics)
else
    dinfo = dir(folderMetrics);
    dinfo([dinfo.isdir]) = [];
    filenames = fullfile(folderMetrics, {dinfo.name});
    if size(filenames) > 0
        delete( filenames{:} );
    end
end

allFiles = dir(strcat(folderRead,'/*.*'));
allFiles([allFiles.isdir]) = [];   %skip directories

%% Use or not a parallel for
usePar = false;
if usePar == true
    pool = gcp();
    if isempty(pool)
        pool = parpool('local', 32);
    end
    opts = parforOptions(pool, 'RangePartitionMethod', 'fixed', 'SubrangeSize', ceil(length(allFiles)/1000));
end

%parfor (k=1:length(allFiles), opts)
for k=1:length(allFiles)
    % disp(k);
    nameFileRead = allFiles(k).name;
    fullFileRead = strcat(folderRead,'/',nameFileRead);
    [Data] = readWriteFunctions.readFiltered(fullFileRead);
    

    %% Create the segments according the selected algorithm
    tic
    if alg.id == 1 % uniformSampling
        [splits] = uniformSampling(Data, alg.functionCriteria, alg.valueCriteria);
        alg.fncSpatialError = 1; % PED
    end
    compTime = toc;
    
    % Create an image of this tracka and its segments
    splitsToImage(Data, splits, k, nameFileRead, folderImages, alg);
    
    %% Save the created segments
    a = strrep(nameFileRead, ".csv", "");
    a = split(a,'_');
    baseNameFile = strcat(folderWrite,'/', a(1), '_', a(2), '_', 'split_');
    
    for i=1:length(splits)
        nameFileWrite = strcat(baseNameFile, num2str(i), extension);
        readWriteFunctions.writeSplitted(nameFileWrite, splits{i});
    end
end

message = strcat("END filteredToSplitted ", nameAlgorithm);
telegramMessage(message);
end