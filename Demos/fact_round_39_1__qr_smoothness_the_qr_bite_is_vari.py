#!/usr/bin/env python3
"""
QR-smoothness: the quadratic-residue bite is variance, not mean.

Self-contained numerical companion.  Sections:

  1. Local root counts r_M(N) = #{x mod M : x^2 = N (mod M)}  for small moduli.
  2. Exact mean / variance identities over the units N mod M:
        sum r_M(N) = phi(M),   sum (r_M(N) - 1)^2 = phi(M) (2^k - 1),
     and the all-or-nothing law r_M(N) in {0, 2^k}.
  3. The local law r_p(N) = 1 + (N|p) (Euler's criterion) and CRT multiplicativity.
  4. The two-prime Euler score a r_p + b r_q: mean a + b, variance a^2 + b^2.
  5. A small Monte Carlo smoothness experiment: x^2 - N versus unrestricted random
     integers of the same size versus random integers smooth over only the QR half
     of the factor base, plus the per-N spread and its correlation with the number
     of small primes that are quadratic residues of N.

Only the Python standard library is used.
"""
from __future__ import annotations

import math
import random
from itertools import combinations
from typing import Dict, List, Sequence, Tuple


# ----------------------------------------------------------------------------
# Elementary number theory helpers
# ----------------------------------------------------------------------------

def primes_up_to(n: int) -> List[int]:
    """Sieve of Eratosthenes."""
    if n < 2:
        return []
    is_p = bytearray([1]) * (n + 1)
    is_p[0] = is_p[1] = 0
    for i in range(2, int(n ** 0.5) + 1):
        if is_p[i]:
            is_p[i * i:: i] = bytearray(len(is_p[i * i:: i]))
    return [i for i in range(n + 1) if is_p[i]]


def phi(m: int) -> int:
    """Euler's totient by trial factorisation."""
    result, n, p = m, m, 2
    while p * p <= n:
        if n % p == 0:
            while n % p == 0:
                n //= p
            result -= result // p
        p += 1
    if n > 1:
        result -= result // n
    return result


def legendre(a: int, p: int) -> int:
    """Legendre symbol (a|p) for an odd prime p, via Euler's criterion."""
    a %= p
    if a == 0:
        return 0
    return 1 if pow(a, (p - 1) // 2, p) == 1 else -1


def root_count(n: int, m: int) -> int:
    """r_m(n) = number of x mod m with x^2 = n (mod m)  (brute force)."""
    n %= m
    return sum(1 for x in range(m) if (x * x - n) % m == 0)


def units(m: int) -> List[int]:
    return [a for a in range(1, m) if math.gcd(a, m) == 1] if m > 1 else [0]


# ----------------------------------------------------------------------------
# Sections 1-4: exact identities
# ----------------------------------------------------------------------------

def table_for_modulus(m: int) -> Dict[int, int]:
    return {n: root_count(n, m) for n in units(m)}


def check_mean_variance(primes: Sequence[int]) -> Tuple[int, int, int, int, int, int]:
    """Return (M, phi, sum r, sum (r-1)^2, predicted variance total, #support)."""
    m = math.prod(primes)
    k = len(primes)
    tab = table_for_modulus(m)
    s1 = sum(tab.values())
    s2 = sum((r - 1) ** 2 for r in tab.values())
    assert set(tab.values()) <= {0, 2 ** k}, "all-or-nothing law violated"
    support = sum(1 for r in tab.values() if r)
    return m, phi(m), s1, s2, phi(m) * (2 ** k - 1), support


def section_exact() -> None:
    print("=" * 72)
    print("1. Local root counts at p = 7 (N = 1..6)")
    print("=" * 72)
    tab7 = table_for_modulus(7)
    print("   N      :", " ".join(f"{n:2d}" for n in tab7))
    print("   r_7(N) :", " ".join(f"{r:2d}" for r in tab7.values()))
    print("   (N|7)  :", " ".join(f"{legendre(n, 7):2d}" for n in tab7))
    print(f"   sum r = {sum(tab7.values())} = p - 1,  "
          f"sum (r-1)^2 = {sum((r - 1) ** 2 for r in tab7.values())} = p - 1")

    print()
    print("=" * 72)
    print("2. Mean compensation and exponential variance, M = p1...pk")
    print("=" * 72)
    print(f"   {'primes':<16}{'M':>7}{'phi':>7}{'sum r':>8}{'sum(r-1)^2':>12}"
          f"{'phi(2^k-1)':>12}{'#support':>10}{'phi/2^k':>9}")
    odd = [3, 5, 7, 11, 13]
    for k in range(1, 5):
        for ps in list(combinations(odd, k))[:2]:
            m, ph, s1, s2, pred, sup = check_mean_variance(ps)
            assert s1 == ph and s2 == pred and sup * 2 ** k == ph
            print(f"   {str(ps):<16}{m:>7}{ph:>7}{s1:>8}{s2:>12}{pred:>12}{sup:>10}"
                  f"{ph // 2 ** k:>9}")
    print("   -> mean of r_M is exactly 1 for every k; variance is 2^k - 1.")

    print()
    print("=" * 72)
    print("3. Local law r_p(N) = 1 + (N|p) and CRT multiplicativity")
    print("=" * 72)
    for p in primes_up_to(60)[1:]:
        assert all(root_count(n, p) == 1 + legendre(n, p) for n in range(1, p))
    print("   r_p(N) = 1 + (N|p) checked for all odd p < 60 and all N prime to p.")
    for m, n in [(3, 5), (5, 7), (7, 11), (9, 5), (15, 7)]:
        assert all(root_count(a, m * n) == root_count(a, m) * root_count(a, n)
                   for a in units(m * n))
    print("   r_mn = r_m * r_n checked for coprime (m, n) in "
          "{(3,5),(5,7),(7,11),(9,5),(15,7)}.")

    print()
    print("=" * 72)
    print("4. Two-prime Euler score S(N) = a r_p(N) + b r_q(N) over N mod pq")
    print("=" * 72)
    for (p, q, a, b) in [(3, 5, 1, 1), (7, 11, 2, -1), (13, 17, 3, 5)]:
        us = units(p * q)
        scores = [a * root_count(u, p) + b * root_count(u, q) for u in us]
        tot = sum(scores)
        dev2 = sum((s - (a + b)) ** 2 for s in scores)
        cross = sum((root_count(u, p) - 1) * (root_count(u, q) - 1) for u in us)
        ph = phi(p * q)
        assert tot == ph * (a + b) and dev2 == ph * (a * a + b * b) and cross == 0
        print(f"   p={p:2d} q={q:2d} a={a:2d} b={b:2d}:  mean = {tot / ph:.3f} (a+b={a + b}),"
              f"  variance = {dev2 / ph:.3f} (a^2+b^2={a * a + b * b}),  covariance = {cross}")


# ----------------------------------------------------------------------------
# Section 5: Monte Carlo smoothness experiment
# ----------------------------------------------------------------------------

def is_smooth(v: int, base: Sequence[int]) -> bool:
    """True iff |v| factors completely over the primes in `base`."""
    v = abs(v)
    if v == 0:
        return False
    for p in base:
        if p * p > v:
            break
        while v % p == 0:
            v //= p
        if v == 1:
            return True
    # remaining cofactor must itself be in the base (it is 1 or a prime)
    return v == 1 or (v <= base[-1] and v in BASE_SET)


BASE_SET: set = set()


def pearson(xs: Sequence[float], ys: Sequence[float]) -> float:
    n = len(xs)
    mx, my = sum(xs) / n, sum(ys) / n
    sxy = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    sxx = sum((x - mx) ** 2 for x in xs)
    syy = sum((y - my) ** 2 for y in ys)
    return sxy / math.sqrt(sxx * syy) if sxx and syy else float("nan")


def section_monte_carlo(seed: int = 20260821, n_count: int = 40,
                        per_n: int = 1500, digits: int = 14, bound: int = 600) -> None:
    global BASE_SET
    rng = random.Random(seed)
    base = primes_up_to(bound)
    BASE_SET = set(base)
    print()
    print("=" * 72)
    print("5. Monte Carlo: x^2 - N vs random integers of the same size")
    print("=" * 72)
    rates_x2: List[float] = []
    rates_rnd: List[float] = []
    rates_half: List[float] = []
    qr_counts: List[int] = []
    small_odd = primes_up_to(100)[1:]
    u_vals: List[float] = []
    for _ in range(n_count):
        n_val = rng.randrange(10 ** (digits - 1), 10 ** digits)
        while math.isqrt(n_val) ** 2 == n_val:
            n_val += 1
        root = math.isqrt(n_val) + 1
        offs = [rng.randrange(0, 4 * per_n) for _ in range(per_n)]
        vals = [(root + t) ** 2 - n_val for t in offs]
        hit = sum(is_smooth(v, base) for v in vals)
        # random integers of identical sizes
        rnd = [rng.randrange(max(2, v // 2), v + v // 2 + 2) for v in vals]
        hit_r = sum(is_smooth(v, base) for v in rnd)
        # random integers smooth over the QR half of the base only
        half = [2] + [p for p in base[1:] if legendre(n_val, p) == 1]
        hit_h = sum(is_smooth(v, half) and all(v % p for p in base if p not in half)
                    for v in rnd)
        rates_x2.append(hit / per_n)
        rates_rnd.append(hit_r / per_n)
        rates_half.append(hit_h / per_n)
        qr_counts.append(sum(1 for p in small_odd if legendre(n_val, p) == 1))
        u_vals.append(sum(math.log(v) for v in vals) / len(vals) / math.log(bound))
    mx2 = sum(rates_x2) / n_count
    mr = sum(rates_rnd) / n_count
    mh = sum(rates_half) / n_count
    print(f"   {n_count} values of N with {digits} digits, {per_n} sieve values each, "
          f"smoothness bound B = {bound}, mean u = {sum(u_vals) / len(u_vals):.2f}")
    print(f"   mean smooth rate, x^2 - N                 : {mx2:.5f}")
    print(f"   mean smooth rate, unrestricted random     : {mr:.5f}   ratio {mx2 / mr:.2f}")
    print(f"   mean smooth rate, QR-half-base random     : {mh:.5f}   "
          f"ratio {mx2 / mh if mh else float('inf'):.1f}x lower")
    srt = sorted(rates_x2)
    dec = max(1, n_count // 10)
    lo, hi = sum(srt[:dec]) / dec, sum(srt[-dec:]) / dec
    print(f"   per-N spread (top decile / bottom decile)  : "
          f"{hi / lo if lo else float('inf'):.1f}x")
    print(f"   corr(per-N rate, #odd primes <= 100 that are QRs of N) = "
          f"{pearson(qr_counts, rates_x2):.2f}")
    print("   (Small-scale illustration; numbers fluctuate with seed and size.)")


if __name__ == "__main__":
    section_exact()
    section_monte_carlo()
