function vf_visualization( csv_linear, csv_constitutive, res, scale, xrange, yrange )
%vf_visualization
%   Reads in csv files (vf1, vf2, ...) that describe vector fields then
%   plots them both in the same figure

if nargin == 2
    res = 11;   % number of vector points in the final plot
    xrange = [-0.25,0.25];    % [xmin, xmax]
    yrange = [-1,1]; % [ymin, ymax]
    scale = [1e-3, 1e0];    % [fscale, mscale]
elseif nargin == 3
    xrange = [-0.25,0.25];    % [xmin, xmax]
    yrange = [-1,1]; % [ymin, ymax] 
    scale = [1e-3, 1e0];    % [fscale, mscale]
elseif nargin == 4
    xrange = [-0.25,0.25];    % [xmin, xmax]
    yrange = [-1,1]; % [ymin, ymax] 
end

% Read in the csvfiles
linModel = csvread(csv_linear);
constModel = csvread(csv_constitutive);

% Make sure both sets of data are for same FREE and at same pressures
if linModel(1,:) ~= constModel(1,:)
    disp('Error: You are attempting to compare vector fields for FREEs with different parameters.');
    return;
end

% extract FREE parameters
[Gama, L, R, P] = deal(linModel(1,1), linModel(1,2), linModel(1,3), linModel(1,4:end));

% extract vector quantities from csv data
vf1 = linModel(2:end,:);
vf2 = constModel(2:end,:);

% separate data into different matrices for each pressure
for i = 1:length(P)
    index1 = ( vf1(:,5) == P(i) );
    vf1_3d(:,:,i) = vf1(index1,:);
    
    index2 = ( vf2(:,5) == P(i) );
    vf2_3d(:,:,i) = vf2(index2,:);
end

% separate into vectors for each quantity type (i.e. extention, twist, force, etc.)
[x1, y1, u1, v1] = deal( vf1_3d(:,1,:), vf1_3d(:,2,:), vf1_3d(:,3,:), vf1_3d(:,4,:) );
[x2, y2, u2, v2] = deal( vf2_3d(:,1,:), vf2_3d(:,2,:), vf2_3d(:,3,:), vf2_3d(:,4,:) );
[p1, vol1] = deal( vf1_3d(:,5,:), vf1_3d(:,6,:) );
[p2, vol2] = deal( vf2_3d(:,5,:), vf2_3d(:,6,:) );

% Change units of s and w such that s: % of L, w: rotations
s1 = x1 * (1/L);
s2 = x2 * (1/L);
w1 = y1 * (1/(2*pi));
w2 = y2 * (1/(2*pi));

% Scale F and M for better plotting
fscale = scale(1); % changes apparent width of arrows
mscale = scale(2); % changes apparent height of arrows
f1 = u1 * fscale;
f2 = u2 * fscale;
m1 = v1 * mscale;
m2 = v2 * mscale;


% Define the points on the vector field to be plotted
X = linspace(xrange(1), xrange(2), res);
Y = linspace(yrange(1), yrange(2), res);
[S,W] = meshgrid(X,Y);

% interpolate to find force vectors at the points to be plotted
for k = 1:length(P)
    F1(:,:,k) = griddata(s1(:,:,k), w1(:,:,k), f1(:,:,k), S,W);
    M1(:,:,k) = griddata(s1(:,:,k), w1(:,:,k), m1(:,:,k), S,W);
    
    F2(:,:,k) = griddata(s2(:,:,k), w2(:,:,k), f2(:,:,k), S,W);
    M2(:,:,k) = griddata(s2(:,:,k), w2(:,:,k), m2(:,:,k), S,W);
end

% create figure
vfplot = figure;
set(vfplot, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
title(['$\Gamma =$ ' num2str(Gama) ' (deg), $L =$ ' num2str(L*1e2) ' (cm), $R = $' num2str(R*1e2) ' (cm)'],'Interpreter','Latex', 'FontSize',25)
% xlabel({'$s$ ($\%$ of L)' ; '$F$ ($3 \times 10^{-4}$ N)'},'Interpreter','Latex', 'FontSize',25)
% ylabel({'$w$ (rev)' ; '$M$ ($5 \times 10^{-1}$ Nm)'},'Interpreter','Latex', 'FontSize',25)
xlabel({['$s$ ($\%$ of L)'] ; ['$F$ (' num2str(fscale) ' N)']},'Interpreter','Latex', 'FontSize',25)
ylabel({['$w$ (rev)'] ; ['$M$ (' num2str(mscale) ' Nm)']},'Interpreter','Latex', 'FontSize',25)
axis([xrange(1) xrange(2) yrange(1) yrange(2)]);
line(xrange, [0,0]);    % draw x-axis
line([0,0], yrange);    % draw y-axis
grid on;
hold on
for i = 1:length(P)
    quiv1(i) = quiver(S,W, F1(:,:,i), M1(:,:,i), 'Color', 'red', 'Linewidth', 1, 'MaxHeadSize', 5e-2, 'AutoScale', 'off', 'ShowArrowHead', 'off', 'Marker', '.');
    quiv2(i) = quiver(S,W, F2(:,:,i), M2(:,:,i), 'Color', 'blue', 'Linewidth', 1, 'MaxHeadSize', 5e-2, 'AutoScale', 'off', 'ShowArrowHead', 'off', 'Marker', '.');
end
hold off


%% Add arrowheads that look good (need the arrow3 function to work)

hold on

for i = 1:length(P)
    U1 = reshape(quiv1(i).UData, [numel(quiv1(i).UData),1]);
    V1 = reshape(quiv1(i).VData, [numel(quiv1(i).VData),1]);
    U2 = reshape(quiv2(i).UData, [numel(quiv2(i).UData),1]);
    V2 = reshape(quiv2(i).VData, [numel(quiv2(i).VData),1]);
    X = reshape(quiv1(i).XData, [numel(quiv1(i).XData),1]);
    Y = reshape(quiv1(i).YData, [numel(quiv1(i).YData),1]);
    
    arrow3( [X,Y], [X+U1,Y+V1] , '^r', 0.5, 0.5, [], 1, i*0.15);
    arrow3( [X,Y], [X+U2,Y+V2] , '^b', 0.5, 0.5, [], 1, i*0.15);
end

hold off

%% Add annotation box to describe arrows

xBox = 0.665;
yBox = 0.35;
hBox = 0.025;
wBox = 0.025;

for i = 1:length(P)
    annotation('rectangle', [xBox, yBox + (i-1)*0.025, 0.025, 0.025], 'FaceColor', [1 0.2*(i-1) 0.2*(i-1)]);
    annotation('rectangle', [xBox+0.025, yBox + (i-1)*0.025, 0.025, 0.025], 'FaceColor', [0.2*(i-1) 0.2*(i-1) 1]);
end

% Label the color boxes with corresponding pressures
for i = 1:length(P)
    dim = [xBox+2*wBox, yBox + (i-1)*hBox, 0.1, hBox];
    str = {num2str(P(i)) 'kPa'};
    str = strjoin(str);
    annotation('textbox',dim,'String',str,'FitBoxToText','off', 'FontSize', 18);
end
% annotation('rectangle',[.665 .25 .2 .2])

legend([quiv1(1), quiv2(1)], {'Linear Model', 'Constitutive Model'}, 'Fontsize', 24, 'Location', 'eastoutside');

end

