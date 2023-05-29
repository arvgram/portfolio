%% First approach, sample large N random walks and see which ones are SAW
N = 1e4;
d = 2;
n = 20;
nbr_saw = 0;
A = zeros(n+1,2);
nbr_possible_walks = (2*d)^n;

for i = 1:N
    % we draw the steps, 1 => +x, 2 = +y, 3 => -x, 4 => -y
    steps = unidrnd(4,n,1);

    posx = steps == 1; posy = steps == 2; 
    negx = steps == 3; negy = steps == 4; 
    
    A(2:end,:) = [cumsum(posx - negx), cumsum(posy - negy)];
    self_avoiding = length(A) == length(unique(A,"rows"));
    
    if (self_avoiding)
        nbr_saw = nbr_saw + 1;
    end
end

est = nbr_saw*nbr_possible_walks/N;
var = est*((2*d)^n-est)/N;
CI = [(est-1.96*sqrt(var))/1E6 (est+1.96*sqrt(var))/1E6];

disp("c_" + n +"(" + d + ") is approximately: " + est)
disp("N_SA/N is: " + nbr_saw/N)
disp("Confidence interval: " + CI(1) + ", " + CI(2))


%% clean
clear A i nbr_saw negx negy posx posy self_avoiding steps
%% Refined approach 

% idea: Only visit free positions. 
% Take one step at the time with every particle before next step

%   for every time step
%       for all particles
%           get position
%           identify vacant adjacent positions
%           draw uniformly the next position from the vacant positions
%           save where you have been in X
%
N = 100;
n = 6;
d = 2;
X = zeros(n+1, d, N);
steps = [eye(d); -eye(d)];


weights = zeros(n+1,N);
weights(1,:) = 1;

for k = 1:n
    for i = 1:N
        memory = X(1:k, :, i);
        current_position = X(k,:,i);
        FN = setdiff(current_position+steps,memory,"rows");
        nbr_available = size(FN,1);
        weights(k+1,i) = weights(k,i)*nbr_available;

        if(nbr_available == 0)
            nextpositions = current_position;
        else 
        nextpositions = FN(randi(nbr_available,1),:);
        end

        X(k+1,:,i) = nextpositions;
    end
end


mean(weights,2)


%% SISR
% idea: take one step at the time with every particle

% allocate memory for weights, one row for each timestep, one column for
% each particle. 
% the weight for each particle is the product of the number of free
% neighbours with the previous weight
% then:
%   for all time steps
%       for every particle
%           get position
%           identify vacant adjacent positions
%           the weights are mulitplied with the number of vacancies
%           (draw new particles with respect to these weights)
%           draw uniformly the next position from the vacant positions
%           save where you have been in X
%       
N = 100;
n = 10;
d = 2;
X = zeros(n+1, d, N);
steps = [eye(d); -eye(d)];

weights = zeros(n+1,N);
weights(1,:) = 1;
available = zeros(1,N);
for k = 1:n
    for i = 1:N
        memory = X(1:k, :, i);
        current_position = X(k,:,i);
        FN = setdiff(current_position+steps,memory,"rows");
        nbr_available = size(FN,1);
        available(i) = nbr_available; 
        if(nbr_available == 0)
            nextposition = current_position;
        else 
        nextpositions = FN(randi(nbr_available,1),:);
        end

        weights(k+1,i) = weights(k,i)*nbr_available;
        X(k+1,:,i) = nextpositions;
    end

    drawn_ind = randsample(N,N,true,weights(k+1,:));
    X(1:k+1,:,:) = X(1:k+1,:,drawn_ind);

    weights(k+1,:) = mean(weights(k+1,:)); 
end


cn = mean(weights,2);
m = linspace(1,n,n);

X = [ones(n,1) log(m)' m'];
Y = log(cn(2:end));

[B, BINT] = regress(Y,X);

A = exp(B(1))
gamma = B(2)+1
mu = exp(B(3))


%% 10. Relative population size
load population_2023

N = 1000; n = 50;
A = 0.9; B = 3.9; C = 0.6; D = 0.99;
G = 0.7; H = 1.2;

greaterthan = zeros(1,n+1); % vector for observations greater than the upper CI
smallerthan = zeros(1,n+1); % for lower CI

tau = zeros(1,n+1); % vector of filter means
w = zeros(N,1);
p = @(y,x) unifpdf(y,G*x,H*x); % observation density, for weights
part = C+(D-C)*rand(N,1); % initialization
w = p(Y(1),part); % weighting
tau(1) = sum(part.*w)/sum(w); % estimation
[xx,I]=sort(part); % sort data
cw=cumsum(w(I))/sum(w); % cumulative normalized weightsum
Ilower=find(cw>=0.025,1); % index for lower 2.5% quantile
Iupper=find(cw>=0.975,1); % index upper 2.5% quantile
taulower(1)=xx(Ilower); % lower 2.5% quantile
tauupper(1)=xx(Iupper); % upper 2.5% quantile
greaterthan(1) = X(1) > tauupper(1);
smallerthan(1) = X(1) < taulower(1);
ind = randsample(N,N,true,w); % selection
part = part(ind);

for k = 1:n % main loop
    part = (A+(B-A)*rand(N,1)).*part.*(1-part); % mutation
    w = p(Y(k+1),part); % weighting
    tau(k + 1) = sum(part.*w)/sum(w); % estimation
    [xx,I]=sort(part); % sort data
    cw=cumsum(w(I))/sum(w); % cumulative normalized weightsum
    % for sorted data
    Ilower=find(cw>=0.025,1); % index for lower 2.5% quantile
    Iupper=find(cw>=0.975,1); % index upper 2.5% quantile
    taulower(k+1)=xx(Ilower); % lower 2.5% quantile
    tauupper(k+1)=xx(Iupper); % upper 2.5% quantile
    greaterthan(k+1) = X(k+1) > tauupper(k+1);
    smallerthan(k+1) = X(k+1) < taulower(k+1);
    ind = randsample(N,N,true,w); % selection
    part = part(ind);
end

%% Estimate vs actual
plot(tau,'r')
hold on
plot(X,'b')
title('Relative population size, estimated and actual')
xlabel('Generation')
ylabel('Relative population size')
legend({'Estimate','True value'})
hold off

%% Confidence interval
plot(tau,'r')
hold on
plot(X,'b')
plot(taulower,'--g')
plot(tauupper,'--g')
title('Relative population size, estimated and actual with CI')
xlabel('Generation')
ylabel('Relative population size')
legend({'Estimate','True value','Confidence interval bounds'})
hold off

sum(greaterthan)
sum(smallerthan)








