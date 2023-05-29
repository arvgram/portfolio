rng(0)
addpath Project/latest_version/custom_functions/
clear 
clc
df = loadCleanValidate(0);
start_date = '1994-09-01';
[df_train, df_val, df_test] = trainValTestSplit(df, start_date, 1);

%% Do a final check for outliers in the data
checkACFnTACF(df.t_sla)
%They look pretty similar so we are good

%% Test for transform
f = figure;
newcolors = ["#0072BD","#D95319","#77AC30"];
colororder(newcolors);
set(f,'DefaultLineLineWidth',2)
f.Position = [100 100 700 300];
max = bcNormPlot(df_train.t_sla);
hold on
xline(max);
l = legend(["Box-Cox likelihood", "\lambda that maximises the value"]);
l.Location = "south";
saveas(gcf,"Project/figs/bcnorm.png")
% Looks to not be necessary for this problem
%% Deterministic Detrend 
df_train_temp = df_train;
x = linspace(1,length(df_train_temp.t_sla),length(df_train_temp.t_sla));
betas = polyfit(x,df_train_temp.t_sla,1)
f = figure;
newcolors = ["#0072BD","#D95319","#77AC30"];
colororder(newcolors);
set(f,'DefaultLineLineWidth',2)

f.Position = [100 100 700 300];
plot(df_train.time,df_train_temp.t_sla)
hold on
plot(df_train.time,betas(2) + betas(1)*x)
saveas(gcf,"Project/figs/datawithtrendspecified.png")
%% Detrend the data using a differentiating filter
f = figure;
newcolors = ["#0072BD","#D95319","#77AC30"];
colororder(newcolors);
%set(f,'DefaultLineLineWidth',2)
f.Position = [100 100 700 300];
df_train_temp = df_train;
df_detrend = df_train_temp;
plot(df_detrend.time, df_detrend.t_sla)
hold on
detrender = [1 -1];
df_detrend.t_sla = filter(detrender, 1,df_detrend.t_sla);
df_detrend = df_detrend(length(detrender):end,:);
%Lets have a look at the detrended data

plot(df_detrend.time, df_detrend.t_sla)
hold on
plot(df_train.time,betas(2) + betas(1)*x)
legend(["Original Data", "Detrended Data", "Trend line"])
disp("Mean of detrended data: " + mean(df_detrend.t_sla))
saveas(gcf,"Project/figs/detrended.png")

%% Take a look at the detrended data
plotACFnPACF(df_detrend.t_sla, 48, 'Detrended', 0.05);

%% Fit on training data and look at model residual
%Model orders are decided through looking at ACF and PACF coupled with
%trial and error
df_train_temp = df_detrend;
season = 24;
p = 2;
q = 1;
A = [ones(1,p+1), zeros(1,season - p - 2) 1 0 1];
C = [ones(1,q+1) zeros(1,season-2) 1];

model_arma = estimateARMA(df_train_temp.t_sla,A,C, "\nabla_{1}SARIMA(" + p + "," + q + ") ", 48);
present(model_arma)
model_arma.a = conv(detrender, model_arma.a); %add detrending polynomial to model


%% Lets save this model for later use
save Code/project/models/model_a model_arma

%% Lets do some prediction with this model
y = df.t_sla;
time = df.time;
A = model_arma.a;
C = model_arma.C;
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

%% Do a 1 and 9 step prediction on all data
y_hat_1 = predictARMA(A,C,y,1);
y_hat_9 = predictARMA(A,C,y,9);

%Fetch respective prediction
%modelling
y_model = y(train_start:train_end);
yhat_model_1 = y_hat_1(train_start:train_end);
yhat_model_9 = y_hat_9(train_start:train_end);

%Validation
y_val = y(val_start:val_end);
yhat_val_1 = y_hat_1(val_start:val_end);
yhat_val_9 = y_hat_9(val_start:val_end);

%Test
y_test = y(test_start:test_end);
yhat_test_1 = y_hat_1(test_start:test_end);
yhat_test_9 = y_hat_9(test_start:test_end);

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


%% Get residuals
resid_1_model = y_model - yhat_model_1;
resid_9_model = y_model - yhat_model_9;

resid_1_val = y_val - yhat_val_1;
resid_9_val = y_val - yhat_val_9;

resid_1_test = y_test - yhat_test_1;
resid_9_test = y_test - yhat_test_9;


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


%% Check Validation residual
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

%% Check Test residual
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







