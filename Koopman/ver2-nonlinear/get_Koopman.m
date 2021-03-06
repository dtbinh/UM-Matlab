function U = get_Koopman( x,y )
%get_Koopman: Generate finite dimensional approx. of Koopman operator from
%snapshot pairs
%   note: polyLift must be defined for the appropriate system before
%   calling this function.

%Px = zeros(length(x),)
for i = 1:length(x)
    Px(i,:) = polyLift(x(i,:)')';
    Py(i,:) = polyLift(y(i,:)')';
end

Pxinv = pinv(Px);
U = Pxinv * Py;

end