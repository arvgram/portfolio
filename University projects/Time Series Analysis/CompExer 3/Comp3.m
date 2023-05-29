clear; close all; clc
load tar2.dat
load thx.dat
%%
figure
subplot(211)
plot(tar2)
subplot(212)
plot(thx)
%%
lambda = 0.99;
X = recursiveAR(2);
X.ForgettingFactor = lambda;
X.InitialA = [1 0 0];
for kk = 1:length(tar2)
    [Aest(kk,:), yhat(kk)] = step(X, tar2(kk));
end

figure
subplot(211)
plot(thx)
subplot(212)
plot(Aest(:,2:end))
% A higher lambda makes the model forget more, thus taking recent values in
% to account more


%%
n = 100;
lambdas = linspace(0.85,1,n);
ls2 = zeros(n,1);
yhat = zeros(n,1);

for i = 1:length(lambdas)
    reset(X);
    X.ForgettingFactor = lambdas(i);
    X.InitialA = [1 0 0];
    for kk = 1:length(tar2)
        [~, yhat(kk)] = step(X, tar2(kk));
    end
    ls2(i) = sum((tar2-yhat).^2);
end
plot(lambdas, ls2);

[minVal, minIndex] = min(ls2);
disp("Best value for lambda is " + lambdas(minIndex));
%%

% define the state space equations:
y = tar2;
N = length(y);
A = 1;
%[-1 -1 ;1 0];
Re = [0.004 0;0 0];
Rw = 1.25;

% Set some initial values
Rxx_1 = 10 * eye(2);
xt_t1 = [1,1]';

x = zeros(2,N);
x(:,3) = xt_t1;
% Vectors to store values in
Xsave = zeros(2,N);
ehat = zeros(1,N);
yt1 = zeros(1,N);
yt2 = zeros(1,N);

% The filter use data up to the time t-1 to predict value at t 
% then update using prediction error. We start at t=3 since first values
% are corrupted. We end at N-2 since

for t = 3:N-2
    Ct = [-y(t-1) -y(t-2)];         % C_{t|t-1}
    yhat(t) = Ct * xt_t1;           % y_{t|t-1}
    ehat(t) = y(t)-yhat(t);         % e_t = y_t - y_{t|t-1}

    % Update
    Ryy = Ct * Rxx_1 * Ct' + Rw;    % R^{yy}_{t|t-1}
    Kt = Rxx_1 * Ct'/Ryy;           % K_t kalman gain
    xt_t = xt_t1 + Kt*ehat(t); % x_{t|t}
    Rxx = Rxx_1 - Kt*Ryy*Kt';       % R^{xx}_{t|t}

    % next state
    xt_t1= A * xt_t;                % x_{t+1|t}
    Rxx_1 = A * Rxx * A' + Re;           % R^{xx}_{t+1|1}
   
    % form a 2-step predicition
    Ct1 = [-y(t) -y(t-1)];
    yt1(t+1) = Ct1 * xt_t1;
    Ct2 = [-yt1(t+1) -yt1(t)];
    yt2(t+2) = Ct2*xt_t1;

    % save
    Xsave (:,t) = xt_t ;



end


%%
plot(Xsave(:,3:N-2)')
hold on
plot(thx)

%% simulated data 
clear;
rng ( 0 ) ;
N = 10000;
ee = 0.1*randn(N,1);
A0 = [1 -.8 .2] ;
y = filter(1 , A0,ee);
Re = [1e-6 0; 0 1e-6];
Rw = .1 ;
%%
% define the state space equations:
N = length(y);
A = 1;
%[-1 -1 ;1 0];
Re = [0.004 0;0 0];
Rw = 1.25;

% Set some initial values
Rxx_1 = 10 * eye(2);
xt_t1 = [1,1]';

x = zeros(2,N);
x(:,3) = xt_t1;
% Vectors to store values in
Xsave = zeros(2,N);
ehat = zeros(1,N);
yt1 = zeros(1,N);
yt2 = zeros(1,N);

% The filter use data up to the time t-1 to predict value at t 
% then update using prediction error. We start at t=3 since first values
% are corrupted. We end at N-2 since

for t = 3:N-2
    Ct = [-y(t-1) -y(t-2)];         % C_{t|t-1}
    yhat(t) = Ct * xt_t1;           % y_{t|t-1}
    ehat(t) = y(t)-yhat(t);         % e_t = y_t - y_{t|t-1}

    % Update
    Ryy = Ct * Rxx_1 * Ct' + Rw;    % R^{yy}_{t|t-1}
    Kt = Rxx_1 * Ct'/Ryy;           % K_t kalman gain
    xt_t = xt_t1 + Kt*ehat(t); % x_{t|t}
    Rxx = Rxx_1 - Kt*Ryy*Kt';       % R^{xx}_{t|t}

    % next state
    xt_t1= A * xt_t;                % x_{t+1|t}
    Rxx_1 = A * Rxx * A' + Re;           % R^{xx}_{t+1|1}
   
    % form a 2-step predicition
    Ct1 = [-y(t) -y(t-1)];
    yt1(t+1) = Ct1 * xt_t1;
    Ct2 = [-yt1(t+1) -yt1(t)];
    yt2(t+2) = Ct2*xt_t1;

    % save
    Xsave (:,t) = xt_t ;
end


%% lets see how our prediction holds up
plot( y(end-100-2:end-2) )
hold on
plot( yt1(end-100-1:end-1),'g' )
plot( yt2(end-100:end),'r')
hold off
legend ( 'y ' , ' k=1 ' , ' k=2 ' )

%% lets see how our estimation of parameters hold upå
plot([-.8*ones(length(Xsave),1) .2*ones(length(Xsave),1)])
hold on
plot(Xsave(:,1:end-2)')
title('Estimated Parameters and Real Parameters')
legend(["$a_1$","$a_2$","$\hat{a}_1$", "$\hat{a}_2$"],'Interpreter','latex')
ylim([-2 2])

%% New Markovian data
clear;
N = 100;
P = [7/8 1/8; 1/8 7/8];
mc = dtmc(P);
u = simulate(mc,N);
subplot(211);
graphplot(mc,'ColorEdges',true);
title("Process Viz")
subplot(212)
plot(u)
title("Realisation")
%%
P = [7 1; 1 7]./8;

for i = 1:100
    randi(2)-1;
end

%% Markovian data
clear
rng(1)
N = 1000;
P = [7/8 1/8; 1/8 7/8];
mc = dtmc(P);
u = simulate(mc,N-1);
b = 20;
sige2 = 1;
sigv2 = 4;

e = sige2*randn(N,1);
v = sigv2*randn(N,1);
A = [1 -1];

x = filter(1,A,e);
y = x + b*u+v; 

plot(y);
hold on
plot(b*u)

%%

% define the state space equations:
N = length(y);
A = eye(2);
%[-1 -1 ;1 0];
Re = [10 0; 0 0];
Rw = 1.25;

% Set some initial values
Rxx_1 = 10;
xt_t1 = [1 1]';

%x = zeros(2,N);
%x(:,3) = xt_t1;

% Vectors to store values in
Xsave = zeros(2,N);
ehat = zeros(1,N);
yt1 = zeros(1,N);
yt2 = zeros(1,N);

bestRe = NaN;
bestError = inf;
% The filter use data up to the time t-1 to predict value at t 
% then update using prediction error. We start at t=3 since first values
% are corrupted. We end at N-2 since
%for Re = [10 0; 0 0] %0.01 0.05 0.1 0.5 1 2 4 8]
    for t = 3:N-2
        Ct = [1 u(t)];              % C_{t|t-1} 
        yhat(t) = Ct * xt_t1 ;    % y_{t|t-1}
        ehat(t) = y(t)-yhat(t);             % e_t = y_t - y_{t|t-1}
    
        % Update
        Ryy = Ct * Rxx_1 * Ct' + Rw;    % R^{yy}_{t|t-1}
        Kt = Rxx_1 * Ct'/Ryy;           % K_t kalman gain
        xt_t = xt_t1 + Kt*ehat(t); % x_{t|t}
        Rxx = Rxx_1 - Kt*Ryy*Kt';       % R^{xx}_{t|t}
    
        % next state
        xt_t1= A * xt_t;                % x_{t+1|t}
        Rxx_1 = A * Rxx * A' + Re;           % R^{xx}_{t+1|1}
       
        % save
        Xsave (:,t) = xt_t ;
    end
    error = norm(Xsave(2,:)-b);
%    if(error < bestError)
%        bestRe = Re;
%        bestError = error;
%    end    
%end
%disp("Best error was obtained using Re = " + bestRe + " with error= " + bestError)
%%
plot(Xsave','b')
hold on
plot(b*ones(length(Xsave(1,:))),'g--');
plot(x,'g')
legend(["Estimate of b", "Estimate of x", "True b", "True x"])

%%
clear; clc;
load svedala94.mat
%%
T = linspace(datenum(1994,1,1),datenum(1994,12,31),length(svedala94));
plot(T, svedala94); datetick('x');
%%
sDiff = [1 zeros(1,5) -1];
ydiff = filter(sDiff,1,svedala94);
plot(T,ydiff); datetick('x');
%%
th = armax (ydiff,[2 2]);

th_winter = armax(ydiff(1:540),[2 2]); 
th_summer = armax(ydiff(907:1458),[2 2]);

%disp("Winter parameters: " + th_winter.A + "MA: " + th_winter.C);
%disp("All year round parameters: " + th.A + "MA: " + th.C);
%%
p = 2;
q = 2;
Aest = zeros(length(ydiff),p+1);
Cest = zeros(length(ydiff),q+1);


X = recursiveARMA([p q]);
X.InitialA = [1 th_winter.A(2:end)];
X.InitialC = [1 th_winter.C(2:end)];
X.ForgettingFactor = 0.991;
for k = 1:length(ydiff)
    [Aest(k,:), Cest(k,:), yhat(k)] = step(X,ydiff(k));
end
%%
figure(1)
plot(T,Aest (: ,2:3))
hold on
plot(T,repmat(th_winter.A(2:end),[length(ydiff) 1]),'g--');
plot(T,repmat(th_summer.A(2:end),[length(ydiff) 1]),'r--');
datetick('x')
legend(["Recursive A1 estimate", "Recursive A2 estimate", "Winter A1", "Winter A2", "Summer A1", "Summer A2"])
axis tight
title("AR A parameters")
hold off

%%
figure(2)
plot(T,Cest (: ,2:3))
hold on
plot(T,repmat(th_winter.C(2:end),[length(ydiff) 1]),'g--');
plot(T,repmat(th_summer.C(2:end),[length(ydiff) 1]),'r--');
datetick('x')
title("MA C parameters")
axis tight
legend(["Recursive estimation", "Winter estimate", "Summer estimate"])
hold off

%% Recursive svedala
clear
load svedala94;
y = svedala94(850:1100);
%%
t = (1:length(y))';

U = [sin(2*pi*t/6) cos(2*pi*t/6)] ;
Z = iddata(y,U);
model = [3 [1 1] 4 [0 0]]; 
%[na[nb_1 nb_2] nc [nk_1 nk_2]];

thx = armax(Z,model);

plot(y-mean(y));
hold on
plot(U*cell2mat(thx.b)');

y = y-mean(y);
%%
U = [sin(2*pi*t/6) cos(2*pi*t/6) ones(size(t))];

Z = iddata(y,U);
m0=[thx.A(2:end) cell2mat(thx.B) 0 thx.C(2:end)]; 

Re=diag([0 0 0 0 0 1 0 0 0 0] ) ;

model=[3 [1 1 1] 4 0 [0 0 0] [1 1 1 ] ] ;

[thr,yhat]=rpem(Z,model,'kf',Re,m0);

%%
plot(y)
hold on 
plot(yhat)

legend(["True", "Predicted"])

%%
m = thr(:,6);
a = thr(end,4);
b = thr (end,5);

y_mean = m + a*U(:,1)+ b*U(:,2); 
y_mean = [0;y_mean(1:end-1)];

plot(y_mean)
hold on
plot(y)

