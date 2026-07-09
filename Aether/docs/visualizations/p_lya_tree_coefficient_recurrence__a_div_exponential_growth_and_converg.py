"""Visualize the growth of the Polya tree sequence and its ratio toward
Otter's constant alpha ~ 2.9557, computed via the verified recurrence.

Requires matplotlib.  Run:  python visualize_polya_growth.py
"""
from __future__ import annotations
from fractions import Fraction
from typing import List
import matplotlib.pyplot as plt


def divisors(n: int) -> List[int]:
    return [d for d in range(1, n + 1) if n % d == 0]


def polya(n_max: int) -> List[int]:
    a = [Fraction(0)] * (n_max + 1)
    if n_max >= 1:
        a[1] = Fraction(1)
    for k in range(2, n_max + 1):
        conv = Fraction(0)
        for j in range(1, k):
            m = k - j
            w = sum((Fraction(d) * a[d] for d in divisors(m)), Fraction(0))
            conv += a[j] * w
        a[k] = conv / Fraction(k - 1)
    return [int(x) for x in a]


def main() -> None:
    N = 30
    a = polya(N)
    ks = list(range(1, N + 1))
    vals = [a[k] for k in ks]
    ratios = [a[k + 1] / a[k] for k in range(1, N)]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    ax1.semilogy(ks, vals, "o-", color="#2b6cb0")
    ax1.set_title("Polya tree counts a_k (log scale)")
    ax1.set_xlabel("k"); ax1.set_ylabel("a_k"); ax1.grid(True, alpha=0.3)

    ax2.plot(range(1, N), ratios, "o-", color="#c05621", label="a_{k+1}/a_k")
    ax2.axhline(2.9557652856, color="green", ls="--", label="Otter alpha ~ 2.9557")
    ax2.set_title("Successive ratios approach Otter's constant")
    ax2.set_xlabel("k"); ax2.set_ylabel("ratio"); ax2.grid(True, alpha=0.3); ax2.legend()

    fig.tight_layout()
    fig.savefig("polya_growth.png", dpi=130)
    print("wrote polya_growth.png")


if __name__ == "__main__":
    main()
