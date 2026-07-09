"""Visualizations of the Erdos-Renyi threshold theorems.

Generates two figures:
  1. The critical window convergence  C(n,3)(c/n)^3 -> c^3/6  for several c.
  2. Isolated-vertex expectation n(1-p)^(n-1) across the two scales p=c/n and
     p=ln(n)/n, exhibiting the gap between the giant-component and connectivity
     thresholds.

Run with: python visualize.py  (writes erdos_renyi_thresholds.png)
"""

from __future__ import annotations

import math
from typing import List

import matplotlib.pyplot as plt


def expected_triangles(n: int, p: float) -> float:
    return math.comb(n, 3) * p ** 3


def expected_isolated(n: int, p: float) -> float:
    return n * (1.0 - p) ** (n - 1)


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    # Panel 1: critical-window convergence to c^3 / 6.
    ns: List[int] = [10, 20, 40, 80, 160, 320, 640, 1280, 2560, 5120]
    for c in (1.0, 2.0, 3.0):
        ys = [expected_triangles(n, c / n) for n in ns]
        ax1.plot(ns, ys, "o-", label=f"c = {c:g}")
        ax1.axhline(c ** 3 / 6, ls="--", color="gray", alpha=0.6)
    ax1.set_xscale("log")
    ax1.set_xlabel("n (log scale)")
    ax1.set_ylabel(r"$\binom{n}{3}(c/n)^3$")
    ax1.set_title("Critical window: E[#triangles] -> c^3/6")
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Panel 2: isolated vertices at the two scales.
    ns2 = [10, 30, 100, 300, 1000, 3000, 10000, 30000, 100000]
    giant = [expected_isolated(n, 1.0 / n) for n in ns2]
    conn = [expected_isolated(n, math.log(n) / n) for n in ns2]
    ax2.plot(ns2, giant, "s-", color="crimson", label="p = 1/n (giant scale)")
    ax2.plot(ns2, conn, "^-", color="steelblue", label="p = ln(n)/n (conn. scale)")
    ax2.set_xscale("log")
    ax2.set_yscale("log")
    ax2.set_xlabel("n (log scale)")
    ax2.set_ylabel("E[#isolated vertices] (log scale)")
    ax2.set_title("Isolated vertices: divergence below connectivity")
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig("erdos_renyi_thresholds.png", dpi=150)
    print("wrote erdos_renyi_thresholds.png")


if __name__ == "__main__":
    main()
