cyclos_networks
===============


This set of scrips can be used for preprocessing and network analysis of the transactions from the Cyclos payment system (<http://www.cyclos.org/>).

requirements
------------
The scripts are written in Python a make use of the NetworkX package (<http://networkx.github.io/>). Currently, there is no graphical interface, the usage will be demonstrated in the IPython (<http://ipython.org/>) interactive shell.

data preprocessing
------------------
We will need three tables from the Cyclos database: 

* ``accounts``
* ``transfers``
* ``custom_field_values``


Export these tables from the database as a csv file with comma as a field delimiter and " as field quoting character. It is likely necessary to anonymize the data prior further processing, for example to remove user names. To do so, open the exported csv file in spreadsheet application and remove the contents of appropriate cells. Do not remove the column as a whole.

The module ``cyclos_networks.filter`` contains the functions for loading the tables into the workspace. The function ``load_tables`` serves as an entry function, 

```python
import cyclos_networks.filter as lfilt
trans, accounts = lfilt.load_tables('data/transfers_example.csv','data/accounts_example.csv')
```

Now, you might want to remove all transactions of some accounts (for example dummy or system accounts), this can be achieved by ``remove_account`` function:

```python
# remove account with id 160
trans = lfilt.remove_account(trans,'160')
```

Now we create the transaction network with the help of the module ``cyclos_networks.graph``. ``gen_multigraph`` creates the multigraph where each transaction is represented by an edge, function ``multi_to_simple`` collapses multiple edges from node A to node B into one edge, summing the weights in the process:

```python
import snippets.graph as lgraph
mg = lgraph.gen_multigraph(trans)
sg = lgraph.multi_to_simple(mg)
```


This graph has TODO

The graph can be written in the GraphML to be opened for example in Gephi for interactive analysis (<http://gephi.org/>):

import networkx as nx
nx.write_graphml(sg, 'cyclos_network.graphml' )


network analysis
----------------
Modules ``graph`` and ``stats`` contain functions for computation and visualization of various properties of the transaction network. First, let us plot the node degree and edge weight distributions:

```python
lgraph.plot_all_dists(sg)
```

If a file name is supplied as second argument, resulting picture will be saved instead of displayed. 

Next, the function ``compute_metrics`` aggregates computation of several centrality measures available in the NetworkX package: PageRank, eigenvector centrality, current flow centrality, and simple degree and strength centralities. Results of these metrics for particular nodes are available after the computation as node attributes. You can specify, what edge weight to take into account: 'weight' for transaction volume, 'count' for transaction count.

```python
lgraph.compute_metrics(sg, 'count')
```

Note, that the node attributes are saved in the graphml format and can be loaded into Gephi for visualization.

We can also compute and plot the currency flow and accounts' balances with the help of ``stats`` module. The structure containing the accounts' balances can be computed:

```python
import cyclos_networks.stats as lstats
bals = lstats.account_ballance(trans)
```


The time course of the accounts' balances can be plotted:

```python
lstats.plot_bals_matrix(bals, 'balances.png')
```


