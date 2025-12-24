function fig_h = suspOpt_check_runValid_plot_wSpd(checkData,plotType)
% suspOpt_check_runValid_plot_wSpd  Plot results used to determine run validity
% fig_h = suspOpt_check_runValid_plot_wSpd(checkData,plotType)
%    Create plot of simulation results used to determine if run is valid. 
%  
%    checkData     Data for plotting
%    plotType      'FL', 'FR', 'RL', 'RR', 'all'
%                  Plot toe angle for front left, front right, 
%                      rear left, rear right, or all wheels
%
%    fig_h         Handle to created figure

% Copyright 2023-2025 The MathWorks, Inc.

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
    if(strcmpi(plotType,'FL') || strcmpi(plotType,'all'))
        plot(checkData(run_i).t,checkData(run_i).wSpd(:,1),'DisplayName','FL')
    end
    hold on
    if(strcmpi(plotType,'FR') || strcmpi(plotType,'all'))
        plot(checkData(run_i).t,checkData(run_i).wSpd(:,2),'DisplayName','FR')
    end
    if(strcmpi(plotType,'RL') || strcmpi(plotType,'all'))
        plot(checkData(run_i).t,checkData(run_i).wSpd(:,3),'DisplayName','RL')
    end
    if(strcmpi(plotType,'RR') || strcmpi(plotType,'all'))
        plot(checkData(run_i).t,checkData(run_i).wSpd(:,4),'DisplayName','RR')
    end
end
plot(checkData(run_i).t,checkData(run_i).vSpd,'k--','DisplayName','Veh')

hold off
grid on
title('Wheel Speed')
ylabel('Speed (km/hr)')
xlabel('Time (s)')

if(isscalar(checkData))
    legend('Location','Best')
end