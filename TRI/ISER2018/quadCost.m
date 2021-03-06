function [ H, f , A, b, Aeq, beq] = quadCost( x, params, fload, penalty )
%quadCost: Calculates the H and f matrices for the quadratic cost function
%whose minimum lies has at the equilibrium point.
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
[C, D] = deal(params.C, params.D);

q = x2q(x);
Jq = calcJq(q, params);

% calculate the elastomer force
felast = calcFelast( x, params );

%% Put the tolerance value into the cost and optimize over it along with p, don't even minimize pressure

% H = blkdiag( zeros(num,num), eye(6) );    % original, most basic version of quadratic cost
% H = blkdiag( zeros(num,num), blkdiag( eye(4), zeros(2,2) ) );    % want to find solution that minimizes tolerance and satisfies model constraints
% H = blkdiag( eye(num) * 1e-6, blkdiag( eye(4), zeros(2,2) ) * 1e3 );    % want to find solution that minimizes pressure and tolerance and satisfies model constraints
% H = blkdiag( eye(num), zeros(6,6) );    % want to find solution that minimizes pressure and satisfies model constraints
H = blkdiag( blkdiag( eye(3) ), zeros(6,6) );    % want to find solution that minimizes pressure of FREEs 1 and 2 and satisfies model constraints
% H = blkdiag( blkdiag( eye(2), [1.5e-2] ), zeros(6,6) );    % want to find solution that minimizes pressure of FREEs 1 and 2 and satisfies model constraints
f = zeros(num + 6,1);

% need more slack so will use inequality constraints with tolerance
A = [D*Jq', -eye(6);...
    -D*Jq', -eye(6)];
b = [-(felast + fload);...
    (felast + fload)];


Aeq = [];
beq = [];


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

