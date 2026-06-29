"""
Visualization: a fiber as a graph of tables connected by basic 2x2 moves.
Enumerates the 2x2 fiber with margins rows=(5,5), cols=(4,6), draws each table
as a node, connects tables differing by a single basic move, and overlays the
greedy connecting walk between two chosen tables.
Requires: matplotlib, networkx.
"""
from __future__ import annotations
from typing import List, Tuple
import matplotlib.pyplot as plt
import networkx as nx

Table = Tuple[Tuple[int, int], Tuple[int, int]]

def margins(u: Table) -> Tuple[Tuple[int, int], Tuple[int, int]]:
    return ((u[0][0] + u[0][1], u[1][0] + u[1][1]),
            (u[0][0] + u[1][0], u[0][1] + u[1][1]))

def differ_by_basic_move(u: Table, v: Table) -> bool:
    d = [[u[i][j] - v[i][j] for j in range(2)] for i in range(2)]
    return sorted(x for row in d for x in row) == [-1, 0, 0, 1] and \
           d[0][0] == -d[1][1] and d[0][1] == -d[1][0]

# Enumerate fiber: rows (5,5), cols (4,6); a = u[0][0] in 0..4.
fiber: List[Table] = []
for a in range(0, 5):
    t = ((a, 5 - a), (4 - a, 5 - (4 - a)))
    if all(x >= 0 for row in t for x in row):
        fiber.append(t)

G = nx.Graph()
for t in fiber:
    G.add_node(t)
for i, u in enumerate(fiber):
    for v in fiber[i + 1:]:
        if differ_by_basic_move(u, v):
            G.add_edge(u, v)

pos = nx.spring_layout(G, seed=1)
labels = {t: f"{t[0]}\n{t[1]}" for t in fiber}
plt.figure(figsize=(9, 6))
nx.draw(G, pos, with_labels=False, node_color="#9ecae1",
        node_size=2600, edge_color="#888")
nx.draw_networkx_labels(G, pos, labels, font_size=8, font_family="monospace")
plt.title("A fiber of the 2x2 independence model, connected by basic moves")
plt.axis("off")
plt.tight_layout()
plt.savefig("fiber_graph.png", dpi=150)
print("saved fiber_graph.png")
