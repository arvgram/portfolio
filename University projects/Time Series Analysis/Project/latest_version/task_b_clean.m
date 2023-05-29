rng(0)
addpath Project/latest_version/custom_functions/
clear 
clc
df = loadCleanValidate(0);
start_date = '1994-09-01';
[df_train, df_val, df_test] = trainValTestSplit(df, start_date, 1);


%% Now we want to use one of the external signals
% Looking at the cross correlation Sturup appears to be the best choice
figure 
subplot(211)
crosscorr(df.tp_stu,df.t_sla, NumLags = 40)
subplot(212)
crosscorr(df.tp_vxo,df.t_sla, NumLags = 40)

%% we now want to model the input as a process
plot(df_train.time, df_train.tp_stu)
% looks like we need a differenenffieation

%% differentiation
detrender = [1 -1];
detrended = filter(detrender, 1, df_train.tp_stu);
detrended = detrended(length(detrender):end);
time = df_train.time(length(detrender):end);
plot(time, df_train.tp_stu(length(detrender): end))
hold on
plot(time, detrended)
title("STURUP")
legend(["Original", "Detrended"])

%% Lets take a look at the statistics of sturup
plotACFnPACF(detrended, 50, 'STURUP', 0.05);
%% Prewhitening
%Now we want to model the exogenous input as a white noise that is filtered
%trough a model

A = [1 1 0 0 0 0 0 0 0 0 0 zeros(1,12) 1 1 1];
C = [1 0 0 0 0 0 0 0 0 0 0 zeros(1,12) 0 1 0];

whitening_model = estimateARMA(detrended,A, C, 'AR(2)', 59);
present(whitening_model)
whitening_model.a = conv(detrender,whitening_model.a);

%% Turns out this is really tricky
% Despite a lot of trial and error this seems impossible. 
r = resid(df_train.tp_stu, whitening_model);
whitenessTest(r)

%% Look at cross correlation between wt and epsilon tilde after whitening
epst = resid(whitening_model, df_train.t_sla);
wt = resid(whitening_model, df_train.tp_stu);
n = length(df_train.t_sla);
M = 40;
stem(-M:M,crosscorr(wt.OutputData,epst.OutputData,M));
title('Cross correlation function');
xlabel('Lag')
hold on
plot(-M:M, 2/sqrt(n)*ones(1,2*M+1)) 
plot(-M:M, -2/sqrt(n)*ones(1,2*M+1))
hold off

%% Next step in BJ model order estimation is to look at the cross correlation between x and y
% Since we can not construct a model that transfers white noise to x this
% is irrelevant
d = 0;
A2 = [1 1];
B = [zeros(1,d) 1 1];
Mi = idpoly(1 ,B ,[] ,[] ,A2);
Mi.Structure.b.Free = [zeros(1,d) 1 1];
z = iddata(df_train.t_sla,df_train.tp_stu);
Mba2 = pem(z,Mi);
present(Mba2)
etilde = resid(Mba2, z );
crosscorr(etilde.OutputData, df_train.tp_stu)
checkIfWhite(etilde.OutputData)


%% Look at acf and pacf of etilde
plotACFnPACF(etilde.OutputData, 20, 'etilde', 0.05)
estimateARMA(etilde.OutputData, [1 1 1], [1 1], 'AR Estimate of x', 20);

%%
season = 24;
deseasoner = [1 zeros(1,season-1) -1];
y_noSeason = filter(deseasoner, 1, df_train.t_sla);
x_noSeason = filter(deseasoner, 1, df_train.tp_stu);

%% The model order estimation scheme failed
% Instead we turn to trial and error and guess our way to a functioning BJ
% model. These model orders seem to be appropriate since the model residual
% is white and the x is almost uncorrelated with the residual. Sometimes
% trial and error is superior to the BJ model order estimation scheme
close all
d = 0;
C1 = [1 0.5 0 0 0 0 zeros(1,17) 0.5 0 0];      % C-polynomial
A1 = [1/0.6 1 0 1 0 0 zeros(1,17) 1 1 0].*0.6;      % D-polynomial
B =  [zeros(1,d) 1 0 0]*0.5;                                % B-polynomial
A2 = [1/0.6 1 0 1 zeros(1,19) 1 1 1].*0.6;          % F-polynomial
y = df_train.t_sla;
x = df_train.tp_stu;

[foundModel, ey, acfEst, pacfEst ] = estimateBJ(y,x,C1,A1,B,A2,'Hello', 40);

figure
crosscorr(x, ey)
save Project/latest_version/models/model_b foundModel


%% Lets do some prediction with this model
close all
y = df.t_sla;
x = df.tp_stu;
time = df.time;

%Reformulate as an ARMAX process
K_a = conv(finalmodel.D, finalmodel.F); %A1A2
K_b = conv(finalmodel.D, finalmodel.B); %A1B
K_c = conv(finalmodel.F, finalmodel.C); %A2C

% Specify when training, validation, test starts and end

%Training
train_start = find(df.time == df_train.time(1));
train_end = find(df.time == df_train.time(end));

%Validation
val_start = find(df.time == df_val.time(1));
val_end = find(df.time == df_val.time(end));

%Test
test_start = find(df.time == df_test.time(1));
test_end = find(df.time == df_test.time(end));

% Do a 1 and 9 step prediction on all data
y_hat_1 = predictARMAX(K_a,K_b,K_c,y,x,1);
y_hat_9 = predictARMAX(K_a,K_b,K_c,y,x,9);

%Fetch respective prediction
%modelling
y_model = y(train_start:train_end);
yhat_model_1 = y_hat_1(train_start:train_end);
yhat_model_9 = y_hat_9(train_start:train_end);

%Validation
y_val = y(val_start:val_end);
yhat_val_1 = y_hat_1(val_start:val_end);
yhat_val_9 = y_hat_9(val_start:val_end);

% test
y_test = y(test_start:test_end);
yhat_test_1 = y_hat_1(test_start:test_end);
yhat_test_9 = y_hat_9(test_start:test_end);


resid_1_model = y_model - yhat_model_1;
resid_9_model = y_model - yhat_model_9;

resid_1_val = y_val - yhat_val_1;
resid_9_val = y_val - yhat_val_9;

resid_1_test = y_test - yhat_test_1;
resid_9_test = y_test - yhat_test_9;

%figure(1)
%plot(df_train.time, resid_1_model)
%hold on
%plot(df_train.time, resid_9_model)
%title("Modelling data")
%legend(["One step resiudal", "Nine step residual"])
disp("Modelling data Residual Variance 1 step: " + var(resid_1_model))
disp("Modelling data Residual Variance 9 step: " + var(resid_9_model))
disp("-------------------")

%figure(2)
%plot(df_val.time, resid_1_val)
%hold on
%plot(df_val.time, resid_9_val)
%title("Validation data")
%legend(["One step resiudal", "Nine step residual"])
disp("Validation Residual Variance 1 step: " + var(resid_1_val))
disp("Validation Residual Variance 9 step: " + var(resid_9_val))
disp("-------------------")

disp("Test Residual Variance 1 step: " + var(resid_1_test))
disp("Test Residual Variance 9 step: " + var(resid_9_test))
disp("-------------------")

%% Plot Predictions
%modelling
figure
plot(df_train.time, df_train.t_sla)
hold on
plot(df_train.time, yhat_model_1)
plot(df_train.time, yhat_model_9)
title("Model Predictions")
legend(["Actual", "1 Step Prediction", "9 Step Prediction"])

%Validation
figure
plot(df_val.time, df_val.t_sla)
hold on
plot(df_val.time, yhat_val_1)
plot(df_val.time, yhat_val_9)
title("Validation Predictions")
legend(["Actual", "1 Step Prediction", "9 Step Prediction"])

%Test
figure
plot(df_test.time, df_test.t_sla)
hold on
plot(df_test.time, yhat_test_1)
plot(df_test.time, yhat_test_9)
title("Test Predictions")
legend(["Actual", "1 Step Prediction", "9 Step Prediction"])


%% Check model residual
disp("##########################Modelling Residual Analysis##########################")
plotACFnPACF(resid_1_model, 50, "Model Residual 1 Step", 0.05);
plotACFnPACF(resid_9_model, 50, "Model Residual 9 Step", 0.05);
disp("Model Residual Variance 1 step: " + var(resid_1_model))
figure
whitenessTest(resid_1_model)
title("1 Step Model")
disp("Model Residual Variance 9 step: " + var(resid_9_model))
figure
whitenessTest(resid_9_model)
title("9 Step Model")


% Check Validation residual
disp("##########################Validation Residual Analysis##########################")
plotACFnPACF(resid_1_val, 50, "Validation Residual 1 Step", 0.05);
plotACFnPACF(resid_9_val, 50, "Validation Residual 9 Step", 0.05);
disp("Validation Residual Variance 1 step: " + var(resid_1_val))
figure
whitenessTest(resid_1_val)
title("1 Step Validation")
disp("Validation Residual Variance 9 step: " + var(resid_9_val))
figure
whitenessTest(resid_9_val)
title("9 Step Validation")

% Check Test residual
disp("##########################Test Residual Analysis##########################")
plotACFnPACF(resid_1_test, 50, "Test Residual 1 Step", 0.05);
plotACFnPACF(resid_9_test, 50, "Test Residual 9 Step", 0.05);
disp("Test Residual Variance 1 step: " + var(resid_1_test))
figure
whitenessTest(resid_1_test)
title("1 Step Test")
disp("Test Residual Variance 9 step: " + var(resid_9_test))
figure
whitenessTest(resid_9_test)
title("9 Step Test")













