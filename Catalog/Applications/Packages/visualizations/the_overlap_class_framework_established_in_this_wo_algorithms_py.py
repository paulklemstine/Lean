"""
Overlap Class Spectral Theory — Core Algorithms

Type-hinted implementations of the key algorithms from the overlap class
spectral theory framework.
"""

from __future__ import annotations
from typing import TypeVar, Sequence
from itertools import combinations
from collections import defaultdict

T = TypeVar("T")


def overlap_interaction_matrix(
    supports: Sequence[set[T]],
) -> list[list[int]]:
    """Compute the overlap interaction matrix M where M[i][j] = |S_i ∩ S_j|.

    Args:
        supports: A list of sets (the support family).

    Returns:
        A symmetric matrix of intersection cardinalities.
    """
    n = len(supports)
    M = [[0] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            M[i][j] = len(supports[i] & supports[j])
    return M


def overlap_complexity(supports: Sequence[set[T]]) -> int:
    """Compute the overlap complexity: Σ_{i<j} |S_i ∩ S_j|.

    Args:
        supports: A list of sets (the support family).

    Returns:
        The total pairwise intersection size.
    """
    return sum(
        len(supports[i] & supports[j])
        for i, j in combinations(range(len(supports)), 2)
    )


def total_support_size(supports: Sequence[set[T]]) -> int:
    """Compute the total support size: Σ_i |S_i|.

    Args:
        supports: A list of sets.

    Returns:
        Sum of individual set sizes.
    """
    return sum(len(s) for s in supports)


def family_union(supports: Sequence[set[T]]) -> set[T]:
    """Compute the family union: ⋃_i S_i.

    Args:
        supports: A list of sets.

    Returns:
        The union of all sets.
    """
    result: set[T] = set()
    for s in supports:
        result |= s
    return result


def overlap_edge_count(supports: Sequence[set[T]]) -> int:
    """Count edges in the overlap graph.

    Args:
        supports: A list of sets.

    Returns:
        Number of pairs (i,j) with i<j and S_i ∩ S_j ≠ ∅.
    """
    return sum(
        1
        for i, j in combinations(range(len(supports)), 2)
        if supports[i] & supports[j]
    )


def overlap_graph_adjacency(supports: Sequence[set[T]]) -> list[list[bool]]:
    """Compute the adjacency matrix of the overlap graph.

    Args:
        supports: A list of sets.

    Returns:
        Boolean adjacency matrix.
    """
    n = len(supports)
    adj = [[False] * n for _ in range(n)]
    for i, j in combinations(range(n), 2):
        if supports[i] & supports[j]:
            adj[i][j] = True
            adj[j][i] = True
    return adj


def overlap_connected_components(supports: Sequence[set[T]]) -> list[list[int]]:
    """Find connected components of the overlap graph via BFS.

    Args:
        supports: A list of sets.

    Returns:
        A list of components, each component being a list of indices.
    """
    n = len(supports)
    adj = overlap_graph_adjacency(supports)
    visited = [False] * n
    components: list[list[int]] = []
    for start in range(n):
        if visited[start]:
            continue
        component = []
        queue = [start]
        visited[start] = True
        while queue:
            node = queue.pop(0)
            component.append(node)
            for neighbor in range(n):
                if adj[node][neighbor] and not visited[neighbor]:
                    visited[neighbor] = True
                    queue.append(neighbor)
        components.append(component)
    return components


def spectral_bound(supports: Sequence[set[T]]) -> int:
    """Compute the spectral inclusion-exclusion lower bound on |⋃ S_i|.

    The bound is: |⋃ S_i| ≥ TotalSupportSize - OverlapComplexity.

    Args:
        supports: A list of sets.

    Returns:
        The spectral lower bound (may be 0 if overlap is very large).
    """
    tss = total_support_size(supports)
    oc = overlap_complexity(supports)
    return max(0, tss - oc)


def is_pairwise_disjoint(supports: Sequence[set[T]]) -> bool:
    """Check if a family of sets is pairwise disjoint.

    Args:
        supports: A list of sets.

    Returns:
        True if all pairs are disjoint.
    """
    for i, j in combinations(range(len(supports)), 2):
        if supports[i] & supports[j]:
            return False
    return True


def multiplicity_distribution(supports: Sequence[set[T]]) -> dict[int, int]:
    """Compute the multiplicity distribution.

    For each element x in ⋃ S_i, count how many sets contain it.
    Return the histogram: multiplicity -> count.

    Args:
        supports: A list of sets.

    Returns:
        Dictionary mapping multiplicity to number of elements with that multiplicity.
    """
    count: dict[T, int] = defaultdict(int)
    for s in supports:
        for x in s:
            count[x] += 1
    hist: dict[int, int] = defaultdict(int)
    for v in count.values():
        hist[v] += 1
    return dict(sorted(hist.items()))


def verify_spectral_bound(supports: Sequence[set[T]]) -> dict[str, int | bool]:
    """Verify the spectral inclusion-exclusion bound for a given family.

    Args:
        supports: A list of sets.

    Returns:
        Dictionary with computed values and whether the bound holds.
    """
    tss = total_support_size(supports)
    oc = overlap_complexity(supports)
    union_size = len(family_union(supports))
    bound_holds = tss <= union_size + oc
    return {
        "total_support_size": tss,
        "overlap_complexity": oc,
        "family_union_size": union_size,
        "spectral_bound": max(0, tss - oc),
        "bound_holds": bound_holds,
        "edge_count": overlap_edge_count(supports),
        "num_components": len(overlap_connected_components(supports)),
    }
