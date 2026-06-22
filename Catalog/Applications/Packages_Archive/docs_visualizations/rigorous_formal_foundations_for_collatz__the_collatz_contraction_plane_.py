"""
Visualization: the (j, m) contraction plane.

Plots every integer pair (j, m) and colours it by which test certifies contraction:
  - grey   : neither (3^j >= 2^m, segment grows)
  - blue   : sharp criterion only  (the band reclaimed beyond the naive 1/2)
  - green  : both naive and sharp
The exact break-even line m = (log3/log2) * j and the naive line m = 2j are overlaid,
making the reclaimed wedge between them visually explicit.
"""

from __future__ import annotations

import math
import matplotlib.pyplot as plt

LOG2: float = math.log(2.0)
LOG3: float = math.log(3.0)
SLOPE: float = LOG3 / LOG2  # ~1.585 : halvings per tripling at the exact margin


def main() -> None:
    J_MAX, M_MAX = 30, 60
    xs_grey, ys_grey = [], []
    xs_blue, ys_blue = [], []
    xs_green, ys_green = [], []
    for j in range(0, J_MAX + 1):
        for m in range(0, M_MAX + 1):
            sharp = j * LOG3 < m * LOG2
            naive = 2 * j < m
            if naive:
                xs_green.append(j); ys_green.append(m)
            elif sharp:
                xs_blue.append(j); ys_blue.append(m)
            else:
                xs_grey.append(j); ys_grey.append(m)

    plt.figure(figsize=(9, 7))
    plt.scatter(xs_grey, ys_grey, c="lightgrey", s=10, label="grows (3^j >= 2^m)")
    plt.scatter(xs_green, ys_green, c="seagreen", s=12, label="contracts (naive & sharp)")
    plt.scatter(xs_blue, ys_blue, c="royalblue", s=14,
                label="contracts (SHARP only — reclaimed band)")

    js = [0, J_MAX]
    plt.plot(js, [SLOPE * j for j in js], "r-", lw=2,
             label=f"exact break-even m = {SLOPE:.3f} j")
    plt.plot(js, [2 * j for j in js], "k--", lw=2, label="naive line m = 2j")

    plt.xlabel("j  (odd / tripling steps)")
    plt.ylabel("m  (even / halving steps)")
    plt.title("Collatz contraction plane: 3^j < 2^m and the reclaimed band")
    plt.legend(loc="upper left")
    plt.xlim(0, J_MAX); plt.ylim(0, M_MAX)
    plt.tight_layout()
    plt.savefig("contraction_plane.png", dpi=130)
    print("Wrote contraction_plane.png")


if __name__ == "__main__":
    main()
