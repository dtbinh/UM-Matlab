function vf2 = vf_koopman(in1,u1)
%VF_KOOPMAN
%    VF2 = VF_KOOPMAN(IN1,U1)

%    This function was generated by the Symbolic Math Toolbox version 7.2.
%    17-Oct-2018 19:25:12

x1 = in1(1,:);
x2 = in1(2,:);
x3 = in1(3,:);
t2 = u1.^2;
t3 = x1.^2;
t4 = x2.^2;
t5 = x3.^2;
vf2 = [t2.*(-8.333143809546673)-t3.*1.911951364088814e-1-t4.*8.748551080747563e-1+t5.*1.509440585661577+u1.*3.884068943499489-x1.*7.411592220746233e-1+x2.*9.339894474180278-x3.*5.993682618470481-u1.*x1.*1.381631363784082e-1-u1.*x2.*2.25239676792355e1+u1.*x3.*4.100731708351574+x1.*x2.*2.488672232332491e-1-x1.*x3.*1.134968088227617-x2.*x3.*9.983149445411675-8.443646814264714e-1;t2.*6.093567832895094+t3.*1.996991475741173e-1+t4.*4.943777483382236e-1+t5.*4.028961086401036-u1.*6.874197581489371e-1-x1.*3.688870900332197-x2.*2.035909384781119-x3.*6.05353455453181e-1+u1.*x1.*1.045010863934774e1+u1.*x2.*5.724508660507947+u1.*x3.*8.869831545252206+x1.*x2.*4.713768562817394e-1+x1.*x3.*6.340272406796029+x2.*x3.*2.554411969435364-5.659732205282205e-1;t2.*(-3.345243184155661)+t3.*1.394494781453958e-2+t4.*2.382610625522648e-1+t5.*1.124214284695558+u1.*1.437593151953706-x1.*3.964487388480427e-1+x2.*1.205782340787113e-1-x3.*2.090273930563697+u1.*x1.*1.051802286930344-u1.*x2.*3.137147789861206e-2+u1.*x3.*1.303468612032505-x1.*x2.*2.025026379002028e-1+x1.*x3.*8.947055193376774e-1-x2.*x3.*6.957285405343384e-1-8.038856169327679e-2];
