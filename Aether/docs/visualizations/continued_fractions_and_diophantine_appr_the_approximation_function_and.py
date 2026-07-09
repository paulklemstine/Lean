"""Visualization: the approximation function q -> q*||q x|| and the Lagrange
constant floor, contrasting a quadratic irrational, pi, and a Liouville number.

Generates a figure with two panels:
  (left)  scatter of q*||q x|| for q = 1..Q, with the universal bound y = 1
          and the Hurwitz floor y = 1/sqrt(5) drawn for reference;
  (right) the running minimum (empirical Lc) vs q on a log-x axis, showing the
          golden ratio leveling at 1/sqrt(5) while a Liouville-like number dives.

Requires matplotlib and numpy.
"""

from __future__ import annotations

import math
from typing import Callable

import numpy as np
import matplotlib.pyplot as plt


def nearest_int_distance(y: float) -> float:
    """||y|| = distance from y to the nearest integer."""
    return abs(y - round(y))


def approx(x: float, q: int) -> float:
    """approx(x, q) = q * ||q x||."""
    return q * nearest_int_distance(q * x)


def running_min(x: float, q_max: int) -> np.ndarray:
    """Vector of running minima of approx(x, .) up to each q."""
    vals = np.array([approx(x, q) for q in range(1, q_max + 1)])
    return np.minimum.accumulate(vals)


def main() -> None:
    q_max = 3000
    phi = (1 + math.sqrt(5)) / 2
    numbers: dict[str, float] = {
        "golden ratio phi": phi,
        "sqrt(2)": math.sqrt(2),
        "pi": math.pi,
    }

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    qs = np.arange(1, q_max + 1)
    for name, x in numbers.items():
        ax1.scatter(qs, [approx(x, q) for q in qs], s=4, alpha=0.4, label=name)
    ax1.axhline(1.0, color="black", ls="--", lw=1, label="universal bound 1")
    ax1.axhline(1 / math.sqrt(5), color="red", ls=":", lw=1.5,
                label="Hurwitz floor 1/sqrt5")
    ax1.set_xlabel("denominator q")
    ax1.set_ylabel("q * ||q x||")
    ax1.set_title("Approximation function (every value <= 1 universally)")
    ax1.set_ylim(0, 1.2)
    ax1.legend(loc="upper right", fontsize=8)

    for name, x in numbers.items():
        ax2.plot(qs, running_min(x, q_max), label=name)
    ax2.axhline(1 / math.sqrt(5), color="red", ls=":", lw=1.5,
                label="1/sqrt5")
    ax2.set_xscale("log")
    ax2.set_xlabel("denominator q (log scale)")
    ax2.set_ylabel("running min  (empirical Lc)")
    ax2.set_title("Empirical Lagrange constant: phi levels off, others dip lower")
    ax2.legend(loc="upper right", fontsize=8)

    fig.suptitle("Diophantine approximation and the Lagrange constant")
    fig.tight_layout()
    fig.savefig("lagrange_constant.png", dpi=150)
    print("wrote lagrange_constant.png")


if __name__ == "__main__":
    main()
