function parTableVal = suspOpt_param_rangeAbsolute(parTableRel)
% suspOpt_param_rangeAbsolute   Update table of suspension parameters to have minimum and maximum values
%   This function takes a table that has offset values for hardpoints and
%   adjusts the "Min" and "Max" columns to have the actual minimum and
%   maximum values.  It adds the provided value to the default.

parTableVal = parTableRel;

% Loop over all parameters
for p_i = 1:size(parTableVal,1)
    % Load default values
    Vehicle_data;
    Vehicle = sm_car_vehcfg_checkConfig(Vehicle);

    % Obtain default value (index needed for vector with [x y z])
    defaultVal         = eval(parTableVal.Parameter{p_i});
    parTableVal.Default(p_i) = defaultVal(parTableRel.Index(p_i));

    % Assemble string to adjust parameter value
    if(startsWith(parTableRel.Label{p_i},'HP'))
        % Labels starting with "HP" are hardpoints with 3 values (x, y, z)
        % Parameter values are offsets to be *added* to the default value
        % Add default value at index provided in that row to provided
        % minimum value in that row.  Repeat for Max value.
        parTableVal.Min(p_i)     = defaultVal(parTableRel.Index(p_i))+parTableRel.Min(p_i);
        parTableVal.Max(p_i)     = defaultVal(parTableRel.Index(p_i))+parTableRel.Max(p_i);
    end
end
