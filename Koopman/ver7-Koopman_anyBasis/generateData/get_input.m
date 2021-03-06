function out = get_input(t,x,params, flag)
% get_input: Define the system input as a function of time (and state if desired)
% NOTE - only works for 1D state in current form!

if strcmp(params.inputType, 'sinusoid')
    unew = params.amp * sin(2*pi*params.freq * t);  % sinusoidal input
elseif strcmp(params.inputType, 'exponential')
    unew = params.amp*(1 - exp(-params.freq * t));  % exponential input
else
    unew = params.amp;      % step input
end

persistent u

% Initialize input:
if isempty(u)
    u = unew;
end

if isempty(flag)
    % Successful integration step! Generate a new value:
    u = [u; unew];
    out = 0;
    
elseif strcmp(flag,'allout')
    out = u;
    
elseif strcmp(flag,'pass2ode')
    out = u(end);
    
    
elseif strcmp(flag,'clear')
    clear u;
    out = 0;
    
end

end
