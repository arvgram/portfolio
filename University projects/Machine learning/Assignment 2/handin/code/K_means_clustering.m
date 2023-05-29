function [y,C] = K_means_clustering(X,K)

% Calculating cluster centroids and cluster assignments for:
% Input:    X   DxN matrix of input data
%           K   Number of clusters
%
% Output:   y   Nx1 vector of cluster assignments
%           C   DxK matrix of cluster centroids

[D,N] = size(X);

intermax = 50;
conv_tol = 1e-6;
% Initialize
C = repmat(mean(X,2),1,K) + repmat(std(X,[],2),1,K).*randn(D,K);
y = zeros(N,1);
Cold = C;

for kiter = 1:intermax
    % CHANGE
    % Step 1: Assign to clusters
    y = step_assign_cluster(X, Cold);
    
    % Step 2: Assign new clusters
    [C, movement] = step_compute_mean(X, Cold, y);
    
    if movement < conv_tol
        return
    end
    Cold = C;
    % DO NOT CHANGE
end

end

function d = fxdist(x,C)
    % CHANGE
    d = norm(x-C);
    % DO NOT CHANGE
end

function d = fcdist(C1,C2)
    % CHANGE
    d = norm(C1-C2);
    % DO NOT CHANGE
end

function clusters = step_assign_cluster(X ,C)
    [~,K] = size(C);
    [~,N] = size(X);
    clusters = zeros(N,1);
    
    for i = 1:N 
        d = zeros(1,K);
        for j=1:K
            d(j) = fxdist(X(:,i), C(:,j));
        end
        [~, clusters(i)] = min(d);
    end
end

function [C_new, movement] = step_compute_mean(X, C, clusters)
    C_new = zeros(size(C));
    [~,K] = size(C);
    for i = 1:K
        C_new(:,i) = mean(X(:,i==clusters), 2);
    end
    movement = fcdist(C,C_new);
end




