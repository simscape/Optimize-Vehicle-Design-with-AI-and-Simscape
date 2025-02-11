function fig_h = suspOpt_check_runValid_plot_aToe(checkData,plotType)
% suspOpt_check_runValid_plot_aToe  Plot results used to determine run validity
% fig_h = suspOpt_check_runValid_plot_aToe(checkData,plotType)
%    Create plot of simulation results used to determine if run is valid. 
%  
%    checkData     Data for plotting
%    plotType      'left', 'right', 'all'
%                  Plot toe angle for left wheel, right wheel, or all wheels
%
%    fig_h         Handle to created figure

% Copyright 2023-2024 The MathWorks, Inc.


% Figure name
figString = ['h1_' mfilename];
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

for run_i = 1:length(checkData)
    if(strcmpi(plotType,'left') || strcmpi(plotType,'all'))
        plot(checkData(run_i).t,checkData(run_i).aToeL*180/pi,'DisplayName','Left')
    end
    hold on
    if(strcmpi(plotType,'right') || strcmpi(plotType,'all'))
        plot(checkData(run_i).t,checkData(run_i).aToeR*180/pi,'DisplayName','Right')
    end
end
title(['Toe Angle, ' plotType])
xlabel('Time (s)')
ylabel('Toe Angle (deg)')
grid on
hold off
if(isscalar(checkData))
    legend('Location','Best')
end
