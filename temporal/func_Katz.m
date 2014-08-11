function [Cbroadcast,Creceive] = func_Katz(data)
% Receive and broadcast (Katz) centralities
% 
% Eva Bujnoskova, August 2014

% create static network
N = size(data(1).m,1);
matrix = sparse(N,N);
for i = 1:size(data,2)
    matrix = matrix+data(i).m;
end
matrix(matrix>0) = 1;

% compute a_max = 1/rho(A[s]) .. upper limit for scalar a is reciprocal
% spectral radius (the first eigenvalue) of the adjacency matrix

temp = eigs(matrix);
rho = max(abs(temp));

a_max = 1/rho;

a = a_max - a_max/8;
% a = 0.05;

% compute communicability matrix
Q = (eye(N)-a*matrix)^(-1);

clear rho temp

% compute broadcast centrality
Cbroadcast = sum(Q,1);

% compute receive centrality
Creceive = sum(Q,2);

figure;
[nelements,xcenters] = hist(Creceive,20);
stem(xcenters,nelements,'*','Linewidth',5,'MarkerSize',10)
set(gca, 'YScale', 'log')
% xlim([0,2.5])
set(gca,'fontsize',20)
%title('Distribution of receive centralities','FontSize',20)
xlabel(['Receive centrality, a = ',num2str(a)],'FontSize',20)
ylabel('Number of accounts','FontSize',20)
print('-depsc','-tiff','-r600','static_receive')

figure;
[nelements,xcenters] = hist(Cbroadcast,20);
stem(xcenters,nelements,'-*','Linewidth',5,'MarkerSize',10)
set(gca, 'YScale', 'log')
% xlim([0,2.5])
set(gca,'fontsize',20)
%title('Distribution of broadcast centralities','FontSize',20)
xlabel(['Broadcast centrality, a = ',num2str(a)],'FontSize',20)
ylabel('Number of accounts','FontSize',20)
print('-depsc','-tiff','-r600','static_broadcast')
