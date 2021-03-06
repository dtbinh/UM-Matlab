function [p, tol] = calcROM( zrange, phirange, res, params )
%calcROM - Calculates the Range of Motion of a module
%   Detailed explanation goes here

% test the calcPressure function. Outputs a plot of the exit flags over a
% range of x values for that you can see where the system is infeasable and
% such. This is written to by used with the 6 DOF module

x = -0.05:0.005:0.05;
y = -0.05:0.005:0.05;
z = linspace(zrange(1), zrange(2), res); 
phi = linspace(phirange(1), phirange(2), res);
theta = -(pi):0.5:(pi);
psi = -(pi):0.5:(pi);

% only use 2 at a time for visualization purposes
in1 = z;
in2 = phi;

testPoints = combvec(in1,in2);

% exitflag = zeros(1, length(testPoints));
% for i = 1:length(testPoints)
%    dli = testPoints(1,i);
%    dphii = testPoints(2,i);
%    [~, exitflag(i)] = calcPressure([0,0,dli,0,0,dphii]', params); 
% end
% [X,Y] = meshgrid(testPoints(1,:), testPoints(2,:));

[X,Y] = meshgrid(in1, in2);

Z = zeros(size(X));
for i = 1:length(X(:,1))
    for j = 1:length(X(1,:))
        in1i = X(i,j);
        in2i = Y(i,j);
%         [sol, exitflag] = calcPressure([0, 0, in1i, in2i, params.x5_offset, params.x6_offset]', params);
        [sol, exitflag] = calcPressure([0, 0, in1i, in2i, 0, 0]', params);
        if exitflag > 0
            Z(i,j) = 1; % feasable
            p(i,j,:) = sol(1:3);
            tol(i,j) = sol(4);
        else
            Z(i,j) = 0; % infeasable
            p(i,j,:) = NaN(params.num, 1);
            tol(i,j) = NaN;
        end
    end
end

% convert pressure to psi for easier comprehension
p = p * 0.000145038;

%% plot it

% define my custom 2 color colormap, white and gray
mymap = [1 1 1;
        0.75 0.75 0.75];

figure
h = pcolor(X,Y,Z);
colormap(mymap);
set(h, 'EdgeColor', 'none');
title(['\Gamma: ', num2str(rad2deg(params.Gama(1))), ', ', num2str(rad2deg(params.Gama(2))), ', ', num2str(rad2deg(params.Gama(3)))])
colorbar('Ticks', [0, 1], 'TickLabels', {'infeasable', 'feasable'})
xlabel('\Delta l (m)')
ylabel('\Delta \phi (rad)')

end

