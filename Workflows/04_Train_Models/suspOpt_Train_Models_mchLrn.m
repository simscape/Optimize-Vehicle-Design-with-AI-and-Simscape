%% Train and Validate Machine Learning Surrogate Model of Design Space
%

%% Overview
% This example trains an AI surrogate model from data generated by a
% vehicle dynamics model created in Simscape. Machine Learning is used for
% both the models and model training.  The basic steps are:
%
% # *Prepare the data* collected from a DoE for training and testing
% # *Select the models* that will be trained
% # *Train the models* using a portion of the DoE data
% # *Evaluate the accuracy* of all trained models
% # *Select the model* for use in other steps of the design workflow
%
% <<suspOpt_Workflow_Train_Models.png>>
%
% The code used to create this documentation is here: <matlab:edit('suspOpt_Train_Models_mchLrn.m'); suspOpt_Train_Models_mchLrn.m>
%
% (<matlab:web('Vehicle_Design_Opt_with_AI_Overview.html') return to Optimizing Vehicle Design Using AI and Simscape Overview>)
%
% Copyright 2023-2024 The MathWorks, Inc.

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
% # *Use*: Indicates the parameter forms the design space to be explored.
% # *Min*: Minimum value for parameter range
% # *Max*: Maximum value for parameter range
% # *Default*: Default value for parameter

% Load parameter table with default values for all
% and with "Use" column set to true for the DoE parameters
load("parTableVal_trimSensitivity.mat");
parTableVal = parTableVal_trim;

useRows = parTableVal.Use == true;
sortrows(parTableVal(useRows,:))

%% Load and Analyze the Training Data
%
% Load results of DoE that generated training data. The scatter plots show
% the distribution of points.  The constraint affecting the first two
% parameters is clearly seen in plots located in the upper left portion of
% the matrix of plots.

% Load the full dataset
runTableFilename     = "doeRunTable.mat"; 
resultsTableFilename = "doeResultsTable.mat";

load(runTableFilename,"runTable");
load(resultsTableFilename,"resultsTable");

% Capture the variable names and descriptions (full parameter names)
inputVars = string(parTableVal.Label);
inputVars = inputVars(parTableVal.Use);
inputDescriptions = string(parTableVal.Parameter);
inputDescriptions = inputDescriptions(parTableVal.Use);
responseVars = string(resultsTable.Properties.VariableNames);

% Create the data table
inputTable = runTable(:,inputVars);
dataTable = [inputTable resultsTable];

% Apply constraints to inputs and responses
% --- Constraint should already have been applied in DoE
% --- If it is applied here, needs to account for case where
% ---   only one or no trackrod points are a "use" parameter
% --- Commenting out for now.
%filterInputConstraints = false; 
%if filterInputConstraints
    % Constraint specified in sweep_all_param.m
%    idx = ((dataTable.HP_A1_Ro_Inbz - dataTable.HP_A1_Ro_Outz)>=-0.05);
%    dataTable = dataTable(idx,:);
%    idx = ((dataTable.HP_A1_Ro_Inbz - dataTable.HP_A1_Ro_Outz)<=0.04);
%    dataTable = dataTable(idx,:);    
%end

% Plot matrix of scatter plots
figure;
[~,ax,bigax] = gplotmatrix(dataTable{:,:},[],[],[],[],[],[],[],...
    dataTable.Properties.VariableNames, dataTable.Properties.VariableNames);
title(['Scatter Plot of ' num2str(height(dataTable)) ' Samples for ' num2str(width(dataTable)-3) ' Parameters.'],'FontSize',18)

set(gcf,'Position',[54   255   850   706])
for j = 1:size(ax,1)
    for k = 1:size(ax,2)
        ax(j,k).XLabel.String = '';
        ax(j,k).YLabel.Interpreter = 'none';
        ax(j,k).YLabel.Rotation = 0;        
        ax(j,k).YTickLabel = [];        
    end
end

%% Verify Influence of Design Space Parameters on Performance Metrics
%
% The data from the DoE contains information of how the performance metrics
% (responses) are influenced by the design space parameters (predictors).
% The function <matlab:doc('corr'); corr> shows the correlation. The plots
% below indicates that the braking metric is not heavily influenced by
% our design space parameters in the performed test.

% Visualize the correlation between signals for predictors and responses
suspOpt_Train_Models_plotCorr(dataTable,inputVars,responseVars)

%%
% Next, rank features for regression using minimum redundancy maximum relevance (MRMR) algorithm.  
% The algorithm minimizes the redundancy of a feature set and maximizes the
% relevance of a feature set to the response variable. See
% <matlab:doc('fsrmrmr') fsrmrmr> documentation for more details. This
% plot also indicates that the braking metric is not heavily influenced by
% our design space parameters in the performed test.

% Rank features using MRMR algorithm for each response, sorted by
% ranking for first response.
suspOpt_Train_Models_plotMRMR(dataTable,responseVars);

% Remove braking metric as these tests do not show the parameters impact on
% that performance metric
ind_respVarKeep = ~startsWith(responseVars,'Brak');
responseVars = responseVars(ind_respVarKeep);
numInputs    = numel(inputVars);
numResponses = numel(responseVars);

% Create the data table
inputTable = runTable(:,inputVars);
dataTable = [inputTable resultsTable];

%% Split Data into Training and Test Data
%
% To verify that our trained model predicts responses accurately, we will
% only use a portion of the data to train the model.  The remainder of the
% data will be used to test the predictions of the performance metrics.
%
% To ensure the training and test data fully represents the design space,
% we plot a histograms for each metric with the training data set and the
% testing data set.  The distributions look similar to the distribution for
% the full set of data, indicating that we have good coverage of the design
% space.

% Split into training and test data
cv = cvpartition(height(dataTable), HoldOut=0.2);
idx = training(cv);
trainingTable = dataTable(idx,:);
testTable = dataTable(~idx,:);

disp(['Number of Test Points from DoE: ' num2str(height(dataTable))]);
disp(['Test points for training: ' num2str(height(trainingTable))]);
disp(['Test points for testing:  ' num2str(height(testTable))]);

% Show distribution of response values
figure
ahH(1) = subplot(221);
histogram(ahH(1),trainingTable.(responseVars(1)),20)
title(ahH(1),[char(responseVars(1)) ' (Training)'])
ylabel('Number of Tests');
ahH(2) = subplot(222);
histogram(ahH(2),trainingTable.(responseVars(2)),20)
title(ahH(2),[char(responseVars(2)) ' (Training)'])

ahH(3) = subplot(223);
histogram(ahH(3),testTable.(responseVars(1)),20)
title(ahH(3),[char(responseVars(1)) ' (Test)'])
ylabel(ahH(3),'Number of Tests');
xlabel(ahH(3),'Value')
ahH(4) = subplot(224);
histogram(ahH(4),testTable.(responseVars(2)),20)
title(ahH(4),[char(responseVars(2)) ' (Test)'])
xlabel(ahH(4),'Value')

linkaxes(ahH(:),'y');
linkaxes(ahH([1 3]),'x');
linkaxes(ahH([2 4]),'x');

%% Train Machine Learning Models
%
% Use training data to train Machine Learning models.  Both multi-output
% and single output models are trained. After the models are trained, we
% assess the accuracy of each model using the test data.  We compare the
% performance metric predicted by the trained model against the true value
% from the original Simscape simulation.  The most accurate models will be
% used for the following steps of the workflow.

% Multi Output Models - R2024b and higher
if(~isMATLABReleaseOlderThan("R2024b"))
    learner = "bag";
    bagModel = fitrchains(trainingTable,trainingTable.Properties.VariableNames(end-2:end),Learner=learner,ChainPredictedResponse=true);
    learner = "gp";
    gpModel = fitrchains(trainingTable,trainingTable.Properties.VariableNames(end-2:end),Learner=learner,ChainPredictedResponse=true);
end

% Single Output Models, Ensemble Trees
template         = templateTree('MinLeafSize', 16, 'NumVariablesToSample', 'all', 'Surrogate','on');
rInputValues     = trainingTable(:,1:end-3);
bagModel1 = fitrensemble(rInputValues,trainingTable.(responseVars(1)),'Method', 'Bag','NumLearningCycles', 100, 'Learners', template, ResponseName=responseVars(1)); % 12/12/2024 - Brad added ResponseName for all of these
bagModel2 = fitrensemble(rInputValues,trainingTable.(responseVars(2)),'Method', 'Bag','NumLearningCycles', 100, 'Learners', template, ResponseName=responseVars(2));
% Omit model for BrakMetric
%regressionModelEns3 = fitrensemble(rInputValues,trainingTable.(responseVars(3)),'Method', 'Bag','NumLearningCycles', 100, 'Learners', template);

% Single Output Models, Gaussian Process Regression
gpModel1 = fitrgp(rInputValues,trainingTable.(responseVars(1)),'BasisFunction','constant','KernelFunction','rationalquadratic','Standardize', true, ResponseName=responseVars(1));
gpModel2 = fitrgp(rInputValues,trainingTable.(responseVars(2)),'BasisFunction','constant','KernelFunction','rationalquadratic','Standardize', true, ResponseName=responseVars(2));
% Omit model for BrakMetric
% regressionModelGP3 = fitrgp(rInputValues,trainingTable.(responseVars(3)),'BasisFunction','constant','KernelFunction','rationalquadratic','Standardize', true);

%%
% Accuracy of Regression Chains, Bag Learner
[rollPr.acc.RBC, rollPr.rSq.RBC] = suspOpt_Train_Models_mchLrn_plotAccuracy(...
    "RollMetric",bagModel,'Regr. Chain Bag',true,testTable);
[ridePr.acc.RBC, ridePr.rSq.RBC] = suspOpt_Train_Models_mchLrn_plotAccuracy(...
    "RideMetric",bagModel,'Regr. Chain Bag',true,testTable);

%% 
% Accuracy of Regression Chains, Gaussian Process Learner
[rollPr.acc.GPC, rollPr.rSq.GPC] = suspOpt_Train_Models_mchLrn_plotAccuracy(...
    "RollMetric",gpModel,'Regr. Chain GP',true,testTable);
[ridePr.acc.GPC, ridePr.rSq.GPC] = suspOpt_Train_Models_mchLrn_plotAccuracy(...
    "RideMetric",gpModel,'Regr. Chain GP',true,testTable);

%% 
% Accuracy of Ensemble Learners for Regression
[rollPr.acc.Ens, rollPr.rSq.Ens] = suspOpt_Train_Models_mchLrn_plotAccuracy(...
    "RollMetric",bagModel2,'Ensemble for Regr.',false,testTable);
[ridePr.acc.Ens, ridePr.rSq.Ens] = suspOpt_Train_Models_mchLrn_plotAccuracy(...
    "RideMetric",bagModel1,'Ensemble for Regr.',false,testTable);

%% 
% Accuracy of Gaussian Process Learners for Regression
[rollPr.acc.GPR, rollPr.rSq.GPR] = suspOpt_Train_Models_mchLrn_plotAccuracy(...
    "RollMetric",gpModel2,'Gaussian PR.',false,testTable);
[ridePr.acc.GPR, ridePr.rSq.GPR] = suspOpt_Train_Models_mchLrn_plotAccuracy(...
    "RideMetric",gpModel1,'Gaussian PR.',false,testTable);

%% Compare Accuracy of AI Surrogate models
%
% The bar chart clearly shows Gaussian Process Regression models are the
% most accurate. The multi-output model is the most convenient to use, so
% that model will be saved to a file for use in other steps of the
% workflow.

figure
bar([struct2array(rollPr.rSq);struct2array(ridePr.rSq)]);
ax = gca;
ax.XTickLabel = {'Roll','Ride'};
ylabel('Accuracy')
legend({'Regr. Chain Bag','Regr. Chain GP','Ensemble for Regr.','Gaussian PR.'},'Location','Best');
title('Comparison of AI Surrogate Model Accuracy')


% Save models to use for optimization workflow
load("aiModels.mat","aiModels");
if(exist('gpModel','var'))
    aiModels.gpModel  = gpModel;
end
if(exist('bagModel','var'))
    aiModels.bagModel = bagModel;
end
aiModels.gpModel1  = gpModel1;
aiModels.gpModel2  = gpModel2;
aiModels.bagModel1 = bagModel1;
aiModels.bagModel2 = bagModel2;

save('aiModels','aiModels','trainingTable','responseVars','rollPr','ridePr');
