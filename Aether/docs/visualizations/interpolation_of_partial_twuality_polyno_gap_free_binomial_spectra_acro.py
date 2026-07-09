"""Visualize partial-twuality polynomials as Pascal's-triangle bar charts.

Generates, for ground sets of several sizes, the coefficient vector of the
single-feasible-set partial-twuality polynomial (always the binomial (1+z)^n)
and plots it as a bar chart, highlighting the gap-free interpolating support.
Requires matplotlib.
"""
from math import comb
from typing import List

import matplotlib.pyplot as plt


def binomial_row(n: int) -> List[int]:
    return [comb(n, k) for k in range(n + 1)]


def main() -> None:
    sizes: List[int] = [2, 3, 4, 5]
    fig, axes = plt.subplots(1, len(sizes), figsize=(4 * len(sizes), 4), sharey=False)
    for ax, n in zip(axes, sizes):
        coeffs = binomial_row(n)
        ax.bar(range(n + 1), coeffs, color="#3b7dd8", edgecolor="black")
        ax.set_title(f"|E| = {n}:  (1+z)^{n}")
        ax.set_xlabel("degree k = |F \u2206 A|")
        ax.set_ylabel("ptCoeff(E, F, k)")
        ax.set_xticks(range(n + 1))
    fig.suptitle("Partial-twuality polynomials are gap-free binomials", fontsize=14)
    fig.tight_layout()
    fig.savefig("partial_twuality_spectra.png", dpi=150)
    print("Saved partial_twuality_spectra.png")


if __name__ == "__main__":
    main()
