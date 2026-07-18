#!/usr/bin/env python3
"""Numerical demonstrations for the literal anti-Fibonacci exclusion rule."""

from __future__ import annotations

from fractions import Fraction
from math import comb
from typing import Iterable


def least_positive_avoiding_sum(x: int, y: int) -> int:
    """Return the least positive integer unequal to x + y."""
    if x < 0 or y < 0:
        raise ValueError("x and y must be nonnegative")
    return 2 if x + y == 1 else 1


def anti_fibonacci_prefix(last_index: int) -> list[int]:
    """Generate A_0 through A_last_index by the literal recurrence."""
    if last_index < 0:
        raise ValueError("last_index must be nonnegative")
    if last_index == 0:
        return [1]
    values = [1, 1]
    for _ in range(2, last_index + 1):
        values.append(least_positive_avoiding_sum(values[-1], values[-2]))
    return values


def anti_fibonacci_closed_form(index: int) -> int:
    """Evaluate the proved closed form A_n = 1."""
    if index < 0:
        raise ValueError("index must be nonnegative")
    return 1


def normalized_value(index: int) -> Fraction:
    """Return the exact rational value A_n / n^2 for positive n."""
    if index <= 0:
        raise ValueError("index must be positive")
    return Fraction(anti_fibonacci_closed_form(index), index * index)


def sum_two_edges(vertex_count: int) -> list[tuple[int, int]]:
    """List edges {i,j} for which A_i + A_j = 2."""
    if vertex_count < 0:
        raise ValueError("vertex_count must be nonnegative")
    return [
        (i, j)
        for i in range(vertex_count)
        for j in range(i + 1, vertex_count)
        if anti_fibonacci_closed_form(i) + anti_fibonacci_closed_form(j) == 2
    ]


def format_fraction(value: Fraction) -> str:
    """Format an exact fraction compactly."""
    return str(value.numerator) if value.denominator == 1 else f"{value.numerator}/{value.denominator}"


def print_normalization_table(indices: Iterable[int]) -> None:
    """Print exact and floating-point quadratic normalizations."""
    print("\nQuadratic normalization")
    print(f"{'n':>12} {'A_n':>6} {'exact A_n/n^2':>24} {'decimal':>16}")
    for n in indices:
        value = normalized_value(n)
        print(
            f"{n:>12,} {anti_fibonacci_closed_form(n):>6} "
            f"{format_fraction(value):>24} {float(value):>16.12g}"
        )


def main() -> None:
    prefix = anti_fibonacci_prefix(16)
    print("Literal recurrence prefix A_0,...,A_16:")
    print(prefix)
    assert prefix == [1] * 17
    assert all(anti_fibonacci_closed_form(n) == prefix[n] for n in range(17))

    print_normalization_table([1, 2, 10, 100, 1_000, 1_000_000])
    millionth = normalized_value(1_000_000)
    assert millionth == Fraction(1, 1_000_000_000_000)
    print(f"\nExact millionth normalized value: {format_fraction(millionth)}")

    n = 8
    edges = sum_two_edges(n)
    expected = comb(n, 2)
    print(f"\nSum-to-two graph on {n} indices:")
    print(f"edges = {len(edges)}; complete-graph count = C({n},2) = {expected}")
    print(edges)
    assert len(edges) == expected


if __name__ == "__main__":
    main()
