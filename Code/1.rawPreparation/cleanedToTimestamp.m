%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desarrollado por | Developed by:                     %
% University Carlos III of Madrid PhD Researchers      %
% Daniel Amigo Herrero    mailto: damigo@inf.uc3m.es   %
% David Sanchez Pedroche  mailto: davsanch@inf.uc3m.es %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Este script lee los N ficheros de la carpeta Data/Cleaned, almacenandolos si cumplen una serie de requisitos
%  this script read all the cleaned folder's files and sort them on folders if they meet some requirements
function cleanedToTimestamp(nameDayFolder, clConf, tConf)

message = strcat("STARTING processingCleaned2Timestamp ", nameDayFolder);
telegramMessage(message);

% Prepare the folders
c = strcat("C", "_", num2str(clConf.cleanNoiseLatLon));
t = strcat("T", "_", num2str(tConf.type), "_", num2str(tConf.maxPeriod), "_", num2str(tConf.minNumTracks), "_", num2str(tConf.thresholdMovement));
folderBase                  = strcat("Data", "/", nameDayFolder, "/", "Cleaned",     "/", "Cleaned",               "_", c );
folderTimestamp             = strcat("Data", "/", nameDayFolder, "/", "Timestamped", "/", "Timestamped",           "_", c, "_", t );
folderMovementAnchored      = strcat("Data", "/", nameDayFolder, "/", "Timestamped", "/", "MovementAnchored",      "_", c, "_", t );
folderNotConsecutives       = strcat("Data", "/", nameDayFolder, "/", "Timestamped", "/", "NotConsecutives",       "_", c, "_", t );
folderNotMovement           = strcat("Data", "/", nameDayFolder, "/", "Timestamped", "/", "NotMovement",           "_", c, "_", t );
folderNoMovementButUnderWay = strcat("Data", "/", nameDayFolder, "/", "Timestamped", "/", "NoMovementButUnderWay", "_", c, "_", t );
extension = ".csv";

% Creamos las carpetas de ficheros si no existen y si ya existen eliminamos su contenido
arrayFoldersCreate = [folderTimestamp, folderMovementAnchored, folderNotConsecutives, folderNotMovement, folderNoMovementButUnderWay];
for i=1:length(arrayFoldersCreate)
    if ~exist(arrayFoldersCreate(i), 'dir')  % If the folder doesn't exist, its created
        mkdir(arrayFoldersCreate(i))
    else
        dinfo = dir(arrayFoldersCreate(i));  % If it do exist, its content it deleted
        dinfo([dinfo.isdir]) = [];
        filenames = fullfile(arrayFoldersCreate(i), {dinfo.name});
        if size(filenames) > 0
            delete( filenames{:} );
        end
    end
end

allFiles = dir(strcat(folderBase,"/*.*"));
allFiles([allFiles.isdir]) = [];   %skip directories


parfor k=1:length(allFiles)
    namefileRead = allFiles(k).name;
    fullFileRead = strcat(folderBase,"/",namefileRead);
    %disp(k + " " + namefileRead);
    
    % Read the file
    [Table] = readWriteFunctions.readMmsiFile(fullFileRead);
    
    if tConf.type == 0 % This mode don't clean anything, just write it on the correct folder
        nameFileWrite = strcat(folderTimestamp,"/",num2str(Table.MMSI(1)),'_', num2str(Table.PosixSeconds(1)), extension);
        readWriteFunctions.writeMmsiTable(nameFileWrite, Table);    % Escribimos esta trayectoria en su correspondiente fichero
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif tConf.type == 1 % Cleans trajectories with extreme noise, but does not discriminate miscategorized trajectories
        
        % Firstly save the first entry of the track
        TableNew = table;
        TableNew(1,:) = Table(1,:);
        firstTimestamp = TableNew.PosixSeconds(1);
        actualManeuver = TableNew.Navigationalstatus(1);
        boolNewTable = 0;
        
        idxNewTable = 2;
        for i=2:height(Table)                                                                      % For all the track
            if ( Table.PosixSeconds(i) - TableNew.PosixSeconds(idxNewTable-1) ) <= tConf.maxPeriod % Checks if this time gap is smaller than the threshold
                if ( Table.PosixSeconds(i) - TableNew.PosixSeconds(idxNewTable-1) ) > 0            % error prevention (if time is going smaller)
                    if strcmp(Table.Navigationalstatus(i), actualManeuver) == 1                    % If the maneuver type remains the same
                        TableNew(idxNewTable,:) = Table(i,:);                                      % Then this point is saved
                        idxNewTable = idxNewTable + 1;
                    else                                                                           % If the maneuver type is not the same
                        boolNewTable = 1; % Marked to stop
                    end
                end
            else                                                                                   % If the time is higher than the threshold
                boolNewTable = 1;         % Marked to stop
            end
            
            
            if boolNewTable == 1 % If its marked to stop
                if height(TableNew) > tConf.minNumTracks % and the current table has enough entries, its saved in a file
                    nameFileWrite = strcat(folderTimestamp,"/",num2str(TableNew.MMSI(1)),"_", num2str(firstTimestamp), extension);
                    readWriteFunctions.writeMmsiTable(nameFileWrite, TableNew);
                end
                % After its saved, some vars are reset
                TableNew = table;
                TableNew(1,:) = Table(i,:);
                firstTimestamp = TableNew.PosixSeconds(1);
                idxNewTable = 2;
                boolNewTable = 0;
                actualManeuver = TableNew.Navigationalstatus(1);
            end
        end
        
        % The same process when the file is over
        if height(TableNew) > tConf.minNumTracks
            nameFileWrite = strcat(folderTimestamp,"/",num2str(TableNew.MMSI(1)),'_', num2str(firstTimestamp), extension);
            readWriteFunctions.writeMmsiTable(nameFileWrite, TableNew);    % Escribimos esta trayectoria en su correspondiente fichero
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif tConf.type == 2 % All the clean proposed is perform
        
        % Firstly save the first entry of the track
        TableNew = table;
        TableNew(1,:) = Table(1,:);
        firstTimestamp = TableNew.PosixSeconds(1);
        
        actualManeuver = TableNew.Navigationalstatus(1);
        boolNewTable = 0;
        
        % Tables to save the bad categorized entries
        tableNotMovement = table;
        tableMovementAnchored = table;
        tablenoMovementButUnderWay = table;
        tableNotConsecutives = table;
        cntNotMovement = 1;
        cntNotConsecutives = 1;
        cntMovementAnchored = 1;
        cntNoMovementButUnderWay = 1;
        
        idxNewTable = 2;
        for i=2:height(Table)                                                                       % For all the track
            if ( Table.PosixSeconds(i) - TableNew.PosixSeconds(idxNewTable-1) ) <= tConf.maxPeriod  % Checks if this time gap is smaller than the threshold
                if ( Table.PosixSeconds(i) - TableNew.PosixSeconds(idxNewTable-1) ) > 0             % error prevention (if time is going smaller)
                    if strcmp(Table.Navigationalstatus(i), actualManeuver) == 1                     % If the maneuver type remains the same
                        TableNew(idxNewTable,:) = Table(i,:);                                       % Then this point is saved
                        idxNewTable = idxNewTable + 1;
                    else                                                                            % If the maneuver type is not the same
                        boolNewTable = 1; % Marked to stop
                    end
                end
            else                                                                                    % If the time is higher than the threshold
                boolNewTable = 1; % Marked to stop
            end
            
            if boolNewTable == 1  % If its marked to stop
                if height(TableNew) > tConf.minNumTracks % and the current table has enough entries, its saved in a file
                    
                    % Its checked if the table track has enough movement
                    [Latitude] = unique(TableNew.Latitude);
                    [Longitude] = unique(TableNew.Longitude);
                    if ( length(Latitude) + length(Longitude) ) > (tConf.thresholdMovement * 2)
                        
                        % It has movement, but also need well categorized (not anchored or moored)
                        if tConf.type > 1 && strcmp(actualManeuver, 'Moored') == 0 && strcmp(actualManeuver, 'At anchor') == 0
                            nameFileWrite = strcat(folderTimestamp,"/",num2str(TableNew.MMSI(1)),"_", num2str(firstTimestamp), extension);
                            readWriteFunctions.writeMmsiTable(nameFileWrite, TableNew);
                        else
                            for j=1:height(TableNew)
                                tableMovementAnchored(cntMovementAnchored,:) = TableNew(j,:);
                                cntMovementAnchored = cntMovementAnchored + 1;
                            end
                        end
                    else % The track has not enough movement
                        % The same process checking the maneuver type
                        if strcmp(actualManeuver, 'Moored') == 1 || strcmp(actualManeuver, 'At anchor') == 1
                            nameFileWrite = strcat(folderTimestamp,"/",num2str(TableNew.MMSI(1)),"_", num2str(firstTimestamp), extension);
                            readWriteFunctions.writeMmsiTable(nameFileWrite, TableNew);
                        elseif strcmp(actualManeuver, 'Under way sailing') == 1 || strcmp(actualManeuver, 'Under way using engine') == 1
                            for j=1:height(TableNew)
                                tablenoMovementButUnderWay(cntNoMovementButUnderWay,:) = TableNew(j,:);
                                cntNoMovementButUnderWay = cntNoMovementButUnderWay + 1;
                            end
                        else
                            for j=1:height(TableNew)
                                tableNotMovement(cntNotMovement,:) = TableNew(j,:);
                                cntNotMovement = cntNotMovement + 1;
                            end
                        end
                    end
                    
                else % Don't have enough entries
                    for j=1:height(TableNew)
                        tableNotConsecutives(cntNotConsecutives,:) = TableNew(j,:);
                        cntNotConsecutives = cntNotConsecutives + 1;
                    end
                end
                
                % Reset all variables for the next entry, as a empty table
                TableNew = table;
                TableNew(1,:) = Table(i,:);
                firstTimestamp = TableNew.PosixSeconds(1);
                idxNewTable = 2;
                boolNewTable = 0;
                actualManeuver = TableNew.Navigationalstatus(1);
            end
        end
        
        % The same process when the file is over
        if height(TableNew) > tConf.minNumTracks
            % Comprobamos que las trazas tienen movimiento y no son maneuver
            nameFileWrite = strcat(folderTimestamp,"/",num2str(TableNew.MMSI(1)),'_', num2str(firstTimestamp), extension);
            readWriteFunctions.writeMmsiTable(nameFileWrite, TableNew);
        end
        
        % Finally, all tracks tables are written on a file
        if height(tableNotMovement) > 0
            nameFileWrite = strcat(folderNotMovement,"/",num2str(tableNotMovement.MMSI(1)),'_notMovement', extension);
            readWriteFunctions.writeMmsiTable(nameFileWrite, tableNotMovement);
        end
        if height(tableNotConsecutives) > 0
            nameFileWrite = strcat(folderNotConsecutives,"/",num2str(tableNotConsecutives.MMSI(1)),'_notConsecutives', extension);
            readWriteFunctions.writeMmsiTable(nameFileWrite, tableNotConsecutives);
        end
        if height(tableMovementAnchored) > 0
            nameFileWrite = strcat(folderMovementAnchored,"/",num2str(tableMovementAnchored.MMSI(1)),'_MovementAnchored', extension);
            readWriteFunctions.writeMmsiTable(nameFileWrite, tableMovementAnchored);
        end
        if height(tablenoMovementButUnderWay) > 0
            nameFileWrite = strcat(folderNoMovementButUnderWay,"/",num2str(tablenoMovementButUnderWay.MMSI(1)),'_noMovementButUnderWay', extension);
            readWriteFunctions.writeMmsiTable(nameFileWrite, tablenoMovementButUnderWay);
        end
        
    end % END type
    
end

message = strcat("END processingCleaned2Timestamp ", nameDayFolder);
telegramMessage(message);

end