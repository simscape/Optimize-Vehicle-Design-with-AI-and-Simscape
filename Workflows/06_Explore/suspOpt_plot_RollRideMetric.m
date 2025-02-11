function suspOpt_plot_RollRideMetric(perfData,perfMetrics,ah_roll,ah_ride)
% suspOpt_plot_RollRideMetric  Plot data used to calculate performance metric
%   suspOpt_plot_RollRideMetric(perfData,perfMetrics,ah_roll,ah_ride)
%
%   This function plots the simulation results that are used to calculate
%   the performance metrics.  The plot shows the dynamic behavior for a
%   given design.
%
%     perfData    Simulation results used to calculate performance metrics
%     perfMetrics Calculated performance metrics from this test
%     ah_roll     Axis handle for where roll metric data should be plotted
%     ah_ride     Axis handle for where ride metric data should be plotted
%
%   The axis handles are required so that this code can plot the results on
%   axes within an App or a standalone figure.

% Copyright 2024-2025 The MathWorks, Inc.

cla(ah_roll);
cla(ah_ride);

for r_i = 1:length(perfData)
    time_allMs    = perfData(r_i).t;
    data_aRoll    = perfData(r_i).aRoll*180/pi;
    data_xVeh     = perfData(r_i).xVeh;
    data_gzVeh    = perfData(r_i).gzVeh;
    data_nRollCG  = perfData(r_i).nRollCG;
    data_nPitchCG = perfData(r_i).nPitchCG;

    tSampDisc  = (0:0.01:time_allMs(end))';
    nrSamp = interp1(time_allMs,  data_nRollCG, tSampDisc,'linear');
    npSamp = interp1(time_allMs, data_nPitchCG, tSampDisc,'linear');
    nzSamp = interp1(time_allMs,  data_gzVeh, tSampDisc,'linear');

    gRollSamp  = gradient(nrSamp)./gradient(tSampDisc);
    gPitchSamp = gradient(npSamp)./gradient(tSampDisc);

    rollMetric = perfMetrics(r_i,"RollMetric").Variables;

    tlimRoll = [12 19];
    mlimRoll = [-0.2 0.2];
    if(r_i == 1)
        rh(1) = patch(ah_roll,tlimRoll([1 2 2 1]),mlimRoll([1 1 2 2]),[102 255 255]/255, 'FaceAlpha','0.5','EdgeColor','none','DisplayName','');
    end
    hold(ah_roll,'on');
    if(isfield(perfData,'runName'))
        dispString = [num2str(['Metric: ' sprintf('%1.3f',rollMetric)]) ' ' perfData(r_i).runName];
    else
        dispString = [num2str(['Metric: ' sprintf('%1.3f',rollMetric)]) ...
            ' Test ' pad('0',length(num2str(length(perfData))),'left')];
    end   

    rh(r_i+1) = plot(ah_roll,time_allMs,data_aRoll,'LineWidth',2,'DisplayName',dispString);
    hold(ah_roll,'off');
    title(ah_roll,'Roll Angle');
    box(ah_roll,'on');
    grid(ah_roll,'on');
    if(isscalar(perfData))
    text(ah_roll,0.05,0.9,['Roll Metric: ' sprintf('%1.3f',rollMetric)],'Units','Normalized',...
        'Color',[0 0 1],'BackgroundColor',[220 255 255]/255,'FontWeight','bold');
    end
    xlabel(ah_roll,'Time (s)');
    ylabel(ah_roll,'deg');
    if(~isscalar(perfData) && length(perfData)<10)
        legend(ah_roll,rh(2:end),'Location','SouthWest','Color',[200 255 255]/255);
    else
        legend(ah_roll,'off')
    end

    %% Plot Ride Metric
    tlimRide = [8.5 11];
    pClr = [102 255 255]/255;
    pFaceAlpha = 0.5;
    rideMetric = perfMetrics(r_i,"RideMetric").Variables;

    if(isscalar(perfData))
        mlimRide = [-1 1];
        lh(1) = patch(ah_ride,tlimRide([1 2 2 1]),mlimRide([1 1 2 2]),pClr, 'FaceAlpha',pFaceAlpha,'EdgeColor','none','DisplayName','');
        hold(ah_ride,'on');
        lh(2) = plot(ah_ride,time_allMs,data_gzVeh,'LineWidth',2,'DisplayName','Acc. Vertical');
        lh(3) = plot(ah_ride,tSampDisc,gRollSamp,'LineWidth',2,'DisplayName','Acc. Roll');
        lh(4) = plot(ah_ride,tSampDisc,gPitchSamp,'LineWidth',2,'DisplayName','Acc. Pitch');
        legend(ah_ride,lh(2:4),'Location','SouthWest');
        text(ah_ride,0.05,0.9,['Ride Metric: ' sprintf('%1.3f',rideMetric)],'Units','Normalized',...
            'Color',[0 0 1],'BackgroundColor',[220 255 255]/255,'FontWeight','bold');
    else
        mlimRide = [0 1];
        if(r_i == 1)
            lh(1) = patch(ah_ride,tlimRide([1 2 2 1]),mlimRide([1 1 2 2]),pClr, 'FaceAlpha',pFaceAlpha,'EdgeColor','none','DisplayName','');
        end
        hold(ah_ride,'on');
        lh(r_i+1) = plot(ah_ride,tSampDisc,sqrt(nzSamp.^2 + gRollSamp.^2 + gPitchSamp.^2),'LineWidth',2,'DisplayName',num2str(['Metric: ' sprintf('%1.3f',rideMetric)]));
        if(length(perfData)<10)
        legend(ah_ride,lh(2:end),'Location','SouthWest','Color',[200 255 255]/255);
        end
    end
    hold(ah_ride,'off');
    title(ah_ride,'Body Accelerations');
    box(ah_ride,'on');
    grid(ah_ride,'on');
    xlabel(ah_ride,'Time (s)');
    ylabel(ah_ride,'m/s^2 or rad/s^2');

    % For animation only
    %{
    title(ah_roll,'Roll Angle','FontSize',18);
    xlabel(ah_roll,'Time (s)','FontSize',14);
    ylabel(ah_roll,'deg','FontSize',14);
    set(ah_roll,'XLim',[12 19]);
    set(ah_roll,'YLim',[-2.2 2.2]);

    title(ah_ride,'Body Acceleration','FontSize',18);
    xlabel(ah_ride,'Time (s)','FontSize',14);
    ylabel(ah_ride,'sqrt(gzBody^2 + gPitch^2 + gRoll^2)','FontSize',14);
    set(ah_ride,'XLim',[8.7 11]);
    set(ah_ride,'YLim',[0 9]);
    
    pause(1e-2)
    %}
end
