%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desarrollado por | Developed by:                     %
% University Carlos III of Madrid PhD Researchers      %
% Daniel Amigo Herrero    mailto: damigo@inf.uc3m.es   %
% David Sanchez Pedroche  mailto: davsanch@inf.uc3m.es %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Este fichero proporciona la entrada/salida de todos los ficheros procesados en esta investigacion
%  This file provides the input/output of all files processed in this investigation

classdef readWriteFunctions
    methods(Static)
        
        %% Lee un fichero de trazas de un solo MMSI que genera la salida de denmarkRawToMmsi
        %  Reads a single MMSI track file that generates denmarkRawToMmsi
        function [Table] = readMmsiFile(fullFileRead)
            
            % Initial reading to see if it uses a period or comma as a decimal separator
            fileRead = fopen(fullFileRead);  % Se abre el Fichero de configuracion
            
            readedContent = strsplit(fgetl(fileRead), ';'); % Header
            try                                             % try the first line, if do not work, empty file
                readedContent = strsplit(fgetl(fileRead), ';');
            catch
                Table = table;
                return
            end
            
            if contains(readedContent{5}, ".") == true     % Latitude uses point as decimal separator
                decimalSeparator = ".";
            elseif contains(readedContent{5}, ",") == true % Latitude uses comma as decimal separator
                decimalSeparator = ",";
            end
            
            %% Setup the Import Options
            opts = delimitedTextImportOptions("NumVariables", 24);
            
            % Specify range and delimiter
            opts.DataLines = [1, Inf];
            opts.Delimiter = ";";
            
            % Specify column names and types
            opts.VariableNames = ["PosixSeconds", "Timestamp", "Typeofmobile", "MMSI", "Latitude", "Longitude", "Navigationalstatus", "RateOfTurn", "Speed", "Course", "Heading", "IMO", "Callsign", "Name", "Shiptype", "Cargotype", "Width", "Length", "Typeofpositionfixingdevice", "Draught", "Destination", "ETA", "Datasourcetype", "VarName24"];
            opts.VariableTypes = ["double", "string", "string", "string", "double", "double", "string", "double", "double", "double", "double", "string", "string", "string", "string", "string", "double", "double", "string", "double", "string", "string", "string", "string"];
            opts = setvaropts(opts, [2, 3, 4, 7, 12, 13, 14, 15, 16, 19, 21, 22, 23, 24], "WhitespaceRule", "preserve");
            opts = setvaropts(opts, [5, 6, 8, 9, 10, 11, 20], "TrimNonNumeric", true);
            opts = setvaropts(opts, [5, 6, 8, 9, 10, 11, 20], "DecimalSeparator", decimalSeparator); % Decimal separator!!!!
            opts = setvaropts(opts, [2, 3, 4, 7, 12, 13, 14, 15, 16, 19, 21, 22, 23, 24], "EmptyFieldRule", "auto");
            opts.ExtraColumnsRule = "ignore";
            opts.EmptyLineRule = "read";
            
            % Import the data
            Table = readtable(fullFileRead, opts);
            Table(1, :) = [];    % Delete the header row, as it is not content
            
            fclose(fileRead);
        end
        
        %% Escribe la trayectoria AIS de un MMSI de Dinamarca en un fichero
        %  Write the AIS track of a Denmark AIS Dataset in a file
        function [] = writeMmsiTable(nameFileWrite, Table)
            
            % Write the header
            fileWrite = fopen(nameFileWrite ,'w');
            fprintf(fileWrite,'%s;','PosixSeconds');            %0 PosixSeconds
            fprintf(fileWrite,'%s;','Timestamp');               %1  Timestamp
            fprintf(fileWrite,'%s;','Type of mobile');          %2  Type of mobile
            fprintf(fileWrite,'%s;','MMSI');                    %3  MMSI
            fprintf(fileWrite,'%s;','Latitude');                %4  Latitude
            fprintf(fileWrite,'%s;','Longitude');               %5  Longitude
            fprintf(fileWrite,'%s;','Navigational status');     %6  Navigational status
            fprintf(fileWrite,'%s;','RateOfTurn');              %7  ROT
            fprintf(fileWrite,'%s;','Speed');                   %8  SOG
            fprintf(fileWrite,'%s;','Course');                  %9  COG
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
            
            % Write the values
            for k=1:height(Table)
                fprintf(fileWrite,strcat(num2str( Table.PosixSeconds(k) ),'; '));
                fprintf(fileWrite,strcat(Table.Timestamp(k),'; '));
                fprintf(fileWrite,strcat(Table.Typeofmobile(k),'; '));
                fprintf(fileWrite,strcat(num2str( Table.MMSI(k) ),'; '));
                fprintf(fileWrite,strcat(num2str( Table.Latitude(k),'%.8f' ),'; '));
                fprintf(fileWrite,strcat(num2str( Table.Longitude(k),'%.8f' ),'; '));
                fprintf(fileWrite,strcat(Table.Navigationalstatus(k),'; '));
                fprintf(fileWrite,strcat(num2str( Table.RateOfTurn(k) ),'; '));
                fprintf(fileWrite,strcat(num2str( Table.Speed(k) ),'; '));
                fprintf(fileWrite,strcat(num2str( Table.Course(k) ),'; '));
                fprintf(fileWrite,strcat(num2str( Table.Heading(k) ),'; '));
                fprintf(fileWrite,strcat(Table.IMO(k),'; '));
                fprintf(fileWrite,strcat(Table.Callsign(k),'; '));
                fprintf(fileWrite,strcat(Table.Name(k),'; '));
                fprintf(fileWrite,strcat(Table.Shiptype(k) ,'; '));
                fprintf(fileWrite,strcat(Table.Cargotype(k) ,'; '));
                fprintf(fileWrite,strcat(num2str( Table.Width(k) ),'; '));
                fprintf(fileWrite,strcat(num2str( Table.Length(k) ),'; '));
                fprintf(fileWrite,strcat(Table.Typeofpositionfixingdevice(k),'; '));
                fprintf(fileWrite,strcat(num2str( Table.Draught(k)),'; '));
                fprintf(fileWrite,strcat(Table.Destination(k),'; '));
                fprintf(fileWrite,strcat(Table.ETA(k),'; '));
                fprintf(fileWrite,strcat(Table.Datasourcetype(k),'; '));
                fprintf(fileWrite,'\n');
            end
            
            fclose(fileWrite);
        end
        
        %% Lee un fichero de una maniobra AIS de un MMSI, de la salida de processingMmsi2MmsiTimestamp
        % Reads a file from an AIS path in the same MMSI after the cleanup process
        function [Table] = readMmsiTimestampedFile(nameFileRead)
            % Initial reading to see if it uses a period or comma as a decimal separator
            fileRead = fopen(fullFileRead);  % Se abre el Fichero de configuracion
            
            readedContent = strsplit(fgetl(fileRead), ';'); % Header
            try                                             % try the first line, if do not work, empty file
                readedContent = strsplit(fgetl(fileRead), ';');
            catch
                Table = table;
                return
            end
            
            if contains(readedContent{5}, ".") == true     % Latitude uses point as decimal separator
                decimalSeparator = ".";
            elseif contains(readedContent{5}, ",") == true % Latitude uses comma as decimal separator
                decimalSeparator = ",";
            end
            
            opts = delimitedTextImportOptions("NumVariables", 24);
            % Specify range and delimiter
            opts.DataLines = [1, Inf];
            opts.Delimiter = ";";
            % Specify column names and types
            opts.VariableNames = ["PosixSeconds", "Timestamp", "Typeofmobile", "MMSI",   "Latitude", "Longitude", "Navigationalstatus", "RateOfTurn", "Speed",  "Course", "Heading", "IMO",    "Callsign", "Name",   "Shiptype", "Cargotype", "Width",  "Length", "Typeofpositionfixingdevice", "Draught", "Destination", "ETA",    "Datasourcetype", "VarName24"];
            opts.VariableTypes = ["double",       "string",    "string",       "string", "double",   "double",    "string",             "double",     "double", "double", "double",  "string", "string",   "string", "string",   "string",    "double", "double", "string",                     "double",  "string",      "string", "string",         "string"];
            opts = setvaropts(opts, [2, 3, 4, 7, 12, 13, 14, 15, 16, 19, 21, 22, 23, 24], "WhitespaceRule", "preserve");
            opts = setvaropts(opts, [8], "TrimNonNumeric", true);
            opts = setvaropts(opts, [8], "DecimalSeparator", decimalSeparator);
            opts = setvaropts(opts, [2, 3, 4, 7, 12, 13, 14, 15, 16, 19, 21, 22, 23, 24], "EmptyFieldRule", "auto");
            opts.ExtraColumnsRule = "ignore";
            opts.EmptyLineRule = "read";
            % Import the data
            Table = readtable(nameFileRead, opts);
            Table(1,:) = [];
            Table(:,end) = [];
            
            fclose(fileRead);
        end
        
        %% Se escribe en fichero el resultado del filtro IMM sobre la trayectoria AIS de Dinamarca
        %  The result of the IMM filter on a Danish AIS track is written to the file
        function [] = writeFiltered(nameFileWrite, tracksTable, filterConf, varargin)
            if length(varargin) > 0
                posStart = varargin{1};
                posStop = varargin{2};
            else
                posStart = 1;
                posStop = length(tracksTable);
            end
            trackFile = fopen(nameFileWrite ,'w');
            
            %% Header
            fprintf(trackFile,strcat('Time','; '));
            fprintf(trackFile,strcat('Timestamp','; '));
            fprintf(trackFile,strcat('Typeofmobile','; '));
            fprintf(trackFile,strcat('MMSI','; '));
            fprintf(trackFile,strcat('Latitude','; '));
            fprintf(trackFile,strcat('Longitude','; '));
            fprintf(trackFile,strcat('Navigationalstatus','; '));
            fprintf(trackFile,strcat('RateOfTurn','; '));
            fprintf(trackFile,strcat('Speed','; '));
            fprintf(trackFile,strcat('Course','; '));
            fprintf(trackFile,strcat('Heading','; '));
            fprintf(trackFile,strcat('IMO','; '));
            fprintf(trackFile,strcat('Callsign','; '));
            fprintf(trackFile,strcat('Name','; '));
            fprintf(trackFile,strcat('Shiptype','; '));
            fprintf(trackFile,strcat('Cargotype','; '));
            fprintf(trackFile,strcat('Width','; '));
            fprintf(trackFile,strcat('Length','; '));
            fprintf(trackFile,strcat('Typeofpositionfixingdevice','; '));
            fprintf(trackFile,strcat('Draught','; '));
            fprintf(trackFile,strcat('Destination','; '));
            fprintf(trackFile,strcat('ETA','; '));
            fprintf(trackFile,strcat('Datasourcetype','; '));
            
            if filterConf.numDimensions == 2
                varsSV = ["px", "py", "vx", "vy"];
            elseif filterConf.numDimensions == 3
                varsSV = ["px", "py", "pz", "vx", "vy", "vz"];
            end
            for i=1:length(varsSV)
                fprintf(trackFile, strcat('kinematic_', varsSV(i), '; '));
            end
            
            % fprintf(trackFile,'track_quality;');
            for i = 1:filterConf.numModes
                fprintf(trackFile,strcat('mode_probabilities_', num2str(i), '; '));
            end
            
            % Covariance matrix
            if filterConf.numDimensions == 2
                varsCov = ["x", "y", "vx", "vy"];
            elseif filterConf.numDimensions == 3
                varsCov = ["x", "y", "z", "vx", "vy", "vz"];
            end
            for i=1:length(varsCov)
                for j=i:length(varsCov)
                    str = strcat('covariance_imm_', varsCov(i), varsCov(j), '; ');
                    fprintf(trackFile, str);
                end
            end
            
            % Kalman Filters
            for i = 1:filterConf.numModes
                for j = 1:filterConf.numDimensions*2
                    fprintf(trackFile,strcat('state_vector_kf', num2str(i), '_', num2str(j), '; '));
                end
                
                for j=1:length(varsCov)
                    for k=j:length(varsCov)
                        str = strcat('covariances_kf', num2str(i), '_', varsCov(j), varsCov(k), '; ');
                        fprintf(trackFile, str);
                    end
                end
            end
            fprintf(trackFile,'\n');
            
            %% Start writing the selected entries (useful to split in some files)
            for k=posStart:posStop
                fprintf(trackFile,strcat(num2str( tracksTable{k}.plot.PosixSeconds ),'; '));
                fprintf(trackFile,strcat(tracksTable{k}.plot.Timestamp,'; '));
                fprintf(trackFile,strcat(tracksTable{k}.plot.Typeofmobile,'; '));
                fprintf(trackFile,strcat(num2str( tracksTable{k}.plot.MMSI ),'; '));
                fprintf(trackFile,strcat(num2str( tracksTable{k}.plot.Latitude,'%.7f' ),'; '));
                fprintf(trackFile,strcat(num2str( tracksTable{k}.plot.Longitude,'%.7f' ),'; '));
                fprintf(trackFile,strcat(tracksTable{k}.plot.Navigationalstatus,'; '));
                fprintf(trackFile,strcat(num2str( tracksTable{k}.plot.RateOfTurn ),'; '));
                fprintf(trackFile,strcat(num2str( tracksTable{k}.plot.Speed ),'; '));
                fprintf(trackFile,strcat(num2str( tracksTable{k}.plot.Course ),'; '));
                fprintf(trackFile,strcat(num2str( tracksTable{k}.plot.Heading ),'; '));
                fprintf(trackFile,strcat(tracksTable{k}.plot.IMO,'; '));
                fprintf(trackFile,strcat(tracksTable{k}.plot.Callsign,'; '));
                fprintf(trackFile,strcat(tracksTable{k}.plot.Name,'; '));
                fprintf(trackFile,strcat(tracksTable{k}.plot.Shiptype ,'; '));
                fprintf(trackFile,strcat(tracksTable{k}.plot.Cargotype ,'; '));
                fprintf(trackFile,strcat(num2str( tracksTable{k}.plot.Width ),'; '));
                fprintf(trackFile,strcat(num2str( tracksTable{k}.plot.Length ),'; '));
                fprintf(trackFile,strcat(tracksTable{k}.plot.Typeofpositionfixingdevice,'; '));
                fprintf(trackFile,strcat(num2str( tracksTable{k}.plot.Draught),'; '));
                fprintf(trackFile,strcat(tracksTable{k}.plot.Destination,'; '));
                fprintf(trackFile,strcat(tracksTable{k}.plot.ETA,'; '));
                fprintf(trackFile,strcat(tracksTable{k}.plot.Datasourcetype,'; '));
                
                for i=1:length(tracksTable{k}.stateVector)
                    fprintf(trackFile,strcat(num2str(tracksTable{k}.stateVector(i)),'; '));
                end
                
                for i=1:filterConf.numModes
                    fprintf(trackFile,strcat(num2str(tracksTable{k}.modeProbabilities(i)),'; ')); % mode_probabilities_X
                end
                
                % Covariance matrix
                for i=1:length(tracksTable{k}.Pk)
                    for j=i:length(tracksTable{k}.Pk)
                        fprintf(trackFile,strcat(num2str(tracksTable{k}.Pk(i,j)),'; '));
                    end
                end
                
                for i=1:filterConf.numModes
                    for j=1:length(tracksTable{k}.stateVectorKFs{i})
                        fprintf(trackFile,strcat(num2str(tracksTable{k}.stateVectorKFs{i}(j,1)),'; '));
                    end
                    
                    for j=1:length(tracksTable{k}.pkKFs{i})
                        for l=j:length(tracksTable{k}.pkKFs{i})
                            fprintf(trackFile,strcat(num2str(tracksTable{k}.pkKFs{i}(j,l)),'; '));
                        end
                    end
                end
                fprintf(trackFile,'\n');
            end
            fprintf(trackFile,'\n');
            fclose(trackFile);
        end
        
        %% Se lee un fichero el resultado del filtro IMM sobre la trayectoria AIS de Dinamarca
        %  A file is read the result of the IMM filter on the Danish AIS path
        function [Data] = readFiltered(nameFileRead)
            fileRead = fopen(nameFileRead);
            
            readedContent = strsplit(fgetl(fileRead), ';'); % Header
            readedContent = strsplit(fgetl(fileRead), ';'); % First data line
            if contains(readedContent{5}, ".") == true     % Latitude uses point as decimal separator
                decimalSeparator = ".";
            elseif contains(readedContent{5}, ",") == true % Latitude uses comma as decimal separator
                decimalSeparator = ",";
            end
            fclose(fileRead);
            
            
            opts = delimitedTextImportOptions("NumVariables", 68);
            % Specify range and delimiter
            opts.DataLines = [1, Inf];
            opts.Delimiter = ";";
            % Specify column names and types
            opts.VariableNames = ["Time",   "Timestamp", "Typeofmobile", "MMSI",   "Latitude", "Longitude", "Navigationalstatus", "RateOfTurn", "Speed",  "Course", "Heading", "IMO",    "Callsign", "Name",   "Shiptype", "Cargotype", "Width",  "Length", "Typeofpositionfixingdevice", "Draught", "Destination", "ETA",    "Datasourcetype", "kinematic_px", "kinematic_py", "kinematic_vx", "kinematic_vy", "mode_probabilities_1", "mode_probabilities_2", "covariance_imm_xx", "covariance_imm_xy", "covariance_imm_xvx", "covariance_imm_xvy", "covariance_imm_yy", "covariance_imm_yvx", "covariance_imm_yvy", "covariance_imm_vxvx", "covariance_imm_vxvy", "covariance_imm_vyvy", "state_vector_kf1_1", "state_vector_kf1_2", "state_vector_kf1_3", "state_vector_kf1_4", "covariances_kf1_xx", "covariances_kf1_xy", "covariances_kf1_xvx", "covariances_kf1_xvy", "covariances_kf1_yy", "covariances_kf1_yvx", "covariances_kf1_yvy", "covariances_kf1_vxvx", "covariances_kf1_vxvy", "covariances_kf1_vyvy", "state_vector_kf2_1", "state_vector_kf2_2", "state_vector_kf2_3", "state_vector_kf2_4", "covariances_kf2_xx", "covariances_kf2_xy", "covariances_kf2_xvx", "covariances_kf2_xvy", "covariances_kf2_yy", "covariances_kf2_yvx", "covariances_kf2_yvy", "covariances_kf2_vxvx", "covariances_kf2_vxvy", "covariances_kf2_vyvy", "VarName68"];
            opts.VariableTypes = ["double", "string",    "string",       "string", "double",   "double",    "string",             "double",     "double", "double", "double",  "string", "string",   "string", "string",   "string",    "double", "double", "string",                     "double",  "string",      "string", "string",         "double",       "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "string"];
            opts = setvaropts(opts, [2, 3, 4, 7, 12, 13, 14, 15, 16, 19, 21, 22, 23, 68], "WhitespaceRule", "preserve");
            opts = setvaropts(opts, 8, "TrimNonNumeric", true);
            opts = setvaropts(opts, 8, "DecimalSeparator", decimalSeparator);
            opts = setvaropts(opts, [2, 3, 4, 7, 12, 13, 14, 15, 16, 19, 21, 22, 23, 68], "EmptyFieldRule", "auto");
            opts.ExtraColumnsRule = "ignore";
            opts.EmptyLineRule = "read";
            % Import the data
            Data = readtable(nameFileRead, opts);
            Data(1, :) = [];    % Header row is deleted
            Data(end, :) = [];  % Last row is empty, so deleted too
            Data(:, end) = [];  % The same with the last column
        end
        
        %% Se escribe en fichero una trayectoria dividida en varios segmentos
        %  A track segment is written in a file
        function [] = writeSplitted(nameFileWrite, tracksTable)
            filterConf.numModes = 2;
            filterConf.numDimensions = 2;
            
            trackFile = fopen(nameFileWrite ,'w');
            
            %% Write the header
            fprintf(trackFile,strcat('Time','; '));
            fprintf(trackFile,strcat('Timestamp','; '));
            fprintf(trackFile,strcat('Typeofmobile','; '));
            fprintf(trackFile,strcat('MMSI','; '));
            fprintf(trackFile,strcat('Latitude','; '));
            fprintf(trackFile,strcat('Longitude','; '));
            fprintf(trackFile,strcat('Navigationalstatus','; '));
            fprintf(trackFile,strcat('RateOfTurn','; '));
            fprintf(trackFile,strcat('Speed','; '));
            fprintf(trackFile,strcat('Course','; '));
            fprintf(trackFile,strcat('Heading','; '));
            fprintf(trackFile,strcat('IMO','; '));
            fprintf(trackFile,strcat('Callsign','; '));
            fprintf(trackFile,strcat('Name','; '));
            fprintf(trackFile,strcat('Shiptype','; '));
            fprintf(trackFile,strcat('Cargotype','; '));
            fprintf(trackFile,strcat('Width','; '));
            fprintf(trackFile,strcat('Length','; '));
            fprintf(trackFile,strcat('Typeofpositionfixingdevice','; '));
            fprintf(trackFile,strcat('Draught','; '));
            fprintf(trackFile,strcat('Destination','; '));
            fprintf(trackFile,strcat('ETA','; '));
            fprintf(trackFile,strcat('Datasourcetype','; '));
            
            if filterConf.numDimensions == 2
                varsSV = ["px", "py", "vx", "vy"];
            elseif filterConf.numDimensions == 3
                varsSV = ["px", "py", "pz", "vx", "vy", "vz"];
            end
            for i=1:length(varsSV)
                fprintf(trackFile, strcat('kinematic_', varsSV(i), '; '));
            end
            
            % fprintf(trackFile,'track_quality;');
            for i = 1:filterConf.numModes
                fprintf(trackFile,strcat('mode_probabilities_', num2str(i), '; '));
            end
            
            % Covariance matrix
            if filterConf.numDimensions == 2
                varsCov = ["x", "y", "vx", "vy"];
            elseif filterConf.numDimensions == 3
                varsCov = ["x", "y", "z", "vx", "vy", "vz"];
            end
            for i=1:length(varsCov)
                for j=i:length(varsCov)
                    str = strcat('covariance_imm_', varsCov(i), varsCov(j), '; ');
                    fprintf(trackFile, str);
                end
            end
            
            % Kalman Filters
            for i = 1:filterConf.numModes
                for j = 1:filterConf.numDimensions*2
                    fprintf(trackFile,strcat('state_vector_kf', num2str(i), '_', num2str(j), '; '));
                end
                
                for j=1:length(varsCov)
                    for k=j:length(varsCov)
                        str = strcat('covariances_kf', num2str(i), '_', varsCov(j), varsCov(k), '; ');
                        fprintf(trackFile, str);
                    end
                end
            end
            fprintf(trackFile,'\n');
            % End of the header
            
            % Start the content
            for k=1:height(tracksTable)
                fprintf(trackFile,strcat(num2str( tracksTable.Time(k) ),'; '));
                fprintf(trackFile,strcat(tracksTable.Timestamp(k),'; '));
                fprintf(trackFile,strcat(tracksTable.Typeofmobile(k) ,'; '));
                fprintf(trackFile,strcat(tracksTable.MMSI(k),'; '));
                fprintf(trackFile,strcat(num2str( tracksTable.Latitude(k) ,'%.7f' ),'; '));
                fprintf(trackFile,strcat(num2str( tracksTable.Longitude(k),'%.7f' ),'; '));
                fprintf(trackFile,strcat(tracksTable.Navigationalstatus(k),'; '));
                fprintf(trackFile,strcat(num2str( tracksTable.RateOfTurn(k)),'; '));
                fprintf(trackFile,strcat(num2str( tracksTable.Speed(k) ),'; '));
                fprintf(trackFile,strcat(num2str( tracksTable.Course(k) ),'; '));
                fprintf(trackFile,strcat(num2str( tracksTable.Heading(k) ),'; '));
                fprintf(trackFile,strcat(tracksTable.IMO(k),'; '));
                fprintf(trackFile,strcat(tracksTable.Callsign(k),'; '));
                fprintf(trackFile,strcat(tracksTable.Name(k),'; '));
                fprintf(trackFile,strcat(tracksTable.Shiptype(k),'; '));
                fprintf(trackFile,strcat(tracksTable.Cargotype(k) ,'; '));
                fprintf(trackFile,strcat(num2str( tracksTable.Width(k) ),'; '));
                fprintf(trackFile,strcat(num2str( tracksTable.Length(k) ),'; '));
                fprintf(trackFile,strcat(tracksTable.Typeofpositionfixingdevice(k),'; '));
                fprintf(trackFile,strcat(num2str(tracksTable.Draught(k)),'; '));
                fprintf(trackFile,strcat(tracksTable.Destination(k),'; '));
                fprintf(trackFile,strcat(tracksTable.ETA(k),'; '));
                fprintf(trackFile,strcat(tracksTable.Datasourcetype(k),'; '));
                
                if filterConf.numDimensions == 2
                    varsSV = ["px", "py", "vx", "vy"];
                elseif filterConf.numDimensions == 3
                    varsSV = ["px", "py", "pz", "vx", "vy", "vz"];
                end
                for i=1:length(varsSV)
                    auxVar = strcat('kinematic_', varsSV(i));
                    fprintf(trackFile, strcat(num2str( tracksTable.(auxVar)(k), '%.7f' ), '; '));
                end
                
                % fprintf(trackFile,'track_quality;');
                for i = 1:filterConf.numModes
                    auxVar = strcat('mode_probabilities_', num2str(i));
                    fprintf(trackFile, strcat(num2str( tracksTable.(auxVar)(k), '%.7f' ), '; '));
                end
                
                if filterConf.numDimensions == 2
                    varsCov = ["x", "y", "vx", "vy"];
                elseif filterConf.numDimensions == 3
                    varsCov = ["x", "y", "z", "vx", "vy", "vz"];
                end
                for i=1:length(varsCov)
                    for j=i:length(varsCov)
                        auxVar = strcat('covariance_imm_', varsCov(i), varsCov(j));
                        fprintf(trackFile, strcat(num2str( tracksTable.(auxVar)(k), '%.7f' ), '; '));
                    end
                end
                
                % Kalman Filters
                for i = 1:filterConf.numModes
                    for j = 1:filterConf.numDimensions*2
                        auxVar = strcat('state_vector_kf', num2str(i), '_', num2str(j));
                        fprintf(trackFile, strcat(num2str( tracksTable.(auxVar)(k), '%.7f' ), '; '));
                    end
                    
                    for j=1:length(varsCov)
                        for l=j:length(varsCov)
                            auxVar = strcat('covariances_kf', num2str(i), '_', varsCov(j), varsCov(l));
                            fprintf(trackFile, strcat(num2str( tracksTable.(auxVar)(k), '%.7f' ), '; '));
                        end
                    end
                end
                fprintf(trackFile,'\n');
            end
            fprintf(trackFile,'\n');
            fclose(trackFile);
        end
        
        %% Se escribe la cabecera del fichero de features extraidas
        %  The header of the extracted features file is written
        function [] = writeExtractedFeaturesHeader(nameFileWrite)
            trackFile = fopen(nameFileWrite ,'w');
            
            fprintf(trackFile,strcat('FirstTimeConsecutive','; '));
            fprintf(trackFile,strcat('FirstTimeManeuver','; '));
            fprintf(trackFile,strcat('MMSI','; '));
            fprintf(trackFile,strcat('TotalTime','; '));
            fprintf(trackFile,strcat('ClassShiptype','; '));
            fprintf(trackFile,strcat('ClassManeuver','; '));
            fprintf(trackFile,strcat('shipWidth','; '));
            fprintf(trackFile,strcat('shipLength','; '));
            
            modos = {'Total','HighMode1','LowMode1','SwitchingMode','LowMode2','HighMode2'};
            
            types = {'sum', 'max', 'min', 'mean', 'std', 'mode', 'q1', 'q2', 'q3'};
            
            variables = {'speedVariation', 'speed', 'distance', 'directionVariation', 'timeGap'};
            
            for i=1:1:length(types)
                for j=1:1:length(modos)
                    for k=1:1:length(variables)
                        fprintf(trackFile,strcat(string(variables(k)),'_', string(modos(j)),'_',string(types(i)),'; '));
                    end
                end
            end
            
            % Modes
            typesMode = {'out', 'sumWithoutMyself', 'sumWithMyself'};
            fprintf(trackFile,strcat('continueSameMode','; '));
            
            for j=1:1:length(typesMode)
                for k=2:1:length(modos) % Start in 2, there is not Total
                    fprintf(trackFile,strcat(string(modos(k)),'_',string(typesMode(j)),'; '));
                end
            end
            
            for j=2:1:length(modos)
                for k=2:1:length(modos) % Start in 2, there is not Total
                    fprintf(trackFile,strcat('to_',string(modos(j)),'_from_', string(modos(k)),'; '));
                end
            end
            
            fprintf(trackFile,'\n');
            fclose(trackFile);
        end
        
        %% Se escriben las features extraidas sobre la trayectoria filtrada con el IMM
        %  The extracted features are written over the filtered track with the IMM
        function [] = writeExtractedFeatures(ClassificationData, nameFileWrite)
            trackFile = fopen(nameFileWrite ,'a');
            for k=1:length(ClassificationData.MMSI)
                fprintf(trackFile,strcat(string(ClassificationData.FirstTimeConsecutive(k)),'; '));
                fprintf(trackFile,strcat(string(ClassificationData.FirstTimeManeuver(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.MMSI(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.TotalTime(k)),'; '));
                fprintf(trackFile,strcat(ClassificationData.ClassShipType(k),'; '));
                fprintf(trackFile,strcat(string(ClassificationData.ClassManeuver(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.shipWidth(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.shipLength(k)),'; '));
                
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationTotalSum(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedTotalSum(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceTotalSum(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationTotalSum(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapTotalSum(k)),'; '));
                
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationHighMode1Sum(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedHighMode1Sum(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceHighMode1Sum(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationHighMode1Sum(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapHighMode1Sum(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationLowMode1Sum(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedLowMode1Sum(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceLowMode1Sum(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationLowMode1Sum(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapLowMode1Sum(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationSwitchingModeSum(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedSwitchingModeSum(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceSwitchingModeSum(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationSwitchingModeSum(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapSwitchingModeSum(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationLowMode2Sum(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedLowMode2Sum(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceLowMode2Sum(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationLowMode2Sum(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapLowMode2Sum(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationHighMode2Sum(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedHighMode2Sum(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceHighMode2Sum(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationHighMode2Sum(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapHighMode2Sum(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationTotalMax(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedTotalMax(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceTotalMax(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationTotalMax(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapTotalMax(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationHighMode1Max(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedHighMode1Max(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceHighMode1Max(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationHighMode1Max(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapHighMode1Max(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationLowMode1Max(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedLowMode1Max(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceLowMode1Max(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationLowMode1Max(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapLowMode1Max(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationSwitchingModeMax(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedSwitchingModeMax(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceSwitchingModeMax(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationSwitchingModeMax(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapSwitchingModeMax(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationLowMode2Max(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedLowMode2Max(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceLowMode2Max(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationLowMode2Max(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapLowMode2Max(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationHighMode2Max(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedHighMode2Max(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceHighMode2Max(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationHighMode2Max(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapHighMode2Max(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationTotalMin(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedTotalMin(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceTotalMin(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationTotalMin(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapTotalMin(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationHighMode1Min(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedHighMode1Min(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceHighMode1Min(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationHighMode1Min(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapHighMode1Min(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationLowMode1Min(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedLowMode1Min(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceLowMode1Min(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationLowMode1Min(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapLowMode1Min(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationSwitchingModeMin(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedSwitchingModeMin(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceSwitchingModeMin(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationSwitchingModeMin(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapSwitchingModeMin(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationLowMode2Min(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedLowMode2Min(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceLowMode2Min(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationLowMode2Min(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapLowMode2Min(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationHighMode2Min(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedHighMode2Min(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceHighMode2Min(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationHighMode2Min(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapHighMode2Min(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationTotalMean(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedTotalMean(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceTotalMean(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationTotalMean(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapTotalMean(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationHighMode1Mean(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedHighMode1Mean(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceHighMode1Mean(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationHighMode1Mean(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapHighMode1Mean(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationLowMode1Mean(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedLowMode1Mean(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceLowMode1Mean(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationLowMode1Mean(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapLowMode1Mean(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationSwitchingModeMean(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedSwitchingModeMean(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceSwitchingModeMean(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationSwitchingModeMean(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapSwitchingModeMean(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationLowMode2Mean(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedLowMode2Mean(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceLowMode2Mean(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationLowMode2Mean(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapLowMode2Mean(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationHighMode2Mean(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedHighMode2Mean(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceHighMode2Mean(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationHighMode2Mean(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapHighMode2Mean(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationTotalStd(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedTotalStd(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceTotalStd(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationTotalStd(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapTotalStd(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationHighMode1Std(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedHighMode1Std(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceHighMode1Std(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationHighMode1Std(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapHighMode1Std(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationLowMode1Std(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedLowMode1Std(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceLowMode1Std(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationLowMode1Std(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapLowMode1Std(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationSwitchingModeStd(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedSwitchingModeStd(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceSwitchingModeStd(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationSwitchingModeStd(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapSwitchingModeStd(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationLowMode2Std(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedLowMode2Std(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceLowMode2Std(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationLowMode2Std(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapLowMode2Std(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationHighMode2Std(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedHighMode2Std(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceHighMode2Std(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationHighMode2Std(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapHighMode2Std(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationTotalMode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedTotalMode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceTotalMode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationTotalMode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapTotalMode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationHighMode1Mode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedHighMode1Mode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceHighMode1Mode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationHighMode1Mode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapHighMode1Mode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationLowMode1Mode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedLowMode1Mode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceLowMode1Mode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationLowMode1Mode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapLowMode1Mode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationSwitchingModeMode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedSwitchingModeMode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceSwitchingModeMode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationSwitchingModeMode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapSwitchingModeMode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationLowMode2Mode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedLowMode2Mode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceLowMode2Mode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationLowMode2Mode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapLowMode2Mode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationHighMode2Mode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedHighMode2Mode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceHighMode2Mode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationHighMode2Mode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapHighMode2Mode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationTotalQ1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedTotalQ1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceTotalQ1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationTotalQ1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapTotalQ1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationHighMode1Q1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedHighMode1Q1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceHighMode1Q1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationHighMode1Q1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapHighMode1Q1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationLowMode1Q1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedLowMode1Q1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceLowMode1Q1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationLowMode1Q1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapLowMode1Q1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationSwitchingModeQ1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedSwitchingModeQ1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceSwitchingModeQ1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationSwitchingModeQ1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapSwitchingModeQ1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationLowMode2Q1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedLowMode2Q1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceLowMode2Q1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationLowMode2Q1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapLowMode2Q1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationHighMode2Q1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedHighMode2Q1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceHighMode2Q1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationHighMode2Q1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapHighMode2Q1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationTotalQ2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedTotalQ2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceTotalQ2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationTotalQ2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapTotalQ2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationHighMode1Q2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedHighMode1Q2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceHighMode1Q2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationHighMode1Q2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapHighMode1Q2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationLowMode1Q2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedLowMode1Q2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceLowMode1Q2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationLowMode1Q2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapLowMode1Q2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationSwitchingModeQ2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedSwitchingModeQ2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceSwitchingModeQ2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationSwitchingModeQ2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapSwitchingModeQ2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationLowMode2Q2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedLowMode2Q2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceLowMode2Q2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationLowMode2Q2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapLowMode2Q2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationHighMode2Q2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedHighMode2Q2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceHighMode2Q2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationHighMode2Q2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapHighMode2Q2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationTotalQ3(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedTotalQ3(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceTotalQ3(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationTotalQ3(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapTotalQ3(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationHighMode1Q3(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedHighMode1Q3(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceHighMode1Q3(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationHighMode1Q3(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapHighMode1Q3(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationLowMode1Q3(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedLowMode1Q3(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceLowMode1Q3(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationLowMode1Q3(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapLowMode1Q3(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationSwitchingModeQ3(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedSwitchingModeQ3(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceSwitchingModeQ3(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationSwitchingModeQ3(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapSwitchingModeQ3(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationLowMode2Q3(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedLowMode2Q3(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceLowMode2Q3(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationLowMode2Q3(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapLowMode2Q3(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedVariationHighMode2Q3(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.speedHighMode2Q3(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.distanceHighMode2Q3(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.directionVariationHighMode2Q3(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.timeGapHighMode2Q3(k)),'; '));
                
                fprintf(trackFile,strcat(num2str(ClassificationData.continueSameMode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.HighMode1Out(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.LowMode1Out(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.SwitchingModeOut(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.LowMode2Out(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.HighMode2Out(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.HighMode1In(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.LowMode1In(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.SwitchingModeIn(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.LowMode2In(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.HighMode2In(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.HighMode1InPlusContinue(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.LowMode1InPlusContinue(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.SwitchingModeInPlusContinue(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.LowMode2InPlusContinue(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.HighMode2InPlusContinue(k)),'; '));
                
                fprintf(trackFile,strcat(num2str(ClassificationData.HighMode1AHighMode1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.HighMode1ALowMode1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.HighMode1ASwitchingMode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.HighMode1AHighMode2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.HighMode1ALowMode2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.LowMode1AHighMode1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.LowMode1ALowMode1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.LowMode1ASwitchingMode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.LowMode1AHighMode2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.LowMode1ALowMode2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.SwitchingModeAHighMode1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.SwitchingModeALowMode1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.SwitchingModeASwitchingMode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.SwitchingModeAHighMode2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.SwitchingModeALowMode2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.HighMode2AHighMode1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.HighMode2ALowMode1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.HighMode2ASwitchingMode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.HighMode2AHighMode2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.HighMode2ALowMode2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.LowMode2AHighMode1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.LowMode2ALowMode1(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.LowMode2ASwitchingMode(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.LowMode2AHighMode2(k)),'; '));
                fprintf(trackFile,strcat(num2str(ClassificationData.LowMode2ALowMode2(k)),'; '));
                
                fprintf(trackFile,'\n');
            end
            
            fclose(trackFile);
        end
        
        %% Se leen las features extraidas para realizar la clasificacion
        %  The extracted features are readed to perform the classification
        function [DataTable, ClassesTable] = readExtractedFeatures(nameFileRead)
            
            % Initial reading to see if it uses a period or comma as a decimal separator
            fileRead = fopen(nameFileRead);  % Se abre el Fichero de configuracion
            readedContent = strsplit(fgetl(fileRead), ';'); % Header
            readedContent = strsplit(fgetl(fileRead), ';'); % First data line
            
            if contains(readedContent{8}, ".") == true     % speedVariation_TotalSum uses point as decimal separator
                decimalSeparator = ".";
            elseif contains(readedContent{8}, ",") == true % speedVariation_TotalSum uses comma as decimal separator
                decimalSeparator = ",";
            end
            fclose(fileRead);
            
            opts = delimitedTextImportOptions("NumVariables", 320);
            % "DecimalSeparator", decimalSeparator
            
            % Specify range and delimiter
            opts.DataLines = [1, Inf];
            opts.Delimiter = ";";
            
            % Specify column names and types
            opts.VariableNames = ["FirstTimeConsecutive", "FirstTimeManeuver", "MMSI", "TotalTime", "ClassShiptype", "ClassManeuver", "shipWidth", "shipLength", "speedVariation_TotalSum", "speed_TotalSum", "distance_TotalSum", "directionVariation_TotalSum", "timeGap_TotalSum", "speedVariationHighMode1Sum", "speedHighMode1Sum", "distanceHighMode1Sum", "directionVariationHighMode1Sum", "timeGapHighMode1Sum", "speedVariationLowMode1Sum", "speedLowMode1Sum", "distanceLowMode1Sum", "directionVariationLowMode1Sum", "timeGapLowMode1Sum", "speedVariationSwitchingModeSum", "speedSwitchingModeSum", "distanceSwitchingModeSum", "directionVariationSwitchingModeSum", "timeGapSwitchingModeSum", "speedVariationLowMode2Sum", "speedLowMode2Sum", "distanceLowMode2Sum", "directionVariationLowMode2Sum", "timeGapLowMode2Sum", "speedVariationHighMode2Sum", "speedHighMode2Sum", "distanceHighMode2Sum", "directionVariationHighMode2Sum", "timeGapHighMode2Sum", "speedVariation_TotalMax", "speed_TotalMax", "distance_TotalMax", "directionVariation_TotalMax", "timeGap_TotalMax", "speedVariationHighMode1Max", "speedHighMode1Max", "distanceHighMode1Max", "directionVariationHighMode1Max", "timeGapHighMode1Max", "speedVariationLowMode1Max", "speedLowMode1Max", "distanceLowMode1Max", "directionVariationLowMode1Max", "timeGapLowMode1Max", "speedVariationSwitchingModeMax", "speedSwitchingModeMax", "distanceSwitchingModeMax", "directionVariationSwitchingModeMax", "timeGapSwitchingModeMax", "speedVariationLowMode2Max", "speedLowMode2Max", "distanceLowMode2Max", "directionVariationLowMode2Max", "timeGapLowMode2Max", "speedVariationHighMode2Max", "speedHighMode2Max", "distanceHighMode2Max", "directionVariationHighMode2Max", "timeGapHighMode2Max", "speedVariation_TotalMin", "speed_TotalMin", "distance_TotalMin", "directionVariation_TotalMin", "timeGap_TotalMin", "speedVariationHighMode1Min", "speedHighMode1Min", "distanceHighMode1Min", "directionVariationHighMode1Min", "timeGapHighMode1Min", "speedVariationLowMode1Min", "speedLowMode1Min", "distanceLowMode1Min", "directionVariationLowMode1Min", "timeGapLowMode1Min", "speedVariationSwitchingModeMin", "speedSwitchingModeMin", "distanceSwitchingModeMin", "directionVariationSwitchingModeMin", "timeGapSwitchingModeMin", "speedVariationLowMode2Min", "speedLowMode2Min", "distanceLowMode2Min", "directionVariationLowMode2Min", "timeGapLowMode2Min", "speedVariationHighMode2Min", "speedHighMode2Min", "distanceHighMode2Min", "directionVariationHighMode2Min", "timeGapHighMode2Min", "speedVariation_TotalMean", "speed_TotalMean", "distance_TotalMean", "directionVariation_TotalMean", "timeGap_TotalMean", "speedVariationHighMode1Mean", "speedHighMode1Mean", "distanceHighMode1Mean", "directionVariationHighMode1Mean", "timeGapHighMode1Mean", "speedVariationLowMode1Mean", "speedLowMode1Mean", "distanceLowMode1Mean", "directionVariationLowMode1Mean", "timeGapLowMode1Mean", "speedVariationSwitchingModeMean", "speedSwitchingModeMean", "distanceSwitchingModeMean", "directionVariationSwitchingModeMean", "timeGapSwitchingModeMean", "speedVariationLowMode2Mean", "speedLowMode2Mean", "distanceLowMode2Mean", "directionVariationLowMode2Mean", "timeGapLowMode2Mean", "speedVariationHighMode2Mean", "speedHighMode2Mean", "distanceHighMode2Mean", "directionVariationHighMode2Mean", "timeGapHighMode2Mean", "speedVariation_TotalStd", "speed_TotalStd", "distance_TotalStd", "directionVariation_TotalStd", "timeGap_TotalStd", "speedVariationHighMode1Std", "speedHighMode1Std", "distanceHighMode1Std", "directionVariationHighMode1Std", "timeGapHighMode1Std", "speedVariationLowMode1Std", "speedLowMode1Std", "distanceLowMode1Std", "directionVariationLowMode1Std", "timeGapLowMode1Std", "speedVariationSwitchingModeStd", "speedSwitchingModeStd", "distanceSwitchingModeStd", "directionVariationSwitchingModeStd", "timeGapSwitchingModeStd", "speedVariationLowMode2Std", "speedLowMode2Std", "distanceLowMode2Std", "directionVariationLowMode2Std", "timeGapLowMode2Std", "speedVariationHighMode2Std", "speedHighMode2Std", "distanceHighMode2Std", "directionVariationHighMode2Std", "timeGapHighMode2Std", "speedVariation_TotalMode", "speed_TotalMode", "distance_TotalMode", "directionVariation_TotalMode", "timeGap_TotalMode", "speedVariationHighMode1Mode", "speedHighMode1Mode", "distanceHighMode1Mode", "directionVariationHighMode1Mode", "timeGapHighMode1Mode", "speedVariationLowMode1Mode", "speedLowMode1Mode", "distanceLowMode1Mode", "directionVariationLowMode1Mode", "timeGapLowMode1Mode", "speedVariationSwitchingModeMode", "speedSwitchingModeMode", "distanceSwitchingModeMode", "directionVariationSwitchingModeMode", "timeGapSwitchingModeMode", "speedVariationLowMode2Mode", "speedLowMode2Mode", "distanceLowMode2Mode", "directionVariationLowMode2Mode", "timeGapLowMode2Mode", "speedVariationHighMode2Mode", "speedHighMode2Mode", "distanceHighMode2Mode", "directionVariationHighMode2Mode", "timeGapHighMode2Mode", "speedVariation_TotalQ1", "speed_TotalQ1", "distance_TotalQ1", "directionVariation_TotalQ1", "timeGap_TotalQ1", "speedVariationHighMode1Q1", "speedHighMode1Q1", "distanceHighMode1Q1", "directionVariationHighMode1Q1", "timeGapHighMode1Q1", "speedVariationLowMode1Q1", "speedLowMode1Q1", "distanceLowMode1Q1", "directionVariationLowMode1Q1", "timeGapLowMode1Q1", "speedVariationSwitchingModeQ1", "speedSwitchingModeQ1", "distanceSwitchingModeQ1", "directionVariationSwitchingModeQ1", "timeGapSwitchingModeQ1", "speedVariationLowMode2Q1", "speedLowMode2Q1", "distanceLowMode2Q1", "directionVariationLowMode2Q1", "timeGapLowMode2Q1", "speedVariationHighMode2Q1", "speedHighMode2Q1", "distanceHighMode2Q1", "directionVariationHighMode2Q1", "timeGapHighMode2Q1", "speedVariation_TotalQ2", "speed_TotalQ2", "distance_TotalQ2", "directionVariation_TotalQ2", "timeGap_TotalQ2", "speedVariationHighMode1Q2", "speedHighMode1Q2", "distanceHighMode1Q2", "directionVariationHighMode1Q2", "timeGapHighMode1Q2", "speedVariationLowMode1Q2", "speedLowMode1Q2", "distanceLowMode1Q2", "directionVariationLowMode1Q2", "timeGapLowMode1Q2", "speedVariationSwitchingModeQ2", "speedSwitchingModeQ2", "distanceSwitchingModeQ2", "directionVariationSwitchingModeQ2", "timeGapSwitchingModeQ2", "speedVariationLowMode2Q2", "speedLowMode2Q2", "distanceLowMode2Q2", "directionVariationLowMode2Q2", "timeGapLowMode2Q2", "speedVariationHighMode2Q2", "speedHighMode2Q2", "distanceHighMode2Q2", "directionVariationHighMode2Q2", "timeGapHighMode2Q2", "speedVariation_TotalQ3", "speed_TotalQ3", "distance_TotalQ3", "directionVariation_TotalQ3", "timeGap_TotalQ3", "speedVariationHighMode1Q3", "speedHighMode1Q3", "distanceHighMode1Q3", "directionVariationHighMode1Q3", "timeGapHighMode1Q3", "speedVariationLowMode1Q3", "speedLowMode1Q3", "distanceLowMode1Q3", "directionVariationLowMode1Q3", "timeGapLowMode1Q3", "speedVariationSwitchingModeQ3", "speedSwitchingModeQ3", "distanceSwitchingModeQ3", "directionVariationSwitchingModeQ3", "timeGapSwitchingModeQ3", "speedVariationLowMode2Q3", "speedLowMode2Q3", "distanceLowMode2Q3", "directionVariationLowMode2Q3", "timeGapLowMode2Q3", "speedVariationHighMode2Q3", "speedHighMode2Q3", "distanceHighMode2Q3", "directionVariationHighMode2Q3", "timeGapHighMode2Q3", "continueSameMode", "HighMode1_out", "LowMode1_out", "SwitchingMode_out", "LowMode2_out", "HighMode2_out", "HighMode1SumWithoutMyself", "LowMode1SumWithoutMyself", "SwitchingModeSumWithoutMyself", "LowMode2SumWithoutMyself", "HighMode2SumWithoutMyself", "HighMode1SumWithMyself", "LowMode1SumWithMyself", "SwitchingModeSumWithMyself", "LowMode2SumWithMyself", "HighMode2SumWithMyself", "toHighMode1_fromHighMode1", "toHighMode1_fromLowMode1", "toHighMode1_fromSwitchingMode", "toHighMode1_fromLowMode2", "toHighMode1_fromHighMode2", "toLowMode1_fromHighMode1", "toLowMode1_fromLowMode1", "toLowMode1_fromSwitchingMode", "toLowMode1_fromLowMode2", "toLowMode1_fromHighMode2", "toSwitchingMode_fromHighMode1", "toSwitchingMode_fromLowMode1", "toSwitchingMode_fromSwitchingMode", "toSwitchingMode_fromLowMode2", "toSwitchingMode_fromHighMode2", "toLowMode2_fromHighMode1", "toLowMode2_fromLowMode1", "toLowMode2_fromSwitchingMode", "toLowMode2_fromLowMode2", "toLowMode2_fromHighMode2", "toHighMode2_fromHighMode1", "toHighMode2_fromLowMode1", "toHighMode2_fromSwitchingMode", "toHighMode2_fromLowMode2", "toHighMode2_fromHighMode2", "VarName320"];
            opts.VariableTypes = ["double", "double", "double", "double", "string", "string", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "string"];
            opts = setvaropts(opts, [5, 6, 320], "WhitespaceRule", "preserve");
            opts = setvaropts(opts, [5, 6, 320], "EmptyFieldRule", "auto");
            
            opts.ExtraColumnsRule = "ignore";
            opts.EmptyLineRule = "read";
            
            % Import the data
            DataTable = readtable(nameFileRead, opts);
            DataTable(1,:) = [];    % Delete the headers
            DataTable(:,end) = [];  % Empty last row
            ClassesTable = DataTable(:,5:6);
            DataTable(:,5:6) = [];  % Delete both classes as them are on ClassesTable
        end
        
        %% Se escriben los resultados de la clasificacion en fichero
        %  The results of the classification are written to a file
        function [] = writeClassificationResults(pathFileWrite, labels, confusionMatrix, DataMatrix, tipoSP, tipoSigma, predictClass, deleteVarsType, classifierType, balanceType, normalizeType, trainTestType, importanceVars, doVector, accuracy)
            
            if isfile(pathFileWrite)   % If it does not exist, is created
                delete(pathFileWrite);
            end
            trackFile = fopen(pathFileWrite, 'w');
            
            fprintf(trackFile,strcat('numEntries','; '));
            fprintf(trackFile,strcat('numVariables','; '));
            fprintf(trackFile,strcat('SwitchProbabilities','; '));
            fprintf(trackFile,strcat('Sigma','; '));
            fprintf(trackFile,strcat('predictClass','; '));
            fprintf(trackFile,strcat('deleteVarsType','; '));
            fprintf(trackFile,strcat('classifierType','; '));
            fprintf(trackFile,strcat('balanceType','; '));
            fprintf(trackFile,strcat('normalizeType','; '));
            fprintf(trackFile,strcat('trainTestType','; '));
            fprintf(trackFile,strcat('importanceVars','; '));
            fprintf(trackFile,strcat('doVector','; '));
            fprintf(trackFile,strcat('accuracy','; '));
            
            for i=1:length(labels)
                for j=1:length(labels)
                    if isnumeric(labels(i)) || islogical(labels(i)) % in binary problems
                        fprintf(trackFile,strcat('real_',num2str(labels(i)),"_predicha_",num2str(labels(j)),'; '));
                    else                    % in multiclass
                        fprintf(trackFile,strcat('real_',labels(i),"_predicha_",labels(j),'; '));
                    end
                end
            end
            fprintf(trackFile,'\n');
            
            [m,n] = size(DataMatrix);
            fprintf(trackFile,strcat(num2str(m),'; '));
            fprintf(trackFile,strcat(num2str(n),'; '));
            fprintf(trackFile,strcat(tipoSP,'; '));
            fprintf(trackFile,strcat(num2str(tipoSigma),'; '));
            fprintf(trackFile,strcat(num2str(predictClass),'; '));
            fprintf(trackFile,strcat(num2str(deleteVarsType),'; '));
            fprintf(trackFile,strcat(num2str(classifierType),'; '));
            fprintf(trackFile,strcat(num2str(balanceType),'; '));
            fprintf(trackFile,strcat(num2str(normalizeType),'; '));
            fprintf(trackFile,strcat(num2str(trainTestType),'; '));
            fprintf(trackFile,strcat(num2str(importanceVars),'; '));
            fprintf(trackFile,strcat(num2str(doVector),'; '));
            fprintf(trackFile,strcat(num2str(accuracy),'; '));
            
            [m,n] = size(confusionMatrix);
            for i=1:m
                for j=1:n
                    fprintf(trackFile,strcat(num2str(confusionMatrix(i,j)),'; '));
                end
            end
            fclose(trackFile);
        end
        
        %% Se leen los resultados de la clasificacion en fichero
        %  The results of the classification are readed from a file
        function [Table] = readClassificationResults(nameFileRead)
            % Setup the Import Options and import the data
            opts = delimitedTextImportOptions("NumVariables", 18);
            % Specify range and delimiter
            opts.DataLines = [2, Inf];
            opts.Delimiter = ";";
            % Specify column names and types
            opts.VariableNames = ["numEntries", "numVariables", "SwitchProbabilities", "Sigma", "predictClass", "deleteVarsType", "classifierType", "balanceType", "normalizeType", "trainTestType", "importanceVars", "doVector", "accuracy", "real_0_predicha_0", "real_0_predicha_1", "real_1_predicha_0", "real_1_predicha_1", "VarName18"];
            opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "string"];
            % Specify file level properties
            opts.ExtraColumnsRule = "ignore";
            opts.EmptyLineRule = "read";
            % Specify variable properties
            opts = setvaropts(opts, "VarName18", "WhitespaceRule", "preserve");
            opts = setvaropts(opts, "VarName18", "EmptyFieldRule", "auto");
            opts = setvaropts(opts, "SwitchProbabilities", "TrimNonNumeric", true);
            opts = setvaropts(opts, "SwitchProbabilities");
            % Import the data
            Table = readtable(nameFileRead, opts);
            Table(:,end) = []; % Empty row
        end
        
        %% Se escriben los resultados de la clasificacion en fichero de union
        %  The results of the classification are written to an union file
        function [] = writeUnionClassificationResults(pathFileWrite, TableCSV, nameUnion, namesSegAlg, doHeader)
            trackFile = fopen(pathFileWrite ,'a');
            varNames = TableCSV.Properties.VariableNames;
            
            if doHeader == true
                fprintf(trackFile, strcat("Union", '; ') );
                fprintf(trackFile, strcat("Segmentation", '; ') );
                for i=1:length(varNames)
                    fprintf(trackFile, strcat(varNames{i}, '; ') );
                end
                fprintf(trackFile, strcat("Sensitivity", '; ') );
                fprintf(trackFile, strcat("Precision", '; ') );
                fprintf(trackFile, strcat("G-measure", '; ') );
                fprintf(trackFile, "\n" );
            end
            
            sens = TableCSV.real_1_predicha_1(1) / ( TableCSV.real_1_predicha_1(1) + TableCSV.real_1_predicha_0(1));
            prec = TableCSV.real_1_predicha_1(1) / ( TableCSV.real_1_predicha_1(1) + TableCSV.real_0_predicha_1(1));
            g = sqrt(sens*prec);
            if isnan(sens)
                sens = 0;
            end
            if isnan(prec)
                prec = 0;
            end
            if isnan(g)
                g = 0;
            end
            
            fprintf(trackFile, strcat(nameUnion, '; ') );
            fprintf(trackFile, strcat(namesSegAlg, '; ') );
            sens = strrep(num2str(sens, "%.5f"), ".", ",");
            prec = strrep(num2str(prec, "%.5f"), ".", ",");
            g = strrep(num2str(g, "%.5f"), ".", ",");
            
            for i=1:length(varNames)
                if floor(TableCSV.(varNames{i})) == TableCSV.(varNames{i}) % Comprueba si es entero
                    val = strrep(num2str(TableCSV.(varNames{i})), ".", ",");
                else
                    val = strrep(num2str(TableCSV.(varNames{i}), "%.5f"), ".", ",");
                end
                fprintf(trackFile, strcat(val, '; ') );
            end
            fprintf(trackFile, strcat(sens, '; ') );
            fprintf(trackFile, strcat(prec, '; ') );
            fprintf(trackFile, strcat(g, '; ') );
            fprintf(trackFile, "\n" );
            
            fclose(trackFile);
        end
        
        %% Se escribe la cabecera de los vectores de la clasificacion
        %  The header of the classification vectors is written
        function [] = writeClassificationVectorHeaders(pathFileWrite, DataTableHeaders)
            trackFile = fopen(pathFileWrite ,'w');
            
            fprintf(trackFile,strcat('Si/No','; '));
            fprintf(trackFile,strcat('classifierType','; '));
            fprintf(trackFile,strcat('predictClass','; '));
            for i=1:length(DataTableHeaders)
                fprintf(trackFile,strcat(DataTableHeaders{i},'; '));
            end
            
            fclose(trackFile);
        end
        
        %% Se escriben los resultados de los vectores de la clasificacion
        %  The results of the classification vectors are written
        function [] = writeClassificationVector(pathFileWrite, avgVector,classifierType,predictClass)
            trackFile = fopen(pathFileWrite ,'a');  % En modo concatenar
            fprintf(trackFile,'\n');
            [m,n] = size(avgVector);
            for i=1:n
                if(i==1)
                    fprintf(trackFile,'Vector de clasificados como SI;');
                else
                    fprintf(trackFile,'Vector de clasificados como NO;');
                end
                fprintf(trackFile,strcat(num2str(classifierType),'; '));
                fprintf(trackFile,strcat(num2str(predictClass),'; '));
                for j=1:m
                    fprintf(trackFile,strcat(num2str(avgVector(m,n)),'; '));
                end
                fprintf(trackFile,'\n');
            end
            fclose(trackFile);
        end
        
        %% Escribe la importancia de las variables originales en el proceso de clasificacion
        %  Write the importance of the original variables in the classification process
        function [] = writeImportanceVariables(pathFileWrite, originalImportance, originalVars)
            
            if isfile(pathFileWrite)
                delete(pathFileWrite);
            end
            trackFile = fopen(pathFileWrite, 'w');
            
            % Header
            for i=1:length(originalVars)
                fprintf(trackFile, strcat(originalVars{i},'; ') );
            end
            fprintf(trackFile,'\n');
            
            % Importance
            for i=1:length(originalImportance)
                fprintf(trackFile, strcat(originalImportance(i),'; ') );
            end
            fprintf(trackFile,'\n');
            
            fclose(trackFile);
        end
        
    end
end