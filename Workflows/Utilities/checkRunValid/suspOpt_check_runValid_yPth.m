function checkData = suspOpt_check_runValid_yPth(logsout_DrvBus)
% suspOpt_check_runValid_yPth  Check if vehicle path is acceptable
%   checkData = suspOpt_check_runValid_yPth(logsout_DrvBus)
%   This function returns logical values indicating if the path followed by
%   the vehicle is acceptable.  An invalid result is returned if the
%   vehicle lateral deviation from the path is too far for too long.
%
%   logsout_DrvBus   Logged simulation results, one or multiple runs
%   
%   checkData        Structure containing simulation results used to assess validity
%                    and results of validity check for each run

% Copyright 2023-2024 The MathWorks, Inc.

% Thresholds for validity
yPth_thresh = 1;   % m
yPth_time   = 0.5; % sec

% Loop over runs
for run_i = 1:length(logsout_DrvBus)
    % Extract lateral deviation
    simlog_yPth = squeeze(logsout_DrvBus(run_i).Values.Reference.latdev.Data);
    simlog_t    = logsout_DrvBus(run_i).Values.Reference.latdev.Time;

    % Save simulation results for plotting
    checkData(run_i).yPth = simlog_yPth;
    checkData(run_i).t    = simlog_t;

    % Check if lateral path deviation is acceptable
    yPthInvalid = hasExceededThreshold(simlog_yPth, simlog_t, yPth_thresh, yPth_time);

    % True if not invalid
    checkData(run_i).valid_yPth = ~(yPthInvalid);
end