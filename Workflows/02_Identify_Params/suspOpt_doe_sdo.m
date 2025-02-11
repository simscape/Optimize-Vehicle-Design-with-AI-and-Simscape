function runTable = suspOpt_doe_sdo(nSamples,sampleMethod)

% Generate parameter combinations using sdo.sample
%modelName = 'sm_car_dlc_only';
setup_sm_car_model

% Create table with *relative* min and max for HPs, min and max for scalars
parTableRel = suspOpt_param_rangeRelative;
% Convert table to have min and max for all values
% Suitable for DOE and sensitivity analysis
parTableVal = suspOpt_param_rangeAbsolute(parTableRel);

% Extract parameter name and parameter index
paramName = parTableVal.Parameter;
paramIndex = parTableVal.Index;

% Concatenate parameter name with index to extract from the model
paramList = strcat(paramName,'(' ,string(paramIndex),')');

% Get design parameters from the model 
SDOParams = sdo.getParameterFromModel(mdl, paramList);

% Set default values and ranges for the design parameters as defined in 'parTableRel'
for i = 1:size(parTableVal,1)
    SDOParams(i).Value   = parTableVal.Default(i);
    SDOParams(i).Minimum = parTableVal.Min(i);
    SDOParams(i).Maximum = parTableVal.Max(i);
end

% Specify probability distributions for model parameters
SDOparamSpace = sdo.ParameterSpace(SDOParams); % uniform distribution is assigned for each parameter by default

% Generate samples (parameter combinations)
SDOnumSamples = nSamples;
SDOsampleOpt = sdo.SampleOptions;
SDOsampleOpt.Method = sampleMethod; % Specify the sampling method as Sobol, can change it to 'lhs' or 'random' if requried
if(strcmp(sampleMethod,'sobol'))
    SDOsampleOpt.MethodOptions.Skip = 0;
end

% SDOparamSamples is the table containing parameter combinations for the sweep
SDOparamSamples = sdo.sample(SDOparamSpace,SDOnumSamples,SDOsampleOpt); % generate samples 

% Return table suitable for use with parsim
runTable = SDOparamSamples;
runTable.Properties.VariableNames = parTableVal.Label';
