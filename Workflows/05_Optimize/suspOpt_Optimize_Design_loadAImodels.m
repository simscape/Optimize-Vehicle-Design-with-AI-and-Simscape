function [rideModel, rollModel, multiRegModel] = suspOpt_Optimize_Design_loadAImodels(modelType)

load aiModels.mat

if(strcmp(modelType,"gpModel"))
    multiRegModel = aiModels.gpModel;
    if(startsWith(aiModels.gpModel1.ResponseName,'Roll'))
        rollModel = aiModels.gpModel1;
        rideModel = aiModels.gpModel2;
    else
        rollModel = aiModels.gpModel2;
        rideModel = aiModels.gpModel1;
    end
elseif(strcmp(modelType,"bagModel"))
    multiRegModel = aiModels.bagModel;
    if(startsWith(aiModels.bagModel1.ResponseName,'Roll'))
        rollModel = aiModels.bagModel1;
        rideModel = aiModels.bagodel2;
    else
        rollModel = aiModels.bagModel2;
        rideModel = aiModels.bagModel1;
    end
elseif(strcmp(modelType,"nnModel"))
    multiRegModel = aiModels.nnModel;
        rollModel = [];
        rideModel = [];
end

    
