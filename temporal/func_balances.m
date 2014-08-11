function balances = func_balances(data)
% use data to compute balances
% 
% Eva Bujnoskova, August 2014

balances = zeros(size(data(1).w,2),size(data,2));
for i = 1:size(balances,1)  % for each node
    balances(i,1) = sum(data(1).w(:,i)) - sum(data(1).w(i,:));
    for j = 2:size(balances,2)  % for each window
        balances(i,j) = balances(i,j-1) + sum(data(j).w(:,i)) - sum(data(j).w(i,:));
    end
end
