"""Visualizations for the no-three-way interaction Markov basis.

Generates two figures:

  1. ``m3_cube.png``      -- the 2x2x2 cube with corners coloured by the sign of
                             the alternating move M3 (a 3-D checkerboard).
  2. ``fiber_line.png``   -- a fiber drawn as an integer interval along the move
                             line, with each cell's value shown as an affine ramp,
                             illustrating discrete convexity.

Run:  ``python visualize.py``  (requires matplotlib).
"""

from __future__ import annotations

from itertools import product
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D  # noqa: F401  (registers 3d projection)

Cell = Tuple[int, int, int]
CELLS: List[Cell] = list(product((0, 1), repeat=3))


def m3(i: int, j: int, k: int) -> int:
    return 1 if (i + j + k) % 2 == 0 else -1


def plot_cube(path: str = "m3_cube.png") -> None:
    fig = plt.figure(figsize=(6, 6))
    ax = fig.add_subplot(111, projection="3d")
    for (i, j, k) in CELLS:
        sign = m3(i, j, k)
        color = "#d7263d" if sign > 0 else "#1b6ca8"
        ax.scatter(i, j, k, s=600, c=color, edgecolors="black", depthshade=False)
        ax.text(i, j, k, f"  {sign:+d}", fontsize=12, weight="bold")
    # cube edges
    for a in CELLS:
        for b in CELLS:
            if sum(abs(x - y) for x, y in zip(a, b)) == 1:
                ax.plot(*zip(a, b), color="gray", linewidth=0.6, alpha=0.5)
    ax.set_title("M3(i,j,k) = (-1)^(i+j+k):  a 3-D checkerboard move")
    ax.set_xlabel("i")
    ax.set_ylabel("j")
    ax.set_zlabel("k")
    ax.set_xticks([0, 1])
    ax.set_yticks([0, 1])
    ax.set_zticks([0, 1])
    fig.tight_layout()
    fig.savefig(path, dpi=130)
    print(f"wrote {path}")


def plot_fiber_line(path: str = "fiber_line.png") -> None:
    # base table at offset t=0; each cell value is base + t * M3(cell)
    base: Dict[Cell, int] = {
        (0, 0, 0): 0, (0, 0, 1): 4, (0, 1, 0): 4, (0, 1, 1): 0,
        (1, 0, 0): 4, (1, 0, 1): 0, (1, 1, 0): 0, (1, 1, 1): 4,
    }
    ts = list(range(-2, 7))
    fig, ax = plt.subplots(figsize=(8, 5))
    for cell in CELLS:
        ys = [base[cell] + t * m3(*cell) for t in ts]
        ax.plot(ts, ys, marker="o", label=f"cell {cell}")
    ax.axhline(0, color="black", linewidth=1)
    feasible = [t for t in ts if all(base[c] + t * m3(*c) >= 0 for c in CELLS)]
    ax.axvspan(min(feasible) - 0.4, max(feasible) + 0.4, color="green", alpha=0.12,
               label="feasible fiber (non-negative)")
    ax.set_title("A fiber is an integer interval along the move line")
    ax.set_xlabel("offset t   (table = base + t * M3)")
    ax.set_ylabel("cell value")
    ax.legend(fontsize=8, ncol=2, loc="upper left")
    fig.tight_layout()
    fig.savefig(path, dpi=130)
    print(f"wrote {path}")


def main() -> None:
    plot_cube()
    plot_fiber_line()


if __name__ == "__main__":
    main()
