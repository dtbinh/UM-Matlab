%% ODE15i Simulation

%% ODE15i Simulation
%   Use this to check of the dynamics are broken, or if it's something else

tspan = [0, 20];
x0 = 1e-6*[0 0 0 0 0 0]';       % initial point
xdot0 = 0*1e-6*[1 1 1 1 1 1]';
u = [1000, 0, 0, 1000]';

% options = odeset('abstol', 1e-6, 'reltol', 1e-6, 'NonNegative', 1);

% Check that initial conditions make sense
fixed_x0 = [1 1 1 0 0 0];
fixed_xdot0 = [0 0 0 0 0 0];
[x0_new,xdot0_new] = decic(@(t, x, xdot)vf(x,calc_u(t),xdot,params),0,x0,fixed_x0,xdot0,fixed_xdot0);

[t, y] = ode15i(@(t, x, xdot)vf(x, calc_u(t), xdot, params), tspan, x0_new, xdot0_new);

%Plot the results
figure
plot(t,y(:,1:3))
legend('psi','theta','phi')

figure
plot(t,y(:,4:6))
legend('psidot','thetadot','phidot')