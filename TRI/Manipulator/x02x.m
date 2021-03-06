function x = x02x( x0, params )
%x02x: Converts state in global coordinates to local module coordinates
%   Detailed explanation goes here

p = params.p;  

% selection matrix to isolate position component of module state
Spos = [eye(3), zeros(3,3)];
Seul = [zeros(3,3), eye(3)];

%% calculate x in terms of x0
x = zeros(size(x0));

x(4:6, 1) = x0(4:6,1);
x(1:3, 1) = euler2cart(x0(4:6,1), params.L(1));
for i = 2:p
   x0i = x0(1+6*(i-1) : 6*i, 1);     % state of ith module in global coordinates
   x0im1 = x0(1+6*(i-2) : 6*(i-1), 1);     % state of (i-1)th module in global coordinates
   
   R0_i = Reuler(x0i(4:6,1));       % rotation matrix from ith to 0 frame
   R0_im1 = Reuler(x0im1(4:6,1));   % rotation matrix from (i-1)th to 0 frame
%    Rim1_0 = pinv(R0_im1);           % rotation matrix from to (i-1)th frame
   Rim1_0 = R0_im1';           % rotation matrix from to (i-1)th frame

%    T = [Rim1_0, zeros(3,3)];
   
%   xi(1:3, 1) = T * (x0i - x0im1);      % set position component of xi
   xi_orient = rot2euler_sym(Rim1_0 * R0_i);
   xi(1:3, 1) = euler2cart(xi_orient, params.L(i));      % set position component of xi
   xi(4:6, 1) = xi_orient;   % set orientation component of xi

%    xi(4:6, 1) = fliplr(rotm2eul(Rim1_0 * R0_i))';     % USES ROBOTICS TOOLBOX, UNNECCESSARY
   
   x(1+6*(i-1) : 6*i, 1) = xi;
end

%% original version of for loop below (does not work)
% for i = 2:p
%    x0i = x0(1+6*(i-1) : 6*i, 1);     % state of ith module in global coordinates
%    x0im1 = x0(1+6*(i-2) : 6*(i-1), 1);     % state of (i-1)th module in global coordinates
%    Tinv = [Reuler(x0im1(4:6, 1)), zeros(3,3); zeros(3,3), Reuler(x0im1(4:6, 1))];      % coordinate transformation, local to global
%    T = pinv(Tinv);      % coordinate transformation, global to local
%    
%    xi = T * (x0i - Spos*x0im1);
%    x(1+6*(i-1) : 6*i, 1) = xi;
% end


end

