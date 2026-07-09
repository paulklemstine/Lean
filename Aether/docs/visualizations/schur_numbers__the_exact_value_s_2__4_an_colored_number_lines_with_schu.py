"""
Visualization: the extremal Schur colorings as colored number lines.

Renders {1..4} (two colors) and {1..13} (three colors) with their color
classes, and overlays every in-range Schur triple x+y=z, highlighting that
none is monochromatic.  Saves PNGs with matplotlib.

Run:  python visualization.py
"""

from __future__ import annotations

from typing import Callable, Dict, List, Tuple

import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle


def witness_two(k: int) -> int:
    return 1 if k in (2, 3) else 0


def witness_three(k: int) -> int:
    if k in (1, 4, 10, 13):
        return 0
    if k in (2, 3, 11, 12):
        return 1
    return 2


def schur_triples(n: int) -> List[Tuple[int, int, int]]:
    out: List[Tuple[int, int, int]] = []
    for x in range(1, n + 1):
        for y in range(x, n + 1):
            z = x + y
            if z <= n:
                out.append((x, y, z))
    return out


def render(n: int, color: Callable[[int], int], palette: List[str],
           title: str, fname: str) -> None:
    fig, ax = plt.subplots(figsize=(max(6, n * 0.9), 3.2))
    for k in range(1, n + 1):
        ax.add_patch(Rectangle((k - 0.45, -0.45), 0.9, 0.9,
                               facecolor=palette[color(k)],
                               edgecolor="black", lw=1.2))
        ax.text(k, 0, str(k), ha="center", va="center",
                fontsize=12, fontweight="bold", color="white")

    # arc each Schur triple; color the arc red if monochromatic
    for i, (x, y, z) in enumerate(schur_triples(n)):
        mono = color(x) == color(y) == color(z)
        h = 0.7 + 0.18 * (i % 4)
        ax.plot([x, z], [0.5, 0.5 + h], lw=0.8, alpha=0.0)  # spacing
        ax.annotate("", xy=(z, 0.5), xytext=(x, 0.5),
                    arrowprops=dict(arrowstyle="-", lw=1.4 if mono else 0.6,
                                    color="red" if mono else "gray",
                                    alpha=0.9 if mono else 0.35,
                                    connectionstyle=f"arc3,rad={0.25 + 0.05*(i%5)}"))
    ax.set_xlim(0.2, n + 0.8)
    ax.set_ylim(-0.8, 1.8)
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_title(title, fontsize=13)
    fig.tight_layout()
    fig.savefig(fname, dpi=140)
    print("saved", fname)


def main() -> None:
    render(4, witness_two, ["#2c7fb8", "#d95f0e"],
           "S(2) = 4:  {1,4} | {2,3}  (no monochromatic x+y=z)",
           "schur_two.png")
    render(13, witness_three, ["#2c7fb8", "#d95f0e", "#31a354"],
           "S(3) >= 13:  {1,4,10,13} | {2,3,11,12} | {5..9}",
           "schur_three.png")


if __name__ == "__main__":
    main()
