function [accuracy, rSquared] = suspOpt_Train_Models_mchLrn_plotAccuracy(perfMetricName,regressionModel,regMdlName,useMultiOutputModel,testTable)

responseName = perfMetricName;

if useMultiOutputModel
    respIndex = strcmp(responseName,regressionModel.ResponseName);
    idxFcn = @(Y) Y(:,respIndex);
    myPredictFcn = @(predictors) idxFcn(predict(regressionModel, predictors));
else
    myPredictFcn = @(predictors) predict(regressionModel, predictors);
end

% Compute predictions on the test dataset
responseValue = testTable.(responseName);
responsePred = myPredictFcn(testTable);

% Compute root-mean-squared error and R-squared to show model accuracy
accuracy = rmse(responsePred,responseValue);
rSquared = 1.0 - accuracy.^2/var(responseValue);
%disp("Accuracy RMSE = " + accuracy + ", R-Squared = " + rSquared);

% Show scatter plot with 1:1 correlation line, and accuracy values in the title
figure;
plot(responseValue,responsePred,"bs");
xlabel("Value (Simscape model)");
ylabel("Prediction (AI Surrogate)");
title(['Accuracy of ' regMdlName ' for ' char(responseName)]); 
text(0.05,0.9,sprintf('Accuracy RMSE = %1.4f \nR-Squared          = %1.4f', accuracy,rSquared),'Units','Normalized');
axis equal;
refline(1.0,0.0);