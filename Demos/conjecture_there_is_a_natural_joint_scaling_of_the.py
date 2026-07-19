#!/usr/bin/env python3
"""Numerical demonstrations of finite prime-occupation cutoff bounds.

The script uses only the Python standard library.  It verifies the exact defect
factorization, compares the true occupation defect with its additive bound, and
shows the separation between prime-cutoff and occupation-cutoff errors.
"""

from __future__ import annotations

import argparse
import math
from dataclasses import dataclass
from typing import Iterable, Sequence


@dataclass(frozen=True)
class OccupationReport:
    """Computed quantities for a finite geometric occupation system."""

    truncated: float
    completed: float
    factorized: float
    defect: float
    tail_bound: float
    normalized_defect: float
    normalized_bound: float


def primes_below(limit: int) -> list[int]:
    """Return all primes strictly below ``limit`` by the sieve of Eratosthenes."""
    if limit <= 2:
        return []
    sieve = bytearray(b"\x01") * limit
    sieve[0:2] = b"\x00\x00"
    for candidate in range(2, math.isqrt(limit - 1) + 1):
        if sieve[candidate]:
            start = candidate * candidate
            sieve[start:limit:candidate] = b"\x00" * (
                ((limit - 1 - start) // candidate) + 1
            )
    return [n for n in range(2, limit) if sieve[n]]


def geometric_sum(q: float, ceiling: int) -> float:
    """Compute ``sum(q**n for n=0..ceiling)`` by stable accumulation."""
    if ceiling < 0:
        raise ValueError("the occupation ceiling must be nonnegative")
    if not 0.0 <= q < 1.0:
        raise ValueError("each weight must satisfy 0 <= q < 1")
    total = 1.0
    term = 1.0
    for _ in range(ceiling):
        term *= q
        total += term
    return total


def occupation_report(weights: Sequence[float], ceiling: int) -> OccupationReport:
    """Evaluate the exact factorization and certified occupation-tail bound."""
    if ceiling < 0:
        raise ValueError("the occupation ceiling must be nonnegative")
    if any(not 0.0 <= q < 1.0 for q in weights):
        raise ValueError("each weight must satisfy 0 <= q < 1")

    truncated = math.prod(geometric_sum(q, ceiling) for q in weights)
    completed = math.prod(1.0 / (1.0 - q) for q in weights)
    local_tails = [q ** (ceiling + 1) for q in weights]
    defect_factor = math.prod(1.0 - tail for tail in local_tails)
    factorized = completed * defect_factor
    defect = completed - truncated
    normalized_defect = 1.0 - defect_factor
    normalized_bound = math.fsum(local_tails)
    tail_bound = completed * normalized_bound
    return OccupationReport(
        truncated=truncated,
        completed=completed,
        factorized=factorized,
        defect=defect,
        tail_bound=tail_bound,
        normalized_defect=normalized_defect,
        normalized_bound=normalized_bound,
    )


def prime_weights(limit: int, beta: float) -> tuple[list[int], list[float]]:
    """Return retained primes and their Boltzmann weights ``p**(-beta)``."""
    if beta <= 0.0:
        raise ValueError("beta must be positive")
    primes = primes_below(limit)
    return primes, [math.exp(-beta * math.log(p)) for p in primes]


def zeta_dirichlet(beta: float, terms: int = 1_000_000) -> tuple[float, float]:
    """Approximate zeta(beta), returning value and an integral-test error bound.

    For beta > 1, the omitted tail after ``terms`` is at most
    ``terms**(1-beta)/(beta-1)``.
    """
    if beta <= 1.0:
        raise ValueError("the Dirichlet-series demonstration requires beta > 1")
    if terms < 1:
        raise ValueError("terms must be positive")
    value = math.fsum(n ** (-beta) for n in range(1, terms + 1))
    remainder_bound = terms ** (1.0 - beta) / (beta - 1.0)
    return value, remainder_bound


def find_occupation_ceiling(weights: Sequence[float], relative_tolerance: float) -> int:
    """Find the least ceiling whose additive relative bound meets a tolerance."""
    if relative_tolerance <= 0.0:
        raise ValueError("relative_tolerance must be positive")
    if any(not 0.0 <= q < 1.0 for q in weights):
        raise ValueError("each weight must satisfy 0 <= q < 1")

    def acceptable(n: int) -> bool:
        return math.fsum(q ** (n + 1) for q in weights) <= relative_tolerance

    if acceptable(0):
        return 0
    high = 1
    while not acceptable(high):
        high *= 2
    low = 0
    while low + 1 < high:
        middle = (low + high) // 2
        if acceptable(middle):
            high = middle
        else:
            low = middle
    return high


def print_report(label: str, report: OccupationReport) -> None:
    """Print a compact table for one occupation system."""
    residual = abs(report.truncated - report.factorized)
    ratio = report.defect / report.tail_bound if report.tail_bound else 0.0
    print(f"\n{label}")
    print(f"  truncated product       = {report.truncated:.15g}")
    print(f"  completed product       = {report.completed:.15g}")
    print(f"  factorized product      = {report.factorized:.15g}")
    print(f"  factorization residual  = {residual:.3e}")
    print(f"  actual defect           = {report.defect:.15g}")
    print(f"  certified tail bound    = {report.tail_bound:.15g}")
    print(f"  defect / bound          = {ratio:.8f}")
    print(f"  normalized defect       = {report.normalized_defect:.15g}")
    print(f"  normalized bound        = {report.normalized_bound:.15g}")


def demonstrate_generic_weights() -> None:
    """Show geometric decay for weights 1/2, 1/3, and 1/5."""
    weights = [1.0 / 2.0, 1.0 / 3.0, 1.0 / 5.0]
    print("DEMO 1: exact defect and additive bound for q=(1/2,1/3,1/5)")
    for ceiling in range(0, 7):
        report = occupation_report(weights, ceiling)
        assert report.defect >= -1e-13
        assert report.defect <= report.tail_bound + 1e-13
        print(
            f"  N={ceiling:2d}  defect={report.defect:11.4e}  "
            f"bound={report.tail_bound:11.4e}  "
            f"normalized={report.normalized_defect:11.4e}"
        )


def demonstrate_prime_partition(limit: int, beta: float, ceiling: int) -> None:
    """Evaluate a finite prime-occupation partition and verify its bound."""
    primes, weights = prime_weights(limit, beta)
    report = occupation_report(weights, ceiling)
    print(f"\nDEMO 2: prime modes p < {limit}, beta={beta:g}, N={ceiling}")
    print(f"  retained primes: {primes}")
    print_report("Prime occupation report", report)
    assert math.isclose(report.truncated, report.factorized, rel_tol=2e-13, abs_tol=2e-13)
    assert report.defect <= report.tail_bound + 2e-13


def demonstrate_two_cutoffs(limit: int, beta: float, ceiling: int) -> None:
    """Compare a zeta target with mode and occupation errors separately."""
    if beta <= 1.0:
        print("\nDEMO 3 skipped: the zeta comparison requires beta > 1")
        return
    _, weights = prime_weights(limit, beta)
    report = occupation_report(weights, ceiling)
    zeta_approx, zeta_numerical_error = zeta_dirichlet(beta)
    prime_error = abs(zeta_approx - report.completed)
    occupation_bound = report.tail_bound
    total_error = abs(zeta_approx - report.truncated)
    split_bound = prime_error + occupation_bound
    print("\nDEMO 3: two-cutoff decomposition against the zeta Dirichlet series")
    print(f"  zeta approximation      = {zeta_approx:.15g}")
    print(f"  Dirichlet tail bound    = {zeta_numerical_error:.3e}")
    print(f"  observed prime error    = {prime_error:.15g}")
    print(f"  occupation bound        = {occupation_bound:.15g}")
    print(f"  observed total error    = {total_error:.15g}")
    print(f"  split upper bound       = {split_bound:.15g}")
    assert total_error <= split_bound + 2e-13


def demonstrate_adaptive_selection(limit: int, beta: float, tolerance: float) -> None:
    """Select the smallest ceiling meeting a relative occupation budget."""
    primes, weights = prime_weights(limit, beta)
    ceiling = find_occupation_ceiling(weights, tolerance)
    report = occupation_report(weights, ceiling)
    print("\nDEMO 4: adaptive occupation-ceiling selection")
    print(f"  primes below {limit}: {len(primes)} modes")
    print(f"  requested relative bound: {tolerance:.3e}")
    print(f"  least certified ceiling:  {ceiling}")
    print(f"  achieved relative bound:  {report.normalized_bound:.3e}")
    assert report.normalized_bound <= tolerance
    if ceiling > 0:
        previous = occupation_report(weights, ceiling - 1)
        assert previous.normalized_bound > tolerance


def main(argv: Iterable[str] | None = None) -> None:
    """Run all numerical demonstrations."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--limit", type=int, default=30, help="prime cutoff x")
    parser.add_argument("--beta", type=float, default=2.0, help="inverse temperature")
    parser.add_argument("--ceiling", type=int, default=3, help="occupation ceiling N")
    parser.add_argument(
        "--tolerance", type=float, default=1e-8, help="relative occupation budget"
    )
    args = parser.parse_args(list(argv) if argv is not None else None)
    demonstrate_generic_weights()
    demonstrate_prime_partition(args.limit, args.beta, args.ceiling)
    demonstrate_two_cutoffs(args.limit, args.beta, args.ceiling)
    demonstrate_adaptive_selection(args.limit, args.beta, args.tolerance)


if __name__ == "__main__":
    main()
