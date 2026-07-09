"""
viz.py — Visualizations for the Character Class Contradiction
=============================================================

Generates two figures:

  1. The point counts N_r = trace(A^r) = 2^r on a log scale, with the r=0
     boundary anomaly (trace = 2, not 2^0 = 1) highlighted in red.
  2. The zeta function Z(t) = 1/(1-2t) on (-1/2, 1/2), with its single pole
     at t = 1/2 marked, alongside truncated-series approximations converging
     to it inside the disc of convergence.

Run:  python viz.py   ->   writes character_class_contradiction.png
"""

from __future__ import annotations

import math
from typing import List

import matplotlib.pyplot as plt
import numpy as np


def point_count(r: int) -> int:
    """N_r = trace(A^r): 2 at r=0 (boundary), 2^r for r >= 1."""
    return 2 if r == 0 else 2 ** r


def zeta_closed(t: float) -> float:
    """Z(t) = 1/(1-2t)."""
    return 1.0 / (1.0 - 2.0 * t)


def zeta_series(t: float, terms: int) -> float:
    """Truncated exp(sum_{r=1..terms} 2^r t^r / r)."""
    s = sum(point_count(r) * (t ** r) / r for r in range(1, terms + 1))
    return math.exp(s)


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    # --- Panel 1: point counts ---
    rs: List[int] = list(range(0, 11))
    counts = [point_count(r) for r in rs]
    pow2 = [2 ** r for r in rs]
    ax1.semilogy(rs[1:], pow2[1:], "o-", color="#1f77b4", label=r"$2^r$ (theorem)")
    ax1.semilogy([0], [counts[0]], "s", color="#d62728", markersize=11,
                 label=r"$\mathrm{trace}(A^0)=2\neq 1$ (anomaly)")
    ax1.semilogy([0], [pow2[0]], "x", color="#999999", markersize=10,
                 label=r"$2^0=1$")
    ax1.set_xlabel("r")
    ax1.set_ylabel(r"$N_r = \mathrm{trace}(A^r)$")
    ax1.set_title("Point counts: an unbounded geometric tower")
    ax1.legend()
    ax1.grid(True, which="both", alpha=0.3)

    # --- Panel 2: zeta function ---
    ts = np.linspace(-0.49, 0.49, 400)
    zs = [zeta_closed(t) for t in ts]
    ax2.plot(ts, zs, color="#2ca02c", lw=2.5, label=r"$Z(t)=\frac{1}{1-2t}$")
    for k, terms in enumerate([2, 5, 20]):
        approx = [zeta_series(t, terms) for t in ts]
        ax2.plot(ts, approx, "--", lw=1, alpha=0.7,
                 label=f"series, {terms} terms")
    ax2.axvline(0.5, color="#d62728", ls=":", label=r"pole $t=1/2$")
    ax2.set_xlabel("t")
    ax2.set_ylabel("Z(t)")
    ax2.set_ylim(-2, 12)
    ax2.set_title("Zeta function and its truncated series")
    ax2.legend(fontsize=8)
    ax2.grid(True, alpha=0.3)

    fig.suptitle("The Character Class Contradiction: "
                 r"$A=\left(\begin{smallmatrix}1&1\\1&1\end{smallmatrix}\right)$",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("character_class_contradiction.png", dpi=150)
    print("wrote character_class_contradiction.png")


if __name__ == "__main__":
    main()
