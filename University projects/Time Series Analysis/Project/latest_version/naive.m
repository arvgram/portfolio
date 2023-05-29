rng(0)
addpath Project/latest_version/custom_functions/
clear 
clc
df = loadCleanValidate(0);
start_date = '1994-09-01';
[df_train, df_val, df_test] = trainValTestSplit(df, start_date, 1);

%% Construct Naive model
% This is the guess-last-hour-value model.
A = [1 zeros(1,23) -1];
C = [1];

%% Lets do some prediction with this model
y = df.t_sla;
time = df.time;

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
plot(df_train.time, y_model)
hold on
plot(df_train.time, yhat_model_1)
plot(df_train.time, yhat_model_9)
title("Modelling data Predictions")
legend(["Actual", "1 Step Prediction", "9 Step Prediction"])

%Validation
figure
plot(df_val.time, y_val)
hold on
plot(df_val.time, yhat_val_1)
plot(df_val.time, yhat_val_9)
title("Validation data Predictions")
legend(["Actual", "1 Step Prediction", "9 Step Prediction"])

%Test
figure
plot(df_test.time, y_test)
hold on
plot(df_test.time, yhat_test_1)
plot(df_test.time, yhat_test_9)
title("Test data Predictions")
legend(["Actual", "1 Step Prediction", "9 Step Prediction"])


%% Get residuals
resid_1_model = y_model - yhat_model_1;
resid_9_model = y_model - yhat_model_9;

resid_1_val = y_val - yhat_val_1;
resid_9_val = y_val - yhat_val_9;

resid_1_test = y_test - yhat_test_1;
resid_9_test = y_test - yhat_test_9;

figure(1)
plot(df_train.time, resid_1_model)
hold on
plot(df_train.time, resid_9_model)
title("Modelling data")
legend(["One step resiudal", "Nine step residual"])
disp("Modelling data Residual Variance 1 step: " + var(resid_1_model))
disp("Modelling data Residual Variance 9 step: " + var(resid_9_model))
disp("-------------------")

figure(2)
plot(df_val.time, resid_1_val)
hold on
plot(df_val.time, resid_9_val)
title("Validation data")
legend(["One step resiudal", "Nine step residual"])
disp("Validation Residual Variance 1 step: " + var(resid_1_val))
disp("Validation Residual Variance 9 step: " + var(resid_9_val))
disp("-------------------")

figure(3)
plot(df_test.time, resid_1_test)
hold on
plot(df_test.time, resid_9_test)
title("Test data")
legend(["One step resiudal", "Nine step residual"])
disp("Test Residual Variance 1 step: " + var(resid_1_test))
disp("Test Residual Variance 9 step: " + var(resid_9_test))
disp("-------------------")

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


