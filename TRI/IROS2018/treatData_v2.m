function [FM1, FM2, FM3, FM4, FM1pred, FM2pred, FM3pred, FM4pred, RMSE, maxERR, percERR] = treatData_v2(MatDataFile, testParams, params)
% treatData: Reads in measured data, removes elastomer offsets, splits into
% separate arrays for each configuration. Also measures error
% MatDataFile is a string which is the name of the .mat file containing the
% test data

% Load in test data and input points
load(MatDataFile);

% FMraw = SyncFT.data;
% RESraw = SycRes.data;
FMraw = FTsync.data;    % for testData_4 and above
RESraw = rSync.data;   % for testData_4 and above

RESraw_t = RESraw(1:end, 1);    % save the time series vector
% RESraw = [RESraw(2:end, :); zeros(size(RESraw(1,:)))]; % offset by one row EXPERIMENTAL

% % shift FM data to the left 5 seconds (i.e. 20 measurements) to properly align them, append zeros to the end so that their lengths will still match up (only test 4, 7)
% FMraw = [FMraw(21:end, :); zeros(20,2)];

% % shift FM data to the left 2.5 seconds (i.e. 10 measurements) to properly align them, append zeros to the end so that their lengths will still match up (only test 8)
% FMraw = [FMraw(11:end, :); zeros(10,2)];

% shift FM data to the left 0.8 seconds (i.e. 3 measurements) to properly align them, append zeros to the end so that their lengths will still match up (only test 9)
FMraw = [FMraw(4:end, :); zeros(4,2)];

%% Remove problematic points
% remove bad transition points (where linear actuator or servo weren't set)
i = 1;
while i <= length(RESraw)
    if (RESraw(i,7) == testParams.servoOffset || RESraw(i,7) == testParams.servoOffset + 20) &&  abs((RESraw(i,8)-testParams.linOffset)*(1/0.033418) - 2.5) > 2
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

% % Remove last 20 data points because we know they are messed up (test 4,7)
% RESraw(end-20:end,:) = [];
% FMraw(end-20:end,:) = [];

% % Remove last 10 data points because we know they are messed up (test 8)
% RESraw(end-10:end,:) = [];
% FMraw(end-10:end,:) = [];

% Remove last 4 data points because we know they are messed up (test 9)
RESraw(end-4:end,:) = [];
FMraw(end-4:end,:) = [];

%% Partition the data by pressure input

% find all of the times when new control pressure signal sent (last entry is when pressure drops back to zero)
RESsteps = [1, RESraw(1, 1:3)];
for i = 2:length(RESraw)
   if any( RESraw(i, 1:3) ~= RESraw(i-1, 1:3) )
       RESsteps = [ RESsteps; i, RESraw(i, 1:3) ];
   end
end

% take average pressure and force/moment at each step (call is "mean")
buffer = 8; % doesn't average in points near transitions
for i = 1:length(RESsteps) - 1
    RESmean(i,:) = nanmean( RESraw( RESsteps(i,1)+buffer : RESsteps(i+1,1)-buffer, : ) );
    FMmean(i,:) = nanmean( FMraw( RESsteps(i,1)+buffer : RESsteps(i+1,1)-buffer, : ) );
end
RESmean(i+1,:) = nanmean( RESraw( RESsteps(i+1,1)+buffer : end-buffer, : ) ); % append last point
FMmean(i+1,:) = nanmean( FMraw( RESsteps(i+1,1)+buffer : end-buffer, : ) );   % append last point

%% Simulate at the same points as those measured

% % Read in the actual points tested and convert to format that can be simulated (using Pin signal values)
% testPoints_V = [RESraw(:,8), RESraw(:,7), RESraw(:,3), RESraw(:,2), RESraw(:,1)];   % actual tested points in units: [s(V), w(deg), P1(V), P2(V), P3(V)]
% testPoints = [(testPoints_V(:,1)-4.077)*(1/0.033418), testPoints_V(:,2)-125, testPoints_V(:,3:5) * (testParams.TRmax/10)];   % convert it to units: [mm, deg, Pa, Pa, Pa]

% Read in the actual points tested and convert to format that can be simulated (using Pmonitor signal values)
% testPoints_V = [RESraw(:,8), RESraw(:,7), RESraw(:,4), RESraw(:,6), RESraw(:,5)];   % actual tested points in units: [s(V), w(deg), P1(V), P2(V), P3(V)]
% testPoints = [(testPoints_V(:,1)-testParams.linOffset)*(1/0.033418), testPoints_V(:,2)-testParams.servoOffset, testPoints_V(:,3:5) * (999740/10)];   % convert it to units: [mm, deg, Pa, Pa, Pa]
testPoints_V = [RESmean(:,8), RESmean(:,7), RESmean(:,4), RESmean(:,6), RESmean(:,5)];   % actual tested points in units: [s(V), w(deg), P1(V), P2(V), P3(V)]
testPoints = [(testPoints_V(:,1)-testParams.linOffset)*(1/0.033418), testPoints_V(:,2)-testParams.servoOffset, testPoints_V(:,3:5) * (999740/10)];   % convert it to units: [mm, deg, Pa, Pa, Pa]

% Calculate the predicted forces at each point in testPoints
FMpred = calcModelFM(testPoints, params);
% FMpred = [FMpred(2:end, :); zeros(1,2)]; % offset by one row EXPERIMENTAL

FMraw = FMmean; % change the name here so I don't have to rewrite all the code following


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

% FM1 = -1 * ( FM1raw - [0, -0.005] - FMraw(1,:) ); (test 3)
% FM2 = -1 * ( FM2raw - [15.9, -0.018] - FMraw(1,:) );
% FM3 = -1 * ( FM3raw - [-1.1, -0.021] - FMraw(1,:) );
% FM4 = -1 * ( FM4raw - [16.2, -0.041] - FMraw(1,:) );
% FM = [FM1; FM2; FM3; FM4];
% % FMpred = [FM1pred; FM2pred; FM3pred; FM4pred];

% % Remove offset automatically (test 6)
% FM1 = -1 * ( FM1raw - FM1raw(1,:) + [7.3266, -0.0435]);
% FM2 = -1 * ( FM2raw - FM2raw(1,:) + [6.2545, 0.0023]);
% FM3 = -1 * ( FM3raw - FM3raw(1,:) + [-1.8354, 0.0093]);
% FM4 = -1 * ( FM4raw - FM4raw(1,:) + [2.2386, -0.0009]);
% FM = [FM1; FM2; FM3; FM4];

% % Remove offset automatically (test 6)
% FM1 = -1 * ( FM1raw + [-13.0604, -0.0992]);
% FM2 = -1 * ( FM2raw + [-25.2231,   -0.0779]);
% FM3 = -1 * ( FM3raw + [-9.8061,   -0.071]);
% FM4 = -1 * ( FM4raw + [-24.6559,   -0.0391]);
% FM = [FM1; FM2; FM3; FM4];

% % Remove offset automatically (test 7)
% FM1 = -1 * ( FM1raw - FM1raw(1,:) + [8.8622,   -0.0075]);
% FM2 = -1 * ( FM2raw - FM2raw(1,:) + [3.9390,    0.0050]);
% FM3 = -1 * ( FM3raw - FM3raw(1,:) + [-2.3967,   -0.0035]);
% FM4 = -1 * ( FM4raw - FM4raw(1,:) + [3.0678,   -0.0033]);
% FM = [FM1; FM2; FM3; FM4];

% % Remove offset automatically (test 8)
% FM1 = -1 * ( FM1raw - FM1raw(1,:) + [7.8917,   -0.0116]);
% FM2 = -1 * ( FM2raw - FM2raw(1,:) + [4.2820   -0.0003]);
% FM3 = -1 * ( FM3raw - FM3raw(1,:) + [-1.2367   -0.0070]);
% FM4 = -1 * ( FM4raw - FM4raw(1,:) + [4.3577   -0.0094]);
% FM = [FM1; FM2; FM3; FM4];

% Remove offset automatically (test 9)
FM1 = -1 * ( FM1raw - FM1raw(1,:) + [0.2830,    0.0057] );
FM2 = -1 * ( FM2raw - FM2raw(1,:) + [3.1437,    0.0092] );
FM3 = -1 * ( FM3raw - FM3raw(1,:) + [-2.6889,   -0.0031] );
FM4 = -1 * ( FM4raw - FM4raw(1,:) + [2.2392,   -0.0015] );
FM = [FM1; FM2; FM3; FM4];

% % Remove offset automatically
% FM1 = -1 * ( FM1raw - FMraw(1,:) );
% FM2 = -1 * ( FM2raw - FM2raw(1,:));
% FM3 = -1 * ( FM3raw - FM3raw(1,:));
% FM4 = -1 * ( FM4raw - FM4raw(1,:));
% FM = [FM1; FM2; FM3; FM4];




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

% Average Error
avgerror = zeros(length(FM), 2);
avgERR(1,:) = sum(error(1:length(FM1), :)) / length(FM1); 
avgERR(2,:) = sum(error(length(FM1)+1 : length([FM1;FM2]), :)) / length(FM2); 
avgERR(3,:) = sum(error(length([FM1;FM2])+1 : length([FM1;FM2;FM3]), :)) / length(FM3); 
avgERR(4,:) = sum(error(length([FM1;FM2;FM3])+1 : end, :)) / length(FM4); 

end
















