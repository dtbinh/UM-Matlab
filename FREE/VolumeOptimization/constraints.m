function [c,ceq] = constraints(x, params)
%constraints: Constraints to the volume maximization problem
%   This ensures that the radius at the ends is equal to the radius of the
%   endcaps.

[l, phi, a0, a1, a2, a3, a4, a5, a6] = deal(x(1), x(2), x(3), x(4), x(5), x(6), x(7), x(8), x(9));

ceq = [a0 - params.R;...
       a0 + a1*l + a2*l^2 + a3*l^3 + a4*l^4 + a5*l^5 + a6*l^6 - params.R;...
       fibconst(x);...
       phi]; % phi=0 added as constraint to emulate McKibbon muscle

z = linspace(0,l,100)';  % want this constraint to hold at all points
% c = [-(a0*ones(size(z)) + a1*z + a2*z.^2 + a3*z.^3 + a4*z.^4 + a5*z.^5 + a6*z.^6)];
c = [];


end

