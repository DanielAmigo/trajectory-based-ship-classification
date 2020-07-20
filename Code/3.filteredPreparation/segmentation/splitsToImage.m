%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desarrollado por | Developed by:                     %
% University Carlos III of Madrid PhD Researchers      %
% Daniel Amigo Herrero    mailto: damigo@inf.uc3m.es   %
% David Sanchez Pedroche  mailto: davsanch@inf.uc3m.es %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Crea y guarda una imagen con la trayectoria actual y sus correspondientes segmentos
%  Create and save an image with the current track and its segments.
function [] = splitsToImage(Data, splits, k, nameFileRead, folderImages, alg)
% Create the figure, per parallel
auxFig = figure(k);
auxFig.Visible = 'off'; % To avoid opening a window
ga = geoaxes;
geotickformat('-dd');   % Axes use degrees
ga.Basemap = 'colorterrain';
hold on;

% Setting the figure's title
a = strrep(nameFileRead, "filtered", "");
a = strrep(a, ".csv", "");
b = strcat(a, alg.name);
scenarioName = strrep(b, '_', ' ');
subtitle = strcat("Segmented in ", num2str(length(splits)), " splits");
sgtitle({scenarioName, subtitle});

plotXY = geoplot( Data.Latitude, Data.Longitude, "DisplayName", "Track", "Color", 'k'); % Draws the original track

% Draws each segment 
plotSplits = gobjects(length(splits), 1);
markersSplits = gobjects(length(splits), 1);
for i=1:length(splits)
    nameSplit = strcat("Split", num2str(i));
    plotSplits(i)      = geoplot( splits{i}.Latitude, splits{i}.Longitude, "DisplayName", nameSplit);
    firstAndLast = splits{i}([1 end],:);
    markersSplits(i) = geoscatter( firstAndLast.Latitude, firstAndLast.Longitude, 'HandleVisibility', 'off', 'Marker', 'x', 'MarkerEdgeColor', 'r', 'SizeData', 100);
end

print(gcf, strcat(folderImages, '/', a), '-dpng','-r400');
close all

end