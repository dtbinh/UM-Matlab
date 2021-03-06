% test the calcPressure function. Outputs a plot of the exit flags over a
% range of x values for that you can see where the system is infeasable and
% such. This is written to by used with the 6 DOF module
clear;

params = setParams;

x = -0.05:0.005:0.05;
y = -0.05:0.005:0.05;
z = -0.05:0.003:0.05;
phi = -(4*pi):0.3:(4*pi);
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
        [~, exitflag] = calcPressure([0,0,in1i,in2i,0,0]', params);
        if exitflag > 0
            Z(i,j) = 1; % feasable
        else
            Z(i,j) = 0; % infeasable
        end
    end
end

%% plot it
figure
pcolor(X,Y,Z);
title(['\Gamma: ', num2str(rad2deg(params.Gama(1))), ', ', num2str(rad2deg(params.Gama(2))), ', ', num2str(rad2deg(params.Gama(3)))])
colorbar('Ticks', [0, 1], 'TickLabels', {'infeasable', 'feasable'})
xlabel('\Delta l (m)')
ylabel('\Delta \phi (rad)')