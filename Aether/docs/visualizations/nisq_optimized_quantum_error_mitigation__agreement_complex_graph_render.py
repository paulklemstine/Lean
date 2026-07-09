import matplotlib.pyplot as plt
import networkx as nx
from itertools import combinations
from typing import Tuple

Readout = Tuple[bool, ...]


def draw_agreement_complex(s: Readout, ax=None):
    """Render the agreement complex of a readout and annotate its betti0."""
    n = len(s)
    G = nx.Graph()
    G.add_nodes_from(range(n))
    for i, j in combinations(range(n), 2):
        if s[i] == s[j]:
            G.add_edge(i, j)
    b0 = len(set(s)) if n else 0
    colors = ["#e74c3c" if s[k] else "#3498db" for k in range(n)]
    pos = nx.spring_layout(G, seed=1)
    ax = ax or plt.gca()
    nx.draw(G, pos, ax=ax, node_color=colors, with_labels=True,
            edge_color="#bbbbbb", node_size=600)
    bits = "".join("1" if x else "0" for x in s)
    ax.set_title(f"readout {bits}   betti0 = {b0}")
    return ax


if __name__ == "__main__":
    fig, axes = plt.subplots(1, 2, figsize=(10, 4))
    draw_agreement_complex((True, True, True, True, True), axes[0])
    draw_agreement_complex((True, True, False, True, True), axes[1])
    plt.tight_layout()
    plt.savefig("agreement_complex.png", dpi=150)
    print("Saved agreement_complex.png")
