function [yhat, xhat] = predictARMAX(A, B, C, y, x, k)
%PREDICTBJ HELLO
%   Detailed explanation goes here
[Fk, Gk] = polydiv( C, A, k );
[Fhat, Ghat] = polydiv( conv(B,Fk), C, k);
xhat = filter( Gk, C, x);
yhat = filter( Gk, C, y ) + filter( Ghat, C, x ) + filter(Fhat, 1, xhat);
end

