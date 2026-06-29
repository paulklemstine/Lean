"""
visualization.py — Tropical valuation flow under differentiation.

Renders two panels:
  (1) The "order ladder": how repeated differentiation lowers the order of a
      power series by at most one per step (Iterated Bound), and exactly one per
      step in characteristic zero (Exact Drop).
  (2) The tropical collision proving the Pinning Theorem: the orders of f' and
      c*f as functions of a hypothetical order n, showing they meet only at n=0.

Requires matplotlib. Saves 'tropical_diff.png'.
"""

from __future__ import annotations

from typing import List

import matplotlib.pyplot as plt


def order_after_k_derivatives(start_order: int, k: int) -> int:
    """Exact drop in characteristic zero: each derivative subtracts exactly one."""
    return max(start_order - k, 0)


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # ---- Panel 1: the order ladder ----
    start = 6
    ks: List[int] = list(range(start + 1))
    exact = [order_after_k_derivatives(start, k) for k in ks]      # char 0
    upper = [start - k for k in ks]                                # universal upper bound line
    ax1.plot(ks, exact, "o-", color="#1f77b4", lw=2, label="ord f^(k)  (char 0, exact)")
    ax1.plot(ks, upper, "--", color="#888888", lw=1.5,
             label="bound: ord f - k  (universal)")
    ax1.fill_between(ks, upper, [start] * len(ks), color="#1f77b4", alpha=0.07)
    ax1.set_title("Order ladder: differentiation drops order by at most one")
    ax1.set_xlabel("k  (number of derivatives)")
    ax1.set_ylabel("ord f^(k)")
    ax1.set_xticks(ks)
    ax1.grid(alpha=0.3)
    ax1.legend()

    # ---- Panel 2: the tropical collision (Pinning Theorem) ----
    ns = list(range(0, 7))
    ord_fprime = [max(n - 1, 0) if n > 0 else None for n in ns]  # ord f' = n-1 for n>0
    ord_cf = [n for n in ns]                                     # ord(c f) = n
    # plot ord(c f) = n
    ax2.plot(ns, ord_cf, "s-", color="#d62728", lw=2, label="ord(c·f) = n")
    # plot ord f' = n-1 (only defined for n>0)
    xs = [n for n in ns if n > 0]
    ys = [n - 1 for n in xs]
    ax2.plot(xs, ys, "o-", color="#2ca02c", lw=2, label="ord(f') = n - 1  (char 0)")
    ax2.scatter([0], [0], s=140, facecolors="none", edgecolors="black", lw=2,
                zorder=5, label="only consistent point: n = 0")
    ax2.set_title("Pinning Theorem: f' = c·f forces ord f = 0")
    ax2.set_xlabel("hypothetical n = ord f")
    ax2.set_ylabel("order of each side")
    ax2.set_xticks(ns)
    ax2.grid(alpha=0.3)
    ax2.legend()
    ax2.text(2.2, 0.3,
             "lines never meet for n>0\n(n-1 = n is impossible)\n→ valuation pinned to 0",
             fontsize=9, color="#444444")

    fig.suptitle("Tropical Differential Equations on Power Series", fontsize=14)
    fig.tight_layout(rect=(0, 0, 1, 0.96))
    fig.savefig("tropical_diff.png", dpi=150)
    print("Saved tropical_diff.png")


if __name__ == "__main__":
    main()
