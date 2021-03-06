%setParams.m
%   Set resting values (when P = 0) for state (xrest), and other FREE parameters.
clear
clc
params = struct;

%% USER DEFINED FREE PARAMETERS

params.numFREEs = 4;    % total number of FREEs
params.num = params.numFREEs;   % reduntant but needed to get code to work together
params.Lspine = 27.94e-2;  % length of central spine (m)

params.Gama = [0.75, -0.75, 0.75, -0.75]';        % relaxed fiber angle (rad)
% params.Gama = deg2rad([42.9, -42.9, 42.9, -42.9])';        % relaxed fiber angle (rad)
params.R = [0.5e-2, 0.5e-2, 0.5e-2, 0.5e-2]';    % relaxed FREE radius (m)
params.L = [params.Lspine, params.Lspine, params.Lspine, params.Lspine]'; % relaxed FREE lenght (m)
params.kelast_s = 1e-2 * [-4e3, -4e3, -4e3, -4e3]';     % spring constants for the elastomer in extension
params.kelast_w = 1e0 * [-4e-2, -4e-2, -4e-2, -4e-2]'; % spring constants for the elastomer in twist
% params.kelast_s = -1e-1 * [1,1,1,1]';     % spring constants for the elastomer in extension
% params.kelast_w = -1e-3 * [1,1,1,1]'; % spring constants for the elastomer in twist
params.xattach = 1*[2e-2, -2e-2, -2e-2, 2e-2]';      % x-coordinate of attachment point of FREE
params.yattach = 1*[2e-2, 2e-2, -2e-2, -2e-2]';      % y-coordinate of attachment point of FREE

% from IROS code
params.d = [params.xattach';...
            params.yattach';...
            zeros(1,params.numFREEs)]; % location of attachment points to the end effector [m]
params.a = [0,0,1 ;...
            0,0,1 ;...
            0,0,1 ;...
            0,0,1 ]';    % direction of FREE axis at attachment point [unit vector]
params.pmin = 6894.76 * [0 0 0 0];   % min gauge pressure for each FREE [Pa]
params.pmax = 6894.76 * [500 500 500 500];   % max gauge pressure for each FREE [Pa]

%% USER DEFINED END EFFECTOR PARAMETERS
params.m = 0.01;         % end effector mass (kg)
params.effdim = [4e-2, 4e-2, 2e-2];     % [lenght, width, height] (m) ... assuming end effector is rectangular prism. 
params.I = params.m/12 * [params.effdim(1)^2 + params.effdim(3)^2; params.effdim(2)^2 + params.effdim(3)^2; params.effdim(1)^2 + params.effdim(2)^2]; % end effector rotational moments of inertia [Mx, My, Mz]'
% params.I = [0.1; 0.1; 0.01]; % end effector rotational moments of inertia [Mx, My, Mz]'
params.g = 9.81;        % acceleration due to gravity (m/s^2)
params.damp = 0.5*[1.3e0; 1.3e0; 1.25*8e-2];    % damping in each direction [damppsi, damptheta, dampphi]'
% params.damp = 0.5*[0; 0; 0];    % damping in each direction [damppsi, damptheta, dampphi]'

% From IROS code
params.deff = [0,0,0]; % location of origin of end effector coordinates in global coordinates
params.euleff = eye(3);  % orientation of end effector coordinate frame in global coordinates, written as rotation matrix
params.meff = 0;   % mass of the end effector [kg]
params.cmeff = [0,0,0]';   % location of the center of mass of end effector [m]

%% USER DEFINED SPINE/BEAM PARAMETERS
params.dbeam = 0.5e-3;    % beam diameter (m)
params.Ebeam = 200e6;  % beam Young's modulus (Pa)
params.Ibeam = pi*params.dbeam^4 / 64;

%% USER DEFINED TEST PARAMETERS

% QP parameters
params.penalty = 1e-5;
params.tol = [Inf, Inf, Inf, 1e-3, 1e-3, 1e-3];   % QP constraint tolerance

% PID gains
params.Kp = 3*blkdiag( zeros(3,3), [1e0, 0, 0; 0, 1e0, 0; 0, 0, 1] );  % proportional gain
params.Ki = 1.5e-1 * blkdiag( zeros(3,3), eye(3) );  % integral gain
params.Kd = zeros(6,6);  % derivative gain

% Initial conditions (could be made more generic in the future)
params.x0 = [0, 0, 0, 0, 0, 0]';
params.xdot0 = [params.x0(4), params.x0(5), params.x0(6), 0, 0, 0]';
params.u0 = [0, 0, 0, 0]';

params.T = 1;   %final time
params.N = 50; %number of steps
params.dt = params.T/params.N;    %size of one time step
params.n = length(params.x0);  %dimension of state vector x
params.m = length(params.u0);  %dimension of state vector u

% Maximum pressure for the FREEs
params.Pmax = 400e3;    % (Pa)

% range of pressures to iterate over
params.Prange1 = [0, 200e3];
params.Prange2 = [0, 200e3];
params.Prange3 = [0, 200e3];
params.Prange4 = [0, 200e3];

% number of steps to take along each FREEs pressure;
params.steps1 = 20;
params.steps2 = 20;
params.steps3 = 20;
params.steps4 = 20;

%% USER DEFINED PLOTTING PARAMETERS 

params.thickness = 0.02;    % thickness of the top and bottom blocks
params.width = 0.04;        % width of the top and bottom blocks

params.frames = 100;    % number of frames in animation over whole time
params.tfinal = 2;     % duration of simulation (s)
params.Ts = 1e-2;       % sampling period

%% Dependent parameters (do not edit below this line)

params.B = abs(params.L ./ cos(params.Gama));   % fiber length (must be positive))
params.Nf = -params.L ./ (2*pi*params.R) .* tan(params.Gama); % total fiber windings in revolutions (when relaxed)

% force transformation matrix from FREE to end effector coordinates
% (cumulative)
params.D = zeros(6,2*params.num);
d = params.d;
a = params.a;
% for i = 1:params.num
%     dix = [0, -d(3,i), d(2,i); d(3,i), 0, -d(1,i); -d(2,i), d(1,i), 0];
%     params.D(: , 2*(i-1)+1:2*i) = [[a(:,i), zeros(3,1)] ; [flipud(dix*a(:,i)), zeros(3,1)] + [zeros(3,1), flipud(a(:,1))]];  % Di's are horizontally concatenated
% end
for i = 1:params.num
    dix = [0, -d(3,i), d(2,i); d(3,i), 0, -d(1,i); -d(2,i), d(1,i), 0];
    params.D(: , 2*(i-1)+1:2*i) = [[a(:,i), zeros(3,1)] ; [(dix*a(:,i)), zeros(3,1)] + [zeros(3,1), (a(:,1))]];  % Di's are horizontally concatenated
end
