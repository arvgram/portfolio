function showProc(y)
    figure
    subplot(311)
    acf(y, floor(length(y)/10), 0.05, 1);
    title('ACF')
    subplot(312)
    pacf(y, floor(length(y)/10), 0.05, 1);
    title('PACF')
    subplot(313)
    normplot(y)
end

