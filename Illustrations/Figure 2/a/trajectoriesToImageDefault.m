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
clc;
clear;

% Create auxiliar variables and folders
currentFilePath = mfilename('fullpath');
aux = split(currentFilePath, '\');
currentPath = "";
for i=1:length(aux)-1
    currentPath = strcat(currentPath, aux{i}, "/");
end
currentPath = strcat(currentPath, "Files");
allFiles = dir(strcat(currentPath,'/*.*'));
allFiles = dir(strcat(currentPath,'/*.*'));
allFiles([allFiles.isdir]) = [];
numIter = length(allFiles);

% Read the data
Data = cell(numIter, 1);
fileName = strings(numIter, 1);

for k=1:length(allFiles)
    nameFileRead = allFiles(k).name;
    fullFileRead = strcat(currentPath,'/',nameFileRead);

    [aux] = readWriteFunctions.readMmsiFile(fullFileRead);

    aux.Callsign = []; % unused variables are cleaned out
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

% The figure is created
figureMap = figure;
mapObject = geoaxes;
geotickformat('-dd');
% mapObject.Basemap = 'colorterrain';
hold on;
nlat = [54.7   55.05]; % custom location
nlon = [10.53   11.65];
[n2lat n2lon] = geolimits(nlat,nlon);

Plots = gobjects(length(Data), 1);
texts = cell(numIter, 1);

for k=1:numIter
    entriesMal = [6347, 5758, 4346];  % Incorrect entries on the table
    DataBad = Data{k}(entriesMal,:);
    DataBien = Data{k}(:,:);
    DataBien(entriesMal,:) = [];
    fig = figure(k);
    % fig.Visible = 'off';

    scatterBien = geoscatter(DataBien.Latitude, DataBien.Longitude, 'Marker', '.', 'MarkerEdgeColor', 'k', 'DisplayName', 'Correct');
    scatterMal = geoscatter(DataBad.Latitude, DataBad.Longitude, 'Marker', 'x', 'MarkerEdgeColor', 'r', 'SizeData', 400, 'DisplayName', 'Errors');
    legend('Location', 'southeast');
    % title( fileName(k) );

    a = split(fileName(k), "/");
    b = split(a(end), ".");
end

end