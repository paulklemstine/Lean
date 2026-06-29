"""
Visualization: exponential collapse of the sheaf-consistency probability.

Plots log10 of  consistencyProbability(r, c) = (1 - r)^c  as a function of the
overlap constraint count  C = overlapConstraintCount(n, k, n) = n(n-1)/2 * (k*n)
for several missing/clash rates r, illustrating the conjecture of exponential
consistency decay. Saves `sheaf_consistency_decay.png`.
"""

from __future__ import annotations

import math
from typing import List

import matplotlib.pyplot as plt


def overlap_constraint_count(n: int, n_rows: int, n_cols: int) -> int:
    return n * (n - 1) // 2 * (n_rows * n_cols)


def main() -> None:
    ns: List[int] = list(range(2, 26))
    k = 100  # rows
    rates = [0.05, 0.1, 0.2, 0.3]

    plt.figure(figsize=(9, 6))
    for r in rates:
        log10_factor = math.log10(1.0 - r)
        xs = [overlap_constraint_count(n, k, n) for n in ns]
        ys = [c * log10_factor for c in xs]  # log10 of (1-r)^c
        plt.plot(ns, ys, marker="o", markersize=3, label=f"r = {r}")

    plt.xlabel("number of columns  n   (rows k = 100)")
    plt.ylabel(r"$\log_{10}\,P(\mathrm{sheaf}) = C(n,k)\cdot\log_{10}(1-r)$")
    plt.title("Exponential collapse of sheaf-consistency probability")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig("sheaf_consistency_decay.png", dpi=150)
    print("wrote sheaf_consistency_decay.png")


if __name__ == "__main__":
    main()
