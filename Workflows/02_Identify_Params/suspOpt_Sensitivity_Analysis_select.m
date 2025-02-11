function labelListSelected = suspOpt_Sensitivity_Analysis_select(rStats,rMethod,parLimit,plotAll)
%suspOpt_Sensitivity_Analysis_select  Select parameters most influential on performance metrics.
%   labelListSelected = suspOpt_Sensitivity_Analysis_select(rStats,rMethod,parLimit,plotAll)
%   This function

% Create string for plot title
if(~startsWith(rMethod,'Correlation'))
    rMethodStr = strrep(rMethod,'Correlation',' Correlation');
    rMethodStr = strrep(rMethodStr,'Regression', ' Regression');
else
    rMethodStr = rMethod;
end

% Use magnitude only to pick influential parameters
senTblSR_abs = abs(rStats.(rMethod));

% Sort parameters by roll and ride metrics
[~,isrtSR_RollMetric] = sortrows(senTblSR_abs,'RollMetric','descend');
[~,isrtSR_RideMetric] = sortrows(senTblSR_abs,'RideMetric','descend');

% Increase number of considered paramters until union of list >= 10
lenList = floor(parLimit/2-1);  % Assume minimum list length
numPar  = floor(parLimit/2-1);  % Minimum number of parameters - each list contributes 5
while(lenList<parLimit)
    numPar = numPar + 1;
    iParUnion = union(isrtSR_RollMetric(1:numPar),isrtSR_RideMetric(1:numPar),'stable');
    lenList = length(iParUnion);
end

% Limit list to 10
iParUnion = sort(iParUnion(1:parLimit));
labelListSelected = rStats.(rMethod).Properties.RowNames(iParUnion);

nPar = height(rStats.Correlation);

%% Plot all sensitivities per standard regressions
% Figure name
if(plotAll)
    figString = ['h1_' mfilename];
else
    figString = ['h1_' mfilename '_sel'];
end

% Only create a figure if no figure exists
figExist = 0;
fig_hExist = evalin('base',['exist(''' figString ''')']);
if (fig_hExist)
    figExist = evalin('base',['ishandle(' figString ') && strcmp(get(' figString ', ''type''), ''figure'')']);
end
if ~figExist
    fig_h = figure('Name',figString);
    assignin('base',figString,fig_h);
else
    fig_h = evalin('base',figString);
end
figure(fig_h)
clf(fig_h)

% Plot all metrics 
% * "stem" saves space, easier to highlight selected
% * "flipud" places front axle at the top, rear axle at the bottom
if(plotAll)
    stem(flipud(rStats.(rMethod).RollMetric),'DisplayName','Roll Metric')
    hold on
    stem(flipud(rStats.(rMethod).RideMetric),'DisplayName','Ride Metric');
else
    stem(flipud(rStats.(rMethod).RollMetric(iParUnion)),'DisplayName','Roll Metric')
    hold on
    stem(flipud(rStats.(rMethod).RideMetric(iParUnion)),'DisplayName','Ride Metric');
end

view(-90,90) % For horizontal stem chart

% Mark selected metrics
if(plotAll)
    yCoord = nPar-iParUnion+1; % Front Axle at top
    plot(yCoord,rStats.(rMethod).RollMetric(iParUnion),'bo','MarkerFaceColor','b','DisplayName','Selected');
    plot(yCoord,rStats.(rMethod).RideMetric(iParUnion),'ro','MarkerFaceColor','r','HandleVisibility','off')
else
    plot(flipud(rStats.(rMethod).RollMetric(iParUnion)),'bo','MarkerFaceColor','b','HandleVisibility','off');
    plot(flipud(rStats.(rMethod).RideMetric(iParUnion)),'ro','MarkerFaceColor','r','HandleVisibility','off')
end
hold off

% Use parameter labels on vertical axis
ax = gca;
if(plotAll)
    nParTotal = length(rStats.(rMethod).RollMetric);
    ax.XTick  = 1:nParTotal;
    % "flipud" places front axle at the top, rear axle at the bottom
    labelList = flipud(rStats.(rMethod).Properties.RowNames);
else
    nParTotal = length(iParUnion);
    ax.XTick  = 1:nParTotal;
    % "flipud" places front axle at the top, rear axle at the bottom
    labelList = flipud(rStats.(rMethod).Properties.RowNames(iParUnion));
end
labelListAx   = strrep(labelList,'_','\_');
ax.XTickLabel = labelListAx;     % Due to view(), x-axis is vertical
ax.XLim       = [0 nParTotal+1]; % Leave space for label at top and bottom
ylabel('Coefficient')
legend('Location','Best')

if(plotAll)
    title(['Sensitivity per ' rMethodStr])
    set(gcf,'Position',[41    81   560   897])
    set(gca,'Position',[0.2360    0.0609    0.6958    0.9008])
else
    title(['Sensitivity per ' rMethodStr ' (only selected)'])
    set(gca,'Position',[0.2270    0.1100    0.6780    0.8150])
end

%{

%% Plot only selected sensitivities per standard regressions
% Figure name
figString = ['h2_' mfilename];
% Only create a figure if no figure exists
figExist = 0;
fig_hExist = evalin('base',['exist(''' figString ''')']);
if (fig_hExist)
    figExist = evalin('base',['ishandle(' figString ') && strcmp(get(' figString ', ''type''), ''figure'')']);
end
if ~figExist
    fig_h = figure('Name',figString);
    assignin('base',figString,fig_h);
else
    fig_h = evalin('base',figString);
end
figure(fig_h)
clf(fig_h)

stem(rStats.(rMethod).RollMetric(iParUnion),'DisplayName','Roll Metric')
hold on
stem(rStats.(rMethod).RideMetric(iParUnion),'DisplayName','Ride Metric');
view(-90,90)

% Mark selected metrics
plot(rStats.(rMethod).RollMetric(iParUnion),'bo','MarkerFaceColor','b','HandleVisibility','off');
plot(rStats.(rMethod).RideMetric(iParUnion),'ro','MarkerFaceColor','r','HandleVisibility','off')
hold off

% Adjust labels
ax = gca;
nParTotal = length(iParUnion);
ax.XTick = 1:nParTotal;
labelList = rStats.(rMethod).Properties.RowNames(iParUnion);
labelListAx = strrep(labelList,'_','\_');
ax.XTickLabel = labelListAx;
ax.XLim = [0 nParTotal+1];
title(['Sensitivity per ' rMethodStr ' (only selected)'])
ylabel('Coefficient')
legend('Location','Best')
set(gca,'Position',[0.2270    0.1100    0.6780    0.8150])
%}