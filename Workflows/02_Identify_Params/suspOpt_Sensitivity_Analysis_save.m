function suspOpt_Sensitivity_Analysis_save(simOut,sensitivities)

%outFieldnames = fieldnames(simOut);
d=simOut(1).getSimulationMetadata.TimingInfo(1).WallClockTimestampStart;
e=strrep(d,'-','');
f=strrep(e,':','');
g=strrep(f,' ','_');
timestamp = g;

foldername  = ['Sens_' timestamp];
if(~exist(foldername,'dir'))
    mkdir(foldername)
end
save([pwd filesep foldername filesep foldername '.mat'],'sensitivities')