"""
Visualization: a Sperner-colored subdivision of the 2-simplex, with the
guaranteed rainbow (fully colored) triangle highlighted.

The triangle is the standard 2-simplex with corners colored 0 (red), 1 (green),
2 (blue).  Interior lattice vertices are colored by a proper rule; Sperner's
lemma guarantees at least one small triangle whose three corners show all three
colors.  That cell is outlined in black.

Run:  python visualize_sperner.py   (writes sperner_simplex.png)
"""

from __future__ import annotations

from itertools import product
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt

Lattice = Tuple[int, int, int]
COLORS = ["#e6194B", "#3cb44b", "#4363d8"]  # red, green, blue


def lattice_points(m: int) -> List[Lattice]:
    return [(a, b, m - a - b) for a in range(m + 1) for b in range(m + 1 - a)]


def bary_to_xy(k: Lattice, m: int) -> Tuple[float, float]:
    """Map barycentric (k0,k1,k2)/m to 2D plane coordinates."""
    corners = [(0.0, 0.0), (1.0, 0.0), (0.5, 0.866)]
    x = sum(corners[i][0] * k[i] / m for i in range(3))
    y = sum(corners[i][1] * k[i] / m for i in range(3))
    return x, y


def upward_cells(m: int) -> List[Tuple[Lattice, Lattice, Lattice]]:
    cells = []
    for a in range(m + 1):
        for b in range(m + 1 - a):
            c = m - a - b
            if c >= 1:
                cells.append(((a + 1, b, c - 1), (a, b + 1, c - 1), (a, b, c)))
    return cells


def main(m: int = 8) -> None:
    pts = lattice_points(m)
    coloring: Dict[Lattice, int] = {
        k: max(i for i in range(3) if k[i] != 0) for k in pts
    }
    cells = upward_cells(m)
    rainbow = [c for c in cells if {coloring[v] for v in c} == {0, 1, 2}]

    fig, ax = plt.subplots(figsize=(7, 6.5))
    # draw subdivision edges faintly
    for cell in cells:
        xy = [bary_to_xy(v, m) for v in cell] + [bary_to_xy(cell[0], m)]
        ax.plot([p[0] for p in xy], [p[1] for p in xy], color="0.85", lw=0.6, zorder=1)
    # draw colored vertices
    for k in pts:
        x, y = bary_to_xy(k, m)
        ax.scatter([x], [y], color=COLORS[coloring[k]], s=70, zorder=3,
                   edgecolors="k", linewidths=0.4)
    # highlight rainbow cells
    for cell in rainbow:
        xy = [bary_to_xy(v, m) for v in cell] + [bary_to_xy(cell[0], m)]
        ax.plot([p[0] for p in xy], [p[1] for p in xy], color="k", lw=2.5, zorder=4)
        cx = sum(bary_to_xy(v, m)[0] for v in cell) / 3
        cy = sum(bary_to_xy(v, m)[1] for v in cell) / 3
        ax.annotate("rainbow", (cx, cy), fontsize=9, ha="center",
                    fontweight="bold", zorder=5)

    ax.set_title(f"Sperner coloring of the 2-simplex (m={m}): "
                 f"{len(rainbow)} rainbow cell(s)")
    ax.set_aspect("equal")
    ax.axis("off")
    fig.tight_layout()
    fig.savefig("sperner_simplex.png", dpi=150)
    print("wrote sperner_simplex.png")


if __name__ == "__main__":
    main()
