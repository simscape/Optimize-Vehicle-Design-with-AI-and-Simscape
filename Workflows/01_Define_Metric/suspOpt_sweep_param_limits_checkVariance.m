function parTableVal_trim = suspOpt_sweep_param_limits_checkVariance(parTableVal,RangeSweepTable)
% suspOpt_param_pickSensitive   Identify parameters to be tuned
%   parTableVal_trim = suspOpt_param_pickSensitive(parTableVal,RangeSweepTable)
%   This function looks at the result of the simulation tests with
%   suspension parameters set to their max and min values.  It provides a
%   simple indication of which parameters showed enough impact on the
%   performance metrics to be selected for the DOE process. A true
%   sensitivity analysis should be used to identify the most influential
%   parameters.
%
%       parTableVal     Table of suspension parameters
%       RangeSweepTable Table holding results of parameter sweep

% Copyright 2023-2025 The MathWorks, Inc.

% Find top 26 parameters as measured by their impact on the roll angle metric
[~, sorted_rollPi] = sort(RangeSweepTable.DiffRoll,'descend');

% Find top 24 parameters as measured by their impact on the ride comfort metric
[~, sorted_ridePi] = sort(RangeSweepTable.DiffRide,'descend');

% Find the union of those sets
includeInds        = union(sorted_rollPi(1:26),sorted_ridePi(1:24));

% Set the "Use" column for identified parameters to true, rest to false
parTableVal_trim = parTableVal;
parTableVal_trim.Use(:) = false;
parTableVal_trim.Use(includeInds) = true;



