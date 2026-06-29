"""Visualization: the Korselt divisibility lattice for Carmichael numbers.

Generates a figure where, for each Carmichael number n below a bound, we draw
the prime factors p and annotate the divisibility (p-1) | (n-1). Saves to
'korselt_lattice.png'. Requires matplotlib.
"""
from __future__ import annotations

from math import gcd
from typing import Dict, List
import matplotlib.pyplot as plt


def factorize(n: int) -> Dict[int, int]:
    factors: Dict[int, int] = {}
    d, m = 2, n
    while d * d <= m:
        while m % d == 0:
            factors[d] = factors.get(d, 0) + 1
            m //= d
        d += 1 if d == 2 else 2
    if m > 1:
        factors[m] = factors.get(m, 0) + 1
    return factors


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    d = 2
    while d * d <= n:
        if n % d == 0:
            return False
        d += 1
    return True


def is_carmichael(n: int) -> bool:
    if n < 2 or is_prime(n):
        return False
    if any(e > 1 for e in factorize(n).values()):
        return False
    return all((n - 1) % (p - 1) == 0 for p in factorize(n))


def main() -> None:
    carmichaels: List[int] = [n for n in range(3, 10000) if is_carmichael(n)]
    fig, ax = plt.subplots(figsize=(11, 6))
    for row, n in enumerate(carmichaels):
        primes = list(factorize(n))
        ax.text(-0.5, row, f"n={n}\n(n-1={n-1})", ha="right", va="center",
                fontsize=8)
        for col, p in enumerate(primes):
            quotient = (n - 1) // (p - 1)
            ax.scatter(col, row, s=600, color="#3b6fb6", zorder=3)
            ax.text(col, row, f"{p}", ha="center", va="center",
                    color="white", fontsize=9, zorder=4)
            ax.text(col, row - 0.32, f"(p-1)|(n-1)\n{n-1}={p-1}·{quotient}",
                    ha="center", va="top", fontsize=6, color="#444")
    ax.set_title("Korselt divisibility fingerprint of Carmichael numbers < 10000",
                 fontsize=12)
    ax.set_xlabel("prime factor index")
    ax.set_yticks([])
    ax.set_xticks(range(3))
    ax.set_ylim(-1, len(carmichaels))
    ax.invert_yaxis()
    plt.tight_layout()
    plt.savefig("korselt_lattice.png", dpi=150)
    print("Saved korselt_lattice.png")


if __name__ == "__main__":
    main()
