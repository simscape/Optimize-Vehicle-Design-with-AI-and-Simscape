% Define bump
[x_road, y_road]=sm_car_05_road_bump;

% Add bump to road surface parameter
Scene.RDF_Rough_Road.Road.extr_data_R = [x_road, y_road];
Scene.RDF_Rough_Road.Road.extr_data_L = Scene.RDF_Rough_Road.Road.extr_data_R.*[1 0];

% Identify subset of road surface data to visualize bump
road_bump_inds = intersect(...
    find(Scene.RDF_Rough_Road.Road.extr_data_R(:,1)<125), ...
    find(Scene.RDF_Rough_Road.Road.extr_data_R(:,1)>0));

% Create extrusion data to visualize bump
bump_visual = Scene.RDF_Rough_Road.Road.extr_data_R(road_bump_inds,:);