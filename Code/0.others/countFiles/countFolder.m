%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desarrollado por | Developed by:                     %
% University Carlos III of Madrid PhD Researchers      %
% Daniel Amigo Herrero    mailto: damigo@inf.uc3m.es   %
% David Sanchez Pedroche  mailto: davsanch@inf.uc3m.es %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Recibe una carpeta, la abre y apunta el numero de ficheros y las lineas totales
%  Receives a folder, opens it and writes down the number of files, the total lines and the number of ships per type
function [numFiles, numEntries, countPerManeuver, countPerShiptype] = countFolder(folderRead)

% Specify the major types to count per class
classesShipType = ["Cargo", "Fishing", "Passenger", "Tanker", "Undefined"];
classesManeuver = ["Engaged in fishing", "Restricted maneuverability", "Under way sailing", "Under way using engine", "Unknown value"];

allFiles = dir(strcat(folderRead, "/*.csv")); % Get all CSV files
allFiles([allFiles.isdir]) = [];              % skip directories

% auxiliar variables
numFiles = length(allFiles);
countPerFile = zeros(numFiles, 1);
% each ship type counter
isCargo     = zeros(numFiles, 1);
isFishing   = zeros(numFiles, 1);
isPassenger = zeros(numFiles, 1);
isTanker    = zeros(numFiles, 1);
isUndefined = zeros(numFiles, 1);
isOtherShip = zeros(numFiles, 1);
% each maneuver type counter
isEngaged    = zeros(numFiles, 1);
isRestricted = zeros(numFiles, 1);
isSailing    = zeros(numFiles, 1);
isEngine     = zeros(numFiles, 1);
isUnknown    = zeros(numFiles, 1);
isOtherMane  = zeros(numFiles, 1);


parfor k=1:numFiles
    nameFileRead = allFiles(k).name;
    fullFileRead = strcat(folderRead,'/',nameFileRead); % Path de lectura
    
    fid = fopen(fullFileRead);
    fgetl(fid);             % Reading the header
    firstLine = fgetl(fid); % Reading the first line
    if firstLine ~= -1      % error prevention. If the file only has a header
        splitted = split(firstLine, ";");
        
        a = find(ismember(classesShipType, splitted{15})); % Get the shiptype
        if a == 1
            isCargo(k) = isCargo(k) + 1;
        elseif a == 2
            isFishing(k) = isFishing(k) + 1;
        elseif a == 3
            isPassenger(k) = isPassenger(k) + 1;
        elseif a == 4
            isTanker(k) = isTanker(k) + 1;
        elseif a == 5
            isUndefined(k) = isUndefined(k) + 1;
        else
            isOtherShip(k) = isOtherShip(k) + 1;
        end
        
        a = find(ismember(classesManeuver, splitted{7})); % Get the maneuver
        if a == 1
            isEngaged(k) = isEngaged(k) + 1;
        elseif a == 2
            isRestricted(k) = isRestricted(k) + 1;
        elseif a == 3
            isSailing(k) = isSailing(k) + 1;
        elseif a == 4
            isEngine(k) = isEngine(k) + 1;
        elseif a == 5
            isUnknown(k) = isUnknown(k) + 1;
        else
            isOtherMane(k) = isOtherMane(k) + 1;
        end
        
        % Read the rest of the file to count the number of lines
        % if the classes change within the file, this is wrong
        while true
            if ~ischar( fgetl(fid) ); break; end
            countPerFile(k) = countPerFile(k) + 1;
        end
        fclose(fid);
    end
    
end

% Not counting the last line
countPerFile(:) = countPerFile(:) - 1;
numEntries = sum(countPerFile);

% Final results per class
countPerManeuver = zeros(length(classesManeuver)+1, 1);
for i=1:length(classesManeuver)+1
    if i == 1
        countPerManeuver(i) = sum(isEngaged(:));
    elseif i == 2
        countPerManeuver(i) = sum(isRestricted(:));
    elseif i == 3
        countPerManeuver(i) = sum(isSailing(:));
    elseif i == 4
        countPerManeuver(i) = sum(isEngine(:));
    elseif i == 5
        countPerManeuver(i) = sum(isUnknown(:));
    else
        countPerManeuver(i) = sum(isOtherMane(:));
    end
end
countPerShiptype = zeros(length(classesShipType)+1, 1);
for i=1:length(classesShipType)+1
    if i == 1
        countPerShiptype(i) = sum(isCargo(:));
    elseif i == 2
        countPerShiptype(i) = sum(isFishing(:));
    elseif i == 3
        countPerShiptype(i) = sum(isPassenger(:));
    elseif i == 4
        countPerShiptype(i) = sum(isTanker(:));
    elseif i == 5
        countPerShiptype(i) = sum(isUndefined(:));
    else
        countPerShiptype(i) = sum(isOtherShip(:));
    end
end

end