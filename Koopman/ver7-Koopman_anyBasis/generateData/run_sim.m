function data = run_sim( params )
%gen_data: Runs a simulation and generates system "measurement"
%   Detailed explanation goes here

% add folder containing system dynamics to path
vf_path = [pwd, filesep, 'systemDynamics'];
addpath(vf_path);

get_input(0,0,params,'clear');
options = odeset('OutputFcn',@(t,x,flag) get_input(t, x, params, flag), 'refine', 1);
x0 = params.x0;
sol = ode45(@(t, x) params.vf_real(t, x, get_input(t,x,params, 'pass2ode'),params),[0 params.duration], x0, options);    % with damping

tout = sol.x;
usol = get_input(0,0,params,'allout');


%% Get state "measurements"

% get the state at sampled times
t = (0 : params.Ts : params.duration)';
x = deval(sol, t)';
u = interp1(tout, usol, t);

% isolate observed states (may not be full state)
yobs = x(:, logical(params.observe));

% inject noise to simulate measurement noise
noise = params.sigma .* randn(size(yobs)) + params.mean;
y = yobs + noise;

% if derivatives are not observed, estimate them by taking numerical derivs
if params.numericalDerivs
    % filter state measurements to lessen noise impact
    yfilt = movmean(y, params.filterWindow(1));
    
    % take numerical derivatives between sampled points
    numstates = params.n/2;
    ydot = ( yfilt(2:end, :) - yfilt(1:end-1,:) ) / params.Ts;
    ydot = [ydot; zeros(1,numstates)];  % pad end with zeros to make size consistent
    
    % filter numerical derivatives to lessen noise impact
    ydotfilt = movmean(ydot, params.filterWindow(2));
    y = [yfilt, ydotfilt];
end

% define output
data = struct;
data.t = t;     % time vector
data.y = y;     % state "measurements"
data.u = u;     % input
data.x = x;     % actual state
% data.params = params;   % parameter values for this simulation


% remove folder conatining system dynamics to path
rmpath(vf_path);

end

