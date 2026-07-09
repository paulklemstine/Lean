"""
Visualization: Roth-number density decay and the Turan edge ceiling.

Generates a two-panel matplotlib figure:
  (left)  the largest 3AP-free fraction r_3(N)/N of {0,...,N-1} versus N,
          illustrating Roth's theorem (the fraction trends to 0);
  (right) the Turan edge ceiling (1 - 1/r) n^2 / 2 versus n for r = 2,3,4,
          with Mantel (r=2) highlighted.
Saves to 'extremal_overview.png'.
"""
from __future__ import annotations
from itertools import combinations
from typing import List, Set
import matplotlib.pyplot as plt


def three_ap_free_max(n: int) -> int:
    universe = list(range(n))
    best = 0
    for mask in range(1 << n):
        subset: Set[int] = {universe[i] for i in range(n) if (mask >> i) & 1}
        if len(subset) <= best:
            continue
        ok = True
        smax = max(subset) if subset else 0
        for x in subset:
            for d in range(1, smax + 1):
                if (x + d) in subset and (x + 2 * d) in subset:
                    ok = False
                    break
            if not ok:
                break
        if ok:
            best = len(subset)
    return best


def main() -> None:
    Ns: List[int] = list(range(1, 16))
    dens = [three_ap_free_max(n) / n for n in Ns]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    ax1.plot(Ns, dens, "o-", color="#c0392b")
    ax1.set_title("Roth: 3AP-free density r_3(N)/N -> 0")
    ax1.set_xlabel("N")
    ax1.set_ylabel("r_3(N) / N")
    ax1.set_ylim(0, 1.05)
    ax1.grid(alpha=0.3)

    ns = list(range(2, 41))
    for r, color in [(2, "#2980b9"), (3, "#27ae60"), (4, "#8e44ad")]:
        ceil = [(1 - 1 / r) * n * n / 2 for n in ns]
        label = "Mantel (r=2)" if r == 2 else f"Turan r={r}"
        ax2.plot(ns, ceil, label=label, color=color)
    ax2.set_title("Turan edge ceiling (1 - 1/r) n^2 / 2")
    ax2.set_xlabel("n")
    ax2.set_ylabel("max edges")
    ax2.legend()
    ax2.grid(alpha=0.3)

    fig.tight_layout()
    fig.savefig("extremal_overview.png", dpi=150)
    print("saved extremal_overview.png")


if __name__ == "__main__":
    main()
