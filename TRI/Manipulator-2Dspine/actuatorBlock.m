function [Z, Vdot] = actuatorBlock( P, qdot, alpha, params)
%actuatorBlock: Relates inputs (pressure) to forces generated by the actuators (FREEs)
%   Currently using the linear FREE model. NOTE: This is only a
%   placeholder, this function can be used to implement any FREE model by
%   replacing the contents of this function.

p = params.p;   % total modules in manipulator
n = params.n;   % number of actuators in each module (a vector)
B = params.B;   % FREE fiber length (array)
N = params.Nf;   % FREE total fiber windings in revolutions (when relaxed) (array)
L = params.L;   % length of central spine of each module

% Define the extension and twist of each FREE with respect to x
q = alpha2q(alpha , params);
s = q;

%% Define volume Jacobain
Jv = zeros(n, n);      % initialize Jv
for i = 1:n
    Jv_ki = (pi*(B(i)^2 - 3*(L+s(i))^2) / (2*pi*N(i))^2);
             
         
    Jv( i, i ) = Jv_ki;     % stack volume jacobian for each actuator diagonally to form Jv.   
end

%% Define elastomer stiffness and damping matrices

% elastomer spring constants (could set these values in setParams, but I wanted to keep that script agnostic about the FREE model for now).
kelast = [-4e1]';     % [axial stiffness, rotational stiffness]'

Kc = eye(length(q)) * kelast;   % elastomer stiffness matrix
Kd = zeros(length(q), length(q));   % elastomer damping matrix

%% Set output values
Vdot = Jv * qdot;
Z = Jv' * P + Kc * q + Kd * qdot;



end
