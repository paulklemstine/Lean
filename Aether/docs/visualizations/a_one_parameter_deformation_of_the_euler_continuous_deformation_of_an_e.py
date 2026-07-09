"""
Visualization: rows of the extended Eulerian numbers A(n, k, s) as the shift s
varies continuously. Each curve k -> A(n, k, s) is plotted against s in [0, 1],
showing how the classical integer Eulerian row (at s = 0) deforms smoothly while
the row sum stays pinned at n!.

Run:  python visualize.py   (writes extended_eulerian.png)
"""

from __future__ import annotations

from math import comb, factorial
from typing import List

import numpy as np
import matplotlib.pyplot as plt


def A_closed(n: int, k: int, s: float) -> float:
    """A(n, k, s) = sum_{i=0}^{k} (-1)^i C(n+1, i) (k+1-i-s)^n."""
    if k < 0 or k > n:
        return 0.0
    return float(sum((-1) ** i * comb(n + 1, i) * (k + 1 - i - s) ** n
                     for i in range(k + 1)))


def main() -> None:
    n = 5
    s_vals = np.linspace(0.0, 1.0, 200)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    for k in range(n):  # last column A(n, n, s) is identically 0
        ys: List[float] = [A_closed(n, k, s) for s in s_vals]
        ax1.plot(s_vals, ys, label=f"k={k}")
    ax1.set_title(f"Extended Eulerian numbers $A({n},k,s)$ vs shift $s$")
    ax1.set_xlabel("shift $s$")
    ax1.set_ylabel(f"$A({n},k,s)$")
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    row_sums = [sum(A_closed(n, k, s) for k in range(n + 1)) for s in s_vals]
    ax2.plot(s_vals, row_sums, color="crimson", lw=2)
    ax2.axhline(factorial(n), ls="--", color="black",
                label=f"${n}! = {factorial(n)}$")
    ax2.set_title(f"Row sum $\\sum_k A({n},k,s)$ is constant $= {n}!$")
    ax2.set_xlabel("shift $s$")
    ax2.set_ylabel("row sum")
    ax2.set_ylim(0, factorial(n) * 1.3)
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig("extended_eulerian.png", dpi=130)
    print("wrote extended_eulerian.png")


if __name__ == "__main__":
    main()
