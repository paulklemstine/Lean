"""Visualization: the species/EGF dictionary in action.

Plots the coefficient sequences and the partial sums of the EGF product
exp * 1/(1-X), whose [X^n] coefficient converges to e.
Saves 'species_egf_bridge.png'.
"""
from __future__ import annotations

from fractions import Fraction
from math import comb, factorial
from typing import List

import matplotlib.pyplot as plt


def egf_coeffs(a: List[int], n: int) -> List[float]:
    return [a[k] / factorial(k) for k in range(n)]


def bin_conv(a: List[int], b: List[int], n: int) -> List[int]:
    return [sum(comb(m, i) * a[i] * b[m - i] for i in range(m + 1)) for m in range(n)]


def main() -> None:
    N = 9
    sets = [1] * N                       # species of sets    -> exp
    orders = [factorial(k) for k in range(N)]  # linear orders -> 1/(1-X)

    prod_counts = bin_conv(sets, orders, N)
    prod_egf = egf_coeffs(prod_counts, N)
    import math

    fig, axes = plt.subplots(1, 2, figsize=(12, 4.5))

    ax = axes[0]
    ax.plot(range(N), sets, "o-", label="sets E:  |E[n]| = 1")
    ax.plot(range(N), orders, "s-", label="linear orders L:  |L[n]| = n!")
    ax.plot(range(N), prod_counts, "^-", label="product E·L:  binom-conv")
    ax.set_yscale("log")
    ax.set_xlabel("n")
    ax.set_ylabel("number of structures (log scale)")
    ax.set_title("Counting sequences of species")
    ax.legend()
    ax.grid(True, alpha=0.3)

    ax = axes[1]
    ax.plot(range(N), prod_egf, "^-", color="green",
            label="[X^n] EGF(E·L) = EGF(E)·EGF(L)")
    ax.axhline(math.e, color="red", ls="--", label="e = 2.71828...")
    ax.set_xlabel("n")
    ax.set_ylabel("coefficient value")
    ax.set_title("Bridge: EGF of product = exp · 1/(1-X)\ncoefficients -> e")
    ax.legend()
    ax.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig("species_egf_bridge.png", dpi=130)
    print("saved species_egf_bridge.png")


if __name__ == "__main__":
    main()
