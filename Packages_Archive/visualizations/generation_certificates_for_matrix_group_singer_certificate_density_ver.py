"""
Visualization: certificate density of GL_n(GF(p)) vs. dimension n.

Plots the empirical fraction of matrices in GL_n(GF(p)) whose characteristic
polynomial is irreducible (the "Singer certificate density"), and overlays the
classical 1/n heuristic of Conjecture A.  Self-contained except for matplotlib.
"""

from __future__ import annotations

import itertools
import matplotlib.pyplot as plt


def inv_mod(a: int, p: int) -> int:
    return pow(a % p, p - 2, p)


def poly_trim(c: list[int]) -> list[int]:
    while len(c) > 1 and c[-1] == 0:
        c.pop()
    return c


def poly_mul(a: list[int], b: list[int], p: int) -> list[int]:
    r = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        if ai:
            for j, bj in enumerate(b):
                r[i + j] = (r[i + j] + ai * bj) % p
    return poly_trim(r)


def poly_add(a: list[int], b: list[int], p: int) -> list[int]:
    m = max(len(a), len(b))
    return poly_trim([((a[i] if i < len(a) else 0)
                       + (b[i] if i < len(b) else 0)) % p for i in range(m)])


def poly_mod(a: list[int], m: list[int], p: int) -> list[int]:
    a = [x % p for x in a]
    m = poly_trim([x % p for x in m])
    dm = len(m) - 1
    inv_lead = inv_mod(m[-1], p)
    while len(poly_trim(a)) - 1 >= dm and any(a):
        da = len(poly_trim(a)) - 1
        if da < dm:
            break
        coeff = (a[da] * inv_lead) % p
        sh = da - dm
        for i, mi in enumerate(m):
            a[i + sh] = (a[i + sh] - coeff * mi) % p
        a = poly_trim(a)
    return poly_trim(a)


def poly_gcd(a: list[int], b: list[int], p: int) -> list[int]:
    a, b = poly_trim(a[:]), poly_trim(b[:])
    while any(b):
        a, b = b, poly_mod(a, b, p)
    return poly_trim(a)


def poly_powmod(base: list[int], e: int, m: list[int], p: int) -> list[int]:
    res = [1]
    base = poly_mod(base, m, p)
    while e > 0:
        if e & 1:
            res = poly_mod(poly_mul(res, base, p), m, p)
        base = poly_mod(poly_mul(base, base, p), m, p)
        e >>= 1
    return res


def prime_divisors(n: int) -> set[int]:
    out, d, m = set(), 2, n
    while d * d <= m:
        while m % d == 0:
            out.add(d)
            m //= d
        d += 1
    if m > 1:
        out.add(m)
    return out


def is_irreducible(f: list[int], p: int) -> bool:
    f = poly_trim([x % p for x in f])
    n = len(f) - 1
    if n <= 0:
        return False
    if n == 1:
        return True
    xp = poly_powmod([0, 1], p ** n, f, p)
    diff = xp[:] + [0] * (2 - len(xp))
    diff[1] = (diff[1] - 1) % p
    if poly_mod(diff, f, p) != [0]:
        return False
    for q in prime_divisors(n):
        xq = poly_powmod([0, 1], p ** (n // q), f, p)
        d = xq[:] + [0] * (2 - len(xq))
        d[1] = (d[1] - 1) % p
        if len(poly_trim(poly_gcd(f, d, p))) - 1 != 0:
            return False
    return True


def poly_mat_det(A: list[list[list[int]]], p: int) -> list[int]:
    n = len(A)
    if n == 1:
        return poly_trim([x % p for x in A[0][0]])
    total: list[int] = [0]
    for j in range(n):
        minor = [[A[i][k] for k in range(n) if k != j] for i in range(1, n)]
        term = poly_mul(A[0][j], poly_mat_det(minor, p), p)
        if j % 2 == 1:
            term = [(-c) % p for c in term]
        total = poly_add(total, term, p)
    return poly_trim(total)


def charpoly(M: list[list[int]], p: int) -> list[int]:
    n = len(M)
    A = [[([(-M[i][j]) % p, 1] if i == j else [(-M[i][j]) % p])
          for j in range(n)] for i in range(n)]
    return poly_mat_det(A, p)


def det(M: list[list[int]], p: int) -> int:
    n = len(M)
    A = [row[:] for row in M]
    d = 1
    for c in range(n):
        piv = next((r for r in range(c, n) if A[r][c] % p), None)
        if piv is None:
            return 0
        if piv != c:
            A[c], A[piv] = A[piv], A[c]
            d = -d
        d = (d * A[c][c]) % p
        inv = inv_mod(A[c][c], p)
        for r in range(c + 1, n):
            f = (A[r][c] * inv) % p
            A[r] = [(A[r][j] - f * A[c][j]) % p for j in range(n)]
    return d % p


def density(n: int, p: int) -> float:
    total = cert = 0
    for entries in itertools.product(range(p), repeat=n * n):
        M = [list(entries[i * n:(i + 1) * n]) for i in range(n)]
        if det(M, p) == 0:
            continue
        total += 1
        if is_irreducible(charpoly(M, p), p):
            cert += 1
    return cert / total


def main() -> None:
    p = 2
    ns = [2, 3, 4]
    dens = [density(n, p) for n in ns]
    heuristic = [1.0 / n for n in ns]

    fig, ax = plt.subplots(figsize=(7, 4.5))
    ax.plot(ns, dens, "o-", label=f"empirical density (GF({p}))", lw=2)
    ax.plot(ns, heuristic, "s--", label="1/n heuristic", lw=2)
    ax.set_xlabel("dimension n")
    ax.set_ylabel("certificate density in GL_n(GF(p))")
    ax.set_title("Singer certificate density vs. dimension (Conjecture A)")
    ax.set_xticks(ns)
    ax.legend()
    ax.grid(alpha=0.3)
    fig.tight_layout()
    fig.savefig("certificate_density.png", dpi=150)
    print("Saved certificate_density.png")


if __name__ == "__main__":
    main()
