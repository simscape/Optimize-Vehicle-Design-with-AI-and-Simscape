function [solutionsTable,predResponseTable] = addSolResptoTables(sol,descriptText,solutionsTable,predResponseTable,designVarNames,responseVarNames,rollPredict,ridePredict)
% Appends solutions table and predicted response table with results from an
% optimization run.

singleSolTable = array2table(sol.designVars,'VariableNames',designVarNames);
singleSolTable.Description = descriptText;
singleSolTable = movevars(singleSolTable,'Description','Before',1);

solutionsTable = [solutionsTable; singleSolTable];

roll = evaluate(rollPredict,sol);
ride = evaluate(ridePredict,sol);

singleRespTable = array2table([ride,roll],'VariableNames',...
    responseVarNames');
singleRespTable.Description = descriptText;
singleRespTable = movevars(singleRespTable,'Description','Before',1);

predResponseTable = [predResponseTable; singleRespTable];

end