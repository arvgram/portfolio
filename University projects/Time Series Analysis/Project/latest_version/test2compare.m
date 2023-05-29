addpath Project/latest_version/custom_functions/

K_a = [1 0.5 0.4];
K_c = [1 0.2 0.3];

rng(0);
N = 100000;
ee = 0.1*randn(N,1);
y = filter(K_c, K_a, ee);

plotACFnPACF(y, 20, "Tja", 0.05);

%%
p = 2;
q = 2;
A = [ones(1,p+1)];
C = [ones(1,q+1)];
model_arma = estimateARMA(y,A,C, "ARMA(" + p + "," + q + ") ", 48);
present(model_arma)

%%
yhat = predictARMA(model_arma.A,model_arma.C,y,1);

figure
plot(yhat(400:500))
hold on
plot(y(400:500))

figure
plot(yhat-y)

disp(var(yhat-y))
