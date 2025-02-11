function checkData = suspOpt_check_runValid_aToe(logsout_VehBus)
% suspOpt_check_runValid_aToe  Check if toe angles are acceptable
%   checkData = suspOpt_check_runValid_aToe(logsout_VehBus)
%   This function returns logical values indicating if tire toe angles
%   remain in an acceptable range.  An invalid result is returned if the
%   toe angle for either front tire exceeds a threshold for too long.
%
%   logsout_VehBus   Logged simulation results, one or multiple runs
%   
%   checkData        Structure containing simulation results used to assess validity
%                    and results of validity check for each run

% Copyright 2023-2024 The MathWorks, Inc.

% Thresholds for validity
toe_thresh = 0.1; % radians
toe_time   = 0.5; % sec

% Loop over runs
for run_i = 1:length(logsout_VehBus)
    % Extract toe angles
    logsout_aToeL = squeeze(logsout_VehBus(run_i).Values.Chassis.SuspA1.WhlL.aToe.Data);
    logsout_aToeR = squeeze(logsout_VehBus(run_i).Values.Chassis.SuspA1.WhlR.aToe.Data);
    logsout_t     = squeeze(logsout_VehBus(run_i).Values.Chassis.SuspA1.WhlR.aToe.Time);

    % Save simulation results for plotting
    checkData(run_i).t     = logsout_t;
    checkData(run_i).aToeL = logsout_aToeL;
    checkData(run_i).aToeR = logsout_aToeR;

    % Evaluate if toe angles exceed thresholds for too long
    toeLInvalid = hasExceededThreshold(abs(logsout_aToeL), logsout_t, toe_thresh, toe_time);
    toeRInvalid = hasExceededThreshold(abs(logsout_aToeR), logsout_t, toe_thresh, toe_time);

    % Result is invalid if either toe angle fails the criteria
    checkData(run_i).valid_aToe = ~(toeLInvalid && toeRInvalid);
end
