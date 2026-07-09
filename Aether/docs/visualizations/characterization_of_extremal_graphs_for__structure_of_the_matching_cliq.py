"""Visualization 1: draw the matching-clique join H(k) with matplotlib.

Block A (perfect matching) on the left, block B (clique) on the right; the
complete bipartite join is drawn lightly so the sparse matching edges stand out.
"""
from __future__ import annotations
import math
from itertools import combinations
import matplotlib.pyplot as plt

def draw(k: int) -> None:
    A = [("A", p, b) for p in range(k) for b in (0, 1)]
    B = [("B", i, 0) for i in range(2 * k)]
    pos = {}
    for idx, v in enumerate(A):
        pos[v] = (0.0, -idx)
    for idx, v in enumerate(B):
        pos[v] = (3.0, -idx * (len(A) / max(1, len(B))))
    fig, ax = plt.subplots(figsize=(7, 8))
    # join edges (light grey)
    for a in A:
        for b in B:
            ax.plot(*zip(pos[a], pos[b]), color="0.85", lw=0.3, zorder=1)
    # clique edges (blue)
    for i, j in combinations(range(2 * k), 2):
        ax.plot(*zip(pos[("B", i, 0)], pos[("B", j, 0)]),
                color="steelblue", lw=0.5, alpha=0.5, zorder=2)
    # matching edges (red, bold) -- the curvature-minimising class
    for p in range(k):
        ax.plot(*zip(pos[("A", p, 0)], pos[("A", p, 1)]),
                color="crimson", lw=2.5, zorder=3)
    for v, (x, y) in pos.items():
        ax.scatter([x], [y], s=60,
                   color="crimson" if v[0] == "A" else "steelblue", zorder=4)
    ax.set_title(f"Matching-clique join H({k}) on n={4*k} vertices\n"
                 f"red = matching (locally sparsest), blue = clique")
    ax.axis("off")
    plt.tight_layout()
    plt.savefig("matching_clique_join.png", dpi=150)
    print("saved matching_clique_join.png")

if __name__ == "__main__":
    draw(3)
