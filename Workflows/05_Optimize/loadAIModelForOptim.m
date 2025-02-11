% loadAIModelForOptim.m
%
% Loads AI model(s)

load aiModels.mat

% Load AI model based on selected model type

% To do: Add checks for SMLT and DLT licenses.  Give error message if
% license missing.

if(strcmp(modelType,"gpModel"))
    % Verify license availability
    if isequal(license('test','Statistics_Toolbox'),0)
        error('Selected model requires a Statistics and Machine Learning Toolbox license.');
    end

    % Load multi-output model, if it exists.  If not, load single-output
    % models for each response
    try
        multiOutModel = aiModels.gpModel;
        useMultiOutputModel = 1;
    catch
        singleOutModel1 = aiModels.gpModel1;
        singleOutModel2 = aiModels.gpModel2;
        useMultiOutputModel = 0;
    end

elseif(strcmp(modelType,"bagModel"))
    % Verify license availability
    if isequal(license('test','Statistics_Toolbox'),0)
        error('Selected model requires a Statistics and Machine Learning Toolbox license.');
    end
    
    % Load multi-output model, if it exists.  If not, load single-output
    % models for each response
    try        
        multiOutModel = aiModels.bagModel;
        useMultiOutputModel = 1;
    catch
        singleOutModel1 = aiModels.bagModel1;
        singleOutModel2 = aiModels.bagModel2;
        useMultiOutputModel = 0;
    end

elseif(strcmp(modelType,"nnModel"))
    % Verify license availability
    if isequal(license('test','Neural_Network_Toolbox'),0)
        error('Selected model requires a Deep Learning Toolbox license.');
    end
    
    % Multi-output model is best-practice for NN.
    multiOutModel = aiModels.nnModel;
    useMultiOutputModel = 1;

end

% Perform a consistency check to verify that the design variables match the AI model predictors.
if ~isequal(designVarNames,trainingTable.Properties.VariableNames(1:10)')
    error('Mismatch between design variable names and model predictor names. Note that order matters.');
end

% Only interested in ride and roll metrics as responses for optimization
% Currently assuming they're the first two metrics
% To do: Could make this more general
responseVarNames = responseVars(1:2);
nResponses = size(responseVarNames,2);