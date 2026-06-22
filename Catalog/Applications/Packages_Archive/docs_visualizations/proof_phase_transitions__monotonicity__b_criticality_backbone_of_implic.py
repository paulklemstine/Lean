"""Visualization: the criticality backbone of the chain theory and a richer theory.

Highlights, for the goal 0 |- n, exactly which axioms are critical (their removal breaks
the proof). On the chain every axiom is critical (index 1); adding shortcut edges lowers
criticality. Requires matplotlib + networkx.
"""
from typing import Set, Tuple
import matplotlib.pyplot as plt
import networkx as nx

Edge = Tuple[int, int]

def reachable(edges: Set[Edge], a: int, b: int) -> bool:
    g = nx.DiGraph(list(edges)); g.add_node(a); g.add_node(b)
    return nx.has_path(g, a, b)

def critical(edges: Set[Edge], a: int, b: int) -> Set[Edge]:
    return {e for e in edges if not reachable(edges - {e}, a, b)}

def draw(edges: Set[Edge], n: int, title: str, ax) -> None:
    g = nx.DiGraph(list(edges))
    crit = critical(edges, 0, n)
    pos = {k: (k, 0) for k in range(n + 1)}
    for k in range(n + 1):
        g.add_node(k); pos.setdefault(k, (k, 0))
    colors = ["crimson" if e in crit else "lightsteelblue" for e in g.edges()]
    widths = [2.6 if e in crit else 1.0 for e in g.edges()]
    nx.draw_networkx_nodes(g, pos, node_color="white", edgecolors="black",
                           node_size=420, ax=ax)
    nx.draw_networkx_labels(g, pos, ax=ax)
    nx.draw_networkx_edges(g, pos, edge_color=colors, width=widths,
                           connectionstyle="arc3,rad=0.25", ax=ax)
    ax.set_title(f"{title}\\ncritical axioms (red): {len(crit)}")
    ax.axis("off")

def main() -> None:
    n = 6
    chain = {(k, k + 1) for k in range(n)}
    withshortcut = chain | {(0, 3), (3, 6)}
    fig, axes = plt.subplots(2, 1, figsize=(8, 6))
    draw(chain, n, "Chain theory: every axiom is critical (index 1)", axes[0])
    draw(withshortcut, n, "With shortcuts 0->3, 3->6: criticality drops", axes[1])
    plt.tight_layout(); plt.savefig("criticality_backbone.png", dpi=150)
    print("saved criticality_backbone.png")

if __name__ == "__main__":
    main()
