%% Calculate dfdx, dfdxdot from f (only the second & third row of f)

clear

syms r0 L0 gama0 P gama r L dP dgama dr dL c1 c2 c3 c4 c5 c6 x

x = [P gama r L];
xdot = [dP dgama dr dL];

%f3 = [c5*((tan(gama)*dL)/r + (L*(tan(gama)^2 + 1)*dgama)/r - (tan(gama)*L*dr)/r^2) + 2*c4*((L0*tan(gama0))/r0 - (tan(gama)*L)/r)*((tan(gama)*dL)/r + (L*(tan(gama)^2 + 1)*dgama)/r - (tan(gama)*L*dr)/r^2) + 2*pi*cot(gama)*r^3*dP - 2*pi*P*r^3*dgama*(cot(gama)^2 + 1) + 6*pi*cot(gama)*P*r^2*dr];
%f3 = [c5*((tan(gama)*dL)/r + (L*(tan(gama)^2 + 1)*dgama)/r - (tan(gama)*L*dr)/r^2) - 2*c4*((L0*tan(gama0))/r0 - (tan(gama)*L)/r)*((tan(gama)*dL)/r + (L*(tan(gama)^2 + 1)*dgama)/r - (tan(gama)*L*dr)/r^2) - 2*pi*cot(gama)*r^3*dP + 2*pi*P*r^3*dgama*(cot(gama)^2 + 1) - 6*pi*cot(gama)*P*r^2*dr];
%f3 = [c5*((tan(gama)*dL)/r + (L*(tan(gama)^2 + 1)*dgama)/r - (tan(gama)*L*dr)/r^2) - 2*c4*((L0*tan(gama0))/r0 - (tan(gama)*L)/r)*((tan(gama)*dL)/r + (L*(tan(gama)^2 + 1)*dgama)/r - (tan(gama)*L*dr)/r^2) + 2*pi*cot(gama)*r^3*dP - 2*pi*P*r^3*dgama*(cot(gama)^2 + 1) + 6*pi*cot(gama)*P*r^2*dr];

% f2 = [c2*dL + 2*c1*L*dL + pi*r^2*dP + 2*pi*P*r*dr - 2*pi*cot(gama)^2*r^2*dP - 4*pi*cot(gama)^2*P*r*dr + 4*pi*cot(gama)*P*r^2*dgama*(cot(gama)^2 + 1)];
% f3 = [c5*((tan(gama)*dL)/r + (L*(tan(gama)^2 + 1)*dgama)/r - (tan(gama)*L*dr)/r^2) - 2*c4*((L0*tan(gama0))/r0 - (tan(gama)*L)/r)*((tan(gama)*dL)/r + (L*(tan(gama)^2 + 1)*dgama)/r - (tan(gama)*L*dr)/r^2) - 2*pi*cot(gama)*r^3*dP + 2*pi*P*r^3*dgama*(cot(gama)^2 + 1) - 6*pi*cot(gama)*P*r^2*dr];

%% 1/6/2017: Made it so F_elast is a function of (L-L0)
% f2 = c2*dL - 2*c1*dL*(L0 - L) + pi*r^2*dP + 2*pi*P*r*dr - 2*pi*cot(gama)^2*r^2*dP - 4*pi*cot(gama)^2*P*r*dr + 4*pi*cot(gama)*P*r^2*dgama*(cot(gama)^2 + 1);
% f3 = c5*((tan(gama)*dL)/r + (L*(tan(gama)^2 + 1)*dgama)/r - (tan(gama)*L*dr)/r^2) - 2*c4*((L0*tan(gama0))/r0 - (tan(gama)*L)/r)*((tan(gama)*dL)/r + (L*(tan(gama)^2 + 1)*dgama)/r - (tan(gama)*L*dr)/r^2) - 2*pi*cot(gama)*r^3*dP + 2*pi*P*r^3*dgama*(cot(gama)^2 + 1) - 6*pi*cot(gama)*P*r^2*dr;                                                                                                                                                                                                                                                                                                                                                                                                                 
% f4 = sin(gama)*dgama + (cos(gama0)*dL)/L0;
%  
%% 1/7/2017: Got rid of a minus sign in front of phi that I had added earlier
% f2 = c2*dL + 2*c1*L*dL + pi*r^2*dP + 2*pi*P*r*dr - 2*pi*cot(gama)^2*r^2*dP - 4*pi*cot(gama)^2*P*r*dr + 4*pi*cot(gama)*P*r^2*dgama*(cot(gama)^2 + 1);
% f3 = 2*pi*P*r^3*dgama*(cot(gama)^2 + 1) - 2*c4*((L0*tan(gama0))/r0 - (tan(gama)*L)/r)*((tan(gama)*dL)/r + (L*(tan(gama)^2 + 1)*dgama)/r - (tan(gama)*L*dr)/r^2) - 2*pi*cot(gama)*r^3*dP - c5*((tan(gama)*dL)/r + (L*(tan(gama)^2 + 1)*dgama)/r - (tan(gama)*L*dr)/r^2) - 6*pi*cot(gama)*P*r^2*dr;
% f4 = sin(gama)*dgama + (cos(gama0)*dL)/L0;

%% 1/10/2017: Made F_elast = (L-L0), M_elast = phi
% f2 = dL + pi*r^2*dP + 2*pi*P*r*dr - 2*pi*cot(gama)^2*r^2*dP - 4*pi*cot(gama)^2*P*r*dr + 4*pi*cot(gama)*P*r^2*dgama*(cot(gama)^2 + 1);
% f3 = (tan(gama)*L*dr)/r^2 - (L*(tan(gama)^2 + 1)*dgama)/r - (tan(gama)*dL)/r - 2*pi*cot(gama)*r^3*dP + 2*pi*P*r^3*dgama*(cot(gama)^2 + 1) - 6*pi*cot(gama)*P*r^2*dr;                                                                                                                                                                                                
% f4 = sin(gama)*dgama + (cos(gama0)*dL)/L0;


%% 1/11/2017: Made F_elast = M_elast = 0
% f2 = pi*r^2*dP + 2*pi*P*r*dr - 2*pi*cot(gama)^2*r^2*dP - 4*pi*cot(gama)^2*P*r*dr + 4*pi*cot(gama)*P*r^2*dgama*(cot(gama)^2 + 1);                                                                       
% f3 = 2*pi*P*r^3*dgama*(cot(gama)^2 + 1) - 2*pi*cot(gama)*r^3*dP - 6*pi*cot(gama)*P*r^2*dr;                                                                                                                                                
% f4 = sin(gama)*dgama + (cos(gama0)*dL)/L0;

%% 1/12/2017: Made F_elast = (L-L0), M_elast = theta
% f2 = dL + pi*r^2*dP + 2*pi*P*r*dr - 2*pi*cot(gama)^2*r^2*dP - 4*pi*cot(gama)^2*P*r*dr + 4*pi*cot(gama)*P*r^2*dgama*(cot(gama)^2 + 1);
% f3 = (tan(gama)*dL)/r + (L*(tan(gama)^2 + 1)*dgama)/r - (tan(gama)*L*dr)/r^2 - 2*pi*cot(gama)*r^3*dP + 2*pi*P*r^3*dgama*(cot(gama)^2 + 1) - 6*pi*cot(gama)*P*r^2*dr;                                                                                                                                                                                                                    
% f4 = sin(gama)*dgama + (cos(gama0)*dL)/L0;

%% 1/12/2017: Made F_elast = (L-L0)*(r/r0), M_elast = phi*(r/r0)
% f2 = pi*r^2*dP + (r*dL)/r0 - (dr*(L0 - L))/r0 + 2*pi*P*r*dr - 2*pi*cot(gama)^2*r^2*dP - 4*pi*cot(gama)^2*P*r*dr + 4*pi*cot(gama)*P*r^2*dgama*(cot(gama)^2 + 1);
% f3 = (((L0*tan(gama0))/r0 - (tan(gama)*L)/r)*dr)/r0 - (r*((tan(gama)*dL)/r + (L*(tan(gama)^2 + 1)*dgama)/r - (tan(gama)*L*dr)/r^2))/r0 - 2*pi*cot(gama)*r^3*dP + 2*pi*P*r^3*dgama*(cot(gama)^2 + 1) - 6*pi*cot(gama)*P*r^2*dr;
% f4 = sin(gama)*dgama + (cos(gama0)*dL)/L0;

%% 1/12/2017: Flipped the sign of first two terms in first equation (makes more sense, but doesn't match ICRA)
% f2 = dL - pi*r^2*dP - 2*pi*P*r*dr + 2*pi*cot(gama)^2*r^2*dP + 4*pi*cot(gama)^2*P*r*dr - 4*pi*cot(gama)*P*r^2*dgama*(cot(gama)^2 + 1);
% f3 = (tan(gama)*L*dr)/r^2 - (L*(tan(gama)^2 + 1)*dgama)/r - (tan(gama)*dL)/r - 2*pi*cot(gama)*r^3*dP + 2*pi*P*r^3*dgama*(cot(gama)^2 + 1) - 6*pi*cot(gama)*P*r^2*dr;
% f4 = sin(gama)*dgama + (cos(gama0)*dL)/L0;

%% Another attempt to match ICRA: F_elast = [c1 c2 c3]*[L^2 L 1]?; M_elast = [c4 c5 c6]*[theta^2 theta 1];
f2 = c2*dL + 2*c1*L*dL + pi*r^2*dP + 2*pi*P*r*dr - 2*pi*cot(gama)^2*r^2*dP - 4*pi*cot(gama)^2*P*r*dr + 4*pi*cot(gama)*P*r^2*dgama*(cot(gama)^2 + 1);
f3 = 2*pi*cot(gama)*r^3*dP + (c5*tan(gama)*dL)/r + (2*c4*tan(gama)^2*L*dL)/r^2 - 2*pi*P*r^3*dgama*(cot(gama)^2 + 1) + (c5*L*(tan(gama)^2 + 1)*dgama)/r - (2*c4*tan(gama)^2*L^2*dr)/r^3 + 6*pi*cot(gama)*P*r^2*dr - (c5*tan(gama)*L*dr)/r^2 + (2*c4*tan(gama)*L^2*(tan(gama)^2 + 1)*dgama)/r^2;
f4 = sin(gama)*dgama + (cos(gama0)*dL)/L0;


%% Calculate gradients
df2dx = jacobian(f2, x);
df2dxdot = jacobian(f2, xdot);

df3dx = jacobian(f3, x);
df3dxdot = jacobian(f3, xdot);

df4dx = jacobian(f4, x);
df4dxdot = jacobian(f4, xdot);
