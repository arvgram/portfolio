load coal_mine_disasters.mat
tau = T;
clear T
%% Hybrid sampling
% for a given number of breakpoints
% decide where these breakpoints are to be placed by drawing from a prior
% distribution for t ( = PI(t_i - t_0) ) 
% draw theta from Gamma as hyperprior
% draw lambdas for each d from Gamma(theta,2)

%%
N = length(tau);
d = 3;
psi = 2;
t = zeros(N+1,d+1);
t(:,1) = 1658; t(:,d+1) = 1980;
theta = zeros(N+1,1);
lambda = zeros(N+1,d);
%theta = @(x) gampdf(x,2,1/psi);
theta(1) = gamrnd(2,1/psi);
lambda(1,1:d) = gamrnd(2,1/theta(1),1,d);

u = 1; fxex = 0;
mu = (t(1,d+1)-t(1,1))/d*linspace(1,d-1,d-1)+t(1,1);

Sigma = (t(1,d+1)-t(1,1))*10*eye(d-1);
alpha = 1e-9;
gpdf = @(x) mvnpdf(x,mu,Sigma);

fpdf = @(T) (t(1,d+1)-T(d-1))*(T(d-2)-t(1,1));

while u > fxex
    g = mvnrnd(mu,Sigma,1);
    ex = gpdf(g)./alpha;
    fxex = fpdf(g)./ex;
    u = rand;
    t(1,2:d) = g;
end


%%
rho = 0.5;
for k = 2:N+1
    tstar = zeros(d-1,1);
    for i = 1:d-1
        R = rho*(t(k,i+1)-t(k,i-1));
        epsilon = 2*R*rand-R;
        tstar(i) = t(k,i)+epsilon;
        r = @(x,T,R) unifpdf(x,T-R,T+R);
        % f = posterior;
        % fr1 = f(tstar(i))*r(t(i),tstar(i),rho*(t(i+1)-t(i-1)));
        % fr2 = f(t(i))*r(tstar(i),t(i),rho*(tstar(i+1)-tstar(i-1)));
        % alpha = min(1, fr1/fr2);
        u = rand;
        if u <= alpha
            t(k+1,i) = tstar(i);
        else
            t(k+1,i) = t(k,i);
        end
    end
    
    % Gibbs
    % theta = sample from posterior;
    % lambda = vector sample from posterior;
end

%%
x1 = linspace(1658,1980,322);
x2 = linspace(1658,1980,322);
dens = zeros(322,322);

for i = 1:322
    for j = 1:322
        dens(i,j) = gpdf([x1(i);x2(j)]);
    end
end

surf(x1,x2,dens)


