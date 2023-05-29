%% Generating data to a BJ-model
clear
clc

rng(0);
n = 500;
A3 = [1 .5];
C3 = [1 -0.3 .2];
w = sqrt(2)*randn(n+100, 1);
x = filter(C3, A3, w);

A1 = [1 -.65];
A2 = [1 .9 .78];
C = 1;
B = [0 0 0 0 .4];
e = sqrt(1.5)*randn(n+100,1);
y = filter(C, A1, e) + filter(B,A2,x);
x = x(101:end); y = y(101:end);
clear A1 A2 C B e w A3 C3;

%% first we want to model the input as a process with random input
showProc(x)


%% From the acf and pacf it seems like AR(1) is a good model
data = iddata(x);
model_init = idpoly([1 0], [], []);

model_armax = pem(data, model_init);

r = resid(model_armax, data);

showProc(r.OutputData);

checkIfWhite(r.OutputData,20,0.05);

% almost white

%% testing more models
model_armax = estimateARMA(x,[1 1 1], [1 0 1], "AR(2,2)", 20); 
% AR(2), ARMA(2,1), ARMA(2,2) all works very well
% best one is ARMA(2,2) but only C2 

%% checking the cross correlation between our x that has been whitened and 
% the same tramsform applied to y

close all
eps = resid(model_armax, y); 
wt = resid(model_armax, x);

M = 40; stem(-M:M, crosscorr(wt.OutputData, eps.OutputData, M));
title('Cross_correlation_function')
hold on
plot(-M:M, 2/sqrt(n)*ones(1, 2*M+1))
plot(-M:M, -2/sqrt(n)*ones(1, 2*M+1))

%% Testing different polynomials, using the alchemy approach

d = 4;
A2 = [1 1 1];
B = [zeros(1,d) 1];
Mi = idpoly(1,B,[],[],A2);
Mi.Structure.b.Free = [zeros(1,d) 1];
z = iddata(y,x);

Mba2 = pem(z,Mi); present(Mba2);
etilde = resid(Mba2, z);

crosscorr(etilde.OutputData,x)

%% examining the residuals
showProc(etilde.OutputData)

% fairly obvious an AR(1) process.
%%
etilde_arma = estimateARMA(etilde.OutputData,[1 1], [1], "ARMA(1,0)", 20);

% this yields A1 = order 1, C1 = order 0
%% We have now estimated all orders in the composite model
% estimating the parameters all together:

A1 = [1 1];
A2 = [1 1 1];
B = [0 0 0 0 1];
C = [1];

Mi = idpoly(1, B, C, A1, A2);
z = iddata(y,x);
MboxJ = pem(z, Mi);
present(MboxJ);
ehat = resid(MboxJ, z);
%%
error = resid(MboxJ,z); 
err = error.OutputData;
err = err(2:end);
variance = var(err);

%% using the complete function
estimateBJ(y,x,C,A1,B,A2,"My BJ-model",20)
%% ask about causality
crosscorr(x,err)
showProc(err)
%% 2.2 hairdryer data
clear all
close all
clc
%%
load tork.dat
tork = tork - repmat(mean(tork), length(tork),1);

figure
y = tork(:,1); x = tork(:,2);
z = iddata(y,x);
plot(z(1:300))
%% guesstimating AR to make x to white noise
showProc(x); % clealy an AR(1) is a good 
model_armax = estimateARMA(x,[1 1], [1], "ARMA(1,0)", 20);


%% calculate eps_t and w_t as the residual
% of the y and x backwords through the same filter
eps_t = resid(model_armax, y); 
w_t = resid(model_armax, x);

%% examine the cross correlation between eps_t and w_t
crosscorr(w_t.OutputData, eps_t.OutputData)

% at first glimpse it looks like (d,r,s) = (3,1,2)
% this yields delay = 5, order of A2 = 1 and order of B is 2
% this is using the alchemy trick, examining when ringing/envelope starts
% and so on
%% 
d = 3;
A2 = [1 1];
B = [zeros(1,d) 1 1 1];
Mi = idpoly(1,B,[],[],A2);

Mi.Structure.b.Free = [zeros(1,d) 1 1 1];
z = iddata(y,x);

Mba2 = pem(z,Mi); present(Mba2);
etilde = resid(Mba2, z);

crosscorr(x,etilde.OutputData)

% turns out alchemy is not good. 
%% now we want to model etilde as an ARMA-process, preferably small
showProc(etilde.OutputData)

% from the acf/pacf we should be using an AR(2). However, as evident below,
% this is not successful. 
%%
etilde_arma = estimateARMA(etilde.OutputData,[1 1 1], [1], "ARMA(2,0)", 20);

% the ARMA-order for etilde to white noise is the last orders needed.
% this is A1, C, but we need a better model of the input
%% we resign to the trial-and-error-method:
d = 3;
A2 = [1 0.1 .1];
B = [zeros(1,d) 1 0.1 .1];

Mi = idpoly(1,B,[],[],A2);

Mi.Structure.b.Free = [zeros(1,d) 1 1 1];
z = iddata(y,x);

Mba2 = pem(z,Mi); present(Mba2);
etilde = resid(Mba2, z);

crosscorr(x,etilde.OutputData)

% it is not perfect, but better

%% estimating our new resiudals etilde:
showProc(etilde.OutputData)

%% now an AR(1) should really do the trick
etilde_arma = estimateARMA(etilde.OutputData,[1 1], [1], "ARMA(1,0)", 20);

% these residuals are whiter than a mf
% this concludes that 

%% the best fit seems to be retrieved after no alchemy, but more trial and error
d = 3;
A2 = [1 0.1 .1];
B = [zeros(1,d) 1 0.1 .1];
Mi = idpoly(1 ,B ,[] ,[] , A2);
Mi.Structure.b.Free = [zeros(1,d) 1 1 1];

z = iddata(y,x);
Mba2 = pem(z,Mi); present(Mba2)

etilde = resid(Mba2, z );
crosscorr(x, etilde.OutputData)
%%
etilde_arma = estimateARMA(etilde.OutputData, [1 1], [1], "ARMA(1,0)", 20);
%% Putting it all together 
% We get the model orders:
d = 3;

A1 = [1 1];
A2 = [1 1 1];
B = [zeros(1,d) 1 1 1];
C = [1];

bestBJ = estimateBJ(y,x,C,A1,B,A2,"My BJ-model",20);

% delay time = 4*0.08 = 0.24 s

present(bestBJ)
%% Prediction
clear all 
load svedala
plot(svedala)
%%
A = [1 -1.79 0.84];
C = [1 -0.18 -0.11];

% solving Diophantine equations
% k = 1:
k = 30;
[Fk, Gk] = polydiv(C, A, k);

yhat_k = filter(Gk, C, svedala);
yhat_k = yhat_k(length(Gk)+1:end);

plot(yhat_k)
hold on

y_true = svedala(length(Gk)+1:end);
plot(y_true)

legend("prediction " + k + " steps", "real")


error = y_true - yhat_k;
disp("The mean error for " + k + "-step prediction is: " + mean(error) + ", the variance of the error is " + var(error))


%%
plot(error)
%% Calculating the theoretical prediction error
% for a time step k this is var(F_k(z)*e) = F_k'*F_k*var(e)

[F1, G1] = polydiv(C, A, 1);

yhat_1 = filter(G1, C, svedala);
yhat_1 = yhat_1(length(G1)+1:end);
y_true = svedala(length(G1)+1:end);

error = y_true - yhat_1;
mean_err_1 = mean(error);
var_err_1 = var(error);
disp("The mean error for " + 1 + "-step prediction is: " + mean_err_1 + ", the variance of the error is " + var_err_1)


[F3, G3] = polydiv(C, A, 3);

yhat_3 = filter(G3, C, svedala);
yhat_3 = yhat_3(length(G3)+1:end);

theo_err_var_3 = F3*F3'*var_err_1; 
disp("The theroetical prediction error for three step prediction " + theo_err_var_3)


[F26, G26] = polydiv(C, A, 26);

yhat_26 = filter(G3, C, svedala);
yhat_26 = yhat_26(length(G26)+1:end);

theo_err_var_26 = F26*F26'*var_err_1; 

disp("The theroetical prediction error for 26 step prediction " + theo_err_var_26)

%%

for k = [3 26]
    [Fk, Gk] = polydiv(C, A, k);
    
    yhat_k = filter(Gk, C, svedala);
    yhat_k = yhat_k(length(Gk)+1:end);
    y_true = svedala(length(Gk)+1:end);

    theo_err_var = Fk*Fk'*var_err_1; 
    
    
    error = y_true - yhat_k;
    disp("The mean error for " + k + "-step prediction is: " + mean(error) + ", the variance of the error is " + var(error))
    
    abs_err = abs(error);
    
    outside = sum(abs_err > norminv(1-0.025)*sqrt(theo_err_var))/length(abs_err);

    disp("Errors outide conf-int for " + k + "-step prediction is " + outside)

    
    
end
%%
figure(2)
plot(y_true, yhat_k, '.')
hold on
plot(yhat_k,yhat_k, '-', 'red')

plotACFnPACF(error,k+5,k, 0.05)
%% 2.4
load sturup
load svedala
A = [1 -1.49 0.57];
B = [0 0 0 .28 -.26];
C = [1];

%%
k = 26;
x = sturup;
y = svedala;

[Fk, Gk] = polydiv(C, A, k);

[Fhat, Ghat] = polydiv(conv(B,Fk),C,k);

xhat_k = filter(Gk, C, x);

yhat_k = filter(Fhat, 1, x) + filter(Ghat,C,x) + filter(Gk,C,y);

ybad_k = filter(Ghat,C,x) + filter(Gk,C,y);

remove = max([length(Ghat) length(Gk) length(Fhat) length(Fk) length(A) length(C) length(B)])+1;

yhat_k = yhat_k(remove:end);

ybad_k = ybad_k(remove:end);
y = y(remove:end);

plot(y)
hold on
plot(yhat_k)

error = y-yhat_k;
baderror = y-ybad_k;
disp("The variance of the error is: " + var(error))
disp("The variance of the bad estimate error is " + var(baderror))

showProc(error)
showProc(baderror)
figure
plot(baderror-error)
 

%% 2.5
load svedala
y = svedala;
showProc(y)
%%

% why dont we do season first?
S = 24;
AS = [1 zeros(1,S-1) -1];

Am = [1 1 1];
Cm = [1 1 1];

model_init = idpoly([1 1 1 zeros( 1 , 19) 0 1 1 1], [],[1 1 1]);
model_init.Structure.A.Free = [0 1 1 zeros(1,19) 0 1 1 1];

myARMA = pem(y, model_init);

k = 26;
[Fk, Gk] = polydiv(myARMA.C, myARMA.A, k);

yhat_k = filter(Gk, myARMA.C, y);
yhat_k = yhat_k(length(Gk)+1:end);

plot(yhat_k)
hold on

y_true = y(length(Gk)+1:end);
plot(y_true)

legend("prediction " + k + " steps", "real")
present(myARMA)
%%
r = resid(myARMA, y);

showProc(r.OutputData);


















