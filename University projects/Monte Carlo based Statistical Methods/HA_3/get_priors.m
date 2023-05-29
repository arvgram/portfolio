function [theta, lambda,t] = get_priors(d,psi)
    t = zeros(1,d+1);
    t(1) = 1658; t(d+1) = 1980;
    lambda = zeros(1,d);
    theta = gamrnd(2,1/psi);
    lambda(1:d) = gamrnd(2,1/theta(1),1,d);

    u = 1; fxex = 0;
    mu = (t(d+1)-t(1))/d*linspace(1,d-1,d-1)+t(1);
    Sigma = (t(d+1)-t(1))*10*eye(d-1);
    alpha = map_d_to_alpha(d);
    gpdf = @(x) mvnpdf(x,mu,Sigma);

    while u > fxex
        g = mvnrnd(mu,Sigma,1);
        ex = gpdf(g)./alpha;
        fx = fpdf(g,t,d);
        fxex = fx./ex;
        u = rand;
        for i = 1:d-2
            if g(i+1) < g(i)
                fxex = 0;
            end
        end
        t(2:d) = g;
    end
end

function alpha = map_d_to_alpha(d)
    switch d
        case 2
            alpha = 1e-7;
        case 3
            alpha = 1e-10;
        case 4
            alpha = 1e-14;
        case 5
            alpha = 1e-17;
        otherwise
            alpha = 1e-20;
    end
end

function [fx] = fpdf(T,t,d)
    fx = T(1)-t(1);
    if d >= 3
        for i = 2:d-1
            fx = fx*(T(i)-T(i-1));
        end
    end
    fx = fx*(t(d+1)-T(d-1));
end
