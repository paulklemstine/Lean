"""
algorithms.py — Support-Compressed Leaf Counting for Matroid Basis Polynomials

Implements the core algorithms for computing nonzero quadratic derivative leaves
using support geometry instead of polynomial differentiation.

Key Algorithms:
1. count_independent_sets: Count k-element independent sets in a matroid
2. count_quadratic_leaves: Count nonzero quadratic leaves of basis generating polynomial
3. compressed_vs_ambient: Compare compressed and ambient leaf counts
4. active_variable_bound: Compute the active-variable upper bound
"""

from itertools import combinations
from math import comb
from typing import List, Set, FrozenSet, Tuple, Optional
import time


def independent_sets_of_size(
    bases: List[FrozenSet[int]], k: int, ground_set: Optional[Set[int]] = None
) -> List[FrozenSet[int]]:
    """
    Enumerate all k-element independent sets (subsets contained in some basis).

    Args:
        bases: List of basis sets (each a frozenset of integers)
        k: Size of independent sets to enumerate
        ground_set: Optional ground set; inferred from bases if not provided

    Returns:
        List of k-element frozensets that are contained in some basis
    """
    if ground_set is None:
        ground_set = set()
        for B in bases:
            ground_set |= B

    indep = set()
    for subset in combinations(sorted(ground_set), k):
        fs = frozenset(subset)
        for B in bases:
            if fs <= B:
                indep.add(fs)
                break
    return sorted(indep)


def count_quadratic_leaves(
    bases: List[FrozenSet[int]], rank: int, ground_set: Optional[Set[int]] = None
) -> int:
    """
    Count nonzero quadratic derivative leaves of the basis generating polynomial.

    This equals the number of independent (rank-2)-sets.

    Args:
        bases: List of basis sets
        rank: Rank of the matroid (= size of each basis)
        ground_set: Optional ground set

    Returns:
        Number of nonzero quadratic leaves
    """
    if rank < 2:
        return 0
    return len(independent_sets_of_size(bases, rank - 2, ground_set))


def active_variables(bases: List[FrozenSet[int]]) -> Set[int]:
    """Return the set of variables appearing in at least one basis."""
    result = set()
    for B in bases:
        result |= B
    return result


def active_variable_count(bases: List[FrozenSet[int]]) -> int:
    """Count the number of active variables."""
    return len(active_variables(bases))


def ambient_leaf_count(n: int, rank: int) -> int:
    """
    Compute the naive ambient leaf count: C(n, rank-2).

    This is the worst-case number of quadratic derivative branches
    without support compression.
    """
    if rank < 2:
        return 0
    return comb(n, rank - 2)


def active_variable_bound(bases: List[FrozenSet[int]], rank: int) -> int:
    """
    Compute the active-variable upper bound: C(|active vars|, rank-2).

    This is the support-compressed upper bound.
    """
    if rank < 2:
        return 0
    omega = active_variable_count(bases)
    return comb(omega, rank - 2)


def compression_ratio(
    bases: List[FrozenSet[int]], rank: int, n: int
) -> float:
    """
    Compute the compression ratio: actual / ambient.

    A ratio close to 0 means strong compression; 1.0 means no compression.
    """
    amb = ambient_leaf_count(n, rank)
    if amb == 0:
        return 0.0
    actual = count_quadratic_leaves(bases, rank)
    return actual / amb


# ---- Matroid constructors ----

def uniform_matroid_bases(n: int, r: int) -> List[FrozenSet[int]]:
    """Generate all bases of the uniform matroid U_{r,n}."""
    return [frozenset(c) for c in combinations(range(n), r)]


def graphic_matroid_bases_from_edges(
    edges: List[Tuple[int, int]], num_vertices: int
) -> List[FrozenSet[int]]:
    """
    Generate all bases of the graphic matroid of a graph.

    A basis is a spanning forest (maximal acyclic edge subset).
    Uses brute-force enumeration for small graphs.

    Args:
        edges: List of edges as (u, v) tuples
        num_vertices: Number of vertices

    Returns:
        List of basis sets (each a frozenset of edge indices)
    """
    from collections import defaultdict

    m = len(edges)
    # Find connected components to determine rank
    parent = list(range(num_vertices))

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        px, py = find(x), find(y)
        if px == py:
            return False
        parent[px] = py
        return True

    # Compute rank = n - c (number of components)
    components = num_vertices
    p2 = list(range(num_vertices))

    def find2(x):
        while p2[x] != x:
            p2[x] = p2[p2[x]]
            x = p2[x]
        return x

    def union2(x, y):
        nonlocal components
        px, py = find2(x), find2(y)
        if px == py:
            return
        p2[px] = py
        components -= 1

    for u, v in edges:
        union2(u, v)

    rank = num_vertices - components

    bases = []
    for edge_subset in combinations(range(m), rank):
        # Check if this subset is acyclic and spans
        par = list(range(num_vertices))

        def find3(x):
            while par[x] != x:
                par[x] = par[par[x]]
                x = par[x]
            return x

        acyclic = True
        comp = num_vertices
        for idx in edge_subset:
            u, v = edges[idx]
            pu, pv = find3(u), find3(v)
            if pu == pv:
                acyclic = False
                break
            par[pu] = pv
            comp -= 1

        if acyclic and comp == components:
            bases.append(frozenset(edge_subset))

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


def grid_graph_edges(rows: int, cols: int) -> List[Tuple[int, int]]:
    """Edges of the grid graph."""
    edges = []
    for r in range(rows):
        for c in range(cols):
            v = r * cols + c
            if c + 1 < cols:
                edges.append((v, v + 1))
            if r + 1 < rows:
                edges.append((v, v + cols))
    return edges


def transversal_matroid_bases(
    left: int, right: int, adj: List[Tuple[int, int]]
) -> List[FrozenSet[int]]:
    """
    Generate all bases of a transversal matroid.

    A transversal matroid is defined by a bipartite graph. A basis is a
    system of distinct representatives (perfect matching on one side).

    Args:
        left: Number of left vertices
        right: Number of right vertices
        adj: Adjacency list as (left_vertex, right_vertex) tuples

    Returns:
        List of basis sets (frozensets of edge indices)
    """
    # Build adjacency from left vertices
    neighbors = [[] for _ in range(left)]
    for idx, (l, r) in enumerate(adj):
        neighbors[l].append((r, idx))

    bases = []
    # Try all possible matchings of size = left (or min(left, right))
    target = min(left, right)

    def backtrack(l_idx, matched_right, current_edges):
        if len(current_edges) == target:
            bases.append(frozenset(current_edges))
            return
        if l_idx >= left:
            return
        # Try matching l_idx to each unmatched neighbor
        for r, edge_idx in neighbors[l_idx]:
            if r not in matched_right:
                backtrack(
                    l_idx + 1,
                    matched_right | {r},
                    current_edges + [edge_idx],
                )
        # Skip l_idx if we can still reach target
        if target - len(current_edges) <= left - l_idx - 1:
            backtrack(l_idx + 1, matched_right, current_edges)

    backtrack(0, set(), [])
    return bases


def timed_count(
    bases: List[FrozenSet[int]], rank: int, n: int
) -> Tuple[int, float]:
    """Count quadratic leaves with timing."""
    start = time.perf_counter()
    count = count_quadratic_leaves(bases, rank)
    elapsed = time.perf_counter() - start
    return count, elapsed


if __name__ == "__main__":
    # Quick self-test
    print("=== Uniform Matroid U_{3,5} ===")
    bases = uniform_matroid_bases(5, 3)
    print(f"  Bases: {len(bases)}")
    print(f"  Quadratic leaves: {count_quadratic_leaves(bases, 3)}")
    print(f"  Expected C(5,1) = {comb(5, 1)}")
    print(f"  Active vars: {active_variable_count(bases)}")

    print("\n=== Path Graph P_5 (graphic matroid) ===")
    edges = path_graph_edges(5)
    bases = graphic_matroid_bases_from_edges(edges, 5)
    rank = 4  # n-1 for tree
    print(f"  Rank: {rank}, Edges: {len(edges)}")
    print(f"  Bases: {len(bases)}")
    print(f"  Quadratic leaves: {count_quadratic_leaves(bases, rank)}")
    print(f"  Ambient C({len(edges)},{rank-2}) = {ambient_leaf_count(len(edges), rank)}")
