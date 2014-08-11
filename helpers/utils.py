import networkx as nx

def read_ghrg(filepath):
    with open(filepath) as f:
        content = f.readlines()
    G = nx.DiGraph()
    
    for line in content:
        fields = line.strip().split("\t")

        # node id on pos 0
        id = fields[0].split(" ")[1] # ^[ id ]\t
        node_id = "%s (D)"%(id)
        G.add_node(node_id)

        # ignore weight on pos 1
        # ignore parent on pos 2

        # children on pos 3
        ch = fields[3].split(" ")
        for i in range(2, len(ch),2):
            child_id = ch[i] + " " + ch[i+1]
            G.add_node(child_id)
            G.add_edge(node_id, child_id)

    return G

