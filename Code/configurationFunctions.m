%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desarrollado por | Developed by:                     %
% University Carlos III of Madrid PhD Researchers      %
% Daniel Amigo Herrero    mailto: damigo@inf.uc3m.es   %
% David Sanchez Pedroche  mailto: davsanch@inf.uc3m.es %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Funciones para leer la configuracion de cada proceso
%  Functions to read the configuration of each process

classdef configurationFunctions
    methods(Static)
        
        
        %% Lee un fichero de configuracion para el filtrado
        %  Read the filter's configuration
        function [filterConf, fusionCenter] = readFilterConf(nameFileConf)
            fileRead = fopen(nameFileConf);
            %readedContent{1} % var
            %readedContent{2} % =
            %readedContent{3} % value
            
            % The 3 first rows are the fusion center's position
            readedContent = strsplit(fgetl(fileRead), ' '); % Reading the header            
            fusionCenter.latitude  = str2num(readedContent{3});
            readedContent = strsplit(fgetl(fileRead), ' '); % Reading the header
            fusionCenter.longitude = str2num(readedContent{3});
            readedContent = strsplit(fgetl(fileRead), ' '); % Reading the header
            fusionCenter.altitude  = str2num(readedContent{3});
            
            % The filter's parameters
            while ~feof(fileRead)
                readedContent = strsplit(fgetl(fileRead), ' '); % Reading the header
                if ~isempty(str2double(readedContent{3})) & ~isnan(str2double(readedContent{3}))
                    filterConf.(readedContent{1}) = str2num(readedContent{3});
                else
                    filterConf.(readedContent{1}) = readedContent{3};
                end
            end
            fclose(fileRead);
        end
                
    end
end