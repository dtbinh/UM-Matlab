function [zntp, ztmax, vx, vy] = zonotopeFun_noPlot(x, params)
% This function expects x to be only an s and w, which all the FREEs share!
% Also, this outputs ztmax whereas the original function doesn't.

% Set the displacement of the end effector
% x = [0, 0, 0, 0, 0, 0]';
% q = x2q(x, params);
stack = zeros(params.num*2,2);
stack(1:2:end, 1) = 1;
stack(2:2:end, 2) = 1;
q = stack*x;  % repeats q vertically for as many FREEs are in system


% Calculate the maximum Z = [F,M]' for each FREE
Zmax = maxZ(q, params);

% Convert Zmax to end effector coordinates for each FREE
zetamax = Z2zeta_i(Zmax, params);

% Generate the zonotope
ztmax = zeros(6,params.num);
for i = 1:params.num
    ztmax(:,i) = zetamax(6*(i-1)+1: 6*i, 1);   % stack them horizontially so genZonotope can read them
end

[zntp, vx, vy] = genZonotope(ztmax);

end