"""Visualize the factorial number system: digit grid and the tight bound.

Generates two panels:
  (1) a heatmap of factoradic digits for n = 0..k!-1, showing the odometer
      pattern where column i cycles with period (i+1)!;
  (2) the maximal length-k value (k!-1) plotted against k! on a log scale,
      illustrating value_lt and its tightness.

Requires: matplotlib, numpy.  Run: python visualize_factoradic.py
"""

from math import factorial
from typing import List

import numpy as np
import matplotlib.pyplot as plt


def digit(n: int, i: int) -> int:
    return (n // factorial(i)) % (i + 1)


def main() -> None:
    k = 5
    N = factorial(k)
    grid = np.array([[digit(n, i) for i in range(k)] for n in range(N)])

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    im = ax1.imshow(grid.T, aspect="auto", cmap="viridis", origin="lower")
    ax1.set_title(f"Factoradic digits of n = 0..{N - 1}  (k = {k})")
    ax1.set_xlabel("n")
    ax1.set_ylabel("digit position i  (bound: c_i <= i)")
    ax1.set_yticks(range(k))
    fig.colorbar(im, ax=ax1, label="digit value")

    ks = list(range(1, 9))
    max_vals = [factorial(kk) - 1 for kk in ks]
    facts = [factorial(kk) for kk in ks]
    ax2.semilogy(ks, facts, "o-", label="k!  (strict upper bound)")
    ax2.semilogy(ks, max_vals, "s--", label="max value = k! - 1  (attained)")
    ax2.set_title("value_lt is tight: max length-k value = k! - 1")
    ax2.set_xlabel("k")
    ax2.set_ylabel("value (log scale)")
    ax2.legend()
    ax2.grid(True, which="both", alpha=0.3)

    fig.tight_layout()
    fig.savefig("factoradic_visualization.png", dpi=150)
    print("Saved factoradic_visualization.png")


if __name__ == "__main__":
    main()
