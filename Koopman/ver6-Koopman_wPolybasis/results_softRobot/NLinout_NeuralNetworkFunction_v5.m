function [y1,xf1] = NLinout_NeuralNetworkFunction_v5(x1,xi1)
%MYNEURALNETWORKFUNCTION neural network simulation function.
%
% Generated by Neural Network Toolbox function genFunction, 24-Aug-2018 20:57:25.
%
% [y1,xf1] = myNeuralNetworkFunction(x1,xi1) takes these arguments:
%   x1 = 3xTS matrix, input #1
%   xi1 = 3x2 matrix, initial 2 delay states for input #1.
% and returns:
%   y1 = 6xTS matrix, output #1
%   xf1 = 3x2 matrix, final 2 delay states for input #1.
% where TS is the number of timesteps.

% ===== NEURAL NETWORK CONSTANTS =====

% Input 1
x1_step1.xoffset = [0;0;0];
x1_step1.gain = [0.20053699350483;0.200544041106296;0.200280392549569];
x1_step1.ymin = -1;

% Layer 1
b1 = [0.073311108827848095;-0.17096615147045457;0.21967679279237434;0.21280491751069572;0.22493616087150156];
IW1_1 = [-10.411171391408432 15.184303112148228 -0.79270624598254613 10.871419025499698 -15.729436254208645 0.81394947195487954;13.30473306000099 5.4184849086464686 -27.744548967275332 -13.713791885513917 -5.7545192326075068 28.559494721044615;-5.6623407115594642 -62.88463581498209 2503.6281902394121 6.0229455968390271 62.987326307301828 -2506.3099227119701;-61.484450908770789 2405.8533803856808 -1.7353925413195848 61.575132783265524 -2408.4825608863002 2.0046006027925061;2347.750712406144 2.0680066235657919 -40.392657821091184 -2350.5947925034534 -1.8526651261515974 40.632537344057845];

% Layer 2
b2 = [-0.0087228713291651067;-0.062790229409360312;0.22786768104622615;0.04577083130889234;0.016437112795133872;-0.0081906762090586133];
LW2_1 = [-0.59049565077510713 0.00024692898386816358 0.012183920891546263 -0.17872919310682339 0.15782947011846885;0.059983136592391927 0.43315910525371737 -0.18099280398267006 0.085062736910606743 0.083671095942740373;-0.039329171544873878 0.0032875132883818424 0.03898132846288959 0.066900198059022253 0.10719437694600571;-0.40513479208372238 -0.0016905205941637556 -0.0037353487313519008 0.048880418626916673 -0.032622527583644798;0.014112061115613722 0.30400339035361129 0.054523326870756769 -0.015823232696150893 -0.01923079889914284;-0.014535298301201705 0.021846614567362043 0.0029910902098538136 -0.00045887527573723976 -0.00044319524013384376];

% Output 1
y1_step1.ymin = -1;
y1_step1.gain = [6.02925470600584;5.80239714539318;19.5174170890666;7.66459323490276;7.02419411493605;19.1826794012276];
y1_step1.xoffset = [-0.156274843142796;-0.148885540376267;-0.106342153265596;-0.133510159664189;-0.139378367975141;-0.0515426322556757];

% ===== SIMULATION ========

% Dimensions
TS = size(x1,2); % timesteps

% Input 1 Delay States
xd1 = mapminmax_apply(xi1,x1_step1);
xd1 = [xd1 zeros(3,1)];

% Allocate Outputs
y1 = zeros(6,TS);

% Time loop
for ts=1:TS
    
    % Rotating delay state position
    xdts = mod(ts+1,3)+1;
    
    % Input 1
    xd1(:,xdts) = mapminmax_apply(x1(:,ts),x1_step1);
    
    % Layer 1
    tapdelay1 = reshape(xd1(:,mod(xdts-[1 2]-1,3)+1),6,1);
    a1 = tansig_apply(b1 + IW1_1*tapdelay1);
    
    % Layer 2
    a2 = b2 + LW2_1*a1;
    
    % Output 1
    y1(:,ts) = mapminmax_reverse(a2,y1_step1);
end

% Final delay states
finalxts = TS+(1: 2);
xits = finalxts(finalxts<=2);
xts = finalxts(finalxts>2)-2;
xf1 = [xi1(:,xits) x1(:,xts)];
end

% ===== MODULE FUNCTIONS ========

% Map Minimum and Maximum Input Processing Function
function y = mapminmax_apply(x,settings)
y = bsxfun(@minus,x,settings.xoffset);
y = bsxfun(@times,y,settings.gain);
y = bsxfun(@plus,y,settings.ymin);
end

% Sigmoid Symmetric Transfer Function
function a = tansig_apply(n,~)
a = 2 ./ (1 + exp(-2*n)) - 1;
end

% Map Minimum and Maximum Output Reverse-Processing Function
function x = mapminmax_reverse(y,settings)
x = bsxfun(@minus,y,settings.ymin);
x = bsxfun(@rdivide,x,settings.gain);
x = bsxfun(@plus,x,settings.xoffset);
end
