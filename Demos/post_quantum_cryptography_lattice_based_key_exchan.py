#!/usr/bin/env python3
"""Numerical demonstrations of reconciliation and finite-view hybrid bounds.

The program uses only Python's standard library.  It checks the concrete
parameter profile, explores several bounded error vectors, and verifies a
common-ideal l1-gap example.  These are demonstrations of the stated arithmetic
and probability inequalities, not cryptanalytic security estimates.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import isqrt
from random import Random
from typing import Mapping, Sequence


@dataclass(frozen=True)
class ReconciliationReport:
    modulus: int
    error_count: int
    error_bound: int
    worst_case_sum: int
    scaled_worst_case: int
    scaled_margin: int
    safe: bool


def is_prime(n: int) -> bool:
    """Return whether n is prime by deterministic trial division."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    divisor = 3
    while divisor <= isqrt(n):
        if n % divisor == 0:
            return False
        divisor += 2
    return True


def reconciliation_report(q: int, m: int, bound: int) -> ReconciliationReport:
    """Audit the sufficient quarter-modulus condition 4*m*bound < q."""
    if q <= 0 or m < 0 or bound < 0:
        raise ValueError("Require q > 0, m >= 0, and bound >= 0")
    worst = m * bound
    scaled = 4 * worst
    return ReconciliationReport(q, m, bound, worst, scaled, q - scaled, scaled < q)


def check_error_vector(errors: Sequence[int], q: int, bound: int) -> tuple[int, bool]:
    """Validate coordinate bounds and test the actual quarter-modulus radius."""
    if any(abs(error) > bound for error in errors):
        raise ValueError("An error exceeds the declared magnitude bound")
    total = sum(errors)
    return total, 4 * abs(total) < q


def l1_gap(p: Mapping[str, float], q: Mapping[str, float]) -> float:
    """Compute the l1 distance between finite mass functions."""
    if set(p) != set(q):
        raise ValueError("Distributions must have the same finite support")
    for distribution in (p, q):
        if any(mass < 0.0 for mass in distribution.values()):
            raise ValueError("Probability masses must be nonnegative")
        if abs(sum(distribution.values()) - 1.0) > 1e-12:
            raise ValueError("Probability masses must sum to one")
    return sum(abs(p[x] - q[x]) for x in p)


def common_ideal_report(
    branch_zero: Mapping[str, float],
    ideal: Mapping[str, float],
    branch_one: Mapping[str, float],
) -> tuple[float, float, float, float]:
    """Return both branch losses, their bound, and the direct branch gap."""
    epsilon_zero = l1_gap(branch_zero, ideal)
    epsilon_one = l1_gap(branch_one, ideal)
    direct = l1_gap(branch_zero, branch_one)
    bound = epsilon_zero + epsilon_one
    if direct > bound + 1e-12:
        raise AssertionError("The l1 triangle inequality was violated")
    return epsilon_zero, epsilon_one, bound, direct


def main() -> None:
    n, q, m, bound = 512, 12_289, 1_024, 3
    report = reconciliation_report(q, m, bound)

    print("Concrete LWE-style reconciliation profile")
    print("=" * 48)
    print(f"dimension:                 {n}")
    print(f"modulus:                   {q} (prime: {is_prime(q)})")
    print(f"raw keyspace >= 2^128:     {pow(q, n) >= pow(2, 128)}")
    print(f"worst accumulated error:  {report.worst_case_sum}")
    print(f"four times worst error:   {report.scaled_worst_case}")
    print(f"strict integer margin:    {report.scaled_margin}")
    print(f"quarter-radius condition: {report.safe}")

    rng = Random(20260731)
    examples: dict[str, list[int]] = {
        "all errors aligned": [bound] * m,
        "perfect cancellation": [bound] * (m // 2) + [-bound] * (m // 2),
        "seeded random errors": [rng.randint(-bound, bound) for _ in range(m)],
    }
    print("\nBounded error-vector examples")
    print("-" * 48)
    for name, errors in examples.items():
        total, safe = check_error_vector(errors, q, bound)
        print(f"{name:22s} sum={total:6d}, 4|sum|={4*abs(total):5d}, safe={safe}")

    branch_zero = {"A": 0.55, "B": 0.45}
    ideal = {"A": 0.50, "B": 0.50}
    branch_one = {"A": 0.48, "B": 0.52}
    eps0, eps1, hybrid_bound, direct = common_ideal_report(
        branch_zero, ideal, branch_one
    )
    print("\nCommon-ideal hybrid example")
    print("-" * 48)
    print(f"branch 0 to ideal:         {eps0:.3f}")
    print(f"branch 1 to ideal:         {eps1:.3f}")
    print(f"sum of hybrid losses:     {hybrid_bound:.3f}")
    print(f"direct branch gap:        {direct:.3f}")
    print(f"triangle inequality holds: {direct <= hybrid_bound + 1e-12}")


if __name__ == "__main__":
    main()
