function suspOpt_sweep_param_limits_plotVariance(RangeSweepResTable)
%% Plot variance in roll metric

figPos = [47   144   616   844];

fig_handle_name_root =  'sm_car_metric_variance';
fig_handle_name      =  ['h1_' fig_handle_name_root];

handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))
clf(evalin('base',fig_handle_name))


numPars = size(RangeSweepResTable,1); 
ah(1) = subplot(121);
RollMax = max([RangeSweepResTable.RollMn RangeSweepResTable.RollMx],[],'all');

barh(RangeSweepResTable.DiffRoll(1:numPars/2)/RollMax*100);
temp_colororder = get(gca,'defaultAxesColorOrder');

ah(1).YTick = 1:numPars/2;
ah(1).YTickLabel = strrep((RangeSweepResTable.Label(1:numPars/2)),'_','\_');
title(ah(1),['Variance/Max Value of Stability Metric (1-' num2str(numPars/2) ')'])
xlabel('% Change in Metric')

ah(2) = subplot(122);
barh(RangeSweepResTable.DiffRoll(numPars/2+1:end)/RollMax*100);
ah(2).YTick = 1:numPars/2;
ah(2).YTickLabel = strrep((RangeSweepResTable.Label((numPars/2+1):end)),'_','\_');
title(ah(2),['(' num2str(numPars/2+1) '-' num2str(numPars) ')'])
xlabel('% Change in Metric')

linkaxes(ah,'x')
set(gcf,'Position',figPos)

%%
fig_handle_name      =  ['h2_' fig_handle_name_root];
handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))
clf(evalin('base',fig_handle_name))

numPars = size(RangeSweepResTable,1); 
ahr(1) = subplot(121);
rideMax = max([RangeSweepResTable.RideMn RangeSweepResTable.RideMx],[],'all');
barh(RangeSweepResTable.DiffRide(1:numPars/2)/rideMax*100,'FaceColor',temp_colororder(2,:));
ahr(1).YTick = 0:numPars/2;
ahr(1).YTickLabel = strrep(([{' '};RangeSweepResTable.Label(1:numPars/2)]),'_','\_');
title(ahr(1),['Variance/Max Value of Comfort Metric (1-' num2str(numPars/2) ')'])
xlabel('% Change in Metric')

ahr(2) = subplot(122);
barh(RangeSweepResTable.DiffRide(numPars/2+1:end)/rideMax*100,'FaceColor',temp_colororder(2,:));
ahr(2).YTick = 0:numPars/2;
ahr(2).YTickLabel = strrep(([{' '};RangeSweepResTable.Label((numPars/2+1):end)]),'_','\_');
title(ahr(2),['(' num2str(numPars/2+1) '-' num2str(numPars) ')'])
xlabel('% Change in Metric')

linkaxes(ahr,'x')
set(gcf,'Position',figPos)

%%
fig_handle_name      =  ['h3_' fig_handle_name_root];

handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))
clf(evalin('base',fig_handle_name))

numPars = size(RangeSweepResTable,1); 
ahb(1) = subplot(121);
BrakMax = max([RangeSweepResTable.BrakMn RangeSweepResTable.BrakMx],[],'all');
barh(RangeSweepResTable.DiffBrak(1:numPars/2)/BrakMax*100,'FaceColor',temp_colororder(3,:));
ahb(1).YTick = 0:numPars/2;
ahb(1).YTickLabel = strrep(([{' '};RangeSweepResTable.Label(1:numPars/2)]),'_','\_');
title(ahb(1),['Variance/Max Value of Safety Metric (1-' num2str(numPars/2) ')'])

ahb(2) = subplot(122);
barh(RangeSweepResTable.DiffBrak(numPars/2+1:end)/BrakMax*100,'FaceColor',temp_colororder(3,:));
ahb(2).YTick = 0:numPars/2;
ahb(2).YTickLabel = strrep(([{' '};RangeSweepResTable.Label((numPars/2+1):end)]),'_','\_');
title(ahb(2),['(' num2str(numPars/2+1) '-' num2str(numPars) ')'])

linkaxes(ahb,'x')
set(gcf,'Position',figPos)


commonMaxX = max([ah(1).XLim(2) ahr(1).XLim(2) ahb(1).XLim(2)]);

ah(1).XLim = [0 commonMaxX];
ahr(1).XLim = [0 commonMaxX];
ahb(1).XLim = [0 commonMaxX];



