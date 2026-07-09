"""Visualization: the associahedron flip graph of a convex m-gon.

Draws every triangulation of an m-gon (m chosen so the picture is legible),
laying out the flip graph whose vertices are triangulations and whose edges are
single diagonal flips. The number of vertices is the Catalan number C(m-2) and
every vertex has degree m-3. For m = 6 this is the 3D associahedron's graph with
14 vertices; we render it in 2D via a spring layout.

Requires: matplotlib, networkx.  Run:  python3 _viz.py
"""

from __future__ import annotations

from itertools import combinations
from typing import FrozenSet, List, Set, Tuple

import matplotlib.pyplot as plt
import networkx as nx


def is_side(i: int, j: int, m: int) -> bool:
    return (j - i) % m == 1 or (i - j) % m == 1


def crosses(d1: Tuple[int, int], d2: Tuple[int, int]) -> bool:
    a, b = sorted(d1)
    c, d = sorted(d2)
    if {a, b} & {c, d}:
        return False
    return (a < c < b) != (a < d < b)


def triangulations(m: int) -> List[FrozenSet[Tuple[int, int]]]:
    chords = [(i, j) for i, j in combinations(range(m), 2) if not is_side(i, j, m)]
    k = m - 3
    out: List[FrozenSet[Tuple[int, int]]] = []
    if k == 0:
        return [frozenset()]
    for combo in combinations(chords, k):
        if all(not crosses(x, y) for x, y in combinations(combo, 2)):
            out.append(frozenset(combo))
    return out


def build_flip_graph(m: int) -> nx.Graph:
    tris = triangulations(m)
    g = nx.Graph()
    g.add_nodes_from(range(len(tris)))
    for a, b in combinations(range(len(tris)), 2):
        if len(tris[a].symmetric_difference(tris[b])) == 2:
            g.add_edge(a, b)
    return g


def main(m: int = 6) -> None:
    g = build_flip_graph(m)
    pos = nx.spring_layout(g, seed=7, k=1.3)
    plt.figure(figsize=(8, 8))
    nx.draw_networkx_edges(g, pos, edge_color="#5ad1c2", width=2, alpha=0.7)
    nx.draw_networkx_nodes(g, pos, node_color="#f5a25d", node_size=420,
                           edgecolors="#0e1320")
    nx.draw_networkx_labels(g, pos, font_size=9, font_color="#0e1320")
    deg = dict(g.degree())
    regular = all(d == m - 3 for d in deg.values())
    plt.title(f"Associahedron flip graph of the {m}-gon  (type A_{m-3})\n"
              f"{g.number_of_nodes()} triangulations = Catalan({m-2}), "
              f"{'(m-3)-regular' if regular else 'irregular'}, "
              f"{g.number_of_edges()} flips")
    plt.axis("off")
    plt.tight_layout()
    plt.savefig("associahedron_flip_graph.png", dpi=150)
    print(f"Wrote associahedron_flip_graph.png "
          f"({g.number_of_nodes()} nodes, {g.number_of_edges()} edges)")


if __name__ == "__main__":
    main()
