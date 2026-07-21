#!/usr/bin/env python3
"""Numerical illustrations of Cantor, beth growth, and successor asymmetry.

The computations are finite models of the structural arguments. They do not
attempt to decide the continuum hypothesis or simulate transfinite cardinals.
"""

from __future__ import annotations

from itertools import combinations
from math import log10
from typing import Iterable, Sequence, TypeVar

T = TypeVar("T")


def diagonal_escape(rows: Sequence[Sequence[int]]) -> tuple[int, ...]:
    """Return the complemented diagonal of a square Boolean matrix.

    Row i is viewed as the characteristic vector of the i-th listed subset.
    The result differs from row i at coordinate i, hence from every row.
    """
    n = len(rows)
    if any(len(row) != n for row in rows):
        raise ValueError("rows must form a square matrix")
    if any(bit not in (0, 1) for row in rows for bit in row):
        raise ValueError("matrix entries must be 0 or 1")
    return tuple(1 - rows[i][i] for i in range(n))


def power_set(items: Sequence[T]) -> list[tuple[T, ...]]:
    """Enumerate every subset of a finite sequence exactly once."""
    return [
        subset
        for size in range(len(items) + 1)
        for subset in combinations(items, size)
    ]


def finite_hartogs_witness(n: int) -> tuple[dict[int, int], str]:
    """Model X -> H(X) with n points mapping into n+1 points.

    Returns the inclusion and an explanation of why no reverse injection exists.
    """
    if n < 0:
        raise ValueError("n must be nonnegative")
    injection = {i: i for i in range(n)}
    obstruction = (
        f"A reverse map would inject {n + 1} distinct points into {n} slots, "
        "contradicting the pigeonhole principle."
    )
    return injection, obstruction


def beth_tower_digits(initial: int, steps: int) -> list[tuple[int, int | None]]:
    """Compute finite analogues k -> 2^k while exact arithmetic is practical.

    Each pair contains a value and, for its successor, the number of decimal
    digits. Exact successors are retained only while their exponent is at most
    100,000, preventing accidental resource exhaustion.
    """
    if initial < 0 or steps < 0:
        raise ValueError("initial and steps must be nonnegative")
    values: list[tuple[int, int | None]] = []
    current = initial
    for _ in range(steps + 1):
        if current > 100_000:
            break
        successor_digits = int(current * log10(2)) + 1 if current > 0 else 1
        values.append((current, successor_digits))
        current = 2**current
    return values


def demo_diagonal() -> None:
    """Display a list of subsets and the subset forced outside that list."""
    rows = [
        (0, 1, 1, 0),
        (1, 1, 0, 0),
        (0, 0, 0, 1),
        (1, 0, 1, 1),
    ]
    escaped = diagonal_escape(rows)
    print("Diagonal escape")
    for i, row in enumerate(rows):
        marker = "differs" if escaped != row else "ERROR"
        print(f"  row {i}: {row}; escaped vector {marker} at coordinate {i}")
    print(f"  escaped subset: {escaped}\n")


def demo_power_growth() -> None:
    """Print finite power-set sizes and verify strict growth."""
    print("Finite power-set growth")
    for n in range(0, 11):
        subsets = 2**n
        assert subsets > n
        print(f"  |X|={n:2d}, |P(X)|=2^{n}={subsets:4d}, gap={subsets - n:4d}")
    concrete = power_set(("a", "b", "c"))
    print(f"  P({{'a','b','c'}}) has {len(concrete)} members: {concrete}\n")


def demo_successor_and_beth() -> None:
    """Contrast finite immediate succession with finite power-set growth."""
    print("Successor and power-set comparison")
    for n in range(1, 9):
        injection, obstruction = finite_hartogs_witness(n)
        print(
            f"  n={n}: successor size={n + 1}, power-set size={2**n}; "
            f"forward injection={injection}"
        )
        assert len(set(injection.values())) == n
    print(f"  {finite_hartogs_witness(8)[1]}\n")

    print("Finite beth-style iteration from 2")
    for level, (value, next_digits) in enumerate(beth_tower_digits(2, 4)):
        rendered = str(value) if value < 10**30 else f"an integer with {len(str(value))} digits"
        print(f"  level {level}: {rendered}; its power of two has {next_digits} digits")


def main() -> None:
    demo_diagonal()
    demo_power_growth()
    demo_successor_and_beth()


if __name__ == "__main__":
    main()
