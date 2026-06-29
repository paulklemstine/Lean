"""
The Lucas Bridge for the Fibonacci Rank of Apparition — Numerical Demonstrations
================================================================================

Self-contained Python demonstrations of the results in the accompanying article and
research paper. No external dependencies (standard library only).

Sequences (matching the Lean formalization):
    Fibonacci:  F_0 = 0, F_1 = 1, F_{n+2} = F_n + F_{n+1}
    Lucas:      L_0 = 2, L_1 = 1, L_{n+2} = L_n + L_{n+1}

Key results demonstrated:
    * Doubling bridge:        F_{2n} = F_n * L_n
    * Quadratic identity:     L_n^2 - 5 F_n^2 = 4 (-1)^n
    * Near-coprimality:       gcd(L_n, F_n) | 2
    * Rank of apparition:     alpha(m) = least k>0 with m | F_k (always exists)
    * Ideal theorem:          m | F_k  <=>  alpha(m) | k
    * Lucas apparition (odd p, r = alpha(p)):
                              p | L_n  <=>  (r | 2n) and (r does not divide n)
    * Two-adic refinement:    write r = 2^a s, n = 2^b t (s,t odd);
                              p | L_n  <=>  s | t and b = a-1
"""

from __future__ import annotations

from math import gcd
from typing import Dict, List, Tuple


# --------------------------------------------------------------------------- #
# Core sequences
# --------------------------------------------------------------------------- #
def fib(n: int) -> int:
    """The n-th Fibonacci number (F_0 = 0, F_1 = 1)."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def lucas(n: int) -> int:
    """The n-th Lucas number (L_0 = 2, L_1 = 1)."""
    a, b = 2, 1
    for _ in range(n):
        a, b = b, a + b
    return a


# --------------------------------------------------------------------------- #
# Identities
# --------------------------------------------------------------------------- #
def check_doubling_bridge(max_n: int = 25) -> bool:
    """Verify F_{2n} = F_n * L_n for n = 0..max_n."""
    return all(fib(2 * n) == fib(n) * lucas(n) for n in range(max_n + 1))


def check_quadratic_identity(max_n: int = 25) -> bool:
    """Verify L_n^2 - 5 F_n^2 = 4 (-1)^n for n = 0..max_n."""
    return all(
        lucas(n) ** 2 - 5 * fib(n) ** 2 == 4 * (-1) ** n for n in range(max_n + 1)
    )


def check_near_coprimality(max_n: int = 40) -> bool:
    """Verify gcd(L_n, F_n) | 2 for n = 1..max_n."""
    return all(2 % gcd(lucas(n), fib(n)) == 0 for n in range(1, max_n + 1))


# --------------------------------------------------------------------------- #
# Rank of apparition (entry point)
# --------------------------------------------------------------------------- #
def rank_of_apparition(m: int) -> int:
    """Least k > 0 with m | F_k. Guaranteed to exist for m > 0 (pigeonhole)."""
    if m <= 0:
        raise ValueError("rank_of_apparition requires m > 0")
    a, b = 0, 1  # (F_0, F_1) mod m
    k = 0
    while True:
        k += 1
        a, b = b % m, (a + b) % m  # now a = F_k mod m
        if a == 0:
            return k


def check_ideal_theorem(m: int, max_k: int = 60) -> bool:
    """Verify  m | F_k  <=>  rank(m) | k   for k = 1..max_k."""
    r = rank_of_apparition(m)
    return all((fib(k) % m == 0) == (k % r == 0) for k in range(1, max_k + 1))


# --------------------------------------------------------------------------- #
# The Lucas apparition criterion
# --------------------------------------------------------------------------- #
def lucas_divisible_by_criterion(p: int, n: int) -> bool:
    """Predict p | L_n for an odd prime p, using only r = alpha(p).

    Criterion:  (r | 2n)  and  (r does not divide n).
    """
    r = rank_of_apparition(p)
    return (2 * n) % r == 0 and n % r != 0


def lucas_divisible_actual(p: int, n: int) -> bool:
    """Ground truth: does p divide L_n (computed directly)?"""
    return lucas(n) % p == 0


def verify_lucas_criterion(p: int, max_n: int = 80) -> bool:
    """Check the criterion against direct computation for n = 1..max_n."""
    return all(
        lucas_divisible_by_criterion(p, n) == lucas_divisible_actual(p, n)
        for n in range(1, max_n + 1)
    )


# --------------------------------------------------------------------------- #
# Two-adic refinement
# --------------------------------------------------------------------------- #
def two_adic_split(x: int) -> Tuple[int, int]:
    """Return (v, odd) with x = 2^v * odd and odd odd. Requires x > 0."""
    v = 0
    while x % 2 == 0:
        x //= 2
        v += 1
    return v, x


def lucas_divisible_two_adic(p: int, n: int) -> bool:
    """Two-adic form of the criterion for odd prime p, r = alpha(p).

    Write r = 2^a s, n = 2^b t (s,t odd). Then p | L_n  <=>  s | t and b = a-1.
    """
    r = rank_of_apparition(p)
    a, s = two_adic_split(r)
    b, t = two_adic_split(n)
    return a >= 1 and b == a - 1 and t % s == 0


def verify_two_adic(p: int, max_n: int = 80) -> bool:
    return all(
        lucas_divisible_two_adic(p, n) == lucas_divisible_actual(p, n)
        for n in range(1, max_n + 1)
    )


# --------------------------------------------------------------------------- #
# Reporting
# --------------------------------------------------------------------------- #
def apparition_set(p: int, max_n: int) -> List[int]:
    """Indices n in [1, max_n] with p | L_n (direct computation)."""
    return [n for n in range(1, max_n + 1) if lucas_divisible_actual(p, n)]


def demo() -> None:
    print("=" * 70)
    print("THE LUCAS BRIDGE FOR THE FIBONACCI RANK OF APPARITION")
    print("=" * 70)

    print("\n--- Sequences ---")
    print("n  : " + " ".join(f"{n:4d}" for n in range(11)))
    print("F_n: " + " ".join(f"{fib(n):4d}" for n in range(11)))
    print("L_n: " + " ".join(f"{lucas(n):4d}" for n in range(11)))

    print("\n--- Identities ---")
    print(f"Doubling bridge   F_2n = F_n * L_n        : {check_doubling_bridge()}")
    print(f"Quadratic identity L_n^2-5F_n^2 = 4(-1)^n : {check_quadratic_identity()}")
    print(f"Near-coprimality  gcd(L_n, F_n) | 2       : {check_near_coprimality()}")
    print("  e.g. F_10 =", fib(10), "=", fib(5), "*", lucas(5), "= F_5 * L_5")
    print("  e.g. L_6^2 - 5 F_6^2 =", lucas(6) ** 2 - 5 * fib(6) ** 2, "= 4*(-1)^6")

    print("\n--- Rank of apparition alpha(m) ---")
    for m in [2, 3, 5, 7, 11, 13, 17, 19, 23]:
        print(f"  alpha({m:2d}) = {rank_of_apparition(m):2d}   "
              f"ideal theorem holds: {check_ideal_theorem(m)}")

    print("\n--- The Lucas apparition criterion (odd primes) ---")
    print("  p | L_n  <=>  (r | 2n) and (r does not divide n),  r = alpha(p)")
    for p in [3, 7, 11, 13, 17, 19, 23]:
        r = rank_of_apparition(p)
        ok = verify_lucas_criterion(p)
        ok2 = verify_two_adic(p)
        s = apparition_set(p, 60)
        print(f"  p={p:2d}  r={r:2d}  criterion OK: {ok}  two-adic OK: {ok2}  "
              f"apparition set (n<=60): {s}")

    print("\n--- Detailed trace for p = 7 (r = 8) ---")
    p = 7
    for n in range(1, 25):
        pred = lucas_divisible_by_criterion(p, n)
        act = lucas_divisible_actual(p, n)
        mark = "<- 7 | L_n" if act else ""
        print(f"  n={n:2d}  L_n={lucas(n):8d}  criterion={pred!s:5}  "
              f"actual={act!s:5} {mark}")


if __name__ == "__main__":
    demo()
