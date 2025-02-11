function descr = suspOpt_param_param2Desc(parTableVal,index)
% parTableVal_Param2Desc  Convert parameter name to descriptive label
%
% This function takes the parameter name and converts it to a descriptive
% label that can be used on an App.  The descriptive label will have some
% abbreviated terms in it that can be interpreted.

if(~isnumeric(index))
    % index is parameter label.  Determine location in table.
    index_label = index;
    index = find(strcmp(parTableVal.Label,index_label));
    if(isempty(index))
        error(['Label ' index_label ' not found in table of parameters.'])
    end
end

parLabel = parTableVal.Label{index};
parName  = parTableVal.Parameter{index};
parIndex = parTableVal.Index(index);

parName  = strrep(parName,'Vehicle.Chassis.','');
parName  = strrep(parName,'Linkage.','');
parName  = strrep(parName,'.Value','');
parName  = strrep(parName,'Axle1.','Axle 1, ');
parName  = strrep(parName,'Axle2.','Axle 2, ');

parName  = strrep(parName,'SuspA1.','Axle 1, ');
parName  = strrep(parName,'SuspA2.','Axle 2, ');
parName  = strrep(parName,'sInboardF','Inboard F, ');
parName  = strrep(parName,'sInboardR','Inboard R, ');
parName  = strrep(parName,'sInboard','Inboard, ');
parName  = strrep(parName,'sOutboard','Outboard, ');
parName  = strrep(parName,'sTop','Top, ');
parName  = strrep(parName,'sBottom','Bottom, ');
parName  = strrep(parName,'sCG','CG, ');
parName  = strrep(parName,'sWheelCentre','Whl Ctr, ');
parName  = strrep(parName,'Wishbone.',' Arm, ');
parName  = strrep(parName,'TrackRod.','Track Rod, ');
parName  = strrep(parName,'Upright.','Upright, ');
parName  = strrep(parName,'Shock.','Shock, ');

parName  = strrep(parName,'AntiRollBar.','ARB, ');
parName  = strrep(parName,'Endstop.','Endstop, ');

parName  = strrep(parName,'Damper.','');
parName  = strrep(parName,'Spring.','');

parName  = strrep(parName,'Damping.','Shock, ');
parName  = strrep(parName,'K.','Shock, ');

parName  = strrep(parName,', d',', Damping');

parName  = strrep(parName,'xMin','Min');
parName  = strrep(parName,'xMax','Max');

parName  = strrep(parName,'ARB, k','ARB, Stiffness');
parName  = strrep(parName,'Axle 1, K','Axle 1, Spring, Stiffness');
parName  = strrep(parName,'Axle 2, K','Axle 2, Spring, Stiffness');
index2axis = ['x', 'y', 'z'];

if(startsWith(parLabel,'HP'))
    parName    = [parName index2axis(parIndex)];
end

descr = parName;

