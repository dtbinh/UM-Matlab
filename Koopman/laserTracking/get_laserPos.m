function [xLaser , yLaser] = get_laserPos( vid , tform)
%get_laserPos: Determine the laser postion in world coordinates
%   Detailed explanation goes here

frame = getdata(vid, 1);

start(vid);
[x, y] = util_findlaser(frame);
stop(vid);

if ~isnan(x) && ~isnan(y)
    % Determine spatial transformation from the calibration points.
    xyScreen = tformfwd([x, y], tform);
    xLaser = xyScreen(1);
    yLaser = xyScreen(2);
end

end

