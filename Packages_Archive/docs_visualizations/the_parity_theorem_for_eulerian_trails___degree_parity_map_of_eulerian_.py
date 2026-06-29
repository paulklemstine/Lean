"""Visualization: degree parity and Eulerian feasibility.

Renders three small multigraphs (open-trail graph, closed-with-loop graph, and
the Seven Bridges of Koenigsberg) as node-link diagrams, coloring vertices by
degree parity (red = odd, blue = even) and annotating each with its degree.
The title of each panel reports the Eulerian verdict implied by the parity
theorem. Requires matplotlib and networkx.

    python3 visualization.py
"""
from typing import List, Tuple
import matplotlib.pyplot as plt
import networkx as nx


def build(endpt1: List[int], endpt2: List[int], n: int) -> nx.MultiGraph:
    g = nx.MultiGraph()
    g.add_nodes_from(range(n))
    for a, b in zip(endpt1, endpt2):
        g.add_edge(a, b)
    return g


def degree_with_loops(endpt1: List[int], endpt2: List[int], v: int) -> int:
    return sum(1 for x in endpt1 if x == v) + sum(1 for x in endpt2 if x == v)


def verdict(endpt1: List[int], endpt2: List[int], n: int) -> str:
    odd = [v for v in range(n)
           if degree_with_loops(endpt1, endpt2, v) % 2 == 1]
    if len(odd) == 0:
        return "Closed Eulerian trail exists"
    if len(odd) == 2:
        return "Open Eulerian trail exists"
    return f"No Eulerian trail ({len(odd)} odd vertices)"


examples: List[Tuple[str, List[int], List[int], int]] = [
    ("Open trail", [0, 1, 2, 0], [1, 2, 0, 3], 4),
    ("Closed trail + loop", [0, 1, 2, 0], [1, 2, 0, 0], 3),
    ("Koenigsberg", [0, 0, 0, 0, 0, 1, 2], [1, 1, 2, 2, 3, 3, 3], 4),
]

fig, axes = plt.subplots(1, 3, figsize=(15, 5))
for ax, (name, e1, e2, n) in zip(axes, examples):
    g = build(e1, e2, n)
    pos = nx.spring_layout(g, seed=7)
    colors = ["#d62728" if degree_with_loops(e1, e2, v) % 2 else "#1f77b4"
              for v in range(n)]
    nx.draw_networkx_edges(g, pos, ax=ax, alpha=0.5)
    nx.draw_networkx_nodes(g, pos, ax=ax, node_color=colors, node_size=900)
    labels = {v: f"{v}\nd={degree_with_loops(e1, e2, v)}" for v in range(n)}
    nx.draw_networkx_labels(g, pos, labels, ax=ax, font_color="white",
                            font_size=9)
    ax.set_title(f"{name}\n{verdict(e1, e2, n)}", fontsize=11)
    ax.axis("off")

fig.suptitle("Degree parity decides Eulerian feasibility "
             "(red = odd, blue = even)", fontsize=13)
plt.tight_layout()
plt.savefig("eulerian_parity.png", dpi=150)
print("wrote eulerian_parity.png")
