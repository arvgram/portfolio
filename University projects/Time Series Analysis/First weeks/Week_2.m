%%Week 2
N = 1e2;
extraN = 10;

A = [1 -1.79 0.84];
C = [1 -0.81 -0.11];
e = randn(extraN + N,1);

y1 = filter( C, 1, e );     y1 = y1(extraN:end);
y2 = filter( 1, A, e );     y2 = y2(extraN:end);
y3 = filter( C, A, e );     y3 = y3(extraN:end);

figure
subplot(311)
plot(y1)

subplot(312)
plot(y2)

subplot(313)
plot(y3)
%%
figure
subplot(211)
acf(y2, 50, 0.05, 1);
title('ACF - AR')
subplot(212)
pacf(y2, 50, 0.05, 1);
title('PACF - AR')


figure
subplot(211)
acf(y1, 50, 0.05, 1);
title('ACF - MA')
subplot(212)
pacf(y1, 50, 0.05, 1);
title('PACF - MA')

figure
subplot(211)
acf(y3, 50, 0.05, 1);
title('ACF - ARMA')
subplot(212)
pacf(y3, 50, 0.05, 1);
title('PACF - ARMA')

%% Part 2
N = 1e2;
extraN = 10;


A = [1 1.05 1.05];
C = [1 0.91 0.8];
e = randn(extraN + N,1);

figure
subplot(211)
zplane(A)
title("Poles for AR")

subplot(212)
zplane(C)
title("Poles for MA")


y1 = filter( C, 1, e );     y1 = y1(extraN:end);
y2 = filter( 1, A, e );     y2 = y2(extraN:end);
y3 = filter( C, A, e );     y3 = y3(extraN:end);

figure
subplot(311)
plot(y1)

subplot(312)
plot(y2)

subplot(313)
plot(y3)

%% Task 3
load week2data.mat
plot(y)

figure
subplot(211)
acf(y, length(y)/4, 0.05, 1);
title('ACF')
subplot(212)
pacf(y, length(y)/4, 0.05, 1);
title('PACF')










