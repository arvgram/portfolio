%% Task 1
N = 10000;
extraN = 100;
e = randn(extraN + N,1);

A = [1 -0.5 0.7];
C = [1 zeros(1,10) -0.7];

y = filter( C, A, e );     y = y(extraN:end);

plot(y)
plotACFnPACF(y,50,"SARIMA(s = 12)");


%% Task 2
plot(svedala)


plotACFnPACF(svedala, 100, "Svedala")










