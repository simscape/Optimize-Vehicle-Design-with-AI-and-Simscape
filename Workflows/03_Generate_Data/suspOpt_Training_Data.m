%% Generate Training Data by Running Design of Experiments
%

%% Overview
% This example generates training data for a AI surrogate model. Design of
% Experiments is used to generate a distribution of parameters. The
% simulation model is tested with those parameters and performance metrics
% are calculated. The parameter sets and performance metrics will be used
% to train an AI surrogate model.
%
% <<suspOpt_Workflow_Generate_Data.png>>
%
% The code used to create this documentation is here: <matlab:edit('suspOpt_Training_Data.m'); suspOpt_Training_Data.m>
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

% Load parameter table with default values for all
% and with "Use" column set to true for the DoE parameters
load("parTableVal_trimSensitivity.mat");
parTableVal = parTableVal_trim;

useRows = parTableVal.Use == true;
sortrows(parTableVal(useRows,:))

%% Specify Design Space Defined by Influential Parameters
%
% Our training data needs to cover the space defined by the parameters
% identified by the sensitivity analysis. The entire list of design
% parameters is loaded and two sets of parameters for testing are created.
% One has all influential parameters set to their minimum value, one has
% all influential parameters set to their maximum value.

% Get max and min values for "Use" parameters
inputNames  = parTableVal.Label;
inputValues = parTableVal.Default;
useIdx      = parTableVal.Use;
numVarying  = nnz(useIdx);

% ---- Constraint could be applied during generation
% ---- If only one track rod point is used, set range accordingly

% Create rows with "Use" parameters set to min
inputValues(useIdx) = parTableVal.Min(useIdx);
runRowMin = array2table(inputValues',VariableNames=inputNames);

% Create rows with "Use" parameters set to max
inputValues(useIdx) = parTableVal.Max(useIdx);
runRowMax = array2table(inputValues',VariableNames=inputNames);

% Assemble into table
runTable = [runRowMin; runRowMax];

%% 
% size(runTable)
size(runTable)

%% 
% Display only influential parameters
%
% runTable(:,useIdx)
runTable(:,useIdx)

%% Generate Space-Filling DOE with Latin Hypercube Sampling
%
% Parameter distributions can be generated using many methods.  A common
% method is Latin Hypercube Sampling.  We generate a large number of
% parameter sets that distribute the parameters evenly throughout the
% design space covered by the parameters in our design that we wish to
% tune.  Each parameter value is varied within its individual range.  The
% scatter plot below shows some of the samples for the list of influential
% parameters, a small subset of the parameter sets generated for our design
% of experiments.

numRuns = 1000; % Run 1000 runs
% numRuns = 2; % Test mode

% Create a doe table for the varying inputs, scaling by the range of the input variables
doeTable = array2table(lhsdesign(numRuns,numVarying),VariableNames=inputNames(useIdx));
minBounds = parTableVal.Min(useIdx)';
maxBounds = parTableVal.Max(useIdx)';
doeTable = doeTable.*(maxBounds-minBounds) + minBounds;

% Add rows to runTable
inputValues = parTableVal.Default;
for row=1:height(doeTable)
    runRow = array2table(inputValues',VariableNames=inputNames);
    runRow(1,useIdx) = doeTable(row,:);
    runTable = [runTable; runRow];
end

nParameters = 10;
nParamPts  = height(runTable);

figure
set(gcf,'Position',[54   255   850   706])
[H,AX,BigAX,P,PAx] = sdo.scatterPlot(runTable(1:nParamPts,useIdx));
title(['Scatter Plot of ' num2str(nParamPts) ' Samples for ' num2str(nParameters) ' Parameters.'],'FontSize',18)
set(gcf,'Position',[54   255   850   706])
for j = 1:size(AX,1)
    for k = 1:size(AX,2)
        AX(j,k).XLabel.String = '';
        AX(j,k).YLabel.String = '';
        H(j,k).MarkerSize=2;
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
close(h5_sm_car)
[runTable,simOut] = runSimulations(mdl,Vehicle,parTableVal,runTable);


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

perfMetrics = suspOpt_calc_perf_metric(simOut,true);

% Save the results
save("doeRunTable.mat","runTable");
resultsTable = perfMetrics;
save("doeResultsTable.mat","resultsTable");

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



