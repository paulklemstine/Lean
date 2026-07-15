#!/usr/bin/env python3
"""Numerical demonstrations of exact clique-to-clique shadow thresholds."""

from __future__ import annotations

from itertools import combinations
from math import comb
from typing import Iterable, Sequence

VertexSet = frozenset[int]
Edge = tuple[int, int]


def normalized_edge(u: int, v: int) -> Edge:
    """Return an undirected edge in canonical order."""
    if u == v:
        raise ValueError("simple graphs have no loops")
    return (u, v) if u < v else (v, u)


def clique_family(vertices: Sequence[int], edges: Iterable[Edge], r: int) -> set[VertexSet]:
    """Enumerate all r-cliques of a finite simple graph."""
    edge_set = {normalized_edge(u, v) for u, v in edges}
    result: set[VertexSet] = set()
    for candidate in combinations(vertices, r):
        if all(normalized_edge(u, v) in edge_set for u, v in combinations(candidate, 2)):
            result.add(frozenset(candidate))
    return result


def shadow(family: set[VertexSet]) -> set[VertexSet]:
    """Compute the one-step lower shadow of a uniform set family."""
    return {member - {x} for member in family for x in member}


def iterated_shadow(family: set[VertexSet], steps: int) -> set[VertexSet]:
    """Apply the lower-shadow operation the specified number of times."""
    if steps < 0:
        raise ValueError("steps must be nonnegative")
    current = set(family)
    for _ in range(steps):
        current = shadow(current)
    return current


def complete_core_graph(n: int, k: int) -> tuple[list[int], set[Edge]]:
    """Create K_k together with n-k isolated vertices."""
    if not 0 <= k <= n:
        raise ValueError("require 0 <= k <= n")
    vertices = list(range(n))
    edges = {normalized_edge(u, v) for u, v in combinations(range(k), 2)}
    return vertices, edges


def largest_threshold_parameter(count_t: int, t: int, n: int) -> int | None:
    """Find the largest k in [t,n] for which C(k,t) <= count_t."""
    if t < 0 or n < t or count_t < 0:
        return None
    lo, hi = t, n
    if comb(t, t) > count_t:
        return None
    while lo < hi:
        mid = (lo + hi + 1) // 2
        if comb(mid, t) <= count_t:
            lo = mid
        else:
            hi = mid - 1
    return lo


def verify_threshold(vertices: Sequence[int], edges: set[Edge], s: int, t: int) -> tuple[int, int, int]:
    """Return k, actual K_s, and certified lower bound C(k,s)."""
    high_count = len(clique_family(vertices, edges, t))
    k = largest_threshold_parameter(high_count, t, len(vertices))
    if k is None:
        raise ValueError("no nontrivial binomial threshold is reached")
    actual_low = len(clique_family(vertices, edges, s))
    certified = comb(k, s)
    assert actual_low >= certified
    return k, actual_low, certified


def main() -> None:
    vertices, edges = complete_core_graph(n=10, k=6)
    four_cliques = clique_family(vertices, edges, 4)
    triangles = clique_family(vertices, edges, 3)
    graph_edges = clique_family(vertices, edges, 2)

    first_shadow = iterated_shadow(four_cliques, 1)
    second_shadow = iterated_shadow(four_cliques, 2)
    assert first_shadow == triangles
    assert second_shadow == graph_edges

    print("Complete six-vertex core with four isolated vertices")
    print(f"4-cliques: {len(four_cliques)} = C(6,4) = {comb(6, 4)}")
    print(f"triangles: {len(triangles)} = C(6,3) = {comb(6, 3)}")
    print(f"edges:     {len(graph_edges)} = C(6,2) = {comb(6, 2)}")
    print(f"shadow sizes: {len(four_cliques)} -> {len(first_shadow)} -> {len(second_shadow)}")

    vertices7, edges7 = complete_core_graph(n=7, k=7)
    for s in (1, 2, 3):
        k, actual, bound = verify_threshold(vertices7, edges7, s=s, t=4)
        print(f"K_7, order 4 to order {s}: maximal k={k}, actual={actual}, bound={bound}")

    # A manually specified overlapping example: two K_4 blocks sharing an edge.
    blocks = [set(range(4)), {0, 1, 4, 5}]
    overlap_edges = {
        normalized_edge(u, v)
        for block in blocks
        for u, v in combinations(sorted(block), 2)
    }
    overlap_vertices = list(range(6))
    high = clique_family(overlap_vertices, overlap_edges, 4)
    low = clique_family(overlap_vertices, overlap_edges, 2)
    high_shadow = iterated_shadow(high, 2)
    assert high_shadow <= low
    print("Two overlapping four-cliques")
    print(f"4-cliques={len(high)}, two-step shadow={len(high_shadow)}, total edges={len(low)}")


if __name__ == "__main__":
    main()
