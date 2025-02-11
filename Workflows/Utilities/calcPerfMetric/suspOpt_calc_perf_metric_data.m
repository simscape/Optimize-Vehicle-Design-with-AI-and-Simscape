function perfMetrics = suspOpt_calc_perf_metric_data(perfData)

for r_i = 1:length(perfData)
    time_allMs    = perfData(r_i).t;
    data_aRoll    = perfData(r_i).aRoll;
    data_xVeh     = perfData(r_i).xVeh;
    data_gzVeh    = perfData(r_i).gzVeh;
    data_nRollCG  = perfData(r_i).nRollCG;
    data_nPitchCG = perfData(r_i).nPitchCG;

    % Resample for calculating L2 Norm
    tSampRoll  = 12:0.05:19;
    rSamp  = interp1(time_allMs,data_aRoll,tSampRoll,'linear');

    % Resample for calculating discomfort
    tSampDisc  = (8.5:0.01:11)';
    nrSamp = interp1(time_allMs,  data_nRollCG, tSampDisc,'linear');
    npSamp = interp1(time_allMs, data_nPitchCG, tSampDisc,'linear');
    gzSamp = interp1(time_allMs,    data_gzVeh, tSampDisc,'linear');

    % Calculate L2 Norm
    roll_metric(r_i)  = norm(rSamp,2);

    % Calculate stopping distance
    tbrk_sta        = find(time_allMs>=20,1);
    brak_metric(r_i)  = data_xVeh(end)-data_xVeh(tbrk_sta);

    % Calculate discomfort
    % Obtain roll acceleration, pitch acceleration
    gRollSamp  = gradient(nrSamp)./gradient(tSampDisc);
    gPitchSamp = gradient(npSamp)./gradient(tSampDisc);

    % Calculate magnitude of vertical, roll, and pitch acceleration
    ride_metric(r_i) =  1/(tSampDisc(end)-tSampDisc(1)) * trapz( tSampDisc, ...
        sqrt(gzSamp.^2 + gRollSamp.^2 + gPitchSamp.^2) );
end

perfMetrics = array2table([ride_metric' roll_metric' brak_metric'],...
    'VariableNames',{'RideMetric','RollMetric','BrakMetric'});

