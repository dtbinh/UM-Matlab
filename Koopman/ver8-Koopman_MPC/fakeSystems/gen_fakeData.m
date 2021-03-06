function fakeData = gen_fakeData( sysName, sysvf, sysinput, params )
%gen_fakeData: generates a csv with fake test data from a nonlinear system
% with input
%   Can use the mat file generated by this function to test the rest of the code
%   sysName:    string that describes name of system, i.e. 'doublePendulum'
%   sysvf:      function handle for system dynamics, i.e. @dp_vf
%   sysinput:   function handle for system input function, i.e. @dp_input
%   params:     struct containing parameters such as sampling time, IC, ... 


Ts = params.Ts;     % sampling period
x0 = params.x0;     % initial condition
tf = params.tf;     % finel time (length of simulation)

tspan = 0 : Ts : tf ;

% Create vector of control inputs
u = zeros(length(tspan) , params.p);
for i = 1 : length(tspan)
    u(i,:) = sysinput(tspan(i), params)';
end

[t, v] = ode45(@(t,x) sysvf(x, sysinput(t, params), params), tspan, x0);   % simulate plant response input (defined below)

tq = (0:Ts:tf)';
vq = interp1(t,v,tq);   % interpolate results to get samples at sampling interval Ts
uq = interp1(t,u,tq);

% inject noise with standard deviation 0.01
mean = 0;   % mean offset
sigma = 0.01;   % standard deviation
noise = sigma .* randn(size(vq)) + mean;
vq = vq + noise;

% Make proper variable names for .mat file
t = tq;
x = vq;
u = uq;

%% save datafile without overwriting previous files with same name
% SaveWithNumber(['dataFiles', filesep, params.systemName, '.mat'], data);
[unique_fname, change_detect] = auto_rename(['simData', filesep, sysName, '.mat'], '0');
save(unique_fname, 't', 'x', 'u');

%% define output
fakeData = struct;
fakeData.t = tq;
fakeData.x = vq;
fakeData.u = uq;
    
end