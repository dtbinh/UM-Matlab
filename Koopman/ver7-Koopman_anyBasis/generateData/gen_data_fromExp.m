function data = gen_data_fromExp( params )
%genData_fromExp: Generate system data and snapshot pairs from experimental
%data
%   Detailed explanation goes here

% initialize output struct
data = struct;
alltrials = struct;

%% Read in data from all trials

trialCount = 0;        % trial counter

% Load in sysid data trials
disp('Please select all .mat files corresponding to sysid trials:');
[sysid_file,sysid_path] = uigetfile('MultiSelect','on');

alltrials.t = []; alltrials.y = []; alltrials.u = []; alltrials.x = [];
x = []; y = [];
for i = 1 : length(sysid_file)
    trialCount = trialCount + 1;    % increment trial counter
    
    % handle single file exception
    if ~iscell(sysid_file)
        file = sysid_file;
    else
        file = sysid_file{i};
    end
    
    % generate data from the ith sysid trial
    trialData = get_data(file, sysid_path, params);
    
    % append this data to the "alltrials" field of data
    alltrials.t = [alltrials.t; trialData.t];     % time vector
    alltrials.y = [alltrials.y; trialData.y];     % state "measurements"
    alltrials.u = [alltrials.u; trialData.u];     % input
    alltrials.x = [alltrials.x; trialData.x];     % actual state
    
    xk = zeros(length(trialData.t), size(trialData.y,2) + size(trialData.u,2));
    yk = zeros(length(trialData.t), size(trialData.y,2) + size(trialData.u,2));
    for j = 1:length(trialData.t)-1
        xk(j,:) = [ trialData.y(j,:), trialData.u(j,:) ];
        yk(j,:) = [ trialData.y(j+1,:), trialData.u(j,:) ];
    end
    
    % append snapshot pairs from this trial onto set of all pairs
    x = [x; xk];
    y = [y; yk];
    
    % save this trial data to the output struct
    trialID = ['trial', num2str(trialCount)];
    data.(trialID) = trialData;
    
end


% define snapshotPairs struct
snapshotPairs = struct;
snapshotPairs.x = x;
snapshotPairs.y = y;

%% Read in validation data set(s)

% Load in validation data trials
disp('Please select all .mat files corresponding to validation trials:');
[val_file,val_path] = uigetfile('MultiSelect','on');

for j = 1 : length(val_file)
    
    % handle single file exception
    if ~iscell(val_file)
        file = val_file;
    else
        file = val_file{j};
    end
    
    % generate data from the jth validation trial
    valData = get_data(file, val_path, params);
    
    % save this trial data to the output struct
    valID = ['val', num2str(j)];
    data.(valID) = valData;   

end


%% Define output

data.alltrials = alltrials;     % saves data from all trials as a single timeseries
data.snapshotPairs = snapshotPairs;
data.validation = data.val1;   % a trial that can be used for model validation
data.valparams = params;   % saves params used for validation so we can remember

%% save datafile without overwriting previous files with same name
% SaveWithNumber(['dataFiles', filesep, params.systemName, '.mat'], data);
[unique_fname, change_detect] = auto_rename(['dataFiles', filesep, params.systemName, '.mat'], '0');
save(unique_fname, 'data');


end