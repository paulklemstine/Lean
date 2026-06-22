"""
Visualization: Hodge diamonds and the mirror reflection.

Renders, side by side, the Hodge diamond of a Calabi-Yau threefold (the quintic)
and its mirror, highlighting the (p,q) -> (n-p,q) reflection that exchanges
h^{1,1} and h^{2,1}, and annotates the Euler-characteristic sign flip.

Standard library + matplotlib only.
"""
from __future__ import annotations

from typing import Dict, Tuple

import matplotlib.pyplot as plt


def diamond_dict(n: int, h: Dict[Tuple[int, int], int]) -> Dict[Tuple[int, int], int]:
    return {(p, q): h.get((p, q), 0) for p in range(n + 1) for q in range(n + 1)}


def mirror(n: int, h: Dict[Tuple[int, int], int]) -> Dict[Tuple[int, int], int]:
    return {(p, q): h.get((n - p, q), 0) for p in range(n + 1) for q in range(n + 1)}


def euler(n: int, h: Dict[Tuple[int, int], int]) -> int:
    return sum((-1) ** (p + q) * h.get((p, q), 0)
               for p in range(n + 1) for q in range(n + 1))


def draw(ax, n: int, h: Dict[Tuple[int, int], int], title: str) -> None:
    # Place (p,q) in "diamond" coordinates: x = q - p, y = -(p + q).
    for (p, q), val in h.items():
        if val == 0 and not (0 <= p <= n and 0 <= q <= n):
            continue
        x = q - p
        y = -(p + q)
        color = "#d62728" if (p, q) in {(1, 1), (2, 1)} else "#1f77b4"
        ax.scatter([x], [y], s=900, c=color, alpha=0.25, zorder=1)
        ax.text(x, y, str(val), ha="center", va="center",
                fontsize=12, fontweight="bold", zorder=2)
    ax.set_title(f"{title}\n$\\chi = {euler(n, h)}$", fontsize=13)
    ax.set_aspect("equal")
    ax.axis("off")


def main() -> None:
    n = 3
    quintic = diamond_dict(n, {
        (0, 0): 1, (3, 3): 1, (3, 0): 1, (0, 3): 1,
        (1, 1): 1, (2, 2): 1, (2, 1): 101, (1, 2): 101,
    })
    mq = mirror(n, quintic)

    fig, axes = plt.subplots(1, 2, figsize=(11, 6))
    draw(axes[0], n, quintic, "Quintic threefold")
    draw(axes[1], n, mq, "Mirror quintic")
    fig.suptitle(
        "Mirror reflection $(p,q)\\mapsto(n-p,q)$: "
        "$h^{1,1}\\leftrightarrow h^{2,1}$ and $\\chi\\mapsto(-1)^n\\chi$",
        fontsize=14)
    fig.tight_layout()
    fig.savefig("hodge_mirror.png", dpi=150)
    print("wrote hodge_mirror.png")


if __name__ == "__main__":
    main()
