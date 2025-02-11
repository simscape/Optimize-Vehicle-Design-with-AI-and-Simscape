function [accuracy, rSquared] = suspOpt_Train_Models_deepLrnTest(XTest,nnModel,truthResponse,metricName,respIndex)

% Obtain predicted response
predictResponse = minibatchpredict(nnModel,XTest,MiniBatchSize=1);
predictResponse = double(predictResponse);

% Calculate accuracy of prediction
accuracy = rmse(predictResponse(:,respIndex),truthResponse(:,respIndex));
rSquared = 1.0 - accuracy.^2/var(truthResponse(:,respIndex));

% If figure handle does not exist, create it
fig_handle_name =   'h1_sm_car_deep_learning_test';
handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))

% Plot predicted response and truth response for metric
metric4title = strrep(metricName(:,respIndex),'Metric','');
scatter(truthResponse(:,respIndex),predictResponse(:,respIndex), "bs");
xlabel("True Value")
ylabel("Predicted Value")
title("Accuracy for " + metric4title + " Metric Preciction"); 
box on
text(0.05,0.9,sprintf('Accuracy RMSE = %1.4f \nR-Squared          = %1.4f', accuracy,rSquared),'Units','Normalized');
refline(1.0,0.0);

% If figure handle does not exist, create it
fig_handle_name =   'h2_sm_car_deep_learning_test';
handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))

% Plot histogram of errors
histogram(mean((truthResponse(:,respIndex) - predictResponse(:,respIndex)).^2,2));
xlabel("Error");
ylabel("Number of Samples");
title("Distribution of " + metric4title + " Metric Prediction Error");