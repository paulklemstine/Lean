"""
Algorithms for Overlap Class Theory in Tropical Kernel Rigidity.

This module implements the core algorithms for computing overlap classes,
overlap graphs, overlap degree, and related invariants for families of
finite sets (support families). These algorithms are the computational
backbone of the overlap class rigidity theory.

Author: Harmonic Research
"""

from typing import List, Set, Tuple, Dict, Optional, FrozenSet
from collections import defaultdict
import itertools


def supports_overlap(A: FrozenSet[int], B: FrozenSet[int]) -> bool:
    """Check if two supports overlap (have nonempty intersection).

    Args:
        A: First support (finite set of vertices).
        B: Second support (finite set of vertices).

    Returns:
        True if A ∩ B is nonempty.

    Time complexity: O(min(|A|, |B|))

    >>> supports_overlap(frozenset({1,2,3}), frozenset({3,4,5}))
    True
    >>> supports_overlap(frozenset({1,2}), frozenset({3,4}))
    False
    """
    return len(A & B) > 0


def overlap_degree(family: List[FrozenSet[int]]) -> int:
    """Compute the overlap degree of a support family.

    The overlap degree is the number of unordered pairs (i, j) with i < j
    such that family[i] and family[j] overlap.

    Args:
        family: List of supports (finite sets).

    Returns:
        Number of overlapping pairs.

    Time complexity: O(n^2 * max_support_size)

    >>> overlap_degree([frozenset({1,2}), frozenset({3,4}), frozenset({5,6})])
    0
    >>> overlap_degree([frozenset({1,2,3}), frozenset({2,3,4}), frozenset({5,6})])
    1
    """
    n = len(family)
    count = 0
    for i in range(n):
        for j in range(i + 1, n):
            if supports_overlap(family[i], family[j]):
                count += 1
    return count


def cross_overlap_count(A: FrozenSet[int], B: FrozenSet[int]) -> int:
    """Compute the intersection cardinality between two supports.

    Args:
        A: First support.
        B: Second support.

    Returns:
        |A ∩ B|

    >>> cross_overlap_count(frozenset({1,2,3}), frozenset({2,3,4}))
    2
    """
    return len(A & B)


def build_overlap_graph(family: List[FrozenSet[int]]) -> Dict[int, Set[int]]:
    """Build the support overlap graph as an adjacency list.

    Vertices are indices 0..n-1. An edge (i, j) exists iff
    family[i] ∩ family[j] is nonempty and i ≠ j.

    Args:
        family: List of supports.

    Returns:
        Adjacency list representation of the overlap graph.

    Time complexity: O(n^2 * max_support_size)

    >>> g = build_overlap_graph([frozenset({1,2}), frozenset({2,3}), frozenset({4,5})])
    >>> sorted(g[0])
    [1]
    >>> sorted(g[2])
    []
    """
    n = len(family)
    adj: Dict[int, Set[int]] = {i: set() for i in range(n)}
    for i in range(n):
        for j in range(i + 1, n):
            if supports_overlap(family[i], family[j]):
                adj[i].add(j)
                adj[j].add(i)
    return adj


def overlap_classes(family: List[FrozenSet[int]]) -> List[List[int]]:
    """Compute the overlap classes (connected components of the overlap graph).

    Each overlap class is a maximal set of indices connected by chains
    of overlapping supports. This is the fundamental decomposition of
    the support family into independent interaction sectors.

    Args:
        family: List of supports.

    Returns:
        List of overlap classes, each a sorted list of indices.

    Time complexity: O(n^2 * max_support_size) for graph construction,
                     O(n) for BFS/DFS traversal.

    >>> overlap_classes([frozenset({1,2}), frozenset({2,3}), frozenset({4,5})])
    [[0, 1], [2]]
    >>> overlap_classes([frozenset({1}), frozenset({2}), frozenset({3})])
    [[0], [1], [2]]
    """
    n = len(family)
    if n == 0:
        return []
    adj = build_overlap_graph(family)
    visited = [False] * n
    components = []

    for start in range(n):
        if visited[start]:
            continue
        # BFS
        component = []
        queue = [start]
        visited[start] = True
        while queue:
            node = queue.pop(0)
            component.append(node)
            for neighbor in sorted(adj[node]):
                if not visited[neighbor]:
                    visited[neighbor] = True
                    queue.append(neighbor)
        components.append(sorted(component))

    return components


def overlap_class_count(family: List[FrozenSet[int]]) -> int:
    """Count the number of overlap classes.

    Args:
        family: List of supports.

    Returns:
        Number of connected components of the overlap graph.

    >>> overlap_class_count([frozenset({1,2}), frozenset({2,3}), frozenset({4,5})])
    2
    """
    return len(overlap_classes(family))


def overlap_signature(family: List[FrozenSet[int]]) -> List[int]:
    """Compute the overlap signature: sorted multiset of intersection sizes.

    For each overlapping pair (i, j) with i < j, includes |family[i] ∩ family[j]|.

    Args:
        family: List of supports.

    Returns:
        Sorted list of intersection cardinalities (each > 0).

    >>> overlap_signature([frozenset({1,2,3}), frozenset({2,3,4}), frozenset({4,5,6})])
    [1, 2]
    """
    n = len(family)
    sig = []
    for i in range(n):
        for j in range(i + 1, n):
            c = cross_overlap_count(family[i], family[j])
            if c > 0:
                sig.append(c)
    return sorted(sig)


def max_overlap_degree(family: List[FrozenSet[int]]) -> int:
    """Compute the maximum pairwise intersection cardinality.

    Args:
        family: List of supports.

    Returns:
        Maximum |family[i] ∩ family[j]| over all distinct i, j.

    >>> max_overlap_degree([frozenset({1,2,3}), frozenset({2,3,4}), frozenset({5,6})])
    2
    """
    n = len(family)
    if n < 2:
        return 0
    return max(
        cross_overlap_count(family[i], family[j])
        for i in range(n) for j in range(i + 1, n)
    )


def is_pairwise_disjoint(family: List[FrozenSet[int]]) -> bool:
    """Check if a support family is pairwise disjoint.

    Equivalent to overlap_degree(family) == 0.

    Args:
        family: List of supports.

    Returns:
        True if all pairs are disjoint.

    >>> is_pairwise_disjoint([frozenset({1,2}), frozenset({3,4})])
    True
    >>> is_pairwise_disjoint([frozenset({1,2}), frozenset({2,3})])
    False
    """
    return overlap_degree(family) == 0


def family_union(family: List[FrozenSet[int]]) -> FrozenSet[int]:
    """Compute the union of all supports in a family.

    >>> family_union([frozenset({1,2}), frozenset({2,3})])
    frozenset({1, 2, 3})
    """
    result: Set[int] = set()
    for s in family:
        result |= s
    return frozenset(result)


def class_union(family: List[FrozenSet[int]], cls: List[int]) -> FrozenSet[int]:
    """Compute the union of supports in a given overlap class.

    Args:
        family: List of supports.
        cls: List of indices forming an overlap class.

    Returns:
        Union of family[i] for i in cls.
    """
    result: Set[int] = set()
    for i in cls:
        result |= family[i]
    return frozenset(result)


def verify_class_disjointness(family: List[FrozenSet[int]]) -> bool:
    """Verify that support unions from different overlap classes are disjoint.

    This is the computational verification of the overlap_class_unions_disjoint
    theorem: supports from different overlap classes have disjoint unions.

    Args:
        family: List of supports.

    Returns:
        True if all class unions are pairwise disjoint.

    >>> family = [frozenset({1,2}), frozenset({2,3}), frozenset({4,5}), frozenset({6,7})]
    >>> verify_class_disjointness(family)
    True
    """
    classes = overlap_classes(family)
    unions = [class_union(family, cls) for cls in classes]
    for i in range(len(unions)):
        for j in range(i + 1, len(unions)):
            if len(unions[i] & unions[j]) > 0:
                return False
    return True


# ---- Graph-theoretic utilities ----

def graph_edges(adj: Dict[int, Set[int]]) -> List[Tuple[int, int]]:
    """Extract sorted edge list from adjacency representation."""
    edges = []
    for u in sorted(adj.keys()):
        for v in sorted(adj[u]):
            if u < v:
                edges.append((u, v))
    return edges


def enumerate_connected_graphs(n: int):
    """Enumerate all connected simple graphs on n labeled vertices.

    Yields adjacency sets for each connected graph.

    Args:
        n: Number of vertices.

    Yields:
        Dict mapping vertex to set of neighbors.
    """
    if n <= 0:
        return
    if n == 1:
        yield {0: set()}
        return

    vertices = list(range(n))
    possible_edges = list(itertools.combinations(vertices, 2))

    for r in range(n - 1, len(possible_edges) + 1):
        for edge_subset in itertools.combinations(possible_edges, r):
            adj: Dict[int, Set[int]] = {v: set() for v in vertices}
            for u, v in edge_subset:
                adj[u].add(v)
                adj[v].add(u)
            # Check connectivity via BFS
            visited = {0}
            queue = [0]
            while queue:
                node = queue.pop(0)
                for nb in adj[node]:
                    if nb not in visited:
                        visited.add(nb)
                        queue.append(nb)
            if len(visited) == n:
                yield adj


def graph_cycle_supports(adj: Dict[int, Set[int]], subset: List[int]) -> List[FrozenSet[int]]:
    """Compute cycle supports in the induced subgraph G[subset].

    A cycle support is the vertex set of a fundamental cycle in the
    induced subgraph. We find these by computing a spanning forest and
    then identifying the non-tree edges, each of which creates a
    fundamental cycle.

    Args:
        adj: Graph adjacency list.
        subset: Vertex subset S.

    Returns:
        List of cycle supports (as frozen sets of vertices).
    """
    if len(subset) < 3:
        return []

    sub = set(subset)
    # Build induced subgraph adjacency
    ind_adj: Dict[int, Set[int]] = {v: set() for v in subset}
    for v in subset:
        for u in adj.get(v, set()):
            if u in sub:
                ind_adj[v].add(u)

    # BFS spanning forest
    parent: Dict[int, Optional[int]] = {}
    visited: Set[int] = set()
    non_tree_edges: List[Tuple[int, int]] = []

    for start in subset:
        if start in visited:
            continue
        visited.add(start)
        parent[start] = None
        queue = [start]
        while queue:
            node = queue.pop(0)
            for nb in sorted(ind_adj[node]):
                if nb not in visited:
                    visited.add(nb)
                    parent[nb] = node
                    queue.append(nb)
                elif parent.get(node) != nb:
                    edge = (min(node, nb), max(node, nb))
                    if edge not in non_tree_edges:
                        non_tree_edges.append(edge)

    # For each non-tree edge, find the fundamental cycle
    cycle_supports = []
    for u, v in non_tree_edges:
        # Find paths from u and v to their common ancestor
        path_u = []
        node = u
        while node is not None:
            path_u.append(node)
            node = parent.get(node)

        path_v = []
        node = v
        while node is not None:
            path_v.append(node)
            node = parent.get(node)

        set_u = set(path_u)
        set_v = set(path_v)

        # Find LCA (lowest common ancestor)
        cycle_verts = set()
        for x in path_u:
            cycle_verts.add(x)
            if x in set_v:
                # x is the LCA
                for y in path_v:
                    cycle_verts.add(y)
                    if y == x:
                        break
                break

        if len(cycle_verts) >= 3:
            cycle_supports.append(frozenset(cycle_verts))

    return cycle_supports


if __name__ == "__main__":
    # Example usage
    print("=== Overlap Class Theory Algorithms ===\n")

    # Example 1: Pairwise disjoint
    family1 = [frozenset({1, 2}), frozenset({3, 4}), frozenset({5, 6})]
    print(f"Family 1: {[set(s) for s in family1]}")
    print(f"  Overlap degree: {overlap_degree(family1)}")
    print(f"  Overlap classes: {overlap_classes(family1)}")
    print(f"  Class count: {overlap_class_count(family1)}")
    print(f"  Pairwise disjoint: {is_pairwise_disjoint(family1)}")
    print()

    # Example 2: Some overlap
    family2 = [frozenset({1, 2, 3}), frozenset({3, 4, 5}), frozenset({7, 8})]
    print(f"Family 2: {[set(s) for s in family2]}")
    print(f"  Overlap degree: {overlap_degree(family2)}")
    print(f"  Overlap classes: {overlap_classes(family2)}")
    print(f"  Class count: {overlap_class_count(family2)}")
    print(f"  Overlap signature: {overlap_signature(family2)}")
    print(f"  Max overlap degree: {max_overlap_degree(family2)}")
    print(f"  Class unions disjoint: {verify_class_disjointness(family2)}")
    print()

    # Example 3: Triangle of overlaps
    family3 = [
        frozenset({1, 2, 3}),
        frozenset({2, 3, 4}),
        frozenset({3, 4, 5}),
    ]
    print(f"Family 3: {[set(s) for s in family3]}")
    print(f"  Overlap degree: {overlap_degree(family3)}")
    print(f"  Overlap classes: {overlap_classes(family3)}")
    print(f"  Overlap signature: {overlap_signature(family3)}")
    print(f"  Max overlap degree: {max_overlap_degree(family3)}")
    print()

    # Example 4: Cycle supports from a small graph
    adj = {0: {1, 2, 3}, 1: {0, 2}, 2: {0, 1, 3}, 3: {0, 2}}
    subset = [0, 1, 2, 3]
    cycles = graph_cycle_supports(adj, subset)
    print(f"Graph with 4 vertices, edges: {graph_edges(adj)}")
    print(f"  Cycle supports in G[{subset}]: {[set(c) for c in cycles]}")
    if cycles:
        print(f"  Overlap degree of cycle supports: {overlap_degree(cycles)}")
        print(f"  Overlap classes: {overlap_classes(cycles)}")
