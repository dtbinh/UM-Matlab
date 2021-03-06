function [ trialData ] = get_data( params )
%get_data: Read in empirical data with time, state, and input information
%   -Valid input file type is .mat
%   -Assumes you load in a single time series
%   -It interpolates input data so that data points are spaced by
%   sample period Ts.

numericalDerivs = params.numericalDerivs;

% create data struct
trialData = struct;

% Prompt user to identify data file
[data_file,data_path] = uigetfile;
[data_filepath,data_name,data_ext] = fileparts([data_path, data_file]);

%% Read in data file, and interpolate so points are Ts apart
if data_ext == '.mat'
    
    raw = load([data_path, data_file]);
    traw = raw.t;
    
%   % STRETCH OUT TIME
%     traw = 12 * traw;    
    
    traw = traw - traw(1);  % remove any offset in start time
    xraw = raw.x;
    uraw = raw.u;
    [traw_uq, index] = unique(traw);    % filter out non-unique values
    
    if numericalDerivs    % do this if numerical derivatives are req.
        % filter raw data to smooth it out a bit
        xraw = movmean(xraw, 50);
        
        % interpolate data so that it lines up with sampling times
        tq = ( 0:params.Ts:traw(end) )';
        xq = interp1(traw_uq, xraw(index,:), tq, 'spline');   % interpolate results to get samples at sampling interval Ts
        uq = interp1(traw_uq, uraw(index,:), tq, 'spline');
        
        % filter state measurements to lessen noise impact
        xfilt = movmean(xq, params.filterWindow(1));
        
%    %     % ISOLATE x coordinate
%         xfilt = xfilt(:,1);
        
        % take numerical derivatives between sampled points
        numstates = params.n/2;
        xdot = ( xfilt(2:end, :) - xfilt(1:end-1,:) ) / params.Ts;
        xdot = [xdot; zeros(1,numstates)];  % pad end with zeros to make size consistent
        
        % filter numerical derivatives to lessen noise impact
        xdotfilt = movmean(xdot, params.filterWindow(2));
        x = [xfilt, xdotfilt];
        
 %       % SCALE DATA (REMOVE THIS LATER!!)
        [x, uq] = scale_data(x, uq);
        
        % define output
        trialData.t = tq;
        trialData.x = x;
        trialData.u = uq;
        trialData.y = trialData.x;    % observed state == state since we have no other ground truth
    else 
        % filter raw data to smooth it out a bit
        xraw = movmean(xraw, 50);     
        
        % interpolate data so that it lines of with sampling times
        tq = ( 0:params.Ts:traw(end) )';
        xq = interp1(traw,xraw,tq, 'spline');   % interpolate results to get samples at sampling interval Ts
        uq = interp1(traw,uraw,tq, 'spline');
        
        % filter state measurements to lessen noise impact
        xfilt = movmean(xq, params.filterWindow(1));
        
   %     % SCALE DATA (REMOVE THIS LATER!!)
        [xfilt, uq] = scale_data(xfilt, uq);
%    %     % ISOLATE x coordinate
%         xfilt = xfilt(:,1);

        % define output
        trialData.t = tq;
        trialData.x = xfilt;
        trialData.u = uq;
        trialData.y = trialData.x;    % observed state == state since we have no other ground truth
    end
    
else 
    
    disp('Invalid file type selected. Data must be in .mat format')
    
end

end


%% CSV handling, which was removed for simiplicity

% if data_ext == '.csv'
%     
%     if numericalDerivs      % do this if numerical derivatives are req.
%         M = csvread([data_path, data_file]);
%         traw = M(:, 1);
%         traw = traw - traw(1);  % remove any offset in start time
%         xraw = M(:, 2 : 1+(params.n/2));
%         uraw = M(:, 2+(params.n/2) : 1+(params.n/2)+params.p);
%         [traw_uq, index] = unique(traw);    % filter out non-unique values
%         
%         % interpolate data so that it lines of with sampling times
%         tq = ( 0:params.Ts:traw(end) )';
%         
%         xq = interp1(traw_uq, xraw(index,:), tq);   % interpolate results to get samples at sampling interval Ts
%         uq = interp1(traw_uq, uraw(index,:), tq);
%         
%         % calculate numerical derivative at each point
%         xqdot = ( xq(2:end,:) - xq(1:end-1,:) ) / params.Ts;
%         xqdot = [xqdot; zeros(1,params.n/2)];
%         
%         % define output
%         trialData.t = tq;
%         trialData.x = [xq, xqdot];
%         trialData.u = uq;
%         trialData.y = trialData.x;    % observed state == state since we have no other ground truth
%     else
%         M = csvread([data_path, data_file]);
%         trialData.t = M(:, 1);
%         trialData.t = trialData.t - trialData.t(1);  % remove any offset in start time
%         trialData.x = M(:, 2 : 1+params.n);
%         trialData.u = M(:, 2+params.n : 1+params.n+params.p);
%         
%         % interpolate data so that it lines of with sampling times
%         tq = ( 0:params.Ts:trialData.t(end) )';
%         xq = interp1(trialData.t,trialData.x,tq);   % interpolate results to get samples at sampling interval Ts
%         uq = interp1(trialData.t,trialData.u,tq);
% 
%         % define output
%         trialData.t = tq;
%         trialData.x = xq;
%         trialData.u = uq;
%         trialData.y = trialData.x;    % observed state == state since we have no other ground truth
%     end
