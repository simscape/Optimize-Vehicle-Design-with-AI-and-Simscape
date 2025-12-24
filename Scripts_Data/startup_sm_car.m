function startup_sm_car
% Startup file for sm_car.slx Example
% Copyright 2019-2025 The MathWorks, Inc.

curr_proj = simulinkproject;

% Add folders with Simscape Multibody tire subsystem to path
% if MATLAB version R2021b or higher
if verLessThan('matlab', '9.11')
    addpath([curr_proj.RootFolder filesep 'Libraries' filesep 'Vehicle' filesep 'Tire' filesep 'MFMbody' filesep 'MFMbody_None']);
else
    addpath([curr_proj.RootFolder filesep 'Libraries' filesep 'Vehicle' filesep 'Tire' filesep 'MFMbody' filesep 'MFMbody']);
end

%% Load visualization and other parameters in workspace
Visual = sm_car_param_visual('default');
assignin('base','Visual',Visual);

%% Load vehicle parameters
Vehicle_data;
Vehicle = sm_car_vehcfg_checkConfig(Vehicle);
assignin('base','Vehicle',Vehicle)
%evalin('base','Vehicle_data')

%% Load Initial Vehicle state
evalin('base','Init_data')

%% Load Maneuver parameters
evalin('base','Maneuver_data')

%% Load Driver parameters
sm_car_gen_driver_database;
evalin('base','Driver = DDatabase.Double_Lane_Change_ISO3888.Sedan_Hamba;');
evalin('base','clear DDatabase;');

%% Load Camera Frame Database
CDatabase.Camera = sm_car_gen_camera_database;
assignin('base','CDatabase',CDatabase)

%% Load driving surface parameters
Scene = sm_car_import_scene_data;
assignin('base','Scene',Scene);
evalin('base','sm_car_comfort_test_setup_bump');

%% Load control parameters
Control = sm_car_import_control_param;
assignin('base','Control',Control);

%% Create custom components for drag calculation
if(isempty(getCurrentWorker))
    custom_code = dir('**/custom_abs.ssc');
    cd(custom_code.folder)
    ssc_build
    cd(fileparts(which('sm_car_dlc_only.slx')))
end

%% Modify solver settings - patch from development
limitDerivativePerturbations()
daesscSetMultibody()

% If running in a parallel pool
% do not open model or demo script
open_start_content = 1;
if(~isempty(ver('parallel')))
    if(~isempty(getCurrentTask()))
        open_start_content = 0;
    end
end

if(open_start_content)
    %% If this is the top level project, open HTML script
    % Do not open it if this is a referenced project.
    this_project = simulinkproject;
    if(this_project.Information.TopLevel == 1)
        web('Vehicle_Design_Opt_with_AI_Overview.html');
    end

    %% Open app
    %evalin('base','sm_car_vehcfg_run');

    %% Open model
    setup_sm_car_model
end
