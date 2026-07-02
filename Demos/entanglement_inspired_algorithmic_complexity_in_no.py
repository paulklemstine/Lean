"""
Numerical companion to
"A Transfer-Operator Framework for Fibonacci Correlations".

This self-contained script demonstrates the paper's three main results:

  1. Pisano periodicity from the finite noncommutative group of the transfer
     operator M = [[1,1],[1,0]] modulo m, with the period equal to the
     multiplicative order of M in GL_2(Z/mZ).
  2. The prime case of Carmichael's primitive-divisor theorem: for a prime
     index n >= 13, F_n has a primitive prime divisor.
  3. The bridge: a prime is "born" at a prime index n and recurs periodically.

All functions are inlined and type-hinted; only the standard library is used.
"""

from __future__ import annotations

from math import gcd, isqrt
from typing import List, Tuple

Matrix = Tuple[int, int, int, int]  # (a, b, c, d) for [[a,b],[c,d]]

# The transfer operator M = [[1,1],[1,0]].
M: Matrix = (1, 1, 1, 0)
IDENTITY: Matrix = (1, 0, 0, 1)


def mat_mul(x: Matrix, y: Matrix, mod: int) -> Matrix:
    """Multiply two 2x2 matrices modulo `mod` (mod <= 0 means no reduction)."""
    a, b, c, d = x
    e, f, g, h = y
    r = (a * e + b * g, a * f + b * h, c * e + d * g, c * f + d * h)
    return tuple(v % mod for v in r) if mod > 0 else r  # type: ignore[return-value]


def mat_pow(x: Matrix, n: int, mod: int) -> Matrix:
    """Fast binary exponentiation of a 2x2 matrix modulo `mod`."""
    result: Matrix = (IDENTITY if mod <= 0 else tuple(v % mod for v in IDENTITY))  # type: ignore[assignment]
    base = x
    while n > 0:
        if n & 1:
            result = mat_mul(result, base, mod)
        base = mat_mul(base, base, mod)
        n >>= 1
    return result


def fib(k: int, mod: int = 0) -> int:
    """F_k via the transfer operator: F_k = (M^{k+1})_{1,1} (lower-right entry)."""
    if k == 0:
        return 0
    p = mat_pow(M, k + 1, mod)
    return p[3]  # the (1,1) entry in 0-indexed = lower-right


def pisano_period(m: int) -> int:
    """Least period of the Fibonacci sequence modulo m == order of M in GL_2(Z/mZ)."""
    if m == 1:
        return 1
    power = M
    steps = 1
    ident = tuple(v % m for v in IDENTITY)
    while power != ident:
        power = mat_mul(power, M, m)
        steps += 1
    return steps


def factorize(n: int) -> List[int]:
    """Return the sorted list of distinct prime factors of n (trial division)."""
    factors: List[int] = []
    d = 2
    while d <= isqrt(n):
        if n % d == 0:
            factors.append(d)
            while n % d == 0:
                n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        factors.append(n)
    return factors


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    for d in range(2, isqrt(n) + 1):
        if n % d == 0:
            return False
    return True


def primitive_prime_divisor(n: int) -> int:
    """Smallest primitive prime divisor of F_n for prime n >= 13 (Theorem 4.2)."""
    fn = fib(n)
    return min(factorize(fn))


def verify_primitive(p: int, n: int) -> bool:
    """Check p | F_n and p does not divide F_k for any 0 < k < n."""
    if fib(n) % p != 0:
        return False
    return all(fib(k) % p != 0 for k in range(1, n))


def demo_pisano() -> None:
    print("=" * 64)
    print("1. Pisano periods = order of the transfer unit in GL_2(Z/mZ)")
    print("=" * 64)
    periods = [pisano_period(m) for m in range(1, 11)]
    print("   pi(m) for m = 1..10 :", periods)
    print("   OEIS A001175 target :", [1, 3, 8, 6, 20, 24, 16, 12, 24, 60])
    # Verify periodicity: F_{n+p} == F_n (mod m).
    ok = True
    for m in range(1, 11):
        p = pisano_period(m)
        ok &= all(fib(n, m) == fib(n + p, m) for n in range(0, 30))
    print("   Periodicity F_{n+p} = F_n (mod m) holds for all tests:", ok)


def demo_primitive() -> None:
    print("=" * 64)
    print("2. Primitive prime divisors at prime indices (n >= 13)")
    print("=" * 64)
    for n in [13, 17, 19, 23, 29]:
        if is_prime(n):
            p = primitive_prime_divisor(n)
            print(f"   n = {n:2d}:  F_n = {fib(n):>8d},  primitive prime = {p:>6d},"
                  f"  verified = {verify_primitive(p, n)}")


def demo_bridge() -> None:
    print("=" * 64)
    print("3. Bridge: birth at n, then periodic recurrence")
    print("=" * 64)
    n = 13
    p = primitive_prime_divisor(n)
    period = pisano_period(p)
    print(f"   Prime {p} is born at index n = {n} (first Fibonacci divisor).")
    print(f"   Order of M modulo {p} is {period}.")
    hits = [n + t * period for t in range(4)]
    print(f"   {p} divides F_k at indices:", hits,
          "->", [fib(k) % p == 0 for k in hits])


def demo_cassini() -> None:
    print("=" * 64)
    print("4. Cassini identity from the multiplicative invariant det")
    print("=" * 64)
    for k in range(1, 8):
        lhs = fib(k + 2) * fib(k) - fib(k + 1) ** 2
        rhs = (-1) ** (k + 1)
        print(f"   k = {k}:  F_(k+2)F_k - F_(k+1)^2 = {lhs:>3d}  =  (-1)^(k+1) = {rhs}")


if __name__ == "__main__":
    demo_pisano()
    demo_primitive()
    demo_bridge()
    demo_cassini()
