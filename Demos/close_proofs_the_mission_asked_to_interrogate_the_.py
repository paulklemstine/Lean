#!/usr/bin/env python3
"""Numerical demonstrations of graph thresholds and triangle shadow bounds."""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from itertools import combinations
from math import comb
from typing import Iterable, Sequence

Edge = tuple[int, int]


@dataclass(frozen=True)
class GraphReport:
    vertices: int
    edges: int
    triangles: int
    threshold: Fraction
    no_isolated_vertices: bool


def normalize_edges(n: int, edges: Iterable[Edge]) -> set[Edge]:
    """Validate and normalize an edge iterable for a simple graph on range(n)."""
    if n < 0:
        raise ValueError("The number of vertices must be nonnegative.")
    result: set[Edge] = set()
    for u, v in edges:
        if not (0 <= u < n and 0 <= v < n):
            raise ValueError(f"Edge {(u, v)} has a vertex outside range({n}).")
        if u == v:
            raise ValueError("Loops are not allowed in a simple graph.")
        result.add((u, v) if u < v else (v, u))
    return result


def count_triangles(n: int, edges: Iterable[Edge]) -> int:
    """Count triangles by testing all three-element vertex subsets."""
    edge_set = normalize_edges(n, edges)
    return sum(
        (a, b) in edge_set and (a, c) in edge_set and (b, c) in edge_set
        for a, b, c in combinations(range(n), 3)
    )


def analyze_graph(n: int, edges: Iterable[Edge]) -> GraphReport:
    """Compute exact edge, triangle, non-isolation, and threshold data."""
    edge_set = normalize_edges(n, edges)
    m = len(edge_set)
    if m == 0:
        raise ValueError("The pair-to-edge threshold requires at least one edge.")
    degrees = [0] * n
    for u, v in edge_set:
        degrees[u] += 1
        degrees[v] += 1
    return GraphReport(
        vertices=n,
        edges=m,
        triangles=count_triangles(n, edge_set),
        threshold=Fraction(comb(n, 2), m),
        no_isolated_vertices=all(degree > 0 for degree in degrees),
    )


def complete_graph(n: int) -> set[Edge]:
    """Return the edge set of the complete graph on n labeled vertices."""
    return set(combinations(range(n), 2))


def perfect_matching(n: int) -> set[Edge]:
    """Return a canonical perfect matching; n must be positive and even."""
    if n <= 0 or n % 2:
        raise ValueError("A perfect matching demo requires positive even n.")
    return {(i, i + 1) for i in range(0, n, 2)}


def strongest_triangle_certificate(n: int, triangle_count: int) -> tuple[int, int]:
    """Return largest k with C(k,3) <= triangle_count and forced C(k,2) edges."""
    if n < 3 or triangle_count < 0:
        raise ValueError("Require n >= 3 and a nonnegative triangle count.")
    feasible = [k for k in range(3, n + 1) if comb(k, 3) <= triangle_count]
    if not feasible:
        return (2, 0)  # No nontrivial k >= 3 certificate is activated.
    k = max(feasible)
    return k, comb(k, 2)


def threshold_test(n: int, m: int, p: Fraction) -> bool:
    """Test p < C(n,2)/m by exact cross multiplication."""
    if m <= 0:
        raise ValueError("m must be positive.")
    return p.numerator * m < p.denominator * comb(n, 2)


def print_report(label: str, report: GraphReport) -> None:
    print(f"\n{label}")
    print("-" * len(label))
    print(f"vertices: {report.vertices}")
    print(f"edges: {report.edges}")
    print(f"triangles: {report.triangles}")
    print(f"threshold C(n,2)/m: {report.threshold} ({float(report.threshold):.3f})")
    print(f"no isolated vertices: {report.no_isolated_vertices}")
    if report.no_isolated_vertices:
        print(
            "interval check: "
            f"1 <= {report.threshold} <= {report.vertices - 1} is "
            f"{1 <= report.threshold <= report.vertices - 1}"
        )


def main() -> None:
    complete = analyze_graph(6, complete_graph(6))
    matching = analyze_graph(6, perfect_matching(6))
    intermediate_edges: Sequence[Edge] = [
        (0, 1), (0, 2), (1, 2),  # one triangle
        (2, 3), (3, 4), (4, 5), (5, 2),
    ]
    intermediate = analyze_graph(6, intermediate_edges)

    print_report("Complete graph K6: lower threshold endpoint", complete)
    print_report("Perfect matching on six vertices: upper endpoint", matching)
    print_report("Intermediate graph", intermediate)

    print("\nExact probability tests")
    print("-----------------------")
    for p in (Fraction(1, 10), Fraction(1, 2), Fraction(9, 10)):
        verdict = threshold_test(intermediate.vertices, intermediate.edges, p)
        print(f"p={p}: p < C(n,2)/m is {verdict}")

    print("\nTriangle-to-edge certificates")
    print("-----------------------------")
    for k in range(3, 9):
        triangles = comb(k, 3)
        recovered_k, forced_edges = strongest_triangle_certificate(k, triangles)
        print(
            f"{triangles:3d} triangles = C({k},3) force at least "
            f"{forced_edges:3d} edges = C({recovered_k},2)."
        )

    assert complete.threshold == 1
    assert matching.threshold == matching.vertices - 1
    assert all(
        threshold_test(intermediate.vertices, intermediate.edges, p)
        for p in (Fraction(0), Fraction(1, 2), Fraction(99, 100))
    )
    assert count_triangles(6, complete_graph(6)) == comb(6, 3)
    assert strongest_triangle_certificate(6, 20) == (6, 15)
    print("\nAll exact consistency checks passed.")


if __name__ == "__main__":
    main()
