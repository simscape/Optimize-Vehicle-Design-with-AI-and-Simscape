function simOutMetaData = plot_simOutStats(simOut)

for i=1:length(simOut)
    exec_time(i)  = simOut(i).SimulationMetadata.TimingInfo.ExecutionElapsedWallTime;
    nSteps(i)     = length(simOut(i).tout);
    total_time(i) = simOut(i).SimulationMetadata.TimingInfo.TotalElapsedWallTime;
end

figure
bar(exec_time)
xlabel('Run #')
ylabel('Time (s)')
title(['Execution Time (Total: ' num2str(sum(exec_time)/60) ' minutes)'])
text(0.01,0.96,'# Steps','Units','Normalized')

for j = 1:length(exec_time)
    text(j, exec_time(j), num2str(nSteps(j)),...
        'VerticalAlignment','baseline',...
        'HorizontalAlignment','center');
end

simOutMetaData.exec_time = exec_time;
simOutMetaData.nSteps = nSteps;
simOutMetaData.total_time = total_time;
