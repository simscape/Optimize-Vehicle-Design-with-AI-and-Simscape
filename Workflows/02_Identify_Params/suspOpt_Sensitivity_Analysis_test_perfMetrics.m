perfMetrics = suspOpt_calc_perf_metric_data(perfData,false);

opts = sdo.AnalyzeOptions;
opts.Method = 'All';
opts.MethodOptions = 'All';
rStats = sdo.analyze(runTableSense_OUT, perfMetrics, opts);

numParTrim = 8;
labelList_SR = suspOpt_Sensitivity_Analysis_select(rStats,'StandardizedRegression',numParTrim,true);
% Plot only top parameters
suspOpt_Sensitivity_Analysis_select(rStats,'StandardizedRegression',numParTrim,false)
