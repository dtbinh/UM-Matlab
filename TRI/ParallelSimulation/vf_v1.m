function [f, dfdx, dfdu, dfdxdot] = vf_v1(x, u, xdot, params)

% Define local names for relevant parameters
n = params.numFREEs;
L = params.Lspine;
a = params.xattach;
b = params.yattach;
m = params.m;
[Ipsi, Itheta, Iphi] = deal(params.I(1), params.I(2), params.I(3)); 
g = params.g;
kelast_s = params.kelast_s;
kelast_w = params.kelast_w;

% Define local names for states and inputs
[psi, theta, phi, dpsi, dtheta, dphi] = deal(x(1), x(2), x(3), x(4), x(5), x(6));
[ddpsi, ddtheta, ddphi] = deal(xdot(4), xdot(5), xdot(6));
[P1, P2, P3 P4] = deal(u(1), u(2), u(3), u(4));

% Define the extension and twist of each FREE with respect to x
q = euler2free(x,params);

% Define the Jacobian, Jeul, such that: qdot = Jeul * [dpsi,dtheta,dphi]'
Jeul = calc_Jeul(x, params);

% Define the Jacobian, Jv, such that fq = Jv * u
Jv = calc_Jv(x, params);

% FREE elastomer forces
Felast = [kelast_s; kelast_w] .* q;   % linear elastomer forces/torques

% Torques on end effector due to FREE forces, tau.
tau = Jeul' * (Jv*u + Felast);

% Define the differential equations of motion
f(1,1) = xdot(1) - dpsi;
f(2,1) = xdot(2) - dtheta;
f(3,1) = xdot(3) - dphi;
%% f(1,4)
f(4,1) = tau(1) - ((1/2).*g.*L.*m.*cos(theta).*sin(psi)+(1/4).*dpsi.^2.*L.^2.*m.*cos( ...
  psi).*cos(theta).^2.*sin(psi)+(1/4).*dtheta.^2.*L.^2.*m.*cos(psi) ...
  .*cos(theta).^2.*sin(psi)+(-1/2).*dpsi.*dtheta.*L.^2.*m.*cos( ...
  theta).*sin(psi).^2.*sin(theta)+(-1/2).*dpsi.*L.*m.*cos(psi).*cos( ...
  theta).*((-1/2).*dpsi.*L.*cos(theta).*sin(psi)+(-1/2).*dtheta.*L.* ...
  cos(psi).*sin(theta))+(1/2).*dtheta.*L.*m.*sin(psi).*sin(theta).*( ...
  (-1/2).*dpsi.*L.*cos(theta).*sin(psi)+(-1/2).*dtheta.*L.*cos(psi) ...
  .*sin(theta))+(1/2).*dphi.*dpsi.*L.^2.*m.*cos(phi).*cos(psi).*( ...
  cos(psi).*sin(phi)+(-1).*cos(phi).*sin(psi).*sin(theta))+(-1/2).* ...
  dphi.*dtheta.*L.^2.*m.*cos(psi).*cos(theta).*sin(phi).*(cos(psi).* ...
  sin(phi)+(-1).*cos(phi).*sin(psi).*sin(theta))+(-1/2).*dpsi.* ...
  dtheta.*L.^2.*m.*cos(phi).*cos(theta).*sin(psi).*(cos(psi).*sin( ...
  phi)+(-1).*cos(phi).*sin(psi).*sin(theta))+(-1/4).*dphi.^2.*L.^2.* ...
  m.*sin(phi).*sin(psi).*(cos(psi).*sin(phi)+(-1).*cos(phi).*sin( ...
  psi).*sin(theta))+(-1/4).*dpsi.^2.*L.^2.*m.*sin(phi).*sin(psi).*( ...
  cos(psi).*sin(phi)+(-1).*cos(phi).*sin(psi).*sin(theta))+(-1/4).* ...
  dphi.^2.*L.^2.*m.*cos(phi).*cos(psi).*sin(theta).*(cos(psi).*sin( ...
  phi)+(-1).*cos(phi).*sin(psi).*sin(theta))+(-1/4).*dpsi.^2.*L.^2.* ...
  m.*cos(phi).*cos(psi).*sin(theta).*(cos(psi).*sin(phi)+(-1).*cos( ...
  phi).*sin(psi).*sin(theta))+(-1/4).*dtheta.^2.*L.^2.*m.*cos(phi).* ...
  cos(psi).*sin(theta).*(cos(psi).*sin(phi)+(-1).*cos(phi).*sin(psi) ...
  .*sin(theta))+(1/2).*dphi.*dpsi.*L.^2.*m.*sin(phi).*sin(psi).*sin( ...
  theta).*(cos(psi).*sin(phi)+(-1).*cos(phi).*sin(psi).*sin(theta))+ ...
  (1/2).*dphi.*dtheta.*L.^2.*m.*cos(phi).*cos(psi).*cos(theta).*( ...
  cos(phi).*cos(psi)+(-1).*sin(phi).*sin(psi).*sin(theta))+(-1/2).* ...
  dphi.*dpsi.*L.^2.*m.*cos(psi).*sin(phi).*(cos(phi).*cos(psi)+(-1) ...
  .*sin(phi).*sin(psi).*sin(theta))+(-1/4).*dphi.^2.*L.^2.*m.*cos( ...
  phi).*sin(psi).*(cos(phi).*cos(psi)+(-1).*sin(phi).*sin(psi).*sin( ...
  theta))+(-1/4).*dpsi.^2.*L.^2.*m.*cos(phi).*sin(psi).*(cos(phi).* ...
  cos(psi)+(-1).*sin(phi).*sin(psi).*sin(theta))+(-1/2).*dpsi.* ...
  dtheta.*L.^2.*m.*cos(theta).*sin(phi).*sin(psi).*(cos(phi).*cos( ...
  psi)+(-1).*sin(phi).*sin(psi).*sin(theta))+(-1/4).*dphi.^2.*L.^2.* ...
  m.*cos(psi).*sin(phi).*sin(theta).*(cos(phi).*cos(psi)+(-1).*sin( ...
  phi).*sin(psi).*sin(theta))+(-1/4).*dpsi.^2.*L.^2.*m.*cos(psi).* ...
  sin(phi).*sin(theta).*(cos(phi).*cos(psi)+(-1).*sin(phi).*sin(psi) ...
  .*sin(theta))+(-1/4).*dtheta.^2.*L.^2.*m.*cos(psi).*sin(phi).*sin( ...
  theta).*(cos(phi).*cos(psi)+(-1).*sin(phi).*sin(psi).*sin(theta))+ ...
  (-1/2).*dphi.*dpsi.*L.^2.*m.*cos(phi).*sin(psi).*sin(theta).*(cos( ...
  phi).*cos(psi)+(-1).*sin(phi).*sin(psi).*sin(theta))+(1/4).*L.^2.* ...
  m.*(dtheta.*cos(phi).*cos(psi).*cos(theta)+dpsi.*cos(psi).*sin( ...
  phi)+dphi.*cos(phi).*sin(psi)+(-1).*dphi.*cos(psi).*sin(phi).*sin( ...
  theta)+(-1).*dpsi.*cos(phi).*sin(psi).*sin(theta)).*(dphi.*cos( ...
  phi).*cos(psi)+(-1).*dtheta.*cos(phi).*cos(theta).*sin(psi)+(-1).* ...
  dpsi.*sin(phi).*sin(psi)+(-1).*dpsi.*cos(phi).*cos(psi).*sin( ...
  theta)+dphi.*sin(phi).*sin(psi).*sin(theta))+(1/4).*L.^2.*m.*((-1) ...
  .*dphi.*cos(psi).*sin(phi)+(-1).*dpsi.*cos(phi).*sin(psi)+(-1).* ...
  dtheta.*cos(theta).*sin(phi).*sin(psi)+(-1).*dpsi.*cos(psi).*sin( ...
  phi).*sin(theta)+(-1).*dphi.*cos(phi).*sin(psi).*sin(theta)).*( ...
  dpsi.*cos(phi).*cos(psi)+dtheta.*cos(psi).*cos(theta).*sin(phi)+( ...
  -1).*dphi.*sin(phi).*sin(psi)+dphi.*cos(phi).*cos(psi).*sin(theta) ...
  +(-1).*dpsi.*sin(phi).*sin(psi).*sin(theta))+ddtheta.*((1/4).* ...
  L.^2.*m.*cos(psi).*cos(theta).*sin(psi).*sin(theta)+(1/4).*L.^2.* ...
  m.*cos(phi).*cos(psi).*cos(theta).*(cos(psi).*sin(phi)+(-1).*cos( ...
  phi).*sin(psi).*sin(theta))+(1/4).*L.^2.*m.*cos(psi).*cos(theta).* ...
  sin(phi).*(cos(phi).*cos(psi)+(-1).*sin(phi).*sin(psi).*sin(theta) ...
  ))+ddphi.*((1/4).*L.^2.*m.*cos(phi).*sin(psi).*(cos(psi).*sin(phi) ...
  +(-1).*cos(phi).*sin(psi).*sin(theta))+(-1/4).*L.^2.*m.*cos(psi).* ...
  sin(phi).*sin(theta).*(cos(psi).*sin(phi)+(-1).*cos(phi).*sin(psi) ...
  .*sin(theta))+(-1/4).*L.^2.*m.*sin(phi).*sin(psi).*(cos(phi).*cos( ...
  psi)+(-1).*sin(phi).*sin(psi).*sin(theta))+(1/4).*L.^2.*m.*cos( ...
  phi).*cos(psi).*sin(theta).*(cos(phi).*cos(psi)+(-1).*sin(phi).* ...
  sin(psi).*sin(theta)))+ddpsi.*(Ipsi+(1/4).*L.^2.*m.*cos(theta) ...
  .^2.*sin(psi).^2+(1/4).*L.^2.*m.*cos(psi).*sin(phi).*(cos(psi).* ...
  sin(phi)+(-1).*cos(phi).*sin(psi).*sin(theta))+(-1/4).*L.^2.*m.* ...
  cos(phi).*sin(psi).*sin(theta).*(cos(psi).*sin(phi)+(-1).*cos(phi) ...
  .*sin(psi).*sin(theta))+(1/4).*L.^2.*m.*cos(phi).*cos(psi).*(cos( ...
  phi).*cos(psi)+(-1).*sin(phi).*sin(psi).*sin(theta))+(-1/4).* ...
  L.^2.*m.*sin(phi).*sin(psi).*sin(theta).*(cos(phi).*cos(psi)+(-1) ...
  .*sin(phi).*sin(psi).*sin(theta)))+(-1/2).*m.*(2.*((-1/2).*dpsi.* ...
  L.*cos(theta).*sin(psi)+(-1/2).*dtheta.*L.*cos(psi).*sin(theta)).* ...
  ((-1/2).*dpsi.*L.*cos(psi).*cos(theta)+(1/2).*dtheta.*L.*sin(psi) ...
  .*sin(theta))+(1/2).*L.^2.*(dtheta.*cos(phi).*cos(psi).*cos(theta) ...
  +dpsi.*cos(psi).*sin(phi)+dphi.*cos(phi).*sin(psi)+(-1).*dphi.* ...
  cos(psi).*sin(phi).*sin(theta)+(-1).*dpsi.*cos(phi).*sin(psi).* ...
  sin(theta)).*(dphi.*cos(phi).*cos(psi)+(-1).*dtheta.*cos(phi).* ...
  cos(theta).*sin(psi)+(-1).*dpsi.*sin(phi).*sin(psi)+(-1).*dpsi.* ...
  cos(phi).*cos(psi).*sin(theta)+dphi.*sin(phi).*sin(psi).*sin( ...
  theta))+(1/2).*L.^2.*((-1).*dphi.*cos(psi).*sin(phi)+(-1).*dpsi.* ...
  cos(phi).*sin(psi)+(-1).*dtheta.*cos(theta).*sin(phi).*sin(psi)+( ...
  -1).*dpsi.*cos(psi).*sin(phi).*sin(theta)+(-1).*dphi.*cos(phi).* ...
  sin(psi).*sin(theta)).*(dpsi.*cos(phi).*cos(psi)+dtheta.*cos(psi) ...
  .*cos(theta).*sin(phi)+(-1).*dphi.*sin(phi).*sin(psi)+dphi.*cos( ...
  phi).*cos(psi).*sin(theta)+(-1).*dpsi.*sin(phi).*sin(psi).*sin( ...
  theta)))); 
%% f(1,5)
f(5,1) = tau(2) - ((1/2).*dphi.*dpsi.*L.^2.*m.*cos(phi).^2.*cos(psi).^2.*cos(theta)+( ...
  -1/2).*dphi.*dpsi.*L.^2.*m.*cos(psi).^2.*cos(theta).*sin(phi).^2+( ...
  -1/2).*dpsi.*dtheta.*L.^2.*m.*cos(phi).^2.*cos(psi).*cos(theta) ...
  .^2.*sin(psi)+(-1/2).*dphi.^2.*L.^2.*m.*cos(phi).*cos(psi).*cos( ...
  theta).*sin(phi).*sin(psi)+(-1/2).*dpsi.^2.*L.^2.*m.*cos(phi).* ...
  cos(psi).*cos(theta).*sin(phi).*sin(psi)+(-1/2).*dpsi.*dtheta.* ...
  L.^2.*m.*cos(psi).*cos(theta).^2.*sin(phi).^2.*sin(psi)+ddphi.*(( ...
  1/4).*L.^2.*m.*cos(phi).^2.*cos(psi).*cos(theta).*sin(psi)+(-1/4) ...
  .*L.^2.*m.*cos(psi).*cos(theta).*sin(phi).^2.*sin(psi))+(1/2).*g.* ...
  L.*m.*cos(psi).*sin(theta)+(1/4).*dpsi.^2.*L.^2.*m.*cos(psi).^2.* ...
  cos(theta).*sin(theta)+(1/4).*dtheta.^2.*L.^2.*m.*cos(psi).^2.* ...
  cos(theta).*sin(theta)+(-1/4).*dphi.^2.*L.^2.*m.*cos(phi).^2.*cos( ...
  psi).^2.*cos(theta).*sin(theta)+(-1/4).*dpsi.^2.*L.^2.*m.*cos(phi) ...
  .^2.*cos(psi).^2.*cos(theta).*sin(theta)+(-1/4).*dtheta.^2.*L.^2.* ...
  m.*cos(phi).^2.*cos(psi).^2.*cos(theta).*sin(theta)+(-1/4).* ...
  dphi.^2.*L.^2.*m.*cos(psi).^2.*cos(theta).*sin(phi).^2.*sin(theta) ...
  +(-1/4).*dpsi.^2.*L.^2.*m.*cos(psi).^2.*cos(theta).*sin(phi).^2.* ...
  sin(theta)+(-1/4).*dtheta.^2.*L.^2.*m.*cos(psi).^2.*cos(theta).* ...
  sin(phi).^2.*sin(theta)+(-1/2).*dpsi.*dtheta.*L.^2.*m.*cos(psi).* ...
  sin(psi).*sin(theta).^2+(-1/2).*dtheta.*L.*m.*cos(psi).*cos(theta) ...
  .*((-1/2).*dpsi.*L.*cos(theta).*sin(psi)+(-1/2).*dtheta.*L.*cos( ...
  psi).*sin(theta))+(1/2).*dpsi.*L.*m.*sin(psi).*sin(theta).*((-1/2) ...
  .*dpsi.*L.*cos(theta).*sin(psi)+(-1/2).*dtheta.*L.*cos(psi).*sin( ...
  theta))+(-1/4).*dphi.*L.^2.*m.*cos(psi).*cos(theta).*sin(phi).*( ...
  dtheta.*cos(phi).*cos(psi).*cos(theta)+dpsi.*cos(psi).*sin(phi)+ ...
  dphi.*cos(phi).*sin(psi)+(-1).*dphi.*cos(psi).*sin(phi).*sin( ...
  theta)+(-1).*dpsi.*cos(phi).*sin(psi).*sin(theta))+(-1/4).*dpsi.* ...
  L.^2.*m.*cos(phi).*cos(theta).*sin(psi).*(dtheta.*cos(phi).*cos( ...
  psi).*cos(theta)+dpsi.*cos(psi).*sin(phi)+dphi.*cos(phi).*sin(psi) ...
  +(-1).*dphi.*cos(psi).*sin(phi).*sin(theta)+(-1).*dpsi.*cos(phi).* ...
  sin(psi).*sin(theta))+(-1/4).*dtheta.*L.^2.*m.*cos(phi).*cos(psi) ...
  .*sin(theta).*(dtheta.*cos(phi).*cos(psi).*cos(theta)+dpsi.*cos( ...
  psi).*sin(phi)+dphi.*cos(phi).*sin(psi)+(-1).*dphi.*cos(psi).*sin( ...
  phi).*sin(theta)+(-1).*dpsi.*cos(phi).*sin(psi).*sin(theta))+(1/4) ...
  .*dphi.*L.^2.*m.*cos(phi).*cos(psi).*cos(theta).*(dpsi.*cos(phi).* ...
  cos(psi)+dtheta.*cos(psi).*cos(theta).*sin(phi)+(-1).*dphi.*sin( ...
  phi).*sin(psi)+dphi.*cos(phi).*cos(psi).*sin(theta)+(-1).*dpsi.* ...
  sin(phi).*sin(psi).*sin(theta))+(-1/4).*dpsi.*L.^2.*m.*cos(theta) ...
  .*sin(phi).*sin(psi).*(dpsi.*cos(phi).*cos(psi)+dtheta.*cos(psi).* ...
  cos(theta).*sin(phi)+(-1).*dphi.*sin(phi).*sin(psi)+dphi.*cos(phi) ...
  .*cos(psi).*sin(theta)+(-1).*dpsi.*sin(phi).*sin(psi).*sin(theta)) ...
  +(-1/4).*dtheta.*L.^2.*m.*cos(psi).*sin(phi).*sin(theta).*(dpsi.* ...
  cos(phi).*cos(psi)+dtheta.*cos(psi).*cos(theta).*sin(phi)+(-1).* ...
  dphi.*sin(phi).*sin(psi)+dphi.*cos(phi).*cos(psi).*sin(theta)+(-1) ...
  .*dpsi.*sin(phi).*sin(psi).*sin(theta))+ddpsi.*((1/2).*L.^2.*m.* ...
  cos(phi).*cos(psi).^2.*cos(theta).*sin(phi)+(1/4).*L.^2.*m.*cos( ...
  psi).*cos(theta).*sin(psi).*sin(theta)+(-1/4).*L.^2.*m.*cos(phi) ...
  .^2.*cos(psi).*cos(theta).*sin(psi).*sin(theta)+(-1/4).*L.^2.*m.* ...
  cos(psi).*cos(theta).*sin(phi).^2.*sin(psi).*sin(theta))+ddtheta.* ...
  (Itheta+(1/4).*L.^2.*m.*cos(phi).^2.*cos(psi).^2.*cos(theta).^2+( ...
  1/4).*L.^2.*m.*cos(psi).^2.*cos(theta).^2.*sin(phi).^2+(1/4).* ...
  L.^2.*m.*cos(psi).^2.*sin(theta).^2)+(-1/2).*m.*(2.*((-1/2).* ...
  dpsi.*L.*cos(theta).*sin(psi)+(-1/2).*dtheta.*L.*cos(psi).*sin( ...
  theta)).*((-1/2).*dtheta.*L.*cos(psi).*cos(theta)+(-1/2).*dpsi.* ...
  L.*sin(psi).*sin(theta))+(1/2).*L.^2.*((-1).*dphi.*cos(psi).*cos( ...
  theta).*sin(phi)+(-1).*dpsi.*cos(phi).*cos(theta).*sin(psi)+(-1).* ...
  dtheta.*cos(phi).*cos(psi).*sin(theta)).*(dtheta.*cos(phi).*cos( ...
  psi).*cos(theta)+dpsi.*cos(psi).*sin(phi)+dphi.*cos(phi).*sin(psi) ...
  +(-1).*dphi.*cos(psi).*sin(phi).*sin(theta)+(-1).*dpsi.*cos(phi).* ...
  sin(psi).*sin(theta))+(1/2).*L.^2.*(dphi.*cos(phi).*cos(psi).*cos( ...
  theta)+(-1).*dpsi.*cos(theta).*sin(phi).*sin(psi)+(-1).*dtheta.* ...
  cos(psi).*sin(phi).*sin(theta)).*(dpsi.*cos(phi).*cos(psi)+ ...
  dtheta.*cos(psi).*cos(theta).*sin(phi)+(-1).*dphi.*sin(phi).*sin( ...
  psi)+dphi.*cos(phi).*cos(psi).*sin(theta)+(-1).*dpsi.*sin(phi).* ...
  sin(psi).*sin(theta)))); 
%% f(1,6)
f(6,1) = tau(3) - ((1/2).*dphi.*dtheta.*L.^2.*m.*cos(phi).*cos(psi).*cos(theta).*(( ...
  -1).*sin(phi).*sin(psi)+cos(phi).*cos(psi).*sin(theta))+(-1/2).* ...
  dphi.*dpsi.*L.^2.*m.*cos(psi).*sin(phi).*((-1).*sin(phi).*sin(psi) ...
  +cos(phi).*cos(psi).*sin(theta))+(-1/4).*dphi.^2.*L.^2.*m.*cos( ...
  phi).*sin(psi).*((-1).*sin(phi).*sin(psi)+cos(phi).*cos(psi).*sin( ...
  theta))+(-1/4).*dpsi.^2.*L.^2.*m.*cos(phi).*sin(psi).*((-1).*sin( ...
  phi).*sin(psi)+cos(phi).*cos(psi).*sin(theta))+(-1/2).*dpsi.* ...
  dtheta.*L.^2.*m.*cos(theta).*sin(phi).*sin(psi).*((-1).*sin(phi).* ...
  sin(psi)+cos(phi).*cos(psi).*sin(theta))+(-1/4).*dphi.^2.*L.^2.* ...
  m.*cos(psi).*sin(phi).*sin(theta).*((-1).*sin(phi).*sin(psi)+cos( ...
  phi).*cos(psi).*sin(theta))+(-1/4).*dpsi.^2.*L.^2.*m.*cos(psi).* ...
  sin(phi).*sin(theta).*((-1).*sin(phi).*sin(psi)+cos(phi).*cos(psi) ...
  .*sin(theta))+(-1/4).*dtheta.^2.*L.^2.*m.*cos(psi).*sin(phi).*sin( ...
  theta).*((-1).*sin(phi).*sin(psi)+cos(phi).*cos(psi).*sin(theta))+ ...
  (-1/2).*dphi.*dpsi.*L.^2.*m.*cos(phi).*sin(psi).*sin(theta).*((-1) ...
  .*sin(phi).*sin(psi)+cos(phi).*cos(psi).*sin(theta))+(1/2).*dphi.* ...
  dpsi.*L.^2.*m.*cos(phi).*cos(psi).*(cos(phi).*sin(psi)+(-1).*cos( ...
  psi).*sin(phi).*sin(theta))+(-1/2).*dphi.*dtheta.*L.^2.*m.*cos( ...
  psi).*cos(theta).*sin(phi).*(cos(phi).*sin(psi)+(-1).*cos(psi).* ...
  sin(phi).*sin(theta))+(-1/2).*dpsi.*dtheta.*L.^2.*m.*cos(phi).* ...
  cos(theta).*sin(psi).*(cos(phi).*sin(psi)+(-1).*cos(psi).*sin(phi) ...
  .*sin(theta))+(-1/4).*dphi.^2.*L.^2.*m.*sin(phi).*sin(psi).*(cos( ...
  phi).*sin(psi)+(-1).*cos(psi).*sin(phi).*sin(theta))+(-1/4).* ...
  dpsi.^2.*L.^2.*m.*sin(phi).*sin(psi).*(cos(phi).*sin(psi)+(-1).* ...
  cos(psi).*sin(phi).*sin(theta))+(-1/4).*dphi.^2.*L.^2.*m.*cos(phi) ...
  .*cos(psi).*sin(theta).*(cos(phi).*sin(psi)+(-1).*cos(psi).*sin( ...
  phi).*sin(theta))+(-1/4).*dpsi.^2.*L.^2.*m.*cos(phi).*cos(psi).* ...
  sin(theta).*(cos(phi).*sin(psi)+(-1).*cos(psi).*sin(phi).*sin( ...
  theta))+(-1/4).*dtheta.^2.*L.^2.*m.*cos(phi).*cos(psi).*sin(theta) ...
  .*(cos(phi).*sin(psi)+(-1).*cos(psi).*sin(phi).*sin(theta))+(1/2) ...
  .*dphi.*dpsi.*L.^2.*m.*sin(phi).*sin(psi).*sin(theta).*(cos(phi).* ...
  sin(psi)+(-1).*cos(psi).*sin(phi).*sin(theta))+(1/4).*L.^2.*m.*( ...
  dtheta.*cos(phi).*cos(psi).*cos(theta)+(-1).*dpsi.*cos(psi).*sin( ...
  phi)+(-1).*dphi.*cos(phi).*sin(psi)+(-1).*dphi.*cos(psi).*sin(phi) ...
  .*sin(theta)+(-1).*dpsi.*cos(phi).*sin(psi).*sin(theta)).*(dpsi.* ...
  cos(phi).*cos(psi)+dtheta.*cos(psi).*cos(theta).*sin(phi)+(-1).* ...
  dphi.*sin(phi).*sin(psi)+dphi.*cos(phi).*cos(psi).*sin(theta)+(-1) ...
  .*dpsi.*sin(phi).*sin(psi).*sin(theta))+(1/4).*L.^2.*m.*(dtheta.* ...
  cos(phi).*cos(psi).*cos(theta)+dpsi.*cos(psi).*sin(phi)+dphi.*cos( ...
  phi).*sin(psi)+(-1).*dphi.*cos(psi).*sin(phi).*sin(theta)+(-1).* ...
  dpsi.*cos(phi).*sin(psi).*sin(theta)).*(dpsi.*cos(phi).*cos(psi)+( ...
  -1).*dtheta.*cos(psi).*cos(theta).*sin(phi)+(-1).*dphi.*sin(phi).* ...
  sin(psi)+(-1).*dphi.*cos(phi).*cos(psi).*sin(theta)+dpsi.*sin(phi) ...
  .*sin(psi).*sin(theta))+ddtheta.*((1/4).*L.^2.*m.*cos(psi).*cos( ...
  theta).*sin(phi).*((-1).*sin(phi).*sin(psi)+cos(phi).*cos(psi).* ...
  sin(theta))+(1/4).*L.^2.*m.*cos(phi).*cos(psi).*cos(theta).*(cos( ...
  phi).*sin(psi)+(-1).*cos(psi).*sin(phi).*sin(theta)))+ddphi.*( ...
  Iphi+(-1/4).*L.^2.*m.*sin(phi).*sin(psi).*((-1).*sin(phi).*sin( ...
  psi)+cos(phi).*cos(psi).*sin(theta))+(1/4).*L.^2.*m.*cos(phi).* ...
  cos(psi).*sin(theta).*((-1).*sin(phi).*sin(psi)+cos(phi).*cos(psi) ...
  .*sin(theta))+(1/4).*L.^2.*m.*cos(phi).*sin(psi).*(cos(phi).*sin( ...
  psi)+(-1).*cos(psi).*sin(phi).*sin(theta))+(-1/4).*L.^2.*m.*cos( ...
  psi).*sin(phi).*sin(theta).*(cos(phi).*sin(psi)+(-1).*cos(psi).* ...
  sin(phi).*sin(theta)))+ddpsi.*((1/4).*L.^2.*m.*cos(phi).*cos(psi) ...
  .*((-1).*sin(phi).*sin(psi)+cos(phi).*cos(psi).*sin(theta))+(-1/4) ...
  .*L.^2.*m.*sin(phi).*sin(psi).*sin(theta).*((-1).*sin(phi).*sin( ...
  psi)+cos(phi).*cos(psi).*sin(theta))+(1/4).*L.^2.*m.*cos(psi).* ...
  sin(phi).*(cos(phi).*sin(psi)+(-1).*cos(psi).*sin(phi).*sin(theta) ...
  )+(-1/4).*L.^2.*m.*cos(phi).*sin(psi).*sin(theta).*(cos(phi).*sin( ...
  psi)+(-1).*cos(psi).*sin(phi).*sin(theta)))+(-1/2).*m.*((1/2).* ...
  L.^2.*(dtheta.*cos(phi).*cos(psi).*cos(theta)+(-1).*dpsi.*cos(psi) ...
  .*sin(phi)+(-1).*dphi.*cos(phi).*sin(psi)+(-1).*dphi.*cos(psi).* ...
  sin(phi).*sin(theta)+(-1).*dpsi.*cos(phi).*sin(psi).*sin(theta)).* ...
  (dpsi.*cos(phi).*cos(psi)+dtheta.*cos(psi).*cos(theta).*sin(phi)+( ...
  -1).*dphi.*sin(phi).*sin(psi)+dphi.*cos(phi).*cos(psi).*sin(theta) ...
  +(-1).*dpsi.*sin(phi).*sin(psi).*sin(theta))+(1/2).*L.^2.*( ...
  dtheta.*cos(phi).*cos(psi).*cos(theta)+dpsi.*cos(psi).*sin(phi)+ ...
  dphi.*cos(phi).*sin(psi)+(-1).*dphi.*cos(psi).*sin(phi).*sin( ...
  theta)+(-1).*dpsi.*cos(phi).*sin(psi).*sin(theta)).*(dpsi.*cos( ...
  phi).*cos(psi)+(-1).*dtheta.*cos(psi).*cos(theta).*sin(phi)+(-1).* ...
  dphi.*sin(phi).*sin(psi)+(-1).*dphi.*cos(phi).*cos(psi).*sin( ...
  theta)+dpsi.*sin(phi).*sin(psi).*sin(theta)))); 

%% Gradients not needed for ode15i
dfdx = 0;   % not needed for ode15i
dfdxdot = 0; % not needed for ode15i
dfdu = 0; % not needed for ode15i

end