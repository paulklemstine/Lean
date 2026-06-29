"""
Visualization for Mantel's theorem and the Turan extremal graphs.

Left panel: the Mantel ceiling 4|E| <= n^2, i.e. the maximum number of
edges floor(n^2/4) of a triangle-free graph, plotted against n, together
with the total number of possible edges C(n,2). The triangle-free maximum
hugs exactly half of the total -- the "half-and-half world".

Right panel: the balanced complete bipartite extremizer T(n,2) = K_{a,b}
drawn as two columns of vertices with all cross edges, the unique densest
triangle-free graph.

Saves 'extremal_graph_viz.png'. Requires matplotlib.
"""

from __future__ import annotations

from itertools import combinations
from typing import List

import matplotlib.pyplot as plt


def mantel_max_edges(n: int) -> int:
    return n * n // 4


def total_edges(n: int) -> int:
    return n * (n - 1) // 2


def make_figure() -> None:
    ns: List[int] = list(range(2, 31))
    mantel = [mantel_max_edges(n) for n in ns]
    total = [total_edges(n) for n in ns]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5.5))

    # Left: Mantel ceiling vs total possible edges
    ax1.plot(ns, total, "o-", color="#c0392b", label="all possible edges  C(n,2)")
    ax1.plot(ns, mantel, "s-", color="#2980b9",
             label="max triangle-free edges  floor(n^2/4)")
    ax1.fill_between(ns, mantel, total, color="#c0392b", alpha=0.12,
                     label="forbidden by triangle-freeness")
    ax1.set_xlabel("number of vertices  n")
    ax1.set_ylabel("number of edges")
    ax1.set_title("Mantel's theorem: forbidding triangles\nhalves the edge budget")
    ax1.legend(loc="upper left", fontsize=9)
    ax1.grid(True, alpha=0.3)

    # Right: K_{a,b} extremizer for n = 12
    n = 12
    a, b = n // 2, n - n // 2
    left_y = [i for i in range(a)]
    right_y = [i for i in range(b)]
    for u in range(a):
        for v in range(b):
            ax2.plot([0, 1], [left_y[u], right_y[v]], color="#7f8c8d",
                     alpha=0.35, linewidth=0.7, zorder=1)
    ax2.scatter([0] * a, left_y, s=180, color="#2980b9", zorder=2,
                edgecolor="black")
    ax2.scatter([1] * b, right_y, s=180, color="#27ae60", zorder=2,
                edgecolor="black")
    ax2.set_title(f"The extremal world  T({n},2) = K_{{{a},{b}}}\n"
                  f"|E| = {a*b} = floor({n}^2/4),  triangle-free")
    ax2.set_xlim(-0.4, 1.4)
    ax2.axis("off")

    fig.tight_layout()
    fig.savefig("extremal_graph_viz.png", dpi=150)
    print("wrote extremal_graph_viz.png")


if __name__ == "__main__":
    make_figure()
