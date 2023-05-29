clear;
close all;
load coal_mine_disasters

start_year = 1658;
end_year = 1980;
years = round(linspace(start_year,end_year,(end_year-start_year)));

% marking accidents per year
y = zeros(length(years),1);
for i = 1:length(years)
    for j = 1:length(T)
        if years(i)-1 < T(j) && T(j) < years(i)+1
            y(i) = y(i)+1;
        end
    end
end

f = figure();
f.Position = [100 100 600 400];
newcolors = ["#0072BD","#D95319","#77AC30"];
colororder(newcolors);
y(y == 0) = nan;

N = 1e5;
burnin = 0.2*N;
%psi = 2;
psis = [0.1, 2, 5, 10]; % if we want to vary rho
d = 3;
% d = [2,3,4,5]
rho = 1;
%rhos = [0.5 1 3 10]; % if we want to vary rho

for index = 1:4
    % below is the actual MC-steps:
    psi = psis(index);
    %rho = rhos(index);
    theta = zeros(N,1);
    lambda = zeros(N,d);
    t = zeros(N,d+1);
    [theta(1), lambda(1,:), t(1,:)] = get_priors(d,psi);
    
    for k = 2:N
        [temp1, temp2, temp3] = get_posteriors(rho,lambda(k-1,:),t(k-1,:),T,d,psi);
        theta(k) = temp1;
        lambda(k,:) = temp2;
        t(k,:) = temp3;
    end

    % average after burnin
    lambda_f = mean(lambda(burnin:end, :));
    t_f = mean(t(burnin:end,:));
    
    % marking breakpoints and lambdas
    breakpoints = nan(length(years),1);
    breakpoint_counter = 1;
    L = zeros(length(years),1);
    for i = 1:length(years)
        if years(i)-1 < t_f(breakpoint_counter) && t_f(breakpoint_counter) < years(i)+1
            breakpoints(i) = 0;
            breakpoint_counter = min(d+1,breakpoint_counter + 1);
        end
        L(i) = lambda_f(breakpoint_counter-1);
    end

% Uncomment paragraph below to plot convergence of different lambdas:
% 
%     subplot(2,2,index)
%     start = 0.5*length(lambda);
%     stop = start+1000;
%     range = start:stop;
%     plot(range,lambda(range,3))
%     axis([start stop 0 inf])
%     title("\lambda_{"+ 3 + "} with \rho = " + rho)
%     subplot(2,2,index)
%     plot(cumsum(lambda)./(linspace(1,N,N)'))
%     legend(["\lambda_1","\lambda_2","\lambda_3"])
%     axis([0 N 0 6])
%     title("\rho = " + rho);
 
% Uncomment below to plot number of accidents, breakpoints and lambdas
% for different combinations of parameters:
    subplot(2,2,index)
    bar(years,y)
    ylabel("Number of accidents")
    xlabel("Year")
    hold on

    stem(years,breakpoints, 'filled')
    hold on
    yyaxis right
    plot(years,L,"LineWidth",1.5)
    axis([start_year end_year 0 6])
    ylabel("Estimated intensity")
    legend(["Accidents", "Break", "Lambda"],"Location","northwest")
    title("d = " + d + ", \Psi = " + psi + ", \rho = " + rho)
    yyaxis left
end

% change this title depending on context.
sgtitle("Variation of \psi with fix \rho = " + rho + " and d = " + d)

%%
% plotting different lambda trajectories, intended for d = 4.
figure()
sgtitle("Values of \lambda over N = " + N + " iterations (burnin: " + burnin + ")")

for sp = 1:d
    subplot(2,2,sp)
    start = 0;
    stop = 0.1;
    range = start*length(lambda):stop*length(lambda);
    plot(lambda(1:10000,sp))
    %axis([round(start*length(lambda)) stop*length(lambda) 0 inf])
    title("\lambda_{"+ sp + "}")
end


