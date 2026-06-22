"""Visualization: the de Bruijn graph B(4,2) and its Eulerian-circuit catalog.

Renders the 4-node de Bruijn graph (nodes 0..3, one directed edge per length-2
address) and overlays the catalog volume's Eulerian circuit, illustrating that
the single catalog word visits every address (edge) exactly once.
"""
from __future__ import annotations

import math
from typing import List, Tuple

import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch

CAT: Tuple[int, ...] = (0, 0, 1, 0, 2, 0, 3, 1, 1, 2, 1, 3, 2, 2, 3, 3)


def window(i: int) -> Tuple[int, int]:
    return (CAT[i % 16], CAT[(i + 1) % 16])


def node_pos(k: int) -> Tuple[float, float]:
    angle = math.pi / 2 - 2 * math.pi * k / 4
    return (math.cos(angle), math.sin(angle))


def main() -> None:
    fig, ax = plt.subplots(figsize=(8, 8))
    edges: List[Tuple[int, int]] = [window(i) for i in range(16)]

    for k in range(4):
        x, y = node_pos(k)
        ax.scatter([x], [y], s=1400, c="#1f3b73", zorder=3)
        ax.text(x, y, str(k), color="white", ha="center", va="center",
                fontsize=18, fontweight="bold", zorder=4)

    for step, (a, b) in enumerate(edges):
        xa, ya = node_pos(a)
        xb, yb = node_pos(b)
        color = plt.cm.viridis(step / 16)
        if a == b:  # self-loop
            ax.annotate("", xy=(xa * 1.18, ya * 1.18), xytext=(xa * 1.02, ya * 1.02),
                        arrowprops=dict(arrowstyle="->", color=color, lw=2,
                                        connectionstyle="arc3,rad=0.9"))
        else:
            arrow = FancyArrowPatch((xa, ya), (xb, yb), color=color, lw=2,
                                    arrowstyle="->", mutation_scale=18,
                                    connectionstyle="arc3,rad=0.18", zorder=2)
            ax.add_patch(arrow)

    ax.set_title("de Bruijn graph B(4,2): the catalog word walks every "
                 "address (edge) exactly once", fontsize=12)
    ax.set_xlim(-1.6, 1.6)
    ax.set_ylim(-1.6, 1.6)
    ax.axis("off")
    plt.tight_layout()
    plt.savefig("debruijn_catalog.png", dpi=150)
    print("saved debruijn_catalog.png")


if __name__ == "__main__":
    main()
