function testcluster
%uma = load('train.dat');
%uma = uma(:,1:28);
uma = load('93odd.dat');
uma = uma(:,1:6);

sils = zeros(7,1);
for i=1:7
    idx = kmeans(uma, i+1, 'distance', 'city');
    sil = silhouette(uma, idx, 'city');
    sils(i) = mean(sil);
end

plot(sils);

sils
