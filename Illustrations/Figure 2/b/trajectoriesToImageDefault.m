%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desarrollado por | Developed by:                     %
% University Carlos III of Madrid PhD Researchers      %
% Daniel Amigo Herrero    mailto: damigo@inf.uc3m.es   %
% David Sanchez Pedroche  mailto: davsanch@inf.uc3m.es %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Script que lee todas las trayectorias que se le pasan por par�metro y las pinta

function trajectoriesToImageDefault()

close all;
clc;
clear;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PREPARACI�N DE VARIABLES, CARPETAS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables que definen el fichero a procesar
currentFilePath = mfilename('fullpath');
aux = split(currentFilePath, '\');
currentPath = "";
for i=1:length(aux)-1
    currentPath = strcat(currentPath, aux{i}, "/");
end
currentPath = strcat(currentPath, "Files");
allFiles = dir(strcat(currentPath,'/*.*'));
allFiles([allFiles.isdir]) = [];   % Saltamos los dos primeros, que son ./ y ../
numIter = length(allFiles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OBTENCI�N DE LOS DATOS COLOCADOS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Data = cell(numIter, 1);
fileName = strings(numIter, 1);

for k=1:length(allFiles)   % Para cada fichero de esta carpeta
    nameFileRead = allFiles(k).name;
    fullFileRead = strcat(currentPath,'/',nameFileRead);                     % Path de lectura

    % Se lee el fichero
    [aux] = readWriteFunctions.readMmsiFile(fullFileRead);

    aux.Callsign = []; % Tambien se limpian variables que no se usar�n
    aux.Name = [];
    aux.VarName24 = [];
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SE CALCULAN LOS SPLITS ESTATICOS CON 10 SEGUNDOS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CREACI�N DE LA FIGURA GLOBAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figureMap = figure;
mapObject = geoaxes;
geotickformat('-dd');
% mapObject.Basemap = 'colorterrain';
% title( "Time gap" );
hold on;
nlat = [57.075   57.55];
nlon = [7.4  8.65];
[n2lat n2lon] = geolimits(nlat,nlon);

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
        legendName = strcat("Not consecutives");
        markerColor = 'r';
        markerUsed = '.';
    else
        legendName = strcat("Selected");
        markerColor = 'b';
        markerUsed = '.';
    end
    Plots(k) = geoscatter(Data{k}.Latitude, Data{k}.Longitude, "Marker", '.', "DisplayName", legendName, "Marker", markerUsed, "MarkerEdgeColor", markerColor, "MarkerFaceColor", markerColor); % "DisplayName", a(k)
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CREACI�N DE LA FIGURA ZOOM INTERMEDIO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figureMap = figure;
mapObject = geoaxes;
geotickformat('-dd');
% mapObject.Basemap = 'colorterrain';
% title( "Time gap" );
hold on;
nlat = [57.157   57.169];
nlon = [8.4725 8.505];
[n2lat n2lon] = geolimits(nlat,nlon);

% Una vez se tiene toda la info, se pinta
Plots = gobjects(length(Data), 1);
texts = cell(numIter, 1);

for k=1:numIter   % Saltamos los dos primeros, que son ./ y ../

    posixTime = Data{k}.PosixSeconds;      %/1000; % 28-Aug-2009 14:50:55 UTC
    posixDays = posixTime/(60*60*24);
    epoch = datenum(1970,1,1,0,0,0);    % Get the serial date number representing the POSIX epoch
    ts = epoch + posixDays;             % Add this value to the serial date number representing the epoch
    
    auxJ = zeros(0,1);
    for j=2:height(Data{k})
        % Para imprimir los saltos de tiempo entre uno y otro
        thisLat     = Data{k}.Latitude(j);
        thisLon     = Data{k}.Longitude(j);
        thisSeconds = Data{k}.PosixSeconds(j);
        prevLat      = Data{k}.Latitude(j-1);
        prevLon      = Data{k}.Longitude(j-1);
        prevSeconds  = Data{k}.PosixSeconds(j-1);
        if thisSeconds - prevSeconds > 8
            thisTime = thisSeconds - prevSeconds;
            message = strcat('\leftarrow ', num2str(thisTime));
            texts{k}(end+1) = text(thisLat, thisLon, message);
            auxJ(end+1) = j;
        end
    end
    
    legendName = "";
    if contains(fileName(k), "notConsecutives")
        legendName = strcat("Not consecutives");
        markerColor = 'r';
        markerUsed = '.';
    else
        legendName = strcat("Selected");
        markerColor = 'b';
        markerUsed = '.';
    end
    Plots(k) = geoscatter(Data{k}.Latitude, Data{k}.Longitude, "Marker", '.', "DisplayName", legendName, "Marker", markerUsed, "MarkerEdgeColor", markerColor, "MarkerFaceColor", markerColor); % "DisplayName", a(k)
end

% Para imprimir los saltos de tiempo entre uno y otro. PARA UNA IMAGEN
%CONCRETA ESTOS NUMEROS
for k=1:numIter
    for j=1:length(texts{k})
        if j > 116 && j < 146
            texts{k}(j).Visible = 'on';
        else
            texts{k}(j).Visible = 'off';
        end
    end
end


% Para ajustar lo pintado si se desea. PRUEBAS
%for k=1:numIter   % Saltamos los dos primeros, que son ./ y ../
%    Plots(k).Color = "r";
%end

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
%title("Timestamped");
leg = legend(toLegend, 'Location', 'southeast');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CREACI�N DE LA FIGURA ZOOM INICIAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figureMap = figure;
mapObject = geoaxes;
geotickformat('-dd');
% mapObject.Basemap = 'colorterrain';
% title( "Time gap" );
hold on;
nlat = [57.118 57.124];
nlon = [8.589 8.6];
[n2lat n2lon] = geolimits(nlat,nlon);

% Una vez se tiene toda la info, se pinta
Plots = gobjects(length(Data), 1);
texts = cell(numIter, 1);

%a = ["selected", "notConsecutives"];

for k=1:numIter   % Saltamos los dos primeros, que son ./ y ../

    posixTime = Data{k}.PosixSeconds;      %/1000; % 28-Aug-2009 14:50:55 UTC
    posixDays = posixTime/(60*60*24);
    epoch = datenum(1970,1,1,0,0,0);    % Get the serial date number representing the POSIX epoch
    ts = epoch + posixDays;             % Add this value to the serial date number representing the epoch
    
    auxJ = zeros(0,1);
    for j=2:height(Data{k})
        % Para imprimir los saltos de tiempo entre uno y otro
        thisLat     = Data{k}.Latitude(j);
        thisLon     = Data{k}.Longitude(j);
        thisSeconds = Data{k}.PosixSeconds(j);
        prevLat      = Data{k}.Latitude(j-1);
        prevLon      = Data{k}.Longitude(j-1);
        prevSeconds  = Data{k}.PosixSeconds(j-1);
        if thisSeconds - prevSeconds > 8
            thisTime = thisSeconds - prevSeconds;
            message = strcat('\leftarrow ', num2str(thisTime));
            texts{k}(end+1) = text(thisLat, thisLon, message);
            auxJ(end+1) = j;
        end
    end
    
    legendName = "";
    if contains(fileName(k), "notConsecutives")
        legendName = strcat("Not consecutives");
        markerColor = 'r';
        markerUsed = '.';
    else
        legendName = strcat("Selected");
        markerColor = 'b';
        markerUsed = '.';
    end
    Plots(k) = geoscatter(Data{k}.Latitude, Data{k}.Longitude, "Marker", '.', "DisplayName", legendName, "Marker", markerUsed, "MarkerEdgeColor", markerColor, "MarkerFaceColor", markerColor); % "DisplayName", a(k)
end

% Para imprimir los saltos de tiempo entre uno y otro. PARA UNA IMAGEN
%CONCRETA ESTOS NUMEROS
%{
for k=1:numIter
    for j=1:length(texts{k})
        if j > 116 && j < 146
            texts{k}(j).Visible = 'on';
        else
            texts{k}(j).Visible = 'off';
        end
    end
end
%}

% Para ajustar lo pintado si se desea. PRUEBAS
%for k=1:numIter   % Saltamos los dos primeros, que son ./ y ../
%    Plots(k).Color = "r";
%end

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
%title("Timestamped");
leg = legend(toLegend, 'Location', 'southeast');

end