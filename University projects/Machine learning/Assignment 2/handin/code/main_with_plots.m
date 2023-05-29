clear; load A2_bundle/A2_data.mat
%%
[pc,~] = pca(train_data_01, 2);


%%
one = train_labels_01 == 1;
zer = train_labels_01 == 0;
label_1 = [pc(1,one); pc(2, one)];
label_0 = [pc(1, zer); pc(2, zer)];


scatter(label_0(1,:), label_0(2,:))
hold on
scatter(label_1(1,:), label_1(2,:))
title('Two-dimensional PCA on MNIST for labels 0 and 1')
legend(["Label: 0", "Label: 1"]);
xlabel('Dimension 1 of PCA')
ylabel('Dimension 2 of PCA')

saveas(gcf, "figs/PCA.png")

%%
clear; load A2_bundle/A2_data.mat; close all;
%% K-means clustering 
K = 5;
d = 2;

[label, centroids] = K_means_clustering(train_data_01, K);
[pc_data, U] = pca(train_data_01, d);

% the coordinates of the centroids must be projected to same 
% dimension as data: 
pc_centroids = U(:,1:d)'*(centroids-mean(train_data_01,2));
figure()
legends = strings(1,K+1);
for i = 1:K
    scatter(pc_data(1,label == i), pc_data(2,label==i))
    legends(i) = "Cluster: " + i;
    hold on 
end
legends(K+1) = "Centroids";
scatter(pc_centroids(1,:), pc_centroids(2,:),150,'black', 'hexagram', ...
    'filled')

title('Unsupervised clustering of MNIST, projected on two principal components')
xlabel('Dimension 1 of PCA')
ylabel('Dimension 2 of PCA')

legend(legends)
saveas(gcf, "figs/"+ K +"-means_clustering.png")


% Visualisation of the centroids
f = figure();
f.Position = [100 100 K*200+100 200];
sgtitle("Visualisation of the K = " + K + " cluster centroids")
for i = 1:K
    subplot(1,K,i)
    imshow(reshape(centroids(:,i),28,28))
    title("Centroid: " + i)
end

file = "figs/centroid_visual_K_" + K + ".png" ;

saveas(gcf,file)


%%
clear; clc; load A2_bundle/A2_data.mat
%%
K = 4;
[label, centroids] = K_means_clustering(train_data_01, K);

%% Labeling the centroids as the one that are similar to most 
% of the training samples:

distances = zeros(K,2);
alternatives = [0 1];

% finding the label of the centroids:
for i = 1:K
   distances(i,1) = norm(...
       centroids(:,i) - train_data_01(:,train_labels_01 == alternatives(1)));
   distances(i,2) = norm(...
       centroids(:,i) - train_data_01(:,train_labels_01 == alternatives(2)));
end
centroid_labels = zeros(1,K);

for i = 1:K
    [~,mindex] = min(distances(i,:));
    centroid_labels(i) = alternatives(mindex);

    % sanity check:
    subplot(1,K,i)
    imshow(reshape(centroids(:,i),28,28))
    title("Classified as: " + centroid_labels(i))
end
%% testing the classifier on train and test data
% the classifier takes as input the centroid coordinates and their label,
% as well as the sample to classify

N_train = length(train_data_01);
y = zeros(N_train,1);
assigned_cluster = zeros(N_train,1);

for i = 1:N_train
    sample = train_data_01(:,i);
    [y(i), assigned_cluster(i)] = K_means_classifier(sample,centroids,centroid_labels);
end

disp(" ")
disp("--------- Train data -------------")
disp("Accuracy on train data: " + 100*mean(y == train_labels_01) + "%")
disp("[train data]: Number of ones: " + sum(y == 1) + ", true value: " + sum(train_labels_01 == 1))
disp("[train data]: Number of zeros: " + sum(y == 0) + ", true value: " + sum(train_labels_01 == 0))

for i = 1:K
    disp(" ")
    disp("Cluster " + i + "/" + K + ". Cluster label: " + centroid_labels(i))
    nbrs_assigned_to_0 = sum(train_labels_01(assigned_cluster == i) == 0);
    nbrs_assigned_to_1 = sum(train_labels_01(assigned_cluster == i) == 1);
    
    disp("#'0' assigned to cluster " + i + ": " + nbrs_assigned_to_0)
    disp("#'1' assigned to cluster " + i + ": " + nbrs_assigned_to_1)
end

N_test = length(test_data_01);
y = zeros(N_test,1);
assigned_cluster = zeros(N_test,1);
for i = 1:N_test
    sample = test_data_01(:,i);
    [y(i), assigned_cluster(i)] = K_means_classifier( ...
        sample,centroids,centroid_labels);
end
disp(" ")
disp("--------- Test data -------------")
disp("accuracy on test data: " + 100*mean(y == test_labels_01) + "%")
disp("[test data]: Number of ones: " + sum(y == 1) + ", true value: " + sum(test_labels_01 == 1))
disp("[test data]: Number of zeros: " + sum(y == 0) + ", true value: " + sum(test_labels_01 == 0))

for i = 1:K
    disp(" ")
    disp("Cluster " + i + "/" + K + ". Cluster label: " + centroid_labels(i))
    nbrs_assigned_to_0 = sum(test_labels_01(assigned_cluster == i) == 0);
    nbrs_assigned_to_1 = sum(test_labels_01(assigned_cluster == i) == 1);
    
    disp("#'0' assigned to cluster " + i + ": " + nbrs_assigned_to_0)
    disp("#'1' assigned to cluster " + i + ": " + nbrs_assigned_to_1)
end


%% grid search

max_K = 20;
min_K = 2;
test_miss = zeros(1,max_K-min_K);
train_miss = zeros(1,max_K-min_K);
for K = min_K:max_K

    [label, centroids] = K_means_clustering(train_data_01, K);
    
    distances = zeros(K,2);
    alternatives = [0 1];
    
    % finding the label of the centroids:
    for i = 1:K
       distances(i,1) = norm(...
           centroids(:,i) - train_data_01(:,train_labels_01 == alternatives(1)));
       distances(i,2) = norm(...
           centroids(:,i) - train_data_01(:,train_labels_01 == alternatives(2)));
    end
    
    centroid_labels = zeros(1,K);

    for i = 1:K
        [~,mindex] = min(distances(i,:));
        centroid_labels(i) = alternatives(mindex);
    end
    
    N_train = length(train_data_01);
    y = zeros(N_train,1);
    assigned_cluster = zeros(N_train,1);
    
    for i = 1:N_train
        sample = train_data_01(:,i);
        [y(i), assigned_cluster(i)] = K_means_classifier(sample,centroids,centroid_labels);
    end
    train_miss(K) = 100*mean(~(y == train_labels_01));
    disp(" ")
    disp("---------------------")
    disp("K = " + K)
    disp("-- Training data --")
    disp("Misclassification rate: " + train_miss(K) + "%")
    N_test = length(test_data_01);
    
    y = zeros(N_test,1);
    assigned_cluster = zeros(N_test,1);

    for i = 1:N_test
        sample = test_data_01(:,i);
        [y(i), assigned_cluster(i)] = K_means_classifier( ...
            sample,centroids,centroid_labels);
    end
    test_miss(K) = 100*mean(~(y == test_labels_01));

    disp(" ")
    disp("-- Test data --")
    disp("Misclassification rate: " + test_miss(K) + "%")
    disp(" ")
    close all
end

%%
figure()
plot(2:K, test_miss(2:end),"LineWidth",2)
hold on
plot(2:K, train_miss(2:end),"LineWidth",2)
title("Missclassification rate for different values of K")
legend(["Test data", "Train data"])
ylabel("%")
xlabel("K")

file = "figs/missclassification_rate_grid.png";

saveas(gcf,file)
%% 
clear; clc; load A2_bundle/A2_data.mat;
%% Linear SVM
model = fitcsvm(train_data_01', train_labels_01);
Y_train = predict(model,train_data_01');
Y_test = predict(model,test_data_01');

%% Model assessment 
names = ["Train data", "Test data"];

disp("---" + names(1) + "---")
dataset = train_labels_01;
Y = Y_train;

predicted_0_was_0 = sum((Y == 0) & (dataset == 0));
predicted_0_was_1 = sum((Y == 0) & (dataset == 1));

predicted_1_was_0 = sum((Y == 1) & (dataset == 0));
predicted_1_was_1 = sum((Y == 1) & (dataset == 1));

disp("Predicted 0, true class 0: " + predicted_0_was_0)
disp("Predicted 0, true class 1: " + predicted_0_was_1)
disp("Predicted 1, true class 0: " + predicted_1_was_0)
disp("Predicted 1, true class 1: " + predicted_1_was_1)
disp("Misclassified: " + 100*(predicted_0_was_1 + predicted_1_was_0)/ ...
    (predicted_1_was_0 + predicted_0_was_1 + predicted_1_was_1 + predicted_0_was_0) ...
    + "%")
disp(" ")

disp("---" + names(2) + "---")
dataset = test_labels_01;
Y = Y_test;

predicted_0_was_0 = sum((Y == 0) & (dataset == 0));
predicted_0_was_1 = sum((Y == 0) & (dataset == 1));

predicted_1_was_0 = sum((Y == 1) & (dataset == 0));
predicted_1_was_1 = sum((Y == 1) & (dataset == 1));

disp("Predicted 0, true class 0: " + predicted_0_was_0)
disp("Predicted 0, true class 1: " + predicted_0_was_1)
disp("Predicted 1, true class 0: " + predicted_1_was_0)
disp("Predicted 1, true class 1: " + predicted_1_was_1)
disp("Misclassified: " + 100*(predicted_0_was_1 + predicted_1_was_0)/ ...
    (predicted_1_was_0 + predicted_0_was_1 + predicted_1_was_1 + predicted_0_was_0) ...
    + "%")
disp(" ")

%%
clear; load A2_bundle/A2_data.mat;
%% Gaussian kernel SVM grid search
tic

N_beta = 15;
beta_min = 3;
beta_max = 12;
betas = exp(linspace(log(beta_min), log(beta_max), N_beta));
lowest_mcr = 1.1;

conc_data = [train_data_01'; test_data_01'];
conc_labels = [train_labels_01; test_labels_01];
mcr_array = zeros(1,N_beta);
disp("Grid search of "+ N_beta + " values of beta between " + beta_min + " and " + beta_max)

for i = 1:N_beta
    beta = betas(i);
    disp("Search " + i + "/" + N_beta)
    disp("Current beta = " + beta);

    model = fitcsvm(train_data_01',train_labels_01, ...
        'KernelFunction','gaussian', 'KernelScale', beta);

    Y_train = predict(model,train_data_01');
    Y_test = predict(model,test_data_01');
    conc_Y = [Y_train; Y_test];
    mcr = mean(conc_Y ~= conc_labels);
    mcr_array(i) = mcr;

    if mcr < lowest_mcr
        best_model = model;
        best_beta = beta;
        lowest_mcr = mcr;
        disp("New best mcr: " + mcr*100 + "% ")
        disp("Achieved by beta= " + beta)
    end
end
disp("-------- Search complete --------")
disp("Lowest missclassification rate was " + lowest_mcr*100 + "%. Achieved by beta = " + best_beta)
toc

%% plotting grid search
figure()
plot(betas, mcr_array, "LineWidth",2)
title("Missclassification rate for different values of \beta")

xline_label = "Optimal \beta = " + best_beta;
xline(best_beta,'-',xline_label)

legend(["Test and train data", "Optimal \beta"])
ylabel("%")
xlabel("\beta")

file = "figs/gauss_missclassification_rate_grid.png";

saveas(gcf,file)


%%
Y_train = predict(best_model,train_data_01');
Y_test = predict(best_model,test_data_01');

%% model assessment
names = ["Train data", "Test data"];
disp(" ")
disp("---" + names(1) + "---")
dataset = train_labels_01;
Y = Y_train;

predicted_0_was_0 = sum((Y == 0) & (dataset == 0));
predicted_0_was_1 = sum((Y == 0) & (dataset == 1));

predicted_1_was_0 = sum((Y == 1) & (dataset == 0));
predicted_1_was_1 = sum((Y == 1) & (dataset == 1));

disp("Predicted 0, true class 0: " + predicted_0_was_0)
disp("Predicted 0, true class 1: " + predicted_0_was_1)
disp("Predicted 1, true class 0: " + predicted_1_was_0)
disp("Predicted 1, true class 1: " + predicted_1_was_1)
disp("Misclassified: " + 100*(predicted_0_was_1 + predicted_1_was_0)/ ...
    (predicted_1_was_0 + predicted_0_was_1 + predicted_1_was_1 + predicted_0_was_0) ...
    + "%")
disp(" ")

disp("---" + names(2) + "---")
dataset = test_labels_01;
Y = Y_test;

predicted_0_was_0 = sum((Y == 0) & (dataset == 0));
predicted_0_was_1 = sum((Y == 0) & (dataset == 1));

predicted_1_was_0 = sum((Y == 1) & (dataset == 0));
predicted_1_was_1 = sum((Y == 1) & (dataset == 1));

disp("Predicted 0, true class 0: " + predicted_0_was_0)
disp("Predicted 0, true class 1: " + predicted_0_was_1)
disp("Predicted 1, true class 0: " + predicted_1_was_0)
disp("Predicted 1, true class 1: " + predicted_1_was_1)
disp("Misclassified: " + 100*(predicted_0_was_1 + predicted_1_was_0)/ ...
    (predicted_1_was_0 + predicted_0_was_1 + predicted_1_was_1 + predicted_0_was_0) ...
    + "%")







