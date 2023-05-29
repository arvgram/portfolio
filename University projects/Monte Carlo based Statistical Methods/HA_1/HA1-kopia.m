load powercurve_V164.mat
%%
N = 10000;
alpha = 0.05;
months = [10.6 9.7 9.2 8.0 7.8 8.1 7.8 8.1 9.1 9.9 10.6 10.6; 2 2 2 1.9 1.9 1.9 1.9 1.9 2 1.9 2 2]';
months = months(1,:);
nbr_months = length(months(:,1));

%%
[powers,x] = Power(1,N);
standard_estimate = mean(powers);
var_standard_estimate = var(powers);
disp("Power estimate: " + standard_estimate)
disp("Variance of estimate: " + var_standard_estimate)
CI = [standard_estimate+norminv(alpha/2)*std(powers)/sqrt(N) standard_estimate+norminv(1-alpha/2)*std(powers)/sqrt(N)];
%%
histogram(powers)

%% Truncated version
[powerstr,xtr] = PowersTrunc(1,N,3.5,25);
trunc_estimate = mean(powerstr);
var_trunc_estimate = var(powerstr);
disp("Power estimate: " + trunc_estimate)
disp("Variance of estimate: " + var_trunc_estimate)

%%
histogram(x,'BinWidth',0.5)
hold on
histogram(xtr,'BinWidth',0.5)

%%
idxjan = powers(1,:) == 0;
probability = 1-sum(idxjan)/N;
%% With control variate:
for month = 1:nbr_months
    lambda = months(month,1);
    k = months(month,2);  
    Y = wblrnd(lambda, k, N,1);
    X = P(Y);
end

m = lambda*gamma(1+1/k);
sig2 = lambda^2*gamma(1+2/k) - m^2;

covXY = cov(X,Y);

beta = -covXY(1,2)/sig2;

Z = X + beta*(Y-m);
cv_estimate = mean(Z);
var_cv_estimate = var(Z);

disp("Control variate adjusted estimate: " + mean(Z))
disp("Variance of estimate: " + var_cv_estimate)

%%
disp("Difference in estimated value: " + ((standard_estimate-cv_estimate)/standard_estimate)*100 + " %")
disp("Difference in estimate variance: " + (-(var_standard_estimate-var_cv_estimate)/var_standard_estimate)*100 + " %")

%% Importance sampling 
% idea: draw from a distribution g where g(x) = 0 => f(x)*phi(x) = 0 but
% which is more dense in important area, and compensate for sampling from
% the wrong distribution with omega = f(x)/g(x) 

% find good instrumental density g: we want to flatten the function f*phi
f = figure;
f.Position = [100 100 700 300];

v = linspace(0,27);
lambda = 9.13;
k = 1.96;  
plot(v, wblpdf(v,lambda,k).*(P(v)).^2')

title("P(v)f(v)")

powerperwind = wblpdf(v,lambda,k).*(P(v)).^2';
meanfp = mean(powerperwind);
varfp = var(powerperwind);


disp("Most frequent power output " + meanfp)
disp("Variance of power output frequency " + varfp)

%% finding good instrumental:
%instrumental = @(v) normpdf(v,12,sqrt(estsig2));
%pd = makedist("Normal","mu",12,"sigma",sqrt(estsig2));

pd = makedist('Weibull','A',15,'B',4);
tpd = truncate(pd,3.5,25);

instrumental = @(v) pdf(tpd,v);

amplifier = max(powerperwind)/max(instrumental(v));

f = figure;
f.Position = [100 100 700 300];
plot(v, amplifier*instrumental(v),"LineWidth",1)
hold on
legends = strings(nbr_months+1,1);
legends(1) = "instrumental g(v)";
plot(v, wblpdf(v,lambda,k).*(P(v)).^2')
hold off

%% Examining the flattening effect
f = figure;
f.Position = [100 100 700 300];
hold on
flattened = wblpdf(v,lambda,k).*(P(v)).^2'./(instrumental(v)); 
flattened(isnan(flattened)) = 0;
plot(v,flattened)

title("The (hopefully) flattened resulting distribution P(v)f(v)/g(v)")
%% ws cleaning 
clear path path_prefix f filename amplifier meanfp varfp v flattened powerperwind legends

%% Using importance sampling from instrumental

omega = @(x) wblpdf(x,lambda, k)./instrumental(x);
X = random(tpd,N,1);
is_samples = (P(X)).^2.*omega(X);

means = mean(is_samples);
variance = var(is_samples);

conf_int = [means+norminv(alpha)/sqrt(N)*sqrt(variance), means-norminv(alpha)/sqrt(N)*sqrt(variance)];

means
variance
conf_int

%% Antithetic sampling
% idea: use a variable that is negatively correlated with our variable but
% has same mean and variance and use average of these to reduce variance.
% Since the power function is monotone, we can use Lemma from lecture 4.
U = rand(N,1);
T_U = 1-U;
V = P(wblinv(U,lambda,k));
V_tilde = P(wblinv(T_U,lambda,k));

W = (V+V_tilde)./2;

at_estimate = mean(W);
var_at_estimate = var(W);

disp("Difference in estimated value: " + ((standard_estimate-at_estimate)/standard_estimate)*100 + " %")
disp("Difference in estimate variance: " + (-(var_standard_estimate-var_at_estimate)/var_standard_estimate)*100 + " %")

%% Estimate the probability that the turbine delivers power

% the turbine delivers power for all windspeeds in [3.5, 25]
M = N;
idx = P(wblrnd(lambda, k, M, 1)) == 0;
disp("Probabilty of turbine producing power: " + (1-sum(idx)/M))

%% Importance sampling 2d
% idea: draw from a distribution g where g(x) = 0 => f(x)*phi(x) = 0
% evaluate our function as phi(x)*f(x)/g(x)

% find good instrumental density g: (for later augmentation only draw
% windspeeds smaller than the turbine produces maximum effect)
% g = uniform(3.5, 25)

k = 1.96; lambda = 9.13; alpha = 0.638; p = 3; q = 1.5;

Fv = @(v) wblcdf(v,lambda,k);
fv = @(v) wblpdf(v,lambda,k);

pdf2d = @(v1,v2) fv(v1).*fv(v2).*(1 + alpha.*(1-Fv(v1).^p).^(q-1).*(1-Fv(v2).^p).^(q-1).*(Fv(v1).^p.*(1+p*q)-1).*(Fv(v2).^p.*(1+p*q)-1))
omega2d = @(v1,v2) pdf2d(v1,v2)./mvnpdf([v1 v2], [11 11], [sig11 sig12 ; sig12 sig22]);

% is_samples = zeros(N,2);
% 
% is_samples(:,1) = P(X(:,1)).*omega2d(X(:,1),X(:,2));
% is_samples(:,2) = P(X(:,2)).*omega2d(X(:,1),X(:,2));
% is_estimate = mean(is_samples);
% var_is_estimate = var(is_samples);
% cov_is_estimate = cov(is_samples);

%%
%[x1, x2] = meshgrid(0:1:30,0:1:30);
%X = P(x1)+P(x2);
mu = 11;
sig11 = 21;
sig12 = 6;
sig22 = 21;

x1 = linspace(0,29,30);
x2 = linspace(0,29,30);
powers = zeros(30,30);

for i = 1:30
    for j = 1:30
        powers(i,j) = (P(i)*P(j))*pdf2d(i,j)/mvnpdf([i j], [mu mu], [sig11 sig12 ; sig12 sig22]); 
    end
end

surf(x1,x2,powers)
xlabel("Windspeed 1")
ylabel("Windspeed 2")

%%
N = 1000;
X = mvnrnd([mu mu], [sig11 sig12; sig12 sig22],N);
omega2d = @(v1,v2) pdf2d(v1,v2)./mvnpdf([v1 v2], [mu mu], [sig11 sig12 ; sig12 sig22]);
is_product = zeros(N,1);
is_product(:) = P(X(:,1)).*P(X(:,2)).*omega2d(X(:,1),X(:,2));
is_productmean = mean(is_product)

pd = makedist('Weibull','A',15,'B',4);
tpd = truncate(pd,3.5,25);
omegasq = @(x) wblpdf(x,lambda, k)./instrumental(x);
X = random(tpd,N,1);
is_square1 = (P(X)).^2.*omegasq(X);
is_sqmean1 = mean(is_square1)
X = random(tpd,N,1);
is_square2 = (P(X)).^2.*omegasq(X);
is_sqmean2 = mean(is_square2)

pd = makedist('Weibull','A',14,'B',3);
tpd = truncate(pd,3.5,25);
omega = @(x) wblpdf(x,lambda, k)./instrumental(x);
X = random(tpd,N,1);
is_1 = (P(X)).*omega(X);
is_mean1 = mean(is_1)
X = random(tpd,N,1);
is_2 = (P(X)).*omega(X);
is_mean2 = mean(is_2)

cov = is_productmean - is_mean1*is_mean2
var1 = is_sqmean1 - is_mean1^2
var2 = is_sqmean2 - is_mean2^2
sumvar = var1 + var2 + 2*cov
stdv = sqrt(sumvar)

%%
N = 100000;
alpha = 0.05;
X = mvnrnd([mu mu], [sig11 sig12; sig12 sig22],N);
omega2d = @(v1,v2) pdf2d(v1,v2)./mvnpdf([v1 v2], [mu mu], [sig11 sig12 ; sig12 sig22]);
is_2d = zeros(N,2);
powers = P(X(:,1)) + P(X(:,2));
equalto = powers == 9.5e6;
greaterthan = powers > 9.5e6;
lessthan = powers < 9.5e6;
probseq = mean(equalto.*omega2d(X(:,1),X(:,2)));
probsgr = mean(greaterthan.*omega2d(X(:,1),X(:,2)));
probsless = mean(lessthan.*omega2d(X(:,1),X(:,2)));

%is_2d(:,1) = P(X(:,1)).*omega2d(X(:,1),X(:,2));
%is_2d(:,2) = P(X(:,2)).*omega2d(X(:,1),X(:,2));

%psum = is_2d*[1, 1]';
% prob1 = psum(:) > 9.5e6;
% mean1 = mean(prob1);
% var1 = var(prob1);
% CI1 = [mean(prob1)+norminv(alpha/2)*std(prob1)/sqrt(N) mean(prob1)+norminv(1-alpha/2)*std(prob1)/sqrt(N)];
% prob2 = psum(:) < 9.5e6;
% mean2 = mean(prob2);
% var2 = var(prob2);
% CI2 = [mean(prob2)+norminv(alpha/2)*std(prob2)/sqrt(N) mean(prob2)+norminv(1-alpha/2)*std(prob2)/sqrt(N)];

% probbgreater = (psum(:) > 9.5e6 - 1e5);
% probbsmaller = (psum(:) < 9.5e6 +1e5);
% probbtot = probbgreater + probbsmaller == 2;
% meann = mean(probbtot);

%%
probb = psum(:) == 9.5e6;
meann = mean(probb);

%%
function [powers,x] = Power(month,n)
   load powercurve_V164
   months = [10.6 9.7 9.2 8.0 7.8 8.1 7.8 8.1 9.1 9.9 10.6 10.6; 2 2 2 1.9 1.9 1.9 1.9 1.9 2 1.9 2 2];
   lambda = months(1,month);
   k = months(2,month);
   x = wblrnd(lambda,k,1,n);
   powers = P(x);
end

function [powerstr,xtr] = PowersTrunc(month,n,a,b)
   load powercurve_V164
   months = [10.6 9.7 9.2 8.0 7.8 8.1 7.8 8.1 9.1 9.9 10.6 10.6; 2 2 2 1.9 1.9 1.9 1.9 1.9 2 1.9 2 2];
   lambda = months(1,month);
   k = months(2,month);
   u = rand([n 1]);
   Fa = 1 - exp(-(a/lambda)^k);
   Fb = 1 - exp(-(b/lambda)^k);
   y = (Fb-Fa)*u+Fa;
   xtr = lambda*nthroot(-log(1-y),k);
   powerstr = P(xtr)*(Fb-Fa);
end
