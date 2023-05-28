function power = draw_power(lambda,k)
%draw_power returns the electric power from weibull(lambda,k)    
%   returns the electrical power generated at a windspeed 
%   drawn from a weibull distribution with scale parameter 
%   lambda and shape parameter k

load powercurve_V164.mat P;
windspeed = wblrnd(lambda, k);
power = P(windspeed);
end