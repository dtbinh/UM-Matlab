function q = x2q(in1)
%X2Q
%    Q = X2Q(IN1)

%    This function was generated by the Symbolic Math Toolbox version 7.2.
%    31-May-2018 16:43:13

x3 = in1(3,:);
x4 = in1(4,:);
t2 = x3+4.0./2.5e1;
t3 = t2.^2;
t4 = x4.^2;
q = [sqrt(t3+t4.*5.225796e-4)-4.0./2.5e1;x4;sqrt(t3+t4.*9.751105400976e-4)-4.0./2.5e1;x4;sqrt(t3+t4.*7.000267289760001e-5)-4.0./2.5e1;x4];
