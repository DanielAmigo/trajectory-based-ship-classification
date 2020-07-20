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

% Lugar donde sacar la imagen
currentFilePath = mfilename('fullpath');
aux = split(currentFilePath, '\');
currentPath = "";
for i=1:length(aux)-1
    currentPath = strcat(currentPath, aux{i}, "/");
end

days = ["Day25", "Day26", "Day27"];
foldersSelected = ["BothUndefined_C_1", "DimensionsMal_C_1", "ManeUndefined_C_1", "NumbersMal_C_1", "ShipUndefined_C_1", ...
    "NotMovement_C_1_T_2_11_50_5", "NotConsecutives_C_1_T_2_11_50_5", "NoMovementButUnderWay_C_1_T_2_11_50_5", "MovementAnchored_C_1_T_2_11_50_5", "Timestamped_C_1_T_2_11_50_5"];
folders = strings(0,1);
for j=1:length(foldersSelected)
    for i=1:length(days)
        folders(end+1) = strcat(currentPath, "Files/", days(i), "/", foldersSelected(j));
    end
end
modeImage = 1; % 0: puntos en Scatter | 1: MMSI en scatter usando Cleaned y sus errores | 2: heatmap del tipo de barco

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
% Para la cuenta sobre todos los Cleaned
cntBaseStations = 0;
cntBothUndefined = 0;
cntCleaned = 0;
cntDimensionsMal = 0;
cntManeUndefined = 0;
cntNumbersMal = 0;
cntShipUndefined = 0;
idxsCle = zeros(7,1); % Se apunta uno de cada para la legend

% Para la cuenta de Cleaned y Timestamped a la vez
cntExtremeNoise = 0;       % NumbersMal_C_1
cntNullClasses = 0;        % BothUndefined_C_1, DimensionsMal_C_1, ManeUndefined_C_1 Cleaned, ShipUndefined_C_1
cntTimestamped = 0;        % Timestamped
cntMovInconsistencies = 0; % NoMovementButUnderWay, MovementAnchored
cntNotMovement = 0;        % NotMovement
cntNotConsecutives = 0;    % NotConsecutives
idxsCleTim = zeros(6,1);   % Se apunta uno de cada para la legend


for k=1:numIter   % Saltamos los dos primeros, que son ./ y ../
    
    if ~isempty(Data{k})
        if length(Data{k}.Longitude) > 0 % Prevenci�n error
            
            %{
            if contains(folderName(k), "BaseStations_C_1")
                colorSelected = 'y';
                markerSel = '.';
                sizeNum = 20;
                cntBaseStations = cntBaseStations + 1;
                if cntBaseStations == 1
                    idxsCle(1) = k;
                end
            elseif contains(folderName(k), "BothUndefined_C_1")
                colorSelected = 'g';
                markerSel = '.';
                sizeNum = 20;
                cntBothUndefined = cntBothUndefined + 1;
                if cntBothUndefined == 1
                    idxsCle(2) = k;
                end
            elseif contains(folderName(k), "Cleaned_C_1")
                colorSelected = 'b';
                markerSel = '.';
                sizeNum = 20;
                cntCleaned = cntCleaned + 1;
                if cntCleaned == 1
                    idxsCle(3) = k;
                end
            elseif contains(folderName(k), "DimensionsMal_C_1")
                colorSelected = 'm';
                markerSel = '.';
                sizeNum = 20;
                cntDimensionsMal = cntDimensionsMal + 1;
                if cntDimensionsMal == 1
                    idxsCle(4) = k;
                end
            elseif contains(folderName(k), "ManeUndefined_C_1")
                colorSelected = 'r';
                markerSel = '.';
                sizeNum = 20;
                cntManeUndefined = cntManeUndefined + 1;
                if cntManeUndefined == 1
                    idxsCle(5) = k;
                end
            elseif contains(folderName(k), "NumbersMal_C_1")
                colorSelected = 'k';
                markerSel = '.';
                sizeNum = 20;
                cntNumbersMal = cntNumbersMal + 1;
                if cntNumbersMal == 1
                    idxsCle(6) = k;
                end
            elseif contains(folderName(k), "ShipUndefined_C_1")
                colorSelected = 'c';
                markerSel = '.';
                sizeNum = 20;
                cntShipUndefined = cntShipUndefined + 1;
                if cntShipUndefined == 1
                    idxsCle(7) = k;
                end
            end
            %}
            
            if contains(folderName(k), "NumbersMal_C_1")
                colorSelected = 'r';
                markerSel = '.';
                sizeNum = 20;
                cntExtremeNoise = cntExtremeNoise + 1;
                if cntExtremeNoise == 1
                    idxsCleTim(1) = k;
                end
            elseif contains(folderName(k), "BothUndefined_C_1") || contains(folderName(k), "DimensionsMal_C_1") || contains(folderName(k), "ManeUndefined_C_1") || contains(folderName(k), "ShipUndefined_C_1")
                colorSelected = 'g';
                markerSel = '.';
                sizeNum = 20;
                cntNullClasses = cntNullClasses + 1;
                if cntNullClasses == 1
                    idxsCleTim(2) = k;
                end
            elseif contains(folderName(k), "Timestamped")
                colorSelected = 'b';
                markerSel = '.';
                sizeNum = 20;
                cntTimestamped = cntTimestamped + 1;
                if cntTimestamped == 1
                    idxsCleTim(3) = k;
                end
            elseif contains(folderName(k), "NoMovementButUnderWay") || contains(folderName(k), "MovementAnchored")
                colorSelected = 'm';
                markerSel = '.';
                sizeNum = 20;
                cntMovInconsistencies = cntMovInconsistencies + 1;
                if cntMovInconsistencies == 1
                    idxsCleTim(4) = k;
                end
            elseif contains(folderName(k), "NotMovement")
                colorSelected = 'r';
                markerSel = '.';
                sizeNum = 20;
                cntNotMovement = cntNotMovement + 1;
                if cntNotMovement == 1
                    idxsCleTim(5) = k;
                end
            elseif contains(folderName(k), "NotConsecutives")
                colorSelected = 'k';
                markerSel = '.';
                sizeNum = 5;
                cntNotConsecutives = cntNotConsecutives + 1;
                if cntNotConsecutives == 1
                    idxsCleTim(6) = k;
                end
            end
            
            size = ones(height(Data{k}), 1) * sizeNum;
            Plots(k) = geoscatter(Data{k}.Latitude, Data{k}.Longitude, size, "Marker", markerSel, "MarkerEdgeColor", colorSelected, "MarkerFaceColor", colorSelected);
            
        end
    end
end

legendPlots = gobjects(7, 1);
legendMsg = [strcat("BaseStations: ",  num2str(cntBaseStations)), ...
    strcat("NullClassValues: ", num2str(cntBothUndefined)), ...
    strcat("Ok: ",       num2str(cntCleaned)), ...
    strcat("ExtremeNoise: ", num2str(cntDimensionsMal)) ];
for i=1:length(idxsCle)
    legendPlots(i) = Plots(idxsCle(i));
end
legend(legendPlots, legendMsg, 'Location', 'southeast');

print(gcf, strcat(ImagesFolder, "NONINON"), '-dpng','-r400'); % Se guarda en fichero