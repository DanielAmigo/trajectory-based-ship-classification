%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desarrollado por | Developed by:                     %
% University Carlos III of Madrid PhD Researchers      %
% Daniel Amigo Herrero    mailto: damigo@inf.uc3m.es   %
% David Sanchez Pedroche  mailto: davsanch@inf.uc3m.es %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Recibe una carpeta con muchos ficheros resultado del proceso featureExtraction. Sobre cada fichero, apunta el numero de trayectorias, las lineas totales, numero de cada tipo de clase...
%  Receives a folder with some results of the featureExtraction process. On each process, opens it and writes down the number of files, the total lines and the number of ships per type
function [numFiles, numEntries] = countPreclassifier(folderRead)

% Get all files of the folder
allFiles = dir(strcat(folderRead, "/*.*"));
allFiles([allFiles.isdir]) = [];   %skip directories

% Specify the major types to count per class
classesShipType = ["Cargo", "Fishing", "Passenger", "Tanker", "Undefined"];
classesManeuver = ["Engaged in fishing", "Restricted maneuverability", "Under way sailing", "Under way using engine", "Unknown value"];

numFiles = length(allFiles);
countPerFile = zeros(numFiles, 1);
% Shiptypes
summaryCargo     = zeros(numFiles, 1);
summaryFishing   = zeros(numFiles, 1);
summaryPassenger = zeros(numFiles, 1);
summaryTanker    = zeros(numFiles, 1);
summaryUndefined = zeros(numFiles, 1);
summaryOtherShip = zeros(numFiles, 1);

parfor k=1:numFiles
    nameFileRead = allFiles(k).name;
    fullFileRead = strcat(folderRead,'/',nameFileRead); % Path de lectura
    
    fid = fopen(fullFileRead);
    line = fgetl(fid); % Reading the header
    while true
        line = fgetl(fid);
        if ~ischar( line ); break; end
        
        splittedLine = split(line, ";");
        a = find(ismember(classesShipType, splittedLine{5}));
        if a == 1
            summaryCargo(k) = summaryCargo(k) + 1;
        elseif a == 2
            summaryFishing(k) = summaryFishing(k) + 1;
        elseif a == 3
            summaryPassenger(k) = summaryPassenger(k) + 1;
        elseif a == 4
            summaryTanker(k) = summaryTanker(k) + 1;
        elseif a == 5
            summaryUndefined(k) = summaryUndefined(k) + 1;
        else
            summaryOtherShip(k) = summaryOtherShip(k) + 1;
        end
        countPerFile(k) = countPerFile(k) + 1;
    end
    fclose(fid);
end

% One file for all featureExtraction outputs
fileWrite = strcat(folderRead, "\", "metrics.csv");
fid = fopen(fileWrite, 'a');
% Write the header
fprintf(fid, strcat("Preclassifier", '; '));
fprintf(fid, strcat("NumEntries", '; '));
fprintf(fid, strcat("NumCargo", '; '));
fprintf(fid, strcat("NumFishing", '; '));
fprintf(fid, strcat("NumPassenger", '; '));
fprintf(fid, strcat("NumTanker", '; '));
fprintf(fid, strcat("NumUndefined", '; '));
fprintf(fid, strcat("NumOther", '; '));
fprintf(fid, "\n");

% Results
for k=1:numFiles
    fprintf(fid, strcat(allFiles(k).name, '; '));
    fprintf(fid, strcat(num2str(countPerFile(k)), '; '));
    fprintf(fid, strcat(num2str(summaryCargo(k)), '; '));
    fprintf(fid, strcat(num2str(summaryFishing(k)), '; '));
    fprintf(fid, strcat(num2str(summaryPassenger(k)), '; '));
    fprintf(fid, strcat(num2str(summaryTanker(k)), '; '));
    fprintf(fid, strcat(num2str(summaryUndefined(k)), '; '));
    fprintf(fid, strcat(num2str(summaryOtherShip(k)), '; '));
    fprintf(fid, "\n");
end

fclose(fid);

end