function [theta, lambda, t] = get_posteriors(rho, lambda, t, tau, d, psi)
    
    % Metropolis-Hastings
    tstar = zeros(d+1,1);
    tstar(1) = 1658; tstar(d+1) = 1980;
    tnew = zeros(d+1,1);
    tnew(1) = 1658; tnew(end) = 1980;
    for i = 2:d % one at a time
        R = rho*(t(i+1)-t(i-1));
        epsilon = 2*R*rand-R;
        tstar(i) = t(i)+epsilon;
        ft = @(t,j) tpdf2(t,tau,j,lambda);
        f1 = ft(tstar,i);
        f2 = ft(t,i);
        alpha = min(0, log(f1)-log(f2));
        u = log(rand);
        if (u <= alpha) && (tstar(i) > tnew(i-1)) && (tstar(i) < t(i+1))
            tnew(i) = tstar(i);
        else
            tnew(i) = t(i);
        end
    end

    % Gibbs
    theta = gamrnd(2d+1,1/(psi+sum(lambda)));
    for i = 1:d
        ntau = sum(tnew(i)<tau & tau<tnew(i+1));
        lambda(i) = gamrnd(ntau+2,1/(theta+tnew(i+1)-tnew(i)));
    end
    
    t = tnew;
end

%%
function [ft] = tpdf(t,tau,d,lambda)
    ft = 1;
    for i = 2:d
        nt = sum(t(i)<tau & tau<t(i+1));
        ft = ft*(t(i+1)-t(i))*lambda(i)^nt*exp(-lambda(i)*(t(i+1)-t(i)));
    end
end

%%
function [ft] = tpdf2(t,tau,k,lambda)
    nt = sum(t(k)<tau & tau<t(k+1));
    ft = (t(k+1)-t(k))*lambda(k)^nt*exp(-lambda(k)*(t(k+1)-t(k)));
end

%%
function [rt] = rpdf(t,T,R,d)
    rt = 1;
    for k = 2:d
        rt = rt.*unifpdf(t(k),T-R,T+R);
    end
end
