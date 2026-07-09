"""Visualization: the equalizer R[1/x] ∩ R[1/y] = R as a denominator lattice.

For coprime x, y we plot, for a grid of rationals p/q, which charts they belong to:
  blue  = x-integral only (in R[1/x])
  green = y-integral only (in R[1/y])
  red   = both charts  ->  forced to be a global section (denominator 1)
  grey  = neither chart
This makes `equalizer_inf` / `fibonacci_inter_eq_bot` visible: the red points all sit
on the integer line q = 1.
"""

from __future__ import annotations

from fractions import Fraction
from math import gcd
from typing import Optional

import matplotlib.pyplot as plt


def is_x_integral(x: int, f: Fraction, max_exponent: int = 64) -> Optional[int]:
    if f.denominator == 1:
        return 0
    if x in (0, 1, -1):
        return None
    power = 1
    for n in range(1, max_exponent + 1):
        power *= x
        if (power * f).denominator == 1:
            return n
    return None


def main() -> None:
    x, y = 3, 5  # coprime coordinates
    assert gcd(x, y) == 1
    fig, ax = plt.subplots(figsize=(9, 6))
    for p in range(1, 31):
        for q in range(1, 21):
            if gcd(p, q) != 1:
                continue
            f = Fraction(p, q)
            in_x = is_x_integral(x, f) is not None
            in_y = is_x_integral(y, f) is not None
            if in_x and in_y:
                color, size = "red", 70
            elif in_x:
                color, size = "tab:blue", 25
            elif in_y:
                color, size = "tab:green", 25
            else:
                color, size = "lightgrey", 12
            ax.scatter(p, q, c=color, s=size, edgecolors="none")
    ax.axhline(1, color="red", lw=0.8, ls="--", alpha=0.6)
    ax.set_xlabel("numerator p")
    ax.set_ylabel("denominator q")
    ax.set_title(f"Equalizer R[1/{x}] ∩ R[1/{y}] = R   (red = both charts = integer)")
    ax.text(16, 18, "red points lie on q=1\n(global sections = Z)",
            color="red", fontsize=10)
    plt.tight_layout()
    plt.savefig("equalizer_lattice.png", dpi=150)
    print("wrote equalizer_lattice.png")


if __name__ == "__main__":
    main()
