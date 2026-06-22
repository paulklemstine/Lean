"""
Visualization: the mirror as a vertical reflection of the Hodge diamond, and the
Euler-number sign flip across complex dimension. Produces a two-panel figure.

Run:  python3 _viz.py   ->  writes arithmetic_mirror.png
"""

from __future__ import annotations

from typing import Dict, Tuple

import matplotlib.pyplot as plt
import numpy as np


def diamond_grid(table: Dict[Tuple[int, int], int], d: int) -> np.ndarray:
    """Return a (d+1) x (d+1) array g[q, p] = h(p, q)."""
    g = np.zeros((d + 1, d + 1), dtype=int)
    for p in range(d + 1):
        for q in range(d + 1):
            g[q, p] = table.get((p, q), 0)
    return g


def mirror_table(table: Dict[Tuple[int, int], int], d: int) -> Dict[Tuple[int, int], int]:
    """Vertical reflection p -> d - p."""
    return {(p, q): table.get((d - p, q), 0)
            for p in range(d + 1) for q in range(d + 1)}


def draw_diamond(ax, table: Dict[Tuple[int, int], int], d: int, title: str) -> None:
    g = diamond_grid(table, d)
    im = ax.imshow(g, cmap="magma", origin="lower")
    for p in range(d + 1):
        for q in range(d + 1):
            ax.text(p, q, str(g[q, p]), ha="center", va="center",
                    color="white" if g[q, p] < g.max() / 2 else "black",
                    fontsize=11, fontweight="bold")
    ax.set_title(title, fontsize=12)
    ax.set_xlabel("p  (column index)")
    ax.set_ylabel("q  (row index)")
    ax.set_xticks(range(d + 1))
    ax.set_yticks(range(d + 1))
    return im


def main() -> None:
    # quintic threefold, d = 3
    d = 3
    X = {(0, 0): 1, (3, 3): 1, (3, 0): 1, (0, 3): 1,
         (1, 1): 1, (2, 2): 1, (2, 1): 101, (1, 2): 101}
    Y = mirror_table(X, d)

    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    draw_diamond(axes[0], X, d, "Quintic X : h(1,1)=1, h(2,1)=101")
    draw_diamond(axes[1], Y, d, "Mirror Y = reflect p->d-p : h(1,1)=101")
    fig.suptitle("Arithmetic Mirror Symmetry: Picard rank of Y = curve count of X",
                 fontsize=14, fontweight="bold")
    fig.tight_layout()
    fig.savefig("arithmetic_mirror.png", dpi=130)
    print("wrote arithmetic_mirror.png")


if __name__ == "__main__":
    main()
