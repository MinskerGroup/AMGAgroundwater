function [errors] = reg_nitr( minpts )
minaxp = [
0   0.2	0   0	0	0   ;
0.9 0.9	0.6	0.6	0.6	1.0 ];
minaxp = minaxp';
minaxpn = bounds(6, -0.9, 0.9);
minaxt = [0 15.0];
minaxtn = [0.0 1.0];

center = [-0.8703    0.1877   -0.7609   -0.7619   -0.7297    0.0657]';
center = [-0.8963    0.2246   -0.7964   -0.7781   -0.7385    0.5301]';
center = [-0.8522    0.2040   -0.7202   -0.6775   -0.6623   -0.3773]';
center2 = [-0.7891    0.1609   -0.6336   -0.5962   -0.5872   -0.4088]';
center = [-0.8522    0.2040   -0.4202   -0.6775   -0.6623   -0.3773]';

%center = [-0.8930    0.3095   -0.7644   -0.7720   -0.6927    0.4907]';
center = [-0.8465    0.1869   -0.7202   -0.6226   -0.6683   -0.3921]';

%center = [center center2];
%center = [-0.7891    0.1609   -0.6336   -0.5962   -0.5872   -0.4088]';
%center = [-0.8087    0.1766   -0.6339   -0.6068   -0.5934   -0.1955]';
%center = [ -0.7811   -0.0429   -0.8421   -0.8238   -0.5800   -0.5252 ]';
%center = [-0.8670   -0.0429   -0.7811   -0.7689   -0.7689   -0.5745]';
%center =  [-0.8743    0.2639   -0.6782   -0.6772   -0.6478  0.4583]';
center = [-0.8756    0.2371   -0.6801   -0.6801   -0.6593    0.4881]';

center = [-0.8963	0.2246	-0.7964	-0.7781	-0.7385	0.5301]'; %c3
%center = [-0.8966	0.2331	-0.8025	-0.7781	-0.74	0.5129]'; %c7
%center = [-0.8519	0.204	-0.7065	-0.6729	-0.6546	-0.36]'; %c8
%center = [-0.7862    0.1417   -0.6256   -0.5891   -0.5860   -0.4273]'; 

center = [-0.6905    0.0532   -0.4428   -0.5038   -0.4550   -0.7027]';
center = [-0.8727    0.2238   -0.6501   -0.5708   -0.4702   -0.6386]';
center = [-0.8590    0.2660   -0.6674   -0.6582   -0.6307    0.3757]';
center = [-0.8573    0.2778   -0.6616   -0.6524   -0.6266    0.3517]';
center = [   -0.8150    0.1688   -0.6451   -0.6217   -0.6118   -0.1880 ]';
center = [-0.8519	0.204	-0.7065	-0.6729	-0.6546	-0.36]'; %c8
center = [-0.8168    0.1626   -0.6492   -0.6261   -0.6149   -0.1631]';


ntrains = 155;
data = load('93odd.dat');

%ntrains = 151;
%data = load('93half.dat');

p = data(:,1:6);
t = data(:,7);
p = p';
p = normalize( p, minaxp, minaxpn );
t = t';
t = normalize( t, minaxt, minaxtn );

vp = p(: , ntrains+1:size(p,2));
vt = t(: , ntrains+1:size(p,2));
pn = p(:, 1:ntrains);
tn = t(:, 1:ntrains);

nodes = [4, 1];
regs = region_train( nodes, pn, tn, center, minpts, minaxpn, vp, vt );

%[net, tr] = train( net, pn, tn );
%[net, tr] = train( net, pn, tn, [], [], vv );

%data = load('valid_g1.dat');
%vp = data(:,1:6);
%vt = data(:,7);
%vp = vp';
%vt = vt';

tp = region_ann_predict( regs, vp );

[corr_norm nmse_norm rmse_norm] = test_errors( tp, vt );
%unnormalize the data.
tp = unnormalize( tp, minaxt, minaxtn );
vt = unnormalize( vt, minaxt, minaxtn );
[corr nmse rmse] = test_errors( tp, vt );

center = center(:,1);
%compute the distance of the points to the center
%center = [-0.8703    0.1877   -0.7609   -0.7619   -0.7297    0.0657]';
%center = [-0.6950    0.2831   -0.2613   -0.1752   -0.2144   -0.0539]';
d = zeros(size(tp,2),1);
for i=1:size(tp,2)
    d(i,1) = distance( vp(:,i), center );
end
error = (tp-vt).^2;
error = error';
error = [d, error];
y = sortrows( error, 1 );
figure(1);
plot( y(:,1), y(:,2), 'x' );

%compute the RMSE.
err = sum( (tp-vt).^2 )/size(vt,2);
disp( 'corr_norm, nmse_norm, rmse' );
disp( [corr_norm nmse_norm rmse] );

y = [tp', vt'];

figure(2);
plot( y );

figure(2);
plot( vt', tp', 'x' );
%min(tp)
hold on;
plot( [0; 16], [0; 16], 'r' );
plot( [10; 10], [0; 16], ':' );
plot( [0; 16], [10; 10], ':' );
axis( [0 16 0 16] );
hold off;

[fp, fn, eall] = count_false( tp, vt );
disp( 'false_positive, false_negative, accuracy' );
disp( [fp fn eall] );

errors = [corr_norm nmse_norm rmse fp fn eall];
return;

p = p';
sils = zeros(7,1);
for i=1:7
    idx = kmeans(p, i+1, 'distance', 'city');
    sil = silhouette(p, idx, 'city');
    sils(i) = mean(sil);
end

plot(sils);

sils

%tp - the predicted result of model
%tn - the true results.
function [corr_norm mse_norm rmse] = test_errors( tp, tn )
%compute normalized MSE
mse_norm = sum( (tp-tn).^2 ) / size(tn,2) / var(tn');

%compute coefficient.
corr_norm = corrcoef( tp', tn' );
corr_norm = corr_norm(1, 2);

%compute the RMSE.
rmse = sqrt( sum( (tp-tn).^2 )/size(tn,2) );

function [mse]=testnn( net, p, t )
tp = sim( net, p );
%calculate the MSE
sz = size( tp );
mse = sum( (t-tp).^2, 1 );
mse = sum( mse ) / sz(1) / sz(2);

function [fp, fn, e] = count_false( p, o)
n1 = 0;
n2 = 0;
n3 = 0;
for i=1:size(p,2)
    if( p(i)>10 && o(i)<10 )
        n1 = n1+1;
        n3 = n3 + 1;
    elseif( p(i)<10 && o(i)>10 )
        n2 = n2 +1;
        n3 = n3 + 1;
    end
end
fp = n1 / (n1+n2);
fn = n2 / (n1+n2);
e = 1 - n3 / size(p,2);

function [z] = SimNet( net, x, minaxp, minaxpn, minaxt, minaxtn )
pn = normalize( x, minaxp, minaxpn );
tn = sim( net, pn );
z = unnormalize( tn, minaxt, minaxtn );

%p[n,m] is a matrix with m points, each point has n dimensions.
%minaxp[n, 2] minaxp(:,1) the minimum of p(:), minaxp(:,2) the maximum of p(:)
function [pn] = normalize( p, minaxp, minaxn )
sz = size(minaxp);
for i=1:sz(1)
    pn(i, :) = ( p(i, :)-minaxp(i, 1) )/( minaxp(i, 2)-minaxp(i, 1) ) * ( minaxn(i, 2)-minaxn(i, 1) ) + minaxn(i, 1);
end

%p[n,m] is a matrix with m points, each point has n dimensions.
%minaxp[n, 2] minaxp(:,1) the minimum of p(:), minaxp(:,2) the maximum of p(:)
function [pn] = unnormalize( p, minaxp, minaxn )
sz = size(minaxp);
for i=1:sz(1)
    pn(i, :) = ( p(i, :) -minaxn(i, 1) )/ ( minaxn(i, 2)-minaxn(i, 1) ) * ( minaxp(i, 2)-minaxp(i, 1) ) + minaxp(i, 1);
end

function [d] = distance( x, y )
d = sqrt( sum( (x-y).^2 ) );

%generate the [min max] matrix [n, 2]. n is the dimension. [:,1] is min
%values, and [:,2] is max values
function [z] = bounds( n, xmin, xmax )
z = [xmin, xmax];
for i=1:n-1
    z = [z; [xmin, xmax] ];
end