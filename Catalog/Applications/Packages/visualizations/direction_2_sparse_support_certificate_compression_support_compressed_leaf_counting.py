"""
Algorithms for Sparse-Support Certificate Compression
for Matroid Basis Polynomials.

Implements the core algorithms from the research paper:
- Independent set counting for basis families
- Support-compressed leaf counting
- Uniform matroid computation
- Active variable compression

All algorithms are designed to match the formally verified Lean implementations.
"""

from itertools import combinations
from math import comb
from typing import FrozenSet, Set, List, Tuple


class BasisFamily:
    """A basis family: a collection of r-element subsets.

    Represents the basis system of a matroid or matroid-like structure.
    Provides methods for independent set enumeration and leaf counting.

    Args:
        bases: Collection of bases, each a frozenset of integers
        n: Size of the ground set
        r: Rank (common cardinality of all bases)

    Example:
        >>> # Uniform matroid U_{3,5}
        >>> bf = BasisFamily.uniform(5, 3)
        >>> bf.indep_count(1)  # All 5 singletons are independent
        5
    """

    def __init__(self, bases: Set[FrozenSet[int]], n: int, r: int):
        self.bases = set(bases)
        self.n = n
        self.r = r
        assert all(len(b) == r for b in bases), "All bases must have size r"
        assert len(bases) > 0, "Must have at least one basis"

    @classmethod
    def uniform(cls, n: int, r: int) -> 'BasisFamily':
        """Create the uniform matroid U_{r,n}: all r-subsets are bases."""
        bases = {frozenset(c) for c in combinations(range(n), r)}
        return cls(bases, n, r)

    @classmethod
    def from_single_basis(cls, basis: FrozenSet[int], n: int) -> 'BasisFamily':
        """Create a basis family with a single basis."""
        return cls({basis}, n, len(basis))

    @classmethod
    def graphic(cls, edges: List[Tuple[int, int]], num_vertices: int) -> 'BasisFamily':
        """Create the graphic matroid from a graph.

        Bases are spanning trees (or spanning forests of maximum size).

        Args:
            edges: List of (u, v) edges
            num_vertices: Number of vertices

        Returns:
            BasisFamily for the graphic matroid
        """
        n = len(edges)
        # Find all spanning trees using brute force for small graphs
        rank = num_vertices - 1  # for connected graphs

        # First determine the actual rank (size of max spanning forest)
        # by finding the maximum subset of edges forming a forest
        from collections import defaultdict

        def is_forest(edge_subset):
            """Check if a subset of edges forms a forest (acyclic)."""
            adj = defaultdict(set)
            vertices = set()
            for idx in edge_subset:
                u, v = edges[idx]
                adj[u].add(v)
                adj[v].add(u)
                vertices.add(u)
                vertices.add(v)
            # BFS/DFS to check for cycles
            visited = set()
            for start in vertices:
                if start in visited:
                    continue
                queue = [(start, -1)]
                while queue:
                    node, parent = queue.pop()
                    if node in visited:
                        return False
                    visited.add(node)
                    for neighbor in adj[node]:
                        if neighbor != parent:
                            queue.append((neighbor, node))
            return True

        def spans_all(edge_subset):
            """Check if edges span all vertices (for connected graphs)."""
            if not edge_subset:
                return num_vertices <= 1
            adj = defaultdict(set)
            vertices_in_edges = set()
            for idx in edge_subset:
                u, v = edges[idx]
                adj[u].add(v)
                adj[v].add(u)
                vertices_in_edges.add(u)
                vertices_in_edges.add(v)
            # Check connectivity of the vertices
            if not vertices_in_edges:
                return False
            visited = set()
            queue = [next(iter(vertices_in_edges))]
            while queue:
                node = queue.pop()
                if node in visited:
                    continue
                visited.add(node)
                for neighbor in adj[node]:
                    if neighbor not in visited:
                        queue.append(neighbor)
            return visited == set(range(num_vertices))

        # Find maximum forest size
        actual_rank = 0
        for size in range(n, 0, -1):
            found = False
            for subset in combinations(range(n), size):
                if is_forest(subset) and spans_all(subset):
                    actual_rank = size
                    found = True
                    break
            if found:
                break

        if actual_rank == 0:
            actual_rank = min(n, num_vertices - 1)

        # Find all bases (maximum forests / spanning trees)
        bases = set()
        for subset in combinations(range(n), actual_rank):
            if is_forest(subset) and spans_all(subset):
                bases.add(frozenset(subset))

        if not bases:
            # Disconnected graph: find max forests
            for size in range(n, 0, -1):
                for subset in combinations(range(n), size):
                    if is_forest(subset):
                        bases.add(frozenset(subset))
                if bases:
                    actual_rank = size
                    break

        return cls(bases, n, actual_rank)

    def active_vars(self) -> Set[int]:
        """Return the set of active variables (those in at least one basis)."""
        result = set()
        for b in self.bases:
            result |= b
        return result

    def active_var_count(self) -> int:
        """Return the number of active variables."""
        return len(self.active_vars())

    def is_independent(self, I: FrozenSet[int]) -> bool:
        """Check if a set is independent (contained in some basis)."""
        return any(I <= b for b in self.bases)

    def indep_sets(self, k: int) -> Set[FrozenSet[int]]:
        """Return all independent sets of size k."""
        result = set()
        for subset in combinations(range(self.n), k):
            fs = frozenset(subset)
            if self.is_independent(fs):
                result.add(fs)
        return result

    def indep_count(self, k: int) -> int:
        """Count independent sets of size k."""
        return len(self.indep_sets(k))

    def quadratic_leaf_count(self) -> int:
        """Count nonzero quadratic leaves = independent (r-2)-sets.

        This is the main algorithm: the number of surviving derivative
        branches in the Lorentzian recognition recursion tree.
        """
        if self.r < 2:
            return 0
        return self.indep_count(self.r - 2)

    def ambient_leaf_count(self) -> int:
        """The naive worst-case leaf count: C(n, r-2)."""
        if self.r < 2:
            return 0
        return comb(self.n, self.r - 2)

    def compression_ratio(self) -> float:
        """Ratio of actual to ambient leaf count."""
        ambient = self.ambient_leaf_count()
        if ambient == 0:
            return 0.0
        return self.quadratic_leaf_count() / ambient

    def active_bound(self) -> int:
        """Upper bound from active variable compression: C(omega, r-2)."""
        if self.r < 2:
            return 0
        return comb(self.active_var_count(), self.r - 2)


def count_nonzero_quadratic_leaves(bases: Set[FrozenSet[int]], n: int, r: int) -> int:
    """Count nonzero quadratic leaves from basis data.

    This is the verified algorithm: count (r-2)-element subsets
    contained in some basis, without polynomial differentiation.

    Args:
        bases: Set of bases (each a frozenset)
        n: Ground set size
        r: Rank

    Returns:
        Number of nonzero quadratic leaves

    Example:
        >>> bases = {frozenset({0,1,2}), frozenset({1,2,3})}
        >>> count_nonzero_quadratic_leaves(bases, 4, 3)
        4
    """
    if r < 2:
        return 0
    k = r - 2
    count = 0
    for subset in combinations(range(n), k):
        fs = frozenset(subset)
        if any(fs <= b for b in bases):
            count += 1
    return count


def active_variable_bound(bases: Set[FrozenSet[int]], r: int) -> int:
    """Compute the active variable compression bound.

    Returns C(omega, r-2) where omega = |union of all bases|.
    """
    if r < 2:
        return 0
    active = set()
    for b in bases:
        active |= b
    return comb(len(active), r - 2)


if __name__ == "__main__":
    # Example usage
    print("=== Uniform Matroid U_{3,6} ===")
    bf = BasisFamily.uniform(6, 3)
    print(f"Number of bases: {len(bf.bases)}")
    print(f"Quadratic leaves: {bf.quadratic_leaf_count()}")
    print(f"Ambient bound: {bf.ambient_leaf_count()}")
    print(f"Compression ratio: {bf.compression_ratio():.4f}")
    print()

    print("=== Single Basis {{0,1,2,3}}, n=8 ===")
    bf2 = BasisFamily.from_single_basis(frozenset({0,1,2,3}), 8)
    print(f"Quadratic leaves: {bf2.quadratic_leaf_count()}")
    print(f"Ambient bound: {bf2.ambient_leaf_count()}")
    print(f"Active bound: {bf2.active_bound()}")
    print(f"Compression ratio: {bf2.compression_ratio():.4f}")
