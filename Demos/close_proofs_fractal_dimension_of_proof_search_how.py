#!/usr/bin/env python3
"""Numerical demonstrations for periodically pruned binary search profiles.

The program counts free levels directly, avoiding enumeration of 2**n words.
It demonstrates rational dimension realization, exact complete-period estimates,
codimension, convergence at arbitrary depths, and non-determination of an
independently attached shortest-solution length.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from math import log2
from typing import Iterable, Sequence


@dataclass(frozen=True)
class PeriodicProfile:
    """A binary profile with selected free residues in each period."""

    period: int
    free_residues: frozenset[int]

    def __post_init__(self) -> None:
        if self.period < 1:
            raise ValueError("period must be positive")
        if any(r < 0 or r >= self.period for r in self.free_residues):
            raise ValueError("free residues must lie between 0 and period - 1")

    @property
    def dimension(self) -> Fraction:
        """Exact limiting dimension."""
        return Fraction(len(self.free_residues), self.period)

    @property
    def codimension(self) -> Fraction:
        """Exact density of constrained levels."""
        return 1 - self.dimension

    def free_count(self, depth: int) -> int:
        """Count free levels among levels 0,...,depth-1 in O(period) time."""
        if depth < 0:
            raise ValueError("depth must be nonnegative")
        full_periods, remainder = divmod(depth, self.period)
        partial = sum(1 for r in self.free_residues if r < remainder)
        return full_periods * len(self.free_residues) + partial

    def viable_prefix_count(self, depth: int) -> int:
        """Return the exact number 2**free_count(depth) of viable prefixes."""
        return 1 << self.free_count(depth)

    def finite_estimate(self, depth: int) -> Fraction:
        """Return log_2(N(depth))/depth exactly as a rational number."""
        if depth < 1:
            raise ValueError("depth must be positive")
        return Fraction(self.free_count(depth), depth)


def realize_rational_dimension(p: int, q: int) -> PeriodicProfile:
    """Construct the canonical period-q profile of dimension p/q."""
    if q < 1 or p < 0 or p > q:
        raise ValueError("require 0 <= p <= q and q >= 1")
    return PeriodicProfile(q, frozenset(range(p)))


def dimension_table(profile: PeriodicProfile, max_depth: int) -> list[tuple[int, int, Fraction]]:
    """Return (depth, viable-prefix count, finite estimate) rows."""
    if max_depth < 1:
        raise ValueError("max_depth must be positive")
    return [
        (n, profile.viable_prefix_count(n), profile.finite_estimate(n))
        for n in range(1, max_depth + 1)
    ]


def ascii_plot(profile: PeriodicProfile, max_depth: int, width: int = 48) -> str:
    """Plot finite estimates on a normalized horizontal scale from 0 to 1."""
    rows: list[str] = []
    target = float(profile.dimension)
    target_col = round(target * width)
    for n, _, estimate in dimension_table(profile, max_depth):
        estimate_col = round(float(estimate) * width)
        chars = [" "] * (width + 1)
        chars[target_col] = "|"
        chars[estimate_col] = "*" if estimate_col != target_col else "X"
        marker = "period" if n % profile.period == 0 else ""
        rows.append(f"{n:3d} [{''.join(chars)}] {float(estimate):.5f} {marker}")
    return "\n".join(rows)


def demonstrate_benchmark(p: int, q: int, periods: int) -> None:
    """Print one exact periodic benchmark and verify its identities."""
    if periods < 1:
        raise ValueError("periods must be positive")
    profile = realize_rational_dimension(p, q)
    depth = q * periods
    estimate = profile.finite_estimate(depth)
    assert estimate == profile.dimension
    assert profile.codimension == Fraction(q - p, q)

    print("RATIONAL DIMENSION AND EXACT COMPLETE-PERIOD BENCHMARK")
    print(f"free pattern: {p} free levels in each period of {q}")
    print(f"target dimension: {profile.dimension} = {float(profile.dimension):.6f}")
    print(f"codimension: {profile.codimension} = {float(profile.codimension):.6f}")
    print(f"benchmark depth: {depth}")
    print(f"free levels: {profile.free_count(depth)}")
    print(f"viable prefixes: {profile.viable_prefix_count(depth)}")
    print(f"finite estimate: {estimate} (exactly the limiting dimension)\n")


def demonstrate_non_determination(
    profile: PeriodicProfile, lengths: Sequence[int]
) -> None:
    """Show that attaching different lengths does not alter profile statistics."""
    if any(length < 0 for length in lengths):
        raise ValueError("lengths must be nonnegative")
    depth = profile.period * 4
    geometry = (profile.dimension, profile.finite_estimate(depth))
    print("NON-DETERMINATION OF INDEPENDENT SHORTEST LENGTH")
    print(f"fixed geometry: dimension={geometry[0]}, estimate at depth {depth}={geometry[1]}")
    for length in lengths:
        assert (profile.dimension, profile.finite_estimate(depth)) == geometry
        print(f"attached shortest length {length:5d} -> unchanged geometry {geometry}")
    print()


def main() -> None:
    profile = realize_rational_dimension(2, 3)
    demonstrate_benchmark(2, 3, periods=4)

    print("FINITE-DEPTH OSCILLATION; X MARKS THE TARGET")
    print(ascii_plot(profile, max_depth=18))
    print()

    demonstrate_non_determination(profile, lengths=[0, 5, 1000])

    # Independent numerical check using the literal logarithmic definition.
    for depth, count, exact_estimate in dimension_table(profile, 30):
        numerical = log2(count) / depth
        assert abs(numerical - float(exact_estimate)) < 1e-12
        if depth % profile.period == 0:
            assert exact_estimate == Fraction(2, 3)
    print("All exact identities and logarithmic cross-checks passed.")


if __name__ == "__main__":
    main()
