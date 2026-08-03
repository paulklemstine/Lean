#!/usr/bin/env python3
"""Numerical demonstrations of Erdős–Rényi threshold phenomena.

The program uses only the Python standard library. It compares exact moment
formulas with Monte Carlo estimates, computes the Poisson survival fixed point,
and samples the giant-component and connectivity transitions.
"""

from __future__ import annotations

import argparse
import itertools
import math
import random
from dataclasses import dataclass
from typing import Iterable, Sequence

Edge = tuple[int, int]


class DisjointSet:
    """Union-find structure for connected-component calculations."""

    def __init__(self, n: int) -> None:
        self.parent = list(range(n))
        self.size = [1] * n

    def find(self, x: int) -> int:
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x

    def union(self, a: int, b: int) -> None:
        ra, rb = self.find(a), self.find(b)
        if ra == rb:
            return
        if self.size[ra] < self.size[rb]:
            ra, rb = rb, ra
        self.parent[rb] = ra
        self.size[ra] += self.size[rb]

    def component_sizes(self) -> list[int]:
        return sorted(
            (self.size[v] for v in range(len(self.parent)) if self.find(v) == v),
            reverse=True,
        )


@dataclass(frozen=True)
class GraphSummary:
    largest_fraction: float
    connected: bool
    isolated: int
    triangles: int


def sample_graph(n: int, p: float, rng: random.Random) -> set[Edge]:
    """Sample all edges of G(n,p) in O(n^2) time."""
    if n < 1 or not 0.0 <= p <= 1.0:
        raise ValueError("require n >= 1 and 0 <= p <= 1")
    return {
        (u, v)
        for u in range(n)
        for v in range(u + 1, n)
        if rng.random() < p
    }


def summarize_graph(n: int, edges: set[Edge]) -> GraphSummary:
    """Compute component, isolation, and triangle statistics."""
    dsu = DisjointSet(n)
    neighbors = [set() for _ in range(n)]
    for u, v in edges:
        dsu.union(u, v)
        neighbors[u].add(v)
        neighbors[v].add(u)
    sizes = dsu.component_sizes()
    triangles = sum(
        1
        for a in range(n)
        for b in neighbors[a]
        if a < b
        for c in neighbors[a].intersection(neighbors[b])
        if b < c
    )
    return GraphSummary(
        largest_fraction=sizes[0] / n,
        connected=len(sizes) == 1,
        isolated=sum(not ns for ns in neighbors),
        triangles=triangles,
    )


def survival_probability(lam: float, tolerance: float = 1e-13) -> float:
    """Return the positive solution of rho = 1-exp(-lam*rho), or zero."""
    if lam <= 0.0:
        raise ValueError("lambda must be positive")
    if lam <= 1.0:
        return 0.0
    rho = 1.0 - math.exp(-lam)  # positive start selects the nonzero root
    for _ in range(100_000):
        nxt = 1.0 - math.exp(-lam * rho)
        if abs(nxt - rho) <= tolerance:
            return nxt
        rho = nxt
    raise RuntimeError("fixed-point iteration did not converge")


def exact_pattern_moments(patterns: Sequence[frozenset[Edge]], p: float) -> tuple[float, float, float]:
    """Compute E[X], E[X^2], and the second-moment appearance lower bound."""
    if not 0.0 <= p <= 1.0:
        raise ValueError("p must lie in [0,1]")
    first = sum(p ** len(pattern) for pattern in patterns)
    second = sum(
        p ** len(left | right) for left in patterns for right in patterns
    )
    lower = first * first / second if second > 0.0 else 0.0
    return first, second, lower


def triangle_patterns(n: int) -> list[frozenset[Edge]]:
    """List the edge sets of all unlabelled triangles on n vertices."""
    return [
        frozenset(((a, b), (a, c), (b, c)))
        for a, b, c in itertools.combinations(range(n), 3)
    ]


def monte_carlo(n: int, p: float, trials: int, rng: random.Random) -> dict[str, float]:
    """Estimate principal graph statistics over independent samples."""
    if trials < 1:
        raise ValueError("trials must be positive")
    summaries = [summarize_graph(n, sample_graph(n, p, rng)) for _ in range(trials)]
    return {
        "largest_fraction": sum(s.largest_fraction for s in summaries) / trials,
        "connected_probability": sum(s.connected for s in summaries) / trials,
        "mean_isolated": sum(s.isolated for s in summaries) / trials,
        "mean_triangles": sum(s.triangles for s in summaries) / trials,
        "triangle_probability": sum(s.triangles > 0 for s in summaries) / trials,
    }


def print_phase_table(n: int, trials: int, rng: random.Random) -> None:
    print("\nGIANT-COMPONENT SCALE: p = lambda/n")
    print("lambda  theory rho  lower bound  simulated largest fraction")
    for lam in (0.70, 1.00, 1.10, 1.50, 2.00, 3.00):
        rho = survival_probability(lam)
        lower = 0.0 if lam <= 1.0 else 2.0 * (lam - 1.0) / lam**2
        estimate = monte_carlo(n, min(lam / n, 1.0), trials, rng)
        print(f"{lam:5.2f}    {rho:8.4f}     {lower:8.4f}            {estimate['largest_fraction']:8.4f}")


def print_connectivity_table(n: int, trials: int, rng: random.Random) -> None:
    print("\nCONNECTIVITY WINDOW: p = (log n + c)/n")
    print("   c    limit exp(-exp(-c))  simulated P(connected)  mean isolated")
    for c in (-2.0, -1.0, 0.0, 1.0, 2.0):
        p = min(max((math.log(n) + c) / n, 0.0), 1.0)
        estimate = monte_carlo(n, p, trials, rng)
        limit = math.exp(-math.exp(-c))
        print(f"{c:5.1f}          {limit:8.4f}               {estimate['connected_probability']:8.4f}         {estimate['mean_isolated']:8.4f}")


def print_triangle_demo(n: int, trials: int, rng: random.Random) -> None:
    # A moderate p keeps exact O(binomial(n,3)^2) overlap enumeration practical.
    p = 1.25 / n
    patterns = triangle_patterns(n)
    first, second, lower = exact_pattern_moments(patterns, p)
    estimate = monte_carlo(n, p, trials, rng)
    print("\nTRIANGLE COUNT AND OVERLAP MOMENTS")
    print(f"n={n}, p={p:.6f}, candidates={len(patterns)}")
    print(f"exact E[X]                 = {first:.6f}")
    print(f"exact E[X^2]              = {second:.6f}")
    print(f"second-moment lower bound = {lower:.6f}")
    print(f"simulated E[X]            = {estimate['mean_triangles']:.6f}")
    print(f"simulated P(X>0)          = {estimate['triangle_probability']:.6f}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--n", type=int, default=80, help="number of vertices")
    parser.add_argument("--trials", type=int, default=300, help="samples per row")
    parser.add_argument("--seed", type=int, default=20260803, help="random seed")
    args = parser.parse_args()
    if args.n < 3:
        parser.error("--n must be at least 3")
    if args.trials < 1:
        parser.error("--trials must be positive")
    rng = random.Random(args.seed)
    print_phase_table(args.n, args.trials, rng)
    print_connectivity_table(args.n, args.trials, rng)
    # Cap n because direct pairwise triangle overlap enumeration is quadratic
    # in the number of triangles.
    print_triangle_demo(min(args.n, 32), args.trials, rng)


if __name__ == "__main__":
    main()
