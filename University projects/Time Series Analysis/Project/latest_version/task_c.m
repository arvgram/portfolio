rng(0)
addpath Code/project/custom_functions/
clear 
clc
df = loadCleanValidate(0);
start_date = '1994-09-01';
[df_train, df_val, df_test] = trainValTestSplit(df, start_date, 1);


%%
load Code/project/models/model_a.mat
load Code/project/models/model_b.mat
model_init_a = model_arma;
model_init_b = foundModel;
present(model_init_a)
present(model_init_b)


%% 
% Reformulate BJ model on the ARMAX form
K_a = conv(model_init_b.D, model_init_b.F); %A1A2 This is A?
K_b = conv(model_init_b.D, model_init_b.B); %A1B This is B?
K_c = conv(model_init_b.F, model_init_b.C); %A2C This is C?

y = df.t_sla;
u = df.tp_stu;
N = length(y);
ehat = zeros(N,1);
A = 1;
idx_a = find(K_a(2:end));
idx_c = find(K_c(2:end));
idx_b = find(K_b(2:end));
xt_t1 = [nonzeros(K_a(2:end))' nonzeros(K_b(2:end))' nonzeros(K_c(2:end))']';
og_params = xt_t1;
Rxx_1 = 10 * eye(length(xt_t1));
Re = 1e-6 * eye(length(xt_t1)); %make smaller
Rw = 3; %look at variance of previous residuals
yhats = zeros(N,1);
yhatk = zeros(N,1);
Xsave = zeros(length(xt_t1), N);

k = 9;

%%
start = max([idx_a idx_b idx_c])+1;
ed = N-k;
for t = start:ed
    Ct = [y(t-idx_a)' ehat(t-idx_c)' u(t-idx_b)'];

    yhat = Ct * xt_t1;          %y{t|t−1}
    yhats(t) = yhat;
    ehat(t) = y(t) - yhat;       %%et=yt−y{t|t−1} One step prediction error
    
    % Update
    Ryy = Ct * Rxx_1 * Ct' + Rw;                     %Rˆ{yy}{t|t−1}
    Kt = Rxx_1 * Ct' / Ryy;                      %Kt Kalman gain
    xt_t = xt_t1 + Kt * ehat(t);                      %x{t|t}
    Rxx = Rxx_1 - Kt * Ryy * Kt';                     %R{xx}{t|t}

    % Predict the next state
    xt_t1 = A * xt_t;                  %x_{t+1|t}
    Rxx_1 = A * Rxx * A' + Re;                  % Rˆ{xx} {t+1|t}
    
    %Form the 2 step prediction
    Ck = [y(t-idx_a+1)' ehat(t-idx_c+1)' u(t-idx_b+1)'];                     %C{t+1|t}
    yk = Ck * xt_t1;                            % \hat{y}_{t+1|t} = C_{t+1|t} A x_{t|t}
    
    for k0=2:k
        Ck = [yhatk(t - idx_a + k0)' ehat(t - idx_c + k0)' u(t - idx_b + k0)']; % C_{t+k|t}
        yk = Ck * A^k * xt_t1;                    % \hat{y}_{t+k|t} = C_{t+k|t} A^k x_{t|t}
    end
    yhatk(t+k) = yk;       

    Xsave(:,t) = xt_t;
end
disp(sum(ehat.^2))

%% Validation
val_start = find(df.time == df_val.time(1));
val_stop = find(df.time == df_val.time(end));

%% Plot prediction on validation set
plot(y(val_start:val_stop))
hold on
plot(yhatk(val_start:val_stop))
legend(["Actual", "Pred"])


%% Check validation residual
val_resid = y(val_start:val_stop) - yhatk(val_start:val_stop);
var(val_resid)
disp(k + " Step Validation Residual Variance: " + var(val_resid))
plotACFnPACF(val_resid, 20, k + " Step Test Residual");
figure
whitenessTest(val_resid);



%% Test
test_start = find(df.time == df_test.time(1));
test_stop = find(df.time == df_test.time(end));

%plot prediction on test set
plot(y(test_start:test_stop))
hold on
plot(yhatk(test_start:test_stop))
legend(["Actual", "Pred"])


%% check test residual
val_resid = y(test_start:test_stop) - yhatk(test_start:test_stop);
disp(k + " Step Test Residual Variance: " + var(val_resid))
plotACFnPACF(val_resid, 20, k + " Step Test Residual");
figure
whitenessTest(val_resid);

%% check params
plot(Xsave(:,start:ed)')
hold on
yline(og_params')










%% Lets try using a simpler model instead of the ARMAX
K_a = model_init_a.a;
K_b = 0;
K_c = model_init_a.c;
y = df.t_sla;
u = df.tp_stu;
N = length(y);
ehat = zeros(N,1);
A = 1;
idx_a = find(K_a(2:end));
idx_c = find(K_c(2:end));
idx_b = find(K_b(2:end));
xt_t1 = [nonzeros(K_a(2:end))' nonzeros(K_c(2:end))']';
og_params = xt_t1;
Rxx_1 = 10*eye(length(xt_t1));
Re = 1e-3 * eye(length(xt_t1)); %make smaller
Rw = 0.22; %look at variance of previous residuals
yhats = zeros(N,1);
yk = zeros(1,N);
yhatk = zeros(N,1);
Xsave = zeros(length(xt_t1), N);

k = 9;
%%
start = max([idx_a idx_b idx_c])+1;
ed = N-k;
for t = start:ed
    Ct = [y(t-idx_a)' ehat(t-idx_c)'];

    yhat = Ct * xt_t1;          %y{t|t−1}
    yhats(t) = yhat;
    ehat(t) = y(t) - yhat;       %%et=yt−y{t|t−1} One step prediction error
    
    % Update
    Ryy = Ct * Rxx_1 * Ct' + Rw;                     %Rˆ{yy}{t|t−1}
    Kt = Rxx_1 * Ct' / Ryy;                      %Kt Kalman gain
    xt_t = xt_t1 + Kt * ehat(t);                      %x{t|t}
    Rxx = Rxx_1 - Kt * Ryy * Kt';                     %R{xx}{t|t}

    % Predict the next state
    xt_t1 = A * xt_t;                  %x_{t+1|t}
    Rxx_1 = A * Rxx * A' + Re;                  % Rˆ{xx} {t+1|t}
    
    %Form the 2 step prediction
    Ck = [y(t-idx_a+1)' ehat(t-idx_c+1)'];                     %C{t+1|t}
    yk = Ck * xt_t1;                            % \hat{y}_{t+1|t} = C_{t+1|t} A x_{t|t}
    
    for k0=2:k
        Ck = [yhatk(t - idx_a + k0)' ehat(t - idx_c + k0)' ]; % C_{t+k|t}
        yk = Ck*A^k*xt_t1;                    % \hat{y}_{t+k|t} = C_{t+k|t} A^k x_{t|t}
    end
    yhatk(t+k) = yk;       

    Xsave(:,t) = xt_t;
end
disp(sum(ehat.^2))

%% Validation
val_start = find(df.time == df_val.time(1));
val_stop = find(df.time == df_val.time(end));

modelling_start = find(df.time == df_train.time(1));
modelling_end = find(df.time == df_train.time(end));


%% Plot prediction on validation set
plot(y(val_start:val_stop))
hold on
plot(yhatk(val_start:val_stop))
legend(["Actual", "Pred"])


%% Check validation residual
val_resid = y(val_start:val_stop) - yhatk(val_start:val_stop);
var(val_resid)
disp(k + " Step Validation Residual Variance: " + var(val_resid))
plotACFnPACF(val_resid, 20, k + " Step Test Residual");
figure
whitenessTest(val_resid);



%% Test
test_start = find(df.time == df_test.time(1));
test_stop = find(df.time == df_test.time(end));


%% plot prediction on test set
plot(y(test_start:test_stop))
hold on
plot(yhatk(test_start:test_stop))
legend(["Actual", "Pred"])


%% check test residual
val_resid = y(test_start:test_stop) - yhatk(test_start:test_stop);
disp(k + " Step Test Residual Variance: " + var(val_resid))
plotACFnPACF(val_resid, 20, k + " Step Test Residual");
figure
whitenessTest(val_resid);

%% check params
plot(Xsave(:, modelling_start:ed)')
hold on
yline(og_params')


