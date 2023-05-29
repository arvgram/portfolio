function [label, mindex] = K_means_classifier(x,centroids, centroid_labels)
% takes as input a sample, the centroids of the K means and their labels
% returns the classified label and the index of the cluster it was
% assigned to.

    [~,K] = size(centroids);
    ds = zeros(1,K);
    for i = 1:K
        ds(i) = norm(x-centroids(:,i));
    end
    [~, mindex] = min(ds);

    label = centroid_labels(mindex);
    return
    
end
