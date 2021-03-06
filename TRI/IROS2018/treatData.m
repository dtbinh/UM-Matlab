function [FM1, FM2, FM3, FM4, FM1pred, FM2pred, FM3pred, FM4pred, RMSE, maxERR, percERR] = treatData(MatDataFile, testPoints2, testPoints_out, params, testParams)
% treatData: Reads in measured data, removes elastomer offsets, splits into
% separate arrays for each configuration. Also measures error
% MatDataFile is a string which is the name of the .mat file containing the
% test data

% Load in test data and input points
load(MatDataFile);
FMraw = SyncFT.data;
RESraw = SycRes.data;
RESraw = [RESraw(2:end, :); zeros(size(RESraw(1,:)))]; % offset by one row EXPERIMENTAL

%% Remove problematic points
% remove bad transition points (where linear actuator or servo weren't set)
i = 1;
while i <= length(RESraw)
    if (RESraw(i,7) == 125 || RESraw(i,7) == 145) && abs((RESraw(i,8)-4.077)*(1/0.033418) - 2.5) > 2
        i = i+1;
    else
        RESraw(i,:) = [];
        FMraw(i,:) = [];
    end
end

% remove bad pressure transition points (where commanded pressure is not same as actual pressure)
j = 2;
while j <= length(RESraw)
    Pj = RESraw(j,1:3);
    Pjm1 = RESraw(j-1,1:3);  
    if (Pjm1(1)>8 && Pj(1)<8) || (Pjm1(2)>9 && Pj(2)<9) || (Pjm1(3)>9 && Pj(3)<9)
        RESraw(j,:) = [];
        FMraw(j,:) = [];
        j = j+1;
    else
        j = j+1;
    end
end

% Remove last 13 data points because we know they are messed up
RESraw(end-13:end,:) = [];
FMraw(end-13:end,:) = [];

%% Simulate at the same points as those measured

% % Read in the actual points tested and convert to format that can be simulated (using Pin signal values)
% testPoints_V = [RESraw(:,8), RESraw(:,7), RESraw(:,3), RESraw(:,2), RESraw(:,1)];   % actual tested points in units: [s(V), w(deg), P1(V), P2(V), P3(V)]
% testPoints = [(testPoints_V(:,1)-4.077)*(1/0.033418), testPoints_V(:,2)-125, testPoints_V(:,3:5) * (testParams.TRmax/10)];   % convert it to units: [mm, deg, Pa, Pa, Pa]

% Read in the actual points tested and convert to format that can be simulated (using Pmonitor signal values)
testPoints_V = [RESraw(:,8), RESraw(:,7), RESraw(:,4), RESraw(:,6), RESraw(:,5)];   % actual tested points in units: [s(V), w(deg), P1(V), P2(V), P3(V)]
testPoints = [(testPoints_V(:,1)-4.077)*(1/0.033418), testPoints_V(:,2)-125, testPoints_V(:,3:5) * (999740/10)];   % convert it to units: [mm, deg, Pa, Pa, Pa]

% Calculate the predicted forces at each point in testPoints
FMpred = calcModelFM(testPoints, params);
% FMpred = [FMpred(2:end, :); zeros(1,2)]; % offset by one row EXPERIMENTAL


%% Separate points into separate configurations

% automatically (possibly flawed)
cfg1 = zeros(size(testPoints(1,:)));    % seed with row of zeros
cfg2 = zeros(size(testPoints(1,:)));    % seed with row of zeros
cfg3 = zeros(size(testPoints(1,:)));    % seed with row of zeros
cfg4 = zeros(size(testPoints(1,:)));    % seed with row of zeros
FM1raw = zeros(1,2); FM2raw = zeros(1,2); FM3raw = zeros(1,2); FM4raw = zeros(1,2);
FM1pred = zeros(1,2); FM2pred = zeros(1,2); FM3pred = zeros(1,2); FM4pred = zeros(1,2);
for j = 1:length(testPoints)
    if abs(testPoints(j,1:2) - [0, 0]) < [0.5, 2]
        cfg1 = [cfg1; testPoints(j,:)];
        FM1raw = [FM1raw; FMraw(j,:)];
        FM1pred = [FM1pred; FMpred(j,:)]; 
    elseif abs(testPoints(j,1:2) - [5, 0]) < [0.5, 2]
        cfg2 = [cfg2; testPoints(j,:)];
        FM2raw = [FM2raw; FMraw(j,:)];
        FM2pred = [FM2pred; FMpred(j,:)]; 
    elseif abs(testPoints(j,1:2) - [0, 20]) < [0.5, 2]
        cfg3 = [cfg3; testPoints(j,:)];
        FM3raw = [FM3raw; FMraw(j,:)];
        FM3pred = [FM3pred; FMpred(j,:)]; 
    elseif abs(testPoints(j,1:2) - [5, 20]) < [0.5, 2]
        cfg4 = [cfg4; testPoints(j,:)];
        FM4raw = [FM4raw; FMraw(j,:)];
        FM4pred = [FM4pred; FMpred(j,:)]; 
    else
        disp('ERROR something wasnt classified!')
        disp(testPoints(j,:))
    end    
end
cfg1 = cfg1(2:end, :);    % remove row 1 seed of zeros
cfg2 = cfg2(2:end, :);    % remove row 1 seed of zeros
cfg3 = cfg3(2:end, :);    % remove row 1 seed of zeros
cfg4 = cfg4(2:end, :);    % remove row 1 seed of zeros
FM1raw = FM1raw(2:end, :); FM2raw = FM2raw(2:end, :); FM3raw = FM3raw(2:end, :); FM4raw = FM4raw(2:end, :);
FM1pred = FM1pred(2:end, :); FM2pred = FM2pred(2:end, :); FM3pred = FM3pred(2:end, :); FM4pred = FM4pred(2:end, :);


% % manually (only valid when not removing bad pressure points)
% cfg1 = 1:128;
% cfg2 = 129:255;
% cfg3 = 256:382;
% cfg4 = 383:length(testPoints);
% 
% FM1raw = FMraw(cfg1,:);
% FM2raw = FMraw(cfg2, :);
% FM3raw = FMraw(cfg3, :);
% FM4raw = FMraw(cfg4, :);
% 
% FM1pred = FMpred(cfg1, :); 
% FM2pred = FMpred(cfg2, :); 
% FM3pred = FMpred(cfg3, :); 
% FM4pred = FMpred(cfg4, :); 


%% Remove offset manually, using averages of measured offset
FM1 = -1 * ( FM1raw - [0, -0.005] - FMraw(1,:) );
FM2 = -1 * ( FM2raw - [15.9, -0.018] - FMraw(1,:) );
FM3 = -1 * ( FM3raw - [-1.1, -0.021] - FMraw(1,:) );
FM4 = -1 * ( FM4raw - [16.2, -0.041] - FMraw(1,:) );
FM = [FM1; FM2; FM3; FM4];
% FMpred = [FM1pred; FM2pred; FM3pred; FM4pred];


%% plot to check if a weird offset is arrising after separation (REMOVE AFTER DEBUGGING)

% % plot
% figure
% hold on
% plot(FMpred(:, 1), FMpred(:, 2), 'r*')
% plot(FM(:,1), FM(:,2), 'b*')
% for j = 1:length(FM)
%     plot([FM(j,1), FMpred(j,1)], [FM(j,2), FMpred(j,2)], 'm')
% end
% hold off
% 
% 
% figure
% hold on
% for k = 1:length(FM1)
%     testPoint_V = [RESraw(k,8), RESraw(k,7), RESraw(k,4), RESraw(k,6), RESraw(k,5)];   % actual tested points in units: [s(V), w(deg), P1(V), P2(V), P3(V)]
%     testPoint = [(testPoint_V(1,1)-4.077)*(1/0.033418), testPoint_V(1,2)-125, testPoint_V(1,3:5) * (999740/10)];   % convert it to units: [mm, deg, Pa, Pa, Pa]
%     FMpred = calcModelFM(testPoint, params);
%     plot(FM1(k,1), FM1(k,2), 'b*')
%     plot(FMpred(1,1), FMpred(1,2), 'r*')
%     plot([FM1(k,1), FMpred(1,1)], [FM1(k,2), FMpred(1,2)], 'm')
% end
% hold off

%%


% Calulate total error at each point
error = ( FM - FMpred );
error1 = abs(error(:,1));
error2 = abs(error(:,2));
squerror = diag(error * error');
squerror1 = error(:,1).^2;
squerror2 = error(:,2).^2;

% Maximum
maxERR(1,1) = max(error1(1 : length(FM1(:,1))));
maxERR(1,2) = max(error2(1 : length(FM1(:,1))));
maxERR(2,1) = max(error1(length(FM1(:,1))+1 : length(FM1(:,1))+length(FM2(:,1))));
maxERR(2,2) = max(error2(length(FM1(:,1))+1 : length(FM1(:,1))+length(FM2(:,1))));
maxERR(3,1) = max(error1(length([FM1;FM2])+1 : length([FM1;FM2;FM3])));
maxERR(3,2) = max(error2(length([FM1;FM2])+1 : length([FM1;FM2;FM3])));
maxERR(4,1) = max(error1(length([FM1;FM2;FM3])+1 : end));
maxERR(4,2) = max(error2(length([FM1;FM2;FM3])+1 : end));

% RMSE
RMSE(1,1) = sqrt(sum(squerror1(1 : length(FM1(:,1)))) / (length(FM1(:,1))));
RMSE(1,2) = sqrt(sum(squerror2(1 : length(FM1(:,1)))) / (length(FM1(:,1))));
RMSE(2,1) = sqrt(sum(squerror1(length(FM1(:,1))+1 : length(FM1(:,1))+length(FM2(:,1)))) / (length(FM2(:,1))));
RMSE(2,2) = sqrt(sum(squerror2(length(FM1(:,1))+1 : length(FM1(:,1))+length(FM2(:,1)))) / (length(FM2(:,1))));
RMSE(3,1) = sqrt(sum(squerror1(length([FM1;FM2])+1 : length([FM1;FM2;FM3]))) / (length(FM3(:,1))));
RMSE(3,2) = sqrt(sum(squerror2(length([FM1;FM2])+1 : length([FM1;FM2;FM3]))) / (length(FM3(:,1))));
RMSE(4,1) = sqrt(sum(squerror1(length([FM1;FM2;FM3])+1 : end)) / (length(FM4(:,1))));
RMSE(4,2) = sqrt(sum(squerror2(length([FM1;FM2;FM3])+1 : end)) / (length(FM4(:,1))));

% Average Percent Error
perror = zeros(length(FM), 1);
for m=1:length(FM)
    perror(m) = norm(error(m,:)) / norm(FMpred(m,:));
end 
percERR(1,1) = sum(perror(1:length(FM1))) / length(FM1); 
percERR(2,1) = sum(perror(length(FM1)+1 : length([FM1;FM2]))) / length(FM2); 
percERR(3,1) = sum(perror(length([FM1;FM2])+1 : length([FM1;FM2;FM3]))) / length(FM3); 
percERR(4,1) = sum(perror(length([FM1;FM2;FM3])+1 : end)) / length(FM4); 

end
















