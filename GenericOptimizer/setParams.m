% setParams.m
%   Set initial values for state (x0) and input (u0), and other solver
%   parameters.
clear
clc

params = struct;

params.x0 = [1 2 pi]';    %state vector initial condition (any size)
params.u0 = [1 0]';        %input vector initial condition (any size)

params.T = 1;   %final time
params.N = 50; %number of steps
params.dt = params.T/params.N;    %size of one time step
params.n = length(params.x0);  %dimension of state vector x
params.m = length(params.u0);  %dimension of state vector u

params.vf = @(x, u) vf(x, u);

% creates functions to evaluate the dynamics at any point
dynamics_symbolic(params);

% tests the gradients of the dynamics at x0, u0.
[grad, num_grad] = run_test_gradient(params);




