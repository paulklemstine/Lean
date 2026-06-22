"""Visualization: occupancy growth under union closure and the FKG base-case
ratio on the powerset. Produces 'union_closed_correlation.png'."""
from __future__ import annotations

from itertools import combinations
import matplotlib.pyplot as plt


def powerset(n: int):
    elts = list(range(n))
    return [frozenset(c) for r in range(n + 1) for c in combinations(elts, r)]


def main() -> None:
    # Panel 1: total occupancy of 2^alpha grows like n * 2^(n-1).
    ns = list(range(1, 8))
    occ = []
    for n in ns:
        P = powerset(n)
        occ.append(sum(len(s) for s in P))

    # Panel 2: FKG ratio |2^a|*jc / (mc*mc) for distinct sites equals 1.
    ratios = []
    for n in range(2, 8):
        P = powerset(n)
        card = len(P)
        a, b = 0, 1
        mc_a = sum(1 for s in P if a in s)
        mc_b = sum(1 for s in P if b in s)
        jc = sum(1 for s in P if a in s and b in s)
        ratios.append(card * jc / (mc_a * mc_b))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 4.2))
    ax1.plot(ns, occ, "o-", color="#2a6f97")
    ax1.plot(ns, [n * 2 ** (n - 1) for n in ns], "--", color="#999",
             label=r"$n\,2^{n-1}$")
    ax1.set_title("Total occupancy of the powerset")
    ax1.set_xlabel("|alpha| = n")
    ax1.set_ylabel(r"$\sum_{s}|s|$")
    ax1.legend()

    ax2.axhline(1.0, color="#e07a5f", lw=2)
    ax2.plot(range(2, 8), ratios, "s", color="#2a6f97")
    ax2.set_title("FKG base-case ratio (distinct sites)")
    ax2.set_xlabel("|alpha| = n")
    ax2.set_ylabel(r"$|2^\alpha|\,\mathrm{jc}/(\mathrm{mc}\cdot\mathrm{mc})$")
    ax2.set_ylim(0.9, 1.1)

    fig.tight_layout()
    fig.savefig("union_closed_correlation.png", dpi=150)
    print("wrote union_closed_correlation.png")


if __name__ == "__main__":
    main()
