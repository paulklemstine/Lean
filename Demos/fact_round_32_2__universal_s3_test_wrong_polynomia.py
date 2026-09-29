#!/usr/bin/env python3
"""
The Wrong Polynomial: numerical companion.

An experiment meant to measure root counts of x^3 - 2 modulo primes actually
measured x^5 - 2.  This script reproduces every numerical fact used in the
accompanying article and paper:

  1. The affine moment law  sum_{a != 0, b} fix(x -> a x + b)^k = q^k + q(q-2)
     for the affine group AGL(1, q), checked by brute force over prime fields.
  2. Normalised moments 1, 2, q + 2 (universal, universal, q-detecting).
  3. AGL(1,3) is all of Sym(3); AGL(1,q) is a proper subgroup for q >= 4.
  4. Root counts of x^n = c over F_p: at most n, alphabet {0, 1, l} for prime l,
     exactly 1 when gcd(n, p-1) = 1, sum over c equal to p, sum of squares
     equal to 1 + (p-1) gcd(n, p-1).
  5. Dial checks at p = 23, 31, 151.
  6. Empirical prime-averaged moments of x^3 - 2 and x^5 - 2 versus the
     group predictions (1, 2, 5) and (1, 2, 7).

Pure Python 3, no dependencies.
"""
from __future__ import annotations

from fractions import Fraction
from itertools import permutations
from math import gcd, factorial
from typing import Dict, List, Tuple


# ---------------------------------------------------------------- utilities
def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test (fine for small n)."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


def primes_in(lo: int, hi: int) -> List[int]:
    """All primes p with lo <= p < hi."""
    return [p for p in range(lo, hi) if is_prime(p)]


# ------------------------------------------------- 1. the affine group AGL(1,q)
def affine_fixed_points(a: int, b: int, q: int) -> int:
    """Number of x in F_q (q prime) with a*x + b = x."""
    return sum(1 for x in range(q) if (a * x + b - x) % q == 0)


def affine_fixed_points_formula(a: int, b: int, q: int) -> int:
    """Closed form: q if identity, 0 if nontrivial translation, 1 if a != 1."""
    if a % q == 1:
        return q if b % q == 0 else 0
    return 1


def affine_power_sum(q: int, k: int) -> int:
    """sum over a != 0, b of fix(a, b)^k, by brute force."""
    return sum(affine_fixed_points(a, b, q) ** k
               for a in range(1, q) for b in range(q))


def affine_moment_law(q: int, k: int) -> int:
    """The closed form q^k + q(q-2), valid for k >= 1."""
    return q ** k + q * (q - 2)


def normalised_affine_moment(q: int, k: int) -> Fraction:
    """k-th moment of the fixed-point count, averaged over AGL(1,q)."""
    return Fraction(affine_moment_law(q, k), q * (q - 1))


def demo_affine_moments() -> None:
    print("=" * 72)
    print("1. The affine moment law for AGL(1,q), q prime")
    print("=" * 72)
    for q in [2, 3, 5, 7, 11, 13]:
        for a in range(1, q):
            for b in range(q):
                assert affine_fixed_points(a, b, q) == affine_fixed_points_formula(a, b, q)
        row = []
        for k in range(1, 6):
            brute = affine_power_sum(q, k)
            assert brute == affine_moment_law(q, k), (q, k)
            row.append(str(normalised_affine_moment(q, k)))
        print(f"q = {q:2d} |AGL| = {q*(q-1):3d}   normalised moments k=1..5: "
              + ", ".join(row))
    print("   -> k=1 always 1 (Burnside), k=2 always 2 (2-transitivity),")
    print("      k=3 equals q+2, so it determines q.")
    print(f"   S3 = AGL(1,3): third moment {normalised_affine_moment(3, 3)};"
          f"  F20 = AGL(1,5): third moment {normalised_affine_moment(5, 3)}")
    print(f"   raw third power sums: {affine_power_sum(3, 3)} (= 6*5) and "
          f"{affine_power_sum(5, 3)} (= 20*7)\n")


# --------------------------------------------- 2. AGL(1,3) = S3, AGL(1,q) < S_q
def affine_permutations(q: int) -> set:
    """The set of permutations of {0..q-1} of the form x -> a x + b."""
    return {tuple((a * x + b) % q for x in range(q))
            for a in range(1, q) for b in range(q)}


def demo_affine_vs_symmetric() -> None:
    print("=" * 72)
    print("2. AGL(1,3) is the whole symmetric group; AGL(1,q) is not for q >= 4")
    print("=" * 72)
    for q in [3, 5, 7]:
        agl = affine_permutations(q)
        print(f"q = {q}: |AGL(1,q)| = {len(agl):4d}, |S_q| = {factorial(q):5d}, "
              f"equal: {len(agl) == factorial(q)}")
    assert affine_permutations(3) == set(permutations(range(3)))
    print("   every permutation of {0,1,2} is affine: verified\n")


# ------------------------------------------------ 3. root counts of x^n = c
def root_count(n: int, c: int, p: int) -> int:
    """#{x in F_p : x^n = c}."""
    c %= p
    return sum(1 for x in range(p) if pow(x, n, p) == c)


def demo_root_counts() -> None:
    print("=" * 72)
    print("3. Root counts of x^n = c over prime fields F_p")
    print("=" * 72)
    for p in primes_in(3, 60):
        for n in [2, 3, 4, 5, 6]:
            counts = [root_count(n, c, p) for c in range(p)]
            mu = gcd(n, p - 1)
            assert max(counts) <= n
            assert sum(counts) == p                       # universal mean
            assert sum(v * v for v in counts) == 1 + (p - 1) * mu  # 2nd moment
            for c in range(1, p):
                assert counts[c] in (0, mu)               # coset dichotomy
                if mu == 1:
                    assert counts[c] == 1                 # inert: bijection
            if is_prime(n):
                assert all(counts[c] in (0, 1, n) for c in range(1, p))
    print("   verified for all primes p < 60 and n = 2..6:")
    print("   * at most n roots;  for c != 0 either 0 or gcd(n, p-1) roots")
    print("   * exactly one root whenever gcd(n, p-1) = 1")
    print("   * for prime n = l the alphabet is {0, 1, l}")
    print("   * sum_c #roots = p   (independent of n)")
    print("   * sum_c #roots^2 = 1 + (p-1) gcd(n, p-1)   (depends on n)")
    p = 31
    print(f"   example p = {p}: sum of squares for n = 3 is "
          f"{sum(root_count(3, c, p)**2 for c in range(p))}, for n = 5 is "
          f"{sum(root_count(5, c, p)**2 for c in range(p))}\n")


# ------------------------------------------------------------ 4. dial checks
def roots_list(n: int, c: int, p: int) -> List[int]:
    return [x for x in range(p) if pow(x, n, p) == c % p]


def demo_dials() -> None:
    print("=" * 72)
    print("4. Single-prime dial checks: intended x^3-2 vs accidental x^5-2")
    print("=" * 72)
    for p in [23, 31, 151]:
        r3, r5 = roots_list(3, 2, p), roots_list(5, 2, p)
        verdict = ("indistinguishable" if len(r3) == len(r5)
                   else "separated")
        if len(r5) == 5:
            verdict += "; 5 roots is impossible for any cubic -> wrong polynomial certified"
        print(f"p = {p:3d}: x^3-2 roots {r3}  |  x^5-2 roots {r5}  -> {verdict}")
    print()


# ---------------------------------------- 5. prime-averaged empirical moments
def empirical_moments(n: int, primes: List[int]) -> Tuple[Dict[int, int], List[float]]:
    hist: Dict[int, int] = {}
    vals = []
    for p in primes:
        r = root_count(n, 2, p)
        hist[r] = hist.get(r, 0) + 1
        vals.append(r)
    moments = [sum(v ** k for v in vals) / len(vals) for k in (1, 2, 3)]
    return dict(sorted(hist.items())), moments


def demo_empirical() -> None:
    print("=" * 72)
    print("5. Prime-averaged root-count moments vs group predictions")
    print("=" * 72)
    for lo, hi in [(7, 400), (7, 5000)]:
        ps = primes_in(lo, hi)
        print(f"primes {lo} <= p < {hi}  ({len(ps)} primes)")
        for n, q in [(3, 3), (5, 5)]:
            hist, m = empirical_moments(n, ps)
            pred = [float(normalised_affine_moment(q, k)) for k in (1, 2, 3)]
            print(f"   x^{n}-2: histogram {hist}; moments "
                  f"{m[0]:.3f}, {m[1]:.3f}, {m[2]:.3f}   predicted "
                  f"{pred[0]:.0f}, {pred[1]:.0f}, {pred[2]:.0f}")
    print("   Moments 1 and 2 agree for both polynomials; moment 3 separates them.\n")


if __name__ == "__main__":
    demo_affine_moments()
    demo_affine_vs_symmetric()
    demo_root_counts()
    demo_dials()
    demo_empirical()
