function suspOpt_Optimize_Design_plot_ParamAndDefault(solutionsTable)

%% Plot Deviation from Default for Each Optimization Result

% Load table with parameters to tune
load("parTableVal_trimSensitivity.mat");
parTableVal = parTableVal_trim;
useRows    = parTableVal.Use == true;
inflParTbl = flipud(sortrows(parTableVal(useRows,:)));
inflParTbl.Range = inflParTbl.Max-inflParTbl.Min;

% Loop over optimization results 
fig_h = figure;
figNum = fig_h.Number;
for sol_i = 1:height(solutionsTable)
    if(sol_i>1)
        figure(figNum+(sol_i-1));
    end
    ax(sol_i) = gca;

    % Loop over parameters
    for par_i = 1:height(inflParTbl)
        LabelName = inflParTbl(par_i,"Label").Variables;
        yLabelStr(par_i) = LabelName;

        % Calculate difference        
        deltaPar(sol_i,par_i) = inflParTbl(par_i,"Default").Variables-solutionsTable(sol_i,LabelName).Variables;

        % Plot range
        minRange = inflParTbl(par_i,"Default").Variables-inflParTbl(par_i,"Min").Variables;
        maxRange = inflParTbl(par_i,"Default").Variables-inflParTbl(par_i,"Max").Variables;
        hgtPtch = 0.2;
        patch([minRange maxRange maxRange minRange],[-1 -1 1 1]*hgtPtch+par_i,'k','FaceAlpha',0.2,'EdgeColor','none');

        hold(ax(sol_i),'on')

        % Plot delta
        plot([0 deltaPar(sol_i,par_i)],[1 1]*par_i,'-kd');

        % Fill location marking delta from default
        plot(deltaPar(sol_i,par_i),par_i,'-kd','MarkerFaceColor','k','MarkerSize',8);
    end
    hold(ax(sol_i),'off')
    box(ax(sol_i),'on')
    title(ax(sol_i),['Adjustments for ' char(solutionsTable(sol_i,1).Variables)]);
    ax(sol_i).YTick      = 1:height(inflParTbl);
    ax(sol_i).YTickLabel = yLabelStr;
    ax(sol_i).TickLabelInterpreter = 'none';
    set(ax(sol_i),'YLim',[0 height(inflParTbl)+1])
    xlabel(ax(sol_i),'Deviation from Default');
    set(gcf,'Position',[680   446   560   351]);
    set(gca,'Position',[0.2393    0.1259    0.6657    0.7991])
end

