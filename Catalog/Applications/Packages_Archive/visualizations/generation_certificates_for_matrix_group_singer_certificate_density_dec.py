"""
Visualization: Certificate density in GL_n(F_q) versus dimension n.

Plots the fraction of invertible matrices whose characteristic polynomial is
irreducible (the "Singer certificate" density), illustrating the conjectured
~ c_q / n decay and confirming Theorem 4 (strict positivity).
Pure standard-library counting for small (n, q); matplotlib for the plot.
"""
from __future__ import annotations
from itertools import product
from typing import List, Tuple
import matplotlib.pyplot as plt


def inv_mod(a: int, p: int) -> int:
    return pow(a % p, p - 2, p)


def det_mod(M: Tuple[Tuple[int, ...], ...], p: int) -> int:
    n = len(M)
    a = [list(r) for r in M]
    det = 1
    for c in range(n):
        piv = next((r for r in range(c, n) if a[r][c] % p), None)
        if piv is None:
            return 0
        if piv != c:
            a[c], a[piv] = a[piv], a[c]; det = -det
        det = (det * a[c][c]) % p
        iv = inv_mod(a[c][c], p)
        for r in range(c + 1, n):
            f = (a[r][c] * iv) % p
            for k in range(c, n):
                a[r][k] = (a[r][k] - f * a[c][k]) % p
    return det % p


def num_irreducible_monic(n: int, q: int) -> int:
    """Gauss's formula: (1/n) * sum_{d|n} mu(d) q^(n/d)."""
    def mu(m: int) -> int:
        if m == 1:
            return 1
        res, d, cnt = 1, 2, 0
        x = m
        while d * d <= x:
            if x % d == 0:
                e = 0
                while x % d == 0:
                    x //= d; e += 1
                if e > 1:
                    return 0
                res = -res
            d += 1
        if x > 1:
            res = -res
        return res
    total = sum(mu(d) * q ** (n // d) for d in range(1, n + 1) if n % d == 0)
    return total // n


def gl_order(n: int, q: int) -> int:
    prod = 1
    for k in range(n):
        prod *= (q ** n - q ** k)
    return prod


def main() -> None:
    qs = [2, 3, 5]
    ns = list(range(2, 9))
    plt.figure(figsize=(8, 5))
    for q in qs:
        densities: List[float] = []
        for n in ns:
            # Each irreducible monic charpoly of degree n corresponds to a
            # conjugacy class of cyclic matrices; the count of elements with
            # irreducible charpoly is (#irreducible monic) * |GL_n| / (q^n - 1).
            irr = num_irreducible_monic(n, q)
            elems = irr * gl_order(n, q) // (q ** n - 1)
            densities.append(elems / gl_order(n, q))
        plt.plot(ns, densities, "o-", label=f"q = {q}")
        plt.plot(ns, [1.0 / n for n in ns], "k--", alpha=0.3)
    plt.xlabel("dimension n")
    plt.ylabel("certificate density in GL_n(F_q)")
    plt.title("Singer certificate density vs dimension (dashed = 1/n)")
    plt.legend()
    plt.grid(alpha=0.3)
    plt.tight_layout()
    plt.savefig("certificate_density.png", dpi=130)
    print("saved certificate_density.png")


if __name__ == "__main__":
    main()
