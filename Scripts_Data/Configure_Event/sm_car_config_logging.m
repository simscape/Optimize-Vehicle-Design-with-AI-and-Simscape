function sm_car_config_logging(modelname,logType)
%sm_car_config_logging  Configure logging for Simscape Vehicle Templates Model
%   sm_car_config_logging(modelname)
%   This function configures the logging for the Simscape Vehicle Templates Model.
%
% Copyright 2018-2024 The MathWorks, Inc.

if(strcmp(logType,'Normal'))
    FullLog = 'on'; SweepLog = 'off';
else
    FullLog = 'off'; SweepLog = 'on';
end
ph = get_param([modelname '/Driver'],'PortHandles');
set_param(ph.Outport(1),...
    'DataLogging',FullLog,...
    'DataLoggingNameMode','Custom',...
    'DataLoggingName','DrvBus');

ph = get_param([modelname '/Controller'],'PortHandles');
set_param(ph.Outport(1),...
    'DataLogging',FullLog,...
    'DataLoggingNameMode','Custom',...
    'DataLoggingName','CtrlBus');

ph = get_param([modelname '/Vehicle'],'PortHandles');
set_param(ph.Outport(1),...
    'DataLogging',FullLog,...
    'DataLoggingNameMode','Custom',...
    'DataLoggingName','TrlBus');

set_param(ph.Outport(2),...
    'DataLogging',FullLog,...
    'DataLoggingNameMode','Custom',...
    'DataLoggingName','VehBus');

ph = get_param([modelname '/Road'],'PortHandles');
set_param(ph.Outport(1),...
    'DataLogging',FullLog,...
    'DataLoggingNameMode','Custom',...
    'DataLoggingName','RdBus');

ph = get_param([modelname '/Sweep Log Only'],'PortHandles');
set_param(ph.Outport(1),...
    'DataLogging',SweepLog);
set_param(ph.Outport(2),...
    'DataLogging',SweepLog);