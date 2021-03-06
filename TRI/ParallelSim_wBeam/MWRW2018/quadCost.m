function [ H, f , A, b, Aeq, beq] = quadCost( x, error, params, fload, penalty )
%quadCost: Calculates the H and f matrices for the quadratic cost function
%whose minimum lies at the equilibrium point.
%   See Matlab documentation on 'quadprog' for more info.

% check for optional arguments
if ~exist('fload','var')
     % fload input does not exist, so default it to 0
      fload = zeros(6,1);
end
if ~exist('penalty','var')
     % penalty input does not exist, so default it to 1e-5
      penalty = 1e-5;
end

num = params.num;
D = params.D;   % matrix describing the attachment points of actuators to end effector
[Kp, Ki, Kd] = deal(params.Kp, params.Ki, params.Kd);   % PID gains

% integral and derivative error
global errI;    % global integral error variable


% q = x2q(x);
q = euler2free_MWRW(x(4:6), params);    % edited so that q follows the correct convention
Jq = calcJq(q, params);

% calculate the elastomer force (set equal to zero, will be ignored)
felast = zeros(6,1);

%% Put the tolerance value into the cost and optimize over it along with p, don't even minimize pressure

% H = blkdiag( eye(num), zeros(6,6) );    % want to find solution that minimizes pressure FREEs and satisfies model constraints
H = blkdiag( zeros(num,num), eye(6) );    % want to find solution that minimizes pressure FREEs and satisfies model constraints
f = zeros(num + 6,1);

% need more slack so will use inequality constraints with tolerance
A = [D*Jq', -eye(6);...
    -D*Jq', -eye(6)];
% b = [-(Kp*error.p + Ki*error.i + Kd*error.d + fload);...
%     (K.p*error.p + K.i*error.i + K.d*error.d + fload)];
b = [-(Kp*error + Ki*errI + fload);...
    (Kp*error + Ki*errI + fload)]; % simple proportional control

Aeq = [D*Jq', -eye(6)];
beq = [-(Kp*error + fload)];

% Aeq = [];
% beq = [];


%% New version hopefully works better

% % define output matrices
% H = penalty*eye(num);
% f = zeros(num,1);
% Aeq = D*Jq';    % equality constraint makes boundary minima infeasable
% beq = -(felast + fload);
% 
% % need more slack so will use inequality constraint instead
% tol = 8e-2;
% A = [D*Jq' ; -D*Jq'];
% b = [-(felast + fload) + tol ;...
%     -( -(felast + fload) - tol ) ];


%% Older version
% % define output matrices
% H = 2 * Jq*(D'*D)*Jq' + penalty*eye(num);
% f = 2 * Jq*D'*(felast + fload);
% Aeq = D*Jq';    % equality constraint makes boundary minima infeasable
% beq = -(felast + fload);
% 
% % need more slack so will use inequality constraint instead
% A = [D*Jq' ; -D*Jq'];
% b = [-(felast + fload) + params.tol ;...
%     -( -(felast + fload) - params.tol ) ];


%% older version with linear stiffness matrix instead of elastomer function
% 
% % define output matrices
% H = 2 * Jq*(D'*D)*Jq' + penalty*eye(num);
% f = 2 * Jq*D'*(C*q + fload);
% Aeq = D*Jq';    % equality constraint makes boundary minima infeasable
% beq = -(D*C*q + fload);

end