"""
algorithms.py — Support-Compressed Lorentzian Recognition Algorithms

Implements the key algorithms from the sparse-support certificate compression theory:
1. Naive ambient leaf counting (worst case)
2. Support-compressed leaf counting (using support geometry)
3. Matroid-specific counting (independent set enumeration)
4. Uniform, graphic, and transversal matroid specializations
"""

from itertools import combinations
from math import comb
from typing import List, Set, FrozenSet, Tuple, Optional, Dict
import time


# ─── Core Data Structures ───────────────────────────────────────────────────

class BasisFamily:
    """A matroid represented by its collection of bases.

    Attributes:
        ground_set: The ground set elements (list of integers).
        bases: Set of frozensets, each a basis.
        rank: Common cardinality of all bases.
    """

    def __init__(self, ground_set: List[int], bases: Set[FrozenSet[int]]):
        self.ground_set = sorted(ground_set)
        self.bases = bases
        if bases:
            self.rank = len(next(iter(bases)))
            assert all(len(b) == self.rank for b in bases), "Bases must be equicardinal"
        else:
            self.rank = 0

    def is_independent(self, I: FrozenSet[int]) -> bool:
        """Check if I is independent (contained in some basis)."""
        return any(I <= B for B in self.bases)

    def independent_sets_of_size(self, k: int) -> List[FrozenSet[int]]:
        """Enumerate all independent sets of size k."""
        return [
            frozenset(s)
            for s in combinations(self.ground_set, k)
            if self.is_independent(frozenset(s))
        ]

    def active_variables(self) -> Set[int]:
        """Union of all elements appearing in any basis."""
        return set().union(*self.bases) if self.bases else set()

    def __repr__(self):
        return f"BasisFamily(rank={self.rank}, |E|={len(self.ground_set)}, |B|={len(self.bases)})"


# ─── Matroid Constructors ────────────────────────────────────────────────────

def uniform_matroid(r: int, n: int) -> BasisFamily:
    """Uniform matroid U_{r,n}: every r-element subset is a basis.

    Args:
        r: Rank.
        n: Size of ground set {0, ..., n-1}.

    Returns:
        BasisFamily representing U_{r,n}.
    """
    E = list(range(n))
    bases = {frozenset(s) for s in combinations(E, r)}
    return BasisFamily(E, bases)


def graphic_matroid(n_vertices: int, edges: List[Tuple[int, int]]) -> BasisFamily:
    """Graphic matroid of a graph: bases are spanning forests.

    Args:
        n_vertices: Number of vertices.
        edges: List of (u, v) edges.

    Returns:
        BasisFamily where bases are spanning forests (maximal acyclic edge subsets).
    """
    E = list(range(len(edges)))

    def find(parent, x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(parent, rank_arr, x, y):
        rx, ry = find(parent, x), find(parent, y)
        if rx == ry:
            return False
        if rank_arr[rx] < rank_arr[ry]:
            rx, ry = ry, rx
        parent[ry] = rx
        if rank_arr[rx] == rank_arr[ry]:
            rank_arr[rx] += 1
        return True

    def is_forest(edge_subset):
        parent = list(range(n_vertices))
        rank_arr = [0] * n_vertices
        for idx in edge_subset:
            u, v = edges[idx]
            if not union(parent, rank_arr, u, v):
                return False
        return True

    def is_spanning_forest(edge_subset):
        if not is_forest(edge_subset):
            return False
        parent = list(range(n_vertices))
        rank_arr = [0] * n_vertices
        for idx in edge_subset:
            u, v = edges[idx]
            union(parent, rank_arr, u, v)
        components = len({find(parent, v) for v in range(n_vertices)})
        return True  # maximal forest has n_vertices - components edges

    # Find the rank (size of any maximal forest)
    # Use greedy to find one spanning forest
    parent = list(range(n_vertices))
    rank_arr = [0] * n_vertices
    forest = []
    for i, (u, v) in enumerate(edges):
        if union(parent, rank_arr, u, v):
            forest.append(i)
    rank = len(forest)

    # Enumerate all forests of size = rank
    bases = set()
    for subset in combinations(E, rank):
        if is_forest(subset):
            # Check it's a maximal forest (same number of components)
            parent2 = list(range(n_vertices))
            rank_arr2 = [0] * n_vertices
            for idx in subset:
                u, v = edges[idx]
                union(parent2, rank_arr2, u, v)
            comps = len({find(parent2, v) for v in range(n_vertices)})
            parent3 = list(range(n_vertices))
            rank_arr3 = [0] * n_vertices
            for idx in forest:
                u, v = edges[idx]
                union(parent3, rank_arr3, u, v)
            comps_ref = len({find(parent3, v) for v in range(n_vertices)})
            if comps == comps_ref:
                bases.add(frozenset(subset))

    return BasisFamily(E, bases)


def transversal_matroid(n_left: int, neighbors: Dict[int, List[int]]) -> BasisFamily:
    """Transversal matroid from a bipartite graph.

    Args:
        n_left: Number of left vertices {0, ..., n_left-1}.
        neighbors: For each left vertex, list of right vertices it connects to.

    Returns:
        BasisFamily where bases are maximal matchable subsets of left vertices.
    """
    E = list(range(n_left))
    right_vertices = set()
    for nbrs in neighbors.values():
        right_vertices.update(nbrs)

    def find_matching(subset):
        """Find if subset of left vertices has a perfect matching (Hall's condition)."""
        # Use augmenting paths
        match_right = {}
        def augment(u, visited):
            for v in neighbors.get(u, []):
                if v not in visited:
                    visited.add(v)
                    if v not in match_right or augment(match_right[v], visited):
                        match_right[v] = u
                        return True
            return False

        match_right.clear()
        count = 0
        for u in subset:
            if augment(u, set()):
                count += 1
        return count == len(subset)

    # Find rank = size of maximum matching
    rank = 0
    for k in range(n_left, 0, -1):
        found = False
        for subset in combinations(E, k):
            if find_matching(subset):
                rank = k
                found = True
                break
        if found:
            break

    # Enumerate all bases (matchable subsets of size rank)
    bases = set()
    for subset in combinations(E, rank):
        if find_matching(subset):
            bases.add(frozenset(subset))

    return BasisFamily(E, bases)


# ─── Leaf Counting Algorithms ────────────────────────────────────────────────

def naive_ambient_leaf_count(n: int, r: int) -> int:
    """Worst-case ambient leaf count: C(n + r - 3, r - 2).

    For multiindices α with |α| = r-2 over n variables.
    For multiaffine case, this is C(n, r-2).
    """
    return comb(n, r - 2)


def support_compressed_leaf_count(M: BasisFamily) -> int:
    """Count nonzero quadratic leaves using support geometry.

    Returns the number of (rank-2)-element subsets that are independent.
    This is the exact complexity of Lorentzian recognition for the basis polynomial.
    """
    r = M.rank
    if r < 2:
        return 1 if r >= 0 else 0
    k = r - 2
    return len(M.independent_sets_of_size(k))


def active_variable_bound(M: BasisFamily) -> int:
    """Upper bound using active variable count: C(omega, r-2)."""
    omega = len(M.active_variables())
    return comb(omega, M.rank - 2)


def count_from_support_direct(bases: Set[FrozenSet[int]], ground_set: List[int], r: int) -> int:
    """Count surviving derivatives directly from support without matroid structure.

    For each (r-2)-subset α, check if α ⊆ β for some basis β.
    """
    k = r - 2
    count = 0
    for alpha in combinations(ground_set, k):
        alpha_set = frozenset(alpha)
        if any(alpha_set <= beta for beta in bases):
            count += 1
    return count


# ─── Analysis Functions ──────────────────────────────────────────────────────

def compression_analysis(M: BasisFamily, name: str = "") -> Dict:
    """Complete compression analysis for a matroid.

    Returns dict with ambient bound, actual count, compression ratio, etc.
    """
    n = len(M.ground_set)
    r = M.rank

    t0 = time.time()
    ambient = naive_ambient_leaf_count(n, r)
    t_ambient = time.time() - t0

    t0 = time.time()
    actual = support_compressed_leaf_count(M)
    t_actual = time.time() - t0

    omega = len(M.active_variables())
    active_bound = active_variable_bound(M)

    ratio = actual / ambient if ambient > 0 else 0

    return {
        "name": name,
        "n": n,
        "rank": r,
        "num_bases": len(M.bases),
        "ambient_leaf_count": ambient,
        "actual_leaf_count": actual,
        "active_variables": omega,
        "active_bound": active_bound,
        "compression_ratio": ratio,
        "time_ambient": t_ambient,
        "time_actual": t_actual,
    }


def print_analysis(result: Dict):
    """Pretty-print a compression analysis result."""
    print(f"\n{'=' * 60}")
    print(f"  {result['name']}")
    print(f"{'=' * 60}")
    print(f"  Ground set size (n):        {result['n']}")
    print(f"  Rank (r):                   {result['rank']}")
    print(f"  Number of bases:            {result['num_bases']}")
    print(f"  Active variables (ω):       {result['active_variables']}")
    print(f"  ─────────────────────────────────────────")
    print(f"  Ambient leaf count C(n,r-2):  {result['ambient_leaf_count']}")
    print(f"  Active bound C(ω,r-2):        {result['active_bound']}")
    print(f"  Actual leaf count:            {result['actual_leaf_count']}")
    print(f"  Compression ratio:            {result['compression_ratio']:.4f}")
    print(f"  ─────────────────────────────────────────")
    print(f"  Time (ambient):             {result['time_ambient']:.6f}s")
    print(f"  Time (actual):              {result['time_actual']:.6f}s")
