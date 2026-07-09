"""Visualization: draw the first few levels of a generating tree.

Renders nodes level by level with edges from parents to children, annotating
each node with its label, to make the recursive succession rule tangible.
"""

from __future__ import annotations

from typing import Callable
import matplotlib.pyplot as plt


def succ(a: int) -> list[int]:
    return list(range(2, a + 2))


def build_levels(root: int, depth: int) -> list[list[int]]:
    levels = [[root]]
    for _ in range(depth):
        nxt: list[int] = []
        for a in levels[-1]:
            nxt.extend(succ(a))
        levels.append(nxt)
    return levels


def main() -> None:
    depth = 4
    levels = build_levels(1, depth)
    fig, ax = plt.subplots(figsize=(11, 6))

    positions: list[list[tuple[float, float]]] = []
    for d, level in enumerate(levels):
        n = len(level)
        xs = [(i - (n - 1) / 2) for i in range(n)]
        positions.append([(x, -d) for x in xs])

    # edges
    for d in range(depth):
        child_idx = 0
        for pi, a in enumerate(levels[d]):
            for _ in succ(a):
                x0, y0 = positions[d][pi]
                x1, y1 = positions[d + 1][child_idx]
                ax.plot([x0, x1], [y0, y1], color="gray", alpha=0.4, zorder=1)
                child_idx += 1

    # nodes
    for d, level in enumerate(levels):
        for (x, y), lbl in zip(positions[d], level):
            ax.scatter([x], [y], s=260, color="#1f77b4", zorder=2)
            ax.text(x, y, str(lbl), color="white", ha="center", va="center",
                    fontsize=8, zorder=3)

    ax.set_title("Generating tree with succ(a) = [2, ..., a+1]")
    ax.axis("off")
    fig.tight_layout()
    fig.savefig("tree.png", dpi=150)
    print("wrote tree.png; level sizes:", [len(l) for l in levels])


if __name__ == "__main__":
    main()
