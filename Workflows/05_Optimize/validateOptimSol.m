function [responseComparison,simResponseTable,predErrTable] = validateOptimSol(solutionsTable,solIdx,paramsAllDef,...
    designVarNames,mdl,Vehicle,parTableVal_trim,predResponseTable,simResponseTable,predErrTable)

% Validate solutions indicated by solIdx
solutions = solutionsTable(solIdx,:);

% Recall that the AI models and optimization only consider a subset of the full set of parameters.  Create a run table using the optimization solutions, and use the default parameter values for all other parameters not included in the AI models and optimization.
% Create a run table with values specified for the full set of parameters
% Initialize the values using the default values from the parameters table
predictedOptimal = repmat(paramsAllDef,height(solutions),1);

% Update the values for the parameters included in the optimization using
% the solution values
for i = 1:height(solutions)
    predictedOptimal{i,designVarNames} = solutions{i,2:end};
end

% Duplicate the run table, since the script that runs the simulations
% includes some code that removes runs that violate certain requirements
optimRunTable = predictedOptimal;

% Run Simscape simulations for each solution in the run table
% Set up Simscape model

open_system(mdl)

%% Run the simulations, passing the model, the parameter table and the run table
% Skip filtering based on input constraints, since input constraints have
% already been enforced by the optimizations, within constraint tolerances
%
% Skip creating simulation validity check plots
[optimRunTable,simOut] = runSimulations(mdl,Vehicle,parTableVal_trim,optimRunTable,false,false);

% Calculate the performance metrics from the simulation results
optimResultsTable = suspOpt_calc_perf_metric(simOut,false);

% Consistency check to make sure first two responses from simulation are ride and roll
if ~isequal(predResponseTable.Properties.VariableNames(2:3),optimResultsTable.Properties.VariableNames(1:2))
    error('Mismatch of names between predicted response variables and simulated response variables. Order matters.');
end

% Create a simulated response table with just the roll and ride metrics for
% comparison
simResponseNewRow = optimResultsTable(:,1:2);

% Compare predicted metric values with the values from the simulations.  Overall, the simulation results match well with the predicted results, validating the designs identified by the optimization.
% Calculate the percentage error of the prediction values compared to the
% values from simulation
responsePredErrPercentage = abs(predResponseTable{solIdx,2:end} - optimResultsTable{:,1:2})./optimResultsTable{:,1:2}*100;

predErrNewRow = array2table(responsePredErrPercentage,'VariableNames',{'Ride % Error','Roll % Error'});

simResponseTable = [simResponseTable; simResponseNewRow];
predErrTable = [predErrTable; predErrNewRow];

% Create a table for comparison
responseComparison = table(predResponseTable,simResponseTable,predErrTable)

