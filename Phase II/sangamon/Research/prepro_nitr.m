function prepro_nitr

minaxp = [
0   0.2	0   0	0	0   ;
0.9 0.9	0.6	0.6	0.6	1.0 ];
minaxp = minaxp';
minaxpn = bounds(6, -0.9, 0.9);
minaxt = [0 15.0];
minaxtn = [0.0 1.0];

center = [-0.8703    0.1877   -0.7609   -0.7619   -0.7297    0.0657]';
%center = [-0.8328	0.2081	-0.6541	-0.6365	-0.6195	0.0401]';
%center = [-0.6950    0.2831   -0.2613   -0.1752   -0.2144   -0.0539]';
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

p = p(:, 1:ntrains);
t = t(:, 1:ntrains);

center = [-0.8522    0.2040   -0.4202   -0.6775   -0.6623   -0.3773]';
%center = [-0.8522    0.2040   -0.7202   -0.6775   -0.6623   -0.3773]';
center = [-0.8963    0.2246   -0.7964   -0.7781   -0.7385    0.5301]';
%center = [-0.8400    0.5297   -0.5556   -0.5068   -0.4763   -0.0567]';
%center = [-0.8670   -0.0429   -0.7811   -0.7689   -0.7689   -0.5745]';
%center = [-0.8969    0.1869   -0.8086   -0.7842   -0.7766    0.5597]';

center = [-0.8748    0.2535   -0.6738   -0.6753   -0.6505    0.4716]';
%center = [-0.7891    0.1609   -0.6336   -0.5962   -0.5872   -0.4088]';
%center = [ -0.8416    0.1015   -0.7542   -0.7430   -0.7233   -0.4723]';

%center = [-0.4175    0.3627   -0.2582   -0.2605   -0.2433    0.5128]';

close all;
s = [];
for i=1:1
     alpha = 1;
%    alpha = i*0.1;
%    alpha = 0.6;
    cluster = [p; alpha*t]';
    [idx, c] = kmeans(cluster, 2);
%    [idx, c] = kmeans(cluster, 2, 'dist', 'city');
%    [idx, c] = kmeans(cluster, 2, 'display', 'iter');
    [sil, h] = silhouette(cluster, idx);
    c
    c = sortrows(c, 7);
    c
    center = c(2,1:6)';

%    center = p(:,i)

%    figure(i);
    d = dist( p, center );
    d = [d; t]';
    d = sortrows(d);
%    plot( d(:,1), d(:,2), 'x' );
    
    s = [s; [alpha std( d(1:180,:) )] ];
end

sortrows( s, 3 )
%s
%return;


vp = p(: , ntrains+1:size(p,2));
vt = t(: , ntrains+1:size(p,2));
pn = p(:, 1:ntrains);
tn = t(:, 1:ntrains);

%save_data( center, pn, tn, 90 );
%save_data( center, vp, vt, 90 );

function save_data( center, p, t, N )
%compute the distance of the points to the center
d = zeros(size(p,2),1);
for i=1:size(p,2)
    d(i,1) = distance( p(:,i), center );
    %d(i,1) = (p(6,i)+0.36)^2;
end
[sd, ix] = sort( d );

%reorder the points
p_all = p;
t_all = t;
for i=1:size(p,2)
    p_all(:,i) = p( :, ix(i) );
    t_all(:,i) = t( :, ix(i) );
end

%create the smaller cluster
data_all = [p_all; t_all];
data_1 = data_all(:,1:N);
data_1 = data_1';
save 'valid1.dat' data_1 '-ascii';
%save 'train1.dat' data_1 '-ascii';

%create the larger cluster
%sample 50 points from data_1.
ix = rand(80,1)*N + 0.5;
ix = round(ix);
ix = unique(ix);

data_2 = data_all(:, N+1:size(data_all,2));
data_2 = data_2';
for i=1:size(ix,1)
    data_2 = [data_2; data_1(ix(i),:)];
end
save 'valid2.dat' data_2 '-ascii';
%save 'train2.dat' data_2 '-ascii';


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