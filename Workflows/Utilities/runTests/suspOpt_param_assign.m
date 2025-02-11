function Vehicle = suspOpt_param_assign(parTableVal,index,value,Vehicle_in)
% suspOpt_param_assign  Assign provided value to field in Vehicle data structure
%   Vehicle = suspOpt_param_assign(parTableVal,index,value,Vehicle_in)
%   This function assigns a new value to the correct field within the Vehicle data
%   structure. It also ensures that value which appear in multiple places
%   are updated accordingly.
%
%   parTableVal     Table of suspension parameters
%   index           Row of parTableVal where parameter is specified
%                   OR label associated with parameter whose value is provided.
%   value           New value to be assigned to parameter listed in row index
%   Vehicle_in      Vehicle data structure to be modified

% Assign input structure to output
Vehicle = Vehicle_in;

if(~isnumeric(index))
    % index is parameter label.  Determine location in table.
    index_label = index;
    index = find(strcmp(parTableVal.Label,index_label));
    if(isempty(index))
        error(['Label ' index_label ' not found in table of parameters.'])
    end
end

% Get parameter label, name, and index of value within parameter
parLabel = parTableVal.Label{index};
parName  = parTableVal.Parameter{index};
parIndex = parTableVal.Index(index);

% Form and eval a string to assign new value within Vehicle data structure
parSetStr = [parName '(' num2str(parIndex) ') = ' num2str(value) ';']; 
%disp(parSetStr)
eval(parSetStr)

% Some values appear multiple times in the Vehicle data structure
% Those values are only entered once in the table above
% but must be modified in multiple locations within Vehicle.

% Check label to see if parameter should be modified in 2 places
if(startsWith(parLabel,'HP_A1_Sh_Top'))
    Vehicle.Chassis.Spring.Axle1.sTop.Value = ...
        Vehicle.Chassis.SuspA1.Linkage.Shock.sTop.Value;
end
if(startsWith(parLabel,'HP_A1_Sh_Bot'))
    Vehicle.Chassis.Spring.Axle1.sBottom.Value = ...
        Vehicle.Chassis.SuspA1.Linkage.Shock.sBottom.Value;
end
if(startsWith(parLabel,'HP_A1_Ro_Inb'))
    Vehicle.Chassis.SuspA1.Steer.Rack.sOutboard.Value = ...
        Vehicle.Chassis.SuspA1.Linkage.TrackRod.sInboard.Value;
end
if(startsWith(parLabel,'HP_A2_Sh_Top'))
    Vehicle.Chassis.Spring.Axle2.sTop.Value = ...
        Vehicle.Chassis.SuspA2.Linkage.Shock.sTop.Value;
end
if(startsWith(parLabel,'HP_A2_Sh_Bot'))
    Vehicle.Chassis.Spring.Axle2.sBottom.Value = ...
        Vehicle.Chassis.SuspA2.Linkage.Shock.sTop.Value;
end
if(startsWith(parLabel,'HP_A2_Ro_Inb'))
    Vehicle.Chassis.SuspA2.Steer.Rack.sOutboard.Value = ...
        Vehicle.Chassis.SuspA2.Linkage.TrackRod.sInboard.Value;
end
