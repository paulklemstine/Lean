"""
Visualization: Certificate density in GL_n(F_p) versus the ~1/n heuristic.

Renders, for a fixed prime p, the empirically computed fraction of GL_n(F_p)
elements whose characteristic polynomial is irreducible (the "Singer
certificate" density), and overlays the theoretical ~1/n trend predicted by
Conjecture A.  Uses only matplotlib + the inlined finite-field utilities.
"""

from __future__ import annotations

from itertools import product
from typing import List, Tuple

import matplotlib.pyplot as plt


def inv_mod(a: int, p: int) -> int:
    return pow(a % p, p - 2, p)


def prime_factors(n: int) -> List[int]:
    f, d, m = [], 2, n
    while d * d <= m:
        if m % d == 0:
            f.append(d)
            while m % d == 0:
                m //= d
        d += 1
    if m > 1:
        f.append(m)
    return f


def poly_trim(c: List[int]) -> List[int]:
    while len(c) > 1 and c[-1] == 0:
        c.pop()
    return c


def poly_mod_mul(a: List[int], b: List[int], p: int) -> List[int]:
    r = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        if ai:
            for j, bj in enumerate(b):
                r[i + j] = (r[i + j] + ai * bj) % p
    return poly_trim(r)


def poly_divmod(a: List[int], b: List[int], p: int) -> Tuple[List[int], List[int]]:
    a, b = poly_trim(a[:]), poly_trim(b[:])
    q = [0] * max(1, len(a) - len(b) + 1)
    il = inv_mod(b[-1], p)
    while len(a) >= len(b) and a != [0]:
        dd = len(a) - len(b)
        co = (a[-1] * il) % p
        q[dd] = co
        for i, bi in enumerate(b):
            a[dd + i] = (a[dd + i] - co * bi) % p
        a = poly_trim(a)
    return poly_trim(q), poly_trim(a)


def poly_gcd(a: List[int], b: List[int], p: int) -> List[int]:
    a, b = poly_trim(a[:]), poly_trim(b[:])
    while b != [0]:
        _, r = poly_divmod(a, b, p)
        a, b = b, r
    if a != [0]:
        il = inv_mod(a[-1], p)
        a = [(c * il) % p for c in a]
    return poly_trim(a)


def poly_powmod(base: List[int], e: int, mod: List[int], p: int) -> List[int]:
    res, b = [1], poly_divmod(base, mod, p)[1]
    while e > 0:
        if e & 1:
            res = poly_divmod(poly_mod_mul(res, b, p), mod, p)[1]
        b = poly_divmod(poly_mod_mul(b, b, p), mod, p)[1]
        e >>= 1
    return poly_trim(res)


def is_irreducible(poly: List[int], p: int) -> bool:
    poly = poly_trim(poly[:])
    n = len(poly) - 1
    if n <= 0:
        return False
    if n == 1:
        return True
    x = [0, 1]
    xpn = poly_powmod(x, p ** n, poly, p)
    diff = poly_trim([((xpn[i] if i < len(xpn) else 0) - (x[i] if i < len(x) else 0)) % p
                      for i in range(max(len(xpn), len(x)))])
    if diff != [0]:
        return False
    for ell in prime_factors(n):
        xpm = poly_powmod(x, p ** (n // ell), poly, p)
        d = poly_trim([((xpm[i] if i < len(xpm) else 0) - (x[i] if i < len(x) else 0)) % p
                       for i in range(max(len(xpm), len(x)))])
        if len(poly_gcd(d, poly, p)) - 1 != 0:
            return False
    return True


def poly_det(PM, p: int) -> List[int]:
    n = len(PM)
    if n == 1:
        return PM[0][0][:]
    total = [0]
    for j in range(n):
        minor = [[PM[i][k] for k in range(n) if k != j] for i in range(1, n)]
        term = poly_mod_mul(PM[0][j], poly_det(minor, p), p)
        if j % 2 == 1:
            term = [(-c) % p for c in term]
        total = poly_trim([((total[i] if i < len(total) else 0) +
                            (term[i] if i < len(term) else 0)) % p
                           for i in range(max(len(total), len(term)))])
    return total


def charpoly(A, p: int) -> List[int]:
    n = len(A)
    PM = [[[(-A[i][j]) % p] for j in range(n)] for i in range(n)]
    for i in range(n):
        PM[i][i] = [(-A[i][i]) % p, 1]
    return poly_trim(poly_det(PM, p))


def density(n: int, p: int) -> float:
    inv, cert = 0, 0
    for entries in product(range(p), repeat=n * n):
        A = [list(entries[i * n:(i + 1) * n]) for i in range(n)]
        cp = charpoly(A, p)
        det = ((-1) ** n) * cp[0]
        if det % p == 0:
            continue
        inv += 1
        if is_irreducible(cp, p):
            cert += 1
    return cert / inv if inv else 0.0


def main() -> None:
    p = 2
    ns = [2, 3, 4]
    empirical = [density(n, p) for n in ns]
    heuristic = [1.0 / n for n in ns]

    plt.figure(figsize=(8, 5))
    plt.plot(ns, empirical, "o-", label=f"empirical density in GL_n(F_{p})")
    plt.plot(ns, heuristic, "s--", label="1/n heuristic (Conjecture A)")
    plt.xlabel("dimension n")
    plt.ylabel("fraction with irreducible charpoly")
    plt.title(f"Singer certificate density in GL_n(F_{p})")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig("certificate_density.png", dpi=150)
    print("Saved certificate_density.png")


if __name__ == "__main__":
    main()
