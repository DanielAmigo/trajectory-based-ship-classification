%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Creado por:                  %
% Daniel Amigo Herrero         %
% mailto: damigo@inf.uc3m.es   %
% David Sanchez Pedroche       %
% mailto: davsanch@inf.uc3m.es %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Script que lee un filtered concreto (sin splitted aun) y su timestamped
% correspondiente y genera su información de preclassifier. Con todo eso,
% genera unas imágenes mu chulas

function trajectoryToImageSummary()
 % trajectoryToImageSummary("Day25", "AISConfigurationDenmark_SP999_10");
% configuracion del PRE-clasificador, para obtener el threshold para separar cada modo
threshold.Modo1Maximo = 0.9;
threshold.Modo1Alto = 0.6;
threshold.Modo1Cambio = 0.4;
threshold.Modo1Bajo = 0.1;

%% Variables que definen el fichero a procesar
extension = '.csv';

currentFilePath = mfilename('fullpath');
aux = split(currentFilePath, '\');
currentPath = "";
for i=1:length(aux)-1
    currentPath = strcat(currentPath, aux{i}, "/");
end
currentPath = strcat(currentPath, "Files");

folderFilteredRead    = strcat(currentPath, "/", "Selected");

% Obtenemos todos los ficheros a procesar
allFiles = dir(strcat(folderFilteredRead,'/*.*'));
allFiles([allFiles.isdir]) = [];   %skip directories

% Recorremos todos los ficheros de la carpeta
for k=1:length(allFiles)
    nameFileFilteredRead = allFiles(k,1).name;
    nameFileFilteredCSV = strrep(nameFileFilteredRead, ".csv", ".png");
    
    %% Se generan todos los estadísticos de preclassifier de este fichero
    [variacionVelocidad, velocidad, distancia, variacionDireccion, periodoTiempo, Modo1Alto, Modo1Bajo, Cambio, Modo2Alto, Modo2Bajo, thisMMSI, thisFirstTimeConsecutive, thisFirstTimeManeuver, thisTiempoTotal, thisClassShiptype, thisClassManeuver, thisShipWidth, thisShipLength] = ...
        MSAWextractInfo(folderFilteredRead, nameFileFilteredRead, threshold);
    variacionVelocidad(1,:) = [];
    velocidad(1,:) = [];
    distancia(1,:) = [];
    variacionDireccion(1,:) = [];
    periodoTiempo(1,:) = [];
    
    % Se lee el fichero filtered
    fullFileFilteredRead = strcat(folderFilteredRead,'/',nameFileFilteredRead);                     % Path de lectura
    [DataFiltered] = readWriteFunctions.readFiltered(fullFileFilteredRead); % ya esta dividido en fragmentos equitativos
    
    % Se lee el fichero timestamped
    %nameFileTimestamped = strrep(nameFileFilteredRead, "_filtered", "");
    %fullFileTimestampedRead = strcat(folderTimestampedRead,'/',nameFileTimestamped);                     % Path de lectura
    %[DataTimestamped] = readWriteFunctions.readMmsiTimestampedFile(fullFileTimestampedRead); % ya esta dividido en fragmentos equitativos
    
    close all
    %% Genera la figura de este fichero
    auxFig = figure(k);  % Selecciono la figura
    auxFig.Visible = 'off';
    auxFig.Position(4) = 800;
    auxFig.Position(3) = auxFig.Position(4) * 1.3333;
    scenarioName = strrep(nameFileFilteredRead,'_',' ');
    % sgtitle({scenarioName});
    
    % Se genera el tiempo muestreado a HH:MM
    posixTime = DataFiltered.Time;      %/1000; % 28-Aug-2009 14:50:55 UTC
    posixDays = posixTime/(60*60*24);
    epoch = datenum(1970,1,1,0,0,0);    % Get the serial date number representing the POSIX epoch
    ts = epoch + posixDays;             % Add this value to the serial date number representing the epoch
    ts(1) = [];
    ts(1) = [];
    
    %% trayectoria LAT-LON, se pinta su velocidad y rumbo
    %ax1 = subplot(6,2,[1 2], geoaxes); % Hace una matrix 4x2, y se coge los dos primeros (primera horizontal)
    %geotickformat('-dd'); % Ejes en grados
    %ax1.Basemap = 'colorterrain';
    %hold on;
    %plotXY = geoplot( DataTimestamped.Latitude, DataTimestamped.Longitude, "DisplayName", "Track");
    
    %% Tiempo
    paintThisVariable(periodoTiempo.Total, ts, "Time variation", "southeast", [1 2], false);
    
    %% Velocidad
    paintThisVariable(velocidad.Total, ts, "Speed", "northeast", [3 4], false);
    
    %% Variacion Velocidad
    paintThisVariable(variacionVelocidad.Total, ts, "Speed variation", "northeast", [5 6], false);
    
    %% Distancia    
    paintThisVariable(distancia.Total, ts, "Distance", "northeast", [7 8], false);
    
    %% variacionDireccion
    paintThisVariable(variacionDireccion.Total, ts, "Course variation", "northeast", [9 10], true);
    
    print(gcf, strcat(currentPath, "/", "Hola"), '-dsvg','-r400'); % Se guarda en fichero
end

end


function paintThisVariable(thisVariableValues, timeValues, thisVariableName, legendLocation, posThisSubplot, withHHMM)
    % Se definen variables del comportamiento de la impresión
    FontSizeYLabel = 12;
    FontSizeLegend = 8;
    LineWidthPlot = 1;
    
    % Se extrae la información de los valores
    stdValue  = std(thisVariableValues);
    modeValue = mode(thisVariableValues);
    meanValue = mean(thisVariableValues);
    [minValue, idxMin] = min(thisVariableValues);
    [maxValue, idxMax] = max(thisVariableValues);
    
    sp = subplot(5, 2, posThisSubplot); % Hace una matrix 4x2, y se coge los dos segundos (segunda horizontal)
    hold on;
    plotVarDir = plot( timeValues, thisVariableValues, "DisplayName", thisVariableName);
    plotVarDir.LineWidth = LineWidthPlot;
    datetick('x','HH:MM','keeplimits');
    xlim([timeValues(1) timeValues(end)]); % Fuerza que la primera esté justo a la izq
    if withHHMM == true
        xlabel('HH:MM');
    end
    ylabel(thisVariableName, 'FontSize', FontSizeYLabel);
    
    % uniform splits 50
    for i=50:50:length(thisVariableValues)
        c = xline(timeValues(i), '--', "DisplayName", "Segment split"); % 
    end
    
    % Métricas adicionales
    b = yline(meanValue, "DisplayName", strcat("Mean: ", num2str(meanValue)));
    maxVar = scatter( timeValues(idxMax), thisVariableValues(idxMax), "DisplayName", strcat("Maximum: ", num2str(maxValue)), "MarkerEdgeColor", 'r' );
    minVar = scatter( timeValues(idxMin), thisVariableValues(idxMin), "DisplayName", strcat("Minimum: ", num2str(minValue)), "MarkerEdgeColor", 'r' );
    legend([plotVarDir maxVar minVar b c], 'Location', legendLocation, 'FontSize', FontSizeLegend); % Se pinta la leyenda con los DisplayName
end
