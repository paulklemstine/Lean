"""Visualize the Fano plane and a minimum strong blocking set (omit-one).

Draws the 7 points and 7 lines (6 straight lines + 1 inscribed circle) of
PG(2,2). The kept points of the strong blocking set S = P \ {p} are filled;
the single omitted point is hollow, illustrating that every line still keeps
at least two filled points.
"""
from __future__ import annotations
from typing import Dict, List, Tuple
import matplotlib.pyplot as plt
import numpy as np

# Coordinates for the classic Fano drawing (triangle + midpoints + center).
COORDS: Dict[int, Tuple[float, float]] = {
    0: (0.0, 0.0), 1: (2.0, 0.0), 2: (1.0, np.sqrt(3.0)),   # outer triangle
    3: (1.0, 0.0),                                          # midpoint 0-1
    4: (1.5, np.sqrt(3.0) / 2), 5: (0.5, np.sqrt(3.0) / 2),  # other midpoints
    6: (1.0, np.sqrt(3.0) / 3),                             # centroid
}
STRAIGHT_LINES: List[Tuple[int, int, int]] = [
    (0, 3, 1), (1, 4, 2), (2, 5, 0), (0, 6, 4), (1, 6, 5), (2, 6, 3),
]
CIRCLE_LINE = (3, 4, 5)  # the inscribed circle through the three midpoints


def draw(omit: int = 0) -> None:
    kept = [p for p in range(7) if p != omit]
    fig, ax = plt.subplots(figsize=(6, 6))
    for a, _, c in STRAIGHT_LINES:
        xa, ya = COORDS[a]; xc, yc = COORDS[c]
        ax.plot([xa, xc], [ya, yc], color="#888", lw=1.5, zorder=1)
    cx, cy = COORDS[6]
    r = np.hypot(*(np.array(COORDS[3]) - np.array((cx, cy))))
    ax.add_patch(plt.Circle((cx, cy), r, fill=False, color="#888", lw=1.5))
    for p, (x, y) in COORDS.items():
        filled = p in kept
        ax.scatter([x], [y], s=420,
                   facecolors=("#2b6cb0" if filled else "white"),
                   edgecolors="#1a365d", linewidths=2, zorder=3)
        ax.text(x, y, str(p), ha="center", va="center", zorder=4,
                color=("white" if filled else "#1a365d"), fontweight="bold")
    ax.set_title(f"Fano plane: strong blocking set omitting point {omit}")
    ax.set_aspect("equal"); ax.axis("off")
    plt.tight_layout(); plt.savefig("fano_strong_blocking.png", dpi=150)
    print("wrote fano_strong_blocking.png")


if __name__ == "__main__":
    draw(omit=0)
