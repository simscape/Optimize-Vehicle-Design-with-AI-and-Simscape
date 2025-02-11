function timestampStr = getSimOutTimestampStr(out)
outFieldnames = fieldnames(out);
d=out(1).getSimulationMetadata.TimingInfo(1).WallClockTimestampStart;
e=strrep(d,'-','');
f=strrep(e,':','');
g=strrep(f,' ','_');
timestampStr = g;