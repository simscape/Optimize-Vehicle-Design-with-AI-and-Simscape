function [perfMetrics, perfData]  = suspOpt_calc_perf_metric(simOutFR,saveRes)
% suspOpt_calc_perf_metric  Extract performance metrics from simulation results
%   perfMetrics  = suspOpt_calc_perf_metric(simOutFR,saveRes)
%   This function extracts performance metrics from the vehicle simulation
%   results.  The metrics are reported in a table with one column per
%   metric.
%
%       simOutFR     Simulation output
%       saveRes      Save only data for calculating performance metrics (true/false)
%
%       rideMetric   Body acceleration as vehicle passes over bump
%       rollMetric   L2 norm of roll angle during double lane change
%       brakMetric   Braking distance as vehicle comes to a halt

% Loop executed in reverse to preallocate array at start
for r_i = length(simOutFR):-1:1
    % Extract only data needed to calculate performance metrics
    time_allMs    = simOutFR(r_i).logsout_sm_car.get('VehBus').Values.World.aRoll.Time;
    data_aRoll    = squeeze(simOutFR(r_i).logsout_sm_car.get('VehBus').Values.World.aRoll.Data);
    data_xVeh     = squeeze(simOutFR(r_i).logsout_sm_car.get('VehBus').Values.World.x.Data);
    data_gzVeh    = squeeze(simOutFR(r_i).logsout_sm_car.get('VehBus').Values.World.gz.Data);
    data_nRollCG  = squeeze(simOutFR(r_i).logsout_sm_car.get('VehBus').Values.Chassis.Body.CG.nRoll.Data);
    data_nPitchCG = squeeze(simOutFR(r_i).logsout_sm_car.get('VehBus').Values.Chassis.Body.CG.nPitch.Data);

    % Combine into single structure
    perfData(r_i).t        = time_allMs;
    perfData(r_i).aRoll    = data_aRoll;
    perfData(r_i).xVeh     = data_xVeh;
    perfData(r_i).gzVeh    = data_gzVeh;
    perfData(r_i).nRollCG  = data_nRollCG;
    perfData(r_i).nPitchCG = data_nPitchCG;

end

% Save simulation results for performance metric calculation to a file
% Create text string to identify test based on date and time
if(saveRes)
    timestamp = getSimOutTimestampStr(simOutFR(1));
    foldername  = ['Res_' timestamp];
    filename    = ['Perf_' timestamp];
    if(~exist(foldername,'dir'))
        mkdir(foldername)
    end
    save([pwd filesep foldername filesep filename '.mat'],'perfData');
end
% Calculate metrics
perfMetrics = suspOpt_calc_perf_metric_data(perfData);
