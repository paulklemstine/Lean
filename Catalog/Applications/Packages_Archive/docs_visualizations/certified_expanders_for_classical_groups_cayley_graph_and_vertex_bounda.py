import itertools
import networkx as nx
import matplotlib.pyplot as plt

def compose(a, b):
    return tuple(a[b[i]] for i in range(len(a)))

def closure(gens, e):
    seen = {e}; frontier = [e]
    while frontier:
        nxt = []
        for g in frontier:
            for s in gens:
                h = compose(g, s)
                if h not in seen:
                    seen.add(h); nxt.append(h)
        frontier = nxt
    return sorted(seen)

e = (0, 1, 2, 3)
transp = (1, 0, 2, 3); cycle = (1, 2, 3, 0)
def inv(p):
    o = [0]*len(p)
    for i, j in enumerate(p): o[j] = i
    return tuple(o)
S = [transp, cycle, inv(transp), inv(cycle)]
G = closure(S, e)

Gr = nx.DiGraph()
Gr.add_nodes_from(G)
for g in G:
    for s in S:
        Gr.add_edge(g, compose(g, s))

A = set(G[:6])
neigh = {compose(a, s) for a in A for s in S}
boundary = neigh - A
colors = ['#d62728' if v in A else '#1f77b4' if v in boundary else '#cccccc'
          for v in Gr.nodes()]
pos = nx.spring_layout(Gr, seed=1)
nx.draw(Gr, pos, node_color=colors, node_size=120, arrows=False,
        edge_color='#999999', width=0.4)
plt.title('Cay(S4, S): A (red), vertex boundary (blue)')
plt.savefig('cayley_boundary.png', dpi=160, bbox_inches='tight')
print('wrote cayley_boundary.png')
