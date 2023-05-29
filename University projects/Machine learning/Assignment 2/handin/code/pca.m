function [pc,U] = pca(data , target_dim)
%pca PCA projects data to target_dim number of dimension.
%   returns a matrix of dimension target_dim x length(data)

    % make the data zero mean:
    data = data - mean(data,2); 

    % perfrom singular value decomposition:
    [U,~,~] = svd(data);

    pc = U(:,1:target_dim)'*data;
end

