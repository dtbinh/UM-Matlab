function draw_at_t( t_des, t, y, u, params )
%draw_at_t: After running ode15i simulation this will draw the module at a
%certain point of time.
%   Basically takes a snapshot of the animation gif at specifit time

% interpolate so that time(s) where figure is drawn are equally spaced
tq = linspace(0,t(end),1200)';
yq = interp1(t,y,tq);
uq = interp1(t,u,tq);

% find point in t closest to t_des
tp = round(t_des,3);
index_tp = find(abs(tq - tp) < 0.005);

% figure
drawModule(yq(index_tp(1),:)', params, tq(index_tp(1)), uq(index_tp(1),:));

end

