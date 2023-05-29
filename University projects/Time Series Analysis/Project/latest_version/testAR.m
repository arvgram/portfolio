function [residualsDeemedWhite,ar_model] = testAR(data,p)
    %TESTAR Tests if an AR-model of order p is a good fit.
    %   Detailed explanation goes here
    ar_model = arx(data, p);
    e_hat = filter(ar_model.A, ar_model.C, data);
    e_hat = e_hat(length(ar_model.A):end);
    [residualsDeemedWhite, ~, ~] = montiTest(e_hat, 20, 0.05);
end

