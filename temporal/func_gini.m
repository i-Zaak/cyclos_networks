function gini = func_gini(data,accounts,unit,dt)
% Gini coeff. in time. curves for indegrees, outdegrees, wei in- and outdegrees, balances.
% variables in time, averaged.
% 
% Eva Bujnoskova, August 2014

for i = 1:size(data,2)
    matrix = data(i).w;
    matrix = matrix(sum(accounts(:,i)>0,2)>0,sum(accounts(:,i)>0,2)>0);
    umatrix = (tril(matrix)+triu(matrix)')+(tril(matrix)'+triu(matrix));
    
    % indegrees
    X = sum(matrix>0,1);
    if isempty(X)
        gini.indegrees(i) = 0;
        gini.outdegrees(i) = 0;
        gini.weiindegrees(i) = 0;
        gini.weioutdegrees(i) = 0;
        gini.balances(i) = 0;
        gini.degrees(i) = 0;
        gini.weights(i) = 0;
        continue
    end
    % indegrees
    x = sort(X,'ascend');
    n = length(x);
    l = 1:n;
    gini.indegrees(i) = (2*sum(l.*x))/(n*sum(x)) - (n+1)/n;
    % outdegrees
    X = sum(matrix>0,2);
    x = sort(X,'ascend')';
    n = length(x);
    l = 1:n;
    gini.outdegrees(i) = (2*sum(l.*x))/(n*sum(x)) - (n+1)/n;
    % weiindegrees
    X = sum(matrix,1);
    x = sort(X,'ascend');
    n = length(x);
    l = 1:n;
    gini.weiindegrees(i) = (2*sum(l.*x))/(n*sum(x)) - (n+1)/n;
    % weioutdegrees
    X = sum(matrix,2);
    x = sort(X,'ascend')';
    n = length(x);
    l = 1:n;
    gini.weioutdegrees(i) = (2*sum(l.*x))/(n*sum(x)) - (n+1)/n;
    % balances - nonsence because summed balance is always 0 in time window
%     X = balances(accounts(:,i),i);
%     x = sort(X,'ascend')';
%     n = length(x);
%     l = 1:n;
%     gini.balances(i) = (2*sum(l.*x))/(n*sum(x)) - (n+1)/n;
    % degrees
    X = sum(umatrix>0);
    x = sort(X,'ascend');
    n = length(x);
    l = 1:n;
    gini.degrees(i) = (2*sum(l.*x))/(n*sum(x)) - (n+1)/n;
    % weights
    X = sum(umatrix,2);
    x = sort(X,'ascend')';
    n = length(x);
    l = 1:n;
    gini.weights(i) = (2*sum(l.*x))/(n*sum(x)) - (n+1)/n;
end

% temp = [gini.indegrees;gini.outdegrees;gini.weiindegrees;gini.weioutdegrees;...
%     gini.degrees;gini.weights]';
temp = dt*(1:length(gini.indegrees));
figure;
plot(temp,gini.indegrees,temp,gini.outdegrees,temp,gini.weiindegrees,temp,...
    gini.weioutdegrees,temp,gini.degrees,temp,gini.weights,'LineWidth',5)
% ylim([0,1])
legend('customers','vendors','incomes','spendings','trade partners','money flow')
xlabel(['Time [',unit,']'],'FontSize',20)
ylabel('Gini coefficient','FontSize',20)
% title('Gini coefficient in time','FontSize',20)
set(gca,'fontsize',20)
print('-depsc','-tiff','-r600','window_gini')

