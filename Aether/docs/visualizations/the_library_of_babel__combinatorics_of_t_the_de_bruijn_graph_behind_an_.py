"""Visualization: the de Bruijn graph B(A, k) for a small toy case."""
import networkx as nx
import matplotlib.pyplot as plt
from itertools import product

A, k = 4, 2
G = nx.MultiDiGraph()
for v in product(range(A), repeat=k - 1):
    for s in range(A):
        u = v[1:] + (s,)
        G.add_edge("".join(map(str, v)), "".join(map(str, u)), label=str(s))
pos = nx.circular_layout(G)
nx.draw(G, pos, with_labels=True, node_color="#ffd28a",
        node_size=900, arrows=True, connectionstyle="arc3,rad=0.15")
plt.title(f"de Bruijn graph B(A={A}, k={k}): Eulerian => optimal code tour")
plt.tight_layout(); plt.savefig("viz_debruijn.png", dpi=150)
print("saved viz_debruijn.png")
