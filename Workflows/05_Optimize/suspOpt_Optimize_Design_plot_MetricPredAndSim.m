function suspOpt_Optimize_Design_plot_MetricPredAndSim(responseComparison)

%% Plot Comparison for Ride Metric
fig_handle_name_root =  'sm_car_opt_res_and_sim';
fig_handle_name      =  ['h1_' fig_handle_name_root];

handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))
clf(evalin('base',fig_handle_name))

b_ri=barh(flipud([responseComparison.predResponseTable(:,2).Variables responseComparison.simResponseTable(:,1).Variables]));
temp_colororder = get(gca,'defaultAxesColorOrder');
b_ri(1).FaceColor = temp_colororder(3,:);
b_ri(2).FaceColor = temp_colororder(4,:);

ax_h = gca;
ax_h.YTickLabel = flipud(responseComparison.predResponseTable(:,1).Variables);
title('Ride Metric Validation with Simulation')
legend({'Prediction','Simulation'},'Location','Best')
set(gcf,"Position",[502   507   560   356]);
set(gca,"Position",[0.2607    0.1100    0.6929    0.8150]);

%% Plot Comparison for Roll Metric
fig_handle_name      =  ['h2_' fig_handle_name_root];
handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))
clf(evalin('base',fig_handle_name))

b_ro = barh(flipud([responseComparison.predResponseTable(:,3).Variables responseComparison.simResponseTable(:,2).Variables]));
b_ro(1).FaceColor = temp_colororder(3,:);
b_ro(2).FaceColor = temp_colororder(4,:);

ax_h = gca;
ax_h.YTickLabel = flipud(responseComparison.predResponseTable(:,1).Variables);
title('Roll Metric Validation with Simulation')
legend({'Prediction','Simulation'},'Location','Best')
set(gcf,"Position",[502   507   560   356]);
set(gca,"Position",[0.2607    0.1100    0.6929    0.8150]);

