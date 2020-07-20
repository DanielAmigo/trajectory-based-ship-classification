%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desarrollado por | Developed by:                     %
% University Carlos III of Madrid PhD Researchers      %
% Daniel Amigo Herrero    mailto: damigo@inf.uc3m.es   %
% David Sanchez Pedroche  mailto: davsanch@inf.uc3m.es %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Contiene la algoritmia para realizar un filtro de Kalman Extendido (EKF) a partir de las variables que le vienen como parametro a cada funcion
%  Contains the algorithms to develop and execute an Extended Kalman Filter (EKF)

classdef KalmanFilter
    methods(Static)

        %% Se inicializan las variables necesarias para el funcionamiento del filtro EKF
        %  all the initial variables are created for the correct work of the filter
        function [stateVector, Pk, R, H] = initialize(filterConf, varargin)
            % Matrix Q. It's generated only when is necessary
            % Matrix A. It's generated only when is necessary
            % Matrix R. Use the ais_horizontal_error. No se utiliza en la primera iteracion
            
            if strcmp(filterConf.filter, "IMMFilter") == false && strcmp(filterConf.filter, "EKF") == false % Error prevention
                error("Wrong filter");
            end
            if strcmp(filterConf.filter, "IMMFilter") == true
                varargin = varargin{1};
            end

            % Create the vector state and covariances matrix depending of the dimensions
            stateVector = zeros(filterConf.numDimensions*(2+filterConf.useZ), 1);
            Pk = zeros(filterConf.numDimensions*(2+filterConf.useZ), filterConf.numDimensions*(2+filterConf.useZ));
            if     filterConf.numDimensions == 2 && filterConf.useZ == false && length(varargin) == 4 % noAccel + 2D
                stateVector(1, 1) = varargin{1}; % x
                stateVector(2, 1) = varargin{2}; % y
                stateVector(3, 1) = varargin{3}; % vx
                stateVector(4, 1) = varargin{4}; % vy
                Pk(1, 1) = filterConf.positionError * filterConf.positionError;
                Pk(2, 2) = filterConf.positionError * filterConf.positionError;
                Pk(3, 3) = filterConf.speedError;
                Pk(4, 4) = filterConf.speedError;
            elseif filterConf.numDimensions == 2 && filterConf.useZ == true && length(varargin) == 6 % noAccel + 3D
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
            elseif filterConf.numDimensions == 3 && filterConf.useZ == false && length(varargin) == 6 % 3D
                stateVector(1, 1) = varargin{1}; % x
                stateVector(2, 1) = varargin{2}; % y
                stateVector(3, 1) = varargin{3}; % vx
                stateVector(4, 1) = varargin{4}; % vy
                stateVector(5, 1) = varargin{5}; % ax
                stateVector(6, 1) = varargin{6}; % ay
                Pk(1, 1) = filterConf.positionError * filterConf.positionError;
                Pk(2, 2) = filterConf.positionError * filterConf.positionError;
                Pk(3, 3) = filterConf.speedError;
                Pk(4, 4) = filterConf.speedError;
                Pk(5, 5) = filterConf.accelError;
                Pk(6, 6) = filterConf.accelError;
            elseif filterConf.numDimensions == 3 && filterConf.useZ == true && length(varargin) == 9 % 3D
                stateVector(1, 1) = varargin{1}; % x
                stateVector(2, 1) = varargin{2}; % y
                stateVector(3, 1) = varargin{3}; % z
                stateVector(4, 1) = varargin{4}; % vx
                stateVector(5, 1) = varargin{5}; % vy
                stateVector(6, 1) = varargin{6}; % vz
                stateVector(7, 1) = varargin{7}; % ax
                stateVector(8, 1) = varargin{8}; % ay
                stateVector(9, 1) = varargin{9}; % az
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

            % Matrix R. Measurement noise. XY or XYZ
            R = zeros(filterConf.numDimensions, filterConf.numDimensions); 
            for i = 1:filterConf.numDimensions
                R(i, i) = filterConf.positionError ^2;
            end
            
            % Matrix H
            [m,n] = size(stateVector);
            H = eye(filterConf.numDimensions, m);
            
            % PCRLB metric
            %QMatrix = filterEKF.calculateQMatrix(m, period, configuration);
            %J = inv(QMatrix);
            %matrixPCRLB = inv(J);
            %PCRLB = diag(matrixPCRLB);
        end
        
        %% Fase de prediccion a partir del estado anterior
        %  Makes the prediction from the previous time
        function [stateVector, Pk] = stateChangePredict(stateVector_0, Pk_0, time, filterConf, varargin)
            [m,n] = size(stateVector_0);
            
            if length(varargin) > 0
                [A] = KalmanFilter.calculateAMatrix(time, m, filterConf, varargin{1});
                [Q] = KalmanFilter.calculateQMatrix(time, m, filterConf, varargin{1});
            else
                [A] = KalmanFilter.calculateAMatrix(time, m, filterConf);
                [Q] = KalmanFilter.calculateQMatrix(time, m, filterConf);
            end
            
            stateVector = A * stateVector_0;
            Pk = A * Pk_0 * transpose(A) + Q;
        end

        %% Actualizacion de la prediccion con la medida
        %  Update the prediction using the measurement
        function [stateVector, Pk] = update(stateVector, Pk, H, R, varargin)
            if length(varargin) == 2     % 2D
                measurement(1, 1) = varargin{1};
                measurement(2, 1) = varargin{2};
            elseif length(varargin) == 3 % 3D
                measurement(1, 1) = varargin{1};
                measurement(2, 1) = varargin{2};
                measurement(3, 1) = varargin{3};
            end
            
            innovation = measurement - H * stateVector;   % Difference between measurement and predicted position
            S = H * Pk * transpose(H) + R;                % Covariance of the measurement?
            K = Pk * transpose(H) * inv(S);               % Kalman Gain

            % The state vector and its covariance matrix are corrected
            stateVector = stateVector + (K * innovation);
            KbyH = K * H;
            [m,n] = size(KbyH);
            identity = eye(m, n);
            Pk = (identity - KbyH) * Pk;

            %% Metrics are calculated
            % NIS = transpose(innovation) * inv(S) * innovation;           % NIS
            % difStateVector = stateVectorFinal - stateVectorPredict;
            % NEES = transpose(difStateVector) * inv(Pk) * difStateVector; % NEES
            % RMSE = sum( (innovation).^2 );                               % RMSE
        end

        %% Se genera la matriz de transicion del instante t-1 a t
        %  It generates the transition matrix from instant t-1 to t
        function [A] = calculateAMatrix(time, m, filterConf, varargin)
            if length(varargin) > 0 && strcmp(filterConf.filter, "IMMFilter") % Es un IMM
                numMode = varargin{1};
                mode = strcat("mode", num2str(numMode) );
            elseif length(varargin) == 0 && strcmp(filterConf.filter, "EKF")
                mode = "mode";
            elseif strcmp(filterConf.filter, "Extrapolate")
                mode = "mode";
            end
            
            A = eye(m, m);
            if     strcmp(filterConf.(mode), "constantVel")   && filterConf.useZ == false && m == 4 % Constant Speed Prediction on 2D
                %    F=[1 0 T 0
                %       0 1 0 T
                %       0 0 1 0
                %       0 0 0 1]
                A(1, 3) = time;
                A(2, 4) = time;

            elseif strcmp(filterConf.(mode), "constantVel")   && filterConf.useZ == true  && m == 6 % Constant Speed Prediction on 3D
                %    F=[1 0 0 T 0 0
                %       0 1 0 0 T 0
                %       0 0 1 0 0 T
                %       0 0 0 1 0 0
                %       0 0 0 0 1 0
                %       0 0 0 0 0 1]
                A(1, 4) = time;
                A(2, 5) = time;
                A(3, 6) = time;
            elseif strcmp(filterConf.(mode), "constantAccel") && filterConf.useZ == false && m == 6 % Constant Acceleration Prediction on 2D
                % a = T    b = 1/2 * T^2
                %         x  y vx vy ax ay
                %    x = [1  0  a  0  b  0
                %    y    0  1  0  a  0  b
                %    vx   0  0  1  0  a  0
                %    vy   0  0  0  1  0  a
                %    ax   0  0  0  0  1  0
                %    ay   0  0  0  0  0  1]
                A(1, 3) = time;
                A(2, 4) = time;
                A(3, 5) = time;
                A(4, 6) = time;
                A(1, 5) = (1/2) * time^2;
                A(2, 6) = (1/2) * time^2;
                
            elseif strcmp(filterConf.(mode), "constantAccel") && filterConf.useZ == true  && m == 9 % Constant Acceleration Prediction on 3D
                % a = T    b = 1/2 * T^2
                %         x  y  z vx vy vz ax ay az
                %    x = [1  0  0  a  0  0  b  0  0
                %    y    0  1  0  0  a  0  0  b  0
                %    z    0  0  1  0  0  a  0  0  b
                %    vx   0  0  0  1  0  0  a  0  0
                %    vy   0  0  0  0  1  0  0  a  0
                %    vz   0  0  0  0  0  1  0  0  a
                %    ax   0  0  0  0  0  0  1  0  0
                %    ay   0  0  0  0  0  0  0  1  0
                %    az   0  0  0  0  0  0  0  0  1]
                A(1, 4) = time;
                A(2, 5) = time;
                A(3, 6) = time;
                
            elseif strcmp(filterConf.(mode), "constantTurn") && m == 4 % Constant Turn Prediction on 2D
                w = 0; % amount of turn
                
                d = sin(w * time);
                a = d / w;
                b = cos(w * time);
                c = (1 - b) / w;
                %         x  y vx vy
                %    x = [1  0  a -c
                %    y    0  1  c  a
                %    vx   0  0  b -d 
                %    vy   0  0  d  b]
                A(1, 3) = a;
                A(1, 4) = -c;
                A(2, 3) = c;
                A(2, 4) = a;
                A(3, 3) = b;
                A(3, 4) = -d;
                A(4, 3) = d;
                A(4, 4) = b;
            
            elseif strcmp(filterConf.(mode), "constantTurn") && m == 6 % Constant Turn Prediction on 3D

            elseif m == 4 % Unknown 2D mode, use the Constant Speed Prediction
                %    F=[1 0 T 0
                %       0 1 0 T
                %       0 0 1 0
                %       0 0 0 1]
                A(1, 3) = time;
                A(2, 4) = time;

            elseif m == 6 % Unknown 3D mode, use the Constant Speed Prediction
                %    F=[1 0 T 0
                %       0 1 0 T
                %       0 0 1 0
                %       0 0 0 1]
                A(1, 3) = time;
                A(2, 4) = time;
            else % Unknown
                error("error on AMatrix");
            end
        end

        %%  Se genera la matriz que modela el ruido de planta
        %  The matrix that models the plant noise is generated
        function [Q] = calculateQMatrix(time, m, filterConf, varargin)
            if length(varargin) > 0 && strcmp(filterConf.filter, "IMMFilter") % Use an IMM filter
                numMode = varargin{1};
                mode = strcat("mode", num2str(numMode) );
                
            elseif length(varargin) == 0 && strcmp(filterConf.filter, "EKF")
                mode = "mode";
            
            elseif length(varargin) == 0 && strcmp(filterConf.filter, "Extrapolate")
                mode = "mode";
            end
            
            
            if strcmp(filterConf.(mode), "constantVel") && m == 4 % Constant Speed Prediction on 2D
                a = time^4 / 4;
                b = time^3 / 2;
                c = time^2;
                %    F=[a 0 b 0
                %       0 a 0 b
                %       b 0 c 0
                %       0 b 0 c]
                Q = zeros(m, m);
                Q(1, 1) = a;
                Q(2, 2) = a;
                Q(3, 3) = c;
                Q(4, 4) = c;
                Q(1, 3) = b;
                Q(3, 1) = b;
                Q(2, 4) = b;
                Q(4, 2) = b;
                variable = strcat(mode, "MaxAccel");
                accel = filterConf.(variable);
                Q = Q * accel^2;

            elseif strcmp(filterConf.(mode), "constantVel") && m == 6 % Constant Speed Prediction on 3D
                a = time^4 / 4;
                b = time^3 / 2;
                c = time^2;
                %    F=[a 0 0 b 0 0
                %       0 a 0 0 b 0
                %       0 0 a 0 0 b
                %       b 0 0 c 0 0
                %       0 b 0 0 c 0
                %       0 0 b 0 0 c]
                Q = zeros(m, m);
                Q(1, 1) = a;
                Q(2, 2) = a;
                Q(3, 3) = a;
                Q(4, 4) = c;
                Q(5, 5) = c;
                Q(6, 6) = c;
                Q(1, 4) = b;
                Q(4, 1) = b;
                Q(2, 5) = b;
                Q(5, 2) = b;
                Q(3, 6) = b;
                Q(6, 3) = b;
                variable = strcat(mode, "MaxAccel");
                accel = filterConf.(variable);
                Q = Q * accel^2;

            elseif strcmp(filterConf.(mode), "constantAccel") && m == 4 % Constant Acceleration Prediction on 2D
                
            elseif strcmp(filterConf.(mode), "constantAccel") && m == 6 % Constant Acceleration Prediction on 3D

            elseif strcmp(filterConf.(mode), "constantTurn") && m == 4 % Constant Turn Prediction on 2D

            elseif strcmp(filterConf.(mode), "constantTurn") && m == 6 % Constant Turn Prediction on 3D
                
            else % Unknown
                error("error on QMatrix");
            end
        end
    end
end