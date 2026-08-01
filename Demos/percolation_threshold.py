#!/usr/bin/env python3
"""Numerical demonstrations for local percolation and finite threshold bounds.

The script uses only Python's standard library.  It exactly enumerates a triangular
face, compares site and bond events, checks complement duality, and illustrates
first- and second-moment bounds in a finite independent-edge model.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations
from math import comb
from random import Random
from typing import Callable, Iterable, Sequence


def triangle_crossing_probability(p: float) -> float:
    """Return the probability that at least two of three sites are open."""
    if not 0.0 <= p <= 1.0:
        raise ValueError("p must lie in [0, 1]")
    return 3.0 * p * p - 2.0 * p * p * p


def triangle_bond_spanning_probability(p: float) -> float:
    """Return the probability that three vertices are joined by three random bonds."""
    if not 0.0 <= p <= 1.0:
        raise ValueError("p must lie in [0, 1]")
    return 3.0 * p * p * (1.0 - p) + p**3


def exact_bernoulli_event_probability(
    p: float, size: int, event: Callable[[tuple[bool, ...]], bool]
) -> float:
    """Enumerate all Bernoulli configurations and sum the mass of an event."""
    total = 0.0
    for mask in range(1 << size):
        state = tuple(bool(mask & (1 << i)) for i in range(size))
        if event(state):
            opened = sum(state)
            total += p**opened * (1.0 - p) ** (size - opened)
    return total


def count_present_patterns(configuration: frozenset[int], patterns: Sequence[frozenset[int]]) -> int:
    """Count prescribed edge patterns contained in a configuration."""
    return sum(pattern <= configuration for pattern in patterns)


@dataclass(frozen=True)
class MomentReport:
    """Exact moments and probability of absence for a finite pattern family."""

    expectation: float
    variance: float
    probability_zero: float
    first_moment_upper_bound: float
    second_moment_upper_bound: float


def finite_pattern_moments(
    edge_count: int, p: float, patterns: Sequence[frozenset[int]]
) -> MomentReport:
    """Exactly enumerate an independent-edge space and compute moment bounds."""
    if edge_count < 0 or not 0.0 <= p <= 1.0:
        raise ValueError("invalid edge count or probability")
    masses_and_counts: list[tuple[float, int]] = []
    for mask in range(1 << edge_count):
        configuration = frozenset(i for i in range(edge_count) if mask & (1 << i))
        mass = p ** len(configuration) * (1.0 - p) ** (edge_count - len(configuration))
        masses_and_counts.append((mass, count_present_patterns(configuration, patterns)))
    expectation = sum(mass * count for mass, count in masses_and_counts)
    variance = sum(mass * (count - expectation) ** 2 for mass, count in masses_and_counts)
    probability_zero = sum(mass for mass, count in masses_and_counts if count == 0)
    first_bound = sum(p ** len(pattern) for pattern in patterns)
    second_bound = variance / expectation**2 if expectation else float("inf")
    return MomentReport(expectation, variance, probability_zero, first_bound, second_bound)


def monte_carlo_triangle(p: float, trials: int = 100_000, seed: int = 20260801) -> float:
    """Estimate the three-site crossing probability by reproducible simulation."""
    rng = Random(seed)
    successes = sum(sum(rng.random() < p for _ in range(3)) >= 2 for _ in range(trials))
    return successes / trials


def print_local_table() -> None:
    """Print exact and simulated local probabilities across the Bernoulli interval."""
    print("Triangular-face crossing and bond spanning")
    print(" p     site C(p)   bond B(p)   C(1-p)   1-C(p)   simulation")
    for p in (0.1, 0.25, 0.5, 0.75, 0.9):
        site = triangle_crossing_probability(p)
        bond = triangle_bond_spanning_probability(p)
        complement = triangle_crossing_probability(1.0 - p)
        simulation = monte_carlo_triangle(p, trials=40_000)
        print(f"{p:4.2f}   {site:9.6f}   {bond:9.6f}   {complement:8.6f}   "
              f"{1.0-site:8.6f}   {simulation:10.6f}")


def print_pattern_example() -> None:
    """Demonstrate exact expectation and first/second-moment inequalities."""
    # Four potential edges arranged cyclically; each adjacent pair is a target pattern.
    patterns = [frozenset(pair) for pair in ((0, 1), (1, 2), (2, 3), (3, 0))]
    report = finite_pattern_moments(4, 0.35, patterns)
    print("\nFour-edge pattern family at p = 0.35")
    print(f"Expected number of present patterns: {report.expectation:.8f}")
    print(f"Sum of individual appearance probabilities: {report.first_moment_upper_bound:.8f}")
    print(f"Probability that no pattern appears: {report.probability_zero:.8f}")
    print(f"Variance: {report.variance:.8f}")
    print(f"Second-moment upper bound on absence: {report.second_moment_upper_bound:.8f}")
    assert abs(report.expectation - report.first_moment_upper_bound) < 1e-12
    assert report.probability_zero <= report.second_moment_upper_bound + 1e-12


def main() -> None:
    """Run all demonstrations and internal numerical checks."""
    for k in range(101):
        p = k / 100.0
        site = triangle_crossing_probability(p)
        exact = exact_bernoulli_event_probability(p, 3, lambda state: sum(state) >= 2)
        assert abs(site - exact) < 1e-12
        assert abs(site - triangle_bond_spanning_probability(p)) < 1e-12
        assert abs(triangle_crossing_probability(1.0 - p) - (1.0 - site)) < 1e-12
    print_local_table()
    print_pattern_example()


if __name__ == "__main__":
    main()
