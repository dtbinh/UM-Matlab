% /SimpleParallel/setParams_2parallel.m
%   Set resting values (when p = 0) for state (xrest), and other FREE parameters.
clear
clc

params = struct;

%% USER DEFINED FREE PARAMETERS

% Parameters for the left FREE, designated by postscript "_l"
params.Gama_l = 0.75;  % relaxed fiber angle (rad)
params.R_l = 0.5e-2;    % relaxed FREE radius (m)
params.L_l = 10e-2; % relaxed FREE length (m)
% params.kelast_l = [-4e3, -4e-2];   % spring constants for the elastomer
params.kelast_l = [0, 0];   % spring constants for the elastomer
params.Ptest_l = 70e3; % test pressure (Pa). Not needed for most functions.

% Parameters for the left FREE, designated by postscript "_r"
params.Gama_r = 0.75;  % relaxed fiber angle (rad)
params.R_r = 0.5e-2;    % relaxed FREE radius (m)
params.L_r = 10e-2; % relaxed FREE length (m)
% params.kelast_r = [-4e3, -4e-2];   % spring constants for the elastomer
params.kelast_r = [0, 0];   % spring constants for the elastomer
params.Ptest_r = 35e3; % test pressure (Pa). Not needed for most functions.

% Parameters shared by both the left and right FREEs
params.load = [0; 0];   % loads on FREE [Fload, Mload] (N)

%% USER DEFINED TEST PARAMETERS

% range of pressures to iterate over
params.Prange_l = [0, 200e3];
params.Prange_r = [0, 200e3];

% number of steps to take along each FREEs pressure;
params.steps_l = 20;
params.steps_r = 20;





%% Dependent parameters (do not edit below this line)

% Left FREE
params.B_l = abs(params.L_l/cos(params.Gama_l));   % fiber length (must be positive)
params.N_l = -params.L_l/(2*pi*params.R_l) * tan(params.Gama_l); % total fiber windings in revolutions (when relaxed)

% Right FREE
params.B_r = abs(params.L_r/cos(params.Gama_r));   % fiber length (must be positive)
params.N_r = -params.L_r/(2*pi*params.R_r) * tan(params.Gama_r); % total fiber windings in revolutions (when relaxed)


