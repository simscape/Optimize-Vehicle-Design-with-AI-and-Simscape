function newRunTable = suspOpt_doe_sobol(stepNumber,numRuns)
%Usage: call runSobolDoe with sequential stepNumber values 1:n, and the
%number of runs to generate in each step.  For step 1, the number of runs
%will be numRuns+2 and include the min/max points of the design space
%
%The function writes out the cumulative sobol doe run table and results table 
% with each call
%
%Example: copy to command window
%for i=1:10
%  runSobolDoe(i,100,Vehicle)
%end

%disp("Sobol step: " + stepNumber);

%% Load parameter table
parTableRel = suspOpt_param_rangeRelative;
parTableVal = suspOpt_param_rangeAbsolute(parTableRel);
useIdx = parTableVal.Use;
numVarying = nnz(useIdx);

inputNames = parTableVal.Label;
minBounds = parTableVal.Min(useIdx)';
maxBounds = parTableVal.Max(useIdx)';

% Add a column to the parameter table to use the mean of Min and Max as the Base value
parTableVal.Base = parTableVal.Default;
%save("doeParTable.mat","parTableVal");

% Create a new table if the first step, otherwise read the previous table
%{
if stepNumber==1
    %% Create table for list of runs
    % Initially add 2 runs for the min and max points of the design space,
    % keeping variables with Use==false at the Base value
    inputValues = parTableVal.Base;
    inputValues(useIdx) = parTableVal.Min(useIdx);
    runRowMin = array2table(inputValues',VariableNames=inputNames);
    inputValues(useIdx) = parTableVal.Max(useIdx);
    runRowMax = array2table(inputValues',VariableNames=inputNames);
    runTable = [runRowMin; runRowMax];
else
    load("sobolDoeRunTable" + (stepNumber-1) + ".mat", "runTable");
end
%}
runTable = [];

%% Create sobol sequence to add runs to the DOE using 
%sobolGenerator = sobolset(numVarying,Skip=(height(runTable)-2)); % Generate the next set of runs
sobolGenerator = sobolset(numVarying,Skip=0); % Generate the next set of runs
sobolDesigns = net(sobolGenerator,numRuns);

% Create a doe table for the varying inputs, scaling by the range of the input variables
doeTable = array2table(sobolDesigns,VariableNames=inputNames(useIdx));
doeTable = doeTable.*(maxBounds-minBounds) + minBounds;

%% Add rows to newRunTable
inputValues = parTableVal.Base;
for row=1:height(doeTable)
    runRow = array2table(inputValues',VariableNames=inputNames);
    runRow(1,useIdx) = doeTable(row,:);
    if row==1
        if stepNumber==1
            newRunTable = [runTable; runRow];
        else
            newRunTable = runRow;
        end
    else
        newRunTable = [newRunTable; runRow];
    end
end
