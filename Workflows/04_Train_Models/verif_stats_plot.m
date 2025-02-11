function [model_rmse, model_rSquared] = verif_stats_plot(ypred,ytruth,modelname,responseVars)

% Compute RMSE
model_rmse = rmse(ypred,ytruth);

% Compute R-squared to show model accuracy
model_rSquared = 1.0 - model_rmse.^2/var(ytruth);

% Show scatter plot with 1:1 correlation line, and accuracy values in the title
% figure;
plot(ytruth,ypred,"bs");
xlabel("True Value");
ylabel("Predicted Value");
title({modelname, "Prediction accuracy on " + responseVars});
text(0.05,0.9,sprintf('Accuracy RMSE = %1.4f \nR-Squared          = %1.4f', model_rmse,model_rSquared),'Units','Normalized');
axis equal;
refline(1.0,0.0);