%train_in are input data set [m_in, n];
%train_out are output data set [m_out, n];
%m_in is the number of inputs. m_out is the number of outputs.
function [regnn] = region_svm_train( options, train_idx, train_in, train_out, minaxpn, test_idx, test_in, test_out, centers )
n_inputs = size(train_in, 1);
n_outputs = size( train_out, 1);
n_count = size(train_in, 2);

n_networks = size( train_idx, 2 );
temp_train_in = [];
temp_train_out = [];
temp_test_in = [];
temp_test_out = [];
regnn = [];

save_train_in = [];
save_train_out = [];
save_test_in = [];
save_test_out = [];
for i=1:n_networks
    %{
    if( i>1 )
        temp_train_in = save_train_in;
        temp_train_out = save_train_out;
        temp_test_in = save_test_in;
        temp_test_out = save_test_out;
    end
    %}

    idx = train_idx{1, i};
    n = size(idx,1);
    for j=1:n
        temp_train_in = [temp_train_in train_in(:, idx(j))];
        temp_train_out = [temp_train_out train_out(:, idx(j))];
    end
    idx = test_idx{1, i};
    n = size(idx, 1);
    for j=1:n
        temp_test_in = [temp_test_in test_in(:, idx(j))];
        temp_test_out = [temp_test_out test_out(:, idx(j))];
    end
    
    if( i==2 )
        options = '-c 0.20 -g 45 -p 0.22 -s 3 -t 2';
    end
    if( i==3 )
        options = '-c 0.8 -g 2 -p 0.95 -s 3 -t 2';
        options = '-c 1.5 -g 2 -p 0.4 -s 3 -t 2';
    end
    reg = reg_train( options, temp_train_in, temp_train_out, centers{i} );
    regnn = [regnn; reg];

    if( i==1 )
        save_train_in = temp_train_in;
        save_train_out = temp_train_out;
        save_test_in = temp_test_in;
        save_test_out = temp_test_out;
    end
        
    temp_train_in = [];
    temp_train_out = [];
    temp_test_in = [];
    temp_test_out = [];

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                               sub functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [reg] = reg_train( options, train_in, train_out, center )
reg = calc_region( train_in' );
%reg.center = center;

model = svmtrain( train_out', train_in', options );
reg.net = model;

svmpredict( train_out', train_in', model );