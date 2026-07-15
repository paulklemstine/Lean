#!/usr/bin/env python3
"""Numerical demonstrations of exact uniform-guesswork prefactors.

The script uses only the Python standard library.  It evaluates exact formulas,
audits them by direct summation, prints convergence tables, and performs a
reproducible Monte Carlo experiment.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
import argparse
import random
from typing import Iterable, Sequence


@dataclass(frozen=True)
class GuessworkStatistics:
    """Exact statistics for a rank uniformly distributed on {1, ..., N}."""

    candidates: int
    mean: Fraction
    second_moment: Fraction
    variance: Fraction
    normalized_mean: Fraction
    normalized_second_moment: Fraction
    normalized_variance: Fraction
    squared_coefficient_variation: Fraction


def exact_statistics(base: int, dimension: int) -> GuessworkStatistics:
    """Return exact uniform-rank statistics for N = base**dimension."""
    if base < 1:
        raise ValueError("base must be at least 1")
    if dimension < 0:
        raise ValueError("dimension must be nonnegative")
    n = base**dimension
    mean = Fraction(n + 1, 2)
    second = Fraction((n + 1) * (2 * n + 1), 6)
    variance = Fraction(n * n - 1, 12)
    return GuessworkStatistics(
        candidates=n,
        mean=mean,
        second_moment=second,
        variance=variance,
        normalized_mean=mean / n,
        normalized_second_moment=second / (n * n),
        normalized_variance=variance / (n * n),
        squared_coefficient_variation=variance / (mean * mean),
    )


def direct_moments(candidate_count: int) -> tuple[Fraction, Fraction]:
    """Compute the first two moments by explicit enumeration for auditing."""
    if candidate_count < 1:
        raise ValueError("candidate_count must be positive")
    first = Fraction(sum(range(1, candidate_count + 1)), candidate_count)
    second = Fraction(
        sum(rank * rank for rank in range(1, candidate_count + 1)),
        candidate_count,
    )
    return first, second


def convergence_rows(base: int, dimensions: Iterable[int]) -> list[GuessworkStatistics]:
    """Evaluate exact statistics along a dimension schedule."""
    return [exact_statistics(base, dimension) for dimension in dimensions]


def monte_carlo_rank(candidate_count: int, trials: int, seed: int = 20260715) -> tuple[float, float]:
    """Estimate the normalized first and second moments by seeded simulation."""
    if candidate_count < 1 or trials < 1:
        raise ValueError("candidate_count and trials must be positive")
    generator = random.Random(seed)
    ranks = (generator.randint(1, candidate_count) for _ in range(trials))
    total = 0
    total_squares = 0
    for rank in ranks:
        total += rank
        total_squares += rank * rank
    return total / (trials * candidate_count), total_squares / (trials * candidate_count**2)


def print_convergence_table(base: int, dimensions: Sequence[int]) -> None:
    """Print normalized statistics and their limiting targets."""
    print(f"Uniform guesswork for base b={base}")
    print(" k          N      E[G]/N      E[G^2]/N^2    Var(G)/N^2     CV^2")
    for dimension, stats in zip(dimensions, convergence_rows(base, dimensions)):
        print(
            f"{dimension:2d} {stats.candidates:10d} "
            f"{float(stats.normalized_mean):12.9f} "
            f"{float(stats.normalized_second_moment):15.9f} "
            f"{float(stats.normalized_variance):15.9f} "
            f"{float(stats.squared_coefficient_variation):10.7f}"
        )
    print("limits             0.500000000     0.333333333     0.083333333  0.3333333")


def run_demo(base: int, dimensions: Sequence[int], trials: int) -> None:
    """Run formula, audit, convergence, and simulation demonstrations."""
    print_convergence_table(base, dimensions)

    audit_dimension = min(dimensions)
    audit = exact_statistics(base, audit_dimension)
    direct_first, direct_second = direct_moments(audit.candidates)
    assert direct_first == audit.mean
    assert direct_second == audit.second_moment
    print(
        f"\nDirect-sum audit at k={audit_dimension}: "
        f"mean={direct_first}, second moment={direct_second} (exact match)."
    )

    largest = exact_statistics(base, max(dimensions)).candidates
    estimate_first, estimate_second = monte_carlo_rank(largest, trials)
    print(f"\nSeeded Monte Carlo with N={largest:,} and {trials:,} trials:")
    print(f"  estimated E[G]/N     = {estimate_first:.6f} (target near 0.5)")
    print(f"  estimated E[G^2]/N^2 = {estimate_second:.6f} (target near 1/3)")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base", type=int, default=2, help="alphabet base b >= 1")
    parser.add_argument(
        "--dimensions", type=int, nargs="+", default=[1, 2, 4, 8, 12],
        help="nonnegative dimensions",
    )
    parser.add_argument("--trials", type=int, default=100_000)
    arguments = parser.parse_args()
    run_demo(arguments.base, arguments.dimensions, arguments.trials)
