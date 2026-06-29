"""Visualization: the sign-flip involution and the vanishing mean correlation.

For a fixed hypothesis h, plots the correlation corr(sigma, h) across all 2^n
sign patterns sigma (sorted), and overlays the flipped pattern's correlation,
showing the exact antisymmetry corr(flip sigma, h) = -corr(sigma, h) that forces
the sum to zero (Theorem 4.2). Requires matplotlib.
"""
from __future__ import annotations
from itertools import product
from typing import Sequence
import matplotlib.pyplot as plt


def corr(sigma: Sequence[int], h: Sequence[float]) -> float:
    n = len(h)
    return sum(s * x for s, x in zip(sigma, h)) / n if n else 0.0


def main() -> None:
    n = 6
    h = [1.0, -2.0, 0.5, 1.5, -0.7, 0.9]
    patterns = list(product((-1, 1), repeat=n))
    cs = sorted(corr(s, h) for s in patterns)
    total = sum(cs)

    plt.figure(figsize=(8, 5))
    plt.bar(range(len(cs)), cs, width=1.0, color="steelblue")
    plt.axhline(0, color="black", lw=0.8)
    plt.title(f"Correlations over the hypercube sum to {total:.1e}  (n={n})\n"
              "antisymmetric under the sign-flip involution")
    plt.xlabel("sign pattern (sorted by correlation)")
    plt.ylabel("corr(sigma, h)")
    plt.tight_layout()
    plt.savefig("flip_symmetry.png", dpi=150)
    print("saved flip_symmetry.png")


if __name__ == "__main__":
    main()
