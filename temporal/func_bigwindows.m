function bigW = func_bigwindows(data,accounts,wsize,bigwsize,unit)
% evolution of metrics
% Eva Bujnoskova, August 2014

bigwsize = round(bigwsize/wsize);   % number of windows in 1 big window
N = zeros(1,floor(size(data,2)/bigwsize));
for i = 1:size(data,2)/bigwsize     % for each big window
    w = (i-1)*bigwsize+1:i*bigwsize;    % windows numbers in a big window
    
    matrix = sparse(1,1);
    for j = 1:length(w)
        matrix = matrix+data(w(j)).w;   % agregated matrix of a big window with all nodes
    end
    matrix = matrix(sum(accounts(:,w)>0,2)>0,sum(accounts(:,w)>0,2)>0); % agregated matrix of a big window with active nodes
    umatrix = (tril(matrix)+triu(matrix)')+(tril(matrix)'+triu(matrix));    % undirected matrix
        
    N(i) = length(matrix);          % number of accounts in big window
    
    indegrees.m{i,:} = sum(matrix>0,1);     % adjacent nodes through columns - I got money from them
    weiindegrees.m{i,:} = sum(matrix,1);    % sums income
    outdegrees.m{i,:} = sum(matrix>0,2)';   % adjacent nodes through rows - I paid them
    weioutdegrees.m{i,:} = sum(matrix,2)';  % sums outlay
    balances_distr.m{i,:} = indegrees.m{i,:} - outdegrees.m{i,:};   % sums balance
    degrees.m{i,:} = sum(umatrix>0);          % sums number of trade partners
    weights.m{i,:} = sum(umatrix,2)';       % sums money flows

    if i>1      % finding max and min values of variables across big windows
        % indegrees
        if max(indegrees.m{i,:})>indegrees.maxm
            indegrees.maxm = max(indegrees.m{i,:});
        end
        if min(indegrees.m{i,:})<indegrees.minm
            indegrees.minm = min(indegrees.m{i,:});
        end
        % weiindegrees
        if max(weiindegrees.m{i,:})>weiindegrees.maxm
            weiindegrees.maxm = max(weiindegrees.m{i,:});
        end
        if min(weiindegrees.m{i,:})<weiindegrees.minm
            weiindegrees.minm = min(weiindegrees.m{i,:});
        end
        % outdegrees
        if max(outdegrees.m{i,:})>outdegrees.maxm
            outdegrees.maxm = max(outdegrees.m{i,:});
        end
        if min(outdegrees.m{i,:})<outdegrees.minm
            outdegrees.minm = min(outdegrees.m{i,:});
        end
        % weioutdegrees
        if max(weioutdegrees.m{i,:})>weioutdegrees.maxm
            weioutdegrees.maxm = max(weioutdegrees.m{i,:});
        end
        if min(weioutdegrees.m{i,:})<weioutdegrees.minm
            weioutdegrees.minm = min(weioutdegrees.m{i,:});
        end
        % balances
        if max(balances_distr.m{i,:})>balances_distr.maxm
            balances_distr.maxm = max(balances_distr.m{i,:});
        end
        if min(balances_distr.m{i,:})<balances_distr.minm
            balances_distr.minm = min(balances_distr.m{i,:});
        end
        % degrees
        if max(degrees.m{i,:})>degrees.maxm
            degrees.maxm = max(degrees.m{i,:});
        end
        if min(degrees.m{i,:})<degrees.minm
            degrees.minm = min(degrees.m{i,:});
        end
        % weights
        if max(weights.m{i,:})>weights.maxm
            weights.maxm = max(weights.m{i,:});
        end
        if min(weights.m{i,:})<weights.minm
            weights.minm = min(weights.m{i,:});
        end
    else
        % indegrees
        indegrees.maxm = max(indegrees.m{i,:});
        indegrees.minm = min(indegrees.m{i,:});
        % weiindegrees
        weiindegrees.maxm = max(weiindegrees.m{i,:});
        weiindegrees.minm = min(weiindegrees.m{i,:});
        % outdegrees
        outdegrees.maxm = max(outdegrees.m{i,:});
        outdegrees.minm = min(outdegrees.m{i,:});
        % weioutdegrees
        weioutdegrees.maxm = max(weioutdegrees.m{i,:});
        weioutdegrees.minm = min(weioutdegrees.m{i,:});
        % balances
        balances_distr.maxm = max(balances_distr.m{i,:});
        balances_distr.minm = min(balances_distr.m{i,:});
        % degrees
        degrees.maxm = max(degrees.m{i,:});
        degrees.minm = min(degrees.m{i,:});
        % weights
        weights.maxm = max(weights.m{i,:});
        weights.minm = min(weights.m{i,:});
    end
end

% divides scale to 10 bars, computes intervals
indegrees.bars = indegrees.minm:(indegrees.maxm - indegrees.minm)/10:indegrees.maxm;
weiindegrees.bars = weiindegrees.minm:(weiindegrees.maxm - weiindegrees.minm)/10:weiindegrees.maxm;
outdegrees.bars = outdegrees.minm:(outdegrees.maxm - outdegrees.minm)/10:outdegrees.maxm;
weioutdegrees.bars = weioutdegrees.minm:(weioutdegrees.maxm - weioutdegrees.minm)/10:weioutdegrees.maxm;
balances_distr.bars = balances_distr.minm:(balances_distr.maxm - balances_distr.minm)/10:balances_distr.maxm;
degrees.bars = degrees.minm:(degrees.maxm - degrees.minm)/10:degrees.maxm;
weights.bars = weights.minm:(weights.maxm - weights.minm)/10:weights.maxm;

for i = 1:floor(size(data,2)/bigwsize)             % for each big window
    for j = 1:length(weiindegrees.bars)-1   % for each interval
        % counts numbers of accounts with variable value in interval
        indegrees.counts(i,j) = full(sum(indegrees.m{i,:}>=indegrees.bars(j)...
            & indegrees.m{i,:}<indegrees.bars(j+1)));
        weiindegrees.counts(i,j) = full(sum(weiindegrees.m{i,:}>=weiindegrees.bars(j)...
            & weiindegrees.m{i,:}<weiindegrees.bars(j+1)));
        outdegrees.counts(i,j) = full(sum(outdegrees.m{i,:}>=outdegrees.bars(j)...
            & outdegrees.m{i,:}<outdegrees.bars(j+1)));
        weioutdegrees.counts(i,j) = full(sum(weioutdegrees.m{i,:}>=weioutdegrees.bars(j)...
            & weioutdegrees.m{i,:}<weioutdegrees.bars(j+1)));
        balances_distr.counts(i,j) = full(sum(balances_distr.m{i,:}>=balances_distr.bars(j)...
            & balances_distr.m{i,:}<balances_distr.bars(j+1)));
        degrees.counts(i,j) = full(sum(degrees.m{i,:}>=degrees.bars(j)...
            & degrees.m{i,:}<degrees.bars(j+1)));
        weights.counts(i,j) = full(sum(weights.m{i,:}>=weights.bars(j)...
            & weights.m{i,:}<weights.bars(j+1)));
    end
    % normalizes numbers of accounts in intervals by number of accounts in big window
    indegrees.normcounts(i,:) = indegrees.counts(i,:)/N(i);
    weiindegrees.normcounts(i,:) = weiindegrees.counts(i,:)/N(i);
    outdegrees.normcounts(i,:) = outdegrees.counts(i,:)/N(i);
    weioutdegrees.normcounts(i,:) = weioutdegrees.counts(i,:)/N(i);
    balances_distr.normcounts(i,:) = balances_distr.counts(i,:)/N(i);
    degrees.normcounts(i,:) = degrees.counts(i,:)/N(i);
    weights.normcounts(i,:) = weights.counts(i,:)/N(i);
    % creates legend for bar-plot - intervals of big window
    bigwlegend{i} = [num2str((i-1)*wsize*bigwsize+1),'-',num2str(i*wsize*bigwsize),' ',unit];
end
% vizualization

% indegrees
% computes middle values of intervals
% temp =  ([indegrees.bars,1] - [1,indegrees.bars])/2 + [1,indegrees.bars];
% bar(temp(2:end-1),indegrees.normcounts'*100)
colors = colormap(jet);
colors = colors(1:round(64/floor(size(data,2)/bigwsize)):end,:);
figure;
stem(indegrees.bars(2:end)-indegrees.bars(2)/2,indegrees.normcounts(1,:)*100,...
    '-*','color',colors(1,:),'LineWidth',5,'MarkerSize',10)
hold on
for i = 2:size(indegrees.normcounts,1)
    stem(indegrees.bars(2:end)-indegrees.bars(2)/2,indegrees.normcounts(i,:)*100,...
        '-*','color',colors(i,:),'LineWidth',5,'MarkerSize',10)
end
set(gca, 'YScale', 'log')
set(gca,'fontsize',20)
legend(bigwlegend)
xlabel('Total number of customers of each account','FontSize',20)
ylabel('Number of accounts','FontSize',20)
%title('Distribution of total numbers of customers','FontSize',20)
print('-depsc','-tiff','-r600','window_indegrees')

% weiindegrees
% computes middle values of intervals
% temp =  ([weiindegrees.bars,1] - [1,weiindegrees.bars])/2 + [1,weiindegrees.bars];
figure;
stem(weiindegrees.bars(2:end)-weiindegrees.bars(2)/2,weiindegrees.normcounts(1,:)*100,...
    '-*','color',colors(1,:),'LineWidth',5,'MarkerSize',10)
hold on
for i = 2:size(weiindegrees.normcounts,1)
    stem(weiindegrees.bars(2:end)-weiindegrees.bars(2)/2,weiindegrees.normcounts(i,:)*100,...
        '-*','color',colors(i,:),'LineWidth',5,'MarkerSize',10)
end
set(gca, 'YScale', 'log')
set(gca,'fontsize',20)
legend(bigwlegend)
xlabel('Total income of each account','FontSize',20)
ylabel('Number of accounts','FontSize',20)
%title('Distribution of total incomes','FontSize',20)
print('-depsc','-tiff','-r600','window_weiindegrees')

% outdegrees
% computes middle values of intervals
% temp =  ([outdegrees.bars,1] - [1,outdegrees.bars])/2 + [1,outdegrees.bars];
figure;
stem(outdegrees.bars(2:end)-outdegrees.bars(2)/2,outdegrees.normcounts(1,:)*100,...
    '-*','color',colors(1,:),'LineWidth',5,'MarkerSize',10)
hold on
for i = 2:size(outdegrees.normcounts,1)
    stem(outdegrees.bars(2:end)-outdegrees.bars(2)/2,outdegrees.normcounts(i,:)*100,...
        '-*','color',colors(i,:),'LineWidth',5,'MarkerSize',10)
end
set(gca, 'YScale', 'log')
set(gca,'fontsize',20)
legend(bigwlegend)
xlabel('Total number of vendors of each account','FontSize',20)
ylabel('Number of accounts','FontSize',20)
% title('Distribution of total number of vendors','FontSize',20)
print('-depsc','-tiff','-r600','window_outdegrees')

% weioutdegrees
% computes middle values of intervals
% temp =  ([weioutdegrees.bars,1] - [1,weioutdegrees.bars])/2 + [1,weioutdegrees.bars];
figure;
stem(weioutdegrees.bars(2:end)-weioutdegrees.bars(2)/2,weioutdegrees.normcounts(1,:)*100,...
    '-*','color',colors(1,:),'LineWidth',5,'MarkerSize',10)
hold on
for i = 2:size(weioutdegrees.normcounts,1)
    stem(weioutdegrees.bars(2:end)-weioutdegrees.bars(2)/2,weioutdegrees.normcounts(i,:)*100,...
        '-*','color',colors(i,:),'LineWidth',5,'MarkerSize',10)
end
set(gca, 'YScale', 'log')
set(gca,'fontsize',20)
legend(bigwlegend)
xlabel('Total spendings of each account','FontSize',20)
ylabel('Number of accounts')
% title('Distribution of spendings','FontSize',20)
print('-depsc','-tiff','-r600','window_weioutdegrees')

% balances
% computes middle values of intervals
temp =  ([balances_distr.bars,1] - [1,balances_distr.bars])/2 + [1,balances_distr.bars];
figure;
bar(temp(2:end-1),balances_distr.normcounts'*100)
set(gca, 'YScale', 'log')
set(gca,'fontsize',20)
legend(bigwlegend)
xlabel('Total balance in each account','FontSize',20)
ylabel('Number of accounts')
% title('Distribution of balances','FontSize',20)
print('-depsc','-tiff','-r600','window_balances')

% degrees
% computes middle values of intervals
% temp =  ([degrees.bars,1] - [1,degrees.bars])/2 + [1,degrees.bars];
figure;
stem(degrees.bars(2:end)-degrees.bars(2)/2,degrees.normcounts(1,:)*100,...
    '-*','color',colors(1,:),'LineWidth',5,'MarkerSize',10)
hold on
for i = 2:size(degrees.normcounts,1)
    stem(degrees.bars(2:end)-degrees.bars(2)/2,degrees.normcounts(i,:)*100,...
        '-*','color',colors(i,:),'LineWidth',5,'MarkerSize',10)
end
set(gca, 'YScale', 'log')
set(gca,'fontsize',20)
legend(bigwlegend)
xlabel('Total number of trade partners of each account','FontSize',20)
ylabel('Number of accounts','FontSize',20)
% title('Distribution of trade partners','FontSize',20)
print('-depsc','-tiff','-r600','window_degrees')

% weights
% computes middle values of intervals
% temp =  ([weights.bars,1] - [1,weights.bars])/2 + [1,weights.bars];
figure;
stem(weights.bars(2:end)-weights.bars(2)/2,weights.normcounts(1,:)*100,...
    '-*','color',colors(1,:),'LineWidth',5,'MarkerSize',10)
hold on
for i = 2:size(weights.normcounts,1)
    stem(weights.bars(2:end)-weights.bars(2)/2,weights.normcounts(i,:)*100,...
        '-*','color',colors(i,:),'LineWidth',5,'MarkerSize',10)
end
set(gca, 'YScale', 'log')
set(gca,'fontsize',20)
legend(bigwlegend)
xlabel('Total money flow of each account','FontSize',20)
ylabel('Number of accounts')
% title('Distribution of money flow','FontSize',20)
print('-depsc','-tiff','-r600','window_weights')

bigW.indegrees = indegrees;
bigW.outdegrees = outdegrees;
bigW.weiindegrees = weiindegrees;
bigW.weioutdegrees = weioutdegrees;
bigW.balances = balances_distr;
bigW.degrees = degrees;
bigW.weights = weights;
