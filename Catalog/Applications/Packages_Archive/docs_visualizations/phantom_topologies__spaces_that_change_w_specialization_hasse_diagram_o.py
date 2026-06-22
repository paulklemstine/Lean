import matplotlib.pyplot as plt
import networkx as nx
from itertools import product

# Sierpinski-like 3-point chain: opens are lower sets of 0 < 1 < 2
carrier = [0, 1, 2]
leq = {(0, 0), (1, 1), (2, 2), (0, 1), (1, 2), (0, 2)}  # y <= x

def specializes(b, a):
    # in lower-set topology, b ~> a  iff  b <= a
    return (b, a) in leq

G = nx.DiGraph()
G.add_nodes_from(carrier)
for b, a in product(carrier, carrier):
    if b != a and specializes(b, a):
        # keep only covering relations for a clean Hasse diagram
        if not any(specializes(b, c) and specializes(c, a)
                   for c in carrier if c not in (a, b)):
            G.add_edge(b, a)

pos = {0: (0, 0), 1: (0, 1), 2: (0, 2)}
plt.figure(figsize=(4, 6))
nx.draw(G, pos, with_labels=True, node_size=1400, node_color='#9ad0ec',
        font_size=14, arrowsize=22, edge_color='#34508a')
plt.title('Specialization Hasse diagram\n(edge b -> a means b ~> a)')
plt.axis('off')
plt.tight_layout()
plt.savefig('specialization_hasse.png', dpi=150)
print('wrote specialization_hasse.png')
