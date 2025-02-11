function fig_h = suspOpt_check_runValid_plot_yPth(checkData)
% suspOpt_check_runValid_plot_yPth  Plot results used to determine run validity
% fig_h = suspOpt_check_runValid_plot_yPth(checkData)
%    Create plot of simulation results used to determine if run is valid. 
%  
%    checkData     Data for plotting
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
    plot(checkData(run_i).t,checkData(run_i).yPth)
    hold on
end
title('Lateral Deviation from Path')
xlabel('Time (s)')
ylabel('Deviation (m)')
grid on
hold off
