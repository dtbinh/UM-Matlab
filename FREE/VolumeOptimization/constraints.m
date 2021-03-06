function [c,ceq] = constraints(x, params)
%constraints: Constraints to the volume maximization problem
%   This ensures that the radius at the ends is equal to the radius of the
%   endcaps.

[l, phi, a0, a1, a2, a3, a4, a5, a6] = deal(x(1), x(2), x(3), x(4), x(5), x(6), x(7), x(8), x(9));
p = [a6, a5, a4, a3, a2, a1, a0];

ceq = [a0 - params.R;...    % radius of left endcap
       polyval(p,l) - params.R;... ];  % radius of right endcap
%        fibconst(x);...
       phi]; % phi=0 added as constraint to emulate McKibbon muscle


% z = linspace(0,l,100)';  % want this constraint to hold at all points
% c = [-(a0*ones(size(z)) + a1*z + a2*z.^2 + a3*z.^3 + a4*z.^4 + a5*z.^5 + a6*z.^6)];   % radius cannot be less than zero

theta_err = thetaconst(x, params);  % evaluate the fiber inext. constraint

c = [abs(theta_err - 1e-8)];    % give it a buffer so it doesn't have to be exact


end

