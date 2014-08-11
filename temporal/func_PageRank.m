function PR = func_PageRank(data)
% PAGERANK  Google's PageRank
% pagerank(U,G,p) uses the URLs and adjacency matrix produced by SURFER,
% together with a damping factory p, (default is .85), to compute and plot
% a bar graph of page rank.
% x = pagerank(U,G,p) returns the page ranks instead of printing.
% See also SURFER, SPY.
% 
% Greg Fasshauer, available at: http://www.math.iit.edu/~fass/matlab/pagerank.m
% 
% Edited for need of our toolbox, Eva Bujnoskova, August 2014


% create static network
N = size(data(1).m,1);
matrix = sparse(N,N);
for i = 1:size(data,2)
    matrix = matrix+data(i).m;
end
matrix(matrix>0) = 1;

G = matrix;

if nargin < 3, p = .85; end

% Eliminate any self-referential links

G = G - diag(diag(G));
  
% c = out-degree, r = in-degree

[n,n] = size(G);
c = full(sum(G,1));   % modified by G.F. so that sprintf does not get sparse input 
r = full(sum(G,2));   % (which it used to be able to handle, but no longer can)

% Scale column sums to be 1 (or 0 where there are no out links).

k = find(c~=0);
D = sparse(k,k,1./c(k),n,n);

% Solve (I - p*G*D)*x = e

e = ones(n,1);
I = speye(n,n);
x = (I - p*G*D)\e;

% Normalize so that sum(x) == 1.

PR = x/sum(x);

% Bar graph of page rank.

figure;
% bar(x)
% title('Page Rank')
[nelements,xcenters] = hist(PR,20);
stem(xcenters,nelements,'*','Linewidth',5,'MarkerSize',10)
set(gca, 'YScale', 'log')
% xlim([0,2.5])
set(gca,'fontsize',20)
%title('Distribution of PageRank','FontSize',20)
xlabel('PageRank distribution','FontSize',20)
ylabel('Number of accounts','FontSize',20)
print('-depsc','-tiff','-r600','static_pagerank')

