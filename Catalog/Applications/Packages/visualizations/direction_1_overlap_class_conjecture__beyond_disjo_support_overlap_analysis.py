"""
Overlap Class Algorithms for Support Families

This module implements the core algorithms for computing overlap invariants
of finite support families, including overlap graphs, overlap degrees,
connected components (overlap classes), and overlap signatures.

These algorithms formalize the combinatorial machinery introduced in
OverlapClassRigidity.lean and provide computational tools for testing
the Overlap Rigidity Conjecture.
"""

from __future__ import annotations
from typing import Dict, FrozenSet, List, Optional, Set, Tuple
from collections import defaultdict
import itertools


# ============================================================
# Core Data Structures
# ============================================================

Support = FrozenSet[int]
SupportFamily = List[Support]


def make_support(*elements: int) -> Support:
    """Create a support (frozenset of integers)."""
    return frozenset(elements)


# ============================================================
# Overlap Relation
# ============================================================

def supports_overlap(a: Support, b: Support) -> bool:
    """
    Check if two supports overlap (have nonempty intersection).

    Corresponds to `SupportsOverlap` in OverlapClassRigidity.lean.

    >>> supports_overlap(frozenset({1,2,3}), frozenset({3,4,5}))
    True
    >>> supports_overlap(frozenset({1,2}), frozenset({3,4}))
    False
    """
    return bool(a & b)


def cross_overlap_count(a: Support, b: Support) -> int:
    """
    Compute the intersection cardinality of two supports.

    Corresponds to `CrossOverlapCount` in OverlapClassRigidity.lean.

    >>> cross_overlap_count(frozenset({1,2,3}), frozenset({2,3,4}))
    2
    """
    return len(a & b)


# ============================================================
# Overlap Graph
# ============================================================

def build_overlap_graph(family: SupportFamily) -> Dict[int, Set[int]]:
    """
    Build the support overlap graph as an adjacency dict.

    Vertices are indices into the family. An edge (i, j) exists
    iff supports i and j overlap.

    Corresponds to the implicit graph structure in OverlapClassRigidity.lean
    whose edges are the pairs counted by `OverlapDegree`.

    Time: O(n^2 * max_support_size)
    Space: O(n^2) for the adjacency structure

    >>> family = [frozenset({1,2}), frozenset({2,3}), frozenset({4,5})]
    >>> g = build_overlap_graph(family)
    >>> 1 in g[0] and 0 in g[1]
    True
    >>> 2 in g[0]
    False
    """
    n = len(family)
    adj: Dict[int, Set[int]] = {i: set() for i in range(n)}
    for i in range(n):
        for j in range(i + 1, n):
            if supports_overlap(family[i], family[j]):
                adj[i].add(j)
                adj[j].add(i)
    return adj


# ============================================================
# Overlap Degree
# ============================================================

def overlap_degree(family: SupportFamily) -> int:
    """
    Compute the overlap degree: number of overlapping pairs.

    Corresponds to `OverlapDegree` in OverlapClassRigidity.lean.

    Time: O(n^2 * max_support_size)

    >>> overlap_degree([frozenset({1,2}), frozenset({3,4})])
    0
    >>> overlap_degree([frozenset({1,2}), frozenset({2,3})])
    1
    >>> overlap_degree([frozenset({1,2}), frozenset({2,3}), frozenset({3,4})])
    2
    """
    n = len(family)
    count = 0
    for i in range(n):
        for j in range(i + 1, n):
            if supports_overlap(family[i], family[j]):
                count += 1
    return count


# ============================================================
# Max Overlap Degree
# ============================================================

def max_overlap_deg(family: SupportFamily) -> int:
    """
    Compute the max overlap degree: maximum intersection cardinality
    over all distinct pairs.

    Corresponds to `MaxOverlapDeg` in OverlapClassRigidity.lean.

    >>> max_overlap_deg([frozenset({1,2,3}), frozenset({2,3,4}), frozenset({5,6})])
    2
    """
    n = len(family)
    if n < 2:
        return 0
    return max(
        cross_overlap_count(family[i], family[j])
        for i in range(n) for j in range(i + 1, n)
    )


# ============================================================
# Overlap Signature
# ============================================================

def overlap_signature(family: SupportFamily) -> List[int]:
    """
    Compute the overlap signature: sorted list of intersection
    cardinalities for all overlapping pairs.

    Corresponds to `OverlapSignature` in OverlapClassRigidity.lean.

    >>> overlap_signature([frozenset({1,2,3}), frozenset({2,3,4}), frozenset({3,4,5})])
    [1, 2, 2]
    """
    n = len(family)
    sig = []
    for i in range(n):
        for j in range(i + 1, n):
            c = cross_overlap_count(family[i], family[j])
            if c > 0:
                sig.append(c)
    return sorted(sig)


# ============================================================
# Connected Components (Overlap Classes)
# ============================================================

def overlap_classes(family: SupportFamily) -> List[List[int]]:
    """
    Compute the overlap classes: connected components of the
    support overlap graph.

    Each class is a list of indices into the family. The number
    of classes corresponds to `OverlapClassCount` in OverlapClassRigidity.lean.

    Uses BFS for component discovery.
    Time: O(n^2 * max_support_size)

    >>> classes = overlap_classes([frozenset({1,2}), frozenset({2,3}), frozenset({4,5})])
    >>> len(classes)
    2
    >>> sorted([sorted(c) for c in classes])
    [[0, 1], [2]]
    """
    adj = build_overlap_graph(family)
    n = len(family)
    visited = [False] * n
    components: List[List[int]] = []

    for start in range(n):
        if visited[start]:
            continue
        component: List[int] = []
        queue = [start]
        visited[start] = True
        while queue:
            node = queue.pop(0)
            component.append(node)
            for neighbor in adj[node]:
                if not visited[neighbor]:
                    visited[neighbor] = True
                    queue.append(neighbor)
        components.append(component)

    return components


def overlap_class_count(family: SupportFamily) -> int:
    """
    Count the number of overlap classes.

    >>> overlap_class_count([frozenset({1,2}), frozenset({2,3}), frozenset({4,5})])
    2
    """
    return len(overlap_classes(family))


# ============================================================
# Pairwise Disjointness Check
# ============================================================

def is_pairwise_disjoint(family: SupportFamily) -> bool:
    """
    Check if a family is pairwise disjoint.

    By the main characterization theorem (overlapDegree_eq_zero_iff),
    this is equivalent to overlap degree being zero.

    >>> is_pairwise_disjoint([frozenset({1,2}), frozenset({3,4})])
    True
    >>> is_pairwise_disjoint([frozenset({1,2}), frozenset({2,3})])
    False
    """
    return overlap_degree(family) == 0


# ============================================================
# Family Union
# ============================================================

def family_union(family: SupportFamily) -> Support:
    """
    Compute the union of all supports in a family.

    Corresponds to `FamilyUnion` in OverlapClassRigidity.lean.

    >>> sorted(family_union([frozenset({1,2}), frozenset({3,4})]))
    [1, 2, 3, 4]
    """
    result: Set[int] = set()
    for s in family:
        result |= s
    return frozenset(result)


# ============================================================
# Graph Cycle Supports (for testing the conjecture)
# ============================================================

def find_all_cycles(adj: Dict[int, Set[int]], vertices: List[int]) -> List[Support]:
    """
    Find all simple cycles in an undirected graph given as adjacency dict.
    Returns the vertex supports of all cycles found.

    Uses DFS-based cycle detection.
    """
    cycles: List[FrozenSet[int]] = []
    n = len(vertices)
    if n == 0:
        return cycles

    # Use Johnson's algorithm idea: find cycles through each vertex
    vertex_set = set(vertices)

    def dfs_cycles(start: int, current: int, path: List[int],
                   visited: Set[int], min_vertex: int) -> None:
        for neighbor in adj.get(current, set()):
            if neighbor not in vertex_set:
                continue
            if neighbor == start and len(path) >= 3:
                cycle_support = frozenset(path)
                cycles.append(cycle_support)
            elif neighbor not in visited and neighbor > min_vertex:
                visited.add(neighbor)
                path.append(neighbor)
                dfs_cycles(start, neighbor, path, visited, min_vertex)
                path.pop()
                visited.discard(neighbor)

    for v in vertices:
        dfs_cycles(v, v, [v], {v}, v)

    # Deduplicate
    unique = list(set(cycles))
    return unique


def cycle_support_family(adj: Dict[int, Set[int]], vertices: List[int]) -> SupportFamily:
    """
    Compute the family of cycle supports for a graph restricted to vertices.
    """
    return find_all_cycles(adj, vertices)


# ============================================================
# Full Analysis
# ============================================================

def full_overlap_analysis(family: SupportFamily) -> Dict:
    """
    Perform a complete overlap analysis of a support family.

    Returns a dictionary with all computed invariants.

    >>> result = full_overlap_analysis([frozenset({1,2}), frozenset({2,3}), frozenset({4,5})])
    >>> result['overlap_degree']
    1
    >>> result['overlap_class_count']
    2
    >>> result['is_pairwise_disjoint']
    False
    """
    classes = overlap_classes(family)
    return {
        'n': len(family),
        'family': [sorted(s) for s in family],
        'overlap_degree': overlap_degree(family),
        'max_overlap_deg': max_overlap_deg(family),
        'overlap_signature': overlap_signature(family),
        'overlap_class_count': len(classes),
        'overlap_classes': [sorted(c) for c in classes],
        'is_pairwise_disjoint': is_pairwise_disjoint(family),
        'family_union_size': len(family_union(family)),
        'sum_of_sizes': sum(len(s) for s in family),
    }


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Overlap Class Analysis — Example Computations")
    print("=" * 60)

    # Example 1: Pairwise disjoint family
    print("\n--- Example 1: Pairwise Disjoint ---")
    f1 = [frozenset({1, 2}), frozenset({3, 4}), frozenset({5, 6})]
    result = full_overlap_analysis(f1)
    for k, v in result.items():
        print(f"  {k}: {v}")

    # Example 2: Chain of overlaps
    print("\n--- Example 2: Chain of Overlaps ---")
    f2 = [frozenset({1, 2}), frozenset({2, 3}), frozenset({3, 4})]
    result = full_overlap_analysis(f2)
    for k, v in result.items():
        print(f"  {k}: {v}")

    # Example 3: All overlapping (clique in overlap graph)
    print("\n--- Example 3: All Overlapping ---")
    f3 = [frozenset({1, 2, 3}), frozenset({2, 3, 4}), frozenset({3, 4, 5})]
    result = full_overlap_analysis(f3)
    for k, v in result.items():
        print(f"  {k}: {v}")

    # Example 4: Two components
    print("\n--- Example 4: Two Overlap Classes ---")
    f4 = [frozenset({1, 2}), frozenset({2, 3}), frozenset({5, 6}), frozenset({6, 7})]
    result = full_overlap_analysis(f4)
    for k, v in result.items():
        print(f"  {k}: {v}")

    print("\n" + "=" * 60)
    print("All examples completed successfully.")
