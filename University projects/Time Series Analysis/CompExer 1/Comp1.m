%%
clear all
clc
A1 = [1 -1.79 0.84];
C1 = [1 -0.18 -0.11];

A2 = [1 -1.79];
C2 = [1 -0.18 -0.11];

arma1 = idpoly(A1, [], C1); arma2 = idpoly(A2, [], C2);

%%
rng(0);
N = 300;
extraN = 100;
sig2 = 1.5;

e = sqrt(sig2)*randn(N+extraN,1);

y1 = filter(arma1.c, arma1.a, e);
y2 = filter(arma2.c, arma2.a, e);

y1 = y1(extraN+1:end);
y2 = y2(extraN+1:end);

figure
subplot(211)
plot(y1)

subplot(212)
plot(y2)
%% THIS IS BROKEN (SIMULATEMYARMA)
figure
y1 = simulateMyARMA(arma1.a,arma1.c,300);
subplot(211)
plot(y1)
y2 = simulateMyARMA(arma2.a, arma2.c,300);
subplot(212)
plot(y2)

%%
figure
subplot(121)
pzmap(arma1)

subplot(122)
pzmap(arma2)

%%
m = 20;
sigma2 = 1.5;
r_theo = kovarians(arma1.c , arma1.a ,m); 
stem(0:m, r_theo*sigma2) 
hold on

r_est = covf(y1,m+1);

stem(0:m, r_est, 'r')
legend("Theroretical", "Estimated")

%%
r_theo2 = kovarians(arma2.c, arma2.a, m);
stem(0:m, r_theo2*sigma2)
hold on
rest = covf(y2, m+1);
stem(0:m, rest, 'r')
%% Q3

showProc(y1)

%%
data = iddata(y1);
%%
ar_model = arx(y1, 1);
arma_model = armax(y1, [3,1]);

%% Grid searching best model orders, p = i, q = j
sizex = 5;
sizey = 5;
FPEsARMA = 3*ones(sizex, sizey);
FPEsAR = 3*ones(sizex,1);
for i = 1:sizex
    for j = 1:sizey
        [deemedWhite, loop_arma_model] = testARMA(y1,i,j);
        if deemedWhite
            disp("The ARMA parameters [" + i + " , " + j + "] was deemed white")
            val = fpe(loop_arma_model);
            disp("FPE is " + val)
            FPEsARMA(i,j) = val;
        end
    end

    [deemedWhite, loop_ar_model] = testAR(y1,i);
    if deemedWhite
            disp("The AR parameter " + i + " was deemed white")
            val = fpe(loop_ar_model);
            disp("FPE is " + val)
            FPEsAR(i) = val;
    end
    
end

%%


%%
estimateARMA(y1, [1 1], [1 1], "My best ARMA", 20)

%%
e_hat_ar = filter(ar_model.A,ar_model.C, y1);
e_hat_ar = e_hat_ar(length(ar_model.A):end);

e_hat_arma = filter(arma_model.A, arma_model.C, y1);
e_hat_arma = e_hat_arma(length(arma_model.A):end);

checkIfWhite(e_hat_ar)
checkIfWhite(e_hat_arma)

%%
clear all
load data.dat
load noise.dat
data = iddata (data);
ar_1 = arx(data, 1);
ar_2 = arx(data, 2);

rar1 = resid(ar_1,data);
rar2 = resid(ar_2,data);

figure
plot(rar1(2:end))
hold on
plot(noise, 'r')

figure
plot(rar2(3:end))
hold on 
plot(noise, 'r')

%%
rar1 = resid(ar_1,data);
varar1 = var(rar1.OutputData);

am11_model = armax(data, [1,1] );

present(am11_model)
rarma12 = resid(am11_model, data);
vararma12 = var(rarma12.OutputData);

plot(rarma12)

disp("Residual variance difference is: " + (varar1-vararma12))

%%
plotACFnPACF(data.OutputData, 20, "data.dat)", 0.05);

%%

plotACFnPACF(rarma12.OutputData, 20, "Residuals?", 0.05);
%%
clear all
clc
%%
rng(0)
A = [1 -1.5 0.7];
C = [1 zeros(1,11) -0.5];
A12 = [1 zeros(1, 11) -1];
A_star = conv(A,A12);
e = randn(600,1);
y = filter(C, A_star, e);
y = y(101:end);
plot(y)

%%
showProc(y)
%% deseasoning
A12 = [1 zeros(1, 11) -1];

ys = filter(A12, 1, y);
ys = ys(length(A12):end);
data = iddata(ys);
%%
showProc(ys)
%%
model_init = idpoly([1 0 0], [], [1 zeros( 1 , 12 )]);


model_init.Structure.c.Free = [zeros(1,12) 1];


model_armax = pem(data, model_init);

r = resid(model_armax, ys);

showProc(r.OutputData);
%%
clear all
clc
load("svedala.mat")
plot(svedala)

%%
showProc(svedala)

%%
season = 24;


As = [1 zeros(1, season-1) -1];

svedala_s = filter(As, 1, svedala);
showProc(svedala_s)
%%

figure
plot(svedala_s)

Ad = [1 -1];
svedala_ds = filter(Ad,1, svedala_s);
showProc(svedala_ds)

%%
x = linspace(1,length(svedala_ds),length(svedala_ds));
polyfit(x,svedala_ds,1)
figure
plot(svedala_ds)

%%
data = iddata(svedala_s);
A = [1 1 1];
C = [1 zeros(1,season)];

model_init = idpoly(A, [], C);

model_init.Structure.c.Free = [0 1 zeros(1,season-2) 1];
model_init.Structure.a.Free = [0 1 1];

model_armax = pem(data, model_init);

r = resid(model_armax, data);

showProc(r.OutputData(season+1:end));

checkIfWhite(r.OutputData(season+1:end))
%%

showProc(r.OutputData)










