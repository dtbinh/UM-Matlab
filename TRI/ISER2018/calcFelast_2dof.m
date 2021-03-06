function felast = calcFelast_2dof(pDatafile ,params)
%calcFelast - performs system identification to determine the cumulative
%elastomer contribution.z

%%  Read in mocap data, save it in 'endeff' struct
mocap = getC3Ddata(params);     % read in raw mocap data from C3D file
endeff = mocap2endeff(mocap);   % convert raw mocap data into endeffector coordinates

%% Read in pressure data, save it in 'TR' struct
TR = struct;
pData = csvread(pDatafile);
TR.t = pData(:,1);
TR.pcontrol = pData(:,3:5);
TR.pmonitor = pData(:,11:13);

%% Partition the pressure data

% find all of the times when new control pressure signal sent (last entry is when pressure drops back to zero)
TR.tsteps = [1, TR.t(1)];
for i = 2:length(TR.t)
   if any( TR.pcontrol(i,:) ~= TR.pcontrol(i-1,:) )
       TR.tsteps = [ TR.tsteps; i, TR.t(i) ];
   end
end

% take average pressure at each step
for i = 1:length(TR.tsteps) - 1
    TR.psteps(i,:) = nanmean( TR.pmonitor( TR.tsteps(i,1)+5:TR.tsteps(i+1,1)-5, : ) );    % excludes some points that are in the transition region
end

%% Line up mocap and pressure data, and partition mocap data

% helpful plot for figuring out time offset
figure
hold on
plot(endeff.t, endeff.x(:,4), 'k')  % phi wrt time
stairs(TR.tsteps(1:end-1,2), TR.psteps(:,3))    % average pressure wrt time
title('Mocap and Pressure Data Together')
legend('Mocap: PhaseSpace', 'Pressure: TR')
hold off

% Prompt the user to identify the time offset between the data sets from
% the plot
prompt = 'What is the time offset between the PhaseSpace and TR data, in seconds?:';
offset = input(prompt);     % the start of the mocap trial expressed in pressure time
if isnumeric(offset)
    PS.t0 = offset;
else
    disp('Invalid. You must enter a numeric value.');
    return;
end

PS.t = endeff.t + PS.t0;  % add the offset to sync the start times
PS.x  = interp1(PS.t, endeff.x, TR.t);    % interpolate to get everything on the same time scale BUT REMEMBER YOU CAN'T INTERPOLATE EULER ANGLES SO YOU MUST CHANGE THIS!
PS.tsteps = TR.tsteps;  % now they are synchronized in time

% take average x at each step
for i = 1:length(TR.tsteps) - 1
    PS.xsteps(i,:) = nanmean( PS.x( TR.tsteps(i,1)+5:TR.tsteps(i+1,1)-5, : ) );    % excludes some points that are in the transition region
end

% plot to see if averaging x at each time step worked (for DEBUGGING)
figure
hold on
plot(TR.t, PS.x(:,4), 'k')  % 
stairs(TR.tsteps(1:end-1,2), PS.xsteps(:,4))    % 
hold off

%% Calculate elastomer force (y) at each point
for i = 1 : length(TR.tsteps)-1
    elast = calcf(PS.xsteps(i,:)', TR.psteps(i,:)', params);
    y(i,:) = -elast';
end

felast = struct;
% fit polynomial to elestomer force: e(x)
felast.x1 = MultiPolyRegress(PS.xsteps, y(:,1), 2);
felast.x2 = MultiPolyRegress(PS.xsteps, y(:,2), 2);
felast.x3 = MultiPolyRegress(PS.xsteps, y(:,3), 2);
felast.x4 = MultiPolyRegress(PS.xsteps, y(:,4), 4);
felast.x5 = MultiPolyRegress(PS.xsteps, y(:,5), 2);
felast.x6 = MultiPolyRegress(PS.xsteps, y(:,6), 2);

% save the elastomer force within the params struct
params.felast = felast;


end
