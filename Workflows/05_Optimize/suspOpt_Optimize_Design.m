%% Optimize Suspension Design Parameters Using Surrogate Model
%

%% Overview
% This example demonstrates how to use optimization solvers to quickly
% identify optimal parameter values that meet design and performance
% criteria. AI surrogate models are used to quickly search the design space
% and the results are validated against the full multibody simulation
% model. The workflow is summarized and illustrated below:
% 
% # *Define the optimization problem* in terms of variables,
% objectives, and constraints. 
% # *Identify a global solution* to the optimization optimization problem. 
% # *Verify the predicted performance metrics* using the multibody model.
%
% <<suspOpt_Workflow_Optimize_Design.png>>
%
% The code used to create this documentation is here: <matlab:edit('suspOpt_Optimize_Design.m'); suspOpt_Optimize_Design.m>
%
% (<matlab:web('Vehicle_Design_Opt_with_AI_Overview.html') return to Optimizing Vehicle Design Using AI and Simscape Overview>)
%
% Copyright 2023-2024 The MathWorks, Inc.

%% Define Optimization Variables
%
% Adjusting the design requires selecting a set of design parameters to
% tune. The design parameters have been selected using sensitivity
% analysis. The design parameters and their ranges are loaded into the
% MATLAB workspace and assembled into an optimization variable where the
% full optimization problem will be defined.

% Load parameter table with default values for all and with "Use" column
% set to true for the parameters to be optimized.
load("parTableVal_trimSensitivity.mat","parTableVal_trim");
parTableVal = parTableVal_trim;

useRows = parTableVal.Use == true;
sortrows(parTableVal(useRows,:))

% Extract information for optimization variable 
extractParamTableForOptim;

% Define optimization variable
designVars = optimvar("designVars",designVarNames',"LowerBound",designVarsMin,...
    "UpperBound",designVarsMax);

% The optimization solvers will start with the default values.
% Not all optimization solvers require this initial point.
initialPoint.designVars = designVarsDef;

%% Load AI Models and Define Design Objective
%
% To accelerate the optimization, AI surrogate models will be used. The AI
% surrogate models are loaded from a file. The models can predict a
% performance metric based on the design parameters. The function call to
% obtain the prediction from the AI surrogate model is added to the
% optimization variable which already has the design parameters and
% constraints.

% Select AI model
modelType = 'gpModel';

% Loads AI model(s) and determines which model/model index corresponds
% to which performance metric.
%loadAIModelForOptim;
[rideModel, rollModel, multiOutRegModel] = suspOpt_Optimize_Design_loadAImodels(modelType);

% Determine the indices for RollMetric and RideMetric
% in the multi-response model
responseNames = multiOutRegModel.ResponseName;
rollIdx = find(strcmp(responseNames, "RollMetric"));
rideIdx = find(strcmp(responseNames, "RideMetric"));

% Create optimization expressions for each metric
ridePredict = fcn2optimexpr(@suspOpt_Optimize_Design_predResponseMulti,designVars,multiOutRegModel,rideIdx);
rollPredict = fcn2optimexpr(@suspOpt_Optimize_Design_predResponseMulti,designVars,multiOutRegModel,rollIdx);

%else % Single-response models
%    rollPredict = fcn2optimexpr(@suspOpt_Optimize_Design_predResponseSingle,designVars,rollModel);
%    ridePredict = fcn2optimexpr(@suspOpt_Optimize_Design_predResponseSingle,designVars,rideModel);
%end

% Create the optimization problem object 
rollProb = optimproblem;

% Define problem objective
rollProb.Objective = rollPredict;
rollProb.ObjectiveSense = 'min';

%% Define Constraints on Design Parameters
%
% The design parameters have upper and lower and upper limits. Additional
% restrictions must be placed on the track rod hardpoints to avoid
% excessive bump steer.  
%
% Specifically: -0.05 <= HP_A1_Ro_Inbz - HP_A1_Ro_Outz <= 0.04

% If both parameters are optimization variables, implement as linear
% inequality constraints
if any(strcmp(designVarNames,"HP_A1_Ro_Inbz")) && any(strcmp(designVarNames,"HP_A1_Ro_Outz"))
    % Constraint expressions are assigned as constraints in the
    % optimization problem
    rollProb.Constraints.tierodAngleMin = ...
        designVars("HP_A1_Ro_Inbz") - designVars("HP_A1_Ro_Outz") >= -0.05;
    rollProb.Constraints.tierodAngleMax = ...
        designVars("HP_A1_Ro_Inbz") - designVars("HP_A1_Ro_Outz") <= 0.04;

% If only one of the parameters is an optimization variable, implement as
% updated lower/upper bounds, if applicable

% If only HP_A1_Ro_Outz is part of the optimization variable
elseif ~any(strcmp(designVarNames,"HP_A1_Ro_Inbz")) && any(strcmp(designVarNames,"HP_A1_Ro_Outz"))
    % Calculate temporary bound values based on the above requirement
    tmpLower = paramsAllDef.HP_A1_Ro_Inbz - 0.04;
    tmpUpper = paramsAllDef.HP_A1_Ro_Inbz + 0.05;

    % Compare temporary and current bound values, and use the more
    % restrictive values
    designVars.LowerBound = max(designVars("HP_A1_Ro_Outz").LowerBound,tmpLower);
    designVars.UpperBound = min(designVars("HP_A1_Ro_Outz").UpperBound,tmpUpper);

% If only HP_A1_Ro_Inbz is part of the optimization variable
elseif any(strcmp(designVarNames,"HP_A1_Ro_Inbz")) && ~any(strcmp(designVarNames,"HP_A1_Ro_Outz"))
    % Calculate temporary bound values based on the above requirement
    tmpLower = paramsAllDef.HP_A1_Ro_Outz - 0.05;
    tmpUpper = paramsAllDef.HP_A1_Ro_Outz + 0.04;

    % Compare temporary and current bound values, and use the more
    % restrictive values
    designVars.LowerBound = max(designVars("HP_A1_Ro_Inbz").LowerBound,tmpLower);
    designVars.UpperBound = min(designVars("HP_A1_Ro_Inbz").UpperBound,tmpUpper);
end

% Call helper script to initialize empty tables for the solution and response values
responseVarNames = ["Ride Predicted","Roll Predicted"];
nResponses = size(responseVarNames,2);
initializeSolTables;

%rollPredict = predResponseMulti(designVarsDefTable,multiOutRegModel,rollIdx);
%ridePredict = predResponseMulti(designVarsDefTable,multiOutRegModel,rideIdx);
solution.designVars = designVarsDef;
[solutionsTable,predResponseTable] = addSolResptoTables(solution,'Default',solutionsTable,predResponseTable,designVarNames,...
    responseVarNames,rollPredict,ridePredict);

%% Scenario 1: Minimize Roll Metric
%
% Our optimization problem is defined in terms of design parameters,
% objective, and constraints. We must now choose an optimization solver and
% optimize the design.
% 
% Recommendations for choosing an optimization solver
%
% Some things to consider when choosing between these solvers:
% 
% # fmincon is the default solver for the problem.  It is a local,
% gradient-based optimization solver, so the solution will depend on the
% initial point the solver starts with.
% # patternsearch is a direct search solver that does not use gradients.  It
% requires more function evaluations that gradient-based solvers, but is
% more robust to noise and discontinuities.
% # ga is a population-based global solver.  It requires many function calls
% to the objective function, but since acquiring prediction values from the
% AI models is so computationally inexpensive and fast, could be a feasible
% approach.  Specifying an additional hybrid function option tells the
% solver to run fmincon starting from the solution of ga, which can help
% further improve the solution.
% # surrogateopt is more beneficial for optimization problems where the
% objective function is computationally expensive to compute.
% # gamultiobj and paretosearch are multi-objective solvers.  They can be
% applied to solve single-objective problems, but they likely will be as
% efficient.
%
% Pattern search is used here, as it provides good optimization results while solving quickly.  The user can experiment with different solvers as well.

% Determine devault and applicable optimization solvers
%[autosolver,validsolvers] = solvers(problem);

% Follow recommendations above
%{
if any(strcmp(validsolvers,"particleswarm"))
    chosenSolver = "particleswarm";
    options = optimoptions(chosenSolver,"Display","final",'HybridFcn','fmincon','PlotFcn','pswplotbestf');

elseif any(strcmp(validsolvers,"ga"))
    chosenSolver = "ga";
    options = optimoptions(chosenSolver,"Display","final",'HybridFcn','fmincon','PlotFcn','gaplotbestf');

else
    chosenSolver = "fmincon";
    options = optimoptions(chosenSolver,"Display","final","PlotFcn","optimplot");

end
%}

% Pattern search is used here, as it provides good optimization results while solving quickly.
chosenSolver = 'patternsearch';
options_roll = optimoptions(chosenSolver,"Display","final","PlotFcn","psplotbestf");

% Solve the optimization problem
tic
[solution_roll,optRollPred_roll,exitFlag_roll,outputOpt_roll] = solve(rollProb,initialPoint,...
    "Solver",chosenSolver,"Options",options_roll);
toc;

% Specify short description of this optimization problem for the table
descriptText = 'Min Roll';

% Call helper function to add the solution and response values to the
% tables
[solutionsTable,predResponseTable] = addSolResptoTables(solution_roll,descriptText,solutionsTable,predResponseTable,designVarNames,...
    responseVarNames,rollPredict,ridePredict);

%%

% Compare final values to default values for design parameters
suspOpt_Optimize_Design_plot_ParamAndDefault(solutionsTable(end,:));

%% Scenario 2: Minimize Roll, Constrain Parameters
%
% The design space for our system has changed.  
% 
% * Inboard longitudinal position of the rear anti-roll bar is fixed to 0.30 m
% * Lower arm inboard rear hardpoint height limited to 0.10m - 0.15m
% 
% These changes can be applied to the existing optimization variable and we
% can rerun the optimization.

% Modify the anti-roll bar hardpoint coordinate limits
designVars("HP_A2_AR_Inbx").LowerBound = 0.30;
designVars("HP_A2_AR_Inbx").UpperBound = 0.30;

% Modify the lower arm hardpoint coordinate limits
designVars("HP_A2_LA_inRz").LowerBound = 0.10;
designVars("HP_A2_LA_inRz").UpperBound = 0.15;

% Solve the new optimization problem
tic
[solution_modVar,optRollPred_modVar,exitFlag_modVar,outputOpt_modVar] = solve(rollProb,initialPoint,...
    "Solver",chosenSolver,"Options",options_roll);
toc;

% Add the new optimization solution to the solutions table and predicted responses table.
% Specify short description of this optimization problem for the table
descriptText = 'Min Roll, Lim Pars';

% Add the solution and response values to the tables
[solutionsTable,predResponseTable] = addSolResptoTables(solution_modVar,descriptText,solutionsTable,predResponseTable,designVarNames,...
    responseVarNames,rollPredict,ridePredict);

%%

% Plot resulting design parameter values relative to the defaults
suspOpt_Optimize_Design_plot_ParamAndDefault(solutionsTable(end,:))

%% Scenario 3: Minimize Ride, Nonlinear Constraint on Design Objective
%
% Suppose the ride discomfort metric must meet the following requirement:
% rideMetric <= 0.95. The optimization problem can be modified to
% include this requirement as a nonlinear constraint.

% Copy the previous problem for modification.
rideConProb = rollProb;

% Add the requirement on ride discomfort as a nonlinear constraint.
rideConProb.Constraints.rideMetric = ridePredict <= 0.95;

% Solve the new optimization problem.
tic
[solution_rideCon,optRoll_rideCon,exitFlag_rideCon,outputOpt_rideCon] = solve(rideConProb,initialPoint,...
    "Solver",chosenSolver,"Options",options_roll);
toc

% Specify short description of this optimization problem for the table
descriptText = 'Min Roll, Lim Ride';

% Add the solution and response values to the tables
[solutionsTable,predResponseTable] = addSolResptoTables(solution_rideCon,descriptText,solutionsTable,predResponseTable,designVarNames,...
    responseVarNames,rollPredict,ridePredict);

%%

% Plot resulting design parameter values relative to the defaults
suspOpt_Optimize_Design_plot_ParamAndDefault(solutionsTable(end,:))

%% Scenario 4: Minimize (Ride + Roll)
%
% Multiple responses can be combined into a single objective
% function.  The optimization solver will optimize both responses at the
% same time.

% Copy the previous problem for modification.
% Use problem2 which does not have a constraint on the objective function.
multiRespProb = rollProb;

% Scale responses so that weighting is not affected by response value.
% Response values from the solution of problem2 are used.
sclRoll = predResponseTable{2,"Roll Predicted"};
sclRide = predResponseTable{2,"Ride Predicted"};

% Weight for each response
wtRoll = 0.5;
wtRide = 0.5;

% Define the combined objective expression and assign it to the problem.
multiRespProb.Objective = wtRoll/sclRoll*rollPredict + ...
    wtRide/sclRide*ridePredict;

% Solve using same options as first optimization problem.
tic
[solution_multiResp,optWgtObjPred_multiResp,exitFlag_multiResp] = solve(multiRespProb,initialPoint,...
    "Solver",chosenSolver,"Options",options_roll);
toc

% Specify short description of this optimization problem for the table
descriptText = 'Min (Roll+Ride)';

% Add the solution and response values to the tables
[solutionsTable,predResponseTable] = addSolResptoTables(solution_multiResp,descriptText,solutionsTable,predResponseTable,designVarNames,...
    responseVarNames,rollPredict,ridePredict);

%%

% Plot resulting design parameter values relative to the defaults
suspOpt_Optimize_Design_plot_ParamAndDefault(solutionsTable(end,:))

%% Scenario 5: Minimize Ride and Minimize Roll (Multi-Objective Optimization)
%
% The approach above of combining multiple responses into a single
% objective function identifies a single solution on the Pareto front.  The
% location of the solution along the Pareto front depended on the weight
% and scale factors used for each response. A more general approach is to
% use a multi-objective optimization algorithm to resolve the full Pareto
% front, fully characterizing the optimal trade-off between the objectives.

% Create a copy of the optimization problem for modification
problem5 = multiRespProb;

% Define multiple objectives separately in the problem
problem5.Objective = [];
problem5.Objective.roll = rollPredict;
problem5.Objective.ride = ridePredict;

problem5.ObjectiveSense.roll = 'min';
problem5.ObjectiveSense.ride = 'min';

% Check which solvers are applicable for this multi-objective problem.
[autosolver5,validsolvers5] = solvers(problem5);

% Choose solver, set additional options
chosenSolver5 = "gamultiobj";

options5 = optimoptions(chosenSolver5,"Display","final","PlotFcn","gaplotpareto");

tic
[solution5,fval5,exitFlag5,outputOpt5] = solve(problem5,initialPoint,...
    "Solver",chosenSolver5,"Options",options5);
toc

hold on
scatter(predResponseTable.("Roll Predicted")(1),predResponseTable.("Ride Predicted")(1),'filled')
hold off

title('Pareto Front: Ride vs Roll')
xlabel('Roll Metric')
ylabel('Ride Metric')
legend('Pareto Front Designs','Default Design')

% Identify one or more points of interest from the Pareto front, to
% validate with simulation. Find indices where the first row is less than
% 0.14
validIndices = find(fval5(1, :) < 0.14);

% Extract the second row values at those indices
secondRowValues = fval5(2, validIndices);

% Find the index of the minimum value in the second row values
[~, minIndex] = min(secondRowValues);

% Get the corresponding column index in fval5
columnIndex = validIndices(minIndex);

% Store the solution point of interest, as a struct for consistency with
% solutions from previous problems
solution5pt = solution5(columnIndex);
solution5ptStruct.designVars = solution5pt.designVars';

% Add point to solutions and predicted responses tables.
% Specify short description of this optimization problem for the table
descriptText = 'Min Roll & Min Ride';

% Add the solution and response values to the tables
[solutionsTable,predResponseTable] = addSolResptoTables(solution5ptStruct,descriptText,solutionsTable,predResponseTable,designVarNames,...
    responseVarNames,rollPredict,ridePredict);

%%

% Plot resulting design parameter values relative to the defaults
suspOpt_Optimize_Design_plot_ParamAndDefault(solutionsTable(end,:))

%% Compare Solutions
%
% Compare the design solutions found from the different optimization
% problems.  Inspect the tabular data shown above, or create plots to
% visualize the data.  For example, plot the solutions on a parallel
% coordinate plot.

% Combine the solutions and predicted response tables into a single table
solsRespTable = [solutionsTable, predResponseTable(:,2:end)];

% Plot resulting design parameter values relative to the defaults
suspOpt_Optimize_Design_plot_ParamAndDefault(solutionsTable(2:end,:))

%% Validate Solutions with Simulation
%
% Validate the predicted performance of the optimization solutions using
% Simscape simulations.

% Create a run table with values specified for the full set of parameters
% Initialize the values using the default values from the parameters table
predictedOptimal = repmat(paramsAllDef,height(solutionsTable),1);

% Update the values for the parameters included in the optimization using
% the solution values
for i = 1:height(solutionsTable)
    predictedOptimal{i,designVarNames} = solutionsTable{i,2:end};
end

% Duplicate the run table, since the script that runs the simulations
% includes some code that removes runs that violate certain requirements
optimRunTable = predictedOptimal;

% Set up Simscape model
mdl = 'sm_car_dlc_only';
open_system(mdl)

% Run the simulations, passing the model, the parameter table and the run table
% Skip filtering based on input constraints, since input constraints have
% already been enforced by the optimizations, within constraint tolerances
%
% To do: Add some code to suppress the plots, since they aren't really
% helpful here
[optimRunTable,simOut] = runSimulations(mdl,Vehicle,parTableVal_trim,optimRunTable,false);

% Calculate the performance metrics from the simulation results
[optimResultsTable, perfData]  = suspOpt_calc_perf_metric(simOut,true);

for i=1:length(perfData)
    perfData(i).runName = char(solutionsTable(i,"Description").Variables);
end

figure
ah(1) = subplot(2,1,1);
ah(2) = subplot(2,1,2);
suspOpt_plot_RollRideMetric(perfData,optimResultsTable,ah(1),ah(2));

% Create a simulated response table with just the roll and ride metrics for
% comparison
simResponseTable = optimResultsTable(:,1:2);

% Calculate the percentage error of the prediction values compared to the
% values from simulation
responsePredErrPercentage = abs(table2array(predResponseTable(:,2:end)) - table2array(optimResultsTable(:,1:2)))./table2array(optimResultsTable(:,1:2))*100;
predErrTable = array2table(responsePredErrPercentage,'VariableNames',{'Roll % Error','RideDiscomfort % Error'});

% Create a table for comparison
responseComparison = table(predResponseTable,simResponseTable,predErrTable)

suspOpt_Optimize_Design_plot_MetricPredAndSim(responseComparison)

% Save the results
save("optimRunTable.mat","optimRunTable");
save("optimResultsTable.mat","optimResultsTable");


simResponseTableD = table(predResponseTable.Description,...
    simResponseTable.RideMetric,simResponseTable.RollMetric,...
    'VariableNames',{'Description','RideMetric','RollMetric'});
suspOpt_Optimize_Design_plot_MetricAndDefault(simResponseTableD);

save('solutionsTable.mat','solutionsTable');