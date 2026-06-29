"""Visualization: Hodge diamonds and the mirror reflection.

Renders the Hodge diamond of the quintic Calabi-Yau threefold and its mirror
side by side, with arrows indicating the mirror involution (p,q) -> (n-p, q),
and annotates each with its Euler characteristic to show the (-1)^n sign flip.
Requires matplotlib.
"""
from __future__ import annotations
import matplotlib.pyplot as plt
from typing import Dict, Tuple


def diamond_table(table: Dict[Tuple[int, int], int], n: int) -> Dict[Tuple[int, int], int]:
    return {(p, q): table.get((p, q), 0) for p in range(n + 1) for q in range(n + 1)}


def euler_char(tbl: Dict[Tuple[int, int], int], n: int) -> int:
    return sum((-1) ** (p + q) * tbl[(p, q)] for p in range(n + 1) for q in range(n + 1))


def draw(ax, tbl: Dict[Tuple[int, int], int], n: int, title: str) -> None:
    for (p, q), val in tbl.items():
        # rotate grid 45 degrees: x = p - q, y = -(p + q)
        x, y = p - q, -(p + q)
        color = "#1f77b4" if val else "#dddddd"
        ax.scatter([x], [y], s=900, c=color, edgecolors="black", zorder=2)
        ax.text(x, y, str(val), ha="center", va="center",
                color="white" if val else "#888888", fontsize=11, zorder=3)
    ax.set_title(f"{title}\\nchi = {euler_char(tbl, n)}", fontsize=12)
    ax.set_aspect("equal")
    ax.axis("off")


def main() -> None:
    n = 3
    quintic = diamond_table({(0, 0): 1, (3, 3): 1, (3, 0): 1, (0, 3): 1,
                             (1, 1): 1, (2, 2): 1, (2, 1): 101, (1, 2): 101}, n)
    mirror = {(p, q): quintic[(n - p, q)] for p in range(n + 1) for q in range(n + 1)}

    fig, axes = plt.subplots(1, 2, figsize=(11, 6))
    draw(axes[0], quintic, n, "Quintic Calabi-Yau 3-fold")
    draw(axes[1], mirror, n, "Mirror quintic  (p,q) -> (n-p, q)")
    fig.suptitle("Mirror symmetry on the Hodge diamond: chi(mirror) = (-1)^n chi",
                 fontsize=14)
    plt.tight_layout()
    plt.savefig("hodge_mirror.png", dpi=150)
    print("wrote hodge_mirror.png")


if __name__ == "__main__":
    main()
