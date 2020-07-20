%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desarrollado por | Developed by:                     %
% University Carlos III of Madrid PhD Researchers      %
% Daniel Amigo Herrero    mailto: damigo@inf.uc3m.es   %
% David Sanchez Pedroche  mailto: davsanch@inf.uc3m.es %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Contiene la algoritmia para realizar un filtrado IMM con dos Kalman a partir de las variables que le vienen como parametro a cada funcion.
%  Has the functions to perform an IMM filter completly. Use two EKF
classdef IMMFilter
    methods(Static)
        
        %% Inicializa el IMM si es un nuevo MMSI
        %  Initialize the IMM filter. When its the first plot
        function [switchProbabilities, modeProbabilities, stateVector, Pk, stateVectorKFs, pkKFs, R, H] = initializeIMMFilter(filterConf, varargin)
            if ~strcmp(filterConf.filter, "IMMFilter") % Error prevention
                error("Wrong filter");
            end
            
            % Cretaion of the state vector and covariances matrix
            if     filterConf.numDimensions == 2 && filterConf.useZ == false % && length(varargin) == 4 % noAccel + 2D
                stateVector(1, 1) = varargin{1}; % x
                stateVector(2, 1) = varargin{2}; % y
                stateVector(3, 1) = varargin{3}; % vx
                stateVector(4, 1) = varargin{4}; % vy
                Pk(1, 1) = filterConf.positionError * filterConf.positionError;
                Pk(2, 2) = filterConf.positionError * filterConf.positionError;
                Pk(3, 3) = filterConf.speedError;
                Pk(4, 4) = filterConf.speedError;
            elseif filterConf.numDimensions == 2 && filterConf.useZ == true % && length(varargin) == 6 % noAccel + 3D
                stateVector(1, 1) = varargin{1}; % x
                stateVector(2, 1) = varargin{2}; % y
                stateVector(3, 1) = varargin{3}; % z
                stateVector(4, 1) = varargin{4}; % vx
                stateVector(5, 1) = varargin{5}; % vy
                stateVector(6, 1) = varargin{6}; % vz
                Pk(1, 1) = filterConf.positionError * filterConf.positionError;
                Pk(2, 2) = filterConf.positionError * filterConf.positionError;
                Pk(3, 3) = filterConf.positionError * filterConf.positionError;
                Pk(4, 4) = filterConf.speedError;
                Pk(5, 5) = filterConf.speedError;
                Pk(6, 6) = filterConf.speedError;
            elseif filterConf.numDimensions == 3 && filterConf.useZ == false % && length(varargin) == 6 % 3D
                stateVector(1, 1) = varargin{1}; % x
                stateVector(2, 1) = varargin{2}; % y
                stateVector(3, 1) = varargin{3}; % vx
                stateVector(4, 1) = varargin{4}; % vy
                stateVector(5, 1) = 0; % varargin{5}; % ax
                stateVector(6, 1) = 0; % varargin{6}; % ay
                Pk(1, 1) = filterConf.positionError * filterConf.positionError;
                Pk(2, 2) = filterConf.positionError * filterConf.positionError;
                Pk(3, 3) = filterConf.speedError;
                Pk(4, 4) = filterConf.speedError;
                Pk(5, 5) = filterConf.accelError;
                Pk(6, 6) = filterConf.accelError;
            elseif filterConf.numDimensions == 3 && filterConf.useZ == true % && length(varargin) == 9 % 3D
                stateVector(1, 1) = varargin{1}; % x
                stateVector(2, 1) = varargin{2}; % y
                stateVector(3, 1) = varargin{3}; % z
                stateVector(4, 1) = varargin{4}; % vx
                stateVector(5, 1) = varargin{5}; % vy
                stateVector(6, 1) = varargin{6}; % vz
                stateVector(7, 1) = 0; % varargin{7}; % ax
                stateVector(8, 1) = 0; % varargin{8}; % ay
                stateVector(9, 1) = 0; % varargin{9}; % az
                Pk(1, 1) = filterConf.positionError * filterConf.positionError;
                Pk(2, 2) = filterConf.positionError * filterConf.positionError;
                Pk(3, 3) = filterConf.positionError * filterConf.positionError;
                Pk(4, 4) = filterConf.speedError;
                Pk(5, 5) = filterConf.speedError;
                Pk(6, 6) = filterConf.speedError;
                Pk(7, 7) = filterConf.accelError;
                Pk(8, 8) = filterConf.accelError;
                Pk(9, 9) = filterConf.accelError;
            end
            
            % Number of modes of the filter
            numModes = filterConf.numModes;
            switchProbabilities = zeros(numModes, numModes);
            modeProbabilities = zeros(numModes, 1);
            for i = 1 : numModes
                for j = 1 : numModes
                    variable = strcat("switchProb_", num2str(i), "_", num2str(j));
                    switchProbabilities(i, j) = filterConf.(variable);
                end
                variable = strcat("mode", num2str(i),"_initialProb");
                modeProbabilities(i, 1) = filterConf.(variable);
            end
            
            % Initialize the Kalman Filters of each mode
            stateVectorKFs = cell(numModes, 1);
            pkKFs = cell(numModes, 1);
            for i = 1:numModes
                [stateVectorKFs{i}, pkKFs{i}, R, H] = KalmanFilter.initialize(filterConf, varargin);
            end
        end
        
        
        %% Ejecuta la fase de prediccion y mezclado de modos
        %  Perform the prediction and modes mixing step
        function [stateVectorKFs, pkKFs, predictProb] = predict(stateVectorKFs, pkKFs, time, switchProbabilities, modeProbabilities, filterConf)
            numModes = filterConf.numModes;
            numDim = filterConf.numDimensions;
            
            remixProb = zeros(numModes, numModes);
            predictProb = transpose(switchProbabilities) * modeProbabilities;
            
            % Mixing probabilities
            for i = 1 : numModes
                for j = 1 : numModes
                    remixProb(j, i) = switchProbabilities(j, i) * modeProbabilities(j, 1) / predictProb(i, 1);
                end
            end
            
            % Mixed estimators
            stateVectorKFs_0 = cell(numModes, 1);
            for modo = 1 : numModes
                stateVectorKFs_0{modo} = zeros(numDim*(2+filterConf.useZ), 1);
                for j = 1 : numModes
                    stateVectorKFs_0{modo} = stateVectorKFs_0{modo} + (remixProb(j,modo) * stateVectorKFs{modo});
                end
            end
            
            pkKFs_0 = cell(numModes, 1);
            for modo = 1 : numModes
                pkKFs_0{modo} = zeros(numDim*(2+filterConf.useZ), numDim*(2+filterConf.useZ));
                for j = 1 : numModes
                    aux2 = stateVectorKFs{modo} - stateVectorKFs_0{modo};
                    aux = aux2 * transpose(aux2); % Correccion
                    pkKFs_0{modo} = pkKFs_0{modo} + ( (aux + pkKFs{modo}) * remixProb(j,modo));
                end
            end
            
            for i = 1 : numModes
                [stateVectorKFs{i}, pkKFs{i}] = KalmanFilter.stateChangePredict(stateVectorKFs_0{i}, pkKFs_0{i}, time, filterConf, i);
            end
        end
        
        %% Fase de actualizacion
        %  Update step
        function [stateVectorKFs, pkKFs, verosimilitudResiduos] = update(stateVectorKFs, pkKFs, H, R, filterConf, varargin)
            if length(varargin) == 2
                measurementMatrix = zeros(2, 1);
                measurementMatrix(1, 1) = varargin{1};
                measurementMatrix(2, 1) = varargin{2};
            elseif length(varargin) == 3
                measurementMatrix = zeros(3, 1);
                measurementMatrix(1, 1) = varargin{1};
                measurementMatrix(2, 1) = varargin{2};
                measurementMatrix(3, 1) = varargin{3};
            end
            
            numModes = filterConf.numModes;
            verosimilitudResiduos = zeros(numModes, 1);
            
            % Update step
            for i = 1 : numModes
                % Update weights before the step
                S = R + (H * pkKFs{i} * transpose(H));
                aux = measurementMatrix - (H * stateVectorKFs{i}); % Pre standardized residue
                a = transpose(aux) * inv(S) * aux;                 % Standardized residue
                
                res1 = exp((-1) * a / 2); % Sometimes is zero and crashes
                res2 = power(abs(2 * pi * det(S)), -0.5);
                
                verosimilitudResiduos(i, 1) = res2 * res1;
            end
            
            % After the IMM update, its turn to update each mode
            for i = 1 : numModes % stateVector, Pk, H, R, varargin
                if length(varargin) == 2
                    [stateVectorKFs{i}, pkKFs{i}] = KalmanFilter.update(stateVectorKFs{i}, pkKFs{i}, H, R, varargin{1}, varargin{2});
                elseif length(varargin) == 3
                    [stateVectorKFs{i}, pkKFs{i}] = KalmanFilter.update(stateVectorKFs{i}, pkKFs{i}, H, R, varargin{1}, varargin{2}, varargin{3});
                end
            end
        end
        
        %% Fase de combinacion
        %  Combination step
        function [stateVector, Pk, modeProbabilities] = combination(stateVectorKFs, pkKFs, predictProb, verosimilitudResiduos, modeProbabilities, filterConf)
            numModes = filterConf.numModes;
            
            % Weighted sum of plausibilities
            verosimilitudAux = transpose(predictProb) * verosimilitudResiduos;
            verosimilitud = verosimilitudAux(1,1);
            
            if verosimilitud == 0 % ERROR PREVENTION
                disp('IMMFilter::combination error prevention as plausibilities == 0');
                for i=1 : numModes
                    verosimilitud = verosimilitud + 0.0000000000000001 * predictProb(i, 1) ;
                    verosimilitudResiduos(i) = 0.0000000000000001;
                end
            end
            
            % We recalculate the a posteriori probabilities
            for i = 1 : numModes
                modeProbabilities(i, 1) = verosimilitudResiduos(i, 1) * predictProb(i, 1) / verosimilitud;
            end
            
            % Calculation of the final state vector
            desviacion = 0; % X in the equations
            for i = 1 : numModes
                if i == 1 % The first mode overwrites the final state vector
                    stateVector = stateVectorKFs{i} * modeProbabilities(i, 1);
                else      % The other modes add their share
                    stateVector = stateVector + stateVectorKFs{i} * modeProbabilities(i, 1);
                end
            end
            
            % Calculation of the final covariance matrix
            for i = 1 : numModes
                dif = (stateVectorKFs{i} - stateVector);
                
                if i == 1 % The first mode overwrites the final covariance matrix
                    Pk = (pkKFs{i} + (dif * (transpose(dif)))) * modeProbabilities(i, 1);
                else      % The other modes add their share
                    Pk = Pk + (pkKFs{i} + (dif * transpose(dif))) * modeProbabilities(i, 1);
                end
            end
            
        end
        
    end
end