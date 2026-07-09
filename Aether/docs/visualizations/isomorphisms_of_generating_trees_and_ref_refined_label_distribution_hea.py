"""Visualization: refined statistic distribution across levels as a heatmap.

For the Catalan generating tree, the label of a node is a positive integer.
We plot, as a heatmap, the number of depth-k nodes carrying each label value,
illustrating the refined statistic that an isomorphism transports intact.
"""

from __future__ import annotations

from typing import Callable
from collections import Counter
import numpy as np
import matplotlib.pyplot as plt


def level_labels(succ: Callable[[int], list[int]], root: int, k: int) -> list[int]:
    level = [root]
    for _ in range(k):
        nxt: list[int] = []
        for a in level:
            nxt.extend(succ(a))
        level = nxt
    return level


def succ(a: int) -> list[int]:
    return list(range(2, a + 2))


def main() -> None:
    max_depth = 8
    max_label = 9
    grid = np.zeros((max_label, max_depth + 1), dtype=float)
    for k in range(max_depth + 1):
        dist = Counter(level_labels(succ, 1, k))
        for lbl, cnt in dist.items():
            if lbl <= max_label:
                grid[lbl - 1, k] = cnt

    fig, ax = plt.subplots(figsize=(8, 5))
    im = ax.imshow(grid, aspect="auto", origin="lower", cmap="viridis")
    ax.set_xlabel("depth k")
    ax.set_ylabel("label value")
    ax.set_yticks(range(max_label))
    ax.set_yticklabels(range(1, max_label + 1))
    ax.set_title("Refined label distribution of the Catalan tree")
    fig.colorbar(im, ax=ax, label="number of nodes")
    fig.tight_layout()
    fig.savefig("distribution.png", dpi=150)
    print("wrote distribution.png")


if __name__ == "__main__":
    main()
