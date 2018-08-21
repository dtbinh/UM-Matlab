function [ koopman, error, data, data4sysid ] = main_flaccy( getData )
%main_test: A generic "main" function for development and testing
%   Performs linear system identification of nonlinear systems using a
%   lifting technique based on the Koopman operator projected onto a finite
%   monomial basis.
%
%   INPUTS:
%       getData is a string that specifies whether data will be generated
%       by simulation, from experimental measurements, or loaded from a 
%       file. Possible values are 'sim', 'exp', and 'file'.
%
%   OUTPUTS:
%       koopman is a struct containing the value of the learned Koopman
%       operator and other values related to the koopman sysid. See the
%       koopmanSysid function for more details.


%% Define system parameters (USER EDIT SECTION)
params = struct;
progress = waitbar(0,'Initializing parameters...');

% Koopman Sysid parameters
params.n = 6;   % dimension of state space (including state derivatives)
params.p = 3;   % dimension of input
params.naug = params.n + params.p; % dimension of augmented state (DNE)

% select maximum degrees for monomial bases (NOTE: m1 = 1)
params.maxDegree = 4;   % maximum degree of vector field monomial basis
params.m1 = 1;  % maximum degree of observables to be mapped through Lkj (DNE)

% define lifting function and basis
params = def_polyLift(params);  % creates polynomial lifting function, polyLift

% choose whether or not to take numerical derivatives of states (boolean)
params.numericalDerivs = true;

params.Ts = 0.02;   % sampling period

% % animation parameters
% params.fps                 = 30;
% params.movie               = true;
params.ploton              = true;  % boolean to turn error plot on or off

% parameters for generating data
params.numTrials = 6;   % numer of sysid trials
params.numVals = 6;     % number of validation trials
params.observe = [1, 1, 1, 0, 0, 0];    % row vector choosing which states to observe
params.inputType = 'sinusoid';
params.vf_real = @vf_doublePendulum;
params.ampRange = [-5, 5];       % amplitude range of sinusoidal inputs
params.freqRange = [0, 10];     % frequency range of sinusoidal inputs
params.amp = [];
params.freq = [];
params.x0min = [-pi/2, -pi/2, 0, 0];
params.x0max = [pi/2, pi/2, 0, 0];
params.mean                = 0;     % mean of noise 
params.sigma               = 0.01;     % standard dev of noise
params.duration            = 5;   % in seconds
params.systemName          = 'val30s_x6_sysid30s_x6_steps+ramps_02Ts';  % name of current system
params.filterWindow        = floor( [1/params.Ts, 1/params.Ts] );  % if taking numerical derivatives, specifies the moving mean window before and after derivatives taken.


%% Generate or load data from file
waitbar(.33,progress,'Generating data...');

addpath('generateData');

if strcmp(getData, 'sim')
    data = gen_data_fromSim( params );
elseif strcmp(getData, 'exp')
%     data = gen_data_fromExp_xonly( params );
    data = gen_data_fromExp( params );
elseif strcmp(getData, 'file')
    % Prompt user to identify data file
    [data_file,data_path] = uigetfile;
    matcontents = load([data_path, data_file]); % must be a .mat file
    data = matcontents.data;
end

rmpath('generateData')

%% Use Koopman operator to perform sysid
waitbar(.5,progress,'Performing Koopman based system identification...');

koopman = koopmanSysid(data.snapshotPairs, params);

%% error
waitbar(0.75,progress,'Comparing to validation data set...');

% [error, xkoop] = koopmanSimulation( data.validation, params, koopman ); % only uses koopman transpose, no ODE
[error, koopsim] = koopmanValidation( data, params, koopman );


%% compare koopman results to those from sysid toolbox
waitbar(0.85,progress,'Preparing data for Matlab SysId toolbox...');

% convert data to a format matlabs sysid toolbox can use
[zsysid_merged, zval_merged, zsysid, zval] = prep_iddata(data);

% save in struct for output
data4sysid = struct;
data4sysid.sysid_merged = zsysid_merged;
data4sysid.val_merged = zval_merged;
data4sysid.val = zval;
data4sysid.sysid = zsysid;
for k = 1:params.numVals - 1
    valID = ['val', num2str(k)];
    zID = ['z', num2str(k)];
    data4sysid.valkoop.(zID) = iddata(koopsim.(valID).x, data.(valID).u, data.valparams.Ts, 'Name', 'Koopman');
end

% show comparison of Koopman system verses ground truth
if params.ploton
    for k = 1: params.numVals - 1
        zID = ['z', num2str(k)];
        figure
        compare(data4sysid.val.(zID), data4sysid.valkoop.(zID));
    end
end

waitbar(1,progress,'Done.');
close(progress);
end