function fourierBasis = stateLift(in1,u1)
%STATELIFT
%    FOURIERBASIS = STATELIFT(IN1,U1)

%    This function was generated by the Symbolic Math Toolbox version 7.2.
%    17-Oct-2018 17:31:23

x1 = in1(1,:);
x2 = in1(2,:);
x3 = in1(3,:);
t2 = x1.*pi.*2.0;
t3 = x2.*pi.*2.0;
t4 = x3.*pi.*2.0;
t5 = u1.*pi.*2.0;
t6 = sin(t2);
t7 = sin(t3);
t8 = sin(t4);
t9 = sin(t5);
t10 = cos(t2);
t11 = x1.*pi.*4.0;
t12 = cos(t3);
t13 = x2.*pi.*4.0;
t14 = cos(t4);
t15 = x3.*pi.*4.0;
t16 = cos(t5);
t17 = u1.*pi.*4.0;
fourierBasis = [1.0;t6;t7;t8;t9;t10;t12;t14;t16;sin(t11);t6.*t7;sin(t13);t6.*t8;t7.*t8;sin(t15);t6.*t9;t7.*t9;t8.*t9;sin(t17);t6.*t10;t7.*t10;t8.*t10;t9.*t10;cos(t11);t6.*t12;t7.*t12;t8.*t12;t9.*t12;t10.*t12;cos(t13);t6.*t14;t7.*t14;t8.*t14;t9.*t14;t10.*t14;t12.*t14;cos(t15);t6.*t16;t7.*t16;t8.*t16;t9.*t16;t10.*t16;t12.*t16;t14.*t16;cos(t17)];
