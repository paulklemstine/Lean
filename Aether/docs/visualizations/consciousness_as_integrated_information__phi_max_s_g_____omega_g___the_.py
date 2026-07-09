"""
visualization.py — Visualize the reduction Phi_max(S(G)) = omega(G).

Draws a small graph G, highlights its maximum clique (= largest co-active
coalition of the induced system S(G)), and plots Phi_max vs. clique number
across a family of graphs to illustrate the exact reduction theorem.

Run: python visualization.py   (requires matplotlib; networkx optional)
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, List, Tuple

import matplotlib.pyplot as plt
import numpy as np

Graph = Tuple[int, List[Tuple[int, int]]]


def clique_number_and_witness(g: Graph) -> Tuple[int, FrozenSet[int]]:
    n, edges = g
    adj = {frozenset((u, v)) for u, v in edges}

    def is_clique(s: Tuple[int, ...]) -> bool:
        return all(frozenset((u, v)) in adj for u, v in combinations(s, 2))

    best_size, best_set = 0, frozenset()
    for r in range(2, n + 1):
        for s in combinations(range(n), r):
            if is_clique(s):
                if r > best_size:
                    best_size, best_set = r, frozenset(s)
    return best_size, best_set


def circle_layout(n: int) -> Dict[int, Tuple[float, float]]:
    return {
        i: (float(np.cos(2 * np.pi * i / n)), float(np.sin(2 * np.pi * i / n)))
        for i in range(n)
    }


def draw_graph_with_clique(ax, g: Graph, title: str) -> None:
    n, edges = g
    pos = circle_layout(n)
    omega, clique = clique_number_and_witness(g)
    clique_edges = {frozenset(e) for e in combinations(sorted(clique), 2)}

    for u, v in edges:
        x = [pos[u][0], pos[v][0]]
        y = [pos[u][1], pos[v][1]]
        in_clique = frozenset((u, v)) in clique_edges
        ax.plot(x, y, color="#d62728" if in_clique else "#bbbbbb",
                lw=3.0 if in_clique else 1.2, zorder=1)
    for i, (x, y) in pos.items():
        on = i in clique
        ax.scatter([x], [y], s=520, zorder=2,
                   color="#d62728" if on else "#1f77b4",
                   edgecolors="black", linewidths=1.0)
        ax.text(x, y, str(i), ha="center", va="center",
                color="white", fontsize=11, fontweight="bold", zorder=3)
    ax.set_title(f"{title}\nomega(G) = Phi_max(S(G)) = {omega}", fontsize=11)
    ax.set_aspect("equal")
    ax.axis("off")


def main() -> None:
    graphs = [
        ("Triangle K3", (3, [(0, 1), (1, 2), (0, 2)])),
        ("Complete K4", (4, [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)])),
        ("K4 + pendant", (5, [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3),
                              (2, 3), (3, 4)])),
        ("Two triangles", (6, [(0, 1), (1, 2), (0, 2), (3, 4), (4, 5), (3, 5)])),
    ]

    fig = plt.figure(figsize=(12, 7))
    for idx, (name, g) in enumerate(graphs):
        ax = fig.add_subplot(2, 3, idx + 1)
        draw_graph_with_clique(ax, g, name)

    # Scatter: Phi_max (== omega) vs |V|, confirming the linear ceiling Phi <= n.
    ax = fig.add_subplot(2, 3, (5, 6))
    ns = [g[0] for _, g in graphs]
    omegas = [clique_number_and_witness(g)[0] for _, g in graphs]
    ax.plot(range(0, max(ns) + 2), range(0, max(ns) + 2),
            "--", color="gray", label="ceiling Phi_max = n")
    ax.scatter(ns, omegas, s=120, color="#d62728", zorder=3,
               label="Phi_max(S(G)) = omega(G)")
    for (name, _), x, y in zip(graphs, ns, omegas):
        ax.annotate(name, (x, y), textcoords="offset points",
                    xytext=(6, 6), fontsize=8)
    ax.set_xlabel("number of variables n")
    ax.set_ylabel("Phi_max")
    ax.set_title("Integrated information vs. system size")
    ax.legend(fontsize=9)
    ax.grid(alpha=0.3)

    fig.suptitle("Phi_max(S(G)) = omega(G): the exact CLIQUE reduction",
                 fontsize=14, fontweight="bold")
    fig.tight_layout(rect=(0, 0, 1, 0.96))
    fig.savefig("phi_clique_reduction.png", dpi=150)
    print("Saved phi_clique_reduction.png")


if __name__ == "__main__":
    main()
