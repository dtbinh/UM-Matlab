function zeta = Z2zeta( Z, params )
%Z2zeta: Converts FREE forces in FREE coordinates to net end effector force
%   Z is vertical concatenation of [F, M]' for several FREEs
%   zeta sum of zeta_i for each FREE

num = params.num;   % number of FREEs in parallel
d = params.d;
p = params.p;

zeta = zeros(6,1);
for i = 1:num
    diX = [0 , -d(3,i), d(2,i); d(3,i), 0, -d(1,i); -d(2,i), d(1,i), 0];
    Di = [p(:,i), zeros(3,1); [zeros(3,1), p(:,i)] + diX*[p(:,i), zeros(3,1)]];
%     zeta(6*(i-1)+1 : 6*i,1) = Di * Z(2*(i-1)+1 : 2*i, 1);
    zeta = zeta + Di * Z(2*(i-1)+1 : 2*i, 1);
end

end

