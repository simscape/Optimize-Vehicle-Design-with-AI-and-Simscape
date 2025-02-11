% Script to set up main model

% Copyright 2023-2024 The MathWorks, Inc.

mdl = 'sm_car_dlc_only';
open_system(mdl);

% Load vehicle data structure
Vehicle_data;

% Fill in any drived fields
Vehicle = sm_car_vehcfg_checkConfig(Vehicle);

% Load data for bump in test scenario
sm_car_comfort_test_setup_bump