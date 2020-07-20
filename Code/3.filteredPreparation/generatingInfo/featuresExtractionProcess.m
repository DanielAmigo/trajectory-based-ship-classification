%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desarrollado por | Developed by:                     %
% University Carlos III of Madrid PhD Researchers      %
% Daniel Amigo Herrero    mailto: damigo@inf.uc3m.es   %
% David Sanchez Pedroche  mailto: davsanch@inf.uc3m.es %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% A partir de los datos cinematicos y obtenidos por filtro IMM, genera informacion de contexto
%  From the kinematic data and the data obtained by IMM filter, it generates context information

function [speedVariation, speed, distance, directionVariation, timeGap, HighMode1, LowMode1, SwitchingMode, HighMode2, LowMode2, thisMMSI, thisFirstTimeConsecutive, thisFirstTimeManeuver, thisTotalTime, thisClassShiptype, thisClassManeuver, thisShipWidth, thisShipLength] = ...
    featuresExtractionProcess(Data, nameTime, threshold)

% Each column of the table stores the entries in each mode of the IMM filter used (1 and 2), the total of the fragment and the mode change
speedVariation     = table; % table of speed variation
speed              = table; % table of speed
distance           = table; % table of distance
directionVariation = table; % table of direction variation
timeGap            = table; % table of time gaps

% Initialize the tables
speedVariation.Total         = zeros(height(Data),1);
speedVariation.HighMode1     = zeros(height(Data),1);
speedVariation.LowMode1      = zeros(height(Data),1);
speedVariation.SwitchingMode     = zeros(height(Data),1);
speedVariation.HighMode2     = zeros(height(Data),1);
speedVariation.LowMode2      = zeros(height(Data),1);
speed.Total                  = zeros(height(Data),1);
speed.HighMode1              = zeros(height(Data),1);
speed.LowMode1               = zeros(height(Data),1);
speed.SwitchingMode              = zeros(height(Data),1);
speed.HighMode2              = zeros(height(Data),1);
speed.LowMode2               = zeros(height(Data),1);
distance.Total               = zeros(height(Data),1);
distance.HighMode1           = zeros(height(Data),1);
distance.LowMode1            = zeros(height(Data),1);
distance.SwitchingMode           = zeros(height(Data),1);
distance.HighMode2           = zeros(height(Data),1);
distance.LowMode2            = zeros(height(Data),1);
directionVariation.Total     = zeros(height(Data),1);
directionVariation.HighMode1 = zeros(height(Data),1);
directionVariation.LowMode1  = zeros(height(Data),1);
directionVariation.SwitchingMode = zeros(height(Data),1);
directionVariation.HighMode2 = zeros(height(Data),1);
directionVariation.LowMode2  = zeros(height(Data),1);
timeGap.Total                = zeros(height(Data),1);
timeGap.HighMode1            = zeros(height(Data),1);
timeGap.LowMode1             = zeros(height(Data),1);
timeGap.SwitchingMode            = zeros(height(Data),1);
timeGap.HighMode2            = zeros(height(Data),1);
timeGap.LowMode2             = zeros(height(Data),1);

% Tables counting the mode changes of the IMM filter
% HighMode1 = 1, LowMode1 = 2, SwitchingMode = 3, HighMode2 = 4, LowMode2 = 5
HighMode1 = table;
LowMode1  = table;
SwitchingMode = table;
HighMode2 = table;
LowMode2  = table;
HighMode1.HighMode1 = 0; % Was in HighMode1 y goes to HighMode1
HighMode1.LowMode1  = 0; % Was in LowMode1 y goes to HighMode1
HighMode1.SwitchingMode = 0;
HighMode1.HighMode2 = 0;
HighMode1.LowMode2  = 0;
LowMode1.HighMode1  = 0;
LowMode1.LowMode1   = 0;
LowMode1.SwitchingMode  = 0;
LowMode1.HighMode2  = 0;
LowMode1.LowMode2   = 0;
SwitchingMode.HighMode1 = 0;
SwitchingMode.LowMode1  = 0;
SwitchingMode.SwitchingMode = 0;
SwitchingMode.HighMode2 = 0;
SwitchingMode.LowMode2  = 0;
HighMode2.HighMode1 = 0;
HighMode2.LowMode1  = 0;
HighMode2.SwitchingMode = 0;
HighMode2.HighMode2 = 0;
HighMode2.LowMode2  = 0;
LowMode2.HighMode1  = 0;
LowMode2.LowMode1   = 0;
LowMode2.SwitchingMode  = 0;
LowMode2.HighMode2  = 0;
LowMode2.LowMode2   = 0;

% Auxiliar vars
modoAct = 0;
modoAnt = 0;
thisMMSI = '';
thisFirstTimeConsecutive = split(nameTime, '_');
thisFirstTimeConsecutive = '0';
thisFirstTimeManeuver = 0;
thisTotalTime = 0;
thisClassShiptype = '';
thisClassManeuver = '';
thisShipWidth = '';
thisShipLength = '';

if height(Data) == 0
    return;
end

%% saving static info too
thisMMSI = Data.MMSI(1);
thisFirstTimeConsecutive = split(nameTime, '_');
thisFirstTimeConsecutive = str2num(thisFirstTimeConsecutive(2));
thisFirstTimeManeuver    = Data.Time(1);
thisTotalTime            = Data.Time(height(Data)) - Data.Time(1);
aux = unique(Data.Shiptype);
aux(strcmp(string(aux),"Undefined") ) = []; % Preventing undefined values
try
    thisClassShiptype = string(aux);
catch
    thisClassShiptype = "-";
end
% Navigationalstatus
[a,~,b] = unique(Data.Navigationalstatus);
if length(a) > 1
    thisClassManeuver = a{mode(b)};
else
    thisClassManeuver = a;
end
% Width
thisShipWidth = 0;
a=unique(Data.Width);
b=isnan(a);
for j=1:length(b)
    if(b == 0)
        thisShipWidth = a(j);
    end
end
% Length
a=unique(Data.Length);
b=isnan(a);
thisShipLength = 0;
for j=1:length(b)
    if(b == 0)
        thisShipLength = a(j);
    end
end

% Counting the current mode
if Data.mode_probabilities_1(1) >= threshold.TopMode1 && Data.mode_probabilities_1(1) <= 1
    modoAnt = 1;
elseif Data.mode_probabilities_1(1) >= threshold.BottomMode1
    modoAnt = 2;
elseif Data.mode_probabilities_1(1) >= threshold.BottomMode2
    modoAnt = 3;
elseif Data.mode_probabilities_1(1) >= threshold.TopMode2
    modoAnt = 4;
elseif threshold.TopMode2 > Data.mode_probabilities_1(1) && Data.mode_probabilities_1(1) >= 0
    modoAnt = 5;
end


for j=2:height(Data)
    v = [Data.kinematic_vx(j) Data.kinematic_vy(j)];          % actual speed
    u = [Data.kinematic_vx(j-1) Data.kinematic_vy(j-1)];      % previous speed
    p = [Data.kinematic_px(j) Data.kinematic_py(j)];          % actual position
    o = [Data.kinematic_px(j-1) Data.kinematic_py(j-1)];      % previous position
    c = cross([v,0],[u,0]);
    
    % Storing Total values
    speedVariation.Total(j) = norm(v) - norm(u);
    speed.Total(j) = norm(v);
    distance.Total(j) = norm(p - o);
    directionVariation.Total(j) = atan2(norm(c),dot(v,u));
    timeGap.Total(j) = Data.Time(j) - Data.Time(j-1);
    
    %% and storing also in the current mode table
    if Data.mode_probabilities_1(j) >= threshold.TopMode1 && Data.mode_probabilities_1(j) <= 1
        modoAct = 1;
        speedVariation.HighMode1(j) = norm(v) - norm(u);
        speed.HighMode1(j) = norm(v);
        distance.HighMode1(j) = norm(p - o);
        directionVariation.HighMode1(j) = atan2(norm(c),dot(v,u));
        timeGap.HighMode1(j) = Data.Time(j)-Data.Time(j-1);
        
        % Storing the mode change (if were any)
        if modoAnt == 1
            HighMode1.HighMode1 = HighMode1.HighMode1 + 1;
        elseif modoAnt == 2
            HighMode1.LowMode1 = HighMode1.LowMode1 + 1;
        elseif modoAnt == 3
            HighMode1.SwitchingMode = HighMode1.SwitchingMode + 1;
        elseif modoAnt == 4
            HighMode1.HighMode2 = HighMode1.HighMode2 + 1;
        elseif modoAnt == 5
            HighMode1.LowMode2 = HighMode1.LowMode2 + 1;
        end
        
    elseif Data.mode_probabilities_1(j) >= threshold.BottomMode1
        modoAct = 2;
        speedVariation.LowMode1(j) = norm(v) - norm(u);
        speed.LowMode1(j) = norm(v);
        distance.LowMode1(j) = norm(p - o);
        directionVariation.LowMode1(j) = atan2(norm(c),dot(v,u));
        timeGap.LowMode1(j) = Data.Time(j)-Data.Time(j-1);
        
        % Storing the mode change (if were any)
        if modoAnt == 1
            LowMode1.HighMode1 = LowMode1.HighMode1 + 1;
        elseif modoAnt == 2
            LowMode1.LowMode1 = LowMode1.LowMode1 + 1;
        elseif modoAnt == 3
            LowMode1.SwitchingMode = LowMode1.SwitchingMode + 1;
        elseif modoAnt == 4
            LowMode1.HighMode2 = LowMode1.HighMode2 + 1;
        elseif modoAnt == 5
            LowMode1.LowMode2 = LowMode1.LowMode2 + 1;
        end
        
    elseif Data.mode_probabilities_1(j) >= threshold.BottomMode2
        modoAct = 3;
        speedVariation.SwitchingMode(j) = norm(v) - norm(u);
        speed.SwitchingMode(j) = norm(v);
        distance.SwitchingMode(j) = norm(p - o);
        directionVariation.SwitchingMode(j) = atan2(norm(c),dot(v,u));
        timeGap.SwitchingMode(j) = Data.Time(j)-Data.Time(j-1);
        
        % Storing the mode change (if were any)
        if modoAnt == 1
            SwitchingMode.HighMode1 = SwitchingMode.HighMode1 + 1;
        elseif modoAnt == 2
            SwitchingMode.LowMode1 = SwitchingMode.LowMode1 + 1;
        elseif modoAnt == 3
            SwitchingMode.SwitchingMode = SwitchingMode.SwitchingMode + 1;
        elseif modoAnt == 4
            SwitchingMode.HighMode2 = SwitchingMode.HighMode2 + 1;
        elseif modoAnt == 5
            SwitchingMode.LowMode2 = SwitchingMode.LowMode2 + 1;
        end
        
    elseif Data.mode_probabilities_1(j) >= threshold.TopMode2
        modoAct = 4;
        speedVariation.HighMode2(j) = norm(v) - norm(u);
        speed.HighMode2(j) = norm(v);
        distance.HighMode2(j) = norm(p - o);
        directionVariation.HighMode2(j) = atan2(norm(c),dot(v,u));
        timeGap.HighMode2(j) = Data.Time(j)-Data.Time(j-1);
        
        % Storing the mode change (if were any)
        if modoAnt == 1
            HighMode2.HighMode1 = HighMode2.HighMode1 + 1;
        elseif modoAnt == 2
            HighMode2.LowMode1 = HighMode2.LowMode1 + 1;
        elseif modoAnt == 3
            HighMode2.SwitchingMode = HighMode2.SwitchingMode + 1;
        elseif modoAnt == 4
            HighMode2.HighMode2 = HighMode2.HighMode2 + 1;
        elseif modoAnt == 5
            HighMode2.LowMode2 = HighMode2.LowMode2 + 1;
        end
        
    elseif threshold.TopMode2 > Data.mode_probabilities_1(j) && Data.mode_probabilities_1(j) >= 0
        modoAct = 5;
        speedVariation.LowMode2(j) = norm(v) - norm(u);
        speed.LowMode2(j) = norm(v);
        distance.LowMode2(j) = norm(p - o);
        directionVariation.LowMode2(j) = atan2(norm(c),dot(v,u));
        timeGap.LowMode2(j) = Data.Time(j)-Data.Time(j-1);
        
        % Storing the mode change (if were any)
        if modoAnt == 1
            LowMode2.HighMode1 = LowMode2.HighMode1 + 1;
        elseif modoAnt == 2
            LowMode2.LowMode1 = LowMode2.LowMode1 + 1;
        elseif modoAnt == 3
            LowMode2.SwitchingMode = LowMode2.SwitchingMode + 1;
        elseif modoAnt == 4
            LowMode2.HighMode2 = LowMode2.HighMode2 + 1;
        elseif modoAnt == 5
            LowMode2.LowMode2 = LowMode2.LowMode2 + 1;
        end
        
    end
    
    modoAnt = modoAct; % update for the following step
end

% Deleting the first row, as its full of 0's
speedVariation(1,:) = [];
speed(1,:)          = [];
distance(1,:)          = [];
directionVariation(1,:) = [];
timeGap(1,:)      = [];

%speedVariation(1,:) = []; % In some cases necessary to delete the second too
%speed(1,:)          = [];
%distance(1,:)          = [];
%directionVariation(1,:) = [];
%timeGap(1,:)      = [];
end