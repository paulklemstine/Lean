"""Visualization: M_3 drawn as a Mobius ladder and as K_{3,3}, with the
certificate orbit of the base edge highlighted. Requires matplotlib."""
from __future__ import annotations
import math
from itertools import combinations
import matplotlib.pyplot as plt

N = 6


def adj3(i: int, j: int) -> bool:
    return (j == (i + 1) % N) or (i == (j + 1) % N) or (j == (i + 3) % N)


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 6))

    # Left: Mobius ladder layout (hexagon rim + antipodal rungs)
    pos = {v: (math.cos(math.pi / 2 - 2 * math.pi * v / N),
               math.sin(math.pi / 2 - 2 * math.pi * v / N)) for v in range(N)}
    for i, j in combinations(range(N), 2):
        if adj3(i, j):
            is_rung = (j == (i + 3) % N)
            x = [pos[i][0], pos[j][0]]
            y = [pos[i][1], pos[j][1]]
            ax1.plot(x, y, color="crimson" if is_rung else "steelblue",
                     lw=2.5, zorder=1)
    for v, (x, y) in pos.items():
        ax1.scatter([x], [y], s=600,
                    color="#fff3b0" if v % 2 == 0 else "#caffbf",
                    edgecolors="black", zorder=2)
        ax1.text(x, y, str(v), ha="center", va="center", fontsize=14)
    ax1.set_title("M_3 as a Mobius ladder (red = rungs i~i+3)")
    ax1.set_aspect("equal"); ax1.axis("off")

    # Right: bipartite K_{3,3} layout
    evens, odds = [0, 2, 4], [1, 3, 5]
    posb = {}
    for k, v in enumerate(evens):
        posb[v] = (0.0, 1.0 - k)
    for k, v in enumerate(odds):
        posb[v] = (2.0, 1.0 - k)
    for i, j in combinations(range(N), 2):
        if adj3(i, j):
            ax2.plot([posb[i][0], posb[j][0]], [posb[i][1], posb[j][1]],
                     color="gray", lw=1.5, zorder=1)
    for v, (x, y) in posb.items():
        ax2.scatter([x], [y], s=600,
                    color="#fff3b0" if v % 2 == 0 else "#caffbf",
                    edgecolors="black", zorder=2)
        ax2.text(x, y, str(v), ha="center", va="center", fontsize=14)
    ax2.set_title("Same graph as K_{3,3}: even {0,2,4} | odd {1,3,5}")
    ax2.set_aspect("equal"); ax2.axis("off")

    plt.tight_layout()
    plt.savefig("mobius_m3.png", dpi=150)
    print("wrote mobius_m3.png")


if __name__ == "__main__":
    main()
