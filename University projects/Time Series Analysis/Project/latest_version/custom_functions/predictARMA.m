function [y_hat] = predictARMA(A,C,y,k)
%PREDICTARMA Summary of this function goes here
%   Detailed explanation goes here
[Fk, Gk] = polydiv( C, A, k);
y_hat = filter( Gk, C , y);
end

