function dldX = relu_backward(X, dldY)
    greater_than_zero = X > 0;
    dldX = dldY.*greater_than_zero;
end
