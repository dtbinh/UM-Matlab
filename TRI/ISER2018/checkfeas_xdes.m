function [xgoal, feasability] = checkfeas_xdes( xdes, params )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

fun = @(xind) xind2xcoupled(xind) - xdes;
xind0 = ones(params.xindnum, 1);

options = optimoptions('fsolve', 'Algorithm', 'levenberg-marquardt', 'FunctionTolerance', 1e-9);
[xindsol, ~, exitflag] = fsolve(fun, xind0, options);

if exitflag <= 0
    xgoal = [];
    feasability = 0;
else
    xgoal = xind2xcoupled(xindsol);
    feasability = 1;
end

end
