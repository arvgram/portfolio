function number_of_params = count_params(net)
%COUNT_PARAMS counts the number of params in a net

number_of_params = 0;

for l = 1:length(net.layers)
    disp("---------------")
    local_number_of_params = 0;
    layer = net.layers{l};
    disp("Layer number: " + l + "/" + length(net.layers))
    disp("Layer type: " + layer.type)
    if isfield(layer,'params')      
        if isfield(layer.params,'weights')
            sz = size(layer.params.weights);
            w = sz(1);
            w_str = "Weights: " + w;
            for i = 2:length(sz)
                w = w*sz(i);
                w_str = w_str + " x " + sz(i);
            end
            disp(w_str)
            disp("Weights in layer " + l + ": " + w)
            local_number_of_params = local_number_of_params + w;
        end

        if isfield(layer.params,'biases')
            sz = size(layer.params.biases);
            b = sz(1);
            for i = 2:length(sz)
                b = b*sz(i);
            end
            disp("Biases in layer " + l + ": " + b)
            local_number_of_params = local_number_of_params + b;
        end
    end
    disp("Number of parameters in layer " + l + ": " + local_number_of_params)
    number_of_params = number_of_params + local_number_of_params;
end
disp("-----------")
disp("Total number of params: " + number_of_params)
end

