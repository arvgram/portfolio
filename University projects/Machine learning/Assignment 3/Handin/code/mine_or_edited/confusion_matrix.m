function [confusion_matrix] = confusion_matrix(predictions,ground_truth, classes)
%CONFUSION_MATRIX Summary of this function goes here
%   Detailed explanation goes here

confusion_matrix = zeros(length(classes));

for i = 1:length(ground_truth)
    confusion_matrix(ground_truth(i), predictions(i)) = ...
        confusion_matrix(ground_truth(i), predictions(i)) + 1;
end

end

