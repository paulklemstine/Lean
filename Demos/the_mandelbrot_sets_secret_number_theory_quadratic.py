"""
The Mandelbrot Set's Secret Number Theory
=========================================

Numerical demonstrations for the quadratic recurrence z -> z^2 + c and the
elementary number theory hidden in its connectedness locus.

This module is fully self-contained (standard library only) and demonstrates:

  1. The escape criterion:  |z_n| > 2  implies the orbit of 0 diverges.
  2. Period = denominator:  the bulb at reduced angle p/q has period q, equal
     to the additive order of p in Z/qZ.
  3. The Lyapunov formula:  lambda(c) = log 2 * cos(pi p/q) at the bulb center
     (checked against the averaged log|2 w_j| over the attracting cycle).
  4. The Fibonacci / Farey spiral:  consecutive Fibonacci ratios are unimodular
     Farey neighbours, certified by Cassini's identity.
  5. Product structure of composite bulbs:  additive order is multiplicative
     over coprime moduli (Chinese Remainder Theorem).

Run:  python demo.py
"""

from __future__ import annotations

import cmath
import math
from math import gcd
from typing import Iterator


# ---------------------------------------------------------------------------
# 1. Escape criterion
# ---------------------------------------------------------------------------

def escape_time(c: complex, max_iter: int = 1000, radius: float = 2.0) -> int | None:
    """Return the first n with |z_n| > radius, or None if bounded within max_iter.

    Implements Corollary 3.3: once the modulus exceeds 2 the orbit of 0 under
    z -> z^2 + c diverges, so first-passage time is a faithful escape test.
    """
    z = 0.0 + 0.0j
    for n in range(max_iter):
        z = z * z + c
        if abs(z) > radius:
            return n
    return None


def in_mandelbrot(c: complex, max_iter: int = 2000) -> bool:
    """Heuristic membership test: bounded within max_iter iterations."""
    return escape_time(c, max_iter=max_iter) is None


# ---------------------------------------------------------------------------
# 2. Period = denominator  (additive order in Z/qZ)
# ---------------------------------------------------------------------------

def additive_order(p: int, q: int) -> int:
    """Least k >= 1 with q | k*p, i.e. the additive order of p in Z/qZ."""
    if q <= 0:
        raise ValueError("q must be positive")
    p %= q
    k = 1
    acc = p % q
    while acc != 0:
        acc = (acc + p) % q
        k += 1
    return k


def bulb_period(p: int, q: int) -> int:
    """Period of the p/q bulb: additive order of p mod q (= q iff gcd(p,q)=1)."""
    return additive_order(p, q)


# ---------------------------------------------------------------------------
# 3. Lyapunov exponent at a bulb center
# ---------------------------------------------------------------------------

def attracting_cycle(c: complex, period: int, max_iter: int = 20000,
                     settle: int = 10000) -> list[complex]:
    """Return one period of the attracting cycle of z -> z^2 + c (numerically)."""
    z = 0.0 + 0.0j
    for _ in range(settle):
        z = z * z + c
    cycle = []
    for _ in range(period):
        z = z * z + c
        cycle.append(z)
    return cycle


def lyapunov_numeric(c: complex, period: int) -> float:
    """Averaged log|2 w_j| over the attracting cycle (Definition 2.5)."""
    cycle = attracting_cycle(c, period)
    total = 0.0
    for w in cycle:
        total += math.log(abs(2.0 * w) + 1e-300)
    return total / period


def lyapunov_formula(p: int, q: int) -> float:
    """Conjectured value log 2 * cos(pi p/q) at the p/q bulb center."""
    return math.log(2.0) * math.cos(math.pi * p / q)


def bulb_center_approx(p: int, q: int) -> complex:
    """Approximate center of the p/q bulb via its attachment on the cardioid.

    The cardioid boundary is c(theta) = e^{i theta}/2 - e^{2 i theta}/4 with the
    internal multiplier e^{i theta}; the p/q bulb attaches at theta = 2 pi p/q.
    We nudge outward along the normal to reach the interior center; a small
    denominator-dependent offset approximates the true center for illustration.
    """
    theta = 2.0 * math.pi * p / q
    root = cmath.exp(1j * theta) / 2.0 - cmath.exp(2j * theta) / 4.0
    # Outward normal direction (toward the bulb interior).
    normal = cmath.exp(1j * theta)
    offset = 0.25 / (q * q)
    return root + offset * normal


# ---------------------------------------------------------------------------
# 4. Fibonacci / Farey spiral
# ---------------------------------------------------------------------------

def fibonacci(n: int) -> int:
    """n-th Fibonacci number, F_0 = 0, F_1 = 1."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def cassini(n: int) -> int:
    """F_{n+1}^2 - F_n F_{n+2}; equals (-1)^n by Cassini's identity."""
    return fibonacci(n + 1) ** 2 - fibonacci(n) * fibonacci(n + 2)


def are_farey_neighbours(a: int, b: int, c: int, d: int) -> bool:
    """True iff a/b and c/d are unimodular Farey neighbours: |b c - a d| = 1."""
    return abs(b * c - a * d) == 1


def mediant(a: int, b: int, c: int, d: int) -> tuple[int, int]:
    """Farey mediant (a+c)/(b+d)."""
    return a + c, b + d


def golden_geodesic(depth: int) -> Iterator[tuple[int, int]]:
    """Yield the Fibonacci ratios F_n / F_{n+1} for n = 1..depth."""
    for n in range(1, depth + 1):
        yield fibonacci(n), fibonacci(n + 1)


# ---------------------------------------------------------------------------
# 5. Product structure of composite bulbs (CRT)
# ---------------------------------------------------------------------------

def prime_factorization(n: int) -> dict[int, int]:
    """Return the prime factorization {p: a} of n >= 2."""
    factors: dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def lcm(a: int, b: int) -> int:
    return a * b // gcd(a, b)


def order_is_multiplicative(a: int, q1: int, q2: int) -> bool:
    """Verify ord_{q1 q2}(a) = lcm(ord_{q1}(a), ord_{q2}(a)) when gcd(q1,q2)=1."""
    assert gcd(q1, q2) == 1
    left = additive_order(a % (q1 * q2), q1 * q2)
    right = lcm(additive_order(a % q1, q1), additive_order(a % q2, q2))
    return left == right


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_escape() -> None:
    print("=" * 68)
    print("1. Escape criterion (|z_n| > 2 => divergence)")
    print("=" * 68)
    samples = [0.0, -1.0, -2.0, 0.25, 0.3, -0.75 + 0.1j, 1.0, -0.12 + 0.75j]
    for c in samples:
        t = escape_time(c)
        status = "bounded (in M)" if t is None else f"escapes at step {t}"
        print(f"  c = {c!s:>16}   ->   {status}")
    print()


def demo_period() -> None:
    print("=" * 68)
    print("2. Period = denominator  (period = additive order of p mod q)")
    print("=" * 68)
    print(f"  {'p/q':>7}  {'reduced?':>9}  {'ord_q(p)':>9}  {'= q?':>5}")
    for q in range(2, 13):
        for p in range(1, q):
            reduced = gcd(p, q) == 1
            per = bulb_period(p, q)
            flag = "yes" if (reduced and per == q) else ("--" if not reduced else "NO")
            if reduced:
                print(f"  {p:>2}/{q:<3}  {'yes':>9}  {per:>9}  {flag:>5}")
    print()


def demo_lyapunov() -> None:
    print("=" * 68)
    print("3. Lyapunov formula  lambda = log 2 * cos(pi p/q)")
    print("=" * 68)
    print(f"  {'p/q':>7}  {'formula':>12}  {'numeric':>12}  {'abs diff':>10}")
    for (p, q) in [(1, 2), (1, 3), (2, 3), (1, 4), (3, 4), (1, 5), (2, 5)]:
        c = bulb_center_approx(p, q)
        per = bulb_period(p, q)
        try:
            num = lyapunov_numeric(c, per)
        except (ValueError, OverflowError):
            num = float("nan")
        form = lyapunov_formula(p, q)
        print(f"  {p:>2}/{q:<3}  {form:>12.6f}  {num:>12.6f}  {abs(form-num):>10.4f}")
    print("  (numeric uses an approximate bulb center; agreement is qualitative)")
    print()


def demo_fibonacci() -> None:
    print("=" * 68)
    print("4. Fibonacci ratios are unimodular Farey neighbours (Cassini)")
    print("=" * 68)
    print(f"  {'n':>3}  {'F_n/F_{n+1}':>14}  {'Cassini':>8}  {'neighbour?':>10}")
    ratios = list(golden_geodesic(10))
    for n in range(1, 9):
        a, b = ratios[n - 1]
        c, d = ratios[n]
        cass = cassini(n)
        nb = are_farey_neighbours(a, b, c, d)
        print(f"  {n:>3}  {f'{a}/{b}':>14}  {cass:>8}  {str(nb):>10}")
    phi = (1 + 5 ** 0.5) / 2
    a, b = ratios[-1]
    print(f"  limit F_n/F_(n+1) -> 1/phi = {1/phi:.8f}   (last {a}/{b} = {a/b:.8f})")
    print()


def demo_product_structure() -> None:
    print("=" * 68)
    print("5. Product structure of composite bulbs (CRT multiplicativity)")
    print("=" * 68)
    ok = True
    for n in range(2, 101):
        factors = prime_factorization(n)
        if len(factors) < 2:
            continue  # prime power -> atomic bulb
        # split n into two coprime parts from its prime powers
        parts = [p ** a for p, a in factors.items()]
        q1 = parts[0]
        q2 = n // q1
        for a in range(1, min(n, 30)):
            if not order_is_multiplicative(a, q1, q2):
                ok = False
                print(f"  FAIL at n={n}, a={a}")
    print(f"  ord_(q1 q2) = lcm(ord_q1, ord_q2) verified for all tested n<=100:"
          f" {'PASS' if ok else 'FAIL'}")
    # Show an explicit factorized example.
    n = 60
    print(f"  example: period n = {n} = "
          + " * ".join(f"{p}^{a}" for p, a in prime_factorization(n).items())
          + "  -> product of prime-power bulbs")
    print()


def main() -> None:
    demo_escape()
    demo_period()
    demo_lyapunov()
    demo_fibonacci()
    demo_product_structure()


if __name__ == "__main__":
    main()
