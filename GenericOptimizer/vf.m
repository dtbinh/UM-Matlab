function [f, dfdx, dfdu, dfdxdot] = vf(x, u, xdot, params)

    n = params.n;
    m = params.m;
    
    f = f_eval(x', u', xdot');   %dynamics
    dfdx = dfdx_eval(x', u', xdot');    % gradient of dynamics wrt state (x)
    dfdu = dfdu_eval(x', u', xdot');    % gradient of dynamics wrt input (u)
    dfdxdot = dfdxdot_eval(x', u', xdot'); % gradient of dynamics wrt time derivative of states (xdot)
    
end