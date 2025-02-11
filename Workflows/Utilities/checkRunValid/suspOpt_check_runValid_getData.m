function data_testValid  = suspOpt_check_runValid_getData(out)

for run_i = length(out):-1:1
    data_testValid.logsout_VehBus(run_i) = out(run_i).logsout_sm_car.get('VehBus');
    data_testValid.logsout_DrvBus(run_i) = out(run_i).logsout_sm_car.get('DrvBus');
end

%{
outFieldnames = fieldnames(out);
d=out(1).getSimulationMetadata.TimingInfo(1).WallClockTimestampStart;
e=strrep(d,'-','');
f=strrep(e,':','');
g=strrep(f,' ','_');
timestamp = g;
%}

data_testValid(1).timestamp = getSimOutTimestampStr(out(1));