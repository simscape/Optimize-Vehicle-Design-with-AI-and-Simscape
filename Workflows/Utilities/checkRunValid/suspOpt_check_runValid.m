function dataValidCheck  = suspOpt_check_runValid(runTable,out,Vehicle,showplot,saveRes)
% suspOpt_check_run_valid  Check if double-lane change test was valid
%   [validwSpd, validaToe, validyPth]  = suspOpt_check_run_valid(simOutFR,runNum,numRuns,Vehicle,showplot)
%   This function returns logical values indicating if all three validity
%   checks for a double lane change test have passed.  A valid test will
%   ensure that 
%   1.  Wheel speeds do not deviate unacceptably from chassis speed 
%   2.  Tire toe angle does not exceed a threshold for too long
%   3.  Vehicle lateral deviation from target trajectory does not exceed a
%       threshold for too long.
%
%      out          Simulation Output Object(s)
%      Vehicle      Vehicle data structure
%      showplot     Create plot
%      saveRes      Save plots and data to folder

% Copyright 2023-2025 The MathWorks, Inc.

% Extract test data from Simulation Output
simRes_checkValid  = suspOpt_check_runValid_getData(out);

% Extract results relevant to validity check and check validity of run
dataValidCheckWS = suspOpt_check_runValid_wSpd(simRes_checkValid.logsout_VehBus,Vehicle);
dataValidCheckYP = suspOpt_check_runValid_yPth(simRes_checkValid.logsout_DrvBus);
dataValidCheckAT = suspOpt_check_runValid_aToe(simRes_checkValid.logsout_VehBus);

% Merge results into a single structure
dataValidCheck = dataValidCheckWS;
WS_fields    = fieldnames(dataValidCheckWS);
YP_fields    = fieldnames(dataValidCheckYP);
newFieldsYP  = setdiff(YP_fields,WS_fields);
for run_i = 1:length(dataValidCheckYP)
    for field_j = 1:length(newFieldsYP)
        dataValidCheck(run_i).(newFieldsYP{field_j}) = dataValidCheckYP(run_i).(newFieldsYP{field_j});
    end
end

allFields    = union(WS_fields,YP_fields);
AT_fields    = fieldnames(dataValidCheckAT);
newFieldsAT  = setdiff(AT_fields,allFields);
for run_i = 1:length(dataValidCheckAT)
    for field_j = 1:length(newFieldsAT)
        dataValidCheck(run_i).(newFieldsAT{field_j}) = dataValidCheckAT(run_i).(newFieldsAT{field_j});
    end
end

% Plot results if requested
if(showplot)
    fig_YP = suspOpt_check_runValid_plot_yPth(dataValidCheck);
    fig_WS = suspOpt_check_runValid_plot_wSpd(dataValidCheck,'all');
    fig_AT = suspOpt_check_runValid_plot_aToe(dataValidCheck,'all');

    % Save results if requested
    if(saveRes)
        foldername  = ['Res_' simRes_checkValid(1).timestamp];
        if(~exist(foldername,'dir'))
            mkdir(foldername)
        end
        filenamefig = ['yPth_' simRes_checkValid(1).timestamp '.png'];
        saveas(fig_YP,[pwd filesep foldername filesep filenamefig])
        filenamefig = ['wSpd_' simRes_checkValid(1).timestamp '.png'];
        saveas(fig_WS,[pwd filesep foldername filesep filenamefig])
        filenamefig = ['aToe_' simRes_checkValid(1).timestamp '.png'];
        saveas(fig_AT,[pwd filesep foldername filesep filenamefig])
        save([pwd filesep foldername filesep foldername '.mat'],'dataValidCheck','runTable')
    end
end

end
