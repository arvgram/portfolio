function [] = presentResiduals(resid_1_model, title, plotIt)
if nargin < 3
    plotIt = 0;
end
if nargin < 2
    title = getVarName(resid_1_model);
end

% Check model residual
disp("########################## Residual Analysis on " + title + " ##########################")

disp("Variance residual of: " + title + " is " + var(resid_1_model))
data = resid_1_model;

N = length(resid_1_model);
n = floor(N/2);
significanceLvl = 0.05;
K = 24;

fprintf('Whiteness test with %d%% significance\n', significanceLvl*100)  


% Perform various tests.
[S, Q, chiV] = lbpTest( data, K, significanceLvl );
fprintf('  Ljung-Box-Pierce test: %d (white if %5.2f < %5.2f)\n', S, Q, chiV) 

[S, Q] = mlTest( data, K, significanceLvl );
fprintf('  McLeod-Li test:        %d (white if %5.2f < %5.2f)\n', S, Q, chiV) 

[S, Q] = montiTest( data, K, significanceLvl );
fprintf('  Monti test:            %d (white if %5.2f < %5.2f)\n', S, Q, chiV) 

[ nRatio, confInt ] = countSignChanges( data, 1-significanceLvl );
 fprintf('  Sign change test:      %d (white if %4.2f in [%4.2f,%4.2f])\n', nRatio>confInt(1) & nRatio<confInt(2), nRatio, confInt(1), confInt(2) ) 


if plotIt
    plotACFnPACF(resid_1_model, 50, title, 0.05);
    figure
    whitenessTest(resid_1_model)
    title(title)
end

