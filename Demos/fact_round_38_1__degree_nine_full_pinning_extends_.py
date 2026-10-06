#!/usr/bin/env python3
"""
Full pinning on the abelian ladder: numerical companion.

This script reproduces, from scratch and with exact enumeration, every number
behind the degree-nine rung K = Q(zeta_19)^+ of the abelian ladder:

  1. the splitting-type density law  P(f = d) = phi(d)/m  on every rung;
  2. the exact entropy H(T) = (4/3) log2 3 - 8/9 = 1.22439... bits at degree 9;
  3. full pinning  I(p mod l ; T) = H(T)  (the type is a function of the residue);
  4. the fixed-root dichotomy: the root count determines the type iff m is 1 or prime;
  5. a polynomial cross-check: factor-degree patterns of the minimal polynomial of
     2cos(2 pi/19) over GF(p) agree with the predicted type for real primes p;
  6. the semiprime laws: the which-factor extra is exactly 0 and the split-count
     projection equals I_s(n) + eta(1/n^2) + eta(2(n-1)/n^2) - eta((2n-1)/n^2);
  7. additivity of the totient entropy over coprime degrees.

Only the Python standard library is used.  Run:  python3 demo.py
"""
from __future__ import annotations

import cmath
import math
import random
from collections import Counter
from fractions import Fraction
from typing import Dict, Hashable, Iterable, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# Elementary number theory
# ----------------------------------------------------------------------------


def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test (fine for the sizes used here)."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    r = int(math.isqrt(n))
    for k in range(3, r + 1, 2):
        if n % k == 0:
            return False
    return True


def primes_up_to(n: int) -> List[int]:
    """Sieve of Eratosthenes."""
    sieve = bytearray([1]) * (n + 1)
    sieve[0:2] = b"\x00\x00"
    for i in range(2, int(math.isqrt(n)) + 1):
        if sieve[i]:
            sieve[i * i :: i] = bytearray(len(sieve[i * i :: i]))
    return [i for i in range(n + 1) if sieve[i]]


def divisors(n: int) -> List[int]:
    return [d for d in range(1, n + 1) if n % d == 0]


def totient(n: int) -> int:
    result, m, p = n, n, 2
    while p * p <= m:
        if m % p == 0:
            while m % p == 0:
                m //= p
            result -= result // p
        p += 1
    if m > 1:
        result -= result // m
    return result


def mult_order(a: int, mod: int) -> int:
    """Multiplicative order of a modulo mod (gcd(a, mod) = 1 assumed)."""
    a %= mod
    k, x = 1, a
    while x != 1:
        x = x * a % mod
        k += 1
    return k


def splitting_type(p: int, ell: int) -> int:
    """Residue degree of p in Q(zeta_ell)^+ : the order of p^2 in (Z/ell)^x,
    equivalently the order of p in (Z/ell)^x / {+1, -1}."""
    return mult_order(p * p % ell, ell)


# ----------------------------------------------------------------------------
# Information theory on finite uniform sample spaces (in bits)
# ----------------------------------------------------------------------------


def entropy(probs: Iterable[float]) -> float:
    return max(0.0, -sum(q * math.log2(q) for q in probs if q > 0))


def eta(x: float) -> float:
    """eta(x) = -x log2 x."""
    return 0.0 if x <= 0 else -x * math.log2(x)


def entropy_of(values: Sequence[Hashable]) -> float:
    n = len(values)
    return entropy(c / n for c in Counter(values).values())


def mutual_info(xs: Sequence[Hashable], ys: Sequence[Hashable]) -> float:
    """I(X;Y) = H(X) + H(Y) - H(X,Y) for the uniform measure on the index set."""
    return entropy_of(xs) + entropy_of(ys) - entropy_of(list(zip(xs, ys)))


def totient_entropy(m: int) -> float:
    """H_phi(m) = sum_{d | m} eta(phi(d)/m), in bits."""
    return sum(eta(totient(d) / m) for d in divisors(m))


# ----------------------------------------------------------------------------
# Polynomial arithmetic over GF(p)  (coefficient lists, lowest degree first)
# ----------------------------------------------------------------------------

Poly = List[int]


def ptrim(a: Poly) -> Poly:
    while a and a[-1] == 0:
        a.pop()
    return a


def pmod(a: Poly, b: Poly, p: int) -> Poly:
    a = [c % p for c in a]
    ptrim(a)
    b = ptrim([c % p for c in b])
    inv = pow(b[-1], p - 2, p)
    while len(a) >= len(b):
        coef = a[-1] * inv % p
        shift = len(a) - len(b)
        for i, c in enumerate(b):
            a[shift + i] = (a[shift + i] - coef * c) % p
        ptrim(a)
    return a


def pmul(a: Poly, b: Poly, p: int) -> Poly:
    if not a or not b:
        return []
    out = [0] * (len(a) + len(b) - 1)
    for i, x in enumerate(a):
        if x:
            for j, y in enumerate(b):
                out[i + j] = (out[i + j] + x * y) % p
    return ptrim(out)


def psub(a: Poly, b: Poly, p: int) -> Poly:
    n = max(len(a), len(b))
    out = [((a[i] if i < len(a) else 0) - (b[i] if i < len(b) else 0)) % p for i in range(n)]
    return ptrim(out)


def pgcd(a: Poly, b: Poly, p: int) -> Poly:
    a = ptrim([c % p for c in a])
    b = ptrim([c % p for c in b])
    while b:
        a, b = b, pmod(a, b, p)
    inv = pow(a[-1], p - 2, p)
    return [c * inv % p for c in a]


def pdiv_exact(a: Poly, b: Poly, p: int) -> Poly:
    a = ptrim([c % p for c in a])
    b = ptrim([c % p for c in b])
    inv = pow(b[-1], p - 2, p)
    q = [0] * (len(a) - len(b) + 1)
    while len(a) >= len(b) and a:
        coef = a[-1] * inv % p
        shift = len(a) - len(b)
        q[shift] = coef
        for i, c in enumerate(b):
            a[shift + i] = (a[shift + i] - coef * c) % p
        ptrim(a)
    return ptrim(q)


def ppowmod(base: Poly, e: int, mod: Poly, p: int) -> Poly:
    result: Poly = [1]
    base = pmod(base, mod, p)
    while e:
        if e & 1:
            result = pmod(pmul(result, base, p), mod, p)
        base = pmod(pmul(base, base, p), mod, p)
        e >>= 1
    return result


def factor_degree_pattern(f: Poly, p: int) -> List[int]:
    """Distinct-degree factorisation of a squarefree f over GF(p); returns the sorted
    multiset of degrees of its irreducible factors (the 'factor pattern')."""
    f = ptrim([c % p for c in f])
    pattern: List[int] = []
    k = 0
    xpow: Poly = [0, 1]  # x^{p^k} mod f
    while len(f) - 1 > 0:
        k += 1
        if 2 * k > len(f) - 1:
            pattern.append(len(f) - 1)
            break
        xpow = ppowmod(xpow, p, f, p)
        g = pgcd(f, psub(xpow, [0, 1], p), p)
        dg = len(g) - 1
        if dg > 0:
            pattern += [k] * (dg // k)
            f = pdiv_exact(f, g, p)
            xpow = pmod(xpow, f, p)
    return sorted(pattern)


def minimal_poly_2cos(ell: int) -> Poly:
    """Integer minimal polynomial of 2cos(2 pi/ell), ell an odd prime (degree (ell-1)/2),
    computed from its numerical roots 2cos(2 pi k/ell), k = 1..(ell-1)/2, then rounded."""
    m = (ell - 1) // 2
    coeffs: List[complex] = [1.0]
    for k in range(1, m + 1):
        r = 2 * math.cos(2 * math.pi * k / ell)
        new = [0j] * (len(coeffs) + 1)
        for i, c in enumerate(coeffs):
            new[i + 1] += c
            new[i] -= r * c
        coeffs = new
    return [int(round(c.real)) for c in coeffs]


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------


def demo_density_law(ell: int) -> None:
    m = (ell - 1) // 2
    types = [splitting_type(u, ell) for u in range(1, ell)]
    counts = Counter(types)
    print(f"  l = {ell:3d}, degree m = {m:2d}: ", end="")
    ok = all(counts.get(d, 0) == 2 * totient(d) for d in divisors(m)) and set(counts) <= set(divisors(m))
    print("  ".join(f"P(f={d})={Fraction(counts.get(d, 0), ell - 1)}" for d in divisors(m)),
          " [law 2*phi(d) holds]" if ok else " [LAW FAILS]")


def demo_degree_nine_entropy() -> Tuple[float, float]:
    types = [splitting_type(u, 19) for u in range(1, 19)]
    residues = list(range(1, 19))
    h_t = entropy_of(types)
    exact = 4 / 3 * math.log2(3) - 8 / 9
    i_full = mutual_info(residues, types)
    i_square = mutual_info([u * u % 19 for u in residues], types)
    print(f"  H(T)                         = {h_t:.10f} bits")
    print(f"  (4/3)log2(3) - 8/9           = {exact:.10f} bits")
    print(f"  I(p mod 19 ; T)              = {i_full:.10f} bits   (full pinning)")
    print(f"  I(p^2 mod 19 ; T)            = {i_square:.10f} bits   (the sign is pure thickening)")
    print(f"  certified window 1.22439 < H < 1.22441 : {1.22439 < exact < 1.22441}")
    return h_t, exact


def demo_chebotarev_sample(limit: int = 4_200_000) -> None:
    """Empirical type frequencies over real primes (the uniform model is Chebotarev's)."""
    ps = [p for p in primes_up_to(limit) if p != 19]
    counts = Counter(splitting_type(p, 19) for p in ps)
    n = len(ps)
    print(f"  {n} primes p < {limit} (p != 19):")
    for d, pred in [(1, 1 / 9), (3, 2 / 9), (9, 6 / 9)]:
        print(f"    f = {d}: observed {counts[d] / n:.5f}   predicted {pred:.5f}   gap {abs(counts[d] / n - pred):.1e}")
    obs_h = entropy(c / n for c in counts.values())
    print(f"  empirical H(T) = {obs_h:.5f} bits; empirical I(p mod 19; T) = "
          f"{mutual_info([p % 19 for p in ps], [splitting_type(p, 19) for p in ps]):.5f} bits")


def demo_polynomial_crosscheck(n_primes: int = 400, seed: int = 20260821) -> None:
    f = minimal_poly_2cos(19)
    print(f"  minimal polynomial of 2cos(2pi/19), coefficients (low->high): {f}")
    rng = random.Random(seed)
    pool = [p for p in primes_up_to(200_000) if p != 19]
    sample = rng.sample(pool, n_primes)
    agree_pattern = 0
    nr_ambiguous = Counter()
    for p in sample:
        d = splitting_type(p, 19)
        pattern = factor_degree_pattern(f, p)
        if pattern == [d] * (9 // d):
            agree_pattern += 1
        nr = pattern.count(1)
        nr_ambiguous[(nr, d)] += 1
    print(f"  factor-degree pattern equals [f^(9/f)] for {agree_pattern}/{n_primes} random primes")
    print("  (root count, type) pairs observed:", dict(sorted(nr_ambiguous.items())))
    print("  -> root count 0 occurs with both f = 3 and f = 9: the root count is lossy,")
    print("     the factor pattern is not.")


def demo_fixed_root_dichotomy(max_m: int = 20) -> None:
    print("   m   H(type)   H(root count)   root count determines type?   m is 1 or prime?")
    for m in range(1, max_m + 1):
        n = 2 * m  # work in the cyclic group Z/2m written additively; g^2 <-> 2g
        types = [ (n // math.gcd(2 * g % n, n)) if (2 * g) % n else 1 for g in range(n)]
        roots = [1 if (2 * g) % n == 0 else 0 for g in range(n)]
        h_t = entropy_of(types)
        h_r = entropy_of(roots)
        det = abs(mutual_info(roots, types) - h_t) < 1e-12
        print(f"  {m:2d}   {h_t:7.4f}   {h_r:12.4f}   {str(det):>26}   {str(m == 1 or is_prime(m)):>15}")


def demo_semiprime(ell: int = 19) -> None:
    res = range(1, ell)
    T = {u: splitting_type(u, ell) for u in res}
    pairs = [(u, v) for u in res for v in res]
    N = [u * v % ell for u, v in pairs]
    ordered = [(T[u], T[v]) for u, v in pairs]
    unordered = [tuple(sorted(t)) for t in ordered]
    i_ord = mutual_info(N, ordered)
    i_uno = mutual_info(N, unordered)
    print(f"  I(N mod {ell} ; unordered type pair) = {i_uno:.5f} bits")
    print(f"  I(N mod {ell} ; ordered type pair)   = {i_ord:.5f} bits")
    print(f"  which-factor extra                 = {i_ord - i_uno:+.2e} bits (exactly 0)")

    # split-count law in C_n with n = (ell-1)/2 and in (Z/ell)^x
    n = (ell - 1) // 2
    split = [int(T[u] == 1) + int(T[v] == 1) for u, v in pairs]
    i_count_ell = mutual_info(N, split)
    Cn = [(a, b) for a in range(n) for b in range(n)]
    Nn = [(a + b) % n for a, b in Cn]
    count_n = [int(a == 0) + int(b == 0) for a, b in Cn]
    orfork = [int(a == 0 or b == 0) for a, b in Cn]
    i_count_n = mutual_info(Nn, count_n)
    i_or = mutual_info(Nn, orfork)

    def h2(x: float) -> float:
        return eta(x) + eta(1 - x)

    is_closed = h2((2 * n - 1) / n**2) - ((1 / n) * h2(1 / n) + ((n - 1) / n) * h2(2 / n))
    law = is_closed + eta(1 / n**2) + eta(2 * (n - 1) / n**2) - eta((2 * n - 1) / n**2)
    print(f"  OR-dial I_s({n}): enumeration {i_or:.5f}, closed form {is_closed:.5f} bits")
    print(f"  split count: I(N in C_{n}; #split) = {i_count_n:.5f}; in (Z/{ell})^x = {i_count_ell:.5f};"
          f" law = {law:.5f} bits")


def demo_totient_additivity() -> None:
    for m, n in [(2, 3), (3, 5), (2, 9), (4, 9), (5, 8), (7, 9)]:
        lhs = totient_entropy(m * n)
        rhs = totient_entropy(m) + totient_entropy(n)
        print(f"  H_phi({m * n:3d}) = {lhs:.6f}   H_phi({m}) + H_phi({n}) = {rhs:.6f}")
    # the l = 37 rung is one bit above the l = 19 rung
    t37 = [splitting_type(u, 37) for u in range(1, 37)]
    print(f"  H(type in Q(zeta_37)^+) - H(type in Q(zeta_19)^+) = "
          f"{entropy_of(t37) - totient_entropy(9):.10f} bits")
    # non-coprime failure
    print(f"  non-coprime example: H_phi(9) = {totient_entropy(9):.6f} vs 2*H_phi(3) = {2 * totient_entropy(3):.6f}")


def main() -> None:
    print("=" * 78)
    print("1. Splitting-type density law  P(f = d) = phi(d)/m  on the abelian ladder")
    for ell in [5, 7, 11, 13, 17, 19, 37, 41]:
        demo_density_law(ell)
    print("=" * 78)
    print("2-3. Degree nine: exact entropy and full pinning")
    demo_degree_nine_entropy()
    print("=" * 78)
    print("   Chebotarev check over real primes")
    demo_chebotarev_sample()
    print("=" * 78)
    print("4. The fixed-root dichotomy (lossless exactly at m = 1 or m prime)")
    demo_fixed_root_dichotomy()
    print("=" * 78)
    print("5. Polynomial cross-check via factor-degree patterns over GF(p)")
    demo_polynomial_crosscheck()
    print("=" * 78)
    print("6. Semiprimes N = p q")
    demo_semiprime()
    print("=" * 78)
    print("7. Totient entropy is additive over coprime degrees")
    demo_totient_additivity()


if __name__ == "__main__":
    main()
