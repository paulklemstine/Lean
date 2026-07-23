"""
Deformation-Stable Arithmetic Coherence Thresholds -- numerical demonstrations.

This self-contained script illustrates the main results:

  * The connection count of a cyclotomic conductor n equals Euler's totient
    phi(n); at a prime conductor p it equals p - 1.
  * The excess above threshold e_c(x) = max(x - c, 0) carries the activation
    boundary: it vanishes exactly when x <= c.
  * Any ZERO-REFLECTING response law F (F(y) = 0 iff y = 0 for y >= 0) yields
    an order parameter Phi_F(x) = F(e_c(x)) that switches on at the same
    boundary, independent of the shape of F.
  * A power response Phi_alpha(x) = e_c(x) ** alpha preserves that boundary for
    every alpha > 0 and obeys the exact scaling law
        Phi_alpha(c + a*t) = a**alpha * Phi_alpha(c + t).
  * Specialized to prime conductors with c = 10000, coherence is active exactly
    when p > 10001, for every response law and every positive exponent.

Run with:  python3 demo.py
No third-party dependencies are required.
"""

from __future__ import annotations

import math
from typing import Callable, List, Tuple

CRITICAL_EDGES: int = 10000  # the critical connection budget c


# --------------------------------------------------------------------------- #
# 1. Arithmetic statistic: the cyclotomic connection count phi(n)             #
# --------------------------------------------------------------------------- #
def euler_totient(n: int) -> int:
    """Euler's totient phi(n): count of 1 <= k <= n with gcd(k, n) = 1."""
    if n <= 0:
        raise ValueError("n must be a positive integer")
    result: int = n
    m: int = n
    p: int = 2
    while p * p <= m:
        if m % p == 0:
            while m % p == 0:
                m //= p
            result -= result // p
        p += 1
    if m > 1:
        result -= result // m
    return result


def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d: int = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


def connection_count(n: int) -> int:
    """Connection count of conductor n = number of 1-dim complex Galois reps = phi(n)."""
    return euler_totient(n)


# --------------------------------------------------------------------------- #
# 2. Positive-part threshold geometry                                         #
# --------------------------------------------------------------------------- #
def excess(c: float, x: float) -> float:
    """Nonnegative excess above threshold: max(x - c, 0)."""
    return max(x - c, 0.0)


# --------------------------------------------------------------------------- #
# 3. Deformed order parameter for an arbitrary response law                   #
# --------------------------------------------------------------------------- #
def deformed_coherence(F: Callable[[float], float], c: float, x: float) -> float:
    """Order parameter Phi_F(x) = F(excess_c(x))."""
    return F(excess(c, x))


def power_coherence(alpha: float, c: float, x: float) -> float:
    """Power response Phi_alpha(x) = excess_c(x) ** alpha."""
    return excess(c, x) ** alpha


def sqrt_coherence(kappa: float, c: float, x: float) -> float:
    """Mean-field square-root order parameter sqrt(kappa) * sqrt(excess_c(x))."""
    return math.sqrt(kappa) * math.sqrt(excess(c, x))


# --------------------------------------------------------------------------- #
# Demonstrations                                                               #
# --------------------------------------------------------------------------- #
def demo_connection_counts() -> None:
    print("=" * 70)
    print("1. Connection count = phi(n);  at prime p it is p - 1")
    print("=" * 70)
    for n in [7, 12, 15, 10007, 10009]:
        phi = connection_count(n)
        tag = f"(prime -> p-1 = {n-1})" if is_prime(n) else "(composite)"
        print(f"  n = {n:>6}:  C(n) = phi(n) = {phi:>6}  {tag}")
    print()


def demo_boundary_invariance() -> None:
    print("=" * 70)
    print("2. Deformation invariance: every zero-reflecting F switches on at c")
    print("=" * 70)
    c = CRITICAL_EDGES
    responses: List[Tuple[str, Callable[[float], float]]] = [
        ("linear   F(y)=y", lambda y: y),
        ("sqrt     F(y)=y^0.5", lambda y: y ** 0.5),
        ("square   F(y)=y^2", lambda y: y ** 2),
        ("log1p    F(y)=log(1+y)", lambda y: math.log1p(y)),
        ("tanh     F(y)=tanh(y)", lambda y: math.tanh(y)),
    ]
    xs = [c - 100, c - 1, c, c + 1, c + 100]
    header = "   x - c   | " + " | ".join(f"{name.split()[0]:>8}" for name, _ in responses)
    print(header)
    print("  " + "-" * (len(header) - 2))
    for x in xs:
        vals = [deformed_coherence(F, c, float(x)) for _, F in responses]
        cells = " | ".join(f"{v:8.3f}" for v in vals)
        print(f"  {x - c:>7} | {cells}")
    print("  -> all response laws are exactly 0 for x <= c and > 0 for x > c.\n")


def demo_power_scaling() -> None:
    print("=" * 70)
    print("3. Exact critical scaling: Phi_a(c + a*t) = a^alpha * Phi_a(c + t)")
    print("=" * 70)
    c = CRITICAL_EDGES
    t = 4.0
    a = 3.0
    for alpha in [0.5, 1.0, 2.0, 1.5]:
        lhs = power_coherence(alpha, c, c + a * t)
        rhs = (a ** alpha) * power_coherence(alpha, c, c + t)
        print(f"  alpha={alpha:<4}:  LHS={lhs:14.6f}  RHS={rhs:14.6f}  match={math.isclose(lhs, rhs)}")
    print()


def demo_exponent_recovery() -> None:
    print("=" * 70)
    print("4. Recovering the exponent from two samples (Algorithm C)")
    print("=" * 70)
    c = CRITICAL_EDGES
    for true_alpha in [0.5, 1.0, 2.0]:
        t1, t2 = 2.0, 8.0
        v1 = power_coherence(true_alpha, c, c + t1)
        v2 = power_coherence(true_alpha, c, c + t2)
        est = math.log(v2 / v1) / math.log(t2 / t1)
        print(f"  true alpha = {true_alpha:<4}  ->  recovered alpha = {est:.6f}")
    print()


def demo_prime_phase_diagram() -> None:
    print("=" * 70)
    print("5. Prime-conductor phase diagram (kappa = 1, c = 10000)")
    print("=" * 70)
    c = CRITICAL_EDGES
    kappa = 1.0
    primes = [9973, 10007, 10009, 10037]  # around the boundary p = 10001
    for p in primes:
        assert is_prime(p)
        cnt = connection_count(p)  # = p - 1
        phi_val = sqrt_coherence(kappa, c, float(cnt))
        active = "ACTIVE" if p > 10001 else "inactive"
        print(f"  p = {p}:  C(p) = {cnt},  Phi_sqrt = {phi_val:8.4f}  [{active}]")
    print("  -> coherence is strictly positive exactly for p > 10001.\n")


def main() -> None:
    demo_connection_counts()
    demo_boundary_invariance()
    demo_power_scaling()
    demo_exponent_recovery()
    demo_prime_phase_diagram()


if __name__ == "__main__":
    main()
