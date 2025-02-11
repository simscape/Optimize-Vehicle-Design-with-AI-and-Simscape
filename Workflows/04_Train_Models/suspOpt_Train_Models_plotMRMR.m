function suspOpt_Train_Models_plotMRMR(dataTable,responseVars)
% suspOpt_Train_Models_plotMRMR  Plot parameter influence on metrics as computed by MRMR algorithm
%   suspOpt_Train_Models_plotMRMR(dataTable,responseVars)
%
%   This function plots the importance of features (predictors) for
%   regression using MRMR algorithm.  A bar chart indicates the sensitivity
%   of design parameters on performance metrics.
%
%     dataTable    Table with design parameter values and resulting metrics
%     responseVars Names of performance metrics.

% Copyright 2024-2025 The MathWorks, Inc.

% If figure handle does not exist, create it
fig_handle_name =   'h1_sm_car_train_models_mrmr';
handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))

normalizedPredictors = standardizeMissing(dataTable(:,1:end-3),{Inf, -Inf});
normalizedPredictors = normalize(normalizedPredictors);
[featureIndex, scores1] = fsrmrmr(normalizedPredictors, dataTable.(responseVars(1)));
sortedFeatureNames = string(dataTable.Properties.VariableNames(featureIndex));
[~, scores2] = fsrmrmr(normalizedPredictors, dataTable.(responseVars(2)));
[~, scores3] = fsrmrmr(normalizedPredictors, dataTable.(responseVars(3)));
scores = [scores1; scores2; scores3];

% Plot in horizontal bar chart, in reverse order
names = sortedFeatureNames(end:-1:1);
values = scores(:,featureIndex(end:-1:1));
barh(names,values,GroupWidth=0.8);
title("Design Parameter Influence on Performance Metrics (MRMR)");
set(gca,'TickLabelInterpreter','none')
legend(responseVars)
