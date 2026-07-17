#!/usr/bin/env python3
"""Numerical demonstrations for singleton sum avoidance and triangular growth."""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from math import gcd
from typing import Iterable, List


def least_positive_avoiding_sum(x: int, y: int) -> int:
    """Return the least positive integer unequal to x + y.

    The mathematical results concern positive predecessors. Validation is kept
    explicit so the boundary case x + y == 1 cannot be silently confused with
    that setting.
    """
    if x <= 0 or y <= 0:
        raise ValueError("x and y must be positive integers")
    forbidden = x + y
    candidate = 1
    while candidate == forbidden:
        candidate += 1
    return candidate


def literal_sequence(length: int) -> List[int]:
    """Generate the literal anti-Fibonacci sequence with initial values 1, 1."""
    if length < 0:
        raise ValueError("length must be nonnegative")
    if length == 0:
        return []
    if length == 1:
        return [1]
    values = [1, 1]
    while len(values) < length:
        values.append(least_positive_avoiding_sum(values[-2], values[-1]))
    return values


def displayed_sequence(length: int) -> List[int]:
    """Generate D(0)=1 and D(n+1)=D(n)+n for n >= 0."""
    if length < 0:
        raise ValueError("length must be nonnegative")
    values: List[int] = []
    current = 1
    for n in range(length):
        values.append(current)
        current += n
    return values


def displayed_closed(n: int) -> int:
    """Evaluate D(n) = 1 + n(n-1)/2 exactly."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    return 1 + n * (n - 1) // 2


def quarter_square(n: int) -> int:
    """Evaluate floor(n^2/4) for n >= 0."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    return n * n // 4


@dataclass(frozen=True)
class BoundWitness:
    """A certificate that D(n) exceeds floor(n^2/4) by more than C."""

    bound: int
    k: int
    index: int
    displayed_value: int
    quarter_square_value: int
    discrepancy: int


def quarter_square_bound_witness(bound: int) -> BoundWitness:
    """Construct the even-index witness n=2(C+2) for a proposed bound C."""
    if bound < 0:
        raise ValueError("bound must be nonnegative")
    k = bound + 2
    n = 2 * k
    d = displayed_closed(n)
    q = quarter_square(n)
    discrepancy = d - q
    assert discrepancy == k * (k - 1) + 1
    assert discrepancy > bound
    return BoundWitness(bound, k, n, d, q, discrepancy)


def normalized_displayed(n: int) -> Fraction:
    """Return the exact rational value D(n)/n^2 for n > 0."""
    if n <= 0:
        raise ValueError("n must be positive")
    return Fraction(displayed_closed(n), n * n)


def verify_prefix(length: int) -> None:
    """Check the defining identities throughout a finite prefix."""
    literal = literal_sequence(length)
    assert all(value == 1 for value in literal)
    assert all(gcd(literal[i + 1], literal[i]) == 1 for i in range(len(literal) - 1))

    displayed = displayed_sequence(length)
    for n, value in enumerate(displayed):
        assert value == displayed_closed(n)
        assert 2 * value == n * (n - 1) + 2
        if n + 1 < length:
            assert displayed[n + 1] == value + n


def format_fraction(value: Fraction, digits: int = 12) -> str:
    """Format an exact fraction with its decimal approximation."""
    return f"{value.numerator}/{value.denominator} = {float(value):.{digits}f}"


def main() -> None:
    """Run demonstrations of all key identities and asymptotic comparisons."""
    verify_prefix(10_000)

    print("Literal singleton-avoidance sequence (first 12 terms):")
    print(literal_sequence(12))
    print("Every term is 1; every consecutive ratio is therefore exactly 1.\n")

    print("Displayed increment sequence (first 12 terms):")
    print(displayed_sequence(12))
    print("Closed-form checks: D(6) =", displayed_closed(6), ", D(8) =", displayed_closed(8))
    print()

    print("Normalized values D(n)/n^2 (approaching 1/2):")
    for n in (10, 100, 1_000, 1_000_000):
        ratio = normalized_displayed(n)
        print(f"  n={n:>9,}: {format_fraction(ratio)}")
    print()

    print("Explicit witnesses against bounded quarter-square discrepancy:")
    for bound in (0, 1, 10, 100, 10_000):
        witness = quarter_square_bound_witness(bound)
        print(
            f"  C={bound:>5}: n={witness.index:>6}, "
            f"D(n)-floor(n^2/4)={witness.discrepancy} > C"
        )

    print("\nAll finite checks passed; the displayed values agree with the exact formulas.")


if __name__ == "__main__":
    main()
