function vf2 = vf_sysid(in1,u1)
%VF_SYSID
%    VF2 = VF_SYSID(IN1,U1)

%    This function was generated by the Symbolic Math Toolbox version 7.2.
%    01-Aug-2018 16:48:55

x1 = in1(1,:);
x2 = in1(2,:);
t2 = u1.^2;
t3 = x2.^2;
t4 = x1.^2;
vf2 = [t2.*8.942016366892542e-1+t3.*1.060300281213078+t4.*2.611423286431021e1-u1.*4.862062362146085+x1.*2.548490111600339e1+x2.*2.039124294467686-t2.*u1.*5.365788258108442e-2-t3.*u1.*1.275254554121495e-1-t4.*u1.*5.077833619286057+t2.*x1.*9.178346006097265e-1+t2.*x2.*8.762198503873258e-3+t3.*x1.*8.845999832283836e-1+t3.*x2.*5.206661634930314e-1+t4.*x1.*8.759594562797066+t4.*x2.*8.162378339712892e-1-u1.*x1.*1.003557967241332e1+u1.*x2.*5.113165789470863e-2+x1.*x2.*1.943291338174812+u1.*x1.*x2.*1.232810245413352e-1+8.136001952735905;t2.*(-2.878035391594362e-1)+t3.*1.810502225545573-t4.*5.604503334089009+u1.*1.159546739261608-x1.*4.503165021103309+x2.*7.338775078573818e-1+t2.*u1.*2.770207829695517e-2-t3.*u1.*3.99704494708778e-1+t4.*u1.*1.482315996463129-t2.*x1.*2.964868152141414e-1-t2.*x2.*1.497387790492946e-1+t3.*x1.*2.014928895617812-t3.*x2.*6.773368730888514e-1-t4.*x1.*2.885792476653759+t4.*x2.*5.273617323488649e-1+u1.*x1.*2.457947128161278+u1.*x2.*3.454891373912043e-1+x1.*x2.*1.347986470994758+u1.*x1.*x2.*4.130809028711627e-1-1.77446620451583];
