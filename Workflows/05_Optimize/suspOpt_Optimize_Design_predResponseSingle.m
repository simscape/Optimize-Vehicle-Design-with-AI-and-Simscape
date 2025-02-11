function response = suspOpt_Optimize_Design_predResponseSingle(designVariables,model)
% Returns predicted response value, given an AI model and row of design
% variable values

responsePredict = predict(model,designVariables);

% Ensure response value is a double.  Deep learning model predictions
% return as single, but optimization solvers expect double.
response = double(responsePredict);

end