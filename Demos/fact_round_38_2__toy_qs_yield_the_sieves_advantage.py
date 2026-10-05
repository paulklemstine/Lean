#!/usr/bin/env python3
"""
A toy quadratic sieve, taken apart: numerical companion to
"The Sieve's Advantage Is the Survivor Filter".

Self-contained (standard library only).  Every function is inlined.
Sections:
  1. Sieve lines modulo prime powers (Hensel lifting): exactly 2 or 0 lines.
  2. The 2-adic cap: N = 7 (mod 8) means no value x^2 - N is divisible by 4.
  3. The log threshold as an exact filter; the first-power bug loses
     every non-squarefree smooth value.
  4. The work count: trial divisions vs. log-additions (survivor filter).
  5. The effective-u shift from the quadratic-residue restriction.
  6. From relations to a factor: GF(2) elimination, congruence of squares,
     gcd extraction, and the CRT coin flip (4 roots, 2 useful).
"""
from __future__ import annotations

import math
from typing import Dict, List, Optional, Tuple

N_TOY: int = 103764863  # = 9127 * 11369


# ----------------------------------------------------------------------------
# Elementary number theory
# ----------------------------------------------------------------------------
def primes_up_to(n: int) -> List[int]:
    """Sieve of Eratosthenes."""
    if n < 2:
        return []
    is_p = bytearray([1]) * (n + 1)
    is_p[0] = is_p[1] = 0
    for i in range(2, math.isqrt(n) + 1):
        if is_p[i]:
            is_p[i * i :: i] = bytearray(len(is_p[i * i :: i]))
    return [i for i in range(n + 1) if is_p[i]]


def legendre(a: int, p: int) -> int:
    """Legendre symbol (a | p) for an odd prime p, via Euler's criterion."""
    t = pow(a % p, (p - 1) // 2, p)
    return -1 if t == p - 1 else t


def sqrt_mod_prime(a: int, p: int) -> Optional[int]:
    """A square root of a modulo the odd prime p (brute force; p is small)."""
    a %= p
    for x in range(p):
        if x * x % p == a:
            return x
    return None


def hensel_roots(N: int, p: int, k: int) -> List[int]:
    """All roots of x^2 = N (mod p^k), p odd, p not dividing N.
    Lifts each root mod p step by step: y = x - (x^2 - N) * (2x)^{-1} mod p^{j+1}."""
    r = sqrt_mod_prime(N, p)
    if r is None:
        return []
    roots = sorted({r, (-r) % p})
    mod = p
    for _ in range(1, k):
        new_mod = mod * p
        lifted = []
        for x in roots:
            inv = pow(2 * x, -1, new_mod)
            y = (x - (x * x - N) * inv) % new_mod
            lifted.append(y)
        roots = sorted(set(lifted))
        mod = new_mod
    return roots


def brute_root_count(N: int, m: int) -> int:
    """Number of residues x mod m with x^2 = N (mod m)."""
    return sum(1 for x in range(m) if (x * x - N) % m == 0)


def factorize_small(v: int, primes: List[int]) -> Tuple[Dict[int, int], int]:
    """Trial-divide v by the given primes; return exponents and cofactor."""
    e: Dict[int, int] = {}
    for p in primes:
        while v % p == 0:
            v //= p
            e[p] = e.get(p, 0) + 1
    return e, v


# ----------------------------------------------------------------------------
# 1. Hensel lines
# ----------------------------------------------------------------------------
def section_hensel(N: int) -> None:
    print("=" * 72)
    print("1. Sieve lines modulo prime powers p^k  (N = %d)" % N)
    print("=" * 72)
    print(" p  (N|p)   #roots mod p, p^2, p^3   (Hensel)   (brute force)")
    for p in [3, 5, 7, 11, 13, 17, 19, 23]:
        if N % p == 0:
            continue
        hens = [len(hensel_roots(N, p, k)) for k in (1, 2, 3)]
        brute = [brute_root_count(N, p ** k) for k in (1, 2, 3)]
        print("%3d   %+d       %-22s %-12s %s" % (p, legendre(N, p), "", hens, brute))
        assert hens == brute
        assert hens == ([2, 2, 2] if legendre(N, p) == 1 else [0, 0, 0])
    print("Theorem check: exactly 2 lines at every level for residues, 0 for non-residues.\n")


# ----------------------------------------------------------------------------
# 2. The prime 2
# ----------------------------------------------------------------------------
def section_two_adic(N: int) -> None:
    print("=" * 72)
    print("2. The 2-adic cap")
    print("=" * 72)
    print("N mod 8 = %d" % (N % 8))
    s = math.isqrt(N) + 1
    max_v2 = 0
    for x in range(s, s + 200000):
        v = x * x - N
        t = 0
        while v % 2 == 0:
            v //= 2
            t += 1
        max_v2 = max(max_v2, t)
    print("max 2-adic valuation of x^2 - N over 200000 consecutive x: %d" % max_v2)
    print("(An odd square is 1 mod 8; N = 3 mod 4 forbids 4 | x^2 - N.)\n")
    assert N % 4 != 3 or max_v2 <= 1


# ----------------------------------------------------------------------------
# 3 & 4. The toy sieve: exact filter, first-power bug, work count
# ----------------------------------------------------------------------------
def admissible_factor_base(N: int, B: int) -> List[int]:
    """Primes p <= B that can divide some x^2 - N: p = 2 (N odd) or (N|p) = +1."""
    fb: List[int] = []
    for p in primes_up_to(B):
        if p == 2:
            fb.append(2)
        elif N % p == 0 or legendre(N, p) == 1:
            fb.append(p)
    return fb


def log_sieve(N: int, a: int, M: int, fb: List[int], K: int) -> Tuple[List[float], int]:
    """Log sieve over x in [a, a+M): add log p at every hit of a line mod p^j, j <= K.
    Returns accumulators and the number of log-additions performed."""
    acc = [0.0] * M
    adds = 0
    for p in fb:
        lp = math.log(p)
        for j in range(1, K + 1):
            pj = p ** j
            if pj > (a + M) ** 2:
                break
            if p == 2:
                roots = [x for x in range(pj) if (x * x - N) % pj == 0]
            else:
                roots = hensel_roots(N, p, j)
            if not roots:
                break
            for r in roots:
                start = (r - a) % pj
                for i in range(start, M, pj):
                    acc[i] += lp
                    adds += 1
    return acc, adds


def section_sieve(N: int, B: int, M: int) -> List[Tuple[int, Dict[int, int]]]:
    print("=" * 72)
    print("3/4. Toy sieve over M = %d values above sqrt(N), B = %d" % (M, B))
    print("=" * 72)
    fb = admissible_factor_base(N, B)
    all_primes = primes_up_to(B)
    print("all primes <= B: %d     admissible (QR-restricted) primes: %d" % (len(all_primes), len(fb)))
    print("factor base:", fb)
    a = math.isqrt(N) + 1

    # Ground truth by trial division over ALL primes <= B (the naive method).
    divisions = 0
    truth: List[Tuple[int, Dict[int, int]]] = []
    for i in range(M):
        x = a + i
        v = x * x - N
        e, cof = {}, v
        for p in all_primes:
            divisions += 1
            while cof % p == 0:
                cof //= p
                divisions += 1
                e[p] = e.get(p, 0) + 1
        if cof == 1:
            truth.append((x, e))
    print("trial division: %d divisions (%.1f per value); smooth values: %d"
          % (divisions, divisions / M, len(truth)))
    # Every prime that ever appears is admissible: p | x^2 - N forces (N|p)=+1.
    used = {p for _, e in truth for p in e}
    assert used <= set(fb)
    print("primes actually used by relations are all admissible:", sorted(used))

    def run(K: int) -> Tuple[List[int], int]:
        acc, adds = log_sieve(N, a, M, fb, K)
        surv = [a + i for i in range(M)
                if abs(acc[i] - math.log((a + i) ** 2 - N)) < 1e-6]
        return surv, adds

    Kfull = int(math.log2((a + M) ** 2 - N)) + 1
    surv_full, adds_full = run(Kfull)
    surv_one, adds_one = run(1)
    truth_x = [x for x, _ in truth]
    sqf = [x for x, e in truth if all(c == 1 for c in e.values())]
    print("full sieve (K = %d): %d survivors, %d log-adds (%.2f per value)"
          % (Kfull, len(surv_full), adds_full, adds_full / M))
    print("  survivors == trial-division smooth set?", surv_full == truth_x)
    print("first-power sieve (K = 1): %d survivors" % len(surv_one))
    print("  survivors == squarefree smooth set?    ", surv_one == sqf)
    lost = 1 - len(surv_one) / max(1, len(truth_x))
    print("  fraction of relations lost by the first-power bug: %.1f%%" % (100 * lost))
    assert surv_full == truth_x and surv_one == sqf

    # Survivor-filter cost: additions + trial division of survivors only.
    surv_div = 0
    for x in surv_full:
        _, _ = factorize_small(x * x - N, fb)
        surv_div += len(fb)
    cost_sieve = adds_full + surv_div
    print("sieve cost = %d adds + %d survivor divisions = %d"
          % (adds_full, surv_div, cost_sieve))
    print("advantage (naive divisions / sieve operations) = %.2fx\n" % (divisions / cost_sieve))
    return truth


# ----------------------------------------------------------------------------
# 5. Effective u
# ----------------------------------------------------------------------------
def dickman_rho(u: float, h: float = 1e-3) -> float:
    """Dickman rho by Euler integration of u rho'(u) = -rho(u-1)."""
    if u <= 1:
        return 1.0
    n1 = int(round(1 / h))
    vals = [1.0] * (n1 + 1)
    n = int(round(u / h))
    for i in range(n1 + 1, n + 1):
        t = i * h
        vals.append(vals[-1] - h * vals[i - n1 - 1] / t)
    return vals[n]


def section_effective_u() -> None:
    print("=" * 72)
    print("5. Effective u from the quadratic-residue restriction")
    print("=" * 72)
    print("    B       v        u     factor lnB/(lnB-ln2)   u_eff   rho(u_eff)/rho(u)")
    for B, v in [(60, 10 ** 7), (500, 10 ** 8), (2000, 10 ** 10), (10 ** 4, 10 ** 12)]:
        u = math.log(v) / math.log(B)
        f = math.log(B) / (math.log(B) - math.log(2))
        ueff = math.log(v) / math.log(B / 2)
        assert abs(ueff - u * f) < 1e-12 and ueff > u
        print("%6d  %8.0e  %6.3f   %10.4f            %6.3f   %6.3f"
              % (B, v, u, f, ueff, dickman_rho(ueff) / dickman_rho(u)))
    print("Identity ln v / ln(B/2) = u * lnB/(lnB - ln2) holds; the ratio < 1\n"
          "is the predicted yield shrinkage relative to the plain rho(u) model.\n")


# ----------------------------------------------------------------------------
# 6. Linear algebra over GF(2) and the congruence of squares
# ----------------------------------------------------------------------------
def gf2_dependencies(vectors: List[int], n_rows: int) -> List[int]:
    """Gaussian elimination over GF(2).  vectors[i] is a bitmask of exponent
    parities.  Returns dependencies as bitmasks over relation indices."""
    pivots: Dict[int, Tuple[int, int]] = {}
    deps: List[int] = []
    for i, v in enumerate(vectors):
        comb = 1 << i
        for bit in range(n_rows - 1, -1, -1):
            if not (v >> bit) & 1:
                continue
            if bit in pivots:
                pv, pc = pivots[bit]
                v ^= pv
                comb ^= pc
            else:
                pivots[bit] = (v, comb)
                break
        if v == 0:
            deps.append(comb)
    return deps


def section_factor(N: int, relations: List[Tuple[int, Dict[int, int]]]) -> None:
    print("=" * 72)
    print("6. From relations to a factor")
    print("=" * 72)
    # (a) The certificate quoted in the paper.
    cert = [10248, 10342, 10749, 18185]
    vals = [x * x - N for x in cert]
    prod_v = math.prod(vals)
    Y = math.isqrt(prod_v)
    X = math.prod(cert)
    assert Y * Y == prod_v
    print("certificate abscissae:", cert)
    for x, v in zip(cert, vals):
        print("  %5d^2 - N = %9d = %s" % (x, v, factorize_small(v, primes_up_to(60))[0]))
    print("product of values = Y^2 with Y =", Y)
    print("X = prod x_i =", X, ";  N | X^2 - Y^2 ?", (X * X - Y * Y) % N == 0)
    g = math.gcd(X - Y, N)
    print("gcd(X - Y, N) =", g, "  N / g =", N // g)
    assert g == 9127 and N // g == 11369
    tri = [10342, 10749, 18185]
    Xt = math.prod(tri)
    Yt = math.isqrt(math.prod(x * x - N for x in tri))
    print("3-relation dependency: Y =", Yt, " (X - Y) mod N =", (Xt - Yt) % N, "-> trivial")

    # (b) Live: GF(2) elimination on the relations collected in section 3.
    fb = sorted({p for _, e in relations for p in e})
    idx = {p: j for j, p in enumerate(fb)}
    vecs = []
    for _, e in relations:
        m = 0
        for p, c in e.items():
            if c % 2:
                m |= 1 << idx[p]
        vecs.append(m)
    deps = gf2_dependencies(vecs, len(fb))
    print("\nlive run: %d relations over %d primes -> %d dependencies"
          % (len(relations), len(fb), len(deps)))
    useful = 0
    for d in deps:
        xs = [relations[i][0] for i in range(len(relations)) if (d >> i) & 1]
        Xd = math.prod(xs) % N
        Yd = math.isqrt(math.prod(x * x - N for x in xs)) % N
        g = math.gcd(Xd - Yd, N)
        if 1 < g < N:
            useful += 1
    if deps:
        print("dependencies giving a proper factor: %d / %d  (CRT predicts ~1/2)"
              % (useful, len(deps)))

    # (c) The CRT coin flip: four square roots, two useful.
    p, q = 9127, 11369
    y = 123456 % N
    s = (y * y) % N
    roots_p = [y % p, (-y) % p]
    roots_q = [y % q, (-y) % q]
    roots = sorted({(a * q * pow(q, -1, p) + b * p * pow(p, -1, q)) % N
                    for a in roots_p for b in roots_q})
    print("\nsquare roots of y^2 mod N for y = %d:" % y)
    for r in roots:
        tag = "trivial (+-y)" if r in (y, (-y) % N) else "useful: gcd = %d" % math.gcd(r - y, N)
        assert r * r % N == s
        print("  %9d   %s" % (r, tag))
    assert len(roots) == 4


def main() -> None:
    section_hensel(N_TOY)
    section_two_adic(N_TOY)
    rels = section_sieve(N_TOY, B=60, M=60000)
    section_effective_u()
    section_factor(N_TOY, rels)


if __name__ == "__main__":
    main()
