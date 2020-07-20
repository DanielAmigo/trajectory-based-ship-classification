%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desarrollado por | Developed by:                     %
% University Carlos III of Madrid PhD Researchers      %
% Daniel Amigo Herrero    mailto: damigo@inf.uc3m.es   %
% David Sanchez Pedroche  mailto: davsanch@inf.uc3m.es %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Script que recibe una serie de parametros, y crea clases auxiliares del problema general.
%  receives a series of parameters, and creates auxiliary classes of the general problem.
function [ClassesTable] = createAuxClasses(ClassesTable, binaryClassesShipType, binaryClassesManeuver)

% Add the binary classes of ship type
BinaryEntriesShipType = zeros( length(binaryClassesShipType)-1, height(ClassesTable));
for i=1:length(binaryClassesShipType)
    isClass = strcat("is", binaryClassesShipType(i));                                   % isCargo, is...
    ClassesTable.(isClass) = zeros( height(ClassesTable), 1 );                          % A new class is added to the class table
    if i == length(binaryClassesShipType)                                               % The last one is "other"
        ClassesTable.(isClass) = transpose(sum(BinaryEntriesShipType)) == false;        % Put the ones that are 0 in the sum as 1
    else
        BinaryEntriesShipType(i,:) = ismember(ClassesTable.ClassShiptype, binaryClassesShipType(i));
        ClassesTable.(isClass) = transpose(BinaryEntriesShipType(i,:));
    end
end

% The same process for the maneuver type
BinaryEntriesManeuver = zeros( length(binaryClassesManeuver)-1, height(ClassesTable));
for i=1:length(binaryClassesManeuver)
    isClass = strcat("is", binaryClassesManeuver(i));                                   
    ClassesTable.(isClass) = zeros( height(ClassesTable), 1 );                          
    if i == length(binaryClassesManeuver)                                               
        ClassesTable.(isClass) = transpose(sum(BinaryEntriesManeuver)) == false;        
    else
        BinaryEntriesManeuver(i,:) = ismember(ClassesTable.ClassShiptype, binaryClassesManeuver(i));
        ClassesTable.(isClass) = transpose(BinaryEntriesManeuver(i,:));
    end
end

% Multi-class combinations are created by merging in Other
allClassesToLessClasses{1} = [...  % The ship types are identified and what class to put them in
    ["Anti-pollution",   "OtherShip"];
    ["Cargo",            "Cargo"];
    ["Diving",           "OtherShip"];
    ["Dredging",         "OtherShip"];
    ["Fishing",          "Fishing"];
    ["HSC",              "OtherShip"];
    ["Law enforcement",  "OtherShip"];
    ["Military",         "OtherShip"];
    ["Other",            "OtherShip"];
    ["Passenger",        "Passenger"];
    ["Pilot",            "OtherShip"];
    ["Pleasure",         "OtherShip"];
    ["Port tender",      "OtherShip"];
    ["Reserved",         "OtherShip"];
    ["SAR",              "OtherShip"];
    ["Sailing",          "OtherShip"];
    ["Spare 1",          "OtherShip"];
    ["Spare 2",          "OtherShip"];
    ["Tanker",           "Tanker"];
    ["Towing",           "OtherShip"];
    ["Towing long/wide", "OtherShip"];
    ["Tug",              "OtherShip"];
    ["WIG",              "OtherShip"]];

allClassesToLessClasses{2} = [...
    ["Anti-pollution",   "OtherShip"];
    ["Cargo",            "Transporter"];
    ["Diving",           "OtherShip"];
    ["Dredging",         "OtherShip"];
    ["Fishing",          "Fishing"];
    ["HSC",              "OtherShip"];
    ["Law enforcement",  "OtherShip"];
    ["Military",         "OtherShip"];
    ["Other",            "OtherShip"];
    ["Passenger",        "Passenger"];
    ["Pilot",            "OtherShip"];
    ["Pleasure",         "OtherShip"];
    ["Port tender",      "OtherShip"];
    ["Reserved",         "OtherShip"];
    ["SAR",              "OtherShip"];
    ["Sailing",          "Sailing"];
    ["Spare 1",          "OtherShip"];
    ["Spare 2",          "OtherShip"];
    ["Tanker",           "Transporter"];
    ["Towing",           "OtherShip"];
    ["Towing long/wide", "OtherShip"];
    ["Tug",              "OtherShip"];
    ["WIG",              "OtherShip"]];

allClassesToLessClasses{3} = [... 
    ["At anchor",                           "OtherManeuver"];
    ["Constrained by her draught",          "OtherManeuver"];
    ["Engaged in fishing",                  "EngagedFishing"];
    ["Moored",                              "OtherManeuver"];
    ["Not under command",                   "OtherManeuver"];
    ["Reserved for future amendment [HSC]", "OtherManeuver"];
    ["Reserved for future use [11]",        "OtherManeuver"];
    ["Restricted maneuverability",          "Restricted"];
    ["Under way sailing",                   "Sailing"];
    ["Under way using engine",              "Engine"];];

% to check that the loop is OK
classForThisOne = ["ClassShiptype", "ClassShiptype", "ClassManeuver"]; % ClassShiptype, ClassManeuver
nameForThisOne  = ["isClassShiptype4Major", "isClassShiptype5Major", "isClassManeuver4Major"];
otherForThisOne  = ["OtherShip", "OtherShip", "OtherManeuver"];

for k=1:length(classForThisOne)
    sumIdx = 0;
    for i=1:length(allClassesToLessClasses{k})
        
        % For each entry, find out which position on the table this class has
        idx = find(ismember(ClassesTable.(classForThisOne(k)), allClassesToLessClasses{k}(i,1)));
        sumIdx = sumIdx + length(idx);                                                          %  Counting in case one is missing
        ClassesTable.(nameForThisOne(k))(idx) = allClassesToLessClasses{k}(i,2);
    end
    if sumIdx ~= height(ClassesTable) % missing ones are put on Other
        idx = find(ismissing(ClassesTable.(nameForThisOne(k))));
        ClassesTable.(nameForThisOne(k))(idx) = otherForThisOne(k);
    end
end


end % END FUNCTION