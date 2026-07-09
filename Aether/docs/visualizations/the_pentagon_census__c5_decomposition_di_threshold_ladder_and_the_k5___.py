"""
Visualization: the generalized Nash-Williams cycle-decomposition threshold
delta_{C_ell} = ell / (2 ell - 2), highlighting the pentagon value 5/8 and the
asymptote 1/2.  Also draws the two non-vacuity witnesses C_5 and K_5 = C_5 u C_5.
"""

from __future__ import annotations

from fractions import Fraction
from typing import List, Tuple

import matplotlib.pyplot as plt
import numpy as np


def nw_threshold(ell: int) -> Fraction:
    return Fraction(ell, 2 * ell - 2)


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    # ---- Left: the threshold family ----
    odd = list(range(3, 60, 2))
    ys = [float(nw_threshold(l)) for l in odd]
    ax1.plot(odd, ys, "o-", color="#2b6cb0", label=r"$\delta_{C_\ell}=\ell/(2\ell-2)$")
    ax1.axhline(0.5, ls="--", color="gray", label=r"asymptote $1/2$")
    ax1.scatter([5], [5 / 8], s=140, color="#e53e3e", zorder=5,
                label=r"pentagon $\delta_{C_5}=5/8$")
    ax1.annotate(r"$5/8$", (5, 5 / 8), textcoords="offset points",
                 xytext=(12, 10), color="#e53e3e", fontsize=12)
    ax1.annotate(r"$3/4$", (3, 3 / 4), textcoords="offset points",
                 xytext=(8, 6), color="#2b6cb0", fontsize=11)
    ax1.set_xlabel(r"odd cycle length $\ell$")
    ax1.set_ylabel(r"min-degree threshold $\delta_{C_\ell}$")
    ax1.set_title("Strictly decreasing threshold family")
    ax1.legend()
    ax1.grid(alpha=0.3)

    # ---- Right: K_5 = C_5 (outer) u C_5 (inner pentagram) ----
    n = 5
    ang = np.array([np.pi / 2 + 2 * np.pi * k / n for k in range(n)])
    pts = np.column_stack([np.cos(ang), np.sin(ang)])
    outer = [(k, (k + 1) % n) for k in range(n)]
    inner = [(0, 2), (2, 4), (4, 1), (1, 3), (3, 0)]
    for a, b in outer:
        ax2.plot(*zip(pts[a], pts[b]), color="#2b6cb0", lw=2.5)
    for a, b in inner:
        ax2.plot(*zip(pts[a], pts[b]), color="#e53e3e", lw=2.0, ls="--")
    ax2.scatter(pts[:, 0], pts[:, 1], s=260, color="#1a202c", zorder=5)
    for k in range(n):
        ax2.annotate(str(k), pts[k], color="white", ha="center", va="center",
                     fontsize=11, zorder=6)
    ax2.set_title(r"$K_5 = C_5 \cup C_5$  (outer pentagon + inner pentagram)")
    ax2.set_aspect("equal")
    ax2.axis("off")

    fig.suptitle("C5-decompositions and the 5/8 threshold", fontsize=14)
    fig.tight_layout()
    fig.savefig("c5_threshold.png", dpi=150)
    print("wrote c5_threshold.png")


if __name__ == "__main__":
    main()
