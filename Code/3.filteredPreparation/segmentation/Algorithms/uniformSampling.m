%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desarrollado por | Developed by:                     %
% University Carlos III of Madrid PhD Researchers      %
% Daniel Amigo Herrero    mailto: damigo@inf.uc3m.es   %
% David Sanchez Pedroche  mailto: davsanch@inf.uc3m.es %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This script takes a filtered track read from a file and divide it into segments according to the Uniform Sampling algorithm.
% Reference of the Uniform Sampling algorithm:
% W. R. Tobler, “Numerical map generalization,” Michigan Inter-University Community of Mathematical Geographers, 1966.
% W. R. Tobler, “An update to ‘Numerical Map Generalization,’” Cartographica: The International Journal for Geographic Information and Geovisualization, vol. 26, no. 1, pp. 7–25, Oct. 1989, doi: 10.3138/U2U2-K560-4L26-2663.


function [splits] = uniformSampling(Data, functionCriteria, valueCriteria)

sizeData = height(Data);

if functionCriteria == 0 % Do not split
    splits{1} = Data(:, :); % Write the split on the output variable
    
elseif functionCriteria == 1 % Criteria is uniform number of measures
    limit = floor(sizeData / valueCriteria); % N
    splits = cell(limit, 1);

    top = 1; % Start index of the current split
    for i = 1:limit
        bottom = top + (valueCriteria-1); % End index of the current split
        splits{i} = Data(top:bottom, :);  % Write the split on the output variable
        top = top + (valueCriteria-1);
    end

elseif functionCriteria == 2 % Criteria is uniform time
    
    
elseif functionCriteria == 3 % Criteria is uniform distance
    
end

end