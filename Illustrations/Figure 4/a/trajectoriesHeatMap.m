%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desarrollado por | Developed by:                     %
% University Carlos III of Madrid PhD Researchers      %
% Daniel Amigo Herrero    mailto: damigo@inf.uc3m.es   %
% David Sanchez Pedroche  mailto: davsanch@inf.uc3m.es %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Script que lee todas las trayectorias que se le pasan por par�metro y las pinta TODAS seg�n el tipo de barco

function trajectoriesHeatMap()

close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PREPARACI�N DE VARIABLES, CARPETAS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables que definen el fichero a procesar
modeImage = 0; % 0: puntos en Scatter | 1: MMSI en scatter usando Cleaned y sus errores | 2: heatmap del tipo de barco

% Lugar donde sacar la imagen
currentFilePath = mfilename('fullpath');
aux = split(currentFilePath, '\');
currentPath = "";
for i=1:length(aux)-1
    currentPath = strcat(currentPath, aux{i}, "/");
end

folders = [strcat(currentPath, "Files/", "MMSI Day25"), strcat(currentPath, "Files/", "MMSI Day26"), strcat(currentPath, "Files/", "MMSI Day27")];
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
workspaceMat = strcat(currentPath, "workspace", num2str(numIter), ".mat");

% Se hace un clave-valor para obtener el color
searchedShiptypes = ["Cargo", "Fishing", "Passenger", "Tanker", "Other"];
valueSet = ["k" "r" "g" "b" "y"];
color = containers.Map(searchedShiptypes,valueSet);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OBTENCI�N DE LOS DATOS COLOCADOS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isfile(workspaceMat) % Si aun no se ha hecho el workspace se leen y se hace ahora
    Data = cell(numIter, 1);
    fileName = strings(numIter, 1);
    folderName = strings(numIter, 1);
    ShipType = strings(numIter, 1);
    
    for l=1:length(folders) % Para cada carpeta
        allFiles = dir(strcat(folders(l),'/*.*'));
        allFiles([allFiles.isdir]) = [];   % Saltamos los dos primeros, que son ./ y ../
        parfor k=1+folderSizeAcum(l):length(allFiles)+folderSizeAcum(l)   % Para cada fichero de esta carpeta
            nameFileRead = allFiles(k-folderSizeAcum(l)).name;
            fullFileRead = strcat(folders(l),'/',nameFileRead);                     % Path de lectura
            
            % Se lee el fichero
            % disp(fullFileRead);
            [aux] = readWriteFunctions.readMmsiFile(fullFileRead);
            if height(aux) == 0
                continue
            end
            
            % Se limpia de latitudes incorrectas, que las hay. EJ: 211226990.csv
            needToDeleteRows = find(aux.Latitude >= 90);
            if length(needToDeleteRows) > 0
                disp(nameFileRead);
                aux(needToDeleteRows,:) = [];
            end
            needToDeleteRows = find(aux.Latitude == 0);
            if length(needToDeleteRows) > 0
                disp(nameFileRead);
                aux(needToDeleteRows,:) = [];
            end
            needToDeleteRows = find(aux.Shiptype == "Undefined");
            if length(needToDeleteRows) > 0
                disp(nameFileRead);
                aux(needToDeleteRows,:) = [];
            end
            
            % Se limpian saltos en lat o lon super grandes, que son errores
            needToDeleteRows = [];
            for i=2:length(aux.Latitude)
                if (abs(aux.Latitude(i) - aux.Latitude(i-1)) >= 1 || abs(aux.Longitude(i) - aux.Longitude(i-1)) >= 1) && abs(aux.PosixSeconds(i) - aux.PosixSeconds(i-1)) <= 1000 % Si se mueve mucho, se apunta
                    needToDeleteRows(end+1) = i;
                end
            end
            if length(needToDeleteRows) > 0
                aux(needToDeleteRows,:) = [];
            end
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
            fileName(k) = fullFileRead;
            folderName(k) = folders(l);
            
            % Se extrae el tipo de barco que utiliza para pintarlo
            result = intersect(searchedShiptypes, unique(Data{k}.Shiptype));
            if length(result) > 0
                ShipType(k) = result;
            else
                ShipType(k) = "Other";
            end
        end
    end
    
    save(workspaceMat, 'Data', 'ShipType', 'fileName', 'folderName', '-v7.3');
else
    load(workspaceMat, 'Data', 'ShipType', 'fileName', 'folderName');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CREACI�N DE LA FIGURA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mapObject = geoaxes;
geolimits(mapObject,[53 59.5], [2 18.2]);
%mapObject.ZoomLevel = nzoom;
geotickformat('-dd');
% mapObject.Basemap = 'colorterrain';
hold on;
nlat = [53   59.55];
nlon = [4.3  16.8];
[n2lat n2lon] = geolimits(nlat,nlon);

% Una vez se tiene toda la info, se pinta
Plots = gobjects(length(Data), 1);

% Para la cuenta de puntos sobre la carpeta MMSI
cntPoints = 0;

for k=1:numIter   % Saltamos los dos primeros, que son ./ y ../
    
    if ~isempty(Data{k})
        if length(Data{k}.Longitude) > 0 % Prevenci�n error
            
            if modeImage == 0
                % Se pinta scatter cuando es MMSI
                cntPoints = cntPoints + height(Data{k});
                size = ones(height(Data{k}), 1) * 20;
                Plots(k) = geoscatter(Data{k}.Latitude, Data{k}.Longitude, size, "Marker", '.', "MarkerEdgeColor", 'b', "MarkerFaceColor", 'b');
            end
        end
    end
end

print(gcf, strcat(currentPath, "AllPoints"), '-dpng','-r400'); % Se guarda en fichero