% initializeSolTables.m
%
% Initializes solution and predicted response tables to store results from
% the optimizations.

solTableVarTypes = cell(1,nDesignVars+1);
solTableVarTypes(1) = {'string'};
solTableVarTypes(2:end) = {'double'};

respTableVarTypes = cell(1,nResponses+1);
respTableVarTypes(1) = {'string'};
respTableVarTypes(2:end) = {'double'};

solutionsTable = table('Size',[0, nDesignVars+1],'VariableTypes',solTableVarTypes,'VariableNames',[{'Description'},designVarNames']);
predResponseTable = table('Size',[0, nResponses+1],'VariableTypes',respTableVarTypes,'VariableNames',[{'Description'},responseVarNames]);

% To do: Could generalize variable naming code instead of hard-coding
simResponseTable = table('Size',[0, nResponses],'VariableTypes',respTableVarTypes(2:end),'VariableNames',{'RideMetric','RollMetric'});
predErrTable = table('Size',[0, nResponses],'VariableTypes',respTableVarTypes(2:end),'VariableNames',{'Ride % Error','Roll % Error'});