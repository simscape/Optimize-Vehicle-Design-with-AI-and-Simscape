function [roll_metric, ride_metric] = suspOpt_plot_Response_Surf(varLabelX,varLabelY,queryPoint,parTable,perfMetricName,regressionModel,varargin)
% suspOpt_plot_Response_Surf  Plot response surface for performance metric
%   [roll_metric, ride_metric] = suspOpt_plot_Response_Surf(varLabelX,varLabelY,queryPoint,parTable,perfMetricName,regressionModel,varargin)
%
%   This function plots the response surface for a performance metric as
%   two design parameters are varied over their range. The remaining design
%   parameters are held at fixed values.
%
%     varLabelX       Label for first design parameter  (HP_xx_xx...)
%     varLabelX       Label for second design parameter  (HP_xx_xx...)
%     queryPoint      Specific values for all design parameters
%     parTable        Table with full information for all design parameters
%     perfMetricName  Name of metric to be plotted
%     regressionModel AI surrogate model for prediction
%     varargin{1}     Optional axis handle for plot.
%
%   The axis handle is an optional input so that this code can plot the results on
%   axes within an App or a standalone figure.

% Copyright 2024-2025 The MathWorks, Inc.

if(nargin==7)
    % Create plot on supplied axis handle
    ax_h = varargin{1};
else
    % If figure handle does not exist, create it
    fig_handle_name =   'h1_sm_car_plot_resp_surface';
    handle_var = evalin('base',['who(''' fig_handle_name ''')']);
    if(isempty(handle_var))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    elseif ~isgraphics(evalin('base',handle_var{:}))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    end
    figure(evalin('base',fig_handle_name))
    ax_h = gca;
end

% Graph response surface function plots for the query point
responseName = perfMetricName;
respIndex = strcmp(responseName,regressionModel.ResponseName);

%if useMultiOutputModel
    idxFcn = @(Y) Y(:,respIndex);
    myPredictFcn = @(predictors) idxFcn(predict(regressionModel, predictors));
%else
%    myPredictFcn = @(predictors) predict(regressionModel1, predictors);
%end

% Compute predictor limits for plots
rangeMinX = parTable(strcmp(parTable.Label,varLabelX),"Min").Variables;
rangeMaxX = parTable(strcmp(parTable.Label,varLabelX),"Max").Variables;
rangeMinY = parTable(strcmp(parTable.Label,varLabelY),"Min").Variables;
rangeMaxY = parTable(strcmp(parTable.Label,varLabelY),"Max").Variables;
valueCount = 25;

% Create a table of predictors varying only along two selected variables
xValues = linspace(rangeMinX,rangeMaxX,valueCount)';
yValues = linspace(rangeMinY,rangeMaxY,valueCount)';
    
plotPredictors = table();
for i = 1:valueCount
    plotPredictorsAdd = repelem(queryPoint,valueCount,1);
    plotPredictorsAdd.(varLabelX) = repmat(xValues(i),valueCount,1);
    plotPredictorsAdd.(varLabelY) = yValues;
    plotPredictors = [plotPredictors; plotPredictorsAdd];
end

% Compute the response values
plotResponse = myPredictFcn(plotPredictors)';

% Compute query point value
plotPredictorQP = queryPoint;
plotResponseQP  = myPredictFcn(plotPredictorQP)';

% Compute Roll and Ride Metrics for return argument
responseNameRoll = "RollMetric";
respIndexRoll    = strcmp(responseNameRoll,regressionModel.ResponseName);
responseNameRide = "RideMetric";
respIndexRide    = strcmp(responseNameRide,regressionModel.ResponseName);
idxFcnRoll       = @(Y) Y(:,respIndexRoll);
myPredictFcnRoll = @(predictors) idxFcnRoll(predict(regressionModel, predictors));
idxFcnRide       = @(Y) Y(:,respIndexRide);
myPredictFcnRide = @(predictors) idxFcnRide(predict(regressionModel, predictors));
roll_metric      = myPredictFcnRoll(plotPredictorQP)';
ride_metric      = myPredictFcnRide(plotPredictorQP)';

% Rearrange into 2D arrays
[xValues2d,yValues2d] = meshgrid(xValues,yValues);
zValues2d = reshape(plotResponse,[valueCount,valueCount]);

% NOTE - In addition to ranges, two parameter constraints should be applied
%        to avoid excessive bump steer
% 1. HP_A1_Ro_Inbz - HP_A1_Ro_Outz >= -0.05
% 2. HP_A1_Ro_Inbz - HP_A1_Ro_Outz <=  0.04
% If these conditions are met, add red dots to response surface
if(strcmp(varLabelX,'HP_A1_Ro_Outz') && strcmp(varLabelY,'HP_A1_Ro_Inbz'))
    badPtsA = (xValues2d-yValues2d)> 0.04;
    badPtsB = (xValues2d-yValues2d)<-0.05;
    badPts  = badPtsA + badPtsB;
elseif(strcmp(varLabelY,'HP_A1_Ro_Outz') && strcmp(varLabelX,'HP_A1_Ro_Inbz'))
    badPtsA = (yValues2d-xValues2d)> 0.04;
    badPtsB = (yValues2d-xValues2d)<-0.05;
    badPts  = badPtsA + badPtsB;
else
    badPts = [];
end

% Create surface plot
surf(ax_h,xValues2d,yValues2d,zValues2d,FaceAlpha=0.5);
colorbar(ax_h)
xlabel(ax_h,varLabelX,Interpreter="none");
ylabel(ax_h,varLabelY,Interpreter="none");
zlabel(ax_h,responseName,'FontWeight','bold');
perfMetricNameStr = char(strrep(perfMetricName,'Metric',' Metric'));
title(ax_h,['Response Surface for ' perfMetricNameStr],'FontSize',14);
box(ax_h,'on');
grid(ax_h,'on');
hold(ax_h,'on');
qpx = queryPoint.(varLabelX);
qpy = queryPoint.(varLabelY);
qpz = plotResponseQP;
plot3(ax_h,qpx,qpy,qpz,'o','MarkerFaceColor',[0 0 1],'MarkerSize',8);

if(~isempty(badPts))
    % If infeasible points are found, mark them.
    badInds = find(badPts);
    lh(1) = plot3(ax_h,xValues2d(badInds),yValues2d(badInds),zValues2d(badInds),'ro',...
        'MarkerFaceColor','r','MarkerSize',4);
    text(ax_h,0.1,0.8,0.5,'Infeasible Point','Color','r','Units','Normalized')
end
hold(ax_h,'off');

% Code to produce contour plot 
%{
% Show a filled contour plot
figure;
contourf(xValues2d,yValues2d,zValues2d);
colorbar
xlabel(varLabelX,Interpreter="none");
ylabel(varLabelY,Interpreter="none");
zlabel(responseName);
%}