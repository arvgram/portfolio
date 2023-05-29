clear;
load A1_data.mat
%% lasso optimization

lambdas = [0.1, 2, 10];
f = figure();
f.Position = [100 100 1000 600];

sgtitle("Reconstructed data using different regularisation parameters \lambda")

for i = 1:3
    lambda = lambdas(i);
    subplot(1,3,i);
    w = lasso_ccd(t,X,lambda);
    scatter(n,t)
    hold on
    scatter(n,X*w)
    plot(ninterp,Xinterp*w)
    title("\lambda = " + lambda)
    legend(["Data", "Reconstructed data", "Interpolated rec. data"])
end

path = "figs/";
name = "plotlambda";
saveas(gcf, path+name,'png')


%% count of number of non-zero elements

N_lambda = 100;
lambda_min = 0.01;
lambda_max = 20;
lambdas = exp(linspace(log(lambda_min), log(lambda_max), N_lambda));

no_nonzero = zeros(length(lambdas),1);
for i = 1:length(lambdas)
    no_nonzero(i) = sum(lasso_ccd(t,X,lambdas(i)) ~= 0);
end
f = figure();
f.Position = [100 100 800 400];

plot(lambdas,no_nonzero, LineWidth=2)
title("The number of non-zero weights for different values of \lambda")
legend("Number of non-zero weights")
xlabel("\lambda")


saveas(gcf, "figs/nonzero.png")

%% Illustrating cross fold validation of hyperparameters
N_lambda = 100;
lambda_min = 0.01;
lambda_max = 10;
lambda_grid = exp(linspace(log(lambda_min), log(lambda_max), N_lambda));
[wopt,lambdaopt,RMSEval,RMSEest] = lasso_cv(t,X,lambda_grid, 5);

f = figure();
f.Position = [100 100 600 400];

plot(lambda_grid,RMSEval,'-o','MarkerIndices',1:N_lambda)
hold on
plot(lambda_grid,RMSEest,'-*','MarkerIndices',1:N_lambda)

xline_label = ['Optimal \lambda = ' num2str(lambdaopt)];
xline(lambdaopt,'-',xline_label)
title("RMSE for validation and estimation data for different values of " + ...
    "regularisation parameter \lambda")
legend(["RMSE on valdidation data", "RMSE on estimation data"])
xlabel("\lambda")


saveas(gcf, "figs/cross_val.png")

%% Reconstruction with optimal lambda

f = figure();
f.Position = [100 100 600 400];

scatter(n,t)
hold on
scatter(n,X*wopt)
plot(ninterp,Xinterp*wopt)
title("Reconstructed data compared to the original data with \lambda = " + lambdaopt)
legend(["Data", "Reconstructed data", "Interpolated recon. data"])

path = "figs/";
name = "optlambda";
saveas(gcf, path+name,'png')

%% cleaning before last part
clear;
load A1_code_and_data/A1_data.mat
%%
N_lambda = 100;
lambda_min = 0.0001;
lambda_max = 0.2;
lambda_grid = exp(linspace(log(lambda_min), log(lambda_max), N_lambda));

[wopt,lambdaopt,RMSEval,RMSEest] = multiframe_lasso_cv(Ttrain,Xaudio,lambda_grid, 5);

%% plot
f = figure();
f.Position = [100 100 600 400];

plot(lambda_grid,RMSEval,'-o','MarkerIndices',1:N_lambda)
hold on
plot(lambda_grid,RMSEest,'-*','MarkerIndices',1:N_lambda)

xline(lambdaopt,'-',"Optimal \lambda = " + lambdaopt)
title("RMSE for validation and estimation data for different values of " + ...
    "regularisation parameter \lambda")
legend(["RMSE on valdidation data", "RMSE on estimation data"])
xlabel("\lambda")


saveas(gcf, "figs/multiframe_cross_val.png")

%% testing around

full_track = [Ttrain; Ttest];
denoised_full = lasso_denoise(full_track, X, 1);
%%
soundsc(full_track, fs)
pause(length(full_track)/fs + 1)
soundsc(denoised, fs)


%%
Ytest = lasso_denoise(Ttest,Xaudio,lambdaopt);


save('denoised','Ytest','fs')
%%


