%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desarrollado por | Developed by:                     %
% University Carlos III of Madrid PhD Researchers      %
% Daniel Amigo Herrero    mailto: damigo@inf.uc3m.es   %
% David Sanchez Pedroche  mailto: davsanch@inf.uc3m.es %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% All arrays are pre-allocated with the final length
MMSI                                = zeros(length(allFiles), 1);
FirstTimeConsecutive                = zeros(length(allFiles), 1);
FirstTimeManeuver                   = zeros(length(allFiles), 1);
TotalTime                           = zeros(length(allFiles), 1);
ClassShipType                       = strings([length(allFiles),1]);
ClassManeuver                       = strings([length(allFiles),1]);
shipWidth                           = zeros(length(allFiles), 1);
shipLength                          = zeros(length(allFiles), 1);
speedVariationTotalSum              = zeros(length(allFiles), 1);
speedTotalSum                       = zeros(length(allFiles), 1);
distanceTotalSum                    = zeros(length(allFiles), 1);
directionVariationTotalSum          = zeros(length(allFiles), 1);
timeGapTotalSum                     = zeros(length(allFiles), 1);
speedVariationHighMode1Sum          = zeros(length(allFiles), 1);
speedHighMode1Sum                   = zeros(length(allFiles), 1);
distanceHighMode1Sum                = zeros(length(allFiles), 1);
directionVariationHighMode1Sum      = zeros(length(allFiles), 1);
timeGapHighMode1Sum                 = zeros(length(allFiles), 1);
speedVariationLowMode1Sum           = zeros(length(allFiles), 1);
speedLowMode1Sum                    = zeros(length(allFiles), 1);
distanceLowMode1Sum                 = zeros(length(allFiles), 1);
directionVariationLowMode1Sum       = zeros(length(allFiles), 1);
timeGapLowMode1Sum                  = zeros(length(allFiles), 1);
speedVariationSwitchingModeSum      = zeros(length(allFiles), 1);
speedSwitchingModeSum               = zeros(length(allFiles), 1);
distanceSwitchingModeSum            = zeros(length(allFiles), 1);
directionVariationSwitchingModeSum  = zeros(length(allFiles), 1);
timeGapSwitchingModeSum             = zeros(length(allFiles), 1);
speedVariationLowMode2Sum           = zeros(length(allFiles), 1);
speedLowMode2Sum                    = zeros(length(allFiles), 1);
distanceLowMode2Sum                 = zeros(length(allFiles), 1);
directionVariationLowMode2Sum       = zeros(length(allFiles), 1);
timeGapLowMode2Sum                  = zeros(length(allFiles), 1);
speedVariationHighMode2Sum          = zeros(length(allFiles), 1);
speedHighMode2Sum                   = zeros(length(allFiles), 1);
distanceHighMode2Sum                = zeros(length(allFiles), 1);
directionVariationHighMode2Sum      = zeros(length(allFiles), 1);
timeGapHighMode2Sum                 = zeros(length(allFiles), 1);
speedVariationTotalMax              = zeros(length(allFiles), 1);
speedTotalMax                       = zeros(length(allFiles), 1);
distanceTotalMax                    = zeros(length(allFiles), 1);
directionVariationTotalMax          = zeros(length(allFiles), 1);
timeGapTotalMax                     = zeros(length(allFiles), 1);
speedVariationHighMode1Max          = zeros(length(allFiles), 1);
speedHighMode1Max                   = zeros(length(allFiles), 1);
distanceHighMode1Max                = zeros(length(allFiles), 1);
directionVariationHighMode1Max      = zeros(length(allFiles), 1);
timeGapHighMode1Max                 = zeros(length(allFiles), 1);
speedVariationLowMode1Max           = zeros(length(allFiles), 1);
speedLowMode1Max                    = zeros(length(allFiles), 1);
distanceLowMode1Max                 = zeros(length(allFiles), 1);
directionVariationLowMode1Max       = zeros(length(allFiles), 1);
timeGapLowMode1Max                  = zeros(length(allFiles), 1);
speedVariationSwitchingModeMax      = zeros(length(allFiles), 1);
speedSwitchingModeMax               = zeros(length(allFiles), 1);
distanceSwitchingModeMax            = zeros(length(allFiles), 1);
directionVariationSwitchingModeMax  = zeros(length(allFiles), 1);
timeGapSwitchingModeMax             = zeros(length(allFiles), 1);
speedVariationLowMode2Max           = zeros(length(allFiles), 1);
speedLowMode2Max                    = zeros(length(allFiles), 1);
distanceLowMode2Max                 = zeros(length(allFiles), 1);
directionVariationLowMode2Max       = zeros(length(allFiles), 1);
timeGapLowMode2Max                  = zeros(length(allFiles), 1);
speedVariationHighMode2Max          = zeros(length(allFiles), 1);
speedHighMode2Max                   = zeros(length(allFiles), 1);
distanceHighMode2Max                = zeros(length(allFiles), 1);
directionVariationHighMode2Max      = zeros(length(allFiles), 1);
timeGapHighMode2Max                 = zeros(length(allFiles), 1);
speedVariationTotalMin              = zeros(length(allFiles), 1);
speedTotalMin                       = zeros(length(allFiles), 1);
distanceTotalMin                    = zeros(length(allFiles), 1);
directionVariationTotalMin          = zeros(length(allFiles), 1);
timeGapTotalMin                     = zeros(length(allFiles), 1);
speedVariationHighMode1Min          = zeros(length(allFiles), 1);
speedHighMode1Min                   = zeros(length(allFiles), 1);
distanceHighMode1Min                = zeros(length(allFiles), 1);
directionVariationHighMode1Min      = zeros(length(allFiles), 1);
timeGapHighMode1Min                 = zeros(length(allFiles), 1);
speedVariationLowMode1Min           = zeros(length(allFiles), 1);
speedLowMode1Min                    = zeros(length(allFiles), 1);
distanceLowMode1Min                 = zeros(length(allFiles), 1);
directionVariationLowMode1Min       = zeros(length(allFiles), 1);
timeGapLowMode1Min                  = zeros(length(allFiles), 1);
speedVariationSwitchingModeMin      = zeros(length(allFiles), 1);
speedSwitchingModeMin               = zeros(length(allFiles), 1);
distanceSwitchingModeMin            = zeros(length(allFiles), 1);
directionVariationSwitchingModeMin  = zeros(length(allFiles), 1);
timeGapSwitchingModeMin             = zeros(length(allFiles), 1);
speedVariationLowMode2Min           = zeros(length(allFiles), 1);
speedLowMode2Min                    = zeros(length(allFiles), 1);
distanceLowMode2Min                 = zeros(length(allFiles), 1);
directionVariationLowMode2Min       = zeros(length(allFiles), 1);
timeGapLowMode2Min                  = zeros(length(allFiles), 1);
speedVariationHighMode2Min          = zeros(length(allFiles), 1);
speedHighMode2Min                   = zeros(length(allFiles), 1);
distanceHighMode2Min                = zeros(length(allFiles), 1);
directionVariationHighMode2Min      = zeros(length(allFiles), 1);
timeGapHighMode2Min                 = zeros(length(allFiles), 1);
speedVariationTotalMean             = zeros(length(allFiles), 1);
speedTotalMean                      = zeros(length(allFiles), 1);
distanceTotalMean                   = zeros(length(allFiles), 1);
directionVariationTotalMean         = zeros(length(allFiles), 1);
timeGapTotalMean                    = zeros(length(allFiles), 1);
speedVariationHighMode1Mean         = zeros(length(allFiles), 1);
speedHighMode1Mean                  = zeros(length(allFiles), 1);
distanceHighMode1Mean               = zeros(length(allFiles), 1);
directionVariationHighMode1Mean     = zeros(length(allFiles), 1);
timeGapHighMode1Mean                = zeros(length(allFiles), 1);
speedVariationLowMode1Mean          = zeros(length(allFiles), 1);
speedLowMode1Mean                   = zeros(length(allFiles), 1);
distanceLowMode1Mean                = zeros(length(allFiles), 1);
directionVariationLowMode1Mean      = zeros(length(allFiles), 1);
timeGapLowMode1Mean                 = zeros(length(allFiles), 1);
speedVariationSwitchingModeMean     = zeros(length(allFiles), 1);
speedSwitchingModeMean              = zeros(length(allFiles), 1);
distanceSwitchingModeMean           = zeros(length(allFiles), 1);
directionVariationSwitchingModeMean = zeros(length(allFiles), 1);
timeGapSwitchingModeMean            = zeros(length(allFiles), 1);
speedVariationLowMode2Mean          = zeros(length(allFiles), 1);
speedLowMode2Mean                   = zeros(length(allFiles), 1);
distanceLowMode2Mean                = zeros(length(allFiles), 1);
directionVariationLowMode2Mean      = zeros(length(allFiles), 1);
timeGapLowMode2Mean                 = zeros(length(allFiles), 1);
speedVariationHighMode2Mean         = zeros(length(allFiles), 1);
speedHighMode2Mean                  = zeros(length(allFiles), 1);
distanceHighMode2Mean               = zeros(length(allFiles), 1);
directionVariationHighMode2Mean     = zeros(length(allFiles), 1);
timeGapHighMode2Mean                = zeros(length(allFiles), 1);
speedVariationTotalStd              = zeros(length(allFiles), 1);
speedTotalStd                       = zeros(length(allFiles), 1);
distanceTotalStd                    = zeros(length(allFiles), 1);
directionVariationTotalStd          = zeros(length(allFiles), 1);
timeGapTotalStd                     = zeros(length(allFiles), 1);
speedVariationHighMode1Std          = zeros(length(allFiles), 1);
speedHighMode1Std                   = zeros(length(allFiles), 1);
distanceHighMode1Std                = zeros(length(allFiles), 1);
directionVariationHighMode1Std      = zeros(length(allFiles), 1);
timeGapHighMode1Std                 = zeros(length(allFiles), 1);
speedVariationLowMode1Std           = zeros(length(allFiles), 1);
speedLowMode1Std                    = zeros(length(allFiles), 1);
distanceLowMode1Std                 = zeros(length(allFiles), 1);
directionVariationLowMode1Std       = zeros(length(allFiles), 1);
timeGapLowMode1Std                  = zeros(length(allFiles), 1);
speedVariationSwitchingModeStd      = zeros(length(allFiles), 1);
speedSwitchingModeStd               = zeros(length(allFiles), 1);
distanceSwitchingModeStd            = zeros(length(allFiles), 1);
directionVariationSwitchingModeStd  = zeros(length(allFiles), 1);
timeGapSwitchingModeStd             = zeros(length(allFiles), 1);
speedVariationLowMode2Std           = zeros(length(allFiles), 1);
speedLowMode2Std                    = zeros(length(allFiles), 1);
distanceLowMode2Std                 = zeros(length(allFiles), 1);
directionVariationLowMode2Std       = zeros(length(allFiles), 1);
timeGapLowMode2Std                  = zeros(length(allFiles), 1);
speedVariationHighMode2Std          = zeros(length(allFiles), 1);
speedHighMode2Std                   = zeros(length(allFiles), 1);
distanceHighMode2Std                = zeros(length(allFiles), 1);
directionVariationHighMode2Std      = zeros(length(allFiles), 1);
timeGapHighMode2Std                 = zeros(length(allFiles), 1);
speedVariationTotalMode             = zeros(length(allFiles), 1);
speedTotalMode                      = zeros(length(allFiles), 1);
distanceTotalMode                   = zeros(length(allFiles), 1);
directionVariationTotalMode         = zeros(length(allFiles), 1);
timeGapTotalMode                    = zeros(length(allFiles), 1);
speedVariationHighMode1Mode         = zeros(length(allFiles), 1);
speedHighMode1Mode                  = zeros(length(allFiles), 1);
distanceHighMode1Mode               = zeros(length(allFiles), 1);
directionVariationHighMode1Mode     = zeros(length(allFiles), 1);
timeGapHighMode1Mode                = zeros(length(allFiles), 1);
speedVariationLowMode1Mode          = zeros(length(allFiles), 1);
speedLowMode1Mode                   = zeros(length(allFiles), 1);
distanceLowMode1Mode                = zeros(length(allFiles), 1);
directionVariationLowMode1Mode      = zeros(length(allFiles), 1);
timeGapLowMode1Mode                 = zeros(length(allFiles), 1);
speedVariationSwitchingModeMode     = zeros(length(allFiles), 1);
speedSwitchingModeMode              = zeros(length(allFiles), 1);
distanceSwitchingModeMode           = zeros(length(allFiles), 1);
directionVariationSwitchingModeMode = zeros(length(allFiles), 1);
timeGapSwitchingModeMode            = zeros(length(allFiles), 1);
speedVariationLowMode2Mode          = zeros(length(allFiles), 1);
speedLowMode2Mode                   = zeros(length(allFiles), 1);
distanceLowMode2Mode                = zeros(length(allFiles), 1);
directionVariationLowMode2Mode      = zeros(length(allFiles), 1);
timeGapLowMode2Mode                 = zeros(length(allFiles), 1);
speedVariationHighMode2Mode         = zeros(length(allFiles), 1);
speedHighMode2Mode                  = zeros(length(allFiles), 1);
distanceHighMode2Mode               = zeros(length(allFiles), 1);
directionVariationHighMode2Mode     = zeros(length(allFiles), 1);
timeGapHighMode2Mode                = zeros(length(allFiles), 1);
speedVariationTotalQ1               = zeros(length(allFiles), 1);
speedTotalQ1                        = zeros(length(allFiles), 1);
distanceTotalQ1                     = zeros(length(allFiles), 1);
directionVariationTotalQ1           = zeros(length(allFiles), 1);
timeGapTotalQ1                      = zeros(length(allFiles), 1);
speedVariationHighMode1Q1           = zeros(length(allFiles), 1);
speedHighMode1Q1                    = zeros(length(allFiles), 1);
distanceHighMode1Q1                 = zeros(length(allFiles), 1);
directionVariationHighMode1Q1       = zeros(length(allFiles), 1);
timeGapHighMode1Q1                  = zeros(length(allFiles), 1);
speedVariationLowMode1Q1            = zeros(length(allFiles), 1);
speedLowMode1Q1                     = zeros(length(allFiles), 1);
distanceLowMode1Q1                  = zeros(length(allFiles), 1);
directionVariationLowMode1Q1        = zeros(length(allFiles), 1);
timeGapLowMode1Q1                   = zeros(length(allFiles), 1);
speedVariationSwitchingModeQ1       = zeros(length(allFiles), 1);
speedSwitchingModeQ1                = zeros(length(allFiles), 1);
distanceSwitchingModeQ1             = zeros(length(allFiles), 1);
directionVariationSwitchingModeQ1   = zeros(length(allFiles), 1);
timeGapSwitchingModeQ1              = zeros(length(allFiles), 1);
speedVariationLowMode2Q1            = zeros(length(allFiles), 1);
speedLowMode2Q1                     = zeros(length(allFiles), 1);
distanceLowMode2Q1                  = zeros(length(allFiles), 1);
directionVariationLowMode2Q1        = zeros(length(allFiles), 1);
timeGapLowMode2Q1                   = zeros(length(allFiles), 1);
speedVariationHighMode2Q1           = zeros(length(allFiles), 1);
speedHighMode2Q1                    = zeros(length(allFiles), 1);
distanceHighMode2Q1                 = zeros(length(allFiles), 1);
directionVariationHighMode2Q1       = zeros(length(allFiles), 1);
timeGapHighMode2Q1                  = zeros(length(allFiles), 1);
speedVariationTotalQ2               = zeros(length(allFiles), 1);
speedTotalQ2                        = zeros(length(allFiles), 1);
distanceTotalQ2                     = zeros(length(allFiles), 1);
directionVariationTotalQ2           = zeros(length(allFiles), 1);
timeGapTotalQ2                      = zeros(length(allFiles), 1);
speedVariationHighMode1Q2           = zeros(length(allFiles), 1);
speedHighMode1Q2                    = zeros(length(allFiles), 1);
distanceHighMode1Q2                 = zeros(length(allFiles), 1);
directionVariationHighMode1Q2       = zeros(length(allFiles), 1);
timeGapHighMode1Q2                  = zeros(length(allFiles), 1);
speedVariationLowMode1Q2            = zeros(length(allFiles), 1);
speedLowMode1Q2                     = zeros(length(allFiles), 1);
distanceLowMode1Q2                  = zeros(length(allFiles), 1);
directionVariationLowMode1Q2        = zeros(length(allFiles), 1);
timeGapLowMode1Q2                   = zeros(length(allFiles), 1);
speedVariationSwitchingModeQ2       = zeros(length(allFiles), 1);
speedSwitchingModeQ2                = zeros(length(allFiles), 1);
distanceSwitchingModeQ2             = zeros(length(allFiles), 1);
directionVariationSwitchingModeQ2   = zeros(length(allFiles), 1);
timeGapSwitchingModeQ2              = zeros(length(allFiles), 1);
speedVariationLowMode2Q2            = zeros(length(allFiles), 1);
speedLowMode2Q2                     = zeros(length(allFiles), 1);
distanceLowMode2Q2                  = zeros(length(allFiles), 1);
directionVariationLowMode2Q2        = zeros(length(allFiles), 1);
timeGapLowMode2Q2                   = zeros(length(allFiles), 1);
speedVariationHighMode2Q2           = zeros(length(allFiles), 1);
speedHighMode2Q2                    = zeros(length(allFiles), 1);
distanceHighMode2Q2                 = zeros(length(allFiles), 1);
directionVariationHighMode2Q2       = zeros(length(allFiles), 1);
timeGapHighMode2Q2                  = zeros(length(allFiles), 1);
speedVariationTotalQ3               = zeros(length(allFiles), 1);
speedTotalQ3                        = zeros(length(allFiles), 1);
distanceTotalQ3                     = zeros(length(allFiles), 1);
directionVariationTotalQ3           = zeros(length(allFiles), 1);
timeGapTotalQ3                      = zeros(length(allFiles), 1);
speedVariationHighMode1Q3           = zeros(length(allFiles), 1);
speedHighMode1Q3                    = zeros(length(allFiles), 1);
distanceHighMode1Q3                 = zeros(length(allFiles), 1);
directionVariationHighMode1Q3       = zeros(length(allFiles), 1);
timeGapHighMode1Q3                  = zeros(length(allFiles), 1);
speedVariationLowMode1Q3            = zeros(length(allFiles), 1);
speedLowMode1Q3                     = zeros(length(allFiles), 1);
distanceLowMode1Q3                  = zeros(length(allFiles), 1);
directionVariationLowMode1Q3        = zeros(length(allFiles), 1);
timeGapLowMode1Q3                   = zeros(length(allFiles), 1);
speedVariationSwitchingModeQ3       = zeros(length(allFiles), 1);
speedSwitchingModeQ3                = zeros(length(allFiles), 1);
distanceSwitchingModeQ3             = zeros(length(allFiles), 1);
directionVariationSwitchingModeQ3   = zeros(length(allFiles), 1);
timeGapSwitchingModeQ3              = zeros(length(allFiles), 1);
speedVariationLowMode2Q3            = zeros(length(allFiles), 1);
speedLowMode2Q3                     = zeros(length(allFiles), 1);
distanceLowMode2Q3                  = zeros(length(allFiles), 1);
directionVariationLowMode2Q3        = zeros(length(allFiles), 1);
timeGapLowMode2Q3                   = zeros(length(allFiles), 1);
speedVariationHighMode2Q3           = zeros(length(allFiles), 1);
speedHighMode2Q3                    = zeros(length(allFiles), 1);
distanceHighMode2Q3                 = zeros(length(allFiles), 1);
directionVariationHighMode2Q3       = zeros(length(allFiles), 1);
timeGapHighMode2Q3                  = zeros(length(allFiles), 1);
continueSameMode                    = zeros(length(allFiles), 1);
HighMode1Out                        = zeros(length(allFiles), 1);
LowMode1Out                         = zeros(length(allFiles), 1);
SwitchingModeOut                    = zeros(length(allFiles), 1);
LowMode2Out                         = zeros(length(allFiles), 1);
HighMode2Out                        = zeros(length(allFiles), 1);
HighMode1In                         = zeros(length(allFiles), 1);
LowMode1In                          = zeros(length(allFiles), 1);
SwitchingModeIn                     = zeros(length(allFiles), 1);
LowMode2In                          = zeros(length(allFiles), 1);
HighMode2In                         = zeros(length(allFiles), 1);
HighMode1InPlusContinue             = zeros(length(allFiles), 1);
LowMode1InPlusContinue              = zeros(length(allFiles), 1);
SwitchingModeInPlusContinue         = zeros(length(allFiles), 1);
LowMode2InPlusContinue              = zeros(length(allFiles), 1);
HighMode2InPlusContinue             = zeros(length(allFiles), 1);
HighMode1AHighMode1                 = zeros(length(allFiles), 1);
HighMode1ALowMode1                  = zeros(length(allFiles), 1);
HighMode1ASwitchingMode             = zeros(length(allFiles), 1);
HighMode1AHighMode2                 = zeros(length(allFiles), 1);
HighMode1ALowMode2                  = zeros(length(allFiles), 1);
LowMode1AHighMode1                  = zeros(length(allFiles), 1);
LowMode1ALowMode1                   = zeros(length(allFiles), 1);
LowMode1ASwitchingMode              = zeros(length(allFiles), 1);
LowMode1AHighMode2                  = zeros(length(allFiles), 1);
LowMode1ALowMode2                   = zeros(length(allFiles), 1);
SwitchingModeAHighMode1             = zeros(length(allFiles), 1);
SwitchingModeALowMode1              = zeros(length(allFiles), 1);
SwitchingModeASwitchingMode         = zeros(length(allFiles), 1);
SwitchingModeAHighMode2             = zeros(length(allFiles), 1);
SwitchingModeALowMode2              = zeros(length(allFiles), 1);
HighMode2AHighMode1                 = zeros(length(allFiles), 1);
HighMode2ALowMode1                  = zeros(length(allFiles), 1);
HighMode2ASwitchingMode             = zeros(length(allFiles), 1);
HighMode2AHighMode2                 = zeros(length(allFiles), 1);
HighMode2ALowMode2                  = zeros(length(allFiles), 1);
LowMode2AHighMode1                  = zeros(length(allFiles), 1);
LowMode2ALowMode1                   = zeros(length(allFiles), 1);
LowMode2ASwitchingMode              = zeros(length(allFiles), 1);
LowMode2AHighMode2                  = zeros(length(allFiles), 1);
LowMode2ALowMode2                   = zeros(length(allFiles), 1);