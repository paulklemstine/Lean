#!/usr/bin/env python3
"""Numerical demonstrations for quadratic recurrence z -> z*z + c.

The program uses only Python's standard library.  Its floating-point period
searches are illustrations; exact integer formulas are evaluated exactly.
"""

from __future__ import annotations

import cmath
import math
from dataclasses import dataclass
from typing import Iterable, Optional


@dataclass(frozen=True)
class OrbitSample:
    step: int
    point: complex
    multiplier: complex


def orbit_with_multiplier(c: complex, z0: complex, steps: int) -> list[OrbitSample]:
    """Return z_k and M_k, where M_{k+1}=2*z_k*M_k."""
    z = z0
    multiplier = 1.0 + 0.0j
    samples = [OrbitSample(0, z, multiplier)]
    for step in range(1, steps + 1):
        multiplier *= 2.0 * z
        z = z * z + c
        samples.append(OrbitSample(step, z, multiplier))
    return samples


def approximate_exact_period(
    c: complex, z0: complex, max_period: int = 100, tolerance: float = 1e-10
) -> Optional[int]:
    """Return the first numerical return time to z0, if one is found."""
    z = z0
    for period in range(1, max_period + 1):
        z = z * z + c
        if abs(z - z0) <= tolerance:
            return period
    return None


def divisors(n: int) -> list[int]:
    """Return the positive divisors of n in increasing order."""
    if n <= 0:
        raise ValueError("n must be positive")
    small: list[int] = []
    large: list[int] = []
    d = 1
    while d * d <= n:
        if n % d == 0:
            small.append(d)
            if d * d != n:
                large.append(n // d)
        d += 1
    return small + large[::-1]


def mobius(n: int) -> int:
    """Evaluate the Möbius function by trial division."""
    if n <= 0:
        raise ValueError("n must be positive")
    remaining = n
    prime_count = 0
    p = 2
    while p * p <= remaining:
        if remaining % p == 0:
            remaining //= p
            prime_count += 1
            if remaining % p == 0:
                return 0
            while remaining % p == 0:
                remaining //= p
        p += 1 if p == 2 else 2
    if remaining > 1:
        prime_count += 1
    return -1 if prime_count % 2 else 1


def dynatomic_point_count(n: int) -> int:
    """Compute Psi(n) = sum_{d|n} mu(n/d) 2^d exactly."""
    return sum(mobius(n // d) * (2**d) for d in divisors(n))


def fibonacci(n: int) -> int:
    """Compute F_n iteratively."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def farey_mediant(left: tuple[int, int], right: tuple[int, int]) -> tuple[int, int]:
    """Return the unreduced Farey mediant of two numerator-denominator pairs."""
    return left[0] + right[0], left[1] + right[1]


def escape_trace(c: complex, max_steps: int = 50) -> tuple[Optional[int], list[float]]:
    """Iterate from zero and return the first certified growth step and norms."""
    z = 0.0 + 0.0j
    norms = [0.0]
    certificate: Optional[int] = None
    for step in range(max_steps):
        if abs(z) > 2.0 and abs(z) > abs(c) and certificate is None:
            certificate = step
        z = z * z + c
        norms.append(abs(z))
        if abs(z) > 1e100:
            break
    return certificate, norms


def print_cycle_demo() -> None:
    print("\n1. Critical cycles and zero multipliers")
    for name, c, expected in [
        ("fixed center", 0.0 + 0.0j, 1),
        ("period-two center", -1.0 + 0.0j, 2),
    ]:
        samples = orbit_with_multiplier(c, 0.0j, expected)
        period = approximate_exact_period(c, 0.0j, 10)
        print(f"  {name:18s}: c={c}, first return={period}")
        for sample in samples:
            print(
                f"    k={sample.step}: z={sample.point:g}, "
                f"M={sample.multiplier:g}"
            )


def print_count_demo(limit: int = 12) -> None:
    print("\n2. Dynatomic point and cycle counts")
    print("   n   Psi(n)   Psi(n)/n")
    for n in range(1, limit + 1):
        count = dynatomic_point_count(n)
        print(f"  {n:2d} {count:8d} {count // n:10d}")
    print("  Prime checks p | (2^p-2):")
    for p in (2, 3, 5, 7, 11, 13, 17, 19):
        value = 2**p - 2
        print(f"    p={p:2d}: remainder={value % p}, cycles={value // p}")


def print_farey_demo(rows: int = 8) -> None:
    print("\n3. Farey mediation of consecutive Fibonacci ratios")
    for n in range(rows):
        left = (fibonacci(n), fibonacci(n + 1))
        right = (fibonacci(n + 1), fibonacci(n + 2))
        med = farey_mediant(left, right)
        target = fibonacci(n + 3)
        print(f"  n={n}: {left} mediant {right} = {med}; denominator F_(n+3)={target}")
        assert med[1] == target


def print_escape_demo() -> None:
    print("\n4. Escape-growth certificate")
    for c in (0.25 + 0.0j, 1.0 + 0.0j, -0.75 + 0.1j):
        step, norms = escape_trace(c, 30)
        status = "no certificate in window" if step is None else f"certificate at k={step}"
        preview = ", ".join(f"{x:.3g}" for x in norms[:8])
        print(f"  c={c}: {status}; norms=[{preview}, ...]")
        if step is not None and step + 1 < len(norms):
            assert norms[step + 1] > norms[step]


def main() -> None:
    print("Quadratic Recurrence and Number Theory")
    print_cycle_demo()
    print_count_demo()
    print_farey_demo()
    print_escape_demo()


if __name__ == "__main__":
    main()
