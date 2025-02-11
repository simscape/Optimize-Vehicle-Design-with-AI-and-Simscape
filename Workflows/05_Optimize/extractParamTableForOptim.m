% extractParamTableOptim.m
%
% Extract relevant data from parameter table (parTableVal_trim) to define
% the optimization design space variables, bounds, and default values.

% Identify indices for the subset of parameters inluded in the DoE and AI
% modeling.  These parameters will be used as design/optimization variables
useIdx = parTableVal_trim.Use;

% Determine number of design variables
nDesignVars = nnz(useIdx);

% Extract the design variable names
paramNamesAll = parTableVal_trim.Label;
designVarNames = paramNamesAll(useIdx);

% Extract the lower and upper bounds for the design variables
designVarsMin = parTableVal_trim.Min(useIdx)';
designVarsMax = parTableVal_trim.Max(useIdx)';
designVarsMinTable = array2table(designVarsMin,'VariableNames',parTableVal_trim.Label(useIdx));
designVarsMaxTable = array2table(designVarsMax,'VariableNames',parTableVal_trim.Label(useIdx));

% Extract the default values for the design variables
designVarsDef      = parTableVal_trim.Default(useIdx)';
designVarsDefTable = array2table(designVarsDef,'VariableNames',parTableVal_trim.Label(useIdx));

% Extract the default values for full set of parameters, including those
% not used as design variables
paramsAllDef = array2table(parTableVal_trim.Default','VariableNames',parTableVal_trim.Label);