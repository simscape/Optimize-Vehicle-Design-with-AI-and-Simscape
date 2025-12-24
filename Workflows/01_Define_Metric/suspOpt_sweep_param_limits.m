%% Create Virtual Test with Performance Metrics 
%

%% Overview
% This example individually tests the vehicle model with one parameter
% value set to one of its range limits. This simple sweep ensures that
%
% * Parameter values are modified in parallel simulations without recompiling
% * Tests at parameter limits do not result in invalid tests (locked wheels, etc.)
% * Performance metrics are calculated properly
% 
% A simple measure of the sensitivity to each metric is calculated by
% measuring the percent change in the performance metric as the parameter
% value is set to its limits.  A more robust evaluation of the performance
% metric would require a design of experiments to test a distribution of
% the parameters.
%
% <<suspOpt_Workflow_Define_Metrics.png>>
%
% The code used to create this documentation is here: <matlab:edit('suspOpt_sweep_param_limits.m'); suspOpt_sweep_param_limits.m>
%
% (<matlab:web('Vehicle_Design_Opt_with_AI_Overview.html') return to Optimizing Vehicle Design Using AI and Simscape Overview>)
%
% Copyright 2023-2025 The MathWorks, Inc.

%% Open Vehicle Model
%
% Open model and load default parameters.  The vehicle model is set up to
% perform a test in three stages.  
%
% # *Ride over a bump* and measure ride comfort
% # *Complete a double-lane change maneuver (ISO 3888)* and measure stability
% # *Brake to a stop* and measure braking distance
%
% For each stage, a performance metric is calculated. In the plots below
% you can see the changes in body pitch and roll angle as it passes over
% the bump and through the double-lane change.  The wheel speeds show the
% steering and braking during the maneuver.
%
% <matlab:open_system('sm_car_dlc_only'); Open Model>

setup_sm_car_model

%%

out = sim(mdl);
logsout_sm_car = out.logsout_sm_car;
sm_car_plot2whlspeed
sm_car_plot5bodymeas

%% Generate Table of Design Parameters
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

close(h2_sm_car)
close(h5_sm_car)
parTableVal

%% Create Simulation Input Objects to Test Range Limits
%
% A suite of tests is defined using the table above. For each test, all
% parameters set to the default value and one parameter set to either of
% its range limits.  The tests are created using a SimulationInput object
% so that the tests can be performed in series or parallel without
% modifying the original model. Parameter value changes and any model
% parameter setting overrides are applied temporarily during the test using
% the SimulationInput object.

% Count number of runs
numFRTests = sum(parTableVal.Use)*2;

% Create empty simulation input objects
clear simInputFR
simInputFR(1:numFRTests) = Simulink.SimulationInput(mdl);

% Initialize indices
inpFRInd = 0;

% Loop over all parameters
% Steps of 2 as each row contains min and max
for p_i = 2:2:numFRTests

    % Load default data structure
    Vehicle_data;
    % Check default data structure
    Vehicle_def = sm_car_vehcfg_checkConfig(Vehicle);

    % Take MINIMUM value of parameter from current row in table 
    % and overwrite field in default Vehicle structure 
    Vehicle = suspOpt_param_assign(parTableVal,p_i/2,parTableVal.Min(p_i/2),Vehicle_def);

    % To simplify post-processing, create a label for each run
    UserString_SimInput = [parTableVal.Label{p_i/2} ' ' num2str(parTableVal.Min(p_i/2))];
    %disp(UserString_SimInput);

    % Set parameter value in odd Simulation Input object (parameter, min value)
    simInputFR(p_i-1) =       setVariable(simInputFR(p_i-1),'Vehicle',Vehicle);
    simInputFR(p_i-1) = setModelParameter(simInputFR(p_i-1),SimMechanicsOpenEditorOnUpdate="off");
    simInputFR(p_i-1) = setModelParameter(simInputFR(p_i-1),SimscapeLogType="None");
    simInputFR(p_i-1) = simInputFR(p_i-1).setModelParameter('initFcn','');
    simInputFR(p_i-1).UserString = UserString_SimInput;

    % Take MAXIMUM value of parameter from current row in table 
    % and overwrite field in default Vehicle structure 
    Vehicle = suspOpt_param_assign(parTableVal,p_i/2,parTableVal.Max(p_i/2),Vehicle_def);

    % To simplify post-processing, create a label for each run
    UserString_SimInput = [parTableVal.Label{p_i/2} ' ' num2str(parTableVal.Max(p_i/2))];
    %disp(UserString_SimInput);

    % Set parameter value in even Simulation Input object (parameter, max value)
    simInputFR(p_i) =       setVariable(simInputFR(p_i),'Vehicle',Vehicle);
    simInputFR(p_i) = setModelParameter(simInputFR(p_i),SimMechanicsOpenEditorOnUpdate="off");
    simInputFR(p_i) = setModelParameter(simInputFR(p_i),SimscapeLogType="None");
    simInputFR(p_i) = simInputFR(p_i).setModelParameter('initFcn','');
    simInputFR(p_i).UserString = UserString_SimInput;
end

simInputFR

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

timerValFR = tic;
clear simOutFR

% Run with with FastRestart ON, parallel ON
curr_proj = simulinkproject;
p = parpool;
p.addAttachedFiles(which('Custom_lib.slx'));
p.addAttachedFiles(curr_proj.RootFolder + "\Libraries\Vehicle\Tire\Data_TIR")

simOutFR = parsim(simInputFR,'ShowSimulationManager','on', ...
    'UseFastRestart','on','ShowProgress','off', ...
    'TransferBaseWorkspaceVariables','on');
Elapsed_Time_Time_FR  = toc(timerValFR);
disp([num2str(length(simOutFR)) ' simulations completed in ' num2str(Elapsed_Time_Time_FR) ' seconds.'])

%% Check Run Validity
%
% The outputs of the test sweep are checked to make sure the runs are all
% valid.  A test run is deemed invalid if any of the following thresholds are
% exceeded for an unacceptable period of time:
%
% # The *toe angle* of either front wheel.
% # The *lateral deviation* of the vehicle from the target path.
% # The *wheel speed deviation* measured as difference in wheel tangential velocity and chassis speed.
%
% Plot show the values of the measurements for all the runs, and a count of
% the valid runs is displayed.  If any run is invalid, we may need to
% reconsider our parameter ranges.

dataValidCheck  = suspOpt_check_runValid(parTableVal,simOutFR,Vehicle,true,true);
validaToe = [dataValidCheck.valid_aToe];
validyPth = [dataValidCheck.valid_yPth];
validwSpd = [dataValidCheck.valid_wSpd];

check_2 = union(find([dataValidCheck.valid_aToe]),find([dataValidCheck.valid_yPth]));
check_3 = union(check_2,find([dataValidCheck.valid_wSpd]));

disp(['Number of valid runs: ' num2str(length(check_3))])

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
% The impact of the parameters on the performance metric are plotted.  The
% plot shows (Metric with parameter at max value - Metric with parameter at
% min value)/(maximum observed performance metric value).
%
% This simple measure indicates how sensitive the metric is to the
% parameter value.  A more rigorous sensitivity analysis should be
% performed to truly determine parameter sensitivity. The plots show that
% the design parameters have a relatively small impact on the braking
% distance.

perfMetrics = suspOpt_calc_perf_metric(simOutFR,true);

%%

% Write to table, save to file
minVal = [];
maxVal = [];
for i = 1:2:size(simInputFR,2)
    labelStrsMin = strsplit(simInputFR(i).UserString,' ');
    labelStrsMax = strsplit(simInputFR(i+1).UserString,' ');
    varLabelStr{(i+1)/2} = labelStrsMin{1};
    minVal((i+1)/2)      = str2num(labelStrsMin{2});
    maxVal((i+1)/2)      = str2num(labelStrsMax{2});
end

RangeSweepResTable = table(...
    varLabelStr',...
    parTableVal.Parameter,...
    parTableVal.Index,...
    minVal',...
    maxVal',...
    perfMetrics.RollMetric(1:2:end),...
    perfMetrics.RollMetric(2:2:end),...
    abs(perfMetrics.RollMetric(1:2:end)-perfMetrics.RollMetric(2:2:end)), ...
    perfMetrics.BrakMetric(1:2:end),...
    perfMetrics.BrakMetric(2:2:end),...
    abs(perfMetrics.BrakMetric(1:2:end)-perfMetrics.BrakMetric(2:2:end)), ...
    perfMetrics.RideMetric(1:2:end),...
    perfMetrics.RideMetric(2:2:end),...
    abs(perfMetrics.RideMetric(1:2:end)-perfMetrics.RideMetric(2:2:end)), ...
    validwSpd(1:2:end)',...
    validwSpd(2:2:end)',...
    validaToe(1:2:end)',...
    validaToe(2:2:end)',...
    validyPth(1:2:end)',...
    validyPth(2:2:end)',...
    ...
    'VariableNames',["Label","Variable Name","Index","Min","Max","RollMn","RollMx","DiffRoll","BrakMn","BrakMx","DiffBrak","RideMn","RideMx","DiffRide" + ...
    "","wSpdMn","wSpdMx","aToeMn","aToeMx","yPthMn","yPthMx"]);

writetable(RangeSweepResTable,'suspOpt_sweep_param_limits_results.xlsx');

% Save results of sweep to MAT file
save RangeSweepResTable RangeSweepResTable

% Plot Variance

suspOpt_sweep_param_limits_plotVariance(RangeSweepResTable)

%% Identify Sensitive Values Based on Variance Threshold
%
% Based on the above result, we can see many parameters have a relatively
% small impact on the performance metrics.  To limit the design space, we
% pick the parameters with the largest impact on the ride comfort and roll
% stability metrics and combine them into a single list.

parTableVal_trim = suspOpt_sweep_param_limits_checkVariance(parTableVal,RangeSweepResTable);

% This set can be saved to a file to explore a broader set of parameters
%save("parTableVal_trimSweepThresh.mat","parTableVal_trim")

useRows = parTableVal_trim.Use == true;
sortrows(parTableVal_trim(useRows,:))

%% Identify Top 10 Parameters Based on Variance Only
%
% That list is then trimmed to a list of the 10 parameters for the
% remainder of our design space investigation.  Working with only 10
% parameters accelerates the process of exploring the design workflow.

parTableVal_trim = suspOpt_sweep_param_limits_pickSet(parTableVal_trim);

% This set can be saved to a file for further exploration
%save('parTableVal_trimSweep.mat','parTableVal_trim');

useRows = parTableVal_trim.Use == true;
sortrows(parTableVal_trim(useRows,:))

%%

%bdclose all
%close all
