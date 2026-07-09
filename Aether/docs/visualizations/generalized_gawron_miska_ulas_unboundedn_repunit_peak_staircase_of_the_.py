"""
Visualization: the coefficient sequence T_{b,2}(n) and its repunit peaks.

Plots |T_{b,2}(n)| for n up to a horizon and overlays the base-b repunit
indices R_k, where the closed form |T_{b,2}(R_k)| = 2^k is attained, showing
the unbounded staircase of peaks that drives the Gawron-Miska-Ulas result.

Requires: matplotlib, numpy.
"""

from __future__ import annotations

from math import comb
from typing import List

import matplotlib.pyplot as plt
import numpy as np


def truncated_product(b: int, m: int, max_deg: int) -> List[int]:
    result = [0] * (max_deg + 1)
    result[0] = 1
    exp = 1
    while exp <= max_deg:
        factor = [0] * (max_deg + 1)
        for j in range(m + 1):
            d = exp * j
            if d > max_deg:
                break
            factor[d] += comb(m, j) * ((-1) ** j)
        new = [0] * (max_deg + 1)
        for i, ai in enumerate(result):
            if ai == 0:
                continue
            for d, fd in enumerate(factor):
                if fd == 0 or i + d > max_deg:
                    continue
                new[i + d] += ai * fd
        result = new
        exp *= b
    return result


def repunit(b: int, k: int) -> int:
    r = 0
    for _ in range(k):
        r = b * r + 1
    return r


def main() -> None:
    b = 3
    horizon = 364  # = R_6 in base 3
    coeffs = truncated_product(b, 2, horizon)
    n = np.arange(horizon + 1)
    absc = np.abs(coeffs)

    fig, ax = plt.subplots(figsize=(11, 5))
    ax.bar(n, absc, width=1.0, color="#9bb7d4", label=r"$|T_{b,2}(n)|$")

    ks, rks, vals = [], [], []
    k = 0
    while repunit(b, k) <= horizon:
        rk = repunit(b, k)
        ks.append(k)
        rks.append(rk)
        vals.append(2 ** k)
        k += 1
    ax.scatter(rks, vals, color="#c0392b", zorder=5,
               label=r"repunit peaks $|T_{b,2}(R_k)| = 2^k$")
    for k, rk, v in zip(ks, rks, vals):
        ax.annotate(rf"$R_{{{k}}}$", (rk, v), textcoords="offset points",
                    xytext=(0, 6), ha="center", color="#c0392b", fontsize=9)

    ax.set_title(rf"Base $b={b}$, multiplicity $m=2$: repunit peaks grow as $2^k$")
    ax.set_xlabel("$n$")
    ax.set_ylabel(r"$|T_{b,2}(n)|$")
    ax.legend()
    fig.tight_layout()
    fig.savefig("gmu_repunit_peaks.png", dpi=150)
    print("saved gmu_repunit_peaks.png")


if __name__ == "__main__":
    main()
