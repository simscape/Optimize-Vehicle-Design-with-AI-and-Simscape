function [runTable,simOutFR] = runSimulations(mdl,Vehicle,parTableVal,runTable,filterInputConstraints,showPlot)

% filterInputConstraints is an optional input, so that Optimization step
% can skip filtering, since Optimization already enforces constraints (to
% within a small tolerance)
% If filterInputConstraints is not specified, set it to true
if nargin < 5
    filterInputConstraints = true;
end
% showPlot is an optional input, so that Optimization step can disable
% simulation validity plots
if nargin < 6
    showPlot = true;
end

%% Prepare vehicle (loaded by project)
% Ensure tire radius has been added to correct fields
Vehicle = sm_car_vehcfg_checkConfig(Vehicle);

numParameterSets = height(runTable);

% Check for constraints before running
if filterInputConstraints
    % Constraint specified in sweep_all_param.m
    idx = ((runTable.HP_A1_Ro_Inbz - runTable.HP_A1_Ro_Outz)>=-0.05);
    runTable = runTable(idx,:);
    idx = ((runTable.HP_A1_Ro_Inbz - runTable.HP_A1_Ro_Outz)<=0.04);
    runTable = runTable(idx,:);    
end

numValidSets = height(runTable);
disp([num2str(numParameterSets) ' parameter sets submitted, ' num2str(numValidSets) ' obey parameter constraints.']);
disp(' ');

%% Set up simulation input objects the runs in runTable
% Count number of runs
numFRTests = height(runTable);
numPars = height(parTableVal);

% Create empty simulation input objects
clear simInputFR
simInputFR(1:numFRTests) = Simulink.SimulationInput(mdl);

% Loop over runs
for r_i=1:numFRTests

    % Load default data structure
    Vehicle_data;
    % Check default data structure
    Vehicle_def = sm_car_vehcfg_checkConfig(Vehicle);
    Vehicle = Vehicle_def;

    % Loop over all parameters
    for p_i=1:numPars
    
        % Overwrite field in default Vehicle structure
        Vehicle = suspOpt_param_assign(parTableVal,p_i,runTable{r_i,p_i},Vehicle);

    end

    % Create a label for each run
    UserString_SimInput = "DOE Run " + r_i;

    % Set vehicle in Simulation Input 
    simInputFR(r_i) = setVariable(simInputFR(r_i),'Vehicle',Vehicle);
    simInputFR(r_i).UserString = UserString_SimInput;
    simInputFR(r_i) = setModelParameter(simInputFR(r_i),SimMechanicsOpenEditorOnUpdate="off");
    simInputFR(r_i) = simInputFR(r_i).setModelParameter('initFcn','');
    simInputFR(r_i) = setModelParameter(simInputFR(r_i),SimscapeLogType="None");
end

%% Run simulations FAST RESTART

timerValFR = tic;
clear simOutFR

% Run with with FastRestart ON, parallel ON
curr_proj = simulinkproject;
p = parpool;
p.addAttachedFiles(which('Custom_lib.slx'));
p.addAttachedFiles(curr_proj.RootFolder + "\Libraries\Vehicle\Tire\Data_TIR")

if(length(simInputFR)>12)
simOutFR = parsim(simInputFR,'ShowSimulationManager','on',...
    'ShowProgress','off','UseFastRestart','on',...
    'TransferBaseWorkspaceVariables','on');
else
simOutFR = sim(simInputFR,'ShowSimulationManager','on',...
    'ShowProgress','off','UseFastRestart','on');
end
Elapsed_Time_Time_FR  = toc(timerValFR);

disp(' ');
disp([num2str(length(simInputFR)) ' simulations completed in ' num2str(Elapsed_Time_Time_FR) ' seconds.'])

% Filter out any invalid simulations
filterInvalid = true;
if filterInvalid
    dataValidCheck = suspOpt_check_runValid(runTable,simOutFR,Vehicle,showPlot,true);
    dataValidCheck = struct2table(dataValidCheck,"AsArray",true);
    idx = dataValidCheck.valid_wSpd & dataValidCheck.valid_yPth & dataValidCheck.valid_aToe;
    simOutFR = simOutFR(idx);
    runTable = runTable(idx,:);
end

disp(' ');
disp(['Of ' num2str(length(simInputFR)) ' tests, ' num2str(length(simOutFR)) ' were valid.'])

timestamp = getSimOutTimestampStr(simOutFR(1));
foldername  = ['Res_' timestamp];
filename    = ['runTableOUT_' timestamp];
if(~exist(foldername,'dir'))
    mkdir(foldername)
end
runTableOUT = runTable;
save([pwd filesep foldername filesep filename '.mat'],'runTableOUT');


end