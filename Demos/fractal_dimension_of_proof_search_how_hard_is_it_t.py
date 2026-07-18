#!/usr/bin/env python3
"""Exact numerical demonstrations for periodically pruned search trees."""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from math import log2
from typing import FrozenSet, Iterable, List, Tuple


@dataclass(frozen=True)
class PeriodicSearch:
    """A binary search profile with periodically free decision levels."""

    period: int
    free_residues: FrozenSet[int]

    def __post_init__(self) -> None:
        if self.period < 1:
            raise ValueError("period must be positive")
        if any(r < 0 or r >= self.period for r in self.free_residues):
            raise ValueError("free residues must lie between 0 and period - 1")

    @property
    def dimension(self) -> Fraction:
        """Return the exact limiting normalized dimension."""
        return Fraction(len(self.free_residues), self.period)

    @property
    def codimension(self) -> Fraction:
        """Return the exact density of forced levels."""
        return 1 - self.dimension

    def free_count(self, depth: int) -> int:
        """Count free levels strictly below ``depth`` in O(period) time."""
        if depth < 0:
            raise ValueError("depth must be nonnegative")
        complete, remainder = divmod(depth, self.period)
        return complete * len(self.free_residues) + sum(
            1 for r in self.free_residues if r < remainder
        )

    def successful_prefix_count(self, depth: int) -> int:
        """Return the exact number of viable binary prefixes at a depth."""
        return 1 << self.free_count(depth)

    def finite_estimate(self, depth: int) -> Fraction:
        """Return log2(N(depth))/depth exactly as a rational number."""
        if depth < 1:
            raise ValueError("depth must be positive")
        return Fraction(self.free_count(depth), depth)


def realize_rational_dimension(p: int, q: int) -> PeriodicSearch:
    """Construct a canonical periodic profile of exact dimension p/q."""
    if q < 1 or p < 0 or p > q:
        raise ValueError("require 0 <= p <= q and q >= 1")
    return PeriodicSearch(q, frozenset(range(p)))


def estimate_table(model: PeriodicSearch, max_depth: int) -> List[Tuple[int, int, Fraction]]:
    """Tabulate depth, viable-prefix count, and exact finite estimate."""
    if max_depth < 1:
        raise ValueError("max_depth must be positive")
    return [
        (n, model.successful_prefix_count(n), model.finite_estimate(n))
        for n in range(1, max_depth + 1)
    ]


def monte_carlo_estimate(
    model: PeriodicSearch, depth: int, samples: int, seed: int = 0
) -> float:
    """Estimate dimension by uniform path sampling at a fixed depth.

    A sampled word survives precisely when every forced-level bit is zero.
    Laplace smoothing prevents the logarithm of zero in rare-event samples.
    """
    import random

    if depth < 1 or samples < 1:
        raise ValueError("depth and samples must be positive")
    rng = random.Random(seed)
    successes = 0
    for _ in range(samples):
        survives = True
        for level in range(depth):
            bit = rng.randrange(2)
            if level % model.period not in model.free_residues and bit != 0:
                survives = False
                break
        successes += int(survives)
    survival_probability = (successes + 0.5) / (samples + 1.0)
    return 1.0 + log2(survival_probability) / depth


def print_model(model: PeriodicSearch, depths: Iterable[int]) -> None:
    """Print exact counts and estimates for selected depths."""
    print(
        f"period={model.period}, free={sorted(model.free_residues)}, "
        f"dimension={model.dimension}, codimension={model.codimension}"
    )
    print("depth  free  successful  ambient  estimate")
    for depth in depths:
        free = model.free_count(depth)
        successful = model.successful_prefix_count(depth)
        print(
            f"{depth:5d}  {free:4d}  {successful:10d}  "
            f"{1 << depth:7d}  {model.finite_estimate(depth)}"
        )


def main() -> None:
    """Run three reproducible demonstrations of the central results."""
    print("Example 1: two free levels in each period of three")
    two_thirds = PeriodicSearch(3, frozenset({0, 1}))
    print_model(two_thirds, [3, 6, 9, 12])
    assert two_thirds.successful_prefix_count(12) == 256
    assert two_thirds.finite_estimate(12) == Fraction(2, 3)

    print("\nExample 2: rational realization and exact period boundaries")
    three_fifths = realize_rational_dimension(3, 5)
    print_model(three_fifths, [5, 10, 15, 20])
    assert all(
        three_fifths.finite_estimate(5 * k) == Fraction(3, 5)
        for k in range(1, 5)
    )

    print("\nExample 3: finite-scale oscillation and Monte Carlo calibration")
    one_half = PeriodicSearch(2, frozenset({0}))
    print_model(one_half, range(1, 9))
    estimate = monte_carlo_estimate(one_half, depth=12, samples=100_000, seed=7)
    print(f"Monte Carlo estimate at depth 12: {estimate:.5f}")
    print("Exact dimension: 0.50000")
    print(
        "The same geometric profile can be paired with any separately "
        "designated terminal length, for example 1000."
    )


if __name__ == "__main__":
    main()
