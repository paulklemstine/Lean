"""
Algorithms for Sunflower Pruning on Pythagorean Hypergraphs.

This module implements:
  - Construction of the Pythagorean triple hypergraph H_n
  - Naive bounded-size hitting set search (branching on arbitrary edges)
  - Sunflower-pruned hitting set search (branching on sunflower cores)
  - Sunflower detection in edge neighborhoods
  - Vertex degree / overlap analysis utilities

All algorithms include recursion-call counters for empirical comparison.
"""

from __future__ import annotations
from typing import Optional
from itertools import combinations
import math


# ---------------------------------------------------------------------------
# Core data structures
# ---------------------------------------------------------------------------

def pythagorean_edges(n: int) -> list[frozenset[int]]:
    """Return all Pythagorean triple edges {a, b, c} with 1 ≤ a < b < c ≤ n
    and a² + b² = c²."""
    edges: list[frozenset[int]] = []
    for a in range(1, n + 1):
        for b in range(a + 1, n + 1):
            c2 = a * a + b * b
            c = int(math.isqrt(c2))
            if c * c == c2 and c > b and c <= n:
                edges.append(frozenset({a, b, c}))
    return edges


def vertex_degrees(edges: list[frozenset[int]], n: int) -> dict[int, int]:
    """Compute degree of each vertex v ∈ {1,…,n} in the hypergraph."""
    deg: dict[int, int] = {v: 0 for v in range(1, n + 1)}
    for e in edges:
        for v in e:
            if v in deg:
                deg[v] += 1
    return deg


# ---------------------------------------------------------------------------
# Sunflower detection
# ---------------------------------------------------------------------------

def find_sunflower_with_core(
    edges: list[frozenset[int]],
    min_petals: int,
) -> Optional[tuple[frozenset[int], list[frozenset[int]]]]:
    """Find a sunflower in `edges` with at least `min_petals` petals.

    Returns (core, petal_edges) or None.

    Strategy: for each vertex v, look at incident edges. Among those,
    check if enough pairs have pairwise intersection exactly {v} — that
    gives a sunflower with singleton core {v}.
    """
    # Group edges by vertex
    from collections import defaultdict
    incidence: dict[int, list[frozenset[int]]] = defaultdict(list)
    for e in edges:
        for v in e:
            incidence[v].append(e)

    # Try singleton cores first (most common for Pythagorean hypergraphs)
    for v, inc_edges in sorted(incidence.items(), key=lambda x: -len(x[1])):
        if len(inc_edges) < min_petals:
            continue
        # Greedy: collect edges whose pairwise intersection is exactly {v}
        sunflower: list[frozenset[int]] = []
        for e in inc_edges:
            compatible = True
            for f in sunflower:
                if e & f != frozenset({v}):
                    compatible = False
                    break
            if compatible:
                sunflower.append(e)
                if len(sunflower) >= min_petals:
                    return frozenset({v}), sunflower
    return None


# ---------------------------------------------------------------------------
# Naive hitting set search
# ---------------------------------------------------------------------------

class SearchCounter:
    """Mutable counter for recursive calls."""
    def __init__(self):
        self.calls = 0


def _naive_hitting_set(
    edges: list[frozenset[int]],
    budget: int,
    current: frozenset[int],
    counter: SearchCounter,
) -> Optional[frozenset[int]]:
    """Naive bounded-size hitting set: branch on elements of an uncovered edge."""
    counter.calls += 1

    # Find an uncovered edge
    uncovered = None
    for e in edges:
        if not (e & current):
            uncovered = e
            break

    if uncovered is None:
        return current  # All edges hit

    if budget == 0:
        return None  # Budget exhausted

    # Branch on each element of the uncovered edge
    for v in sorted(uncovered):
        result = _naive_hitting_set(edges, budget - 1, current | {v}, counter)
        if result is not None:
            return result
    return None


def naive_hitting_set(
    edges: list[frozenset[int]], k: int
) -> tuple[Optional[frozenset[int]], int]:
    """Find a hitting set of size ≤ k using naive branching.
    Returns (hitting_set_or_None, recursive_calls)."""
    counter = SearchCounter()
    result = _naive_hitting_set(edges, k, frozenset(), counter)
    return result, counter.calls


# ---------------------------------------------------------------------------
# Sunflower-pruned hitting set search
# ---------------------------------------------------------------------------

def _sunflower_hitting_set(
    edges: list[frozenset[int]],
    budget: int,
    current: frozenset[int],
    counter: SearchCounter,
) -> Optional[frozenset[int]]:
    """Sunflower-pruned hitting set: when a large sunflower is found,
    branch only on core elements."""
    counter.calls += 1

    # Remove already-hit edges
    remaining = [e for e in edges if not (e & current)]
    if not remaining:
        return current  # All edges hit

    if budget == 0:
        return None  # Budget exhausted

    # Try to find a sunflower with > budget petals
    sf = find_sunflower_with_core(remaining, budget + 1)
    if sf is not None:
        core, _ = sf
        # Branch only on core elements (soundness: hitting_set_must_hit_core)
        for v in sorted(core):
            result = _sunflower_hitting_set(
                edges, budget - 1, current | {v}, counter
            )
            if result is not None:
                return result
        return None
    else:
        # Fall back to naive branching on an arbitrary uncovered edge
        uncovered = remaining[0]
        for v in sorted(uncovered):
            result = _sunflower_hitting_set(
                edges, budget - 1, current | {v}, counter
            )
            if result is not None:
                return result
        return None


def sunflower_hitting_set(
    edges: list[frozenset[int]], k: int
) -> tuple[Optional[frozenset[int]], int]:
    """Find a hitting set of size ≤ k using sunflower-pruned branching.
    Returns (hitting_set_or_None, recursive_calls)."""
    counter = SearchCounter()
    result = _sunflower_hitting_set(edges, k, frozenset(), counter)
    return result, counter.calls


# ---------------------------------------------------------------------------
# Analysis utilities
# ---------------------------------------------------------------------------

def overlap_analysis(edges: list[frozenset[int]], n: int) -> dict:
    """Analyze overlap structure of the hypergraph."""
    deg = vertex_degrees(edges, n)
    max_deg_v = max(deg, key=deg.get) if deg else 0
    max_deg = deg.get(max_deg_v, 0)

    # Check sunflower existence around top-degree vertices
    top_vertices = sorted(deg.keys(), key=lambda v: -deg[v])[:10]
    sunflower_info = []
    for v in top_vertices:
        inc = [e for e in edges if v in e]
        # Find max sunflower size with core {v}
        sf_size = 0
        sunflower: list[frozenset[int]] = []
        for e in inc:
            compatible = all(e & f == frozenset({v}) for f in sunflower)
            if compatible:
                sunflower.append(e)
                sf_size += 1
        sunflower_info.append({
            'vertex': v,
            'degree': deg[v],
            'max_sunflower_size': sf_size,
        })

    return {
        'num_edges': len(edges),
        'max_degree': max_deg,
        'max_degree_vertex': max_deg_v,
        'avg_degree_times_n': 3 * len(edges),  # = sum of degrees
        'top_vertices': sunflower_info,
    }


if __name__ == '__main__':
    # Quick demo
    for n in [50, 100, 200]:
        edges = pythagorean_edges(n)
        print(f"\nn={n}: {len(edges)} Pythagorean edges")
        analysis = overlap_analysis(edges, n)
        print(f"  Max degree: {analysis['max_degree']} (vertex {analysis['max_degree_vertex']})")
        print(f"  Top-3 sunflower sizes: {[v['max_sunflower_size'] for v in analysis['top_vertices'][:3]]}")
