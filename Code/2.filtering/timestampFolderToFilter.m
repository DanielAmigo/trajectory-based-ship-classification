%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desarrollado por | Developed by:                     %
% University Carlos III of Madrid PhD Researchers      %
% Daniel Amigo Herrero    mailto: damigo@inf.uc3m.es   %
% David Sanchez Pedroche  mailto: davsanch@inf.uc3m.es %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Script que obtiene los ficheros con trazas divididas en timestamps y le realiza un filtrado IMM, almacenando su resultado en ficheros
% read the splitted tracks folder obtained on timestamped process and apply an estimation filtering of its kinematic values
function timestampFolderToFilter(nameDay, clConf, tConf, filtConf)

message = strcat("START timestampFolderToFilter ", nameDay);
telegramMessage(message);

% Read the filter configuration
extensionConf = '.ini';
folderConf = '2.filtering/Configurations';
nameFileConf = strcat(folderConf, '/', filtConf.immConf, extensionConf);
[filterConf, fusionCenter] = configurationFunctions.readFilterConf(nameFileConf);

%% create the folders to read/write
extension = '.csv';
c = strcat("C", "_", num2str(clConf.cleanNoiseLatLon));
t = strcat("T", "_", num2str(tConf.type), "_", num2str(tConf.maxPeriod), "_", num2str(tConf.minNumTracks), "_", num2str(tConf.thresholdMovement));
f = strcat("F", "_", filtConf.immConf, "_", num2str(filtConf.type));
readPath       = strcat("Data", "/", nameDay, "/");
folderRead     = strcat(readPath, "Timestamped", "/", "Timestamped", "_", c, "_", t);
folderFiltered = strcat(readPath, "Filtered",  "/");
folderWrite    = strcat(folderFiltered, c, "_", t, "_", f, "/");  % Si no existe la carpeta la generamos
% create if the output folders don't exist
if ~exist(folderFiltered, 'dir')
    mkdir(folderFiltered);
end
if ~exist(folderWrite, 'dir')
    mkdir(folderWrite);
end

% get the files
allFiles = dir(strcat(folderRead, "/*.*"));
allFiles([allFiles.isdir]) = [];   %skip directories

% create a thread pool
useParfor = true;
if useParfor == true
    pool = gcp();
    if isempty(pool)
        pool = parpool();
    end
    opts = parforOptions(pool, 'RangePartitionMethod', 'fixed', 'SubrangeSize', ceil(length(allFiles)/100));
end

%for k=1:length(allFiles)           % If useParfor is false
parfor (k=1:length(allFiles), opts) % If useParfor is true
    nameFileRead = allFiles(k).name;
    fullFileRead = strcat(folderRead,'/',nameFileRead);
    mmsi = nameFileRead(1:end-4); % filename without extension
    nameFileWrite = strcat(folderWrite, mmsi, extension);
    
    if isfile(nameFileWrite) % if already exist, jump this file
        continue;
    end
    
    % Use the correct function to read this type of file
    if strcmp(nameDay, "MOPSI")
        [plotsTable] = readWriteFunctions.readMOPSI(fullFileRead);
    elseif strcmp(nameDay, "Geolife")
        [plotsTable] = readWriteFunctions.readGeolife(fullFileRead);
    elseif strcmp(nameDay, "TDrive")
        [plotsTable] = readWriteFunctions.readTDrive(fullFileRead);
    else
        [plotsTable] = readWriteFunctions.readMmsiTimestampedFile(fullFileRead);
    end
    
    
    
    if filtConf.type == 1  % Apply the filter
        [tracksTable] = filterAllTrack(plotsTable, filterConf, fusionCenter);
        
        
    elseif filtConf.type == 0 % Do not apply any filter, just copy the values with the same structure further
        tracksTable = cell(1, height(plotsTable));
        for i=1:height(plotsTable)
            tracksTable{i}.plot           = plotsTable(i,:);
            if isnan(plotsTable(i,:).Course)
                speed_vx = plotsTable(i,:).Speed / sqrt(2); % Supone 45 grados, porque si xd
                speed_vy = plotsTable(i,:).Speed / sqrt(2);
            else
                speed_vx = plotsTable(i,:).Speed * cos(plotsTable(i,:).Course * pi / 180);
                speed_vy = plotsTable(i,:).Speed * sin(plotsTable(i,:).Course * pi / 180);
            end
            tracksTable{i}.stateVector       = [plotsTable(i,:).Latitude, plotsTable(i,:).Longitude, speed_vx, speed_vy];
            tracksTable{i}.modeProbabilities = zeros(2,1);
            tracksTable{i}.Pk                = zeros(4,4);
            tracksTable{i}.stateVectorKFs    = cell(2,1);
            tracksTable{i}.stateVectorKFs{1} = zeros(4,1);
            tracksTable{i}.stateVectorKFs{2} = zeros(4,1);
            tracksTable{i}.pkKFs    = cell(2,1);
            tracksTable{i}.pkKFs{1} = zeros(4,4);
            tracksTable{i}.pkKFs{2} = zeros(4,4);
        end
    end
    
    % Generamos el fichero de salida
    if ~exist(folderWrite, 'dir')
        mkdir(folderWrite);
    end
    
    % Write the output, depending of the type of dataset
    if strcmp(nameDay, "MOPSI") || strcmp(nameDay, "Geolife") || strcmp(nameDay, "TDrive")
        for i=1:length(tracksTable)
            tracksTable{i}.plot.Timestamp                  = "1";
            tracksTable{i}.plot.Typeofmobile               = "1";
            tracksTable{i}.plot.MMSI                       = 1;
            tracksTable{i}.plot.Latitude                   = plotsTable.Latitude(i+2);
            tracksTable{i}.plot.Longitude                  = plotsTable.Longitude(i+2);
            tracksTable{i}.plot.Navigationalstatus         = "1";
            tracksTable{i}.plot.RateOfTurn                 = 1;
            tracksTable{i}.plot.Speed                      = 1;
            tracksTable{i}.plot.Course                     = 1;
            tracksTable{i}.plot.Heading                    = 1;
            tracksTable{i}.plot.IMO                        = "1";
            tracksTable{i}.plot.Callsign                   = "1";
            tracksTable{i}.plot.Name                       = "1";
            tracksTable{i}.plot.Shiptype                   = "1";
            tracksTable{i}.plot.Cargotype                  = "1";
            tracksTable{i}.plot.Width                      = 1;
            tracksTable{i}.plot.Length                     = 1;
            tracksTable{i}.plot.Typeofpositionfixingdevice = "1";
            tracksTable{i}.plot.Draught                    = 1;
            tracksTable{i}.plot.Destination                = "1";
            tracksTable{i}.plot.ETA                        = "1";
            tracksTable{i}.plot.Datasourcetype             = "1";
        end
        readWriteFunctions.writeFiltered(nameFileWrite, tracksTable, filterConf);
    else
        readWriteFunctions.writeFiltered(nameFileWrite, tracksTable, filterConf);
    end
end

message = strcat("END timestampToFilter ", nameDay);
telegramMessage(message);

end