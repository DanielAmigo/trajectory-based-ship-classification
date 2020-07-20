%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desarrollado por | Developed by:                     %
% University Carlos III of Madrid PhD Researchers      %
% Daniel Amigo Herrero    mailto: damigo@inf.uc3m.es   %
% David Sanchez Pedroche  mailto: davsanch@inf.uc3m.es %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Cuenta cuantos ficheros, lineas y tipos de barco / maniobra hay en cada carpeta dentro de Data
%  It counts how many files, entries and ship type / maneuver type are on each subfolder within Data
function [] = countAllFolders()

fileWrite = "folderAnalysis.csv";
fid = fopen(fileWrite, 'w');        % w clears the file (if it exists). Open the file.
fprintf(fid, strcat('numFiles', '; ', 'numEntries', '; ', "Cargo",          '; ', "Fishing",    '; ', "Passenger", '; ', "Tanker", '; ', "Undefined",     '; ', "Other", '; ', ...
    "EngagedFishing", '; ', "Restricted", '; ', "Sailing",   '; ', "Engine", '; ', "Unknown value", '; ', "Other", '; ', ...
    'completePath', '; ', 'pathPart1', '; ', 'pathPart2', '; ', 'pathPart3', '; ', 'pathPart4'));
fprintf(fid, "\n");
countAllFoldersRecursive("Data", fileWrite);
end


%% Abre de forma recursiva todas las sub-carpetas. Apunta en fileWrite el nombre de carpeta, numero de ficheros, entradas, y cada tipo de barco y maniobra
%  Open recursively all subfolders. Write at the fileWrite the folder name, number of files, entries and each shiptype and maneuvertype.
function [] = countAllFoldersRecursive(folder, fileWrite)

allFiles = dir(strcat(folder, "/*.*"));
folders = allFiles([allFiles.isdir]); % getting all folders in the folder
folders(1:2) = []; % Deleting . and .. folders


for k=1:length(folders)
    thisPath = strcat(folder, "/", folders(k).name);
    allFiles2 = dir(strcat(thisPath, "/*.*"));
    allFiles2(1:2) = []; % Deleting . and .. folders
    if sum([allFiles2(:).isdir]) > 0 % If it still have folders to analyze, keep on the recursive searching
        %disp("Not a final folder");
        countAllFoldersRecursive(thisPath, fileWrite);
        
    else                            % If its a final folder, all its files are analyzed, writing the results in a single line
        [numFiles, numEntries, numManeuverType, numShipType] = countFolder(thisPath);
        disp("Soy carpeta: "+thisPath);
        fid = fopen(fileWrite, 'a');
        fprintf(fid, strcat(num2str(numFiles), '; ', num2str(numEntries), '; '));
        for i=1:length(numShipType)
            fprintf(fid, strcat(num2str(numShipType(i)), '; '));
        end
        for i=1:length(numManeuverType)
            fprintf(fid, strcat(num2str(numManeuverType(i)), '; '));
        end
        fprintf(fid, strcat(thisPath, '; '));
        a = split(thisPath, '/');
        for i=1:length(a)
            fprintf(fid, strcat(a(i), '; ') );
        end
        fprintf(fid, "\n");
        
        fclose(fid);
    end
end

end