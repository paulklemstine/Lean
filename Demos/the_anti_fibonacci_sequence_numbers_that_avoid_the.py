#!/usr/bin/env python3
"""Exact numerical demonstrations for the shifted triangular sequence.

The sequence is A(0) = 1 and A(n + 1) = A(n) + n, hence
A(n) = 1 + n(n - 1)/2.  This script uses integer arithmetic for all
identities and floating point only for human-readable ratios.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from math import isqrt
from typing import Iterable, Optional


@dataclass(frozen=True)
class Snapshot:
    """Numerical data at one sequence index."""

    index: int
    value: int
    normalized: float
    quarter_discrepancy: Fraction
    next_ratio: Fraction


def anti_fibonacci(n: int) -> int:
    """Return A(n) = 1 + n(n-1)/2 exactly in O(1) arithmetic operations."""
    if n < 0:
        raise ValueError("the index must be nonnegative")
    return 1 + n * (n - 1) // 2


def fibonacci(n: int) -> int:
    """Return F(n) by fast doubling in O(log n) recursive steps."""
    if n < 0:
        raise ValueError("the index must be nonnegative")

    def pair(k: int) -> tuple[int, int]:
        if k == 0:
            return (0, 1)
        a, b = pair(k // 2)
        c = a * (2 * b - a)
        d = a * a + b * b
        return (d, c + d) if k % 2 else (c, d)

    return pair(n)[0]


def value_index(m: int) -> Optional[int]:
    """Return a positive index n with A(n)=m, or None if no index exists.

    The repeated value 1 is reported at index 1; it also occurs at index 0.
    """
    if m < 1:
        return None
    discriminant = 8 * m - 7
    root = isqrt(discriminant)
    if root * root != discriminant or root % 2 == 0:
        return None
    return (root + 1) // 2


def consecutive_sum_index(m: int) -> Optional[int]:
    """Return n when m=A(n)+A(n+1), or None if m is outside the spectrum."""
    if m < 2:
        return None
    root = isqrt(m - 2)
    return root if root * root == m - 2 else None


def snapshot(n: int) -> Snapshot:
    """Build an exact/asymptotic diagnostic record at index n > 0."""
    if n <= 0:
        raise ValueError("snapshot requires a positive index")
    value = anti_fibonacci(n)
    return Snapshot(
        index=n,
        value=value,
        normalized=value / (n * n),
        quarter_discrepancy=Fraction(value) - Fraction(n * n, 4),
        next_ratio=Fraction(anti_fibonacci(n + 1), value),
    )


def verify_identities(indices: Iterable[int]) -> None:
    """Assert the recurrence, both square identities, and Fibonacci domination."""
    for n in indices:
        a = anti_fibonacci(n)
        b = anti_fibonacci(n + 1)
        assert b - a == n
        assert a + b == n * n + 2
        assert 8 * a - 7 == (2 * n - 1) ** 2
        if n >= 6:
            assert a < fibonacci(2 * n + 1)


def print_table() -> None:
    """Print representative values and asymptotic diagnostics."""
    print("Shifted triangular anti-Fibonacci diagnostics")
    print(" n          A(n)                 A(n)/n^2       A(n)-n^2/4")
    for n in (1, 2, 5, 10, 100, 1_000, 1_000_000):
        s = snapshot(n)
        print(
            f"{n:>8,d}  {s.value:>20,d}  {s.normalized:>16.12f}  "
            f"{float(s.quarter_discrepancy):>16.3f}"
        )


def print_spectra() -> None:
    """Print the first values and consecutive sums with their square witnesses."""
    print("\nFirst terms and shifted-square consecutive sums")
    for n in range(8):
        a = anti_fibonacci(n)
        b = anti_fibonacci(n + 1)
        print(f"n={n}: A(n)={a}, A(n)+A(n+1)={a+b}={n}^2+2")


def main() -> None:
    """Run all exact checks and display the principal numerical examples."""
    verify_identities(range(0, 101))
    assert anti_fibonacci(1_000_000) == 499_999_500_001
    assert value_index(16) == 6
    assert value_index(15) is None
    assert consecutive_sum_index(38) == 6
    assert consecutive_sum_index(39) is None

    print_table()
    print_spectra()
    print("\nExact checks passed for indices 0 through 100.")
    print("A(1,000,000) =", f"{anti_fibonacci(1_000_000):,}")


if __name__ == "__main__":
    main()
