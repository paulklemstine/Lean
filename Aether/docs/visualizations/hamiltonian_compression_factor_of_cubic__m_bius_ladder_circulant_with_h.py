"""
Visualization: draw the Mobius-ladder circulant ML(n) and highlight its
2-symmetric Hamiltonian cycle together with the half-turn automorphism.

The n vertices are placed on a circle. Rim edges (+/-1) form the outer cycle;
rung edges (n/2) cross the centre. The canonical Hamiltonian tour is drawn in
bold, and each vertex i is paired by an arrow to its half-turn image i + n/2,
illustrating the order-2 rotation that certifies kappa(ML(n)) >= 2.
"""

from __future__ import annotations

import math
from typing import List, Tuple

import matplotlib.pyplot as plt


def diam(n: int) -> int:
    return (n // 2) % n


def positions(n: int) -> List[Tuple[float, float]]:
    return [
        (math.cos(2 * math.pi * i / n), math.sin(2 * math.pi * i / n))
        for i in range(n)
    ]


def draw_mobius_ladder(n: int = 12) -> None:
    pos = positions(n)
    fig, ax = plt.subplots(figsize=(7, 7))

    # rim edges (Hamiltonian cycle, bold)
    for i in range(n):
        x0, y0 = pos[i]
        x1, y1 = pos[(i + 1) % n]
        ax.plot([x0, x1], [y0, y1], color="#1f77b4", lw=3, zorder=1)

    # rung edges (diameters)
    d = diam(n)
    for i in range(n):
        j = (i + d) % n
        if i < j:
            x0, y0 = pos[i]
            x1, y1 = pos[j]
            ax.plot([x0, x1], [y0, y1], color="#d62728",
                    lw=1.2, ls="--", alpha=0.7, zorder=0)

    # half-turn arrows (i -> i + n/2) for the first half
    for i in range(n // 2):
        j = (i + d) % n
        x0, y0 = pos[i]
        x1, y1 = pos[j]
        ax.annotate("", xy=(x1 * 0.85, y1 * 0.85), xytext=(x0 * 0.85, y0 * 0.85),
                    arrowprops=dict(arrowstyle="->", color="#2ca02c", alpha=0.5))

    for i, (x, y) in enumerate(pos):
        ax.scatter([x], [y], s=320, color="white", edgecolors="black", zorder=2)
        ax.text(x, y, str(i), ha="center", va="center", zorder=3, fontsize=10)

    ax.set_title(f"ML({n}): bold = Hamiltonian cycle, dashed = rungs (n/2),\n"
                 f"green arrows = half-turn automorphism (rotation by {d})")
    ax.set_aspect("equal")
    ax.axis("off")
    plt.tight_layout()
    plt.savefig("mobius_ladder.png", dpi=150)
    print("saved mobius_ladder.png")


if __name__ == "__main__":
    draw_mobius_ladder(12)
