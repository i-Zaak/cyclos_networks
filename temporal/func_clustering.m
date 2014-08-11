function clustering = func_clustering(data,accounts,unit,dt)
% clustering in time
% 
% Eva Bujnoskova, August 2014

for i = 1:size(data,2)
    matrix = data(i).w;
    matrix = matrix(sum(accounts(:,i)>0,2)>0,sum(accounts(:,i)>0,2)>0);
    umatrix = (tril(matrix)+triu(matrix)')+(tril(matrix)'+triu(matrix));
    bmatrix = data(i).m;
    bmatrix = bmatrix(sum(accounts(:,i)>0,2)>0,sum(accounts(:,i)>0,2)>0);
    bumatrix = (tril(bmatrix)+triu(bmatrix)')+(tril(bmatrix)'+triu(bmatrix));
    if isempty(matrix)
        continue
    end
    clustering.wd(i) = mean(clustering_coef_wd(matrix));
    clustering.bd(i) = mean(clustering_coef_bd(bmatrix));
    clustering.wu(i) = mean(clustering_coef_wu(umatrix));
    clustering.bu(i) = mean(clustering_coef_bu(bumatrix));
end

% temp = [clustering.wd;clustering.bd;clustering.wu;clustering.bu]';
temp = dt*(1:length(clustering.wd));
figure;
semilogy(temp,clustering.wd+1,temp,clustering.bd+1,temp,clustering.wu+1,temp,...
    clustering.bu+1,'LineWidth',5)
legend('directed money flow','directed trade partners',...
    'undirected money flow','undirected trade partners')
xlabel(['Time [',unit,']'],'FontSize',20)
ylabel('Clustering coefficient + 1','FontSize',20)
% title('Clustering coefficient in time','FontSize',20)
set(gca,'fontsize',20)
print('-depsc','-tiff','-r600','window_clustering')
