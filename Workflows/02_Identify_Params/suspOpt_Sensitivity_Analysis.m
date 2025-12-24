%% Test Sensitivity of Performance Metrics to Design Parameters
%

%% Overview
% This example performs a sensitivity analysis for the design parameters in
% a vehicle suspension. Design of Experiments is used to generate a
% distribution of parameters. The simulation model is tested with those
% parameters and performance metrics are calculated. Statistical methods
% are used to identify the relative sensitivities of each performance
% metric to each parameter.
%
% <<suspOpt_Workflow_Identify_Params.png>>
%
% The code used to create this documentation is here: <matlab:edit('suspOpt_Sensitivity_Analysis.m'); suspOpt_Sensitivity_Analysis.m>
%
% (<matlab:web('Vehicle_Design_Opt_with_AI_Overview.html') return to Optimizing Vehicle Design Using AI and Simscape Overview>)
%
% Copyright 2023-2025 The MathWorks, Inc.

%% Open Vehicle Model
%
% The vehicle model is created using Simscape.  The suspension is modeled
% using Simscape Multibody for rigid parts and joints.  Simscape is used to
% model the springs, dampers, and driveline. A driver model attempts to
% follow a path provided for the test.
%
% <matlab:open_system('sm_car_dlc_only'); Open Model>

setup_sm_car_model

%% Perform Single Test
%
% The vehicle model is set up to perform a test in three stages.
%
% # *Ride over a bump* and measure ride comfort
% # *Complete a double-lane change maneuver (ISO 3888)* and measure stability
% # *Brake to a stop* and measure braking distance
%
% For each stage, a performance metric is calculated. In the plots below
% you can see the changes in body pitch and roll angle as it passes over
% the bump and through the double-lane change.  The wheel speeds show the
% steering and braking during the maneuver.

out = sim(mdl);
logsout_sm_car = out.logsout_sm_car;
sm_car_plot2whlspeed
sm_car_plot5bodymeas

%% Load Table of Design Parameters
%
% Adjusting the design requires selecting a set of design parameters to
% tune and setting ranges for those values. That set is defined in a table.
% For each parameter we specify:
%
% # *Label*: A short character string to identify the parameter
% # *Parameter*: Location in a MATLAB structure where the parameter is
% defined
% # *Index*: Index of the value within the structure field
% # *Use*: Indicator if the parameter should be tuned (true/false). Set to
% "true" until a senstivity analysis has been performed.
% # *Min*: Minimum value for parameter range
% # *Max*: Maximum value for parameter range
% # *Default*: Default value for parameter

% Create table with *relative* min and max for HPs, min and max for scalars
parTableRel = suspOpt_param_rangeRelative;

% Convert table to have min and max for all values
% Suitable for DOE and sensitivity analysis
parTableVal = suspOpt_param_rangeAbsolute(parTableRel);

% NOTE - In addition to ranges, two parameter constraints should be applied
%        to avoid excessive bump steer
% 1. HP_A1_Ro_Inbz - HP_A1_Ro_Outz >= -0.05
% 2. HP_A1_Ro_Inbz - HP_A1_Ro_Outz <=  0.04

parTableVal

%% Generate Distribution of Parameters
%
% Parameter distributions can be generated using many methods.  A common
% method is Sobol.  We generate 1000 parameter sets that distribute the
% parameters evenly throughout the design space covered by the 94
% parameters in our design.  Each parameter value is varied within its
% individual range.  The scatter plot below shows 1000 samples for 8
% parameters, a small subset of the 94 parameters that cover our entire
% design space.
%
% Some of the parameter sets will not be tested as they will violate the
% constraint we have on the track rod hardpoints.  Those will be omitted
% before the simulation sweep is started.

runTableSense = suspOpt_doe_sobol(1,1600);

% Also possible using Simulink Design Optimization
% Requires model to be open
%runTableSense = suspOpt_doe_sdo(1600,'Sobol');
%runTableSense = suspOpt_doe_sdo(1600,'lhs');

nParameters = 8;
nParamPts   = height(runTableSense);

[h,ax,bigax] = gplotmatrix(runTableSense{1:nParamPts,1:nParameters},[],[],[],[],[],[],[],...
    runTableSense.Properties.VariableNames(1:nParameters), runTableSense.Properties.VariableNames(1:nParameters));
title(['Scatter Plot of ' num2str(nParamPts) ' Samples for ' num2str(nParameters) ' Parameters.'],'FontSize',18)
set(gcf,'Position',[54   255   850   706])
for j = 1:size(ax,1)
    for k = 1:size(ax,2)
        ax(j,k).XLabel.String = '';
        ax(j,k).YLabel.String = '';
        try
            h(j,k).MarkerSize=2;
        catch
        end
    end
end

%% Run Simulations Using Parallel Computing
% 
% Using the parsim() command, the suite of tests is executed in parallel on
% multiple workers.  Using Fast Restart, the model is only compiled once
% per worker.  Because we have defined the design parameters as run-time
% parameters, we can modify their values even within the compiled model.
% This dramatically shortens the time it takes to execute the sweep.
%
% Progress is reported using the Simulation Manager. We can see if any
% warnings or errors have occurred during any of the tests and see how long
% each run has taken.

close(gcf)
close(h2_sm_car)
[runTableSense_OUT,simOutSense] = runSimulations(mdl,Vehicle,parTableVal,runTableSense);

%% Extract Performance Metrics
%
% For all runs, performance metrics are calculated.
%
% # *Ride Comfort*: The magnitude of the vertical acceleration, roll
% acceleration, and pitch acceleration of the vehicle body is integrated
% during the period of time the vehicle passes over a bump. Larger values
% indicates worse ride comfort.
% # *Roll Stability*: The L2 norm of the roll angle is calculated during
% the period of time the vehicle is in the double lane change maneuver.
% Larger values indicate worse vehicle stability.
% # *Vehicle Safety*: The braking distance at the end of the test is
% measured.  Longer braking distance indicates worse safety.
%
% The plots below show a histogram of the performance metrics.  The braking
% metric has a very narrow band, indicating the design space does not have
% much effect on the braking distance.  Other design parameters or tests
% must be considered to impact that performance metric.

perfMetrics = suspOpt_calc_perf_metric(simOutSense,true);

figure
ahH(1) = subplot(131);
histogram(perfMetrics.RollMetric);
title('Roll Metric')
ylabel('Number of Tests');
ahH(2) = subplot(132);
histogram(perfMetrics.RideMetric);
title('Ride Metric')
ahH(3) = subplot(133);
histogram(perfMetrics.BrakMetric)
title('Braking Metric')

linkaxes(ahH,'y');

%% Perform Sensitivity Analysis
%
% There are many methods that can be used to perform a sensitivity
% analysis.  Results using the Standard Regression method are shown below.
%
% In the first plot below, the coefficients indicating the influence of the
% parameter on the performance metrics are plotted in a tornado plot
% (unsorted) using the MATLAB command stem.
% 
% * *Stem magnitude* indicates the parameter has a large influence on the
% performance metric. 
% * *Stem direction* indicates if increasing the parameter increases or
% decreases the metric.  When the same parameter has stems pointing in
% opposite directions, it indicates that altering the parameter trades an
% improvement in one metric with a degradation of the other.
%
% The stems with filled-in circles are the ones our criteria have selected
% for design space exploration.  To see the criteria for selection, look at
% code <matlab:edit('suspOpt_Sensitivity_Analysis_select.m');
% suspOpt_Sensitivity_Analysis_select.m>
%
% The second plot shows only the parameters that have been selected. The
% label includes abbreviations such as "HP" for hardpoint, "A1" for front
% axle", "UA" for upper arm", and so on.  A table of the selected parameters
% is shown in the next section.

% Perform sensitivity analysis
opts = sdo.AnalyzeOptions;
opts.Method = 'All';
opts.MethodOptions = 'All';
rStats = sdo.analyze(runTableSense_OUT, perfMetrics, opts);
suspOpt_Sensitivity_Analysis_save(simOutSense(1),rStats);

% Select parameters according to Standardized Regression
numParTrim = 8;
labelList_SR = suspOpt_Sensitivity_Analysis_select(rStats,'StandardizedRegression',numParTrim,true);
% Plot only top parameters
suspOpt_Sensitivity_Analysis_select(rStats,'StandardizedRegression',numParTrim,false);

%% Select parameters according to Correlation
labelList_CO = suspOpt_Sensitivity_Analysis_select(rStats,'Correlation',numParTrim,true);
% Plot only top parameters
suspOpt_Sensitivity_Analysis_select(rStats,'Correlation',numParTrim,false);

%% Selected List of Parameters
%
% That list is then trimmed for the remainder of our design space
% investigation.  Working with a reduced number of parameters accelerates
% the process of exploring the design workflow. Below is the list selected
% using our criteria applied to Standardized Regression coefficients. The
% track rod parameters have also been explicitly added to the list so that
% we can see how to implement constraints on parameters in the rest of the
% workflow.

parTableVal_trim = suspOpt_sweep_param_limits_pickSet(parTableVal,labelList_SR);
save parTableVal_trimSensitivity.mat parTableVal_trim

useRows = parTableVal_trim.Use == true;
sortrows(parTableVal_trim(useRows,:))

