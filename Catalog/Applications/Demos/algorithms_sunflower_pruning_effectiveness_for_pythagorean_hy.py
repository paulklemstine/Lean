"""
Sunflower Pruning Algorithms for Pythagorean Hypergraphs

Implements certified search procedures for minimum transversals (hitting sets)
with sunflower-based pruning on the Pythagorean triple hypergraph.

Includes:
- Pythagorean hypergraph construction
- Naive branching transversal search
- Sunflower-pruned branching transversal search
- Sunflower detection
- Overlap/degree analysis
"""

from __future__ import annotations
from typing import FrozenSet, Optional
from itertools import combinations
import math


# ─────────────────────────────────────────────────────────────────────
# Pythagorean Hypergraph Construction
# ─────────────────────────────────────────────────────────────────────

def pythagorean_edges(n: int) -> set[frozenset[int]]:
    """
    Construct the 3-uniform Pythagorean hypergraph on {1, ..., n}.

    Each edge is a frozenset {a, b, c} where a < b < c ≤ n and a² + b² = c².

    >>> sorted(sorted(e) for e in pythagorean_edges(13))
    [[3, 4, 5], [5, 12, 13], [6, 8, 10]]
    """
    edges: set[frozenset[int]] = set()
    for a in range(1, n + 1):
        for b in range(a + 1, n + 1):
            c_sq = a * a + b * b
            c = int(math.isqrt(c_sq))
            if c * c == c_sq and c <= n and c > b:
                edges.add(frozenset({a, b, c}))
    return edges


def vertex_degree(edges: set[frozenset[int]], v: int) -> int:
    """Number of edges containing vertex v."""
    return sum(1 for e in edges if v in e)


def degree_profile(edges: set[frozenset[int]], n: int) -> dict[int, int]:
    """Map vertex → degree for all vertices in {1, ..., n}."""
    return {v: vertex_degree(edges, v) for v in range(1, n + 1)}


def max_degree_vertex(edges: set[frozenset[int]], n: int) -> tuple[int, int]:
    """Return (vertex, degree) for the vertex with maximum degree."""
    profile = degree_profile(edges, n)
    v = max(profile, key=profile.get)  # type: ignore
    return v, profile[v]


# ─────────────────────────────────────────────────────────────────────
# Sunflower Detection
# ─────────────────────────────────────────────────────────────────────

def find_sunflower(edges: set[frozenset[int]], min_petals: int) -> Optional[tuple[list[frozenset[int]], frozenset[int]]]:
    """
    Search for a sunflower (Δ-system) with at least `min_petals` petals.

    Returns (sunflower_edges, kernel) if found, None otherwise.
    Uses a greedy approach: for each vertex v, check if the edges through v
    form a sunflower with kernel containing v.
    """
    edge_list = list(edges)

    # Strategy: look for sunflowers around high-degree vertices
    for v in sorted(set().union(*edges), key=lambda x: -vertex_degree(edges, x)):
        incident = [e for e in edge_list if v in e]
        if len(incident) < min_petals:
            continue

        # Check if incident edges form a sunflower with core {v}
        # (pairwise intersection = {v})
        sunflower: list[frozenset[int]] = []
        used_petal_elements: set[int] = set()

        for e in incident:
            petal = e - {v}
            if not petal & used_petal_elements:
                sunflower.append(e)
                used_petal_elements |= petal
                if len(sunflower) >= min_petals:
                    return sunflower, frozenset({v})

    # Try pairs of edges for general kernels
    for e1, e2 in combinations(edge_list, 2):
        kernel = e1 & e2
        if not kernel:
            continue
        sf = [e for e in edge_list if kernel <= e]
        # Verify pairwise intersection = kernel
        is_sf = True
        for i, ei in enumerate(sf):
            for j in range(i + 1, len(sf)):
                if ei & sf[j] != kernel:
                    is_sf = False
                    break
            if not is_sf:
                break
        if is_sf and len(sf) >= min_petals:
            return sf[:min_petals], kernel

    return None


# ─────────────────────────────────────────────────────────────────────
# Transversal Search: Naive Branching
# ─────────────────────────────────────────────────────────────────────

class SearchCounter:
    """Tracks recursive calls during search."""
    def __init__(self):
        self.calls = 0

    def increment(self):
        self.calls += 1


def _naive_search(
    edges: list[frozenset[int]],
    current: set[int],
    k: int,
    counter: SearchCounter,
) -> Optional[set[int]]:
    """
    Naive branching: pick an uncovered edge, branch on each element.

    Returns a hitting set of size ≤ k, or None if impossible.
    """
    counter.increment()

    # Find uncovered edge
    uncovered = None
    for e in edges:
        if not (e & current):
            uncovered = e
            break

    if uncovered is None:
        return set(current)  # All edges covered

    if k == 0:
        return None  # Budget exhausted

    # Branch on each element of uncovered edge
    for v in sorted(uncovered):
        current.add(v)
        result = _naive_search(edges, current, k - 1, counter)
        if result is not None:
            return result
        current.discard(v)

    return None


def naive_transversal_search(
    edges: set[frozenset[int]], k: int
) -> tuple[Optional[set[int]], int]:
    """
    Find a hitting set of size ≤ k using naive branching.

    Returns (hitting_set_or_None, recursive_call_count).
    """
    counter = SearchCounter()
    result = _naive_search(list(edges), set(), k, counter)
    return result, counter.calls


# ─────────────────────────────────────────────────────────────────────
# Transversal Search: Sunflower-Pruned Branching
# ─────────────────────────────────────────────────────────────────────

def _sunflower_search(
    edges: list[frozenset[int]],
    current: set[int],
    k: int,
    counter: SearchCounter,
) -> Optional[set[int]]:
    """
    Sunflower-pruned branching: when a sunflower with > k petals is found,
    branch only on the core (which must be hit by any size-k hitting set).

    Returns a hitting set of size ≤ k, or None if impossible.
    """
    counter.increment()

    # Remove already-covered edges
    remaining = [e for e in edges if not (e & current)]

    if not remaining:
        return set(current)  # All edges covered

    if k == 0:
        return None  # Budget exhausted

    remaining_set = set(frozenset(e) for e in remaining)

    # Try to find a sunflower with > k petals
    sf = find_sunflower(remaining_set, k + 1)

    if sf is not None:
        sf_edges, kernel = sf
        # Branch only on core elements (soundness: theorem hitting_set_must_hit_sunflower_core)
        for v in sorted(kernel):
            current.add(v)
            result = _sunflower_search(remaining, current, k - 1, counter)
            if result is not None:
                return result
            current.discard(v)
        return None
    else:
        # Fall back to naive: pick an uncovered edge, branch on each element
        uncovered = remaining[0]
        for v in sorted(uncovered):
            current.add(v)
            result = _sunflower_search(remaining, current, k - 1, counter)
            if result is not None:
                return result
            current.discard(v)
        return None


def sunflower_transversal_search(
    edges: set[frozenset[int]], k: int
) -> tuple[Optional[set[int]], int]:
    """
    Find a hitting set of size ≤ k using sunflower-pruned branching.

    Returns (hitting_set_or_None, recursive_call_count).
    """
    counter = SearchCounter()
    result = _sunflower_search(list(edges), set(), k, counter)
    return result, counter.calls


# ─────────────────────────────────────────────────────────────────────
# Analysis Utilities
# ─────────────────────────────────────────────────────────────────────

def overlap_analysis(edges: set[frozenset[int]], n: int) -> dict:
    """
    Analyze the overlap structure of the hypergraph.

    Returns a dict with:
    - max_degree: maximum vertex degree
    - max_vertex: vertex achieving max degree
    - avg_degree: average degree (= 3 * |E| / n for 3-uniform)
    - incident_pairwise_intersections: for the max-degree vertex,
      the distribution of pairwise intersection sizes among incident edges
    """
    profile = degree_profile(edges, n)
    max_v = max(profile, key=profile.get)  # type: ignore
    max_d = profile[max_v]
    total_incidence = sum(profile.values())

    # Pairwise intersections around max-degree vertex
    incident = [e for e in edges if max_v in e]
    intersection_sizes: dict[int, int] = {}
    for i, e1 in enumerate(incident):
        for e2 in list(incident)[i + 1:]:
            sz = len(e1 & e2)
            intersection_sizes[sz] = intersection_sizes.get(sz, 0) + 1

    return {
        "max_degree": max_d,
        "max_vertex": max_v,
        "avg_degree": total_incidence / n if n > 0 else 0,
        "total_incidence": total_incidence,
        "three_times_edges": 3 * len(edges),
        "incident_edge_count": len(incident),
        "pairwise_intersection_sizes": intersection_sizes,
    }


def pruning_gain(naive_calls: int, sunflower_calls: int) -> float:
    """Compute pruning gain: 1 - (sunflower_calls / naive_calls)."""
    if naive_calls == 0:
        return 0.0
    return 1.0 - sunflower_calls / naive_calls


# ─────────────────────────────────────────────────────────────────────
# Recursive Call Bounds (Theoretical)
# ─────────────────────────────────────────────────────────────────────

def recursive_calls_naive(r: int, k: int) -> int:
    """
    Upper bound on recursive calls for naive branching on r-uniform hypergraph
    with budget k: r^k.
    """
    return r ** k


def recursive_calls_sunflower(s: int, k: int) -> int:
    """
    Upper bound on recursive calls for sunflower-pruned branching
    with core size s and budget k: s^k.
    """
    return s ** k


if __name__ == "__main__":
    # Quick demonstration
    n = 50
    edges = pythagorean_edges(n)
    print(f"Pythagorean hypergraph on {{1,...,{n}}}: {len(edges)} edges")

    analysis = overlap_analysis(edges, n)
    print(f"Max degree vertex: {analysis['max_vertex']} with degree {analysis['max_degree']}")
    print(f"Total incidence sum: {analysis['total_incidence']}")
    print(f"3 * |E|: {analysis['three_times_edges']}")
    print(f"Match (double-counting): {analysis['total_incidence'] == analysis['three_times_edges']}")

    k = 5
    naive_result, naive_calls = naive_transversal_search(edges, k)
    sf_result, sf_calls = sunflower_transversal_search(edges, k)

    print(f"\nTransversal search with budget k={k}:")
    print(f"  Naive: {naive_calls} calls, result: {naive_result}")
    print(f"  Sunflower: {sf_calls} calls, result: {sf_result}")
    print(f"  Pruning gain: {pruning_gain(naive_calls, sf_calls):.1%}")
