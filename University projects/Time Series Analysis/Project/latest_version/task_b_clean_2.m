rng(0)
addpath Project/latest_version/custom_functions/
clear 
clc
df = loadCleanValidate(0);
df = shift_exo(df, 0);
start_date = '1994-09-01';
[df_train, df_val, df_test] = trainValTestSplit(df, start_date, 1);
saveas(gcf,"Project/figs/train_test_split.png")

%% Now we want to use one of the external signals
%Looking at the cross correlation Sturup appears to be the best choice
numlags = 30;
f = figure;
newcolors = ["#0072BD","#D95319","#77AC30"];
colororder(newcolors);
f.Position = [100 100 700 300];
stuslaxcorr = crosscorr(df.tp_stu,df.t_sla, NumLags = numlags);
vxoslaxcorr = crosscorr(df.tp_vxo,df.t_sla, NumLags = numlags);
figure(1)
stem(-numlags:numlags,stuslaxcorr)
hold on
stem(-numlags:numlags,vxoslaxcorr)
title("Cross correlation between prediction in Sturup/Växjö and measured value in Svedala")
xlabel("Number of lags")
ylabel("Sample cross correlation")
lgd = legend(["Sturup with Svedala", "Växjö with Svedala"]);
lgd.Location = 'southwest';

filename = "your_name";
path_prefix = "Project/figs/";
path = path_prefix + filename + ".png";
saveas(gcf,path)

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
saveas(gcf,"Project/figs/sturupOrdinaryDifferentiated.png")

%% Lets take a look at the statistics of sturup
plotACFnPACF(detrended, 50, 'STURUP', 0.05);
saveas(gcf,"Project/figs/sturupACFnPACF.png")

%% Prewhitening
%Now we want to model the exogenous input as a white noise that is filtered
%trough a model

A = [1 0 0 1 0 0 1 0 0 1 0 0 1 0 0 1 zeros(1,7) 0 1 0];
C = [1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 zeros(1,7) 0 1 0];

[whitening_model, whiteningResiduals] = estimateARMA(detrended, A, C, 'ARIMA(24, 24)', 48);
saveas(gcf,"Project/figs/sturupACFnPACFafterLargeARMA.png")
present(whitening_model)
whitening_model.a = conv(detrender,whitening_model.a);

%% Look at cross correlation between wt and epsilon tilde after whitening
epst = resid(whitening_model,df_train.t_sla); epst = epst(length(whitening_model.A)+2:end);
wt = resid(whitening_model, df_train.tp_stu); wt = wt(length(whitening_model.A)+2:end);
n = length(df_train.t_sla);
M = 30;
stem(-M:M,crosscorr(wt.OutputData,epst.OutputData,M));
title('Cross correlation between the resiudals from Svedala and Sturup temperatures');
xlabel('Lag')
hold on
plot(-M:M, 2/sqrt(n)*ones(1,2*M+1)) 
plot(-M:M, -2/sqrt(n)*ones(1,2*M+1))
saveas(gcf,"Project/figs/xcorrResids.png")
hold off

%% We make a prelinary BJ-model with the orders identified from the crosscorrelation
close all
d = 0;
r = 2;
s = 0;
C1 = [];                                        % C-polynomial
A1 = [];                                        % D-polynomial
B =  [zeros(1,d) 1 ones(1,s)]*0.5;              % B-polynomial
A2 = [1/0.6 ones(1,r)].*0.6;                    % F-polynomial
y = df_train.t_sla;
x = df_train.tp_stu;

[prelModel, ey, acfEst, pacfEst ] = estimateBJ(y,x,C1,A1,B,A2,'Hello', 40);

f = figure();
newcolors = ["#0072BD","#D95319","#77AC30"];
colororder(newcolors);
f.Position = [100 100 700 250];
subplot(2,2,[1,3])
crosscorr(x,ey);
subplot(2,2,2)
acf(ey, 30, 0.05, 1);
title("Auto correlation function")
subplot(2,2,4)
pacf(ey, 30, 0.05, 1);
title("Partial auto correlation function")

saveas(gcf,"Project/figs/xcorrACFnPACFprelBJ.png")
%% From the preliminary BJ-model we find approporiate model orders
%   using trial and error
close all
d = 0;
r = 2;
s = 0;
C1 = [1 0.5 zeros(1,21) 0.5 0.3 0.5];       % C-polynomial
A1 = [1/0.2 1 1 1 zeros(1,19) 1 1 1].*0.2;  % D-polynomial
B =  [zeros(1,d) 1 ones(1,s)]*0.5;          % B-polynomial
A2 = [1/0.6 1 0 1 0 0].*0.6;                    % F-polynomial
y = df_train.t_sla;
x = df_train.tp_stu;

[b_finalmodel, ey, acfEst, pacfEst ] = estimateBJ(y,x,C1,A1,B,A2,'Hello', 40);

f = figure();
newcolors = ["#0072BD","#D95319","#77AC30"];
colororder(newcolors);
f.Position = [100 100 750 300];
subplot(2,2,[1,3])
crosscorr(x,ey,'NumLags', 30);
title("Cross correlation between exogenous input and model residual")
subplot(2,2,2)
acf(ey, 30, 0.05, 1);
title("Auto correlation function of model residuals")
subplot(2,2,4)
pacf(ey, 30, 0.05, 1);
title("Partial auto correlation function of model residuals")

saveas(gcf,"Project/figs/xcorrACFnPACFfinalBJresid.png")

save Project/latest_version/models/model_b_final b_finalmodel
%% Lets do some prediction with this model
close all
y = df.t_sla;
x = df.tp_stu;
time = df.time;

%Reformulate as an ARMAX process
K_a = conv(b_finalmodel.D, b_finalmodel.F); %A1A2
K_b = conv(b_finalmodel.D, b_finalmodel.B); %A1B
K_c = conv(b_finalmodel.F, b_finalmodel.C); %A2C

%% Specify when training, validation, test starts and end

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
[y_hat_1, x_hat_1] = predictARMAX(K_a,K_b,K_c,y,x,1);
[y_hat_9, x_hat_9] = predictARMAX(K_a,K_b,K_c,y,x,9);

%Fetch respective prediction
%modelling
y_model = y(train_start:train_end);
yhat_model_1 = y_hat_1(train_start:train_end);
yhat_model_9 = y_hat_9(train_start:train_end);

x_model = x(train_start:train_end);
xhat_model_1 = x_hat_1(train_start:train_end);
xhat_model_9 = x_hat_9(train_start:train_end);

%Validation
y_val = y(val_start:val_end);
yhat_val_1 = y_hat_1(val_start:val_end);
yhat_val_9 = y_hat_9(val_start:val_end);

x_val = x(val_start:val_end);
xhat_val_1 = x_hat_1(val_start:val_end);
xhat_val_9 = x_hat_9(val_start:val_end);

% test
y_test = y(test_start:test_end);
yhat_test_1 = y_hat_1(test_start:test_end);
yhat_test_9 = y_hat_9(test_start:test_end);

x_test = x(test_start:test_end);
xhat_test_1 = x_hat_1(test_start:test_end);
xhat_test_9 = x_hat_9(test_start:test_end);

test_predictions_b = [yhat_test_1 yhat_test_9]; % 
xtest_predictions_b = [xhat_test_1 xhat_test_9]; % these are set aside and not part of modelling process

save Project/preds/task_b test_predictions_b
save Project/preds/xtask_b xtest_predictions_b
%% Plot Predictions of y on modelling and validation data
%modelling
f = figure;
newcolors = ["#0072BD","#D95319","#77AC30"];
colororder(newcolors);
f.Position = [100 100 800 400];
set(f,'DefaultLineLineWidth',2)
subplot(211)
plot(df_train.time, df_train.t_sla)
hold on
plot(df_train.time, yhat_model_1)
plot(df_train.time, yhat_model_9)
title("Predictions of Svedala temperature on modelling data")
legend(["Actual", "1 Step Prediction", "9 Step Prediction"])
ylabel("°C")

%Validation
subplot(212)
plot(df_val.time, df_val.t_sla)
hold on
plot(df_val.time, yhat_val_1)
plot(df_val.time, yhat_val_9)
title("Predictions of Svedala temperature on validation data")
legend(["Actual", "1 Step Prediction", "9 Step Prediction"])
ylabel("°C")

saveas(gcf,"Project/figs/BJvalpreds.png")

%% Plot Predictions of x on modelling and validation data
f = figure;
newcolors = ["#0072BD","#D95319","#77AC30"];
colororder(newcolors);
f.Position = [100 100 800 400];
set(f,'DefaultLineLineWidth',2)
subplot(211)
plot(df_train.time, df_train.tp_stu)
hold on
plot(df_train.time, xhat_model_1)
plot(df_train.time, xhat_model_9)
title("Predictions of modelling exogenous input data")
legend(["Actual", "1 Step Prediction", "9 Step Prediction"])
ylabel("°C")

%Validation
subplot(212)
plot(df_val.time, df_val.tp_stu)
hold on
plot(df_val.time, xhat_val_1)
plot(df_val.time, xhat_val_9)
title("Predictions of validation exogenous input data")
legend(["Actual", "1 Step Prediction", "9 Step Prediction"])
ylabel("°C")

saveas(gcf,"Project/figs/exoBJvalpreds.png")
%% Get residuals for y and x predictions
resid_1_model = y_model - yhat_model_1;
resid_9_model = y_model - yhat_model_9;

resid_1_val = y_val - yhat_val_1;
resid_9_val = y_val - yhat_val_9;

xresid_1_model = x_model - xhat_model_1;
xresid_9_model = x_model - xhat_model_9;

xresid_1_val = x_val - xhat_val_1;
xresid_9_val = x_val - xhat_val_9;



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

%% Prediction of input model residual
disp("########################## Input Modelling Residual Analysis##########################")
plotACFnPACF(xresid_1_model, 50, "Model Residual 1 Step", 0.05);
plotACFnPACF(xresid_9_model, 50, "Model Residual 9 Step", 0.05);
disp("Model Residual Variance 1 step: " + var(xresid_1_model))
figure
whitenessTest(xresid_1_model)
title("1 Step Model")
disp("Model Residual Variance 9 step: " + var(xresid_9_model))
figure
whitenessTest(xresid_9_model)
title("9 Step Model")


%% Check Validation residual
disp("########################## Validation Residual Analysis##########################")
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

%% Prediction of input validation residual
disp("########################## Input Validation Residual Analysis##########################")
plotACFnPACF(xresid_1_val, 50, "Validation Residual 1 Step", 0.05);
plotACFnPACF(xresid_9_val, 50, "Validation Residual 9 Step", 0.05);
disp("Validation Residual Variance 1 step: " + var(xresid_1_val))
figure
whitenessTest(xresid_1_val)
title("1 Step Validation")
disp("Validation Residual Variance 9 step: " + var(xresid_9_val))
figure
whitenessTest(xresid_9_val)
title("9 Step Validation")













