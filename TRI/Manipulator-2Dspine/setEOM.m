function setEOM(params)
%setDynamics: Symbolically derives Euler-Lagrange EOM, then creates
%function to evaluate them.
%   Assumptions: 
%       -all mass is concentrated at the module connecting blocks (i.e. FREEs and spine are massless).
%       -spine does not contribute forces.

%% Define symbolic parameters

p = params.p;   % total number of modules
n = params.n;   % number of actuators in each module (a vector)
L = params.L;   % length of each module
M = params.M;
I = params.I;

g = 9.81;   % acceleration due to gravity, 9.81 m/s^s

%m = sym('m', [p,p], 'real');    % masses of the module blocks
%I = sym('I', [p,p], 'real');      % rotational moment of inertia matrices of the module blocks expressed in the local coordinate frame, vertically concatenated

zeta = sym('zeta', [p,1], 'real');
tau = sym('tau', [p,1], 'real');

alpha = sym('alpha', [p,1], 'real');
alphadot = sym('alphadot', [p,1], 'real');
alphaddot = sym('alphaddot', [p,1], 'real');

x = alpha2x_sym(alpha, params);
Jax = J_ax(alpha);
xdot = Jax * alphadot;

%% Define the Lagrangian


% kinetic energy
KE = (1/2) * xdot' * M * xdot + (1/2) * alphadot' * I * alphadot;

% potential energy
PE = 0;
for i = 1:p
   PE = PE - g* x(3*(i-1)+2,1) * M(i,i); 
end

% lagrangian
Lagrangian = KE - PE;


%% Euler Lagrange Equations of Motion (using my own code)

dLdalphadot = jacobian(Lagrangian, alphadot)';
dLdalpha = jacobian(Lagrangian, alpha)';
%dLdx0 = dLdx0' * jacobian(x00, x0);
%dLdx0 = dLdx0';

% define x0 and x0dot as functions of time
syms t
x0t = zeros(p,1);
x0t = sym(x0t);
x0tdot = zeros(p,1);
x0tdot = sym(x0tdot);
for j = 1 : p
   jstr = num2str(j);
   
   x0t(j) = sym(strcat('x0t', jstr, '(t)'));
   x0tdot(j) = sym(strcat('x0tdot', jstr, '(t)'));
end

dLdx0dot_t = subs(dLdalphadot, [alpha, alphadot], [x0t, x0tdot]);
dLdx0_t = subs(dLdalpha, [alpha, alphadot], [x0t, x0tdot]);

% Euler Lagrange Equations of motion
EOM_raw = diff(dLdx0dot_t, t) - dLdalpha - zeta - tau;    % assuming no load on the system 

% Character substitutions to get rid of all the 'diff(x(t), t)' stuff in EOM_raw
Dx0t = sym( zeros(p,1) );        % x0dot written in gross way, e.g. x0dot = diff(x0(t), t)
Dx0tdot = sym( zeros(p,1) );     % x0ddot written in gross way, e.g. x0ddot = diff(x0dot(t), t)
for i = 1:p
   istr = num2str(i);
   Dx0t(i,1) = sym(strcat( 'diff(x0t', istr, '(t), t)' )); 
   Dx0tdot(i,1) = sym(strcat( 'diff(x0tdot', istr, '(t), t)' )); 
end

EOM = subs(EOM_raw, [x0t; x0tdot; Dx0t; Dx0tdot], [alpha; alphadot; alphadot; alphaddot]);      % replace all instances of 't'

%% Creates Matlab function for evaluating the Equations of Motion
X0 = [alpha; alphadot];       % dynamics state vector, x0 and x0dot vertically concatenated
X0dot = [alphadot; alphaddot];
matlabFunction(EOM, 'File', 'EOM', 'Vars', {X0, X0dot, zeta, tau}, 'Optimize', false);

end










