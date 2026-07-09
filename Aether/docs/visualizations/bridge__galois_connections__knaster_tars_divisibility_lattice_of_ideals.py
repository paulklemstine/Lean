"""
Visualization: the divisibility lattice of ideals of Z below N, with the
radical ideals (fixed points of the Galois closure c = vanishingIdeal . zeroLocus)
highlighted, and arrows showing how each ideal closes onto its radical.

This pictures Theorem A (the fixed points form a sub-lattice) and Theorem B
(the closure is the radical) simultaneously.
"""

from __future__ import annotations

from math import gcd
import matplotlib.pyplot as plt


def squarefree_part(n: int) -> int:
    n, result, d = abs(n), 1, 2
    seen = set()
    m = n
    while d * d <= m:
        while m % d == 0:
            if d not in seen:
                result *= d
                seen.add(d)
            m //= d
        d += 1
    if m > 1 and m not in seen:
        result *= m
    return result if n not in (0, 1) else n


def divisors(n: int) -> list[int]:
    return [d for d in range(1, n + 1) if n % d == 0]


def main() -> None:
    N = 12
    ds = divisors(N)
    # position: x by number of prime factors (rank), y spread
    import math
    def omega(k: int) -> int:
        c, d, m = 0, 2, k
        while d * d <= m:
            while m % d == 0:
                c += 1
                m //= d
            d += 1
        if m > 1:
            c += 1
        return c

    ranks: dict[int, int] = {d: omega(d) for d in ds}
    by_rank: dict[int, list[int]] = {}
    for d in ds:
        by_rank.setdefault(ranks[d], []).append(d)

    pos: dict[int, tuple[float, float]] = {}
    for r, group in by_rank.items():
        for i, d in enumerate(sorted(group)):
            pos[d] = (i - (len(group) - 1) / 2.0, r)

    fig, ax = plt.subplots(figsize=(8, 6))

    # Hasse cover edges (divisibility, prime-step)
    for a in ds:
        for b in ds:
            if b % a == 0 and ranks[b] == ranks[a] + 1:
                ax.plot([pos[a][0], pos[b][0]], [pos[a][1], pos[b][1]],
                        color="0.7", zorder=1)

    # closure arrows (ideal (n) -> radical) for non-radical ideals
    for d in ds:
        r = squarefree_part(d)
        if r != d and r in pos:
            ax.annotate("", xy=pos[r], xytext=pos[d],
                        arrowprops=dict(arrowstyle="->", color="crimson",
                                        lw=1.6, connectionstyle="arc3,rad=0.25"),
                        zorder=2)

    for d in ds:
        is_rad = squarefree_part(d) == d
        ax.scatter(*pos[d], s=900,
                   color=("#2ca02c" if is_rad else "#cfcfcf"),
                   edgecolors="black", zorder=3)
        ax.text(*pos[d], f"({d})", ha="center", va="center",
                fontsize=11, fontweight="bold", zorder=4)

    ax.set_title("Ideals of Z dividing 12: radical ideals (green = fixed points)\n"
                 "red arrows = Galois closure c(I)=radical(I)  (Theorems A & B)")
    ax.set_xlabel("(red arrows collapse each ideal onto its radical)")
    ax.set_ylabel("number of prime factors (lattice rank)")
    ax.set_xticks([])
    ax.margins(0.2)
    plt.tight_layout()
    plt.savefig("galois_zariski_lattice.png", dpi=150)
    print("Saved galois_zariski_lattice.png")


if __name__ == "__main__":
    main()
