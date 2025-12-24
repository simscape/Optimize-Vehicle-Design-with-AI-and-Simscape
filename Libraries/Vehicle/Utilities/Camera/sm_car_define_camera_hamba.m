function Camera =  sm_car_define_camera_hamba
% Function to specify parameters for animation cameras
%
% Adjust frame locations below
%
% Copyright 2021-2025 The MathWorks, Inc.

% Offset from vehicle reference to camera reference
%   Vehicle Reference: Frame where camera frame subsystem is attached
%   Camera Reference:  Frame camera will point at
camera_name = 'Hamba';
camera_param.veh_to_cam = [-1.5      0          0];

% Camera positions relative to camera reference
% Circle of cameras
camera_param.xyz_f      = [   5      0        1.8];   % Front
camera_param.xyz_l      = [   0      5        1.0];  % Left  (right)
camera_param.xyz_r      = [  -5      0        1.8];   % Rear
camera_param.xyz_d      = [   3.8412 3.201    1.8];   % Front Left (diagonal)
camera_param.xyz_t      = [-eps      0       10];     % Top

% Viewing Suspension and Seats
camera_param.whl_fl     = [   1.412   3       0.35];  % Wheel Front Left (right)
camera_param.whl_rl     = [  -1.412   3       0.35];  % Wheel Rear Left  (right)
camera_param.susp_f     = [   3.00    0       0.35];  % Suspension Front
camera_param.susp_r     = [  -3.00    0       0.35];  % Suspension Rear
camera_param.susp_fl    = [   0.80    0.45    0.35];  % Suspension Front Left (right) 
camera_param.susp_rl    = [  -0.70    0.45    0.35];  % Suspension Rear Left  (right) 
camera_param.seat_fl    = [   0.10    0.375   1.20];  % Seat Front Left       (right) 

% Dolly Camera
camera_param.dolly.s    = [   0   -5.00    1];  % Camera offset
camera_param.dolly.a    = [   0   11.3099 90];     % View angle orientation
camera_param.dolly.xvec = [5.0000    7.7463   11.7166   17.1294   24.4354   34.1914   46.9662   63.1652   82.6486  104.2606 ...
  126.2459  148.2354  170.2248  192.1963  214.0848  236.0516  257.9524  279.8855  301.8717  323.8077 ...
  345.6270  363.1803  372.0083];
camera_param.dolly.tvec = [0:1:length(camera_param.dolly.xvec)-1]; % Time
%[5   6.1 8.6 12.5 17.7 24.5 44.1 79.9 199]; % Trajectory x
camera_param.dolly.yvec = camera_param.dolly.s(2)*ones(size(camera_param.dolly.xvec)); % Trajectory y
camera_param.dolly.zvec = camera_param.dolly.s(3)*ones(size(camera_param.dolly.xvec));; % Trajectory z

 

% Obtain Camera structure
Camera = sm_car_define_camera(camera_param);
Camera.Rear.a.Value = [0 10 0];
Camera.Instance = camera_name;
