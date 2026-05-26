"""
Algorithms for Support-Compressed Leaf Counting in Matroid Basis Polynomials.

Implements the core algorithms from the research paper:
1. Naive ambient leaf counting
2. Support-compressed leaf counting
3. Matroid independence testing
4. Uniform, graphic, and transversal matroid leaf counting

All algorithms operate on combinatorial representations (sets of sets)
rather than symbolic polynomials, following the support compression principle.
"""

from itertools import combinations
from typing import Set, FrozenSet, List, Tuple, Optional
from collections import defaultdict
import time


# Type aliases
Element = int
Subset = FrozenSet[Element]
Family = Set[Subset]


def ambient_leaf_count(n: int, k: int) -> int:
    """Naive worst-case leaf count: C(n, k).

    This is the number of degree-k multiindices in n variables,
    which bounds the derivative branches in the generic Lorentzian
    recognition algorithm.

    Args:
        n: Number of variables (ground set size).
        k: Degree of the derivative (typically r - 2).

    Returns:
        C(n, k), the binomial coefficient.
    """
    from math import comb
    return comb(n, k)


def nonzero_derivative_leaf_set(
    bases: Family, n: int, k: int
) -> Set[Subset]:
    """Compute the set of k-element subsets contained in some basis.

    This is the support-compressed leaf set: a derivative branch α
    survives iff supp(α) ⊆ some basis.

    Args:
        bases: Family of basis sets.
        n: Ground set size [n] = {0, 1, ..., n-1}.
        k: Size of subsets to enumerate.

    Returns:
        Set of k-element subsets each contained in some basis.

    Time complexity: O(C(n,k) * |bases|)
    Space complexity: O(C(n,k))
    """
    ground = range(n)
    leaves: Set[Subset] = set()
    for subset in combinations(ground, k):
        fs = frozenset(subset)
        for B in bases:
            if fs <= B:
                leaves.add(fs)
                break
    return leaves


def support_compressed_leaf_count(
    bases: Family, n: int, k: int
) -> int:
    """Count nonzero derivative leaves using support geometry.

    Args:
        bases: Family of basis sets.
        n: Ground set size.
        k: Derivative degree (number of variables differentiated).

    Returns:
        Number of k-element subsets contained in some basis.
    """
    return len(nonzero_derivative_leaf_set(bases, n, k))


def active_variable_set(bases: Family) -> Set[Element]:
    """Compute the union of all variables appearing in the support.

    Args:
        bases: Family of basis sets.

    Returns:
        Union of all elements across all bases.
    """
    result: Set[Element] = set()
    for B in bases:
        result |= B
    return result


def active_variable_count(bases: Family) -> int:
    """Count distinct variables appearing in the support."""
    return len(active_variable_set(bases))


def active_variable_bound(bases: Family, k: int) -> int:
    """Upper bound on leaf count from active variable geometry.

    Returns C(|active variables|, k).
    """
    from math import comb
    return comb(active_variable_count(bases), k)


# --- Matroid Constructions ---

def uniform_matroid_bases(n: int, r: int) -> Family:
    """Bases of the uniform matroid U_{r,n}.

    Every r-element subset of [n] is a basis.
    """
    ground = range(n)
    return {frozenset(B) for B in combinations(ground, r)}


def graphic_matroid_bases(n_vertices: int, edges: List[Tuple[int, int]]) -> Family:
    """Bases of the graphic matroid of a graph.

    A basis is a spanning forest: a maximal acyclic edge subset.
    Uses a greedy/enumeration approach.

    Args:
        n_vertices: Number of vertices.
        edges: List of edges as (u, v) pairs.

    Returns:
        Set of bases (each a frozenset of edge indices).
    """

    def is_acyclic(edge_indices: List[int]) -> bool:
        """Check if the selected edges form an acyclic subgraph using Union-Find."""
        parent = list(range(n_vertices))

        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x

        def union(x, y) -> bool:
            rx, ry = find(x), find(y)
            if rx == ry:
                return False
            parent[rx] = ry
            return True

        for idx in edge_indices:
            u, v = edges[idx]
            if not union(u, v):
                return False
        return True

    def count_components(edge_indices: List[int]) -> int:
        """Count connected components in the subgraph."""
        parent = list(range(n_vertices))

        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x

        def union(x, y):
            rx, ry = find(x), find(y)
            if rx != ry:
                parent[rx] = ry

        for idx in edge_indices:
            u, v = edges[idx]
            union(u, v)

        return len({find(i) for i in range(n_vertices)})

    m = len(edges)
    # Rank = n_vertices - number of connected components of full graph
    full_components = count_components(list(range(m)))
    rank = n_vertices - full_components

    bases: Family = set()
    for subset in combinations(range(m), rank):
        if is_acyclic(list(subset)):
            bases.add(frozenset(subset))
    return bases


def transversal_matroid_bases(
    n: int, sets: List[Set[int]]
) -> Family:
    """Bases of a transversal matroid.

    A basis is a system of distinct representatives (SDR) for
    a subfamily of maximum size.

    Args:
        n: Ground set size.
        sets: List of subsets of [n], defining the bipartite incidence.

    Returns:
        Set of bases (each a frozenset of selected elements).
    """
    m = len(sets)

    def find_all_sdrs(idx: int, used: Set[int], current: List[int]) -> List[FrozenSet[int]]:
        if idx == m:
            return [frozenset(current)]
        results = []
        for elem in sets[idx]:
            if elem not in used:
                used.add(elem)
                current.append(elem)
                results.extend(find_all_sdrs(idx + 1, used, current))
                current.pop()
                used.remove(elem)
        # Also try not using this set (if not all sets can be matched)
        results.extend(find_all_sdrs(idx + 1, used, current))
        return results

    all_sdrs = find_all_sdrs(0, set(), [])
    if not all_sdrs:
        return set()
    max_size = max(len(s) for s in all_sdrs)
    return {s for s in all_sdrs if len(s) == max_size}


def independent_sets_of_size(bases: Family, k: int) -> Set[Subset]:
    """Compute independent sets of size k (sets contained in some basis).

    This is equivalent to the nonzero derivative leaf set.
    """
    indep: Set[Subset] = set()
    for B in bases:
        for subset in combinations(sorted(B), k):
            indep.add(frozenset(subset))
    return indep


def compression_ratio(bases: Family, n: int, k: int) -> float:
    """Compute the ratio actual_leaves / ambient_count.

    A ratio < 1 indicates support compression.
    A ratio << 1 indicates dramatic compression.

    Returns:
        Ratio in [0, 1], or 0 if ambient count is 0.
    """
    amb = ambient_leaf_count(n, k)
    if amb == 0:
        return 0.0
    actual = support_compressed_leaf_count(bases, n, k)
    return actual / amb


def benchmark_leaf_counting(
    bases: Family, n: int, k: int
) -> dict:
    """Benchmark naive vs. compressed leaf counting.

    Returns timing and count data for comparison.
    """
    from math import comb

    # Ambient count (instant)
    t0 = time.time()
    amb = comb(n, k)
    t_ambient = time.time() - t0

    # Compressed count
    t0 = time.time()
    compressed = support_compressed_leaf_count(bases, n, k)
    t_compressed = time.time() - t0

    # Active variable bound
    t0 = time.time()
    active_bound = active_variable_bound(bases, k)
    t_active = time.time() - t0

    return {
        "ambient_count": amb,
        "compressed_count": compressed,
        "active_bound": active_bound,
        "ratio": compressed / amb if amb > 0 else 0,
        "time_ambient_s": t_ambient,
        "time_compressed_s": t_compressed,
        "time_active_bound_s": t_active,
    }


if __name__ == "__main__":
    # Quick self-test
    print("=== Uniform Matroid U_{3,5} ===")
    bases = uniform_matroid_bases(5, 3)
    print(f"  Bases: {len(bases)}")
    print(f"  Leaf count (k=1): {support_compressed_leaf_count(bases, 5, 1)}")
    print(f"  Ambient (k=1): {ambient_leaf_count(5, 1)}")
    print(f"  Expected: C(5,1) = 5")

    print("\n=== Path Graph P_4 (4 vertices, 3 edges) ===")
    edges = [(0, 1), (1, 2), (2, 3)]
    bases = graphic_matroid_bases(4, edges)
    r = 3  # rank = 4 - 1 = 3
    print(f"  Bases: {len(bases)}")
    k = r - 2
    print(f"  Leaf count (k={k}): {support_compressed_leaf_count(bases, 3, k)}")
    print(f"  Ambient (k={k}): {ambient_leaf_count(3, k)}")
