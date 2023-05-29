clear
load atlantic.txt
%% Gumbel
T = 3*14*100;
B = 1000; 
[beta, mu] = est_gumbel(atlantic);
sample = mu - beta*log(-log(rand(B,T)));

%
estimates = zeros(B,2);
for i = 1:B
    [beta_hat,mu_hat] = est_gumbel(sample(i,:));
    estimates(i,1) = beta_hat;
    estimates(i,2) = mu_hat;
end

% confidence intervals
delta = sort(estimates-[beta,mu]);
alpha = 0.05;
L = [beta, mu]-delta(ceil((1-alpha/2) * B));
U = [beta, mu]-delta(ceil(alpha * B/2));

% Upper bounded 95% confidence for 100-year return value
hundred_year_returns = sort(max(sample,[],2));
upper_bound = hundred_year_returns(ceil((1-alpha)*B))




