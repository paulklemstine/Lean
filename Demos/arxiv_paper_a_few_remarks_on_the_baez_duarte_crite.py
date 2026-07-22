#!/usr/bin/env python3
"""Numerical demonstrations of finite Báez–Duarte identities.

Only the Python standard library is required.  The script compares the defining
alternating binomial transform with its geometric-mixture form, checks the
first-difference law, illustrates monotonicity for nonnegative weights, and
verifies the divisor Möbius identity on a finite table.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import comb
from typing import Callable, Iterable, Sequence

Weight = Callable[[int], float]


def arithmetic_mobius(n: int) -> int:
    """Return the arithmetic Möbius function μ(n) for n >= 1."""
    if n < 1:
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


def divisors(n: int) -> list[int]:
    """List the positive divisors of n in increasing order."""
    if n < 1:
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


def sigma_power(n: int, s: int) -> int:
    """Return σ_s(n), the sum of s-th powers of positive divisors of n."""
    if s < 0:
        raise ValueError("s must be nonnegative")
    return sum(d**s for d in divisors(n))


def moment(weight: Weight, cutoff: int, j: int) -> float:
    """Compute M_j(N) = sum_{n=1}^N weight(n) / n^(2j+2)."""
    if cutoff < 0 or j < 0:
        raise ValueError("cutoff and j must be nonnegative")
    return sum(weight(n) / n ** (2 * j + 2) for n in range(1, cutoff + 1))


def coefficient_from_moments(weight: Weight, cutoff: int, k: int) -> float:
    """Evaluate C_k(N) from the alternating binomial definition."""
    if k < 0:
        raise ValueError("k must be nonnegative")
    return sum(
        (-1.0) ** j * comb(k, j) * moment(weight, cutoff, j)
        for j in range(k + 1)
    )


def coefficient_geometric(weight: Weight, cutoff: int, k: int) -> float:
    """Evaluate C_k(N) from the finite geometric-mixture identity."""
    if cutoff < 0 or k < 0:
        raise ValueError("cutoff and k must be nonnegative")
    return sum(
        weight(n) / n**2 * (1.0 - 1.0 / n**2) ** k
        for n in range(1, cutoff + 1)
    )


def difference_mixture(weight: Weight, cutoff: int, k: int) -> float:
    """Evaluate the reciprocal-fourth-power side of C_k(N)-C_{k+1}(N)."""
    if cutoff < 0 or k < 0:
        raise ValueError("cutoff and k must be nonnegative")
    return sum(
        weight(n) / n**4 * (1.0 - 1.0 / n**2) ** k
        for n in range(1, cutoff + 1)
    )


def coefficient_table_iterative(
    weights: Sequence[float], max_k: int
) -> list[float]:
    """Compute C_0,...,C_max_k by recursively evolving geometric modes."""
    if max_k < 0:
        raise ValueError("max_k must be nonnegative")
    modes = [w / (n * n) for n, w in enumerate(weights, start=1)]
    ratios = [1.0 - 1.0 / (n * n) for n in range(1, len(weights) + 1)]
    output: list[float] = []
    for _ in range(max_k + 1):
        output.append(sum(modes))
        modes = [value * ratio for value, ratio in zip(modes, ratios)]
    return output


def divisor_mobius_convolution(n: int, s: int) -> int:
    """Compute sum_{ab=n} μ(a) σ_s(b), which equals n^s."""
    return sum(arithmetic_mobius(a) * sigma_power(n // a, s) for a in divisors(n))


@dataclass(frozen=True)
class AuditRow:
    """One row in a numerical identity audit."""

    k: int
    direct: float
    geometric: float
    identity_error: float
    difference_error: float


def audit(weight: Weight, cutoff: int, max_k: int) -> list[AuditRow]:
    """Compare both coefficient formulas and the first-difference formula."""
    rows: list[AuditRow] = []
    for k in range(max_k + 1):
        direct = coefficient_from_moments(weight, cutoff, k)
        geometric = coefficient_geometric(weight, cutoff, k)
        next_geometric = coefficient_geometric(weight, cutoff, k + 1)
        rows.append(
            AuditRow(
                k=k,
                direct=direct,
                geometric=geometric,
                identity_error=abs(direct - geometric),
                difference_error=abs(
                    (geometric - next_geometric)
                    - difference_mixture(weight, cutoff, k)
                ),
            )
        )
    return rows


def print_audit(title: str, rows: Iterable[AuditRow]) -> None:
    """Print a formatted audit table."""
    print(f"\n{title}")
    print(" k       direct transform       geometric mixture    identity err   diff err")
    for row in rows:
        print(
            f"{row.k:2d}  {row.direct: .12e}  {row.geometric: .12e}  "
            f"{row.identity_error:.2e}    {row.difference_error:.2e}"
        )


def main() -> None:
    """Run three demonstrations and fail if their mathematical checks fail."""
    cutoff = 20
    max_k = 12

    positive_rows = audit(lambda _n: 1.0, cutoff, max_k)
    print_audit("Demo 1: nonnegative unit weights", positive_rows)
    positive_values = [row.geometric for row in positive_rows]
    assert all(value >= -1e-14 for value in positive_values)
    assert all(
        positive_values[k + 1] <= positive_values[k] + 1e-14
        for k in range(len(positive_values) - 1)
    )

    mobius_rows = audit(lambda n: float(arithmetic_mobius(n)), cutoff, max_k)
    print_audit("Demo 2: signed arithmetic Möbius weights", mobius_rows)

    iterative = coefficient_table_iterative([1.0] * cutoff, max_k)
    assert max(abs(a - b) for a, b in zip(iterative, positive_values)) < 1e-12
    print("\nDemo 3: iterative mode evolution agrees with direct geometric powers.")

    print("\nDivisor-lattice Möbius identity: sum_{ab=n} μ(a)σ_s(b)=n^s")
    for s in range(4):
        for n in range(1, 31):
            assert divisor_mobius_convolution(n, s) == n**s
        print(f"  checked exactly for s={s} and 1 <= n <= 30")

    max_identity_error = max(
        row.identity_error for row in positive_rows + mobius_rows
    )
    max_difference_error = max(
        row.difference_error for row in positive_rows + mobius_rows
    )
    print(f"\nMaximum floating identity discrepancy: {max_identity_error:.3e}")
    print(f"Maximum floating difference discrepancy: {max_difference_error:.3e}")


if __name__ == "__main__":
    main()
