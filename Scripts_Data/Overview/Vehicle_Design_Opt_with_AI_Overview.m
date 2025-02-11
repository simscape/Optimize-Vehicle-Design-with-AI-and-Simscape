%% Optimizing Vehicle Design Using AI and Simscape
%
% <<sm_car_dlc_only_image.png>>
%
% <matlab:open_system('sm_car_dlc_only'); Open model sm_car_dlc_only>
%
% This example shows the workflow to create a surrogate AI model using
% training data from a multibody model of a vehicle. The resulting AI model
% can be used for design space exploration and for finding the optimal
% design parameters. 
% 
% * *Early-stage physical physical design* is conducted by creating a
% reduced order model to rapidly evaluate hardpoint locations.
% * *Sensitivity analysis* is conducted by running many simulations in
% parallel and analyzing the influence of design parameters on performance
% metrics
% * *Training data* for the AI model is produced using Design of
% Experiments to ensure the entire design spaces is covered.
% * *Machine Learning and Deep Learning* are both used to create surrogate
% models that are automatically validated against the generated data.
% * *Optimization algorithms* are used to identify the set of design
% parameters that balance the tradeoff between multiple performance metrics.
% * A *MATLAB App* enables exploration of the design space using responses surfaces.
%
% *Design Workflows*
% 
% # <matlab:web('suspOpt_sweep_param_limits.html') Create Virtual Test with Performance Metrics>
% # <matlab:web('suspOpt_Sensitivity_Analysis.html') Identify Key Parameters for Design>
% # <matlab:web('suspOpt_Training_Data.html') Generate Training Data by Running Design of Experiments> 
% # <matlab:web('suspOpt_Train_Models_mchLrn.html') Train and Validate Machine Learning Surrogate Model of Design Space>
% # <matlab:web('suspOpt_Train_Models_deepLrn.html') Train and Validate Deep Learning Surrogate Model of Design Space>
% # <matlab:web('suspOpt_Optimize_Design.html') Optimize Suspension Design Parameters Using Surrogate Model>
% # <matlab:web('suspOpt_Explore_Design_Space.html') Interactively Explore Design Space>
%
% *Workflow Overview*
%
% <<Vehicle_Design_Opt_with_AI_Overview_Workflow_900x506.PNG>>
% 

