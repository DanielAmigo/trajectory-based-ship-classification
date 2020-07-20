%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desarrollado por | Developed by:                     %
% University Carlos III of Madrid PhD Researchers      %
% Daniel Amigo Herrero    mailto: damigo@inf.uc3m.es   %
% David Sanchez Pedroche  mailto: davsanch@inf.uc3m.es %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Lee el fichero original de datos de Dinamarca linea a linea, y los escribe en un fichero segun su MMSI
%  Read the daily original files from Denmark AIS contacts. Each line its written according to its MMSI
function denmarkRawToMmsi(namefileRead)
folderBase = 'Data/Denmark';
extension = '.csv';
fullFileRead = strcat(folderBase,'/',namefileRead);
fileRead = fopen(fullFileRead);
tline = fgetl(fileRead); % header

%1  Timestamp
%2  Type of mobile
%3  MMSI
%4  Latitude
%5  Longitude
%6  Navigational status
%7  ROT
%8  SOG
%9  COG
%10 Heading
%11 IMO
%12 Callsign
%13 Name
%14 Ship type
%15 Cargo type
%16 Width
%17 Length
%18 Type of position fixing device
%19 Draught
%20 Destination
%21 ETA
%22 Data source type

while ~feof(fileRead) % While there are more lines
    
    % Reading current line
    tline = fgetl(fileRead);
    tline = strrep(tline,',',';'); % Commas to semicolon
    tline = strrep(tline,'.',','); % dots to comma
    C = regexp(tline,';','split'); % Split using semicolon
    
    % Extraccion de caracteristicas
    
    % Timestamp to posixtime
    t = datetime(C(1),'InputFormat','dd/MM/yyyy HH:mm:ss');
    ms = posixtime(t);
    
    % If the line has other format, error prevention, this line not processed
    if any( size(C) > 22 )
        disp('Error prevention');
        continue;
    end
    
    %% Written the processed info
    folder = 'Resultados/MMSI';
    if ~exist(folder, 'dir')
        mkdir(folder)
    end
    extension = '.csv';
    nameFileWrite = strcat(folder,'/',C(3),extension);
    nameFileWrite = nameFileWrite{1};
    
    if ~isfile(nameFileWrite) % Si no existe aun, escribimos la cabecera
        % disp('No existe cabecera, se escribe');
        fileWrite = fopen(nameFileWrite ,'w');
        fprintf(fileWrite,'%s;','PosixSeconds');            %0 PosixSeconds
        fprintf(fileWrite,'%s;','Timestamp');             %1  Timestamp
        fprintf(fileWrite,'%s;','Type of mobile');          %2  Type of mobile
        fprintf(fileWrite,'%s;','MMSI');                    %3  MMSI
        fprintf(fileWrite,'%s;','Latitude');                %4  Latitude
        fprintf(fileWrite,'%s;','Longitude');               %5  Longitude
        fprintf(fileWrite,'%s;','Navigational status');     %6  Navigational status
        fprintf(fileWrite,'%s;','ROT');                     %7  ROT
        fprintf(fileWrite,'%s;','SOG');                     %8  SOG
        fprintf(fileWrite,'%s;','COG');                     %9  COG
        fprintf(fileWrite,'%s;','Heading');                 %10 Heading
        fprintf(fileWrite,'%s;','IMO');                     %11 IMO
        fprintf(fileWrite,'%s;','Callsign');                %12 Callsign
        fprintf(fileWrite,'%s;','Name');                    %13 Name
        fprintf(fileWrite,'%s;','Ship type');               %14 Ship type
        fprintf(fileWrite,'%s;','Cargo type');              %15 Cargo type
        fprintf(fileWrite,'%s;','Width');                   %16 Width
        fprintf(fileWrite,'%s;','Length');                  %17 Length
        fprintf(fileWrite,'%s;','Type of position fixing device'); %18 Type of position fixing device
        fprintf(fileWrite,'%s;','Draught');                 %19 Draught
        fprintf(fileWrite,'%s;','Destination');             %20 Destination
        fprintf(fileWrite,'%s;','ETA');                     %21 ETA
        fprintf(fileWrite,'%s;','Data source type');        %22 Data source type
        fprintf(fileWrite,'\n');
    else
        fileWrite = fopen(nameFileWrite ,'a');  % En modo concatenar
    end
    
    % Se escriben los valores
    fprintf(fileWrite,'%.0f;',ms);
    fprintf(fileWrite,'%s;',C{1});  %1  Timestamp
    fprintf(fileWrite,'%s;',C{2});  %2  Type of mobile
    fprintf(fileWrite,'%s;',C{3});  %3  MMSI
    fprintf(fileWrite,'%s;',C{4});  %4  Latitude
    fprintf(fileWrite,'%s;',C{5});  %5  Longitude
    fprintf(fileWrite,'%s;',C{6});  %6  Navigational status
    fprintf(fileWrite,'%s;',C{7});  %7  ROT
    fprintf(fileWrite,'%s;',C{8});  %8  SOG
    fprintf(fileWrite,'%s;',C{9});  %9  COG
    fprintf(fileWrite,'%s;',C{10}); %10 Heading
    fprintf(fileWrite,'%s;',C{11}); %11 IMO
    fprintf(fileWrite,'%s;',C{12}); %12 Callsign
    fprintf(fileWrite,'%s;',C{13}); %13 Name
    fprintf(fileWrite,'%s;',C{14}); %14 Ship type
    fprintf(fileWrite,'%s;',C{15}); %15 Cargo type
    fprintf(fileWrite,'%s;',C{16}); %16 Width
    fprintf(fileWrite,'%s;',C{17}); %17 Length
    fprintf(fileWrite,'%s;',C{18}); %18 Type of position fixing device
    fprintf(fileWrite,'%s;',C{19}); %19 Draught
    fprintf(fileWrite,'%s;',C{20}); %20 Destination
    fprintf(fileWrite,'%s;',C{21}); %21 ETA
    fprintf(fileWrite,'%s;',C{22}); %22 Data source type
    fprintf(fileWrite,'\n');
    
    fclose(fileWrite);  % Se cierra el fichero de escritura una vez escrito
    
    % break;  % PRUEBA. Para que solo haga una linea
end

fclose(fileRead);

end