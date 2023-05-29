clear; 
load 'Tenta'/sysiddata.mat
Ts = h;
%outlier_index = [314 628 942];
%for i = outlier_index
%    y(i) = mean([y(i-1) y(i+1)]);
%end
%%
figure(1);
subplot(211)
plot(u);
legend("Input")
subplot(212)
plot(y)
legend("Output")

%% model validation split
N = length(y);
split = N*0.7;
ym = y(1:split);
yt = y(split+1:end);

um = u(1:split);
ut = u(split+1:end);
%%
noLags = 30;
signlvl = 0.05;
alpha = 0.02;
acfEst = acf(ym, noLags, signlvl, 1, 1);
hold on
tacfEst = tacf(ym, noLags, alpha, signlvl, 1, 1);
%%
figure()
pwelch(um)
hold on
pwelch(ym)
legend(["Input", "Output"])
%%
figure(1)
crosscorr(um, ym)
title("Crosscorr between in and output")
saveas(gcf,"Tenta/Figs/crosscorr.png")

figure(2)
subplot(211)
acfEst = acf(ym, noLags, signlvl, 1, 1);
title("ACF and PACF output")
subplot(212)
pacfEst = pacf(ym, noLags, signlvl, 1, 1);
saveas(gcf,"Tenta/Figs/outputacfnpacf.png")

figure(3)
subplot(211)
acfEst = acf(um, noLags, signlvl, 1, 1);
title("ACF and PACF input")
subplot(212)
pacfEst = pacf(um, noLags, signlvl, 1, 1);
saveas(gcf,"Tenta/Figs/inputacfnpacf.png")
%%
systemIdentification
%% modelling 
close all
C1 = [1];         % C-polynomial
A1 = [1];         % D-polynomial
B =  [1 1 1 0 0 0 0 0 0 0 0 0];   % B-polynomial
A2 = [1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0];   % F-polynomial


% pem-magic
A1(2:end) = A1(2:end) * 0.3;
A2(2:end) = A2(2:end) * 0.3;
C1(2:end) = C1(2:end) * 0.3;
B(2:end)  = B(2:end)  * 0.3;

polyContainer = idpoly( 1, B, C1, A1, A2 );
dataContainer = iddata(ym, um, Ts);



if length(B)>1                              % Only estimate the specified parameters.
    polyContainer.Structure.B.Free = B;
end
if length(A2)>1
    polyContainer.Structure.F.Free = A2;
end
if length(C1)>1
    polyContainer.Structure.C.Free = C1;
end
if length(A1)>1
    polyContainer.Structure.D.Free = A1;
end

foundModel = pem( dataContainer, polyContainer);

present(foundModel);
ey = resid( foundModel, dataContainer );
ey = ey.y( length(foundModel.B):end );

noLags = 20;
signlvl = 0.05;

figure(1)
crosscorr(um, ey)
saveas(gcf,"Tenta/Figs/modellingresid.png")

figure(2)
subplot(211)
acfEst = acf(ey, noLags, signlvl, 1, 1);
subplot(212)
pacfEst = pacf(ey, noLags, signlvl, 1, 1);
saveas(gcf,"Tenta/Figs/modellingacf.png")
%% validation
%foundModel = oe222;
valdatacontainer = iddata(yt,ut,Ts);

figure(1)
resid(foundModel,valdatacontainer);


yp = predict(foundModel,valdatacontainer,1);

figure(2)
plot(yp.OutputData)
hold on
plot(yt)
legend(["Prediction", "True"])

%%
compare(valdatacontainer,foundModel)
saveas(gcf,"Tenta/Figs/compare.png")
%% frequency
bodeplot(foundModel)
saveas(gcf,"Tenta/Figs/bode.png")
%% poles
pzmap(foundModel)

%%
yhat_step = step(foundModel,t);
figure()
plot(t,yhat_step)
hold on
plot(t,ystep);
saveas(gcf,"Tenta/Figs/stepresponse.png")

resiudals = yhat_step-ystep;

figure(2)
subplot(211)
acfEst = acf(resiudals, noLags, signlvl, 1, 1);
subplot(212)
pacfEst = pacf(resiudals, noLags, signlvl, 1, 1);
saveas(gcf,"Tenta/Figs/stepresidacf.png")



