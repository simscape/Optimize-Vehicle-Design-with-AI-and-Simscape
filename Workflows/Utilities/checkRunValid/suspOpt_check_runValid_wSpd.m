function checkData = suspOpt_check_runValid_wSpd(logsout_VehBus,Vehicle)
% suspOpt_check_runValid_wSpd  Check if wheel speeds are acceptable
%   checkData = suspOpt_check_runValid_wSpd(Vehicle,logsout_VehBus,showplot)
%   This function returns logical values indicating if wheel speeds
%   remain in an acceptable range.  An invalid result is returned if the
%   wheel speed for any tire deviates from the chassis speed for too long.
%
%   logsout_VehBus   Logged simulation results, one or multiple runs
%   Vehicle          Vehicle data structure with parameters (has tire radius)
%   
%   checkData        Structure containing simulation results used to assess validity
%                    and results of validity check for each run

% Copyright 2023-2024 The MathWorks, Inc.

% Thresholds for validity
ws_thresh   = 40 ; % m/s
ws_duration = 0.5; % sec

% Get tire radius to convert wheel rotation speed to linear speed
[tire_radius, ~] = sm_car_vehcfg_getTireRadius(Vehicle);

% Find fields where wheel speeds are saved
chassis_log_fieldnames = fieldnames(logsout_VehBus(1).Values.Chassis);
whl_inds = find(startsWith(chassis_log_fieldnames,'Whl'));
whlnames = sort(chassis_log_fieldnames(whl_inds));

% Loop over runs
for run_i = 1:length(logsout_VehBus)

    % Calculate chassis speed
    logsout_vxVeh = logsout_VehBus(run_i).Values.World.vx;
    logsout_vyVeh = logsout_VehBus(run_i).Values.World.vy;
    logsout_sVeh  = sqrt(logsout_vxVeh.Data.^2+logsout_vyVeh.Data.^2);

    % Assume wheel speeds are accceptable (invalid = false)
    wsInvalid = zeros(1,length(whl_inds));
    % Loop over wheels
    for whl_i = 1:length(whl_inds)

        % Calculate deviation of wheel speed with chassis speed
        logsout_nWhl = logsout_VehBus(run_i).Values.Chassis.(whlnames{whl_i}).n;
        radius_ind   = str2num(whlnames{whl_i}(end));
        diffWS       = logsout_nWhl.Data*3.6*tire_radius(radius_ind)-logsout_sVeh*3.6;

        % Check if deviation is acceptable
        wsInvalid(whl_i) = hasExceededThreshold(abs(diffWS), logsout_vxVeh.Time, ws_thresh, ws_duration);

        % Save wheel speeds for plotting
        checkData(run_i).wSpd(:,whl_i) = logsout_nWhl.Data*3.6*tire_radius(radius_ind);
    end

    % Check if run is valid
    valid_wSpd = true;
    if(sum(wsInvalid)>0)
        % If any wheel speed fails criteria, test is invalid)
        valid_wSpd = false;
    end

    % Save simulation results for plotting
    checkData(run_i).t          = logsout_vxVeh.Time;
    checkData(run_i).vSpd       = logsout_sVeh*3.6;
    checkData(run_i).valid_wSpd = valid_wSpd;
end