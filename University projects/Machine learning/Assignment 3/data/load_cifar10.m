
function [x_train, z_train, x_test, z_test, classes] = load_cifar10(N)
    for i=1:N
        batch = load(sprintf('data/cifar-10-batches-mat/data_batch_%d.mat', i));
        x = batch.data;
        x = reshape(x', [32, 32, 3, 10000]);
        x = permute(x, [2 1 3 4]);
        x = double(x);
        z = vec(batch.labels+1); % starts at 0 otherwise

        if i==1
            x_train = x;
            z_train = z;
        else
            x_train = cat(4, x_train, x);
            z_train = cat(1, z_train, z);
        end
    end
    
    batch = load('data/cifar-10-batches-mat/test_batch.mat');
    x = batch.data;
    x = reshape(x', [32, 32, 3, 10000]);
    x = permute(x, [2 1 3 4]);
    x = double(x);
    z = vec(batch.labels+1); % starts at 0 otherwise
    x_test = x;
    z_test = z;
    
    meta = load('data/cifar-10-batches-mat/batches.meta.mat');
    classes = meta.label_names;
end
