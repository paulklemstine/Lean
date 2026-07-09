from __future__ import annotations

import math
from itertools import combinations
from typing import Dict, List, Set, Tuple

import matplotlib.pyplot as plt

Graph = Dict[int, Set[int]]


def complete_graph(n: int) -> Graph:
    return {i: {j for j in range(n) if j != i} for i in range(n)}


def delete_path_edges(g: Graph, path: List[int]) -> Graph:
    edges = {frozenset((path[i], path[i + 1])) for i in range(len(path) - 1)}
    h: Graph = {v: set(g[v]) for v in g}
    for e in edges:
        a, b = tuple(e)
        h[a].discard(b)
        h[b].discard(a)
    return h


def circular_positions(n: int) -> Dict[int, Tuple[float, float]]:
    return {i: (math.cos(2 * math.pi * i / n), math.sin(2 * math.pi * i / n))
            for i in range(n)}


def draw(ax, g: Graph, pos, title: str, highlight: Set[frozenset] | None = None) -> None:
    highlight = highlight or set()
    for a, b in combinations(sorted(g), 2):
        if b in g[a]:
            e = frozenset((a, b))
            color = "crimson" if e in highlight else "lightgray"
            lw = 2.4 if e in highlight else 0.7
            (x1, y1), (x2, y2) = pos[a], pos[b]
            ax.plot([x1, x2], [y1, y2], color=color, lw=lw, zorder=1)
    for v, (x, y) in pos.items():
        ax.scatter([x], [y], s=420, color="#1f4e79", zorder=2)
        ax.text(x, y, str(v), color="white", ha="center", va="center",
                fontsize=10, zorder=3)
    ax.set_title(title, fontsize=12)
    ax.set_aspect("equal")
    ax.axis("off")


def main() -> None:
    """
    Visualize the connectivity-preserving deletion on K_12 (k=2, n=4k+4):
    left panel shows K_12 with a Hamiltonian path highlighted; right panel shows
    the residual graph G - E(P), which remains 2-connected with min degree 9.
    """
    n, k = 12, 2
    g = complete_graph(n)
    path = list(range(n))
    path_edges = {frozenset((path[i], path[i + 1])) for i in range(len(path) - 1)}
    h = delete_path_edges(g, path)
    pos = circular_positions(n)

    fig, axes = plt.subplots(1, 2, figsize=(12, 6))
    draw(axes[0], g, pos,
         f"K_{n}: Hamiltonian path P (red) to be deleted", highlight=path_edges)
    delta_after = min(len(h[v]) for v in h)
    draw(axes[1], h, pos,
         f"G - E(P): still {k}-connected, min degree {delta_after} (>= 2k+1={2*k+1})")
    fig.suptitle("Connectivity-preserving Hamiltonian path deletion (4k+4 regime)",
                 fontsize=14)
    fig.tight_layout()
    fig.savefig("conn_preserving_deletion.png", dpi=150)
    print("saved conn_preserving_deletion.png")


if __name__ == "__main__":
    main()
