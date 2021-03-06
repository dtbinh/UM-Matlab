function data = gen_data( params )
%gen_data: Runs a simulation and generates system "measurement"
%   Detailed explanation goes here

get_input(0,0,params,'clear');
options = odeset('OutputFcn',@(t,x,flag) get_input(t, x, params, flag), 'refine', 1);
x0 = [params.phi1; params.phi2; params.dtphi1; params.dtphi2];
sol = ode45(@(t, x) double_pendulum_ODE(t, x, get_input(t,x,params, 'pass2ode'),params),[0 params.duration], x0, options);    % with damping
% sol = ode45(@(t, x) double_pendulum_ODE_nodamp(t, x, get_input(t,x,params, 'pass2ode'), params),[0 params.duration], x0, options);      % without damping
tout = sol.x;
[~,usol] = get_input(0,0,params,'allout');


%% Get state "measurements"

% get the state at sampled times
t = (0 : params.Ts : params.duration)';
y = deval(sol, t)';
u = interp1(tout, usol, t);

% define observed states (this may be different than simulation states, 
%   e.g. could track only angular positions, or the xy position of end eff)
theta1 = y(:,1);
theta2 = y(:,2);
dtheta1 = y(:,3);
dtheta2 = y(:,4);
x1 = params.l1 * sin(theta1);
y1 = -params.l1 * cos(theta1);
x2 = x1 + params.l2 * sin(theta2);
y2 = y1 - params.l2 * cos(theta2);
x1dot = params.l1 * cos(theta1) .* dtheta1;
y1dot = params.l1 * sin(theta1) .* dtheta1;
x2dot = x1dot + params.l2 * cos(theta2) .* dtheta2;
y2dot = y1dot + params.l2 * sin(theta2) .* dtheta2;

xobs = y(:,1:4);    % full state in theta coordinates
% xobs = [x1, y1, x2, y2, x1dot, y1dot, x2dot, y2dot];    % full state in xy coordinates
% xobs = [x2, y2, x2dot, y2dot];    % just end effector xy position

% inject noise to simulate measurement noise
noise = params.sigma .* randn(size(xobs)) + params.mean;
x = xobs + noise;

% moving average filter to reduce impact of noise
x = movmean(x, 5);

% use numerical derivatives for thetadot instead of measured ones (comment out this section for full state measurements)
xdot = ( x(2:end, 1:2) - x(1:end-1,1:2) ) / params.Ts;
xdot = [xdot; zeros(1,2)];
xdot = movmean(xdot, 5);    % filter the numerical derivatives 
x = [x(:, 1:2) , xdot(:,:)];

% define output
data = struct;
data.t = t;
data.x = x;
data.u = u;

end




%% Define the system input as a function of time (and state if desired)
function [status, out_u] = get_input(t,x,params, flag)
%   will want to parametrize in terms of some params later...

% unew = 10*sin( (1/(2*pi)) * t) .* sin( 3*t - 1.5*cos(t) );
% unew = 10*sin(0.1*t) + cos(t);
% unew = 20 * rand  - 10;
% unew = zeros(size(t));  % just trying this for now! CHANGE LATER
% unew = 10 * rand(size(t)) - 5;
% unew = 5*(1 - exp(-t));
unew = params.amp * sin(2*pi*params.freq * t);

persistent u

% Initialize input:
if isempty(u)
    u = unew;
end

if isempty(flag)
    % Successful integration step! Generate a new value:
    u = [u; unew];
    status = 0;

elseif strcmp(flag,'allout')
    out_u = u;
    status = 0;
    
elseif strcmp(flag,'pass2ode')
    out_u = u(end);
    status = out_u; % hacky way of making the relevant value the primary output

elseif strcmp(flag,'clear')
    clear u;
    status = 0;

end

% % Always keep integrating:
% status = 0;

end

