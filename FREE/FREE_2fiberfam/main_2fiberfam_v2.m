%
% main_2fiberfam_v2
%   Script that finds optimal control inputs to drive system to target set
%   
%   states: x = [P gama betta r L phi T_gama T_betta]'
%   inputs: u = P_desired
%

%% Set value of params
clear
clc

params = struct;

% % Desired twist and/or length
% params.phi_desired = deg2rad(130);
% params.len_desired = 7;
params.u = 10;

%SET RESTING GEOMETRY OF FREE HERE:
params.x_rest = [0.0001, deg2rad(35), deg2rad(-20), 3/16, 5, 0, 0, 0]';    % resting state, P = 0 psi. States are [P, gama, betta, r, L, phi, T_gama, T_betta]. By convention abs(gama)>abs(betta)

% Determine which set of dynamics apply to this problem
if params.x_rest(2) > 0 && params.x_rest(3) > 0
    params.case = 1;
elseif params.x_rest(2) < 0 && params.x_rest(3) < 0
    params.case = 2;
elseif params.x_rest(2) > 0 && params.x_rest(3) < 0
    params.case = 3;
elseif params.x_rest(2) < 0 && params.x_rest(3) > 0
    params.case = 4;
end

            
params.x0 = params.x_rest;     % state vector initial condition, same as resting condition

params.u0 = [0]';        %input vector initial condition

params.Pmax = 100;  % maximum pressure allowed
params.T = 0.01;   %final time
params.N = 10; %number of steps
params.dt = params.T/params.N;    %size of one time step
params.n = length(params.x0);  %dimension of state vector x
params.m = length(params.u0);  %dimension of state vector u

% Set values of elastomer constants
% params.Felast_consts = [14.32402, -149.8227, 389.7264];     % force elastomer constants (L0 = 5.68 in)
% params.Melast_consts = -[0.0197989, -1.11737, 15.6772];     % moment elastomer constants (L0 = 5.68 in)   

% params.Felast_consts = [1, 60, -5.6038];     % Me tweaking it to fit pre ICRA results #YOLO
% params.Melast_consts = [-0.2483, 0, 0];     % Me tweaking it to fit pre ICRA results

% params.Felast_consts = -[0, 10, -5.58*10];     % force elastomer constants (L0 = 5.68 in)
% params.Melast_consts = [0, 1, 0];     % moment elastomer constants (L0 = 5.68 in)

% params.Felast_consts = [102.793, -636.9886, 987.7724];     % force elastomer constants (L0 = 3.152 in)
% params.Melast_consts = [0.0502413, -1.67107, 13.6699];     % moment elastomer constants (L0 = 3.152 in) 

params.Felast_consts = [7.21992225409945, 0, 0];     % force elastomer constants
params.Melast_consts = [7, 0, 0];     % moment elastomer constants 

% params.Felast_consts = [1, 0, 0];     % weak elastomer
% params.Melast_consts = [1, 0, 0];     % weak elastomer 

% params.Felast_consts = [7, 0, 0];     % strong elastomer
% params.Melast_consts = [100, 0, 0];     % strong elastomer 

% params.Felast_consts = [0, 0, 0];     % No elastomer
% params.Melast_consts = [7, 0, 0];     % No elastomer

params.vf = @( x, u ) vf( x, u );

%% Run Optimization

s0 = state_encode0(params);

% Dummy inequality constraints. Defined as A*s <= B
A = eye(length(s0));
B = ones(length(s0),1)*100;

% % defining options for fmincon
options = optimoptions('fmincon','Algorithm','interior-point',...
   'GradObj', 'on', 'GradConstr', 'on', 'Display', 'iter',  ...
   'MaxIter', 1000, 'ScaleProblem', 'obj-and-constr', 'Hessian', 'lbfgs'  );

% Lower and upper bounds of states/inputs
lb = -10*ones(length(s0),1);
ub = params.Pmax*ones(length(s0),1);            % maximum pressure/control input

% NL program to solve optimization problem
s_star = fmincon(@(s)obj(s, params), s0, [], [],[],[], lb, ub, @(s)implicit_Dynamics(s,params), options);
% s_star = fmincon(@(s)obj(s, params), s0, [], [],[],[], lb, ub, [], options); %no constraints

% convert results of optimization to states and inputs
[x_star, u_star] = state_decode(s_star, params);


% create plot of the outputs
tvec = [0:length(x_star')-1].*params.dt;    % time vector

figure
set(gcf,'numbertitle','off','name','Control Optimization Results') % See the help for GCF

subplot(2,3,1)       
plot(tvec, x_star(1,:)')
title('Pressure (psi)')

subplot(2,3,2)       
plot(tvec, rad2deg(x_star(2,:)'))
title('gamma (deg)')

subplot(2,3,3)       
plot(tvec, rad2deg(x_star(3,:)'))
title('beta (deg)')

subplot(2,3,4)       
plot(tvec, x_star(4,:)')
title('radius (in)')

subplot(2,3,5)       
plot(tvec, x_star(5,:)')
title('Length (in)')

subplot(2,3,6)       
plot(tvec, rad2deg(x_star(6,:)'))
title('phi (deg)')