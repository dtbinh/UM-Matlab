% solve_FB- just solves for the tension forces given a pressure and a given
%   FREE geometry


function [Tgama, Tbetta, P, gama, betta, r, L, phi] = solveFB(P_test, x_rest)


[P0, gama0, betta0, r0, L0, phi0] = deal(x_rest(1), x_rest(2), x_rest(3), x_rest(4), x_rest(5), x_rest(6));

x_test = [P_test, gama0, betta0, r0, L0, phi0];

LB = [0, 0, P_test+1e-3, -pi/2, -pi/2, r0, 0, -inf]; 
UB = [inf, inf, P_test+1e-3, pi/2, pi/2, inf, inf, inf];

dx = 1e-3;

% LB = [0, 0, P_test-dx, gama0-dx, betta0-dx, r0-dx, L0-dx, phi0-dx]; 
% UB = [inf, inf, P_test+dx, gama0+dx, betta0+dx, r0-dx, L0+dx, phi0+dx];

% solver variable
Tx = lsqnonlin(@(Tx) FB(P_test, Tx(1:2), Tx(3:8), x_rest), [0, 0, x_rest], LB, UB);

Tgama = Tx(1);
Tbetta = Tx(2);
P = Tx(3);
gama = Tx(4);
betta = Tx(5);
r = Tx(6);
L = Tx(7);
phi = Tx(8);

end