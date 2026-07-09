"""Visualization of the Boolean hypercube flip graph Q_4 and the four
generic-valid foldings of a degree-4 origami vertex.

Generates 'miura_flip_Q4.png': the 16 vertices of Q_4 placed on a circle, all
32 single-flip edges drawn, with the four nodes corresponding to the
generic-valid degree-4 MV assignments highlighted.

Run:  python visualize.py
"""

from __future__ import annotations

import math
from itertools import product
from typing import List, Tuple

import matplotlib.pyplot as plt

Assignment = Tuple[bool, ...]


def all_configs(d: int) -> List[Assignment]:
    return [tuple(bits) for bits in product([False, True], repeat=d)]


def hamming(a: Assignment, b: Assignment) -> int:
    return sum(1 for x, y in zip(a, b) if x != y)


def generic_valid(a: Assignment) -> bool:
    return (a[0] != a[1]) and (a[2] == a[3])


def label(a: Assignment) -> str:
    return "".join("1" if x else "0" for x in a)


def main() -> None:
    d = 4
    cfgs = all_configs(d)
    n = len(cfgs)

    # circular layout
    pos = {
        a: (math.cos(2 * math.pi * k / n), math.sin(2 * math.pi * k / n))
        for k, a in enumerate(cfgs)
    }

    fig, ax = plt.subplots(figsize=(9, 9))

    # edges (single flips)
    for i, a in enumerate(cfgs):
        for b in cfgs[i + 1:]:
            if hamming(a, b) == 1:
                xa, ya = pos[a]
                xb, yb = pos[b]
                ax.plot([xa, xb], [ya, yb], color="#b0c4de", lw=0.8, zorder=1)

    # nodes
    for a in cfgs:
        x, y = pos[a]
        if generic_valid(a):
            ax.scatter([x], [y], s=520, color="#e8551c", zorder=3,
                       edgecolors="black", linewidths=1.3)
            ax.text(x * 1.16, y * 1.16, label(a), ha="center", va="center",
                    fontsize=11, fontweight="bold", color="#e8551c")
        else:
            ax.scatter([x], [y], s=300, color="#4a78c2", zorder=2,
                       edgecolors="black", linewidths=0.7)
            ax.text(x * 1.16, y * 1.16, label(a), ha="center", va="center",
                    fontsize=9, color="#33415c")

    ax.set_title("Flip graph $Q_4$ (16 nodes, 32 edges, 4-regular)\n"
                 "highlighted: the 4 generic-valid degree-4 foldings",
                 fontsize=13)
    ax.set_aspect("equal")
    ax.axis("off")
    fig.tight_layout()
    fig.savefig("miura_flip_Q4.png", dpi=150)
    print("wrote miura_flip_Q4.png")


if __name__ == "__main__":
    main()
