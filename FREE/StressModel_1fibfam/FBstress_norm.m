
function Fnorm = FBstress_norm(x, u, params)

[F,J] = FBstress(x,u,params);
Fnorm = norm(F);

end