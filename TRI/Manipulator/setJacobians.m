function setJacobians(params)
%setJacobians: Defines the Jacobians of the system symbolically then
%creates Matlab functions to evaluate them.
%   Detailed explanation goes here


%% Module Block Jacobian

syms a_ki b_ki L_k x_k y_k z_k psi_k theta_k phi_k real

% The state of the ith actuator of the kth module (q_ki) in terms of the state of
% the kth module in local coordinate frame (X_k).
s_ki = -L_k + sqrt( (L_k - sin(theta_k)*a_ki + cos(theta_k)*sin(psi_k)*b_ki)^2 + (a_ki^2 + b_ki^2)*phi_k^2 );
w_ki = phi_k;

q_ki = [s_ki, w_ki]';
X_k = [x_k, y_k, z_k, psi_k, theta_k, phi_k];

J_ki = jacobian(q_ki, X_k);

% Create Matlab function for evaluating J_ki
matlabFunction(J_ki, 'File', 'J_ki', 'Vars', {[x_k, y_k, z_k, psi_k, theta_k, phi_k], [a_ki, b_ki], L_k});



%% Manipulator Block Jacobian

% selection matrix to isolate position component of module state
Spos = [eye(3), zeros(3,3); zeros(3,3), zeros(3,3)];



end

