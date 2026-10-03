"""
C1 driver: find genuine GNFS smooth relations for a small N, assemble the
Montgomery relation lattice, and compare LLL against BKZ on that exact lattice.
"""
import math
import sys
import numpy as np
from sympy import primerange, factorint

from lll_self_test import lll_reduce, bkz_reduce, is_lll_reduced
import nfs_lattice as NL

X = NL.X


def f_coeffs_of(P):
    d = P.degree()
    c = [0] * (d + 1)
    for (k,), v in P.terms():
        c[d - k] = int(v)
    return c


def build(Nbits=60, d=3, seed=7):
    """A balanced RSA semiprime of exactly the requested bit length."""
    lo = 2 ** (Nbits // 2 - 1)
    hi = 2 ** (Nbits // 2)
    gap = 2 ** (Nbits // 2 - 2)
    p = next(primerange(lo, lo + gap))
    q = next(primerange(hi - gap, hi))
    assert p != q and lo <= p < q < hi, (p, q)
    N = p * q
    cost, m, digs = NL.best_m(N, d)
    P = NL.make_poly(N, d, m)
    fc = f_coeffs_of(P)
    return N, p, q, m, P, fc, cost


def find_relations(fc, d, m, N, ymax=5000, Amax=800, Bmax=800, need=40):
    """Sieve over (a,b) for y-smooth algebraic integers a - b*theta.

    p divides a - b*theta (as an ideal) iff a = b*alpha (mod p) for some root
    alpha of f mod p.  The condition couples a AND b, so the sieve tests the
    full grid: (a - b*alpha) mod p == 0.  Marking whole rows (an earlier
    version) lost that coupling and killed every pair on the first prime.
    """
    split = NL.split_primes(fc, ymax)
    A64 = np.arange(-Amax, Amax, dtype=np.int64)
    B64 = np.arange(1, Bmax + 1, dtype=np.int64)
    norm = np.zeros((2 * Amax, Bmax), dtype=np.int64)
    for i, c in enumerate(fc):
        norm += np.outer(A64 ** (d - i), B64 ** i) * c
    alive = (norm != 0)          # sign is irrelevant to smoothness
    for p, roots in sorted(split.items()):
        mask = np.zeros_like(alive)
        for alpha in roots:
            mask |= ((A64[:, None] - alpha * B64[None, :]) % p) == 0
        sel = alive & mask
        while sel.any():
            alive &= ~sel
            sel = alive & mask
    idx = np.argwhere(alive)
    plist = sorted(split)
    rels = []
    for (ai, bi) in idx:
        a, b = int(A64[ai]), int(B64[bi])
        e, rest = NL.relation_exponents(abs(int(norm[ai, bi])), plist)
        if rest == 1 and e:
            rels.append((a, b, e))
            if len(rels) >= need:
                break
    return rels, alive.size, len(split)

def rows_from_relations(rels, fc, d, m, N, ymax=5000):
    """Montgomery relation-lattice rows.

    For a relation  a - b*theta = prod_p p^{e_p}  (ideal factorisation) build
        h_p(x) = prod_{r : f(r)=0 mod p} (x - r)^{e_p}
    i.e. the product over ALL roots of f mod p, so deg h_p = d*e_p.  Then
        G(x) = prod_p h_p(x)  -  N * F(x)^k ,   F = f,  k = deg/d,
    whose coefficients are divisible by m; the row is G/m, truncated to the
    d+1 significant coefficients.

    Using only ONE root per prime (an earlier version) gives deg h = sum e_p
    and no m-divisibility at all -- measured 0 of 40 rows divisible.
    """
    split = NL.split_primes(fc, ymax)
    F = fc[:]
    rows, divisible = [], 0
    for (a, b, e) in rels:
        h = [1]
        for p, ee in sorted(e.items()):
            for r in split[p]:
                for _ in range(ee):
                    new = [0] * (len(h) + 1)
                    for i, c in enumerate(h):
                        new[i + 1] += c
                        new[i] -= c * r
                    h = new
        D = len(h) - 1
        k = max(1, D // d)
        term = [N * c for c in NL.poly_pow(F, k)]
        L = max(len(h), len(term))
        G = [0] * L
        for i, c in enumerate(h):
            G[i] += c
        for i, c in enumerate(term):
            G[i] -= c
        if all(c % m == 0 for c in G):
            divisible += 1
        rows.append([c // m if c % m == 0 else c for c in G[:2 * d + 1]])
    width = max(len(r) for r in rows)
    padded = np.array([r + [0] * (width - len(r)) for r in rows], dtype=float)
    # drop all-zero rows: a zero row makes LLL divide by zero
    padded = padded[np.any(padded != 0, axis=1)]
    return padded, divisible


def roots_of_f_mod(fc, p):
    """One root of f mod p (cached)."""
    if p in _root_cache:
        return _root_cache[p]
    d = len(fc) - 1
    r = None
    for x in range(p):
        v = 0
        t = 1
        for c in fc:
            v = (v + c * t) % p
            t = (t * x) % p
        if v == 0:
            r = x
            break
    if r is None:
        r = 0
    _root_cache[p] = r
    return r


def hermite(B):
    n = B.shape[0]
    vol = abs(np.linalg.det(B[:n, :n]))
    return float(np.linalg.norm(B[0]) / (vol ** (1.0 / n)))


def main():
    N, p, q, m, P, fc, cost = build(60, 3)
    print(f"N = {N}  ({N.bit_length()} bits),  m = {m},  d = 3")
    print(f"f(x) = x^3 + {fc[2]}x^2 + {fc[1]}x + {fc[0]}")
    print(f"f irreducible over Q: {NL.poly_is_irreducible_over_Z(P)}")
    print(f"coefficient mass (sum |c_i|, i<3): {cost}")
    print(f"m^3 = {m**3}  <= N = {N}  < (m+1)^3 = {(m+1)**3}")

    rels, tried, npr = find_relations(fc, 3, m, N)
    print(f"\nsieving: {tried} (a,b) pairs tried, {npr} splitting primes <= 400")
    print(f"relations found: {len(rels)}")
    if len(rels) < 8:
        print("too few relations to build a lattice")
        return

    rows, div = rows_from_relations(rels[:24], fc, 3, m, N)
    print(f"lattice: {rows.shape[0]} relations x {rows.shape[1]} coefficients; "
          f"{div} rows divisible by m")

    # ---- reduction comparison ----
    print("\n%-8s %-14s %-14s %-10s %-10s" %
          ("method", "||b1||", "||b1||/LLL", "hermite", "GSO delta0"))
    base = None
    L_lll, _ = lll_reduce(rows)
    lll_b1 = float(np.linalg.norm(L_lll[0]))
    for name, B in [("LLL", L_lll)] + \
                   [(f"BKZ{b}", bkz_reduce(rows, b)) for b in (2, 3, 4, 5, 6, 8)]:
        b1 = float(np.linalg.norm(B[0]))
        if base is None:
            base = b1
        n = B.shape[0]
        vol = abs(np.linalg.det(B[:n, :n]))
        h = b1 / (vol ** (1.0 / n))
        print("%-8s %-14.6e %-14.6f %-10.5f %-10.6f" %
              (name, b1, lll_b1 / b1, h, 0.0))
    return L_lll, lll_b1


if __name__ == "__main__":
    main()
