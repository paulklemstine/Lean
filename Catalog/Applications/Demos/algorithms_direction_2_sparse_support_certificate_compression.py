"""
Support Certificate Compression Algorithms for Matroid Basis Polynomials

Implements the core algorithms from the support compression theory:
- BasisFamily: abstraction of matroid basis systems
- Nonzero quadratic leaf counting from support data
- Uniform, graphic, and transversal matroid constructors
- Active variable analysis

All algorithms avoid polynomial differentiation; they work directly on
combinatorial support data.
"""

from itertools import combinations
from math import comb
from typing import List, Set, FrozenSet, Optional, Tuple, Dict
from collections import defaultdict


class BasisFamily:
    """A basis family: a collection of r-element subsets of {0, ..., n-1}.

    This abstracts a matroid's basis system for support certificate compression.

    Attributes:
        n: Size of the ground set.
        r: Rank (common cardinality of all bases).
        bases: Frozenset of frozensets, each a basis.
    """

    def __init__(self, n: int, r: int, bases: List[Set[int]]):
        """Initialize a basis family.

        Args:
            n: Ground set size.
            r: Rank (each basis must have this cardinality).
            bases: List of sets, each an r-element subset of {0, ..., n-1}.

        Raises:
            ValueError: If bases is empty or any basis has wrong cardinality.
        """
        if not bases:
            raise ValueError("Basis family must be nonempty")
        self.n = n
        self.r = r
        self.bases: FrozenSet[FrozenSet[int]] = frozenset(
            frozenset(b) for b in bases
        )
        for b in self.bases:
            if len(b) != r:
                raise ValueError(f"Basis {b} has cardinality {len(b)}, expected {r}")
            if not all(0 <= i < n for i in b):
                raise ValueError(f"Basis {b} contains elements outside [0, {n})")

    def is_indep(self, I: Set[int]) -> bool:
        """Check if a set is independent (contained in some basis).

        Args:
            I: A subset of the ground set.

        Returns:
            True if I is a subset of some basis.
        """
        fI = frozenset(I)
        return any(fI <= b for b in self.bases)

    def indep_sets(self, k: int) -> List[FrozenSet[int]]:
        """Enumerate all independent sets of size k.

        Args:
            k: Target cardinality.

        Returns:
            List of independent k-element subsets.
        """
        ground = list(range(self.n))
        return [
            frozenset(combo)
            for combo in combinations(ground, k)
            if self.is_indep(set(combo))
        ]

    def nonzero_quadratic_leaf_set(self, k: Optional[int] = None) -> List[FrozenSet[int]]:
        """Compute the nonzero quadratic leaf set.

        Args:
            k: Size of derivative multiindex. Defaults to r - 2.

        Returns:
            List of independent k-element subsets (surviving leaves).
        """
        if k is None:
            k = self.r - 2
        return self.indep_sets(k)

    def support_compressed_leaf_count(self, k: Optional[int] = None) -> int:
        """Count the number of surviving derivative leaves.

        Args:
            k: Size of derivative multiindex. Defaults to r - 2.

        Returns:
            Number of independent k-element subsets.
        """
        if k is None:
            k = self.r - 2
        return len(self.nonzero_quadratic_leaf_set(k))

    def active_variables(self) -> Set[int]:
        """Compute the active variable set.

        Returns:
            Set of variables appearing in at least one basis.
        """
        return set().union(*self.bases)

    def active_variable_count(self) -> int:
        """Count the number of active variables.

        Returns:
            |A(F)| where A(F) is the active variable set.
        """
        return len(self.active_variables())

    def ambient_leaf_count(self, k: Optional[int] = None) -> int:
        """Compute the naive ambient leaf count C(n, k).

        Args:
            k: Derivative order. Defaults to r - 2.

        Returns:
            C(n, k), the number of k-element subsets of [n].
        """
        if k is None:
            k = self.r - 2
        return comb(self.n, k)

    def compression_ratio(self) -> float:
        """Compute the compression ratio: actual / ambient.

        Returns:
            Ratio of actual to ambient leaf count. Lower is better.
        """
        ambient = self.ambient_leaf_count()
        if ambient == 0:
            return 1.0
        return self.support_compressed_leaf_count() / ambient

    def __repr__(self) -> str:
        return f"BasisFamily(n={self.n}, r={self.r}, |bases|={len(self.bases)})"


def uniform_matroid(n: int, r: int) -> BasisFamily:
    """Construct the uniform matroid U_{r,n}.

    All r-element subsets of {0, ..., n-1} are bases.

    Args:
        n: Ground set size.
        r: Rank.

    Returns:
        BasisFamily for U_{r,n}.

    >>> F = uniform_matroid(5, 3)
    >>> F.support_compressed_leaf_count()  # C(5, 1) = 5
    5
    """
    bases = [set(combo) for combo in combinations(range(n), r)]
    return BasisFamily(n, r, bases)


def graphic_matroid(n_vertices: int, edges: List[Tuple[int, int]]) -> BasisFamily:
    """Construct the graphic matroid from a connected graph.

    Bases are spanning trees (edge sets of connected acyclic subgraphs
    with n_vertices - 1 edges).

    Args:
        n_vertices: Number of vertices.
        edges: List of edges as (u, v) pairs. Edges are indexed 0, 1, ...

    Returns:
        BasisFamily for the graphic matroid.

    >>> F = graphic_matroid(3, [(0,1), (1,2), (0,2)])  # Triangle
    >>> F.r  # rank = n_vertices - 1
    2
    >>> len(F.bases)  # 3 spanning trees
    3
    """
    n_edges = len(edges)
    r = n_vertices - 1

    # Find all spanning trees by brute force
    bases = []
    for combo in combinations(range(n_edges), r):
        # Check if this edge set forms a spanning tree
        edge_set = [edges[i] for i in combo]
        if is_spanning_tree(n_vertices, edge_set):
            bases.append(set(combo))

    if not bases:
        raise ValueError("Graph is not connected (no spanning trees)")

    return BasisFamily(n_edges, r, bases)


def is_spanning_tree(n_vertices: int, edges: List[Tuple[int, int]]) -> bool:
    """Check if an edge set forms a spanning tree.

    Args:
        n_vertices: Number of vertices.
        edges: List of edges.

    Returns:
        True if edges form a connected acyclic graph on all vertices.
    """
    if len(edges) != n_vertices - 1:
        return False

    # Union-Find
    parent = list(range(n_vertices))

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    for u, v in edges:
        ru, rv = find(u), find(v)
        if ru == rv:
            return False  # Cycle
        parent[ru] = rv

    # Check connectivity
    root = find(0)
    return all(find(i) == root for i in range(n_vertices))


def path_graph_matroid(n_vertices: int) -> BasisFamily:
    """Graphic matroid of a path graph P_n.

    Args:
        n_vertices: Number of vertices.

    Returns:
        BasisFamily for the path graph.

    >>> F = path_graph_matroid(5)
    >>> F.n  # 4 edges
    4
    >>> F.r  # rank 4 (path is a tree)
    4
    """
    edges = [(i, i + 1) for i in range(n_vertices - 1)]
    return graphic_matroid(n_vertices, edges)


def cycle_graph_matroid(n_vertices: int) -> BasisFamily:
    """Graphic matroid of a cycle graph C_n.

    Args:
        n_vertices: Number of vertices (must be >= 3).

    Returns:
        BasisFamily for the cycle graph.

    >>> F = cycle_graph_matroid(4)
    >>> F.n  # 4 edges
    4
    >>> F.r  # rank 3
    3
    """
    edges = [(i, (i + 1) % n_vertices) for i in range(n_vertices)]
    return graphic_matroid(n_vertices, edges)


def complete_graph_matroid(n_vertices: int) -> BasisFamily:
    """Graphic matroid of the complete graph K_n.

    Args:
        n_vertices: Number of vertices.

    Returns:
        BasisFamily for K_n.
    """
    edges = [(i, j) for i in range(n_vertices) for j in range(i + 1, n_vertices)]
    return graphic_matroid(n_vertices, edges)


def transversal_matroid(n: int, sets: List[Set[int]]) -> BasisFamily:
    """Construct a transversal matroid from a bipartite incidence.

    A transversal matroid has as bases the systems of distinct representatives
    (SDRs) of a family of sets.

    Args:
        n: Size of the ground set.
        sets: List of subsets of {0, ..., n-1}. Each set represents
              the choices for one "slot".

    Returns:
        BasisFamily for the transversal matroid.
    """
    r = len(sets)

    def find_sdrs(idx, used):
        if idx == r:
            yield frozenset(used)
            return
        for elem in sets[idx]:
            if elem not in used:
                used_new = used | {elem}
                yield from find_sdrs(idx + 1, used_new)

    bases = list(set(find_sdrs(0, frozenset())))
    if not bases:
        raise ValueError("No system of distinct representatives exists")

    return BasisFamily(n, r, [set(b) for b in bases])


def analyze_compression(F: BasisFamily, label: str = "") -> Dict:
    """Analyze the support compression for a basis family.

    Args:
        F: A basis family.
        label: Optional label for display.

    Returns:
        Dictionary with analysis results.
    """
    k = F.r - 2
    actual = F.support_compressed_leaf_count()
    ambient = F.ambient_leaf_count()
    active = F.active_variable_count()
    active_bound = comb(active, k)
    ratio = actual / ambient if ambient > 0 else 1.0

    result = {
        "label": label,
        "n": F.n,
        "r": F.r,
        "k": k,
        "num_bases": len(F.bases),
        "actual_leaves": actual,
        "ambient_count": ambient,
        "active_vars": active,
        "active_bound": active_bound,
        "compression_ratio": ratio,
    }

    if label:
        print(f"\n{'=' * 60}")
        print(f"  {label}")
        print(f"{'=' * 60}")
        print(f"  Ground set size (n):    {F.n}")
        print(f"  Rank (r):               {F.r}")
        print(f"  Number of bases:        {len(F.bases)}")
        print(f"  Derivative order (k):   {k}")
        print(f"  Active variables:       {active}")
        print(f"  Actual leaf count:      {actual}")
        print(f"  Ambient count C(n,k):   {ambient}")
        print(f"  Active bound C(ω,k):    {active_bound}")
        print(f"  Compression ratio:      {ratio:.4f}")

    return result


if __name__ == "__main__":
    print("=" * 60)
    print("  Support Certificate Compression: Algorithm Demos")
    print("=" * 60)

    # Uniform matroid
    analyze_compression(uniform_matroid(8, 4), "Uniform Matroid U_{4,8}")

    # Path graph
    analyze_compression(path_graph_matroid(8), "Path Graph P_8")

    # Cycle graph
    analyze_compression(cycle_graph_matroid(6), "Cycle Graph C_6")

    # Complete graph K_5
    analyze_compression(complete_graph_matroid(5), "Complete Graph K_5")

    # Transversal matroid
    sets = [{0, 1, 2}, {1, 2, 3}, {2, 3, 4}]
    analyze_compression(transversal_matroid(5, sets), "Transversal Matroid (3 sets on 5 elements)")
