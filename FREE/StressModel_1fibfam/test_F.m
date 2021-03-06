function F = test_F(x, params)

[P, gama, r, L, phi, T] = deal(x(1), x(2), x(3), x(4), x(5), x(6));
[P0, gama0, r0, L0, phi0, T0] = deal(params.x_rest(1), params.x_rest(2), params.x_rest(3), params.x_rest(4), params.x_rest(5), params.x_rest(6));

%% Definition of modulus of elasticity equations
dL_norm = (L - L0)/L0;
dphi_norm = atan(r*phi)/L0;

E = params.modulus(1);    % constant modulus
G = params.modulus(2);    % constant modulus
% E = params.modulus(1,1)*dL_norm + params.modulus(1,2);  % varying modulus
% G = params.modulus(2,1)*dphi_norm + params.modulus(2,2);    % varying modulus

u = 10; % just some number
%% Set value of output    
    F = Feval(x, params.x_rest, params.t_rest, params.load, u);

end