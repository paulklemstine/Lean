"""
Visualization: the pentagon colouring of K5 and its triangle-free complement.

Draws the five vertices on a regular pentagon.  RED edges (the 5-cycle C5,
the verified `pentagon`) are solid; BLUE edges (the complement, again a
5-cycle / pentagram) are dashed.  Neither colour class contains a triangle,
which is exactly the content of `pentagon_no_triangle` and
`pentagon_compl_no_triangle`, witnessing R(3,3) > 5.

Run:  python _viz.py   (writes pentagon_ramsey.png)
"""

from __future__ import annotations

from itertools import combinations
from math import cos, pi, sin
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt


def vertex_positions(n: int = 5) -> Dict[int, Tuple[float, float]]:
    return {i: (cos(pi / 2 + 2 * pi * i / n), sin(pi / 2 + 2 * pi * i / n)) for i in range(n)}


def pentagon_red_edges() -> List[Tuple[int, int]]:
    return [(min(i, (i + 1) % 5), max(i, (i + 1) % 5)) for i in range(5)]


def main() -> None:
    pos = vertex_positions(5)
    red = set(pentagon_red_edges())
    all_edges = list(combinations(range(5), 2))

    fig, ax = plt.subplots(figsize=(6, 6))
    for (a, b) in all_edges:
        xa, ya = pos[a]
        xb, yb = pos[b]
        if (a, b) in red:
            ax.plot([xa, xb], [ya, yb], color="crimson", lw=3, solid_capstyle="round")
        else:
            ax.plot([xa, xb], [ya, yb], color="royalblue", lw=2, ls="--")

    for i, (x, y) in pos.items():
        ax.scatter([x], [y], s=600, color="white", edgecolors="black", zorder=3)
        ax.text(x, y, str(i), ha="center", va="center", fontsize=14, zorder=4)

    ax.set_title("Pentagon colouring of $K_5$: no monochromatic triangle\n"
                 "(red = $C_5$, blue = complement) $\\Rightarrow R(3,3) > 5$")
    ax.set_aspect("equal")
    ax.axis("off")
    fig.tight_layout()
    fig.savefig("pentagon_ramsey.png", dpi=150)
    print("Wrote pentagon_ramsey.png")


if __name__ == "__main__":
    main()
