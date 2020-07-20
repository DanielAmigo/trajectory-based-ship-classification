%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desarrollado por | Developed by:                     %
% University Carlos III of Madrid PhD Researchers      %
% Daniel Amigo Herrero    mailto: damigo@inf.uc3m.es   %
% David Sanchez Pedroche  mailto: davsanch@inf.uc3m.es %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Aplica un balanceo a los datos de entrada para sacar una matriz de datos modificada
%  Apply a balancing to the input data to get a modified data matrix
function [newDataMatrix, newClassesTable] = balancerProcess(DataMatrix, balanceType, ClassesTable, selectedClass, otherClasses, varargin)

[numEntries, numVars] = size(DataMatrix);

if balanceType > 0 && (selectedClass > 2 && selectedClass < 13) % Only binary classes
    
    entriesSelectedClass = sum( ismember(ClassesTable{:, selectedClass}, 1) ); % Number of entries of the selected class
    entriesPerOtherClasses = zeros(length(otherClasses), 1);                   % Number of entries of the other binary classes
    for i=1:length(otherClasses)
        entriesPerOtherClasses(i) = sum( ismember(ClassesTable{:, otherClasses(i)}, 1) );
    end
    newClassesTable = [];
    
    % The type of balancing is identified and the number of entries to be used from each type is assigned
    entriesToUsePerClass = zeros(length(otherClasses), 1);
    
    %% Half of the entries of the selected class, the other half of the rest, maintaining the distribution ratio
    if balanceType == 1
        for i=1:length(otherClasses)
            entriesToUsePerClass(i) = round(entriesSelectedClass * (entriesPerOtherClasses(i) / sum(entriesPerOtherClasses) ) ); % balancing ratio
        end
        
        % Entries are inserted into a new DataMatrix at random
        [newDataMatrix, newClassesTable] = genNewDataMatrix(DataMatrix, ClassesTable, selectedClass, otherClasses, entriesSelectedClass, entriesPerOtherClasses, entriesToUsePerClass);
        
    %% Half of the selected one, the other half balanced with the others (if possible)
    elseif balanceType == 2
        
        numberEntriesAllClasses = round( entriesSelectedClass * (1 / length(entriesPerOtherClasses) ) ); % Proportional number of entries
        
        % The exact percentage of each class is attempted
        diff = 0;
        for i=1:length(otherClasses)
            entriesToUsePerClass(i) = min(entriesPerOtherClasses(i), numberEntriesAllClasses);   % Attempts to introduce the maximum possible of this class (may not be possible)
            diff = diff + (numberEntriesAllClasses - entriesToUsePerClass(i));                   % Note the number that could not be entered (if any)
        end
        while diff > 0 % If there is something that cannot be inserted
            flag = 0;
            for i=1:length(otherClasses) % It is entered one by one with the classes that can still enter more
                if entriesPerOtherClasses(i) >= entriesToUsePerClass(i)
                    flag = 1;
                    entriesToUsePerClass(i) = entriesToUsePerClass(i) + 1; 
                    diff = diff - 1;
                end
            end
            if flag == 0
                diff = 0;
            end
        end
        
        % Entries are inserted into a new DataMatrix at random
        [newDataMatrix, newClassesTable] = genNewDataMatrix(DataMatrix, ClassesTable, selectedClass, otherClasses, entriesSelectedClass, entriesPerOtherClasses, entriesToUsePerClass);
        
        %% Random Undersampling. All the entries of the selected one are entered, and the others (otherClasses) the same number but randomly (no criteria)
    elseif balanceType == 3
        
        % Getting the entries from the other classes
        indexNonSelected = ClassesTable{:,selectedClass} == false;
        posNonSelected   = find(indexNonSelected == 1);
        selected = randsample(length(posNonSelected), entriesSelectedClass); % Indexes to be selected from the other classes
        newDataMatrix = DataMatrix(posNonSelected(selected),:);
        newClassesTable = ClassesTable(posNonSelected(selected),:);
        
        % Getting the entries from the selected class
        entriesThisClass = find(ClassesTable{:,selectedClass} == 1);
        newDataMatrix = [DataMatrix(entriesThisClass,:); newDataMatrix];
        newClassesTable = [ClassesTable(entriesThisClass,:); newClassesTable];
        
        %% SMOTE. It performs random oversampling on the selected class until it matches up to the sum of the rest.
    elseif balanceType == 4
        if entriesSelectedClass > sum(entriesPerOtherClasses)
            disp("Is not necessary to do SMOTE");
        else
            numEntriesToCreate = sum(entriesPerOtherClasses) - entriesSelectedClass; % The number of entries to be created from the selected one is calculated
            % Entries of this selected type are generated up to half of the total with SMOTE
            if length(varargin) > 0
                [addToDataMatrix, addToClassesTable] = SMOTE(DataMatrix, ClassesTable{:,selectedClass}, numEntriesToCreate, varargin{1}); % Entries of this selected type are generated up to half of the total
                entries = height(ClassesTable);
                newEntries = length(addToClassesTable);
                ClassesTable{entries+1:entries+newEntries,selectedClass} = addToClassesTable; % The new ones created are added
                DataMatrix(entries+1:entries+newEntries,:) = addToDataMatrix;
            end
        end
        newDataMatrix = DataMatrix;
        newClassesTable = ClassesTable;
        
        %% SMOTE in the classes that need to match it to the maximum
    elseif balanceType == 5
        newDataMatrix = DataMatrix;
        newClassesTable = ClassesTable;
    else % ERROR
        disp("Incorrect balance ID");
        newDataMatrix = DataMatrix;
        newClassesTable = ClassesTable;
    end
    
elseif selectedClass < 3 % MULTICLASE ORIGINAL
    disp("Balance over multiclass don't work yet");
    newDataMatrix = DataMatrix;
    newClassesTable = ClassesTable;
else % Multiclase OK
    disp("Balance over multiclass don't work yet");
    newDataMatrix = DataMatrix;
    newClassesTable = ClassesTable;
end

end

%% Funcion que orquesta la creacion del nuevo dataMatrix, a partir de las variables que le indican la cantidad a utilizar de cada clase
%  This function orchestrates the creation of the new dataMatrix, using the variables which indicate the quantity of each class to be introduced
function [newDataMatrix, newClassesTable] = genNewDataMatrix(DataMatrix, ClassesTable, selectedClass, otherClasses, entriesSelectedClass, entriesPerOtherClasses, entriesToUsePerClass)
[numEntries, numVars] = size(DataMatrix);
newDataMatrix = zeros((entriesSelectedClass*2-1), numVars);
%newClassesTable = zeros((entriesSelectedClass*2-1), width(ClassesTable));
currentIndex = 1;

% The ones from the selected class are put in
entriesThisClass = find(ClassesTable{:,selectedClass} == 1); % The positions selected are obtained
newIndex = currentIndex + entriesSelectedClass - 1;
newDataMatrix(currentIndex:newIndex,:) = DataMatrix(entriesThisClass,:);
newClassesTable(currentIndex:newIndex,:) = ClassesTable(entriesThisClass,:);
currentIndex = newIndex + 1;                                   % Para la siguiente

for i=1:length(otherClasses) % For each other class
    entriesThisClass = find(ClassesTable{:,otherClasses(i)} == 1);
    newIndex = currentIndex + entriesToUsePerClass(i) - 1;        
    if entriesToUsePerClass(i) == entriesPerOtherClasses(i)        % Every entry in this class has to be put in
        newDataMatrix(currentIndex:newIndex,:) = DataMatrix(entriesThisClass,:);
        newClassesTable(currentIndex:newIndex,:) = ClassesTable(entriesThisClass,:);
    elseif entriesPerOtherClasses(i) >= entriesToUsePerClass(i)    % Not all of them are selected, just take a random set
        selected = randsample(entriesPerOtherClasses(i), entriesToUsePerClass(i)); % The desired number of your entries are randomly taken
        selected = sort(selected);
        newDataMatrix(currentIndex:newIndex,:) = DataMatrix(selected,:);
        newClassesTable(currentIndex:newIndex,:) = ClassesTable(selected,:);
    end
    currentIndex = newIndex + 1;
end
end

%% SMOTE algorithm
function [addToDataMatrix, addToClassesTable] = SMOTE(DataMatrix, ClassTable, numEntriesToCreate, varargin)

indexesClass = find(ClassTable == 1);       % Get the indexes of this class
entriesClass = DataMatrix(indexesClass, :); % All the entries of this class

numNeighbours = 3; % Use only 3 neighbors, enhancing performance
[numEntriesClass, numVarsEntries] = size(entriesClass);

if length(varargin) > 0 
    pathNeighbours = varargin{1};
    if isfile(pathNeighbours)  % This file stores the neighbors for this same experiment, so it is not necessary to calculate it again
        load(pathNeighbours, 'nearestUnroll');
        [~, numToSelect] = size(nearestUnroll);
    else
        % Calcule the N nearest neighbors of each entry, using all its variables
        nearest = nearestneighbour(transpose(entriesClass), 'NumberOfNeighbours', numNeighbours);
        
        if find(nearest == 0) > 0 % Delete the ones without neighbors
            idxDelete = find(nearest(1,:) == 0);
            nearest(:,idxDelete) = [];
        end
        
        % All detections (selected-neighbor) are placed in a vertical array
        cnt = 1;
        numEntriesClass = length(nearest);
        numToSelect = numNeighbours*numEntriesClass;
        nearestUnroll = zeros(2, numToSelect);
        for i=1:numNeighbours
            for j=1:length(nearest)
                nearestUnroll(1,cnt) = j;               % Seleccionado
                nearestUnroll(2,cnt) = nearest(i,j);   % Vecino detectado
                cnt = cnt + 1;
            end
        end
        
        % If entries with these neighbors are missing, the neighbors found are cloned as many times as needed
        if numToSelect/numEntriesToCreate < 1
            percent = numToSelect/numEntriesToCreate;
            numCopy = ceil(1/percent);
            newSize = numToSelect*numCopy;
            newNearestUnroll = zeros(2, newSize);
            indexFloor = 1;
            for i=1:numCopy
                indexCeil = indexFloor + floor(newSize/(numCopy)) - 1;
                newNearestUnroll(:,indexFloor:indexCeil) = nearestUnroll;
                indexFloor = indexCeil + 1;
            end
            numToSelect = newSize;
            nearestUnroll = newNearestUnroll;
        end
        
        save(pathNeighbours, 'nearestUnroll'); % save the neighbors in the path
    end
end

% Going through the near neighbours and generating the new points
addToDataMatrix   = zeros(numEntriesToCreate, numVarsEntries);
addToClassesTable = ones(numEntriesToCreate, 1);
selected = randsample(numToSelect, numEntriesToCreate);
for i=1:length(selected)
    pos = selected(i);
    selectedEntry = entriesClass(nearestUnroll(1,pos), :);
    neighbourEntry = entriesClass(nearestUnroll(2,pos), :);
    diff = neighbourEntry - selectedEntry;               
    for j=1:length(diff)                                 
        addToDataMatrix(i,j) = selectedEntry(j) + (rand * diff(j));
    end
end
end


%% NN needed for SMOTE
function [idx, tri] = nearestneighbour(varargin)
%NEARESTNEIGHBOUR    find nearest neighbours
%   IDX = NEARESTNEIGHBOUR(X) finds the nearest neighbour by Euclidean
%   distance to each point (column) in X from X. X is a matrix with points
%   as columns. IDX is a vector of indices into X, such that X(:, IDX) are
%   the nearest neighbours to X. e.g. the nearest neighbour to X(:, 2) is
%   X(:, IDX(2))
%
%   IDX = NEARESTNEIGHBOUR(P, X) finds the nearest neighbour by Euclidean
%   distance to each point in P from X. P and X are both matrices with the
%   same number of rows, and points are the columns of the matrices. Output
%   is a vector of indices into X such that X(:, IDX) are the nearest
%   neighbours to P
%
%   IDX = NEARESTNEIGHBOUR(I, X) where I is a logical vector or vector of
%   indices, and X has at least two rows, finds the nearest neighbour in X
%   to each of the points X(:, I).
%   I must be a row vector to distinguish it from a single point.
%   If X has only one row, the first input is treated as a set of 1D points
%   rather than a vector of indices
%
%   IDX = NEARESTNEIGHBOUR(..., Property, Value)
%   Calls NEARESTNEIGHBOUR with the indicated parameters set. Property
%   names can be supplied as just the first letters of the property name if
%   this is unambiguous, e.g. NEARESTNEIGHBOUR(..., 'num', 5) is equivalent
%   to NEARESTNEIGHBOUR(..., 'NumberOfNeighbours', 5). Properties are case
%   insensitive, and are as follows:
%      Property:                         Value:
%      ---------                         ------
%         NumberOfNeighbours             natural number, default 1
%            NEARESTNEIGHBOUR(..., 'NumberOfNeighbours', K) finds the closest
%            K points in ascending order to each point, rather than the
%            closest point. If Radius is specified and there are not
%            sufficient numbers, fewer than K neighbours may be returned
%
%         Radius                         positive, default +inf
%            NEARESTNEIGHBOUR(..., 'Radius', R) finds neighbours within
%            radius R. If NumberOfNeighbours is not set, it will find all
%            neighbours within R, otherwise it will find at most
%            NumberOfNeighbours. The IDX matrix is padded with zeros if not
%            all points have the same number of neighbours returned. Note
%            that specifying a radius means that the Delaunay method will
%            not be used.
%
%         DelaunayMode                   {'on', 'off', |'auto'|}
%            DelaunayMode being set to 'on' means NEARESTNEIGHBOUR uses the
%            a Delaunay triangulation with dsearchn to find the points, if
%            possible. Setting it to 'auto' means NEARESTNEIGHBOUR decides
%            whether to use the triangulation, based on efficiency. Note
%            that the Delaunay triangulation will not be used if a radius
%            is specified.
%
%         Triangulation                  Valid triangulation produced by
%                                        delaunay or delaunayn
%            If a triangulation is supplied, NEARESTNEIGHBOUR will attempt
%            to use it (in conjunction with dsearchn) to find the
%            neighbours.
%
%   [IDX, TRI] = NEARESTNEIGHBOUR( ... )
%   If the Delaunay Triangulation is used, TRI is the triangulation of X'.
%   Otherwise, TRI is an empty matrix
%
%   Example:
%
%     % Find the nearest neighbour in X to each column of X
%     x = rand(2, 10);
%     idx = nearestneighbour(x);
%
%     % Find the nearest neighbours to each point in p
%     p = rand(2, 5);
%     x = rand(2, 20);
%     idx = nearestneighbour(p, x)
%
%     % Find the five nearest neighbours to points x(:, [1 6 20]) in x
%     x = rand(4, 1000)
%     idx = nearestneighbour([1 6 20], x, 'NumberOfNeighbours', 5)
%
%     % Find all neighbours within radius of 0.1 of the points in p
%     p = rand(2, 10);
%     x = rand(2, 100);
%     idx = nearestneighbour(p, x, 'r', 0.1)
%
%     % Find at most 10 nearest neighbours to point p from x within a
%     % radius of 0.2
%     p = rand(1, 2);
%     x = rand(2, 30);
%     idx = nearestneighbour(p, x, 'n', 10, 'r', 0.2)
%
%
%   See also DELAUNAYN, DSEARCHN, TSEARCH
%TODO    Allow other metrics than Euclidean distance
%TODO    Implement the Delaunay mode for multiple neighbours
% Copyright 2006 Richard Brown. This code may be freely used and
% distributed, so long as it maintains this copyright line
error(nargchk(1, Inf, nargin, 'struct'));
% Default parameters
userParams.NumberOfNeighbours = []    ; % Finds one
userParams.DelaunayMode       = 'auto'; % {'on', 'off', |'auto'|}
userParams.Triangulation      = []    ;
userParams.Radius             = inf   ;
% Parse inputs
[P, X, fIndexed, userParams] = parseinputs(userParams, varargin{:});
% Special case uses Delaunay triangulation for speed.
% Determine whether to use Delaunay - set fDelaunay true or false
nX  = size(X, 2);
nP  = size(P, 2);
dim = size(X, 1);
switch lower(userParams.DelaunayMode)
    case 'on'
        %TODO Delaunay can't currently be used for finding more than one
        %neighbour
        fDelaunay = userParams.NumberOfNeighbours == 1 && ...
            size(X, 2) > size(X, 1)                    && ...
            ~fIndexed                                  && ...
            userParams.Radius == inf;
    case 'off'
        fDelaunay = false;
    case 'auto'
        fDelaunay = userParams.NumberOfNeighbours == 1 && ...
            ~fIndexed                                  && ...
            size(X, 2) > size(X, 1)                    && ...
            userParams.Radius == inf                   && ...
            ( ~isempty(userParams.Triangulation) || delaunaytest(nX, nP, dim) );
end
% Try doing Delaunay, if fDelaunay.
fDone = false;
if fDelaunay
    tri = userParams.Triangulation;
    if isempty(tri)
        try
            tri   = delaunayn(X');
        catch
            msgId = 'NearestNeighbour:DelaunayFail';
            msg = ['Unable to compute delaunay triangulation, not using it. ',...
                'Set the DelaunayMode parameter to ''off'''];
            warning(msgId, msg);
        end
    end
    if ~isempty(tri)
        try
            idx = dsearchn(X', tri, P')';
            fDone = true;
        catch
            warning('NearestNeighbour:DSearchFail', ...
                'dsearchn failed on triangulation, not using Delaunay');
        end
    end
else % if fDelaunay
    tri = [];
end
% If it didn't use Delaunay triangulation, find the neighbours directly by
% finding minimum distances
if ~fDone
    idx = zeros(userParams.NumberOfNeighbours, size(P, 2));
    % Loop through the set of points P, finding the neighbours
    Y = zeros(size(X));
    for iPoint = 1:size(P, 2)
        x = P(:, iPoint);
        % This is the faster than using repmat based techniques such as
        % Y = X - repmat(x, 1, size(X, 2))
        for i = 1:size(Y, 1)
            Y(i, :) = X(i, :) - x(i);
        end
        % Find the closest points, and remove matches beneath a radius
        dSq = sum(abs(Y).^2, 1);
        iRad = find(dSq < userParams.Radius^2);
        if ~fIndexed
            iSorted = iRad(minn(dSq(iRad), userParams.NumberOfNeighbours));
        else
            iSorted = iRad(minn(dSq(iRad), userParams.NumberOfNeighbours + 1));
            iSorted = iSorted(2:end);
        end
        % Remove any bad ones
        idx(1:length(iSorted), iPoint) = iSorted';
    end
    %while ~isempty(idx) && isequal(idx(end, :), zeros(1, size(idx, 2)))
    %    idx(end, :) = [];
    %end
    idx( all(idx == 0, 2), :) = [];
end % if ~fDone
if isvector(idx)
    idx = idx(:)';
end
end % nearestneighbour
%DELAUNAYTEST   Work out whether the combination of dimensions makes
%fastest to use a Delaunay triangulation in conjunction with dsearchn.
%These parameters have been determined empirically on a Pentium M 1.6G /
%WinXP / 512MB / Matlab R14SP3 platform. Their precision is not
%particularly important
function tf = delaunaytest(nx, np, dim)
switch dim
    case 2
        tf = np > min(1.5 * nx, 400);
    case 3
        tf = np > min(4 * nx  , 1200);
    case 4
        tf = np > min(40 * nx , 5000);
        % if the dimension is higher than 4, it is almost invariably better not
        % to try to use the Delaunay triangulation
    otherwise
        tf = false;
end % switch
end % delaunaytest
%MINN   find the n most negative elements in x, and return their indices
%  in ascending order
function I = minn(x, n)
% Make sure n is no larger than length(x)
n = min(n, length(x));
% Sort the first n
[xsn, I] = sort(x(1:n));
% Go through the rest of the entries, and insert them into the sorted block
% if they are negative enough
for i = (n+1):length(x)
    j = n;
    while j > 0 && x(i) < xsn(j)
        j = j - 1;
    end
    if j < n
        % x(i) should go into the (j+1) position
        xsn = [xsn(1:j), x(i), xsn((j+1):(n-1))];
        I   = [I(1:j), i, I((j+1):(n-1))];
    end
end
end %minn
%PARSEINPUTS    Support function for nearestneighbour
function [P, X, fIndexed, userParams] = parseinputs(userParams, varargin)
if length(varargin) == 1 || ~isnumeric(varargin{2})
    P           = varargin{1};
    X           = varargin{1};
    fIndexed    = true;
    varargin(1) = [];
else
    P             = varargin{1};
    X             = varargin{2};
    varargin(1:2) = [];
    % Check the dimensions of X and P
    if size(X, 1) ~= 1
        % Check to see whether P is in fact a vector of indices
        if size(P, 1) == 1
            try
                P = X(:, P);
            catch
                error('NearestNeighbour:InvalidIndexVector', ...
                    'Unable to index matrix using index vector');
            end
            fIndexed = true;
        else
            fIndexed = false;
        end % if size(P, 1) == 1
    else % if size(X, 1) ~= 1
        fIndexed = false;
    end
    if ~fIndexed && size(P, 1) ~= size(X, 1)
        error('NearestNeighbour:DimensionMismatch', ...
            'No. of rows of input arrays doesn''t match');
    end
end
% Parse the Property/Value pairs
if rem(length(varargin), 2) ~= 0
    error('NearestNeighbour:propertyValueNotPair', ...
        'Additional arguments must take the form of Property/Value pairs');
end
propertyNames = {'numberofneighbours', 'delaunaymode', 'triangulation', ...
    'radius'};
while length(varargin) ~= 0
    property = varargin{1};
    value    = varargin{2};
    % If the property has been supplied in a shortened form, lengthen it
    iProperty = find(strncmpi(property, propertyNames, length(property)));
    if isempty(iProperty)
        error('NearestNeighbour:InvalidProperty', 'Invalid Property');
    elseif length(iProperty) > 1
        error('NearestNeighbour:AmbiguousProperty', ...
            'Supplied shortened property name is ambiguous');
    end
    property = propertyNames{iProperty};
    switch property
        case 'numberofneighbours'
            if rem(value, 1) ~= 0 || ...
                    value > length(X) - double(fIndexed) || ...
                    value < 1
                error('NearestNeighbour:InvalidNumberOfNeighbours', ...
                    'Number of Neighbours must be an integer, and smaller than the no. of points in X');
            end
            userParams.NumberOfNeighbours = value;
        case 'delaunaymode'
            fOn = strcmpi(value, 'on');
            if strcmpi(value, 'off')
                userParams.DelaunayMode = 'off';
            elseif fOn || strcmpi(value, 'auto')
                if userParams.NumberOfNeighbours ~= 1
                    if fOn
                        warning('NearestNeighbour:TooMuchForDelaunay', ...
                            'Delaunay Triangulation method works only for one neighbour');
                    end
                    userParams.DelaunayMode = 'off';
                elseif size(X, 2) < size(X, 1) + 1
                    if fOn
                        warning('NearestNeighbour:TooFewDelaunayPoints', ...
                            'Insufficient points to compute Delaunay triangulation');
                    end
                    userParams.DelaunayMode = 'off';
                elseif size(X, 1) == 1
                    if fOn
                        warning('NearestNeighbour:DelaunayDimensionOne', ...
                            'Cannot compute Delaunay triangulation for 1D input');
                    end
                    userParams.DelaunayMode = 'off';
                else
                    userParams.DelaunayMode = value;
                end
            else
                warning('NearestNeighbour:InvalidOption', ...
                    'Invalid Option');
            end % if strcmpi(value, 'off')
        case 'radius'
            if isscalar(value) && isnumeric(value) && isreal(value) && value > 0
                userParams.Radius = value;
                if isempty(userParams.NumberOfNeighbours)
                    userParams.NumberOfNeighbours = size(X, 2) - double(fIndexed);
                end
            else
                error('NearestNeighbour:InvalidRadius', ...
                    'Radius must be a positive real number');
            end
    
        case 'triangulation'
            if isnumeric(value) && size(value, 2) == size(X, 1) + 1 && ...
                    all(ismember(1:size(X, 2), value))
                userParams.Triangulation = value;
            else
                error('NearestNeighbour:InvalidTriangulation', ...
                    'Triangulation not a valid Delaunay Triangulation');
            end
    end % switch property
    varargin(1:2) = [];
end % while
if isempty(userParams.NumberOfNeighbours)
    userParams.NumberOfNeighbours = 1;
end
end %parseinputs