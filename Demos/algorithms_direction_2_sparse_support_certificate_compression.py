"""
algorithms.py — Support-Compressed Leaf Counting for Matroid Basis Polynomials

Implements the core algorithms for computing nonzero quadratic derivative leaves
using support geometry rather than symbolic differentiation.
"""

from itertools import combinations
from math import comb
from typing import Set, FrozenSet, List, Tuple
import time


def independent_sets_of_size(
    bases: List[FrozenSet[int]], k: int
) -> List[FrozenSet[int]]:
    """
    Enumerate all k-element subsets of the ground set that are contained
    in at least one basis (i.e., independent sets of size k).

    Args:
        bases: List of bases, each a frozenset of ground set elements.
        k: Size of independent sets to enumerate.

    Returns:
        List of independent k-sets.

    >>> bases = [frozenset({0,1,2}), frozenset({1,2,3})]
    >>> sorted([sorted(s) for s in independent_sets_of_size(bases, 1)])
    [[0], [1], [2], [3]]
    """
    if not bases:
        return []
    ground = frozenset().union(*bases)
    result = []
    for combo in combinations(sorted(ground), k):
        subset = frozenset(combo)
        if any(subset <= b for b in bases):
            result.append(subset)
    return result


def count_nonzero_quadratic_leaves(
    bases: List[FrozenSet[int]], r: int
) -> int:
    """
    Count nonzero quadratic derivative leaves from basis data.
    This is the support-compressed alternative to polynomial differentiation.

    Args:
        bases: List of bases (each a frozenset).
        r: Rank (degree of the basis generating polynomial).

    Returns:
        Number of independent (r-2)-sets.

    >>> count_nonzero_quadratic_leaves(
    ...     [frozenset(c) for c in combinations(range(5), 3)], 3)
    5
    """
    if r < 2:
        return 0
    return len(independent_sets_of_size(bases, r - 2))


def active_variable_count(bases: List[FrozenSet[int]]) -> int:
    """Count variables appearing in at least one basis."""
    if not bases:
        return 0
    return len(frozenset().union(*bases))


def compression_ratio(bases: List[FrozenSet[int]], n: int, r: int) -> float:
    """
    Compute the compression ratio: actual leaves / ambient worst case.

    Args:
        bases: List of bases.
        n: Size of ground set.
        r: Rank.

    Returns:
        Ratio in [0, 1]. Values near 0 indicate high compression.

    >>> ratio = compression_ratio(
    ...     [frozenset(c) for c in combinations(range(10), 3)], 10, 3)
    >>> abs(ratio - 1.0) < 1e-10
    True
    """
    ambient = comb(n, r - 2) if r >= 2 else 1
    if ambient == 0:
        return 0.0
    actual = count_nonzero_quadratic_leaves(bases, r)
    return actual / ambient


# --- Matroid Constructors ---

def uniform_matroid_bases(n: int, r: int) -> List[FrozenSet[int]]:
    """
    Bases of the uniform matroid U_{r,n}: all r-element subsets of {0,...,n-1}.

    >>> len(uniform_matroid_bases(4, 2))
    6
    """
    return [frozenset(c) for c in combinations(range(n), r)]


def graphic_matroid_bases(n_vertices: int, edges: List[Tuple[int, int]]) -> List[FrozenSet[int]]:
    """
    Bases of the graphic matroid: maximal forests (spanning trees if connected).
    Each basis is a set of edge indices forming a spanning forest.

    Uses a simple DFS-based enumeration for small graphs.

    Args:
        n_vertices: Number of vertices.
        edges: List of (u, v) edges.

    Returns:
        List of bases (frozensets of edge indices).
    """
    rank = n_vertices - 1  # for connected graphs
    # For general graphs, rank = n_vertices - connected_components

    def is_acyclic(edge_indices):
        """Check if selected edges form a forest."""
        parent = list(range(n_vertices))

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

        for idx in edge_indices:
            u, v = edges[idx]
            if not union(u, v):
                return False
        return True

    def spans(edge_indices):
        """Check if edges span the graph (all vertices connected)."""
        parent = list(range(n_vertices))

        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x

        def union(x, y):
            px, py = find(x), find(y)
            if px == py:
                return
            parent[px] = py

        for idx in edge_indices:
            u, v = edges[idx]
            union(u, v)

        roots = set(find(i) for i in range(n_vertices))
        return len(roots) == 1

    m = len(edges)
    bases = []
    for combo in combinations(range(m), rank):
        if is_acyclic(combo) and spans(combo):
            bases.append(frozenset(combo))
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


# --- Analysis Functions ---

def analyze_matroid(name: str, bases: List[FrozenSet[int]], n: int, r: int) -> dict:
    """
    Full analysis of a matroid's quadratic leaf compression.

    Returns a dictionary with:
      - name, n, r
      - ambient_count: C(n, r-2)
      - actual_count: number of nonzero quadratic leaves
      - active_bound: C(|active|, r-2)
      - ratio: actual/ambient
      - active_vars: number of active variables
    """
    t0 = time.time()
    actual = count_nonzero_quadratic_leaves(bases, r)
    elapsed = time.time() - t0

    ambient = comb(n, r - 2) if r >= 2 else 1
    active = active_variable_count(bases)
    active_bound = comb(active, r - 2) if r >= 2 else 1
    ratio = actual / ambient if ambient > 0 else 0.0

    return {
        "name": name,
        "n": n,
        "r": r,
        "ambient_count": ambient,
        "actual_count": actual,
        "active_bound": active_bound,
        "ratio": ratio,
        "active_vars": active,
        "time_seconds": elapsed,
    }


if __name__ == "__main__":
    # Quick self-test
    print("=== Uniform Matroid U_{3,5} ===")
    bases = uniform_matroid_bases(5, 3)
    result = analyze_matroid("U_{3,5}", bases, 5, 3)
    print(f"  Actual leaves: {result['actual_count']}")
    print(f"  C(5,1) = {comb(5,1)}")
    assert result["actual_count"] == comb(5, 1), "Uniform matroid test failed!"
    print("  ✓ Matches C(n, r-2)")

    print("\n=== Graphic Matroid of K4 ===")
    edges = complete_graph_edges(4)
    bases = graphic_matroid_bases(4, edges)
    r = 3  # rank = n_vertices - 1
    result = analyze_matroid("K4", bases, len(edges), r)
    print(f"  Number of bases (spanning trees): {len(bases)}")
    print(f"  Actual leaves: {result['actual_count']}")
    print(f"  Ambient C({len(edges)}, {r-2}) = {comb(len(edges), r-2)}")
    print(f"  Ratio: {result['ratio']:.4f}")
