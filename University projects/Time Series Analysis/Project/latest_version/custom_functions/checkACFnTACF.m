function [] = checkACFnTACF(y)
%CHECKACFNTACF Summary of this function goes here
%   Detailed explanation goes here
figure
subplot(311)
tacfEstimate = tacf(y, 25, 0.02, 0.05, 1);
title('TACF')
subplot(312)
acfEstimate = acf(y, 25, 0.05, 1);
title('ACF')
subplot(313)
stem(abs(tacfEstimate - acfEstimate))
title('|ACF-TACF|')
end

