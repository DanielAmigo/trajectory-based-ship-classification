%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desarrollado por | Developed by:                     %
% University Carlos III of Madrid PhD Researchers      %
% Daniel Amigo Herrero    mailto: damigo@inf.uc3m.es   %
% David Sanchez Pedroche  mailto: davsanch@inf.uc3m.es %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Este script lee los N ficheros de la carpeta Resultados, los prepara y coloca en funcion de una serie de criterios
%  All the MMSI files are readed. After that, each MMSI is cleaned, and sorted on its corresponding folder depending of some variables
function [] = mmsiToCleaned(nameDayFolder, clConf)

message = strcat("START mmsiToCleaned ", nameDayFolder);
telegramMessage(message);

% Creating the folders
folderBase          = strcat('Data/',nameDayFolder, "/", "MMSI");
folderBothUndefined = strcat('Data/',nameDayFolder, "/", "Cleaned", "/", "BothUndefined", "_", "C", "_", num2str(clConf.cleanNoiseLatLon));
folderShipUndefined = strcat('Data/',nameDayFolder, "/", "Cleaned", "/", "ShipUndefined", "_", "C", "_", num2str(clConf.cleanNoiseLatLon));
folderManeUndefined = strcat('Data/',nameDayFolder, "/", "Cleaned", "/", "ManeUndefined", "_", "C", "_", num2str(clConf.cleanNoiseLatLon));
folderBaseStations  = strcat('Data/',nameDayFolder, "/", "Cleaned", "/", "BaseStations" , "_", "C", "_", num2str(clConf.cleanNoiseLatLon));
folderCleaned       = strcat('Data/',nameDayFolder, "/", "Cleaned", "/", "Cleaned"      , "_", "C", "_", num2str(clConf.cleanNoiseLatLon));
folderNumbersMal    = strcat('Data/',nameDayFolder, "/", "Cleaned", "/", "NumbersMal"   , "_", "C", "_", num2str(clConf.cleanNoiseLatLon));
folderDimensionsMal = strcat('Data/',nameDayFolder, "/", "Cleaned", "/", "DimensionsMal", "_", "C", "_", num2str(clConf.cleanNoiseLatLon));
extension = '.csv';
% If they exist, its content is deleted. Otherwise, they are created
arrayFoldersCreate = [folderBothUndefined, folderShipUndefined, folderManeUndefined, folderBaseStations, folderCleaned, folderNumbersMal, folderDimensionsMal];
for i=1:length(arrayFoldersCreate)
    if ~exist(arrayFoldersCreate(i), 'dir')
        mkdir(arrayFoldersCreate(i))
    else
        dinfo = dir(arrayFoldersCreate(i));
        dinfo([dinfo.isdir]) = [];
        filenames = fullfile(arrayFoldersCreate(i), {dinfo.name});
        if size(filenames) > 0
            delete( filenames{:} );
        end
    end
end

% Reading the data folder
allFiles=dir(strcat(folderBase,'/*.*'));
allFiles([allFiles.isdir]) = [];   %skip directories



parfor k=1:length(allFiles)
    namefileRead = allFiles(k).name;
    fullFileRead = strcat(folderBase,'/',namefileRead);
    % disp(k + " " + namefileRead); % Current file
    
    % Read the current file
    [Table] = readWriteFunctions.readMmsiFile(fullFileRead);
    
    % The information to analyze is readed
    [Shiptypes] = unique(Table.Shiptype);
    [Cargotypes] = unique(Table.Cargotype);
    [Width] = unique(Table.Width);
    [Length] = unique(Table.Length);
    [Typeofpositionfixingdevice] = unique(Table.Typeofpositionfixingdevice);
    [Navigationalstatuses] = unique(Table.Navigationalstatus);
    [Name] = unique(Table.Name);
    [Typeofmobile] = unique(Table.Typeofmobile);
    [Draught] = unique(Table.Draught);
    [Callsign] = unique(Table.Callsign);
    [IMO] = unique(Table.IMO);
    
    % Vars to perform the analysis
    OkShiptype = 0;
    OkCargotype = 0;
    OkWidth = 0;
    OkLength = 0;
    OkDraught = 0;
    OkTypeofpositionfixingdevice = 0;
    OkNavigationalstatuses = 0;
    OkLatitude = 0;
    OkLongitude = 0;
    OkTypeofmobile = 0;
    
    if clConf.cleanNoiseLatLon== 1 % Wrong latitude/longitudes. Example: 211226990.csv
        needToDeleteRows = find(Table.Latitude >= 90);
        if length(needToDeleteRows) > 0
            Table(needToDeleteRows,:) = [];
        end
        needToDeleteRows = find(Table.Latitude == 0);
        if length(needToDeleteRows) > 0
            Table(needToDeleteRows,:) = [];
        end
        needToDeleteRows = find(Table.Longitude >= 90);
        if length(needToDeleteRows) > 0
            Table(needToDeleteRows,:) = [];
        end
        needToDeleteRows = find(Table.Longitude == 0);
        if length(needToDeleteRows) > 0
            Table(needToDeleteRows,:) = [];
        end
    end
    
    %% Clear extreme noise (max 5 complete tests, to avoid get stuck)
    counterWhile = 0;
    perfect = false;
    while perfect == false
        perfect = true;
        counterWhile = counterWhile + 1;
        if counterWhile >= 5
            break;
        end
        
        if clConf.cleanNoiseLatLon == 1
            for i=2:length(Table.Latitude)
                
                % Much movement on a small time
                if abs(Table.PosixSeconds(i) - Table.PosixSeconds(i-1)) <= 1000 && ... % One latitude point is 110km
                        (abs(Table.Latitude(i) - Table.Latitude(i-1)) >= 0.3 || ...
                        abs(Table.Longitude(i) - Table.Longitude(i-1)) >= 0.3)
                    perfect = false; % If there was an error, other test
                    
                    % Try to repair this entry
                    if abs(Table.Latitude(i)) - abs(Table.Latitude(i-1)) < 0.01 % Inverted latitude
                        Table.Latitude(i) = - Table.Latitude(i);
                    end
                    if abs(Table.Longitude(i)) - abs(Table.Longitude(i-1)) < 0.01 % Inverted longitude
                        Table.Longitude(i) = - Table.Longitude(i);
                    end
                end
            end
        end
    end
    if height(Table) <= 1 % If the MMSI track is empty, discard it
        counterWhile = 10;
    end
    
    %% Test if the MMSI maneuver says is still and the values say otherwise, and vice versa
    if length(Shiptypes) == 1 && contains(Shiptypes, 'Undefined') == 0 && contains(Shiptypes, '') == 0   % Undefined, discarded
        OkShiptype = 1;
    elseif length(Shiptypes) == 2 && sum(contains(Shiptypes, "Undefined")) == 1 % Two values and one of them is Undefined
        if strcmp(Shiptypes(1), "Undefined") == true
            realType = Shiptypes(2);
        else
            realType = Shiptypes(1);
        end
        Table.Shiptype(:) = realType; % All values are replaced to the other value
        OkShiptype = 1;
    else % MAL
    end
    
    for a=1:length(Cargotypes) % Cargotypes
        if strcmp(Cargotypes(a),'Unknown') == 0   % No Unknown
            if length(Cargotypes) > 1
                Table.Cargotype(:) = Cargotypes(a);
                OkCargotype = 1;
                break;
            end
        end
    end
    for a=1:length(Width) % All width values
        if isnan(Width(a)) == 0    % No NaN
            Table.Width(:) = Width(a);
            OkWidth = 1;
            break;
        end
    end
    for a=1:length(Length) % All Length values
        if isnan(Length(a)) == 0    % No NaN
            Table.Length(:) = Length(a);
            OkLength = 1;
            break;
        end
    end
    for a=1:length(Draught) % All Draught values
        if isnan(Draught(a)) == 0    % No NaN
            Table.Length(:) = Draught(a);
            OkDraught = 1;
            break;
        end
    end
    for a=1:length(Typeofpositionfixingdevice) % All Typeofpositionfixingdevice values
        if strcmp(Typeofpositionfixingdevice(a),'Undefined') == 0 % No Undefined
            if length(Typeofpositionfixingdevice) > 1
                selectedItem = Typeofpositionfixingdevice(a);
                selectedItem = cleanItem(selectedItem);
                Table.Typeofpositionfixingdevice(:) = selectedItem;
                OkTypeofpositionfixingdevice = 1;
                break;
            end
        end
    end
    for a=1:length(IMO) % All IMO values
        if strcmp(IMO(a),'') == 0 && strcmp(IMO(a), 'Unknown') == 0    % Neither Unknown nor ""
            if length(IMO) > 1             % Y tiene algo escrito
                selectedItem = IMO(a);
                selectedItem = cleanItem(selectedItem);
                Table.IMO(:) = selectedItem;
                OkIMO = 1;
                break;
            end
        end
    end
    for a=1:length(Callsign) % All Callsign values
        if strcmp(Callsign(a),'') == 0    % Not Undefined
            if length(Callsign) > 1
                selectedItem = Callsign(a);
                selectedItem = cleanItem(selectedItem);
                Table.Callsign(:) = selectedItem;
                OkCallsign = 1;
                break;
            end
        end
    end
    for a=1:length(Name) % All Name values
        if strcmp(Name(a),'') == 0    % Not ""
            if length(Name) > 1
                selectedItem = Name(a);
                selectedItem = cleanItem(selectedItem);
                Table.Name(:) = selectedItem;
                OkName = 1;
                break;
            end
        end
    end
    if length(Navigationalstatuses) > 0
        haveNavStat = find(contains(Navigationalstatuses,'Unknown value'));
        if haveNavStat > 0
            if length(Navigationalstatuses) > 1
                OkNavigationalstatuses = 1;
            else
                OkNavigationalstatuses = 0;
            end
        else
            OkNavigationalstatuses = 2;
        end
    end
    
    %% Each type to its corresponding folder
    isBaseStation = find(contains(Typeofmobile,'Base Station'));
    if isBaseStation > 0
        nameFileWrite = strcat(folderBaseStations,'/',namefileRead);
        readWriteFunctions.writeMmsiTable(nameFileWrite, Table);
        continue;
    end
    if OkNavigationalstatuses == 0
        if OkShiptype == 0
            nameFileWrite = strcat(folderBothUndefined,'/',namefileRead);
            readWriteFunctions.writeMmsiTable(nameFileWrite, Table);
            continue;
        else
            nameFileWrite = strcat(folderManeUndefined,'/',namefileRead);
            readWriteFunctions.writeMmsiTable(nameFileWrite, Table);
            continue;
        end
    end
    if counterWhile >= 5
        nameFileWrite = strcat(folderNumbersMal,'/',namefileRead);
        readWriteFunctions.writeMmsiTable(nameFileWrite, Table);
        continue;
    end
    if OkShiptype == 0
        nameFileWrite = strcat(folderShipUndefined,'/',namefileRead);
        readWriteFunctions.writeMmsiTable(nameFileWrite, Table);
        continue;
    end
    if OkLength ~=1 && OkWidth ~= 1
        nameFileWrite = strcat(folderDimensionsMal,'/',namefileRead);
        readWriteFunctions.writeMmsiTable(nameFileWrite, Table);
        continue;
    end
    
    if OkNavigationalstatuses == 1
        discardTracks = table;
        cnt = 1;
        sizeTable = height(Table);
        idxWhile = 1;
        while idxWhile < sizeTable
            if strcmp(Table.Navigationalstatus(idxWhile), 'Unknown value') == 1 || strcmp(Table.Navigationalstatus(idxWhile), '') == 1
                discardTracks(cnt, :) = Table(idxWhile, :);
                Table(idxWhile, :) = [];
                cnt = cnt + 1;
                idxWhile = idxWhile - 1;
                sizeTable = sizeTable - 1;
            end
            idxWhile = idxWhile + 1;
        end
        
        nameFileWrite = strcat(folderManeUndefined,'/',namefileRead(1:end-4),'_discarded',extension);
        readWriteFunctions.writeMmsiTable(nameFileWrite, discardTracks);
        delete(fullFileRead);
        nameFileWrite = strcat(folderCleaned,'/',namefileRead);
        readWriteFunctions.writeMmsiTable(nameFileWrite, Table);
    end
    
    % If neither bad category was detected, it goes to the clean folder
    nameFileWrite = strcat(folderCleaned,'/',namefileRead);
    readWriteFunctions.writeMmsiTable(nameFileWrite, Table);
end

message = strcat("END mmsiToCleaned ", nameDayFolder);
telegramMessage(message);

end


%% Clean certain characters of the name
function [newString] = cleanItem(string)
newString = string;
newString = strrep(newString, '\', ' ');
newString = strrep(newString, '/', ' ');
newString = strrep(newString, '^', ' ');
newString = strrep(newString, '`', ' ');
newString = strrep(newString, '~', ' ');
end