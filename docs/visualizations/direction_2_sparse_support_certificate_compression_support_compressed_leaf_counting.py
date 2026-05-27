"""
algorithms.py — Support-Compressed Certificate Counting for Matroid Basis Polynomials

Implements the core algorithms from the formalized theory:
1. Basis generating polynomial construction
2. Derivative survival testing
3. Support-compressed leaf counting
4. Naive vs compressed comparison

All algorithms operate on matroid basis families represented as sets of frozensets.
"""

from __future__ import annotations
from itertools import combinations
from math import comb
from typing import FrozenSet, Set, Collection
import time


# ──────────────────────────────────────────────────────────────────────
# Core Data Structures
# ──────────────────────────────────────────────────────────────────────

class BasisFamily:
    """A matroid-like structure: a nonempty collection of r-element subsets of {0,...,n-1}.

    Attributes:
        n: size of the ground set
        r: common cardinality of all bases
        bases: frozenset of frozensets, each of size r
    """

    def __init__(self, n: int, r: int, bases: Collection[FrozenSet[int]]):
        self.n = n
        self.r = r
        self.bases = frozenset(bases)
        assert len(self.bases) > 0, "Basis family must be nonempty"
        for B in self.bases:
            assert len(B) == r, f"Basis {B} has size {len(B)}, expected {r}"
            assert all(0 <= i < n for i in B), f"Basis {B} has elements outside [0, {n})"

    def is_indep(self, I: FrozenSet[int]) -> bool:
        """Check if I is independent (contained in some basis)."""
        return any(I <= B for B in self.bases)

    def indep_sets(self, k: int) -> list[FrozenSet[int]]:
        """Return all independent sets of size k."""
        return [
            frozenset(S) for S in combinations(range(self.n), k)
            if self.is_indep(frozenset(S))
        ]

    def indep_count(self, k: int) -> int:
        """Count independent sets of size k."""
        return len(self.indep_sets(k))

    def active_vars(self) -> FrozenSet[int]:
        """Variables appearing in at least one basis."""
        result: set[int] = set()
        for B in self.bases:
            result |= B
        return frozenset(result)

    def active_var_count(self) -> int:
        """Number of active variables."""
        return len(self.active_vars())

    def support_compressed_leaf_count(self) -> int:
        """The certificate complexity: number of independent (r-2)-sets."""
        if self.r < 2:
            return 0
        return self.indep_count(self.r - 2)

    def ambient_leaf_count(self) -> int:
        """Naive ambient worst-case: C(n, r-2)."""
        if self.r < 2:
            return 0
        return comb(self.n, self.r - 2)

    def compression_ratio(self) -> float:
        """Ratio of actual/ambient leaf count."""
        ambient = self.ambient_leaf_count()
        if ambient == 0:
            return 0.0
        return self.support_compressed_leaf_count() / ambient


# ──────────────────────────────────────────────────────────────────────
# Standard Matroid Constructors
# ──────────────────────────────────────────────────────────────────────

def uniform_matroid(n: int, r: int) -> BasisFamily:
    """Uniform matroid U_{r,n}: every r-element subset is a basis.

    >>> F = uniform_matroid(5, 3)
    >>> F.support_compressed_leaf_count() == comb(5, 1)
    True
    """
    bases = [frozenset(S) for S in combinations(range(n), r)]
    return BasisFamily(n, r, bases)


def graphic_matroid(n_vertices: int, edges: list[tuple[int, int]]) -> BasisFamily:
    """Graphic matroid of a graph: bases are spanning forests.

    Args:
        n_vertices: number of vertices (labeled 0..n_vertices-1)
        edges: list of (u, v) edges (0-indexed)

    Returns:
        BasisFamily on ground set = edges, with bases = spanning forests of max size.
    """
    n_edges = len(edges)

    def is_forest(edge_indices: Collection[int]) -> bool:
        """Check if the selected edges form a forest (no cycles)."""
        parent = list(range(n_vertices))

        def find(x: int) -> int:
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x

        def union(x: int, y: int) -> bool:
            px, py = find(x), find(y)
            if px == py:
                return False
            parent[px] = py
            return True

        return all(union(edges[i][0], edges[i][1]) for i in edge_indices)

    # Find maximum forest size
    max_forest = 0
    for k in range(n_edges + 1):
        for S in combinations(range(n_edges), k):
            if is_forest(S):
                max_forest = max(max_forest, k)

    bases = [
        frozenset(S) for S in combinations(range(n_edges), max_forest)
        if is_forest(S)
    ]

    if not bases:
        # Fallback: single empty basis for edgeless graph
        bases = [frozenset()]
        max_forest = 0

    return BasisFamily(n_edges, max_forest, bases)


def transversal_matroid(n_left: int, n_right: int,
                         edges: list[tuple[int, int]]) -> BasisFamily:
    """Transversal matroid from a bipartite graph.

    Bases are maximum matchings (as sets of left vertices matched).

    Args:
        n_left: number of left vertices
        n_right: number of right vertices
        edges: list of (left_vertex, right_vertex) pairs
    """
    # Find all matchings by brute force
    def max_matchings() -> tuple[int, list[FrozenSet[int]]]:
        """Find all maximum matchings, return (size, list of matched left vertex sets)."""
        best_size = 0
        results: list[FrozenSet[int]] = []

        def backtrack(idx: int, matched_left: set[int],
                      matched_right: set[int]) -> None:
            nonlocal best_size, results
            current_size = len(matched_left)

            if current_size > best_size:
                best_size = current_size
                results = [frozenset(matched_left)]
            elif current_size == best_size and current_size > 0:
                results.append(frozenset(matched_left))

            if idx >= len(edges):
                return

            for i in range(idx, len(edges)):
                l, r = edges[i]
                if l not in matched_left and r not in matched_right:
                    matched_left.add(l)
                    matched_right.add(r)
                    backtrack(i + 1, matched_left, matched_right)
                    matched_left.remove(l)
                    matched_right.remove(r)

        backtrack(0, set(), set())
        return best_size, results

    r, bases = max_matchings()
    if not bases:
        bases = [frozenset()]
        r = 0

    return BasisFamily(n_left, r, set(bases))


# ──────────────────────────────────────────────────────────────────────
# Derivative Survival Algorithm
# ──────────────────────────────────────────────────────────────────────

def derivative_survives(bases: Collection[FrozenSet[int]],
                         S: FrozenSet[int]) -> bool:
    """Check if the iterated derivative ∂_S(B_M) is nonzero.

    By the derivative survival theorem, this is equivalent to
    S being independent (contained in some basis).

    Time: O(|bases| · |S|) — just a subset check per basis.
    """
    return any(S <= B for B in bases)


def count_nonzero_leaves_naive(n: int, r: int,
                                 bases: Collection[FrozenSet[int]]) -> int:
    """Count nonzero quadratic leaves by checking all C(n, r-2) candidates.

    This is the naive approach: enumerate all (r-2)-subsets and test each.
    """
    if r < 2:
        return 0
    count = 0
    for S in combinations(range(n), r - 2):
        if derivative_survives(bases, frozenset(S)):
            count += 1
    return count


def count_nonzero_leaves_compressed(F: BasisFamily) -> int:
    """Count nonzero quadratic leaves using support compression.

    Equivalent to count_nonzero_leaves_naive but emphasizes the
    support-geometric interpretation.
    """
    return F.support_compressed_leaf_count()


# ──────────────────────────────────────────────────────────────────────
# Benchmark Utilities
# ──────────────────────────────────────────────────────────────────────

def benchmark_matroid(name: str, F: BasisFamily) -> dict:
    """Compute all relevant statistics for a matroid.

    Returns dict with:
        name, n, r, num_bases, ambient_count, actual_count,
        active_vars, active_bound, ratio, time_ms
    """
    t0 = time.perf_counter()
    actual = F.support_compressed_leaf_count()
    t1 = time.perf_counter()

    ambient = F.ambient_leaf_count()
    active = F.active_var_count()
    active_bound = comb(active, F.r - 2) if F.r >= 2 else 0

    return {
        "name": name,
        "n": F.n,
        "r": F.r,
        "num_bases": len(F.bases),
        "ambient_count": ambient,
        "actual_count": actual,
        "active_vars": active,
        "active_bound": active_bound,
        "ratio": actual / ambient if ambient > 0 else 0.0,
        "time_ms": (t1 - t0) * 1000,
    }


if __name__ == "__main__":
    # Quick self-test
    F = uniform_matroid(6, 3)
    assert F.support_compressed_leaf_count() == comb(6, 1) == 6
    print(f"U_{{3,6}}: leaf count = {F.support_compressed_leaf_count()}, "
          f"expected C(6,1) = 6 ✓")

    F = uniform_matroid(8, 4)
    assert F.support_compressed_leaf_count() == comb(8, 2) == 28
    print(f"U_{{4,8}}: leaf count = {F.support_compressed_leaf_count()}, "
          f"expected C(8,2) = 28 ✓")

    # Graphic matroid of a path on 4 vertices
    path_edges = [(0, 1), (1, 2), (2, 3)]
    G = graphic_matroid(4, path_edges)
    stats = benchmark_matroid("Path_4", G)
    print(f"Path_4: actual={stats['actual_count']}, "
          f"ambient={stats['ambient_count']}, "
          f"ratio={stats['ratio']:.3f}")

    print("\nAll self-tests passed.")
