function [residualsDeemedWhite,arma_model] = testARMA(data,p,q)
    % Tests if an ARMA-model of order p,q is a good fit
    %   Detailed explanation goes here
    arma_model = armax(data, [p,q]);
    e_hat = filter(arma_model.A, arma_model.C, data);
    e_hat = e_hat(length(arma_model.A):end);
    [residualsDeemedWhite, ~,~] = montiTest(e_hat, 20, 0.05);
end

