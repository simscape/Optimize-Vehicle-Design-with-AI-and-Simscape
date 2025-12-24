function sm_car_config_camera
% Copyright 2018-2025 The MathWorks, Inc.

veh_config = evalin('base','Vehicle.config');
veh_config_set = strsplit(veh_config,'_');
veh_body =  veh_config_set{1};

veh_body = strrep(veh_body,'HambaLG','Hamba');
veh_body = strrep(veh_body,'Makhulu3Axle','Makhulu');
veh_body = strrep(veh_body,'Amandla3Axle','Amandla');


camera_str = ['Camera = CDatabase.Camera.' strrep(veh_body,'HambaLG','Hamba') ';'];
evalin('base',camera_str)

try
    Visual = evalin('base','Visual');
catch
    Visual = [];
end

if (isempty(Visual))
    if strcmpi(veh_body,'achilles')
        Visual = sm_car_param_visual('fsae');
    else
        Visual = sm_car_param_visual('default');
    end
    assignin('base','Visual',Visual);
end
