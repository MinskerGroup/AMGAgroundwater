%gate_w is [n_inputs, n_networks] matrix.
function [predict, mse] = region_ann_modular_predict( regnn, gate_w, data, cluster_mx )
n_inputs = size( regnn(1).center, 2 );
count = size(data, 2);
n_networks = size( regnn, 1 );

%the input data matrix
data_in = data(1:n_inputs, :);

%predict for each network y_net[n_networks, count]
y_net = [];
for i=1:n_networks
    y_net = [y_net; sim(regnn(i).net, data_in) ];
end

%compute the trust matrix
if( nargin==3 )
    cluster_mx = calc_clustermx( regnn, data_in );
end

%compute u and g
u = exp( gate_w' * data_in ) .* cluster_mx';
g = u  ./ ( ones(n_networks, 1)*sum(u, 1) );

%modulate the outputs.
predict = sum( g.*y_net, 1 );

%check if the data has test output in it
calc_mse = false;
if( size(data,1)>n_inputs )
    calc_mse = true;
end

%if needs to compute mse, do it.
if( calc_mse )
    n_outputs = size(predict,1);
    true_out = data( n_inputs+1:n_inputs+n_outputs, : );
    mse = sum( (predict-true_out).^2, 1 );
    mse = sum( mse ) / n_outputs / count;
end

%disp( [ exp(gate_w'*data_in); g; (predict-true_out).^2 ]' );