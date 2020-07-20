%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desarrollado por | Developed by:                     %
% University Carlos III of Madrid PhD Researchers      %
% Daniel Amigo Herrero    mailto: damigo@inf.uc3m.es   %
% David Sanchez Pedroche  mailto: davsanch@inf.uc3m.es %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Este script lee los ficheros de la carpeta Files, y realiza una imagen concreta para destacar los errores de AIS
%  This script reads the files in the Files folder, and creates a specific image to highlight the AIS errors
function trajectoriesToImageDefault()

close all;

currentFilePath = mfilename('fullpath');
aux = split(currentFilePath, '\');
currentPath = "";
for i=1:length(aux)-1
    currentPath = strcat(currentPath, aux{i}, "/");
end
currentPath = strcat(currentPath, "Files");

% Variables que definen el fichero a procesar
folders = strcat(currentPath, "/Timestamped_C_1_T_2_11_50_5"); % Para pintar solo la trayectoria del girito
%folders = ["Data/selectedToImage/Cleaned_C_0"];
folderSizeAcum = zeros(length(folders), 1);

% Obtenemos todos los ficheros a procesar
numIter = 0;
if length(folders) == 1
    allFiles = dir(strcat(folders(1),'/*.*'));
    if length(allFiles) == 0
        error("No se ha cargado la carpeta correctamente");
    end
    allFiles([allFiles.isdir]) = [];   %skip directories
    numIter=length(allFiles);
elseif length(folders) > 1
    for i=2:length(folders)
        allFiles = dir(strcat(folders(i-1),'/*.*'));
        if length(allFiles) == 0
            error("No se ha cargado la carpeta correctamente");
        end
        allFiles([allFiles.isdir]) = [];   %skip directories
        numIter = numIter + length(allFiles);
        folderSizeAcum(i) = numIter;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OBTENCI�N DE LOS DATOS COLOCADOS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Data = cell(numIter, 1);
fileName = strings(numIter, 1);

for l=1:length(folders) % Para cada carpeta
    allFiles = dir(strcat(folders(l),'/*.*'));
    allFiles([allFiles.isdir]) = [];   % Saltamos los dos primeros, que son ./ y ../
    for k=1+folderSizeAcum(l):length(allFiles)+folderSizeAcum(l)   % Para cada fichero de esta carpeta
        nameFileRead = allFiles(k-folderSizeAcum(l)).name;
        fullFileRead = strcat(folders(l),'/',nameFileRead);                     % Path de lectura
        
        % Se lee el fichero
        % disp(fullFileRead);
        [aux] = readWriteFunctions.readMmsiTimestampedFile(fullFileRead);
        
        aux.Callsign = []; % Tambien se limpian variables que no se usar�n
        aux.Name = [];
        % aux.VarName24 = [];
        aux.Datasourcetype = [];
        aux.Destination = [];
        aux.Typeofpositionfixingdevice = [];
        aux.ETA = [];
        aux.Cargotype = [];
        aux.Typeofmobile = [];
        aux.IMO = [];
        aux.Width = [];
        aux.Length = [];
        aux.Draught = [];
        aux.RateOfTurn = [];
        aux.Speed = [];
        aux.Course = [];
        aux.Heading = [];
        aux.Timestamp = [];
        
        Data{k} = aux;
        
        fileName(k) = nameFileRead;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CREACI�N DE LA FIGURA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figureMap = figure;
mapObject = geoaxes;
geotickformat('-dd');
% mapObject.Basemap = 'colorterrain';
% title( "Time gap" );
hold on;

% Una vez se tiene toda la info, se pinta
Plots = gobjects(length(Data), 1);
texts = cell(numIter, 1);

%a = ["selected", "notConsecutives"];

for k=1:numIter   % Saltamos los dos primeros, que son ./ y ../

    posixTime = Data{k}.PosixSeconds;      %/1000; % 28-Aug-2009 14:50:55 UTC
    posixDays = posixTime/(60*60*24);
    epoch = datenum(1970,1,1,0,0,0);    % Get the serial date number representing the POSIX epoch
    ts = epoch + posixDays;             % Add this value to the serial date number representing the epoch
    
    legendName = "";
    if contains(fileName(k), "notConsecutives")
        legendName = strcat("NotConsecutiveContacts: ", num2str(height(Data{k})));
        markerColor = 'k';
        markerUsed = '.';
    else
        legendName = strcat("ConsecutiveTracks: ", num2str(length(Data)-1));
        markerColor = 'b';
        markerUsed = '.';
    end
    Plots(k) = geoscatter(Data{k}.Latitude, Data{k}.Longitude, "Marker", '.', "DisplayName", legendName, "Marker", markerUsed, "MarkerEdgeColor", markerColor, "MarkerFaceColor", markerColor); % "DisplayName", a(k)
end

% Leyenda
toLegend = [];
onlyOne = true;
for k=1:length(fileName)
    if contains(fileName(k), "notConsecutives")
        toLegend = [toLegend Plots(k)];
    elseif onlyOne == true
        toLegend = [toLegend Plots(k)];
        onlyOne = false;
    end
end
leg = legend(toLegend, 'Location', 'southeast');

print(gcf, strcat(currentPath, "untitled"), '-dsvg'); % Se guarda en fichero

end