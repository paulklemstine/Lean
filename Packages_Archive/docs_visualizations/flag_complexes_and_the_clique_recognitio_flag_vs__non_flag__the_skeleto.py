"""
Visualization: a graph, its clique complex, and a hollow (non-flag) counterpart.

Draws three panels with matplotlib:
  (1) the 4-cycle-with-diagonal graph,
  (2) its clique complex (two filled triangles) -- a FLAG complex,
  (3) the hollow triangle -- a NON-flag complex whose three edges fail to fill.

Run:  python3 visualize_flag.py   (requires matplotlib, numpy)
"""
from itertools import combinations
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt
import numpy as np


def regular_positions(n: int) -> Dict[int, Tuple[float, float]]:
    return {i: (np.cos(2 * np.pi * i / n), np.sin(2 * np.pi * i / n))
            for i in range(n)}


def draw_complex(ax, pos: Dict[int, Tuple[float, float]],
                 edges: List[Tuple[int, int]],
                 triangles: List[Tuple[int, int, int]],
                 title: str) -> None:
    for (a, b, c) in triangles:
        poly = np.array([pos[a], pos[b], pos[c]])
        ax.fill(poly[:, 0], poly[:, 1], color="#7aa6ff", alpha=0.45, zorder=1)
    for (a, b) in edges:
        xs, ys = zip(pos[a], pos[b])
        ax.plot(xs, ys, color="#1f3b73", lw=2.5, zorder=2)
    for v, (x, y) in pos.items():
        ax.plot(x, y, "o", color="#0b1d4d", ms=14, zorder=3)
        ax.annotate(str(v), (x, y), color="white", ha="center", va="center",
                    fontsize=10, fontweight="bold", zorder=4)
    ax.set_title(title, fontsize=12)
    ax.set_aspect("equal"); ax.axis("off")


def main() -> None:
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    pos4 = regular_positions(4)
    edges_g = [(0, 1), (1, 2), (2, 3), (3, 0), (0, 2)]
    draw_complex(axes[0], pos4, edges_g, [], "Graph G (1-skeleton)")
    draw_complex(axes[1], pos4, edges_g, [(0, 1, 2), (0, 2, 3)],
                 "cliqueComplex(G): FLAG (filled)")

    pos3 = regular_positions(3)
    edges_h = [(0, 1), (1, 2), (2, 0)]
    draw_complex(axes[2], pos3, edges_h, [],
                 "Hollow triangle: NOT flag (unfilled clique)")

    fig.suptitle("Flag vs. non-flag: the skeleton's cliques must be filled",
                 fontsize=14)
    fig.tight_layout()
    fig.savefig("flag_complex.png", dpi=150)
    print("wrote flag_complex.png")


if __name__ == "__main__":
    main()
