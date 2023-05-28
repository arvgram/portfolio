load powercurve_V164.mat
%%
N = 1000;
alpha = 0.05;
constants = [10.6 9.7 9.2 8.0 7.8 8.1 7.8 8.1 9.1 9.9 10.6 10.6; 2 2 2 1.9 1.9 1.9 1.9 1.9 2 1.9 2 2]';
month_names = ["Jan", "Feb", "Mar", "Apr","May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]';
nbr_months = length(constants(:,1));


%%
mean_values_standard = zeros(nbr_months,1);
variance_standard = zeros(nbr_months,1);
for month = 1:nbr_months
    lambda = constants(month,1);
    k = constants (month,2);
    X = wblrnd(lambda, k, N,1);
    mean_values_standard(month) = mean(P(X));
    variance_standard(month) = var(P(X));
end

standard_conf_int = [mean_values_standard+norminv(alpha)/sqrt(N)*sqrt(variance_standard), mean_values_standard-norminv(alpha)/sqrt(N)*sqrt(variance_standard)];

disp("Mean value of " + month_names +": " + mean_values_standard./1e6 + " MW")
disp("Variance for " + month_names +": " + variance_standard./1e12 + " *10^12")

disp( ((1-alpha)*100) + "% confidence interval for standard on " + month_names +": [" + standard_conf_int(:,1)./1e6 + " , " + standard_conf_int(:,2)./1e6 + "] MW")

%% optional ws cleaning cell
clear X k lambda 
%% when truncated sampling
a = 3.5;
b = 25;

mean_values_truncated = zeros(nbr_months,1);
variance_truncated = zeros(nbr_months,1);
for month = 1:nbr_months
    lambda = constants(month,1);
    k = constants (month,2);
    U = rand(N,1);

    argument = (wblcdf(b,lambda,k)-wblcdf(a,lambda,k))*U + wblcdf(a,lambda,k);
    X = wblinv(argument, lambda, k);
    
    mean_values_truncated(month) = mean(P(X)*(wblcdf(b,lambda,k)-wblcdf(a,lambda,k)));
    variance_truncated(month) = var(P(X)*(wblcdf(b,lambda,k)-wblcdf(a,lambda,k)));
end

means = mean_values_truncated;
variance = variance_truncated;

conf_int = [means+norminv(alpha)/sqrt(N)*sqrt(variance), means-norminv(alpha)/sqrt(N)*sqrt(variance)];

disp("Mean value of " + month_names +": " + means./1e6 + " MW")
disp("Variance for " + month_names +": " + variance./1e12 + " *10^12")

disp( ((1-alpha)*100) + "% confidence interval for " + month_names +": [" + conf_int(:,1)./1e6 + " , " + conf_int(:,2)./1e6 + "] MW")

disp("Variance reduction using truncated: " + ((variance_standard-variance_truncated)./variance_standard*100) + " %")
%% optional ws cleaning cell
clear a b argument U X lambda k;
%% With control variate:
mean_values_cv = zeros(nbr_months,1);
variance_cv = zeros(nbr_months,1);

for month = 1:nbr_months
    lambda = constants(month,1);
    k = constants(month,2);  
    
    Y = wblrnd(lambda, k, N,1);
    X = P(Y);
    
    m = lambda*gamma(1+1/k);
    sig2 = lambda^2*gamma(1+2/k) - m^2;
    
    covXY = cov(X,Y);
    beta = -covXY(1,2)/sig2;
    Z = X + beta*(Y-m);

    mean_values_cv(month) = mean(Z);
    variance_cv(month) = var(Z);
end

means = mean_values_cv;
variance = variance_cv;

conf_int = [means+norminv(alpha)/sqrt(N)*sqrt(variance), means-norminv(alpha)/sqrt(N)*sqrt(variance)];

disp("Mean value of " + month_names +": " + means./1e6 + " MW")
disp("Variance for " + month_names +": " + variance./1e12 + " *10^12")

disp( ((1-alpha)*100) + "% confidence interval for " + month_names +": [" + conf_int(:,1)./1e6 + " , " + conf_int(:,2)./1e6 + "] MW")

disp("Variance reduction for "+month_names + " using control variate: " + ((variance_standard-variance)./variance_standard*100) + " %")

%%
clear covXY Z Y X sig2 m beta
%% Importance sampling 
% idea: draw from a distribution g where g(x) = 0 => f(x)*phi(x) = 0 but
% which is more dense in important area, and compensate for sampling from
% the wrong distribution with omega = f(x)/g(x) 

% find good instrumental density g: we want to flatten the function f*phi
f = figure;
f.Position = [100 100 700 300];

v = linspace(0,27);
for month = 1:nbr_months
    lambda = constants(month,1);
    k = constants(month,2);  
    plot(v, wblpdf(v,lambda,k).*P(v)')
    hold on
end

title("P(v)f(v)")
legend(month_names)
filename = "powerperwindallmonths";
path_prefix = "figs/";
path = path_prefix + filename + ".png";
saveas(gcf,path)

powerperwind = wblpdf(v,constants(12,1),constants(12,2)).*P(v)';

%% finding good instrumental:
%instrumental = @(v) normpdf(v,12,sqrt(estsig2));
%pd = makedist("Normal","mu",12,"sigma",sqrt(estsig2));

pd = makedist('Weibull','A',14,'B',3);
tpd = truncate(pd,3.5,25);

instrumental = @(v) pdf(tpd,v);

amplifier = max(powerperwind)/max(instrumental(v));


f = figure;
f.Position = [100 100 700 300];
plot(v, amplifier*instrumental(v),"LineWidth",1)
legends = strings(nbr_months+1,1);
legends(1) = "instrumental g(v)";

for month = 1:nbr_months
    hold on
    lambda = constants(month,1);
    k = constants(month,2);     
    plot(v, wblpdf(v,lambda,k).*P(v)')
    
    legends(month+1) = "P(v)f(v) for " + month_names(month);
end

title("Fitting a good instrumental distribution")
legend(legends);


filename = "Instrumental_density_fit";
path_prefix = "figs/";
path = path_prefix + filename + ".png";
saveas(gcf,path)

%% Examining the flattening effect
f = figure;
f.Position = [100 100 700 300];
for month = 1:nbr_months
    hold on
    lambda = constants(month,1);
    k = constants(month,2);
    
    flattened = wblpdf(v,lambda,k).*P(v)'./(instrumental(v)); 
    flattened(isnan(flattened)) = 0;
    plot(v,flattened)
    
end

title("The (hopefully) flattened resulting distribution P(v)f(v)/g(v)")
legend(month_names);

filename = "flattening";
path_prefix = "figs/";
path = path_prefix + filename + ".png";
saveas(gcf,path)
%% ws cleaning 
clear path path_prefix f filename amplifier meanfp varfp v flattened powerperwind legends

%% Using importance sampling from instrumental mean_values_is = zeros(nbr_months,1);
variance_is = zeros(nbr_months,1);
mean_values_is = zeros(nbr_months,1);

for month = 1:nbr_months
    lambda = constants(month,1);
    k = constants(month,2);  
    
    omega = @(x) wblpdf(x,lambda, k)./instrumental(x);
    X = random(tpd,N,1);
    is_samples = P(X).*omega(X);

    mean_values_is(month) = mean(is_samples);
    variance_is(month) = var(is_samples);
end

means = mean_values_is;
variance = variance_is;

conf_int = [means+norminv(alpha)/sqrt(N)*sqrt(variance), means-norminv(alpha)/sqrt(N)*sqrt(variance)];

disp("Mean value of " + month_names +": " + means./1e6 + " MW")
disp("Variance for " + month_names +": " + variance./1e12 + " *10^12")

disp( ((1-alpha)*100) + "% confidence interval for " + month_names +": [" + conf_int(:,1)./1e6 + " , " + conf_int(:,2)./1e6 + "] MW")

disp("Variance reduction for " + month_names + " using importance sampling: " + ((variance_standard-variance)./variance_standard*100) + " %")

%% ws clean
clear k lambda omega X is_samples pd tpd 

%% Antithetic sampling
% idea: use a variable that is negatively correlated with our variable but
% has same mean and variance and use average of these to reduce variance.
% Since the power function is monotone, we can use Lemma from lecture 4.

mean_values_at = zeros(nbr_months,1);
variance_at = zeros(nbr_months,1);

for month = 1:nbr_months
    lambda = constants(month,1);
    k = constants(month,2);  
    
    U = rand(N,1);
    T_U = 1-U;

    V = P(wblinv(U,lambda,k));
    V_tilde = P(wblinv(T_U,lambda,k));
    W = (V+V_tilde)./2;

    mean_values_at(month) = mean(W);
    variance_at(month) = var(W);
end

means = mean_values_at;
variance = variance_at;

conf_int = [means+norminv(alpha)/sqrt(N)*sqrt(variance), means-norminv(alpha)/sqrt(N)*sqrt(variance)];

disp("Mean value of " + month_names +": " + means./1e6 + " MW")
disp("Variance for " + month_names +": " + variance./1e12 + " *10^12")

disp( ((1-alpha)*100) + "% confidence interval for " + month_names +": [" + conf_int(:,1)./1e6 + " , " + conf_int(:,2)./1e6 + "] MW")

disp("Variance reduction for " + month_names + " using antithetic sampling: " + ((variance_standard-variance)./variance_standard*100) + " %")
%% cleaning 
clear V V_tilde W lambda k U T_U conf_int means
%% Probability that the turbine outputs power: 
zeroidx = zeros(nbr_months,N);

for month = 1:nbr_months
    lambda = constants(month,1);
    k = constants(month,2);
    zeroidx(month,:) = P(wblrnd(lambda, k, N,1)) == 0;
end

probability = 1-mean(zeroidx,2);
disp("Probability of no power output in " + month_names + ": " + probability)
 
%% Scatter plotting theoretical vs estimated 
theoretical = [0.8929, 0.8741, 0.8646, 0.8121, 0.8039, 0.8160, 0.8039, 0.8160, 0.8620, 0.8675, 0.8929, 0.8929]';
scatter(theoretical, probability, 35, "red","filled")
title("Scatter plot of theoretical and estimated values")
xlabel("Theoretical probability of zero power output")
ylabel("Estimated probability of zero power output")

filename = "correlation_theo_est";
path_prefix = "figs/";
path = path_prefix + filename + ".png";
saveas(gcf,path)
%% optional ws cleaning cell
clear theoretical filename path_prefix path probability zeroidx lambda k 
%%
standard = cumsum(powers)'./(1:N)';
trunc = cumsum(trunc_powers)./(1:N)';
cv = cumsum(Z)./(1:N)';
is = cumsum(is_samples)./(1:N)';
at = cumsum(W)./(1:N)';

%% plotting the different methods convergence
f = figure;
f.Position = [100 100 700 300];

from = 10;
to = 1000;

plot((from:to),standard(from:to))
hold on
plot((from:to),trunc(from:to))
hold on
plot((from:to),cv(from:to))
hold on
plot((from:to),is(from:to))
hold on
plot((from:to),at(from:to))
title("Convergence of estimated values for different methods")
xlabel("Number of samples")
ylabel("Estimated value")
legend(["standard", "truncated", "control variate", "importance sampling", "antithetic"])

filename = "convergence";
path_prefix = "figs/";
path = path_prefix + filename + ".png";
saveas(gcf,path)

%%
clear
load powercurve_V164.mat;
N = 1000;
month_names = ["Jan", "Feb", "Mar", "Apr","May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]';
nbr_months = length(constants(:,1));
%% Multivariate 

k = 1.96; lambda = 9.13; alpha = 0.638; p = 3; q = 1.5;

Fv = @(v) wblcdf(v,lambda,k);
fv = @(v) wblpdf(v,lambda,k);

pdf2d = @(v1,v2) fv(v1).*fv(v2).*(1 + alpha.*(1-Fv(v1).^p).^(q-1).* ...
    (1-Fv(v2).^p).^(q-1).*(Fv(v1).^p.*(1+p*q)-1).*(Fv(v2).^(p).*(1+p*q)-1));

%% The expected amount of combined power from two turbines
% This reduces to the one dimensional problem:

pd = makedist('Weibull','A',14,'B',3);
tpd = truncate(pd,3.5,25);
instrumental = @(v) pdf(tpd,v);

omega = @(x) wblpdf(x,lambda, k)./instrumental(x);

X = random(tpd,N,1);
is_samples = P(X).*omega(X);

disp("The estimated combined value of two turbines, with k: " + k + " " + ...
    "and lambda: " + lambda + " is: " + (2*mean(is_samples)/1e6) + " MW")

%% Covariance of two turbines with dependent winds:
% To perform importance sampling we must first find a suitable instrumental
% distribution in two dimensions. We are interested in finding the expected
% value of the product P(V_1)P(V_2), in order to calculate the covariance
% as E[P(V_1)P(V_2)]-E[P(V_1)]E[P(V_2)]

x1 = linspace(0,29,30);
x2 = linspace(0,29,30);
powers = zeros(30,30);

for i = 1:30
    for j = 1:30
        powers(i,j) = (P(i)*P(j))*pdf2d(i,j);
    end
end

surf(x1,x2,powers)
xlabel("Windspeed 1")
ylabel("Windspeed 2")

%% Suitable instrumental
% We take the twodimensional normal distribution as our instrumental, with
% parameters as found below. We plot phi(X)f(X)/g(X) to examine the
% "flatness". 
mu = 11;
sig11 = 21;
sig12 = 6;
sig22 = 21;

x1 = linspace(0,29,30);
x2 = linspace(0,29,30);
phi_f = zeros(30,30);

for i = 1:30
    for j = 1:30
        phi_f(i,j) = (P(i)*P(j))*pdf2d(i,j)/mvnpdf([i j], [mu mu], [sig11 ...
            sig12 ; sig12 sig22]); 
    end
end

surf(x1,x2,phi_f)
xlabel("Windspeed 1")
ylabel("Windspeed 2")

%% Calculating the covariance of two turbines with dependent winds
% We proceed with the found instrumental distribution:

X = mvnrnd([mu mu], [sig11 sig12; sig12 sig22],N);

omega2d = @(v1,v2) pdf2d(v1,v2)./mvnpdf([v1 v2], [mu mu], [sig11 sig12 ; sig12 sig22]);

is_product = P(X(:,1)).*P(X(:,2)).*omega2d(X(:,1),X(:,2));
is_productmean = mean(is_product);

%% We use this result together with the one dimensional findings from 2c)

X1 = random(tpd,N,1);
is_1 = (P(X1)).*omega(X1);
is_mean1 = mean(is_1);

X2 = random(tpd,N,1);
is_2 = (P(X2)).*omega(X2);
is_mean2 = mean(is_2);

cov = is_productmean - is_mean1*is_mean2;

disp("The covariance of the output of the output of two turbines with " + ...
    "dependent winds is " + cov/1e12 + " 10^12")

%% Variance of total output of two turbines
% For the variance of the sum of output we need 
% V[P(V_1)] = E[P^2(V_1)] - E^2[P(V_1)], meaning that we further need to
% calculate the expected value of the squared output. To use importance
% sampling in this case we use another instrumental distribution, more
% suitable for the squared power.

pdsq = makedist('Weibull','A',15,'B',4);
tpdsq = truncate(pdsq,3.5,25);
instrumentalsq = @(v) pdf(tpdsq,v);

omegasq = @(x) wblpdf(x,lambda, k)./instrumentalsq(x);

X_1 = random(tpdsq,N,1);
is_sqmean1 = mean((P(X_1)).^2.*omegasq(X_1));

X_2 = random(tpdsq,N,1);
is_sqmean2 = mean((P(X_2)).^2.*omegasq(X_2));

%V[P(V_1)] = E[P^2(V_1)] - E^2[P(V_1)]:

var1 = is_sqmean1 - is_mean1^2;
var2 = is_sqmean2 - is_mean2^2;
sumvar = var1 + var2 + 2*cov;
stdv = sqrt(sumvar);

%% Probability of total power is less than 9.5 MW? More than 9.5 MW?
% Since the turbines have a high probability of producing exactly 9.5 (for
% all winds in [14,25], and 0 for winds > 25 m/s, there should be a non
% zero probability that it sums to 9.5. This would be for all windpairs
% [v_1, v_2] where v_1 is in [14,25] and v_2 > 25.

% we sample like previously:
X = mvnrnd([mu mu], [sig11 sig12; sig12 sig22],N);
powers = P(X(:,1)) + P(X(:,2));

greaterthan = powers > 9.5e6;
lessthan = powers < 9.5e6;

% we use the importance weights to add importance to winds that are
% "neglegted" by our intstrumental disitribution, compared to the real:
probsgr = greaterthan.*omega2d(X(:,1),X(:,2));
probsless = lessthan.*omega2d(X(:,1),X(:,2));


meangr = mean(probsgr);
vargr = var(probsgr);
CIgr = [meangr+norminv(alpha/2)*sqrt(vargr)/sqrt(N) meangr+norminv(1-alpha/2)*sqrt(vargr)/sqrt(N)];
meanls = mean(probsless);
varls = var(probsless);
CIls = [meanls+norminv(alpha/2)*sqrt(varls)/sqrt(N) meanls+norminv(1-alpha/2)*sqrt(varls)/sqrt(N)];

disp("Expected value of probablity of combined output less than 9.5 MW: " + meanls)
disp("Expected value of probablity of combined output greater than 9.5 MW: " + meangr)

disp( ((1-alpha)*100) + "% confidence interval for probability" + ...
    "of combined output less than 9.5 MW [" + CIls(:,1) + " , " + CIls(:,2) + "]")

disp( ((1-alpha)*100) + "% confidence interval for probability" + ...
    "of combined output greater than 9.5 MW [" + CIgr(:,1) + " , " + CIgr(:,2) + "]")
