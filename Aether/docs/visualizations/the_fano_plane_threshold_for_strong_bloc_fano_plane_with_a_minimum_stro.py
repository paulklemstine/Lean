"""
Visualization: the Fano plane PG(2,2) with a minimum strong blocking set highlighted.

Draws the seven points and seven lines (six straight segments plus one curved line)
of the Fano plane in the standard triangle-plus-incircle diagram, and highlights the
six-point strong blocking set univ \\ {0} (all points except the removed one), showing
that every line still contains at least two highlighted points.

Run with:  python _viz_fano.py   (saves fano_strong_blocking.png)
"""

from __future__ import annotations

from typing import Dict, List, Tuple

import matplotlib.pyplot as plt
import numpy as np

# Standard coordinates for the seven Fano points in the triangle diagram.
# We map the cyclic labels 0..6 onto a classic Fano drawing.
COORDS: Dict[int, Tuple[float, float]] = {
    0: (0.0, np.sqrt(3.0)),       # top vertex
    1: (-1.0, 0.0),               # bottom-left vertex
    2: (1.0, 0.0),                # bottom-right vertex
    3: (0.0, np.sqrt(3.0) / 3.0), # center
    4: (-0.5, np.sqrt(3.0) / 2),  # mid left edge
    5: (0.0, 0.0),                # mid bottom edge
    6: (0.5, np.sqrt(3.0) / 2),   # mid right edge
}


def fano_line(i: int) -> Tuple[int, int, int]:
    """The i-th line {i, i+1, i+3} (mod 7)."""
    return (i % 7, (i + 1) % 7, (i + 3) % 7)


def main() -> None:
    removed = 0
    blocking = [p for p in range(7) if p != removed]

    fig, ax = plt.subplots(figsize=(7, 7))
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_title("Fano plane PG(2,2): strong blocking set  univ \\ {0}", fontsize=13)

    # Draw the seven lines as light connections between their three points.
    for i in range(7):
        pts = fano_line(i)
        xs = [COORDS[p][0] for p in pts] + [COORDS[pts[0]][0]]
        ys = [COORDS[p][1] for p in pts] + [COORDS[pts[0]][1]]
        ax.plot(xs, ys, color="#b0b0b0", lw=1.2, zorder=1)

    # Draw points: blocking-set points filled, the removed point hollow/red.
    for p, (x, y) in COORDS.items():
        if p in blocking:
            ax.scatter([x], [y], s=320, color="#1f77b4", zorder=3, edgecolors="k")
            ax.text(x, y, str(p), color="white", ha="center", va="center",
                    fontsize=11, zorder=4, fontweight="bold")
        else:
            ax.scatter([x], [y], s=320, facecolors="none", edgecolors="#d62728",
                       linewidths=2.5, zorder=3)
            ax.text(x, y, str(p), color="#d62728", ha="center", va="center",
                    fontsize=11, zorder=4, fontweight="bold")

    ax.text(0.0, -0.45,
            "Blue = chosen (6 points).  Red hollow = removed point 0.\n"
            "Every line still contains >= 2 blue points  =>  strong blocking.",
            ha="center", va="center", fontsize=10)

    fig.tight_layout()
    fig.savefig("fano_strong_blocking.png", dpi=150)
    print("saved fano_strong_blocking.png")


if __name__ == "__main__":
    main()
