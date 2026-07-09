"""Visualization of incoherence indices of standard social decision frames.

Produces two panels:

  (1) The "clock walk": for the unit frame {1} on Z/nZ, the shortest balanced
      sequence is 1 repeated n times -- one full lap around the clock.  We draw
      the lap, showing why index({1}) == n.

  (2) The spectrum: the incoherence index of {1} on Z/nZ as a function of n
      (a straight line index == n, the realization theorem), with the saturated
      odd-frame index plotted for contrast (always 2 for even n).

Run: python visualization.py   (writes incoherence_index.png)
"""

from __future__ import annotations

from math import cos, pi, sin
from typing import List

import matplotlib.pyplot as plt


def clock_points(n: int) -> List[tuple[float, float]]:
    """Coordinates of the n clock positions of Z/nZ on the unit circle."""
    return [(cos(pi / 2 - 2 * pi * k / n), sin(pi / 2 - 2 * pi * k / n)) for k in range(n)]


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 6))

    # ---- Panel 1: the clock walk for {1} on Z/8Z ------------------------- #
    n = 8
    pts = clock_points(n)
    xs = [p[0] for p in pts] + [pts[0][0]]
    ys = [p[1] for p in pts] + [pts[0][1]]
    ax1.plot(xs, ys, color="#cccccc", lw=1, zorder=1)
    for k, (x, y) in enumerate(pts):
        ax1.scatter([x], [y], s=120, color="#2b6cb0", zorder=3)
        ax1.annotate(str(k), (x, y), textcoords="offset points", xytext=(0, 10),
                     ha="center", fontsize=11)
    # the lap 0 -> 1 -> ... -> 0, each step is the atom 1
    for k in range(n):
        x0, y0 = pts[k % n]
        x1, y1 = pts[(k + 1) % n]
        ax1.annotate("", xy=(x1, y1), xytext=(x0, y0),
                     arrowprops=dict(arrowstyle="->", color="#e53e3e", lw=2))
    ax1.set_title("Unit frame {1} on Z/8Z:\nshortest balanced run = 1 repeated 8 times "
                  "(index = 8)", fontsize=11)
    ax1.set_aspect("equal")
    ax1.axis("off")

    # ---- Panel 2: realized spectrum -------------------------------------- #
    ns = list(range(2, 21))
    idx_unit = ns  # index({1}) == n  (realization_even / sharpness)
    even_ns = [n for n in ns if n % 2 == 0]
    idx_odd_saturated = [2 for _ in even_ns]  # saturated odd frame index = 2

    ax2.plot(ns, idx_unit, "o-", color="#2b6cb0",
             label="index({1}) = n  (maximal, sparse)")
    ax2.plot(even_ns, idx_odd_saturated, "s--", color="#e53e3e",
             label="saturated odd frame index = 2  (maximal, crowded)")
    ax2.axhline(0, color="#aaaaaa", lw=0.5)
    ax2.set_xlabel("n  (number of social states)")
    ax2.set_ylabel("incoherence index")
    ax2.set_title("Realization & saturation contrast:\nmaximality does not pin the index",
                  fontsize=11)
    ax2.legend(loc="upper left", fontsize=9)
    ax2.grid(True, alpha=0.3)

    fig.suptitle("Incoherence Indices of Standard Social Decision Frames", fontsize=14)
    fig.tight_layout(rect=(0, 0, 1, 0.96))
    fig.savefig("incoherence_index.png", dpi=150)
    print("wrote incoherence_index.png")


if __name__ == "__main__":
    main()
