function [ q ] = x2q( x, params )
%x2q: Relates end effector and FREE states
%   Detailed explanation goes here

q = zeros(2*params.num, 1); % set proper size of q, 2nx1

% Assume end effector displacement is the same as FREE displacement
q(1:2:end) = x(3)*ones(3,1);  % s
q(2:2:end) = x(6)*ones(3,1);  % w

end

