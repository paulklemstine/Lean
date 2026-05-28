"""
Support-Compressed Leaf Counting for Matroid Basis Polynomials

This module implements the verified algorithms for computing nonzero quadratic
derivative leaves using support geometry rather than symbolic differentiation.

The key insight: for a multiaffine homogeneous polynomial of degree r, the
derivative ∂^α p is nonzero iff α is dominated by some support vector. For
matroid basis polynomials, this means nonzero quadratic leaves correspond
exactly to independent sets of size r-2.
"""

from itertools import combinations
from typing import FrozenSet, Set, List, Tuple, Dict
from math import comb
import time


def independent_sets_of_size(
    bases: List[FrozenSet[int]], n: int, k: int
) -> List[FrozenSet[int]]:
    """
    Compute all k-element subsets of [n] that are contained in some basis.

    This is the combinatorial core: a k-subset I is "independent" iff
    there exists a basis B such that I ⊆ B.

    Args:
        bases: List of basis sets (frozensets of integers in range(n))
        n: Size of the ground set
        k: Size of independent sets to enumerate

    Returns:
        List of k-element frozensets that are independent
    """
    if k < 0:
        return []
    ground = range(n)
    result = []
    for subset in combinations(ground, k):
        fs = frozenset(subset)
        if any(fs <= B for B in bases):
            result.append(fs)
    return result


def count_nonzero_quadratic_leaves(
    bases: List[FrozenSet[int]], n: int, r: int
) -> int:
    """
    Count nonzero quadratic derivative leaves from support data.

    For a family of r-element bases on ground set [n], counts the number
    of (r-2)-element subsets contained in some basis. This replaces
    full symbolic differentiation with combinatorial enumeration.

    Args:
        bases: List of basis sets
        n: Size of the ground set
        r: Rank (degree of the polynomial)

    Returns:
        Number of nonzero quadratic leaves

    Complexity:
        O(C(n, r-2) * |bases| * r) in the worst case
    """
    if r < 2:
        return 1
    return len(independent_sets_of_size(bases, n, r - 2))


def active_variable_count(bases: List[FrozenSet[int]]) -> int:
    """Count the number of distinct elements appearing in any basis."""
    return len(set().union(*bases)) if bases else 0


def ambient_leaf_count(n: int, r: int) -> int:
    """Naive worst-case leaf count: C(n, r-2)."""
    if r < 2:
        return 1
    return comb(n, r - 2)


def compressed_upper_bound(bases: List[FrozenSet[int]], r: int) -> int:
    """Support-compressed upper bound: C(|active|, r-2)."""
    if r < 2:
        return 1
    a = active_variable_count(bases)
    return comb(a, r - 2)


# --- Matroid Constructors ---

def uniform_matroid_bases(n: int, r: int) -> List[FrozenSet[int]]:
    """
    All r-element subsets of [n].
    This is the uniform matroid U_{r,n}.
    """
    return [frozenset(s) for s in combinations(range(n), r)]


def graphic_matroid_bases(edges: List[Tuple[int, int]], num_vertices: int) -> List[FrozenSet[int]]:
    """
    Bases of the graphic matroid of a graph.
    A basis is a maximal forest (spanning tree if connected).

    Args:
        edges: List of (u, v) edges, indexed by position
        num_vertices: Number of vertices

    Returns:
        List of frozensets of edge indices forming spanning forests
    """
    n_edges = len(edges)
    rank = num_vertices - 1  # for connected graphs

    # Find all spanning trees by brute force (for small graphs)
    bases = []
    for subset in combinations(range(n_edges), rank):
        # Check if this subset of edges forms a spanning tree
        adj: Dict[int, Set[int]] = {v: set() for v in range(num_vertices)}
        for idx in subset:
            u, v = edges[idx]
            adj[u].add(v)
            adj[v].add(u)

        # BFS to check connectivity
        visited = set()
        queue = [0]
        visited.add(0)
        while queue:
            node = queue.pop(0)
            for neighbor in adj[node]:
                if neighbor not in visited:
                    visited.add(neighbor)
                    queue.append(neighbor)

        if len(visited) == num_vertices:
            bases.append(frozenset(subset))

    return bases


def path_graph_edges(n: int) -> List[Tuple[int, int]]:
    """Edges of the path graph P_n on n vertices."""
    return [(i, i + 1) for i in range(n - 1)]


def cycle_graph_edges(n: int) -> List[Tuple[int, int]]:
    """Edges of the cycle graph C_n on n vertices."""
    return [(i, (i + 1) % n) for i in range(n)]


def complete_graph_edges(n: int) -> List[Tuple[int, int]]:
    """Edges of the complete graph K_n."""
    return [(i, j) for i in range(n) for j in range(i + 1, n)]


def transversal_matroid_bases(
    sets: List[Set[int]], ground_size: int
) -> List[FrozenSet[int]]:
    """
    Bases of the transversal matroid.
    A basis is a system of distinct representatives (SDR) of the sets.

    Args:
        sets: List of subsets of [ground_size]
        ground_size: Size of the ground set

    Returns:
        List of frozensets forming bases (SDRs)
    """
    n = len(sets)
    bases = []

    def find_sdrs(idx: int, used: Set[int], current: List[int]):
        if idx == n:
            bases.append(frozenset(current))
            return
        for elem in sets[idx]:
            if elem not in used:
                used.add(elem)
                current.append(elem)
                find_sdrs(idx + 1, used, current)
                current.pop()
                used.remove(elem)

    find_sdrs(0, set(), [])
    return bases


def compression_ratio(
    bases: List[FrozenSet[int]], n: int, r: int
) -> float:
    """
    Compute the ratio actual_leaves / ambient_leaves.
    Values < 1 indicate compression; smaller = better.
    """
    actual = count_nonzero_quadratic_leaves(bases, n, r)
    ambient = ambient_leaf_count(n, r)
    return actual / ambient if ambient > 0 else 1.0


if __name__ == "__main__":
    # Quick test
    print("=== Uniform Matroid U_{3,5} ===")
    bases = uniform_matroid_bases(5, 3)
    print(f"Bases: {len(bases)}")
    print(f"Quadratic leaves: {count_nonzero_quadratic_leaves(bases, 5, 3)}")
    print(f"C(5, 1) = {comb(5, 1)}")
    print(f"Match: {count_nonzero_quadratic_leaves(bases, 5, 3) == comb(5, 1)}")
