% The script for transaction network analysis
% 
% The script requires own data in a struct format with arrays of transaction
% IDs (transactionid), IDs of nodes that sent money (from_account), IDs of nodes
% that received money (to_account), timestamp (in unit specified further in
% the script, and setting the first transaction to time t=0), amount of
% money that was sent (amount). Optional is also an array with real data when
% the transactions where made for specification in visualizations.
% 
% Eva Bujnoskova, August 2014

clear all
clc
close all

% load data
% load('LETSE.mat');
% sourcedata = LETSE;
% clear LETSE

% change ids to have them from 1 to N
temp = unique([sourcedata.from_account' sourcedata.to_account']);
for i = 1:size(sourcedata.from_account)
    sourcedata.fromID(i,1) = find(temp==sourcedata.from_account(i));
end
for i = 1:size(sourcedata.to_account)
    sourcedata.toID(i,1) = find(temp==sourcedata.to_account(i));
end

clear i temp

% create adjacency matrices - windows equidistant
% dt = min(abs(diff(sourcedata.timestamp)));    % window size for 1 edge per window
dt = 30;                                        % window size = 7 days
% dt = 7;                                       % window size = 7 days
unit = 'days';
bigwsize = floor(365/2);                        % size of long term window in days

sourcedata.windows = floor(sourcedata.timestamp/dt);    % snapshot where the transction takes place
temp = sourcedata.windows==0;
sourcedata.windows(temp) = ones(sum(temp),1);           % changes zero times to 1

t = unique(sourcedata.windows);                         % allows more edges in 1 window
N = max([max(sourcedata.fromID),max(sourcedata.toID)]);

for i = 1:length(t)%-1
    pos = find(sourcedata.windows==t(i));               % edges in one window
    data(i).m = sparse(sourcedata.fromID(pos),sourcedata.toID(pos),...
        ones(1,length(pos)),N,N);                       % binary adjacency matrix
    data(i).w = sparse(sourcedata.fromID(pos),sourcedata.toID(pos),...
    	sourcedata.amount(i),N,N);                      % weighted adjacency matrix
	data(i).window = t(i);
end

clear t i temp pos

%% static analysis
% Katz centrality - contain Katz (broadcast) and receive centralities
[static.katz,static.receive] = func_Katz(data);

% PageRank metric
static.pagerank = func_PageRank(data);

%% window analysis
% balances
window_analysis.balances = func_balances(data);

% the growth of the network
[window_analysis.accounts, window_analysis.active_accounts] = func_growth(data,unit,dt);

% network sparsity in time
window_analysis.sparsity = func_sparsity(data,window_analysis.accounts,unit,dt);

% evolution of indegree, outdegree, incomes, outcomes, degree, node strength
window_analysis.bigW = func_bigwindows(data,window_analysis.accounts,dt,bigwsize,unit);

% Gini coeff. in time. curves for indegrees, outdegrees, incomes, outcomes,
% node strength, degree
window_analysis.Gini = func_gini(data,window_analysis.accounts,unit,dt);

% clustering in time
window_analysis.clustering = func_clustering(data,window_analysis.accounts,unit,dt);

% distribution of time delays between transactions initiated from a ...
% ... single account
time_delays = func_delays(data,window_analysis.active_accounts,unit);


%% temporal analysis
% broadcast and receive centralities
[temporal.broadcast,temporal.receive] = func_rec_broad(data);

% change-point detection - create data in wanted format here, the code for
% change-point detection in python
func_change_point(data);

