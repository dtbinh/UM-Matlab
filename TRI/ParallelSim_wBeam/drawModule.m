function drawModule( xeul, params, t, u )
%Visualizes the end effector position in 3D. This does not create a figure
%so is useful for animations that must iterative call a plot function.
%   Detailed explanation goes here

if nargin == 2
    t = 69;
    u = 69*ones(params.m,1);
end

L = params.Lspine;

% attached points for each FREE
[a1, a2, a3, a4] = deal(params.xattach(1), params.xattach(2), params.xattach(3), params.xattach(4));
[b1, b2, b3, b4] = deal(params.yattach(1), params.yattach(2), params.yattach(3), params.yattach(4));

xcart = euler2cart(xeul, params);
R = R10(xeul);

% Get the coordinates of the vertices of the end effector
vertEff = verticesEff(xeul, xcart, params);

% Define the coordinates of the vertices of the top block
width = params.width/1.25;
vertTop = [[width; width; -L], [width; -width; -L], [-width; -width; -L], [-width; width; -L]];
    
% Define the central spine
res = 100;
dl = L/res;
m = (R(:,3) - [0, 0, 1]') * (1/L);
b = [0; 0; 1];
spine(:,1) = [0; 0; -L];
free1(:,1) = spine(:,1) + [a1; b1; 0];
free2(:,1) = spine(:,1) + [a2; b2; 0];
free3(:,1) = spine(:,1) + [a3; b3; 0];
free4(:,1) = spine(:,1) + [a4; b4; 0];
for i = 2:res
    l = i*dl;
    nspine = m*l + b;   % directinal vector of the spine
    spine(:,i) = spine(:,i-1) + nspine * dl;
    
    deul = (l/L) * xeul;
    dR = R10(deul);
    
    free1(:,i) = dR*[a1; b1; 0] + spine(:,i);
    free2(:,i) = dR*[a2; b2; 0] + spine(:,i);
    free3(:,i) = dR*[a3; b3; 0] + spine(:,i);
    free4(:,i) = dR*[a4; b4; 0] + spine(:,i);
    
%     % attempt to draw FREE around the outside of central spine (works okay but the way done above is much better)
%     helix1 = [sqrt(a4^2 + b4^2) * cos(xeul(3) * l/L + pi/4);...
%             sqrt(a4^2 + b4^2) * sin(xeul(3) * l/L + pi/4);...
%             0];
%     helix2 = [sqrt(a4^2 + b4^2) * cos(xeul(3) * l/L + 3*pi/4);...
%             sqrt(a4^2 + b4^2) * sin(xeul(3) * l/L + 3*pi/4);...
%             0];
%     helix3 = [sqrt(a4^2 + b4^2) * cos(xeul(3) * l/L - 3*pi/4);...
%             sqrt(a4^2 + b4^2) * sin(xeul(3) * l/L - 3*pi/4);...
%             0];
%     helix4 = [sqrt(a4^2 + b4^2) * cos(xeul(3) * l/L - pi/4);...
%             sqrt(a4^2 + b4^2) * sin(xeul(3) * l/L - pi/4);...
%             0];
%         
%     free1(:,i) = spine(:,i) + helix1;
%     free2(:,i) = spine(:,i) + helix2;
%     free3(:,i) = spine(:,i) + helix3;
%     free4(:,i) = spine(:,i) + helix4;
end


% Convert pressures to KPa for display purposes
% Pkpa = [u(1); u(2); u(3); u(4)] / (2e6) * 120;  % conversion for poster
Pkpa = [u(1); u(2); u(3); u(4)] * 10^(-3);  % correct conversion

% Create the plot
color = [189 215 231]./256;

% The title is two lines to increase space between subplots
title(['';'$t = $' num2str(t,'%.2f') ':  $P_1 = $' num2str(Pkpa(1),'%.0f') ', $P_2 = $' num2str(Pkpa(2),'%.0f') ', $P_3 = $' num2str(Pkpa(3),'%.0f') ', $P_4 = $' num2str(Pkpa(4),'%.0f') ' (kPa)'], 'Interpreter', 'LaTex')
% title(['$t = $' num2str(t,'%.2f') ':  $P_1 = $' num2str(Pkpa(1),'%.0f') ', $P_2 = $' num2str(Pkpa(2),'%.0f') ', $P_3 = $' num2str(Pkpa(3),'%.0f') ', $P_4 = $' num2str(Pkpa(4),'%.0f') ' (kPa)'], 'Interpreter', 'LaTex')
% title(['$t = $' num2str(t,'%.2f')], 'Interpreter', 'LaTex')
hold on
patch(vertEff(1,1:4), vertEff(2,1:4), vertEff(3,1:4), color)
patch(vertEff(1,5:8), vertEff(2,5:8), vertEff(3,5:8), color)
patch([vertEff(1,1:2), vertEff(1,6), vertEff(1,5)], [vertEff(2,1:2), vertEff(2,6), vertEff(2,5)], [vertEff(3,1:2), vertEff(3,6), vertEff(3,5)], 'r')
patch([vertEff(1,2:3), vertEff(1,7), vertEff(1,6)], [vertEff(2,2:3), vertEff(2,7), vertEff(2,6)], [vertEff(3,2:3), vertEff(3,7), vertEff(3,6)], 'b')
patch([vertEff(1,3:4), vertEff(1,8), vertEff(1,7)], [vertEff(2,3:4), vertEff(2,8), vertEff(2,7)], [vertEff(3,3:4), vertEff(3,8), vertEff(3,7)], 'g')
patch([vertEff(1,1), vertEff(1,4), vertEff(1,8), vertEff(1,5)], [vertEff(2,1), vertEff(2,4), vertEff(2,8), vertEff(2,5)], [vertEff(3,1), vertEff(3,4), vertEff(3,8), vertEff(3,5)], 'm')
patch(vertTop(1,:), vertTop(2,:), vertTop(3,:), color)
plot3(spine(1,:), spine(2,:), spine(3,:), 'LineWidth',5)
plot3(free1(1,:), free1(2,:), free1(3,:), 'LineWidth',2)
plot3(free2(1,:), free2(2,:), free2(3,:), 'LineWidth',2)
plot3(free3(1,:), free3(2,:), free3(3,:), 'LineWidth',2)
plot3(free4(1,:), free4(2,:), free4(3,:), 'LineWidth',2)
hold off
set(gca,'zdir','reverse')
% view(3)
view(-35,-10)
xlabel('x (m)')
ylabel('y (m)')
zlabel('z (m)')
axis equal
xlim([-L, L]*0.6)
ylim([-L, L]*0.6)
zlim([-L, 5e-2])
box on


end
