"""Visualization: the slowness gap and the convexity that creates it.

Generates a two-panel figure:
  (left)  the convex stopwatch function phi(t) = 1/(1-t) with the order-three
          collinear/generic split for q=2, showing the Jensen surplus;
  (right) the order-three slowness surplus as a function of the plane order q.

Saves 'slowness_visualization.png'.
"""

from __future__ import annotations

from fractions import Fraction
from math import comb
from typing import List

import matplotlib.pyplot as plt
import numpy as np


def order_three_surplus(q: int) -> float:
    n = q * q + q + 1
    p_coll = Fraction(q * q - 2 * q, n)
    p_gen = Fraction((q - 1) ** 2, n)
    p_u = Fraction(comb(n - 3, q + 1), comb(n, q + 1))
    n_coll = n * comb(q + 1, 3)
    n_gen = comb(n, 3) - n_coll
    plane = n_coll / (1 - p_coll) + n_gen / (1 - p_gen)
    unif = Fraction(comb(n, 3)) / (1 - p_u)
    return float(plane - unif)


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Panel 1: convexity / Jensen at q = 2 triples.
    t = np.linspace(0.0, 0.45, 400)
    ax1.plot(t, 1.0 / (1.0 - t), color="#1f77b4", lw=2, label=r"$\phi(t)=1/(1-t)$")
    p_coll, p_gen, p_mean = 0.0, 1.0 / 7.0, 4.0 / 35.0  # q=2 triple values
    yc, yg = 1.0 / (1.0 - p_coll), 1.0 / (1.0 - p_gen)
    ax1.plot([p_coll, p_gen], [yc, yg], "o--", color="#d62728",
             label="chord (collinear, generic)")
    ax1.plot(p_mean, 1.0 / (1.0 - p_mean), "s", color="green", ms=9,
             label=r"uniform mean $\bar p$")
    ax1.plot(p_mean, (yc + yg) / 2.0, "^", color="purple", ms=9,
             label="plane average (above)")
    ax1.set_title("Convexity creates the order-3 surplus (q = 2)")
    ax1.set_xlabel("avoid-probability $t$")
    ax1.set_ylabel(r"$1/(1-t)$")
    ax1.legend(fontsize=9)
    ax1.grid(alpha=0.3)

    # Panel 2: order-3 surplus vs q.
    qs: List[int] = [2, 3, 4, 5, 7, 8, 9, 11, 13]
    surplus = [order_three_surplus(q) for q in qs]
    ax2.bar([str(q) for q in qs], surplus, color="#ff7f0e")
    ax2.set_title("Order-3 slowness surplus is positive for all q")
    ax2.set_xlabel("projective plane order $q$")
    ax2.set_ylabel("order-3 surplus")
    ax2.grid(alpha=0.3, axis="y")

    fig.tight_layout()
    fig.savefig("slowness_visualization.png", dpi=150)
    print("saved slowness_visualization.png")


if __name__ == "__main__":
    main()
