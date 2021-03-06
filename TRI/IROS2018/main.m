% main.m
clear

%% Set parameter values
% Set the values of system parameters
Gama = deg2rad([48, -48, -85]);
R = (10e-3)/2 * ones(1,3); % R = 0.009525/2 * ones(1,3);
L = 0.10 * ones(1,3);
d = zeros(3,3);
p = [0,0,0 ; 0,0,0 ; 1,1,1];
Pmax = (1/0.14503) * 1e3 * [15 15 15];   % Pa = 15psi
params = setParams(Gama, R, L, d, p, Pmax);

% Set the value of test parameters
testParams = struct;
testParams.Psteps = 4;     % how finely to break up Pmax
testParams.stest = [0, 5, 0, 5];   % mm
testParams.wtest = [0, 0, 20, 20];    % deg
testParams.TRmax = (1/0.14503) * 1e3 * 15;   % Pa = 15psi

testParams.servoOffset = 35;    % deg
% testParams.linOffset = 3.5427; % V (for tests 4 and 5)
testParams.linOffset = 3.70979; % V (for test 6 and 7)

% % Much smaller set of points for debugging
% testParams.Psteps = 1;     % how finely to break up Pmax
% testParams.stest = [0, 5];   % mm
% testParams.wtest = [0, 20];    % deg
% testParams.TRmax = 103.421e3;   % Pa = 15psi

%% Create csv of the test data points
testPoints = setTestPoints(testParams, params);
% Need to convert these to voltages before writing to csv or tsv
testPoints_out = testPoints * diag([0.033418, 1, 10/testParams.TRmax, 10/testParams.TRmax, 10/testParams.TRmax]);
csvwrite('testPoints.csv',testPoints_out);      % exports testPoint to csv file
dlmwrite('testPoints.txt',testPoints_out, 'delimiter', '\t', 'newline', 'pc');

%% Calculate Error between test data and measured data
% [FM1, FM2, FM3, FM4, FM1pred, FM2pred, FM3pred, FM4pred, RMSE, maxERR, percERR] = treatData('testData/testData_3.mat', testPoints, testPoints_out, params, testParams);
[FM1, FM2, FM3, FM4, FM1pred, FM2pred, FM3pred, FM4pred, RMSE, maxERR, percERR] = treatData_v2('testData/testData_9.mat', testParams, params);  % for test4 and above

%% Calculate the force zonotope for each test configuration
for i = 1:length(testParams.stest)
    s = testParams.stest(i);
    w = testParams.wtest(i);
    x = [0, 0, s*10^(-3), 0, 0, deg2rad(w)]';  % end effector state
    [zntp(:,i), vx(:,i), vy(:,i)] = zonotopeFun(x, params);

    % Plot measured points on top of zonotope
    if i == 1
        FM = FM1;
        FMpred = FM1pred;
    elseif i == 2
        FM = FM2;
        FMpred = FM2pred;
    elseif i == 3
        FM = FM3;
        FMpred = FM3pred;
    elseif i == 4
        FM = FM4;
        FMpred = FM4pred;
    end
    % generate cvx hull of measured points
    cvxh = convhull(FM(:,1),FM(:,2));
    % plot
    hold on
    
   mod = plot(FMpred(:, 1), FMpred(:, 2), 'k^', 'markers', 6);
   meas = plot(FM(:,1), FM(:,2), 'k.', 'markers', 13);
   plot(FM(cvxh,1), FM(cvxh,2), 'k-', 'LineWidth', 2);
   for j = 1:length(FM)
       plot([FM(j,1), FMpred(j,1)], [FM(j,2), FMpred(j,2)], 'k')
   end
   legend([mod, meas], {'Predicted', 'Measured'})

    ax = gca;
    ax.XTick = [-12, -6, 0, 6, 12];
    ax.YTick = [-0.08, -0.04, 0, 0.04, 0.08];
%    ax.YTickLabel = []; %     set(gca,'YTickLabel',[])
    hold off
end


% Plot all of the force zonotopes using subplots
% ...


% Plot all the points on one plot (for debugging data alignment)
FM = [FM1; FM2; FM3; FM4];
FMpred = [FM1pred; FM2pred; FM3pred; FM4pred];
figure
hold on
% mod = plot(FMpred(:, 1), FMpred(:, 2), 'k^', 'markers', 6);
meas = plot(FM(:,1), FM(:,2), 'k.', 'markers', 13);
% plot(FM(cvxh,1), FM(cvxh,2), 'k-', 'LineWidth', 2);
% for j = 1:length(FM)
%     plot([FM(j,1), FMpred(j,1)], [FM(j,2), FMpred(j,2)], 'k')
% end
hold off


%% Create awesome plot of all the zonotopes based on configuration

xp = (-10:5:10) * 1e-3;
yp = -deg2rad(40):deg2rad(20):deg2rad(40);
[Xp, Yp] = meshgrid(xp,yp);
sp = Xp(:)';
wp = Yp(:)';
qp = [sp;wp];

% Creat plot
scale = [0.00018, 2];
zntp_qplot(qp, scale, params);

% plot zonotopes of measured points on top
mzntp1 = convhull(FM1(:,1),FM1(:,2));
mzntp2 = convhull(FM2(:,1),FM2(:,2));
mzntp3 = convhull(FM3(:,1),FM3(:,2));
mzntp4 = convhull(FM4(:,1),FM4(:,2));

hold on
plot((FM1(mzntp1,1)*scale(1) + 0)*1e3, rad2deg(FM1(mzntp1,2)*scale(2) + 0), 'k-', 'LineWidth', 1.5);
plot((FM2(mzntp2,1)*scale(1) + 0.005)*1e3, rad2deg(FM2(mzntp2,2)*scale(2) + 0), 'k-', 'LineWidth', 1.5);
plot((FM3(mzntp3,1)*scale(1) + 0)*1e3, rad2deg(FM3(mzntp3,2)*scale(2)) + 20, 'k-', 'LineWidth', 1.5);
plot((FM4(mzntp4,1)*scale(1) + 0.005)*1e3, rad2deg(FM4(mzntp4,2)*scale(2)) + 20, 'k-', 'LineWidth', 1.5);
hold off



