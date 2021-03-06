% main: Run the Koopman sysid process on a user defined nonlinear system
% w/input
%
%   DNE = "do not edit this line"
clear all;

%% USER EDIT SECTION

% define parameters
params = struct;  % DNE

params.n = 2;   % dimension of state space
params.p = 1;   % dimension of input
params.naug = params.n + params.p; % dimension of augmented state (DNE)

% select maximum degrees for monomial bases (NOTE: m1 = 1 )
params.maxDegree = 3;   % maximum degree of vector field monomial basis
params.m1 = 1;  % maximum degree of observables to be mappee through Lkj (DNE)
params = def_polyLift(params);  % creates the lifting function, polyLift

params.Ts = 0.2;   % sampling period
params.numTrials = 5;  % number of "experiments" to run from different initial conditions
params.x0lb = [-1, -1]'; % lower bound of initial state condition
params.x0ub = [1, 1]';  % upper bound of initial state condition
params.ulb = [-1]'; % lower bound of input
params.uub = [1]';  % upper bound of input
params.tf = 10; % simulation time for each "experiment"
% NOTE: to change input function used in trials edit "get_u.m"

% define dynamics: xdot = f(x,u)
x = params.x;    % DNE
u = params.u;    % DNE

vf = [x(2);...
      x(1) - x(1)^3 - 0.2*x(2) + 0.2*x(1)^2 * u(1)];

matlabFunction(vf, 'File', 'vf_real', 'Vars', { x, u }); % create plant dynamics func. (DNE)


%% Simulate and find Koopman operator from "measurements" (DNE)

[x,y] = get_snapshotPairs(params);
U = get_Koopman(x,y, params);

%% Calculate the infiniesimal generator as funtion of coeffients, and from data (DNE)
Ldata = get_Ldata(U, params);   % infinitesimal generator from data
Ldata_hat = Ldata(:, 1:params.N1);  % N x N1 version of Ldata (projection onto the polyBasis)
vecLdata = Ldata_hat(:);    % vectorized version of Ldata matrix

vecstackL = zeros(params.N*params.N1, params.N*params.n);
for k = 1:params.N
    for j = 1:params.n
        Lkj = get_Lkj(k,j,params);
        
        % convert all the Lkj's into vectors and stack them horizontally
        vecLkj = Lkj(:);
        vecstackL(:, (k-1)*params.n + j) = vecLkj;
    end
end

%% solve for the coefficients, i.e. Eq. (18) from Mauroy and Gonclaves (DNE)

W = pinv(vecstackL) * vecLdata;

% matrix of coefficents of monomials
w = reshape(W, [params.n, params.N]);

% dynamics (gives symbolic expression in terms of state)
vf2 = w * params.polyBasis; 
matlabFunction(vf2, 'File', 'vf_sysid', 'Vars', {params.x, params.u});

%% Run simulatio of sysId'd system and compare results to real system (DNE)

% compare the coefficients of the real system to the modeled system
wreal = get_coeffs(vf, params); % real coefficients of plant
wsysid = w; % estimated cefficients
error = wreal-wsysid;
rmse = sqrt( sum(sum(error.^2)) / (params.n * params.N));


tspan = [0, params.tf];
x0sim = (params.x0ub - params.x0lb)*rand + params.x0lb; % random initial state
[tsysid, xsysid] = ode45(@(t,x) vf_sysid(x, get_u(t, params)), tspan, x0sim);
[treal, xreal] = ode45(@(t,x) vf_real(x, get_u(t, params)), tspan, x0sim);

% plot the results
figure
subplot(2,1,1)
plot(treal,xreal)
title('Real system')
subplot(2,1,2)
plot(tsysid,xsysid)
title('Identified system')


