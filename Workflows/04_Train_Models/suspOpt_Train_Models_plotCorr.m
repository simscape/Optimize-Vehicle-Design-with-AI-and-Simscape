function suspOpt_Train_Models_plotCorr(dataTable,inputVars,responseVars)

%% Plot in Heat Map
% If figure handle does not exist, create it
fig_handle_name =   'h1_sm_car_train_models_corr';
handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))

useColormap = turbo;
dataCorr = corr(dataTable{:,:});
h = heatmap(dataTable.Properties.VariableNames, dataTable.Properties.VariableNames,dataCorr,Colormap=useColormap,Interpreter="none");
clim([-1,1]);
title("Correlation of Predictors and Response");

%% Plot in horizontal bar chart
% If figure handle does not exist, create it
fig_handle_name =   'h2_sm_car_train_models_corr';
handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))

names = inputVars(end:-1:1); % Reverse order so first variable is on the top
values = dataCorr(end-2:end,end-3:-1:1);
barh(names,values,GroupWidth=0.8);
title("Correlation of Design Parameters to Response");
set(gca,'TickLabelInterpreter','none')
legend(responseVars)

