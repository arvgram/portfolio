function [y] = simulateMyARMA(A, C, N, seed, sig2)
    %SIMULATEMYARMA Simulates ARMA-process with poly A, C
    %   Detailed explanation goes here
    switch nargin
        case 2
            N = 10000;
            seed = 0;
            sig2 = 1;
    
        case 3
            seed = 0;
            sig2 = 1;
        
        case 4
            sig2 = 1;
    end
    extraN = 100;
    rng(seed);
    e = sqrt(sig2)*randn(N+extraN,1);
    y = filter(C, A, e);
    y = y(extraN+1:end);

end


