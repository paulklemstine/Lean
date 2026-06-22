"""
Visualization: the self-complementary pentagon witnessing R(3,3) > 5.

Draws K_5 with the pentagon (5-cycle) edges in red and the complementary
"pentagram" edges in blue, side by side, illustrating that neither colour
class contains a triangle. Saves `pentagon_R33.png`.
"""

from __future__ import annotations

from itertools import combinations
from math import cos, pi, sin
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt


def pentagon_positions(n: int = 5) -> Dict[int, Tuple[float, float]]:
    """Vertex coordinates on a regular n-gon (vertex 0 at the top)."""
    return {
        i: (sin(2 * pi * i / n), cos(2 * pi * i / n))
        for i in range(n)
    }


def red_edges(n: int = 5) -> List[Tuple[int, int]]:
    """Red = the n-cycle 0-1-...-(n-1)-0."""
    return [(i, (i + 1) % n) for i in range(n)]


def main() -> None:
    n = 5
    pos = pentagon_positions(n)
    reds = {frozenset(e) for e in red_edges(n)}
    fig, axes = plt.subplots(1, 2, figsize=(10, 5))

    for ax, show_red, title, col in (
        (axes[0], True, "Red edges: pentagon $C_5$ (no red triangle)", "crimson"),
        (axes[1], False, "Blue edges: pentagram $C_5^c$ (no blue triangle)", "royalblue"),
    ):
        for u, v in combinations(range(n), 2):
            e = frozenset((u, v))
            if (e in reds) == show_red:
                (x0, y0), (x1, y1) = pos[u], pos[v]
                ax.plot([x0, x1], [y0, y1], color=col, lw=2.2, zorder=1)
        for i, (x, y) in pos.items():
            ax.scatter([x], [y], s=420, color="white", edgecolors="black",
                       zorder=2)
            ax.text(x, y, str(i), ha="center", va="center", zorder=3,
                    fontsize=12, fontweight="bold")
        ax.set_title(title, fontsize=11)
        ax.set_aspect("equal")
        ax.axis("off")

    fig.suptitle("R(3,3) = 6: the pentagon colouring of $K_5$ escapes both colours",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("pentagon_R33.png", dpi=150)
    print("saved pentagon_R33.png")


if __name__ == "__main__":
    main()
