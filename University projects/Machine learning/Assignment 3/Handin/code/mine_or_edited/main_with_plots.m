test_fully_connected
%%
test_relu
%%
test_softmaxloss
test_gradient_whole_net
%%
mnist_starter
%%
[predictions, ground_truth] = mnist_with_assignment;
%%
load A3_bundle/models/network_trained_with_momentum.mat
%% plot kernels
first_layer_weights = net.layers{2}.params.weights; 
% the weights of the first layer, should be 5x5x1x16

sz = size(first_layer_weights);

figure();
for i = 1:sz(1,4)
    subplot(4,4,i)
    kernel = first_layer_weights(:,:,1,i);
    imshow(kernel);
    title("Kernel: " + i);
end

file = "figs/kernel_illustration.png";
saveas(gcf,file)
%% display misclassified images
images = loadMNISTImages('data/mnist/t10k-images.idx3-ubyte');
images = reshape(images, [28, 28, 1, 10000]);
classes = [1:9 0];

subplot_grid_sz = 3;
misclassified_images = images(:,:,1,ground_truth ~= predictions);
misc_gt = classes(ground_truth(ground_truth ~= predictions));
misc_pr = classes(predictions(ground_truth ~= predictions));

images_to_show = randperm(length(misclassified_images),subplot_grid_sz^2);
figure()
count = 1;
for index = images_to_show
    subplot(subplot_grid_sz,subplot_grid_sz,count)
    imshow(misclassified_images(:,:,1,index));
    title("True: " + misc_gt(index) + ", Predicted: " + misc_pr(index))
    count = count+1;
end

file = "figs/missclassified_images.png";
saveas(gcf,file)

%% confusion_matrix
mnist_confusion_matrix = confusion_matrix(predictions,ground_truth,classes);

figure;
confusionchart(mnist_confusion_matrix, classes)

file = "figs/confusion_matrix.png";
saveas(gcf,file)

%% Precision and recall:

% precision = nbr_correct/nbr_predicted
% recall = nbr_correct/nbr_available 

% in the confusion matrix, the number of correct predictions for each class
% i is the number at position i in the diagonal. The false i:s, that is the
% ones that were predicted as i but were class j are found at row i and
% column j. If we sum up the columns to one 10 row column vector, the 
% number of true samples of class i are found at row i. If we instead sum up the
% rows to one 10 column row vector we get all the predictions of class j at
% column j.

precision = diag(mnist_confusion_matrix)./sum(mnist_confusion_matrix,1)';
recall = diag(mnist_confusion_matrix)./sum(mnist_confusion_matrix,2);

fprintf("Label: \t Precision: \t Recall: \n")
disp([classes' precision recall])

%% Number of layers:
count_params(net)
%%
clear;
%%
cifar10_starter
%%
load A3_bundle/models/cifar10_baseline.mat
count_params(net)
%%
% extract and preprocess data just like the baseline:

[x_train, z_train, x_test, z_test, classes] = load_cifar10(2);

% Always subtract the mean. Optimization will work much better if you do.
data_mean = mean(mean(mean(x_train, 1), 2), 4); % mean RGB triplet

x_train = bsxfun(@minus, x_train, data_mean);
x_test = bsxfun(@minus, x_test, data_mean);
% and shuffle the examples. Some datasets are stored so that all elements of class 1 are consecutive
% training will not work on those datasets if you don't shuffle
perm = randperm(numel(z_train));
x_train = x_train(:,:,:,perm);
z_train = z_train(perm);

% we use 2000 validation images
x_val = x_train(:,:,:,end-2000:end);
y_val = z_train(end-2000:end);
x_train = x_train(:,:,:,1:end-2001);
z_train = z_train(1:end-2001);

% the last layer before fully connected, that is layers{end-2} is
% (5x5x16x16)

% remove the fully connected and add more convolutions:
net.layers{end-1} = struct( ...
    'type', 'convolution', ...
    'params', struct('weights', 0.1*randn(5,5,16,16)/sqrt(5*5*16/2), ...
    'biases', zeros(16,1)), ...
    'padding', [2 2]);

% remove the softmax and add relu and maxpooling

net.layers{end} = struct('type', 'relu');

net.layers{end+1} = struct('type', 'maxpooling');

% size is now (16/2)x(16/2)x16

net.layers{end+1} = struct( ...
    'type', 'convolution', ...
    'params', struct('weights', 0.1*randn(5,5,16,16)/sqrt(5*5*16/2), ...
    'biases', zeros(16,1)), ...
    'padding', [2 2]);

net.layers{end+1} = struct('type', 'relu');

net.layers{end+1} = struct( ...
    'type', 'fully_connected', ...
    'params', struct('weights', randn(10,8*8*16)/sqrt(8*8*16/2), ...
    'biases', zeros(10,1)));

net.layers{end+1} = struct('type', 'softmaxloss');

[a, b] = evaluate(net, x_train(:,:,:,1:8), z_train(1:8), true);

%%
training_opts = struct('learning_rate', 1e-3,...
        'iterations', 3000,...
        'batch_size', 16,...
        'momentum', 0.95,...
        'weight_decay', 0.001);

%%
count_params(net)
net = training(net, x_train, z_train, x_val, y_val, training_opts);

%%
d = string(datetime("now", 'ConvertFrom', 'datenum','Format', 'yyMMdd-hhmm'));
name = "A3_bundle/models/cifar10_" + d + ".mat";
save(name, 'net')


%%
% evaluate on the test set

pred = zeros(numel(z_test),1);
batch = training_opts.batch_size;
for i=1:batch:size(z_test)
    idx = i:min(i+batch-1, numel(z_test));
    % note that z_test is only used for the loss and not the prediction
    z = evaluate(net, x_test(:,:,:,idx), z_test(idx));
    [~, p] = max(z{end-1}, [], 1);
    pred(idx) = p;
end
fprintf('Accuracy on the test set: %f\n', mean(vec(pred) == vec(z_test)));

%% this did not improve the accuracy too much.
% we have actually lowered the number of parameters. We can also see that
% we have not yet converged. We therefore add one more convolutional layer
% and train for more iterations
load A3_bundle/models/cifar10_230510-0401.mat

% remove the fully connected and softmax and add the convolution
net.layers{end-1} = struct( ...
    'type', 'convolution', ...
    'params', struct('weights', 0.1*randn(5,5,16,16)/sqrt(5*5*16/2), ...
    'biases', zeros(16,1)), ...
    'padding', [2 2]);

% add relu
net.layers{end} = struct('type', 'relu');

net.layers{end+1} = struct( ...
    'type', 'convolution', ...
    'params', struct('weights', 0.1*randn(5,5,16,16)/sqrt(5*5*16/2), ...
    'biases', zeros(16,1)), ...
    'padding', [2 2]);

% size is still (16/2)x(16/2)x16
net.layers{end+1} = struct( ...
    'type', 'fully_connected', ...
    'params', struct('weights', randn(10,8*8*16)/sqrt(8*8*16/2), ...
    'biases', zeros(10,1)));

net.layers{end+1} = struct('type', 'softmaxloss');

count_params(net)

%%
training_opts = struct('learning_rate', 1e-3,...
        'iterations', 7500,...
        'batch_size', 16,...
        'momentum', 0.95,...
        'weight_decay', 0.001);
%%
net = training(net, x_train, z_train, x_val, y_val, training_opts);

%%
d = string(datetime(now, 'ConvertFrom', 'datenum','Format', 'yyMMdd-hhmm'));
name = "A3_bundle/models/cifar10_" + d + ".mat";
save(name, 'net')

%%
pred = zeros(numel(z_test),1);
batch = training_opts.batch_size;
for i=1:batch:size(z_test)
    idx = i:min(i+batch-1, numel(z_test));
    % note that z_test is only used for the loss and not the prediction
    z = evaluate(net, x_test(:,:,:,idx), z_test(idx));
    [~, p] = max(z{end-1}, [], 1);
    pred(idx) = p;
end
fprintf('Accuracy on the test set: %f\n', mean(vec(pred) == vec(z_test)));

%%
cifar_conf_matrix = confusion_matrix(pred,z_test,classes);

figure;
confusionchart(cifar_conf_matrix,classes)

file = "figs/cifar_confusion_matrix.png";
saveas(gcf,file)

%%
precision_recall(cifar_conf_matrix,string(classes));

%%
count_params(net);
%%
subplot_grid_sz = 3;

[~, ~, vis_x_test, ~, ~] = load_cifar10(2);

misclassified_images = vis_x_test(:,:,:,pred ~= z_test);
misc_gt = classes(z_test(pred ~= z_test));
misc_pr = classes(pred(pred ~= z_test));

images_to_show = randperm(length(misclassified_images),subplot_grid_sz^2);
figure()
count = 1;
for index = images_to_show
    subplot(subplot_grid_sz,subplot_grid_sz,count)
    imagesc(misclassified_images(:,:,:,index)/255);
    title("True: " + misc_gt(index) + ", Pred: " + misc_pr(index))
    count = count+1;
    colormap("default")
    axis off;
end

file = "figs/cifar_missclassified_images.png";
saveas(gcf,file)
%%
first_layer_weights = net.layers{2}.params.weights; 
% the weights of the first layer, should be 5x5x1x16

sz = size(first_layer_weights);

figure();
for i = 1:sz(1,4)
    subplot(4,4,i)
    kernel = rescale(first_layer_weights(:,:,:,i));
    image(kernel);
    title("Kernel: " + i);
end

file = "figs/cifar_kernel_illustration.png";
saveas(gcf,file)


