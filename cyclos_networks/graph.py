import numpy as np
import networkx as nx
import os
import filter as letsf
import matplotlib.pyplot as plt


def write_msc(trans,filepath):
    f = open(filepath, 'w')
    f.write( "msc{\n")
    f.write( '","'.join(np.unique(trans[:,(1,2)])) + '\n')
    
    for row in enumerate(trans[:,(1,2,5)]):
        f.write( '%s->%s [label="%s"];\n' % (row[1][0],row[1][1],row[1][2]))
    
    f.write( "}\n")



def gen_multigraph(trans):
    mg=nx.MultiDiGraph()
    for row in enumerate(trans[:,(1,2,5,30)]):
        mg.add_edge(row[1][0], row[1][1], weight=float(row[1][2]), type=int(row[1][3]))
    #nx.write_dot(mg,'multi113.dot')
    return mg

def multi_to_simple(mg):
    sg=nx.DiGraph()
    for u,v,data in mg.edges_iter(data=True):
        w = data['weight']
        if sg.has_edge(u,v):
            sg[u][v]['weight'] += w
            sg[u][v]['count'] += 1
        else:
            sg.add_edge(u, v, weight=w, count=1)
    return sg

def _di_to_undi(dg):
    ug = nx.Graph()
    ug.add_nodes_from(dg)
    for u,v,d in dg.edges(data=True):
        if ug.has_edge(u,v):
            ug[u][v]['weight']+=d['weight']
            ug[u][v]['count']+=d['count']
        else:
            ug.add_edge(u,v,d)
    return ug

def rich_club_coefficient(G, bins=None, normalized=True, Q=1000, weight='weight'):
    import random
    for e in G.edges():
        G[e[0]][e[1]][weight] = float(G[e[0]][e[1]][weight])
    if not (G.is_multigraph() or G.is_directed()):
        return nx.rich_club_coefficient(G, normalized, Q)
    
    if bins is None:
        bins = np.logspace(0,4.6,num=30) # weight
        #bins = np.linspace(0,218,num=30) # count
        #bins = sorted(G.degree(weight='weight').values())[:-1]

    rc = map(lambda x:_phi_w(G,x,w=weight), bins)

    if normalized:
        R = G.copy()
        rcs = []
        for i in range(Q):
            for n in R.nodes_iter():
                keys = R.edge[n].keys()
                vals = map(lambda x: R.edge[n][x], keys)
                random.shuffle(vals)
                for k,v in zip(keys,vals):
                    R.edge[n][k] = v
            rcs.append(map(lambda x:_phi_w(R,x,w=weight), bins))
        rc_n = np.zeros(len(rcs[0]))
        for i in range(len(rc_n)):
            for j in range(len(rcs)):
                rc_n[i] += rcs[j][i]
            rc_n[i] = rc_n[i]/Q
        rc = map(lambda x,y:x/y, rc, rc_n)
    return rc, bins

def plot_rc(rc,bins,filepath):
    plt.rcParams['xtick.labelsize'] = 18
    plt.rcParams['ytick.labelsize'] = 18
    plt.semilogx(bins, rc)
    ax = plt.gca()
    ax.annotate('33, 17', xy=(bins[-1],rc[-1]),arrowprops=dict(facecolor='black', shrink=0.05), xytext=(1000, 8), fontsize=18)
    ax.annotate('49', xy=(bins[-2],rc[-2]),arrowprops=dict(facecolor='black', shrink=0.05), xytext=(1000, 4), fontsize=18)
    ax.annotate('14,27,6,8', xy=(bins[-3],rc[-3]),arrowprops=dict(facecolor='black', shrink=0.05), xytext=(100, 2), fontsize=18)
    ax.set_ylim(bottom=0)
    plt.axhline(y=1,color='k')
    ax.set_yticks([0,1,2,3,4,5,6,7,8,9,10])
    ax.set_ylabel(r'$\rho$', fontsize=25)
    ax.set_xlabel('r', fontsize=25)
    plt.savefig(filepath,format='pdf')
    #plt.show()

def rich_club_subgraph(G, r, w='weight'):
    n_s = G.degree(weight=w)             # node strengths
    n_r = [i for i in n_s.items() if i[1] >= r] # nodes stronger than r
    G_r = G.subgraph(map(lambda x:x[0], n_r))   # club subgraph
    return G_r




def _phi_w(G, r, w='weight'):
    n_s = G.degree(weight=w)             # node strengths
    n_r = [i for i in n_s.items() if i[1] >= r] # nodes stronger than r
    G_r = G.subgraph(map(lambda x:x[0], n_r))   # club subgraph
    E_r = G_r.size()                            # num of edges in subgraph
    W_r = G_r.size(weight=w)             # weight sum in subgraph
    #w_rank = sorted(n_s.values())               # sorted edge weights
    # sorted edge weights
    w_rank = sorted( [i[2][w] for i in G.edges(data=True)])
    w_sum = sum(w_rank[-E_r:])                  # sum of top E_r edges
    print E_r, " ", w_sum, ' ', W_r , " ", W_r/w_sum 
    return W_r/w_sum



def plot_deg_dist(G, direction='both'):
    if direction == 'both':
        deg = G.degree()
    elif direction == 'out':
        deg = G.out_degree()
    elif direction == 'in':
        deg = G.in_degree()
    
    deg_val = sorted(set(deg.values()))
    deg_hist = [deg.values().count(x) for x in deg_val]
    deg_hist = map(lambda x:float(x)/G.number_of_nodes(), deg_hist)
    ax = plt.subplot(111)
    ax.scatter(deg_val, deg_hist)
    ax.set_xscale('log')
    ax.set_yscale('log')
    plt.show()

def _plot_cumdist(vals, ax=None):
    val_bins = sorted(set(vals))
    cummcount = []
    for i in val_bins:
        cummcount.append( sum(1 for j in vals if j >= i)  )
    if ax is not None:
        ax.loglog(val_bins, cummcount, 'ro')
    else:
        plt.loglog(val_bins, cummcount, 'ro')
        plt.show()

def plot_all_dists(G, filepath=None):
    #from matplotlib.ticker import MultipleLocator, FormatStrFormatter
    #majorFormatter = FormatStrFormatter('10^%d')


    #f, axarr = plt.subplots(3,3)
    f, axarr = plt.subplots(2,3)
    #f.set_size_inches(8.5,10)
    f.set_size_inches(8.5,5)
    vals = G.degree().values()
    axarr[0,0].hist(vals)
    axarr[0,0].set_xlabel('degree')
    axarr[0,0].set_ylabel('number of nodes')

    axarr[1,0].hist([map(np.log, vals)])
    axarr[1,0].set_xlabel('logarithm of degree')
    axarr[1,0].set_ylabel('number of nodes')
    #axarr[1,0].xaxis.set_major_formatter(majorFormatter)
    #plot_cumdist(vals,axarr[2,0])
    #axarr[2,0].set_xlabel('degree')
    #axarr[2,0].set_ylabel('number of nodes\nwith higher degree',multialignment='center')

    vals2 = G.degree(weight='weight').values()
    axarr[0,1].hist(map(lambda x: x/10000.0, vals2))
    axarr[0,1].set_xlabel(r'strength ($10^5$)')
    axarr[0,1].set_ylabel('number of nodes')
    axarr[1,1].hist([map(np.log, vals2)])
    axarr[1,1].set_xlabel('logarithm of strength')
    axarr[1,1].set_ylabel('number of nodes')
    #plot_cumdist(vals2,axarr[2,1])
    #axarr[2,1].set_xlabel('strength')
    #axarr[2,1].set_ylabel('number of nodes\nwith higher strength',multialignment='center')

    vals3 = [i[2]['weight'] for i in G.edges(data=True)]
    axarr[0,2].hist(map(lambda x: x/1000.0, vals3))
    axarr[0,2].set_xlabel(r'edge weight ($10^3$)')
    axarr[0,2].set_ylabel('number of edges')
    axarr[1,2].hist([map(np.log, vals3)])
    axarr[1,2].set_xlabel('logarithm of edge weight')
    axarr[1,2].set_ylabel('number of nodes')
    #plot_cumdist(vals3,axarr[2,2])
    #axarr[2,2].set_xlabel('edge weight')
    #axarr[2,2].set_ylabel('number of edges\nwith higher weight',multialignment='center')

    font = {'family' : 'normal',
            'size'   : 10}

    import matplotlib
    matplotlib.rc('font', **font)

    plt.tight_layout()
    if filepath is None:
        plt.show()
    else:
        #plt.savefig(filepath,dpi=100)
        plt.savefig(filepath,format='pdf')




def plot_deg_cumdist(G, direction='both'):
    if direction == 'both':
        deg = G.degree()
    elif direction == 'out':
        deg = G.out_degree()
    elif direction == 'in':
        deg = G.in_degree()
    
    degs = deg.values()
    _plot_cumdist(degs)


def plot_weight_cumdist(G, w='weight'):
    weights = [i[2][w] for i in G.edges(data=True)]
    _plot_cumdist(weights)


def plot_strength_cumdist(G, direction='both', w='weight'):
    import matplotlib.pylab as plt
    if direction == 'both':
        deg = G.degree(weight=w)
    elif direction == 'out':
        deg = G.out_degree(weight=w)
    elif direction == 'in':
        deg = G.in_degree(weight=w)
    degs = deg.values()
    _plot_cumdist(degs)

def plot_weight_dist(G, w='weight'):
    import matplotlib.pylab as plt
    weight = sorted([i[2][w] for i in G.edges(data=True)])
    bins = np.logspace(np.log10(weight[0]),np.ceil(np.log10(weight[-1])),num=30)
    weight_hist, _ = np.histogram(weight, bins)
    ax = plt.subplot(111)
    ax.scatter(bins[:-1], weight_hist)
    ax.set_xscale('log')
    #ax.set_yscale('log')
    plt.show()


def plot_strength_dist(G, direction='both', w='weight'):
    import matplotlib.pylab as plt
    if direction == 'both':
        deg = G.degree(weight=w)
    elif direction == 'out':
        deg = G.out_degree(weight=w)
    elif direction == 'in':
        deg = G.in_degree(weight=w)
    
    deg_val = sorted(deg.values())
    bins = np.logspace(np.log10(deg_val[0]),np.ceil(np.log10(deg_val[-1])),num=20)

    deg_hist, _ = np.histogram(deg_val, bins)
    ax = plt.subplot(111)
    ax.scatter(bins[:-1], deg_hist)
    ax.set_xscale('log')
    #ax.set_yscale('log')
    plt.show()

def compute_metrics(G, w='weight'):
    for e in G.edges():
        G[e[0]][e[1]][w] = float(G[e[0]][e[1]][w])

    pr = nx.pagerank(G,weight=w, tol=0.000001)
    nx.set_node_attributes(G,'pagerank',pr)

    eig = nx.eigenvector_centrality_numpy(G)
    nx.set_node_attributes(G, 'eigencent',eig)

    ug = _di_to_undi(G)
    cf = nx.current_flow_betweenness_centrality(ug,weight=w)
    cf2 = dict.fromkeys(cf)
    for k in cf2.keys():
        cf2[k] = float(cf[k])
    nx.set_node_attributes(G,'currentflow',cf2)

    deg = G.degree()
    nx.set_node_attributes(G,'degree',deg)
    
    stren = G.degree(weight=w)
    nx.set_node_attributes(G,'strength',stren)


def sort_nodes_by(G,attribute):
    return [(a,b[attribute]) for (a,b) in sorted(G.nodes(data = True), key = lambda (n, dct): dct[attribute],reverse=True)]

