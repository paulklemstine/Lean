#!/usr/bin/env python3
"""Numerical demonstrations for the Property-B view of hypergraph Ramsey avoidance."""

from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations
from math import comb
from random import Random
from typing import Dict, Iterable, Iterator, Sequence, Tuple

Subset = Tuple[int, ...]
Coloring = Dict[Subset, int]


@dataclass(frozen=True)
class ThresholdReport:
    n: int
    r: int
    k: int
    variables: int
    constraints: int
    edge_size: int
    threshold: int
    expected_bad_sets: float
    certified_avoidable: bool


def subsets(n: int, size: int) -> Iterator[Subset]:
    """Yield all subsets of range(n) of a fixed size as sorted tuples."""
    yield from combinations(range(n), size)


def threshold_report(n: int, r: int, k: int) -> ThresholdReport:
    """Compute the exact incidence counts and first-moment certificate."""
    if not (0 <= r <= k <= n):
        raise ValueError("expected 0 <= r <= k <= n")
    variables = comb(n, r)
    constraints = comb(n, k)
    edge_size = comb(k, r)
    threshold = 2 ** (edge_size - 1)
    return ThresholdReport(
        n=n,
        r=r,
        k=k,
        variables=variables,
        constraints=constraints,
        edge_size=edge_size,
        threshold=threshold,
        expected_bad_sets=constraints / threshold,
        certified_avoidable=constraints < threshold,
    )


def random_coloring(n: int, r: int, rng: Random) -> Coloring:
    """Color every r-subset independently with a uniformly random bit."""
    return {edge: rng.randrange(2) for edge in subsets(n, r)}


def monochromatic_k_sets(
    n: int, r: int, k: int, coloring: Coloring
) -> list[Subset]:
    """Return all k-sets whose internal r-subsets have a common color."""
    bad: list[Subset] = []
    for candidate in subsets(n, k):
        colors = {
            coloring[tuple(edge)] for edge in combinations(candidate, r)
        }
        if len(colors) <= 1:
            bad.append(candidate)
    return bad


def monte_carlo(
    n: int, r: int, k: int, trials: int, seed: int = 20260719
) -> tuple[float, int]:
    """Estimate the average bad-set count and return the observed minimum."""
    if trials <= 0:
        raise ValueError("trials must be positive")
    rng = Random(seed)
    counts = [
        len(monochromatic_k_sets(n, r, k, random_coloring(n, r, rng)))
        for _ in range(trials)
    ]
    return sum(counts) / trials, min(counts)


def incidence_overlap(r: int, first: Sequence[int], second: Sequence[int]) -> int:
    """Count shared r-subsets of two candidate sets."""
    intersection_size = len(set(first).intersection(second))
    return comb(intersection_size, r)


def print_report(report: ThresholdReport) -> None:
    verdict = "YES" if report.certified_avoidable else "NO"
    print(f"Parameters (n,r,k) = ({report.n},{report.r},{report.k})")
    print(f"  colored r-subsets:       {report.variables}")
    print(f"  candidate k-sets:        {report.constraints}")
    print(f"  r-subsets per candidate: {report.edge_size}")
    print(f"  Property-B threshold:    {report.threshold}")
    print(f"  expected bad k-sets:     {report.expected_bad_sets:.6f}")
    print(f"  first-moment certificate: {verdict}")


def main() -> None:
    print("PROPERTY-B RAMSEY AVOIDANCE THRESHOLDS")
    for n, r, k in [(5, 2, 3), (11, 3, 5), (12, 3, 5), (13, 3, 4)]:
        print_report(threshold_report(n, r, k))
        print()

    average, minimum = monte_carlo(11, 3, 5, trials=250)
    theory = threshold_report(11, 3, 5).expected_bad_sets
    print("MONTE CARLO: triples on 11 vertices, candidate 5-sets")
    print(f"  theoretical expected bad sets: {theory:.6f}")
    print(f"  sample average over 250 trials: {average:.6f}")
    print(f"  smallest observed count:        {minimum}")

    first = (0, 1, 2, 3, 4)
    second = (0, 1, 2, 5, 6)
    print("\nINCIDENCE OVERLAP")
    print(f"  {first} and {second} share {incidence_overlap(3, first, second)} triple(s)")


if __name__ == "__main__":
    main()
