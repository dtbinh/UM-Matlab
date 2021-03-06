% elastomerSysID.m    
% Uses polynomial fits of P vs L and P vs theta to determine the spring
% constant functions of the system.
%
% NOTE: Must run setParams.m before using this script

%% Generate elastomer force/torques (Fs and Ms) at each pressure

% Generates r at each pressure in P from linear equation fit
% r = dr + r_rest*ones(size(P)); 
r = params.rcoeff(2)*P + params.rcoeff(1)*ones(size(P));

% Generates L at each pressure in P
L = dL + L_rest*ones(size(dL));

% Generates theta at each pressure in P
theta = dphi + params.theta_rest*ones(size(dphi));

% Generates phi at each pressure in P
phi = dphi + 0;

% Generates gama at each pressure in P
gama = atan(r.*(-theta)./L);

% Normalized displacements (divided by L0)
dL_norm = dL/L_rest;
dphi_norm = atan((dphi.*r)/L_rest);

% Generates T, E, and G at each time step
E = zeros(size(P));
G = zeros(size(P));
for k = 1:length(P)
    
    x = [P(k), gama(k), r(k), L(k), phi(k), 0];     % tension is unknown so last value is zero (it doesn't matter, could put anything there)
    [E(k), G(k)] = elastomerModulus(x, params);
    
end
    

%% Fits a polynomial to each spring FORCE/MOMENT as a functions of P and phi normalized
% reg_E = MultiPolyRegress(dL_norm',E',1);
% reg_G = MultiPolyRegress(dphi_norm',G',1);

E_poly = polyfit(dL_norm',E',1);
G_poly = polyfit(dphi_norm',G',1);

%% Generate Plots of interest
figure

% F_elast vs. P
subplot(2,2,1)
set(gca,'fontsize', 32);
%axis([5, 12*6, -100, 150]);
xlabel('$P$ (psi)', 'fontsize', 32, 'Interpreter', 'LaTex');
ylabel('$E$ (psi)', 'fontsize', 32, 'Interpreter', 'LaTex');
hold on
plot(P,E,'*')
hold off

% M_elast vs. P
subplot(2,2,2)
set(gca,'fontsize', 32);
%axis([5, 12*6, -100, 150]);
xlabel('$P$ (psi)', 'fontsize', 32, 'Interpreter', 'LaTex');
ylabel('$G$ (psi)', 'fontsize', 32, 'Interpreter', 'LaTex');
hold on
plot(P,G,'*')
hold off

% F_elast vs. (L-L0/L0)
subplot(2,2,3)
set(gca,'fontsize', 32);
xlabel('$\frac{l-L}{L}$ (\%)', 'fontsize', 32, 'Interpreter', 'LaTex');
ylabel('$E$ (psi)', 'fontsize', 32, 'Interpreter', 'LaTex');
hold on
plot(dL_norm,E,'*')
plot(linspace(0,0.05,100), polyval(E_poly, linspace(0,0.05,100)))
hold off


% M_elast vs. (phi/L0)
subplot(2,2,4)
set(gca,'fontsize', 32);
xlabel('$\frac{\Phi r}{L}$ (rad)', 'fontsize', 32, 'Interpreter', 'LaTex');
ylabel('$G$ (psi)', 'fontsize', 32, 'Interpreter', 'LaTex');
hold on
plot(dphi_norm,G,'*')
plot(linspace(0,0.2,100), polyval(G_poly, linspace(0,0.2,100)))
hold off
