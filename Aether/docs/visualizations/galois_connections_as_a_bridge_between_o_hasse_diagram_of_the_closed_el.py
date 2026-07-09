"""Visualization: the fixed-point correspondence and closed-element lattice.

Generates two figures:
  (1) A Hasse-style diagram of the lattice of closed elements of a Galois
      connection (here the divisor-closure closure system).
  (2) A bipartite picture of the order isomorphism between closed elements of
      alpha and coclosed elements of beta (extents vs. intents of a formal
      context).

Requires matplotlib and networkx. Run:  python3 _viz.py
"""

from __future__ import annotations

from itertools import combinations
from typing import FrozenSet, List

import matplotlib.pyplot as plt
import networkx as nx


def powerset(items: List[int]) -> List[FrozenSet[int]]:
    return [frozenset(c) for r in range(len(items) + 1)
            for c in combinations(items, r)]


def divisor_closure(universe: List[int]):
    def l(X: FrozenSet[int]) -> FrozenSet[int]:
        out = set()
        for n in X:
            out |= {d for d in universe if n % d == 0}
        return frozenset(out)
    u = lambda Y: frozenset(
        n for n in Y if all(d in Y for d in {d for d in universe if n % d == 0})
    )
    return l, u


def main() -> None:
    universe = [1, 2, 3, 4, 6, 12]
    l, u = divisor_closure(universe)
    cl = lambda a: u(l(a))
    closed = [a for a in powerset(universe) if cl(a) == a]

    # Hasse diagram: edge from C to D if C subset D and no element strictly between
    G = nx.DiGraph()
    labels = {c: "{" + ",".join(map(str, sorted(c))) + "}" for c in closed}
    G.add_nodes_from(closed)
    for c in closed:
        for d in closed:
            if c < d and not any(c < e < d for e in closed):
                G.add_edge(c, d)

    # layer nodes by cardinality for a tidy Hasse layout
    pos = {}
    by_size: dict[int, List[FrozenSet[int]]] = {}
    for c in closed:
        by_size.setdefault(len(c), []).append(c)
    for size, nodes in by_size.items():
        for i, n in enumerate(sorted(nodes, key=lambda s: sorted(s))):
            pos[n] = (i - (len(nodes) - 1) / 2, size)

    plt.figure(figsize=(9, 6))
    nx.draw_networkx_edges(G, pos, arrows=False, edge_color="#888")
    nx.draw_networkx_nodes(G, pos, node_color="#cfe8ff",
                           edgecolors="#1f6feb", node_size=1600)
    nx.draw_networkx_labels(G, pos, labels=labels, font_size=8)
    plt.title("Lattice of closed elements (divisor-closure closure system)")
    plt.axis("off")
    plt.tight_layout()
    plt.savefig("closed_lattice.png", dpi=150)
    print("wrote closed_lattice.png")


if __name__ == "__main__":
    main()
