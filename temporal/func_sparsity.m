function sparsity = func_sparsity(data,accounts,unit,dt)
% network sparsity in time - considers directionality of edges
% 
% Eva Bujnoskova, August 2014

sparsity = zeros(1,size(data,2));
for i = 1:size(data,2)  % for each time window
    matrix = data(i).m(accounts(:,i)==1,accounts(:,i)==1);  % network defined by existing accounts
    sparsity(i) = sum(matrix(:)>0)/(size(matrix,1)*(size(matrix,1)-1));    % # transactions / # all possible transactions
end

figure;
plot(dt*(1:length(sparsity)),sparsity,'LineWidth',5)
xlabel(['Time [',unit,']'])
set(gca,'fontsize',20)
ylabel('Network sparsity','FontSize',20)
% title('Network sparsity evolving in time','FontSize',20)
print('-depsc','-tiff','-r600','window_sparsity')

