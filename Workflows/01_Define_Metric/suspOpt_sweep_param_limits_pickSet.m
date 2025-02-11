function parTableVal_trim = suspOpt_sweep_param_limits_pickSet(parTableVal_trim,varargin)
% This function sets the list of 10 parameters that will be used to
% investigate the design space of the suspension.  If a list of labels is
% provided, that set of labels will be used to trim the list.  Else, a
% default set of labels will be used.

if(nargin==1)
    % No list of labels for parameters supplied.
    % Use default list of labels from visual inspection.
    labelShortList ={ ...
        'HP_A1_AR_Inbx';
        'HP_A1_Ro_Inbz';
        'HP_A1_Ro_Outz';
        'HP_A2_AR_Inbx';
        'HP_A2_AR_Outx';
        'HP_A2_AR_Outy';
        'HP_A2_LA_Outy';
        'HP_A2_LA_Outz';
        'HP_A2_LA_inRz';
        'HP_A2_UA_Outz';
        };
else
    % Use list of labels supplied as input argument
    labelShortList = varargin{:};
    labelShortList{9}  = 'HP_A1_Ro_Inbz';
    labelShortList{10} = 'HP_A1_Ro_Outz';
    labelShortList = sortrows(labelShortList);
end

parTableVal_trim.Use(:) = false;

% Set "Use" field to true for this list
for lbl_i = 1:length(labelShortList)
    lbl_ind = strcmp(parTableVal_trim.Label,labelShortList{lbl_i});
    if(~isempty(lbl_ind))
        parTableVal_trim.Use(lbl_ind) = true;
    else
        error(['Label ' labelShortList{lbl_i} ' not found in table.']);
    end
end

