function [net, tblTrainFtSelect] = suspOpt_Train_Models_deepLrn_trainnet(trainingTable,inputVars,responseVars)

inputVars = inputVars; % this can be modified if there are additional feature selection
% (right now, it uses all features available)

% Apply feature selection to training and testing tables
tblTrainFtSelect = trainingTable(:,inputVars);

XTrain           = table2array(trainingTable(:,inputVars));
TTrain           = table2array(trainingTable(:,responseVars));

%% Define the neural network architecture

% deepNetworkDesigner

% Model 1: use featureInputLayer
numFeatures  = size(XTrain,2);
numResponses = length(responseVars); 
layers = [
    featureInputLayer(numFeatures,Normalization="zscore")
    fullyConnectedLayer(16) % the number can be changed based on expert knowledge, trial-and-error, or with hyperparameter tuning
    layerNormalizationLayer
    reluLayer
    fullyConnectedLayer(numResponses)];

% Model 2: Create an LSTM regression network.
% NOTE: As of now, the LSTM model does not work because the dataset was not
% prepared in a way to accomondate the architecture 
% 
% numHiddenUnits = 100;
% 
% layers = [ ...
%     sequenceInputLayer(numFeatures, Normalization="zscore")
%     lstmLayer(numHiddenUnits, OutputMode="last")
%     fullyConnectedLayer(numResponses)]

%% Specify the training options:
options = trainingOptions("lbfgs", ... % try different solvers
    ExecutionEnvironment="cpu", ...
    Plots="training-progress", ...
    Verbose=false);

%% Train the network using the trainnet function.
net = trainnet(XTrain,TTrain,layers,"mse",options);