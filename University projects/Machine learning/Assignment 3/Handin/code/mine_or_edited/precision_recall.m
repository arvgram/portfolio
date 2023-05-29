function [precision,recall] = precision_recall(confusion_matrix,classes)
%PRECISION_RECALL returns the precision and recall from confusion_matrix

precision = diag(confusion_matrix)./sum(confusion_matrix,1)';
recall = diag(confusion_matrix)./sum(confusion_matrix,2);

fprintf("Label: \t Precision: \t Recall: \n")
disp([classes precision recall])
end

