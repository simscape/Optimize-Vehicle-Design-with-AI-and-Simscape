function response = suspOpt_Optimize_Design_predResponseMulti(designVariables,model,respIdx)
% Returns predicted response value for one response variable indicated by index respIdx,
% given a multi-response AI model and row of design variable values

responsesPredictMulti = predict(model,designVariables);

% Prepare to return the response variable indicated by the index
responsePredictOne = responsesPredictMulti(:,respIdx);

% Ensure response value is a double.  Deep learning model predictions
% return as single, but optimizaion solvers expect double.
response = double(responsePredictOne);

end