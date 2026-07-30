#!/usr/bin/env python3
"""Numerical demonstrations of threshold phenomena in G(n,p), using only stdlib."""
from __future__ import annotations

from collections import deque
from dataclasses import dataclass
from math import comb, exp, log
from random import Random
from typing import Iterable

Adjacency = list[set[int]]


@dataclass(frozen=True)
class GraphStats:
    connected: bool
    largest_component: int
    isolated_vertices: int
    triangles: int


def sample_gnp(n: int, p: float, rng: Random) -> Adjacency:
    """Sample G(n,p) as adjacency sets in O(n^2) time."""
    if n < 0 or not 0.0 <= p <= 1.0:
        raise ValueError("require n >= 0 and 0 <= p <= 1")
    graph: Adjacency = [set() for _ in range(n)]
    for u in range(n):
        for v in range(u + 1, n):
            if rng.random() < p:
                graph[u].add(v)
                graph[v].add(u)
    return graph


def component_sizes(graph: Adjacency) -> list[int]:
    """Return component sizes by breadth-first search in O(n+m) time."""
    seen: set[int] = set()
    sizes: list[int] = []
    for start in range(len(graph)):
        if start in seen:
            continue
        seen.add(start)
        queue = deque([start])
        size = 0
        while queue:
            u = queue.popleft()
            size += 1
            for v in graph[u]:
                if v not in seen:
                    seen.add(v)
                    queue.append(v)
        sizes.append(size)
    return sizes


def count_triangles(graph: Adjacency) -> int:
    """Count triangles once each using ordered adjacency intersections."""
    total = 0
    for u, neighbors in enumerate(graph):
        for v in neighbors:
            if v > u:
                total += sum(1 for w in graph[u] & graph[v] if w > v)
    return total


def summarize(graph: Adjacency) -> GraphStats:
    sizes = component_sizes(graph)
    n = len(graph)
    largest = max(sizes, default=0)
    return GraphStats(
        connected=(n == 0 or len(sizes) == 1),
        largest_component=largest,
        isolated_vertices=sum(not neighbors for neighbors in graph),
        triangles=count_triangles(graph),
    )


def monte_carlo(n: int, p: float, trials: int, seed: int) -> dict[str, float]:
    """Estimate connectivity, giant fraction, isolates, and triangle count."""
    if trials <= 0:
        raise ValueError("trials must be positive")
    rng = Random(seed)
    stats = [summarize(sample_gnp(n, p, rng)) for _ in range(trials)]
    return {
        "p": p,
        "connectivity": sum(s.connected for s in stats) / trials,
        "largest_fraction": sum(s.largest_component / max(n, 1) for s in stats) / trials,
        "mean_isolates": sum(s.isolated_vertices for s in stats) / trials,
        "mean_triangles": sum(s.triangles for s in stats) / trials,
    }


def connectivity_window(n: int, c_values: Iterable[float], trials: int = 300) -> None:
    print("\nCONNECTIVITY WINDOW")
    print(" c      p          simulated   limit       isolates(sim/exact/limit)")
    for index, c in enumerate(c_values):
        p = min(1.0, max(0.0, (log(n) + c) / n))
        result = monte_carlo(n, p, trials, 1000 + index)
        exact_isolates = n * (1.0 - p) ** (n - 1)
        print(f"{c:>4.1f}  {p:>8.5f}   {result['connectivity']:>8.3f}   "
              f"{exp(-exp(-c)):>8.3f}   {result['mean_isolates']:>6.3f}/"
              f"{exact_isolates:>6.3f}/{exp(-c):>6.3f}")


def giant_component_window(n: int, lambdas: Iterable[float], trials: int = 300) -> None:
    print("\nGIANT-COMPONENT WINDOW")
    print("lambda     p        mean largest-component fraction")
    for index, lam in enumerate(lambdas):
        result = monte_carlo(n, lam / n, trials, 2000 + index)
        print(f" {lam:>4.2f}   {lam/n:>8.5f}              {result['largest_fraction']:>7.3f}")


def triangle_first_moment(n: int, p_values: Iterable[float], trials: int = 300) -> None:
    print("\nTRIANGLE FIRST MOMENT")
    print(" p        simulated mean     exact E[X]     P(X>0) upper bound")
    for index, p in enumerate(p_values):
        result = monte_carlo(n, p, trials, 3000 + index)
        expectation = comb(n, 3) * p**3
        print(f"{p:>7.4f}       {result['mean_triangles']:>8.3f}       "
              f"{expectation:>8.3f}       {min(1.0, expectation):>8.3f}")


def main() -> None:
    n = 300
    connectivity_window(n, (-2.0, -1.0, 0.0, 1.0, 2.0))
    giant_component_window(n, (0.6, 0.8, 1.0, 1.2, 1.5, 2.0))
    triangle_first_moment(80, (0.004, 0.008, 0.012, 0.020))


if __name__ == "__main__":
    main()
