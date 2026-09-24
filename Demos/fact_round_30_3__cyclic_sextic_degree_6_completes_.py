#!/usr/bin/env python3
"""
The degree-6 rung of the abelian splitting-type ladder: Q(zeta_13)^+.

Numerical companion to "The Ladder Is Complete".  Everything is exact finite
enumeration; logarithms are base 2 (bits).  No third-party packages needed.

Sections
  1. The splitting law of Q(zeta_13)^+ and the rates {1/6, 1/6, 1/3, 1/3}.
  2. The CRT factorisation  T6 = T2 * T3  (quadratic x cubic subfield).
  3. Entropies: H(T6) = 1/3 + log2 3 = H(T2) + H(T3).
  4. Full pinning, the orthogonal split, and independence of T2 and T3.
  5. The semiprime channels: I(pair) = log2 3 - 1/9 and the split channel.
  6. CRT additivity of the type entropy for general coprime orders.
  7. Comparison with the experimentally reported numbers.
  8. A Monte-Carlo check with actual primes (Dirichlet density).
"""
from __future__ import annotations

import random
from collections import Counter, defaultdict
from fractions import Fraction
from math import gcd, log2
from typing import Callable, Hashable, Iterable, Sequence, TypeVar

T = TypeVar("T", bound=Hashable)

# ---------------------------------------------------------------------------
# Generic counting entropy (uniform law on a finite sample set)
# ---------------------------------------------------------------------------


def entropy(values: Sequence[Hashable]) -> float:
    """Shannon entropy (bits) of the empirical law of `values`."""
    n = len(values)
    return -sum((c / n) * log2(c / n) for c in Counter(values).values())


def cond_entropy(xs: Sequence[Hashable], ys: Sequence[Hashable]) -> float:
    """H(X | Y) for paired samples under the uniform law."""
    groups: dict[Hashable, list[Hashable]] = defaultdict(list)
    for x, y in zip(xs, ys):
        groups[y].append(x)
    n = len(xs)
    return sum(len(g) / n * entropy(g) for g in groups.values())


def mutual_info(xs: Sequence[Hashable], ys: Sequence[Hashable]) -> float:
    """I(X ; Y) = H(X) - H(X | Y)."""
    return entropy(xs) - cond_entropy(xs, ys)


# ---------------------------------------------------------------------------
# 1. The splitting law of Q(zeta_13)^+
# ---------------------------------------------------------------------------

F = 13
UNITS: list[int] = list(range(1, F))  # (Z/13)^x


def real_degree(u: int, f: int = F) -> int:
    """Order of u in (Z/f)^x / {+-1}: the residue degree in Q(zeta_f)^+."""
    k, x = 1, u % f
    while x not in (1, f - 1):
        x = (x * u) % f
        k += 1
    return k


def sextic_type(r: int) -> int:
    """The closed-form splitting law of Q(zeta_13)^+ as a function of p mod 13."""
    if r in (1, 12):
        return 1
    if r in (5, 8):
        return 2
    if r in (3, 4, 9, 10):
        return 3
    return 6


def section1() -> None:
    print("=" * 72)
    print("1. Splitting law of Q(zeta_13)^+  (Galois group C6)")
    print("=" * 72)
    for u in UNITS:
        assert real_degree(u) == sextic_type(u)
    table: dict[int, list[int]] = defaultdict(list)
    for u in UNITS:
        table[real_degree(u)].append(u)
    for d in (1, 2, 3, 6):
        rate = Fraction(len(table[d]), len(UNITS))
        print(f"  residue degree {d}:  p mod 13 in {table[d]!s:18}  rate {rate}")
    phi = {1: 1, 2: 1, 3: 2, 6: 2}
    assert all(len(table[d]) == 2 * phi[d] for d in phi)
    print("  counts = 2*phi(d): the kernel {+-1} doubles the C6 law #{T=d} = phi(d)")


# ---------------------------------------------------------------------------
# 2. The CRT factorisation
# ---------------------------------------------------------------------------


def quad_type(u: int) -> int:
    """Residue degree in Q(sqrt 13): 1 iff u is a square iff u^6 = 1."""
    return 1 if pow(u, 6, F) == 1 else 2


def cubic_type(u: int) -> int:
    """Residue degree in the cyclic cubic subfield: 1 iff u is a cube iff u^4 = 1."""
    return 1 if pow(u, 4, F) == 1 else 3


def section2() -> None:
    print("\n2. CRT factorisation  T6 = T2 * T3,   T2 = gcd(T6,2),  T3 = gcd(T6,3)")
    print("   u : T2  T3  T6")
    for u in UNITS:
        t2, t3, t6 = quad_type(u), cubic_type(u), real_degree(u)
        assert t6 == t2 * t3 and t2 == gcd(t6, 2) and t3 == gcd(t6, 3)
        print(f"  {u:2d} : {t2}   {t3}   {t6}")


# ---------------------------------------------------------------------------
# 3-4. Entropies, pinning, orthogonal split
# ---------------------------------------------------------------------------


def section3_4() -> None:
    t6 = [real_degree(u) for u in UNITS]
    t2 = [quad_type(u) for u in UNITS]
    t3 = [cubic_type(u) for u in UNITS]
    sign = [min(u, F - u) for u in UNITS]
    h6, h2, h3 = entropy(t6), entropy(t2), entropy(t3)
    print("\n3. Entropies over the 12 Frobenius classes")
    print(f"  H(T6) = {h6:.6f}   exact 1/3 + log2 3   = {1/3 + log2(3):.6f}")
    print(f"  H(T2) = {h2:.6f}   exact 1")
    print(f"  H(T3) = {h3:.6f}   exact log2 3 - 2/3   = {log2(3) - 2/3:.6f}")
    print(f"  H(T2)+H(T3) = {h2 + h3:.6f}  (CRT additivity)")
    print("\n4. Pinning and the orthogonal split")
    print(f"  H(T6 | p mod 13)      = {cond_entropy(t6, UNITS):.6f}   (full pinning)")
    print(f"  H(T6 | sign class)    = {cond_entropy(t6, sign):.6f}")
    print(f"  I(T6 ; T2) = {mutual_info(t6, t2):.6f}   = H(T2)")
    print(f"  I(T6 ; T3) = {mutual_info(t6, t3):.6f}   = H(T3)")
    print(f"  I(T2 ; T3) = {mutual_info(t2, t3):.6f}   (independent subfields)")
    print(f"  H(T6 | T2) = {cond_entropy(t6, t2):.6f}   = H(T3): quadratic subfield does not pin")
    print(f"  H(T6 | T3) = {cond_entropy(t6, t3):.6f}   = H(T2): cubic subfield does not pin")


# ---------------------------------------------------------------------------
# 5. Semiprime channels in the abstract C_n model
# ---------------------------------------------------------------------------


def ord_type(n: int, a: int) -> int:
    """Order of a in Z/n: the splitting type of a Frobenius element a in C_n."""
    return n // gcd(a, n)


def type_entropy(n: int) -> float:
    """H(T_n): entropy of ord_type(n, a) for a uniform in Z/n."""
    return entropy([ord_type(n, a) for a in range(n)])


def pair_channel(n: int) -> float:
    """I(N-Frobenius ; (T(p), T(q))) with Frob(N) = a + b mod n."""
    box = [(a, b) for a in range(n) for b in range(n)]
    pair = [(ord_type(n, a), ord_type(n, b)) for a, b in box]
    res = [(a + b) % n for a, b in box]
    return mutual_info(pair, res)


def split_channel(n: int) -> float:
    """I(N-Frobenius ; number of completely split prime factors)."""
    box = [(a, b) for a in range(n) for b in range(n)]
    cnt = [(a == 0) + (b == 0) for a, b in box]
    res = [(a + b) % n for a, b in box]
    return mutual_info(cnt, res)


def bin_ent(q: float, k: float) -> float:
    p = k / q
    return -(p * log2(p) + (1 - p) * log2(1 - p))


def split_prime_formula(q: float) -> float:
    """Closed form of the split channel derived for prime q (valid for q >= 3)."""
    head = log2(q * q) - ((q - 1) ** 2 * log2((q - 1) ** 2)
                          + 2 * (q - 1) * log2(2 * (q - 1))) / q ** 2
    return head - ((1 / q) * bin_ent(q, 1) + ((q - 1) / q) * bin_ent(q, 2))


def section5() -> None:
    print("\n5. Semiprime channels at degree 6")
    ip, is_ = pair_channel(6), split_channel(6)
    print(f"  I(pair)  = {ip:.6f}   exact log2 3 - 1/9 = {log2(3) - 1/9:.6f}")
    exact_split = log2(3) - (55 / 36) * log2(5) + 19 / 9
    print(f"  I(split) = {is_:.6f}   exact log2 3 - (55/36) log2 5 + 19/9 = {exact_split:.6f}")
    print(f"  prime-degree formula at q = 6       = {split_prime_formula(6):.6f}")
    print(f"  retained fraction I(split)/I(pair)  = {is_ / ip:.4%}  (< 11%)")
    print(f"  pair channel additive: I2 + I3 = {pair_channel(2):.6f} + {pair_channel(3):.6f}"
          f" = {pair_channel(2) + pair_channel(3):.6f}")
    print("  split channel vs prime formula, n = 3..12:")
    for n in range(3, 13):
        print(f"    n={n:2d}  split={split_channel(n):.6f}  formula={split_prime_formula(n):.6f}"
              f"  pair={pair_channel(n):.6f}")


# ---------------------------------------------------------------------------
# 6. CRT additivity in general
# ---------------------------------------------------------------------------


def prime_power_parts(n: int) -> list[int]:
    parts, p, m = [], 2, n
    while p * p <= m:
        if m % p == 0:
            q = 1
            while m % p == 0:
                m //= p
                q *= p
            parts.append(q)
        p += 1
    if m > 1:
        parts.append(m)
    return parts


def section6() -> None:
    print("\n6. H(T_n) = sum over prime-power parts  (CRT additivity)")
    for n in (6, 10, 12, 15, 30, 60, 84, 210):
        parts = prime_power_parts(n)
        s = sum(type_entropy(q) for q in parts)
        print(f"  n={n:3d}  parts={parts!s:14}  H(T_n)={type_entropy(n):.6f}  sum={s:.6f}")
    print("  prime-power rungs (saturation conjecture):")
    for p in (2, 3, 5):
        lim = (p / (p - 1)) * bin_ent(p, 1)
        vals = ", ".join(f"{type_entropy(p ** k):.4f}" for k in range(1, 6 if p == 2 else 4))
        print(f"    p={p}: {vals}  -> conjectured limit {lim:.4f}")


# ---------------------------------------------------------------------------
# 7. Reported numbers
# ---------------------------------------------------------------------------


def section7() -> None:
    print("\n7. Comparison with the experimentally reported values")
    h = 1 / 3 + log2(3)
    ip = log2(3) - 1 / 9
    print(f"  H(T):    reported 1.9192, exact {h:.6f}, gap {1.9192 - h:+.6f}  (> 8e-4)")
    print(f"  I(pair): reported 1.4704, exact {ip:.6f}, gap {1.4704 - ip:+.6f}  (< -3e-3)")


# ---------------------------------------------------------------------------
# 8. Monte Carlo with real primes
# ---------------------------------------------------------------------------


def primes_up_to(n: int) -> list[int]:
    sieve = bytearray([1]) * (n + 1)
    sieve[0:2] = b"\x00\x00"
    for i in range(2, int(n ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i::i] = bytearray(len(range(i * i, n + 1, i)))
    return [i for i in range(n + 1) if sieve[i]]


def section8(limit: int = 2_000_000) -> None:
    print(f"\n8. Actual primes p < {limit} (p != 13): empirical type rates")
    ps = [p for p in primes_up_to(limit) if p != 13]
    types = [sextic_type(p % 13) for p in ps]
    c = Counter(types)
    for d in (1, 2, 3, 6):
        print(f"  degree {d}: {c[d] / len(ps):.5f}")
    print(f"  empirical H(T) = {entropy(types):.5f}  (exact {1/3 + log2(3):.5f})")
    rng = random.Random(13)
    sample = [(rng.choice(ps), rng.choice(ps)) for _ in range(200_000)]
    pair = [(sextic_type(p % 13), sextic_type(q % 13)) for p, q in sample]
    res = [(p * q) % 13 for p, q in sample]
    print(f"  empirical I(N mod 13 ; pair) = {mutual_info(pair, res):.4f}  (exact {log2(3)-1/9:.4f})")


if __name__ == "__main__":
    section1()
    section2()
    section3_4()
    section5()
    section6()
    section7()
    section8()
