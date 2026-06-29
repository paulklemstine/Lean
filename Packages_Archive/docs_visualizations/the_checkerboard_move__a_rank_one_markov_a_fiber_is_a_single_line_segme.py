"""
Visualization: the rank-one fiber of the 2x2x2 no-three-way interaction model.

Plots the eight cell counts of the tables base + t*M3 as t varies over the
non-negative interval, showing that the fiber is a single line segment and that
even-parity cells rise while odd-parity cells fall in lock-step.
"""

from __future__ import annotations

from itertools import product
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt

Cell = Tuple[int, int, int]
CELLS: List[Cell] = list(product((0, 1), repeat=3))


def M3(i: int, j: int, k: int) -> int:
    return 1 if (i + j + k) % 2 == 0 else -1


def main() -> None:
    base: Dict[Cell, int] = {c: 4 for c in CELLS}
    ts = list(range(-4, 5))  # non-negative interval for base value 4
    fig, ax = plt.subplots(figsize=(9, 5.5))
    for c in CELLS:
        ys = [base[c] + t * M3(*c) for t in ts]
        parity = "even (+M3)" if M3(*c) == 1 else "odd (-M3)"
        style = "-o" if M3(*c) == 1 else "--s"
        ax.plot(ts, ys, style, label=f"cell {c}  [{parity}]")
    ax.axhline(0, color="black", linewidth=0.8)
    ax.set_xlabel("move multiplier  t   (table = base + t*M3)")
    ax.set_ylabel("cell count")
    ax.set_title("A 2x2x2 no-three-way fiber is a single line segment (rank-one move lattice)")
    ax.legend(fontsize=8, ncol=2)
    ax.grid(alpha=0.3)
    fig.tight_layout()
    fig.savefig("fiber_segment.png", dpi=150)
    print("wrote fiber_segment.png")


if __name__ == "__main__":
    main()
