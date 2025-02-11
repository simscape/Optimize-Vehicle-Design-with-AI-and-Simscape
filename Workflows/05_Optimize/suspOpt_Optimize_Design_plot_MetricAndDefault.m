function suspOpt_Optimize_Design_plot_MetricAndDefault(responseTable)

% Normalize Ride, Roll with respect to Default design
% Find index of default results
defIdx = find(matches(responseTable.Description,"Default"));

% Normalize
normRide = responseTable(:,2).Variables'/(responseTable(defIdx,2).Variables');
normRoll = responseTable(:,3).Variables'/(responseTable(defIdx,3).Variables');

% Reuse figure if it exists, else create new figure
fig_handle_name =   'h1_compare_metric_default_opt';

handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))
clf(evalin('base',fig_handle_name))


% flipud puts default at top
barh(flipud([normRoll;normRide]'),GroupWidth=0.8)
ax_h = gca;
% flipud puts default at top
ax_h.YTickLabel = flipud(responseTable(:,1).Variables);
legend({'Roll','Ride'},'Location','Best')
set(gca,'Position',[0.2482    0.1100    0.6568    0.8150])

title('Compare Performance Metrics (Normalized)')
xlabel('Normalized Performance Metrics')


% For Slides
% set(gcf,'Position',[3167 751 619.3333 330]);
% set(gca,'Position',[0.3108 0.1807 0.6311 0.7109]);
% set(gca,'FontSize',14.'FontWeight','bold');
% title font = 20