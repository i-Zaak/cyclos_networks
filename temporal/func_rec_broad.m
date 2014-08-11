function [Cbroadcast,Creceive] = func_rec_broad(data)
% Receive and broadcast centralities
% 
% Eva Bujnoskova, August 2014

% compute a_max = 1/max_s(rho(A[s])) .. upper limit for scalar a. = maximum
% over all windows of spectral radia (the largest eigenvalues) of all
% adjacency matrices

rho = zeros(1,size(data,2));
for i = 1:size(data,2)
    temp = eigs(data(i).m);
    rho(i) = max(abs(temp));
end
a_max = 1/max(rho);

a = a_max - a_max/8;
% a = 0.05;

% compute communicability matrix - the equation depends on #links per
% window - 1 link per window - eq Q1, >1 links per window - eq Q2
N = size(data(1).m,1);
Q1old = eye(N);
for i = 1:size(data,2)%-1
%     Q1 = Q1*(eye(N)+a*data(i).m);   % exceeds number size - overflow
    Q1 = (Q1old*(eye(N)+a*data(i).m))/(norm(Q1old*(eye(N)+a*data(i).m)));
    Q1old = Q1;
end

Q2old = eye(N);
for i = 1:size(data,2)%-1
    Q2 = (Q2old*(eye(N)-a*data(i).m)^(-1))/(norm(Q1old*(eye(N)-a*data(i).m)^(-1)));
    Q2old = Q2;
end

clear Q1old Q2old i rho temp

% compute broadcast centrality
C1broadcast = sum(Q1,1);
C2broadcast = sum(Q2,1);
Cbroadcast(1).c = C1broadcast;
Cbroadcast(2).c = C2broadcast;

% compute receive centrality
C1receive = sum(Q1,2);
C2receive = sum(Q2,2);
Creceive(1).c = C1receive;
Creceive(2).c = C2receive;

figure;
[nelements,xcenters] = hist(Creceive(1).c,20);
stem(xcenters,nelements,'*','Linewidth',5,'MarkerSize',10)
set(gca, 'YScale', 'log')
xlim([0,2.5])
set(gca,'fontsize',20)
%title('Distribution of receive centralities','FontSize',20)
xlabel(['Receive centrality, a = ',num2str(a)],'FontSize',20)
ylabel('Number of accounts','FontSize',20)
print('-depsc','-tiff','-r600','temporal_receive')

% figure;
% [nelements,xcenters] = hist(Creceive(2).c,20);
% bar(xcenters,nelements)
% set(gca, 'YScale', 'log')
% title('Distribution of receive centralities - equation for very sparse network')

figure;
[nelements,xcenters] = hist(Cbroadcast(1).c,20);
stem(xcenters,nelements,'-*','Linewidth',5,'MarkerSize',10)
set(gca, 'YScale', 'log')
xlim([0,2.5])
set(gca,'fontsize',20)
%title('Distribution of broadcast centralities','FontSize',20)
xlabel(['Broadcast centrality, a = ',num2str(a)],'FontSize',20)
ylabel('Number of accounts','FontSize',20)
print('-depsc','-tiff','-r600','temporal_broadcast')

% figure;
% [nelements,xcenters] = hist(Cbroadcast(2).c,20);
% bar(xcenters,nelements)
% set(gca, 'YScale', 'log')
% title('Distribution of broadcast centralities - equation for very sparse network')