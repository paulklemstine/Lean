"""
Visualization: Pascal's triangle central maximality and the Sauer-Shelah ceiling.

Generates two panels:
  (left)  rows of binomial coefficients with the central (maximal) entry
          highlighted, illustrating  C(d,k) <= C(d, floor(d/2));
  (right) the Sauer-Shelah growth bound layeredSum(n,d) = sum_{k=0}^d C(n,k)
          versus the full-row total 2^n, showing the polynomial-vs-exponential gap.

Run with:  python viz.py   (saves layered_star_viz.png)
"""

from __future__ import annotations

from math import comb
from typing import List

import matplotlib.pyplot as plt


def sauer_shelah_sum(n: int, d: int) -> int:
    return sum(comb(n, k) for k in range(d + 1))


def main() -> None:
    fig, (ax0, ax1) = plt.subplots(1, 2, figsize=(13, 5))

    # Panel 0: Pascal rows with central entry highlighted.
    rows: List[int] = list(range(0, 9))
    for d in rows:
        xs = list(range(d + 1))
        ys = [comb(d, k) for k in xs]
        ax0.plot([x - d / 2 for x in xs], [d] * len(xs), color="0.85", zorder=0)
        ax0.scatter([x - d / 2 for x in xs], [d] * len(xs),
                    s=[8 + 4 * v for v in ys], color="tab:blue", alpha=0.6, zorder=1)
        cmid = d // 2
        ax0.scatter([cmid - d / 2], [d], s=8 + 4 * comb(d, cmid),
                    color="tab:red", zorder=2)
    ax0.set_title("Pascal rows: central entry (red) is maximal")
    ax0.set_xlabel("k - d/2  (centered)")
    ax0.set_ylabel("row d")
    ax0.invert_yaxis()

    # Panel 1: Sauer-Shelah sum vs 2^n.
    n = 20
    ds = list(range(0, n + 1))
    ss = [sauer_shelah_sum(n, d) for d in ds]
    ax1.plot(ds, ss, "o-", label=f"layeredSum({n}, d)")
    ax1.axhline(2 ** n, color="tab:red", ls="--", label=f"$2^{{{n}}}$")
    ax1.set_yscale("log")
    ax1.set_title(f"Sauer-Shelah ceiling (n={n}) stays below $2^n$")
    ax1.set_xlabel("VC budget d")
    ax1.set_ylabel("count (log scale)")
    ax1.legend()

    fig.tight_layout()
    fig.savefig("layered_star_viz.png", dpi=140)
    print("Saved layered_star_viz.png")


if __name__ == "__main__":
    main()
