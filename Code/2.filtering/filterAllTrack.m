%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desarrollado por | Developed by:                     %
% University Carlos III of Madrid PhD Researchers      %
% Daniel Amigo Herrero    mailto: damigo@inf.uc3m.es   %
% David Sanchez Pedroche  mailto: davsanch@inf.uc3m.es %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Aplica el filtro IMM sobre la trayectoria completa y una configuracion concreta.
%  apply the selected estimation filter on the selected plots
function [tracks, errorInFilter] = filterAllTrack(plots, filterConf, fusionCenter, varargin)
useRMSE = false; % Se guarda el RMSE de cada traza
if length(varargin) > 0
    if strcmp(varargin{1}, "RMSE")
        useRMSE = true;
    end
end

errorInFilter = false;
tracks = cell(1, height(plots)-2);

% get the fusion center, (0,0) on px py
lat_orig = fusionCenter.latitude;
lon_orig = fusionCenter.longitude;
h_orig = fusionCenter.altitude;
h = 0;

% First and second plots to start (calculate initial speed)
[px1, py1, pz1] = transformations.posWGS84toCar(plots.Latitude(1), plots.Longitude(1), h, lat_orig, lon_orig, h_orig);
[px2, py2, pz2] = transformations.posWGS84toCar(plots.Latitude(2), plots.Longitude(2), h, lat_orig, lon_orig, h_orig);
previous_time = plots.PosixSeconds(2);
period = previous_time - plots.PosixSeconds(1);
px = px2;
py = py2;
pz = pz2;
vx = (px2 - px1) / period;
vy = (py2 - py1) / period;
vz = (pz2 - pz1) / period;

if strcmp(filterConf.filter, "IMMFilterMatlab") % Use the Matlab IMM filter
    if filterConf.numDimensions == 2
        [imm] = IMMFilterMatlab.initialize(filterConf, px, py, vx, vy);
    elseif filterConf.numDimensions == 3
        [imm] = IMMFilterMatlab.initialize(filterConf, px, py, pz, vx, vy, vz);
    end
    
elseif strcmp(filterConf.filter, "IMMFilter") % use our IMM filter
    if filterConf.numDimensions == 2
        [switchProbabilities, modeProbabilities, stateVector, Pk, stateVectorKFs, pkKFs, R, H] = IMMFilter.initializeIMMFilter(filterConf, px, py, vx, vy);
    elseif filterConf.numDimensions == 3
        [switchProbabilities, modeProbabilities, stateVector, Pk, stateVectorKFs, pkKFs, R, H] = IMMFilter.initializeIMMFilter(filterConf, px, py, pz, vx, vy, vz);
    end
end


for i = 3 : height(plots)
    [px, py, pz] = transformations.posWGS84toCar(plots.Latitude(i), plots.Longitude(i), h, lat_orig, lon_orig, h_orig);
    period = plots.PosixSeconds(i) - previous_time;
    
    % Execute the algorithm
    if strcmp(filterConf.filter, "IMMFilterMatlab")
        if filterConf.numDimensions == 2
            measure = [px; py];
        elseif filterConf.numDimensions == 3
            measure = [px; py; pz];
        end
        
        try
            [predict] = IMMFilterMatlab.predictNext(imm, period, filterConf);
            [~] = IMMFilterMatlab.correction(imm, measure, filterConf);
        catch
            disp("timestampToFilter: error in IMMFilterMatlab");
            errorInFilter = true;
            return
        end
        modeProbabilities   = imm.ModelProbabilities;
        if filterConf.numDimensions == 3
            stateVector = [imm.State(1), imm.State(3), imm.State(5), imm.State(2), imm.State(4), imm.State(6)];
            Pk = modifyPk(imm.StateCovariance);
        end
        
        
    elseif strcmp(filterConf.filter, "IMMFilter")
        [stateVectorKFs, pkKFs, predictProb] = IMMFilter.predict(stateVectorKFs, pkKFs, period, switchProbabilities, modeProbabilities, filterConf);
        [stateVectorKFs, pkKFs, verosimilitudResiduos] = IMMFilter.update(stateVectorKFs, pkKFs, H, R, filterConf, px, py);
        [stateVector, Pk, modeProbabilities] = IMMFilter.combination(stateVectorKFs, pkKFs, predictProb, verosimilitudResiduos, modeProbabilities, filterConf);
    end
    
    % Write the results on the output object
    tracks{i-2}.stateVector = stateVector;
    tracks{i-2}.Pk = Pk;
    tracks{i-2}.modeProbabilities = modeProbabilities;
    tracks{i-2}.plot = plots(i,:);
    if strcmp(filterConf.filter, "IMMFilterMatlab")
    elseif strcmp(filterConf.filter, "IMMFilter")
        tracks{i-2}.stateVectorKFs = stateVectorKFs;
        tracks{i-2}.pkKFs = pkKFs;
    end
    % tracks{i-2}.RMSE = RMSE; % Metrics. Not fully working
    
    previous_time = plots.PosixSeconds(i);
end

end

%% Se recibe una Pk de 3D del filtro IMM de Matlab y sale con nuestro formato
%  change the format of the covariances matrix, from Matlab IMM filter to ours filter
function [PkMod] = modifyPk(Pk, filterConf)
% px vx py vy pz vz
% to
% px py pz vx vy vz
PkMod = zeros(length(Pk));
PkMod(1,1) = Pk(1,1); % px
PkMod(1,2) = Pk(1,3); %
PkMod(1,3) = Pk(1,5); %
PkMod(1,4) = Pk(1,2); %
PkMod(1,5) = Pk(1,4); %
PkMod(1,6) = Pk(1,5); %
PkMod(2,1) = Pk(3,1); % py
PkMod(2,2) = Pk(3,3); %
PkMod(2,3) = Pk(3,5); %
PkMod(2,4) = Pk(3,2); %
PkMod(2,5) = Pk(3,4); %
PkMod(2,6) = Pk(3,5); %
PkMod(3,1) = Pk(5,1); % pz
PkMod(3,2) = Pk(5,3); %
PkMod(3,3) = Pk(5,5); %
PkMod(3,4) = Pk(5,2); %
PkMod(3,5) = Pk(5,4); %
PkMod(3,6) = Pk(5,5); %
PkMod(4,1) = Pk(2,1); % vx
PkMod(4,2) = Pk(2,3); %
PkMod(4,3) = Pk(2,5); %
PkMod(4,4) = Pk(2,2); %
PkMod(4,5) = Pk(2,4); %
PkMod(4,6) = Pk(2,5); %
PkMod(5,1) = Pk(4,1); % vy
PkMod(5,2) = Pk(4,3); %
PkMod(5,3) = Pk(4,5); %
PkMod(5,4) = Pk(4,2); %
PkMod(5,5) = Pk(4,4); %
PkMod(5,6) = Pk(4,5); %
PkMod(6,1) = Pk(6,1); % vz
PkMod(6,2) = Pk(6,3); %
PkMod(6,3) = Pk(6,5); %
PkMod(6,4) = Pk(6,2); %
PkMod(6,5) = Pk(6,4); %
PkMod(6,6) = Pk(6,5); %
end