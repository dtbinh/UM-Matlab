function xdot = DCmotor_vf(x,u,params)
% DCmotor_vf: Ordinary differential equations for double pendulum.
%
%   author:  Alexander Erlich (alexander.erlich@gmail.com)
%
%   parameters:
%
%   t       Column vector of time points 
%   xdot    Solution array. Each row in xdot corresponds to the solution at a
%           time returned in the corresponding row of t.
%
%
%   ---------------------------------------------------------------------

La = params.La;
Ra = params.Ra;
km = params.km;
J = params.J;
B = params.B;
tau1 = params.tau1;
ua = params.ua;

if isa(x,'sym')
    xdot = sym( 'xdot' , [params.n,1] );
else
    xdot = zeros(2,1);
end
xdot(1) = -(Ra/La) * x(1) - (km/La) * x(2) * u + ua/La;
xdot(2) = -(B/J) * x(2) + (km/J) * x(1) * u - tau1/J;


% if input is symbolic, create matlab function that evaluates these
% dynamics with the given parameters.
if isa( x , 'sym' )
    name = [ 'simDynamics' , filesep , params.name , '_dynamics.m' ];
    matlabFunction( xdot, 'File', name, 'Vars', {x , u} );
end

end