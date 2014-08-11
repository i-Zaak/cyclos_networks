function noinitiating = func_delays(data,active_accounts,unit)
% distribution of time delays between transactions initiated from a ...
% ... single account
% 
% Eva Bujnoskova, August 2014

[node,t] = find(active_accounts==1);
initiators = zeros(size(active_accounts));
for i = 1:length(node)
    if sum(data(t(i)).m(node(i),:)~=0)
        initiators(node(i),t(i)) = 1;
    end
end

alldelays = [];
for i = 1:size(initiators,1)   % for each node
    count = 0;
    counts = [];
    temp = find(initiators(i,:)==1,1);
    for j = temp:size(initiators,2)     % for each time window since first activity
        if initiators(i,j) == 1         % node is active
            if count ~= 0               % if node wasn't active in t-1
                counts = [counts,count];    % save # windows without activity
                count = 0;              % count set to zero
            end
        else                        % node is inactive
            if count == 0           % if node was active in t-1
                count = 1;          % # windows of inactivity = 1
            else                    % if node was inactive in t-1
                count = count+1;    % # windows of inactivity increase by 1
            end
        end
    end
    if count ~= 0
        counts = [counts,count];	% save last count of inactivity
    end
    noinitiating(i).counts = counts;  % save # windows of inactivity
    alldelays = [alldelays,counts];
end

% temp = exp(1:max(alldelays)/10);
% d = max(alldelays)/max(temp);
% temp = temp*d+1;
% figure;
% [nelements,xcenters] = hist(alldelays,temp);
figure;
[nelements,xcenters] = hist(alldelays,20);
stem(xcenters,nelements,'*','LineWidth',5,'MarkerSize',10)
set(gca, 'YScale', 'log')
set(gca,'fontsize',20)
% set(gca, 'XScale', 'log')
% title('Distribution of time delays between transactions','FontSize',20)
xlabel({'Time delays between transactions initiated'; ['from a single account [',unit,']']},'FontSize',20)
ylabel('Number of accounts','FontSize',20)
print('-depsc','-tiff','-r600','time_delays')
