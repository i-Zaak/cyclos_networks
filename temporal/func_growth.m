function [accounts, active_accounts] = func_growth(data,unit,dt)
% the growth of the network: # accounts in time, curve for existing ...
%  ... accounts, active accounts (active means initiating or participating...
% ... in transaction?). need to consider changing ...
%  ... network size - members join the network on the fly and also ...
%  ... leaving the network. joining the network defined by the first ...
%  ... transaction. leaving the network not strictly defined. arbitrary ...
%  ... chosen to be inactivity for more than X, the end point set up to ...
%  ... be last transaction + X/2. X computed from distribution of delays ...
%  ... between transactions - an order or so higher than average?
% 
% Eva Bujnoskova, August 2014

active_accounts = zeros(size(data(1).m,1),size(data,2));
for i = 1:size(data,2)
    [temp1,temp2] = find(data(i).m~=0); % nodes trading in time window i
    temp = unique([temp1',temp2']);
    active_accounts(temp,i) = ones(length(temp),1); % Nxt matrix, ...
    % ... (i,j)=1 when node i participated in any transaction in time j
end
clear temp1 temp2 temp

accounts = zeros(size(data(1).m,1),size(data,2));
for i = 1:size(active_accounts,1)
    count = 0;
    pos = [];
    pos2 = [];
    counts = [];
    for j = 1:size(active_accounts,2)   % for each time window
        if active_accounts(i,j) == 1    % node is activ
            accounts(i,j) = 1;
            if count ~= 0               % if node wasn't active in t-1
                pos2 = [pos2,j-1];      % save time t-1
                counts = [counts,count];    % save # windows without activity
                count = 0;              % count set to zero
            end
        else                        % node is inactive
            if count == 0           % if node was active in t-1
                count = 1;          % # windows of inactivity = 1
                pos = [pos,j];      % save time t
            else                    % if node was inactive in t-1
                count = count+1;    % # windows of inactivity increase by 1
            end
        end
    end
    if count ~= 0
        counts = [counts,count];	% save last count of inactivity
    end
    notransactions(i).pos1 = pos;   % save times when inactivity begun
    notransactions(i).pos2 = pos2;  % save times when inactivity ended
    notransactions(i).counts = counts;  % save # windows of inactivity
    meannotranstimes(i) = mean(counts);
end

thr = 2*median(meannotranstimes);   % threshold used to remove account from network

for i = 1:size(accounts,1)  % for each node
    [~,pos] = find(notransactions(i).counts > thr); % # windows of inactivity higher than thr
    for j = 1:length(pos)                       % for section of long inactivity
        temp1 = notransactions(i).pos1(pos(j)); % start point t1 of inactivity
        if temp1 > find(active_accounts(i,:),1) % if the start point is later in time than 1st transaction of the node
            if temp1+round(thr/2) <= size(accounts,2)   % section from t1 to thr/2 said to be of existing node, rest thr/2 inactive
                accounts(i,temp1:temp1+round(thr/2)) = ones(1,length(temp1:temp1+round(thr/2)));
            else
                accounts(i,temp1:end) = ones(1,length(temp1:size(accounts,2)));
            end
        end
    end
    [~,pos] = find(notransactions(i).counts <= thr);    % sections of inactivity shorter than thr
    for j = 1:length(pos)   % for each section
        temp1 = notransactions(i).pos1(pos(j)); % start point t1 of the section
        if temp1 > find(active_accounts(i,:),1)
            if size(notransactions(i).pos2,2) >= j
                temp2 = notransactions(i).pos2(j);  % end point of the section if saved
            else
                temp2 = size(accounts,2);   % end point of the section if the section lasts till the end
            end
            accounts(i,temp1:temp2) = ones(1,length(temp1:temp2));  % section said to be of existing node
        end
    end
end

plot(dt*(1:size(accounts,2)),sum(accounts),'LineWidth',5)
hold on
plot(dt*(1:size(accounts,2)),sum(active_accounts),'r','LineWidth',5)
xlabel(['Time [',unit,']'],'FontSize',20)
set(gca,'fontsize',20)
ylabel('Number of accounts','FontSize',20)
legend('number of accounts','number of active account')
% title('Number of accounts and active accounts in time','FontSize',20)
hold off
print('-depsc','-tiff','-r600','window_growth')