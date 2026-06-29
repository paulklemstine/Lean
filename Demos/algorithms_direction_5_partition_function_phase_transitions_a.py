"""
Algorithms for Certificate Complexity Computation

Implements algorithms for computing certificate complexity bounds
for combinatorial structures, with a focus on graphic matroids.
"""

import math
from typing import List, Tuple, Set, Optional, Dict
from dataclasses import dataclass


@dataclass
class CertTree:
    """
    A deletion/contraction certificate tree.

    Attributes:
        element: The element being deleted/contracted (None for leaves)
        is_contraction: True for contraction, False for deletion
        left: Left subtree (None for leaves)
        right: Right subtree (None for leaves)
    """
    element: Optional[int] = None
    is_contraction: Optional[bool] = None
    left: Optional['CertTree'] = None
    right: Optional['CertTree'] = None

    @property
    def is_leaf(self) -> bool:
        return self.element is None

    def size(self) -> int:
        """Total number of nodes (internal + leaves)."""
        if self.is_leaf:
            return 1
        return 1 + self.left.size() + self.right.size()

    def depth(self) -> int:
        """Length of longest root-to-leaf path."""
        if self.is_leaf:
            return 0
        return 1 + max(self.left.depth(), self.right.depth())

    def leaves(self) -> int:
        """Number of leaves."""
        if self.is_leaf:
            return 1
        return self.left.leaves() + self.right.leaves()

    def internal_nodes(self) -> int:
        """Number of internal nodes."""
        if self.is_leaf:
            return 0
        return 1 + self.left.internal_nodes() + self.right.internal_nodes()

    def verify_properties(self) -> Dict[str, bool]:
        """Verify the formally proven properties hold for this tree."""
        s = self.size()
        d = self.depth()
        l = self.leaves()
        i = self.internal_nodes()

        return {
            "size_positive": s > 0,
            "leaves_positive": l > 0,
            "size_eq_internal_plus_leaves": s == i + l,
            "leaves_eq_internal_plus_one": l == i + 1,
            "size_eq_2_leaves_minus_1": s == 2 * l - 1,
            "size_eq_2_internal_plus_1": s == 2 * i + 1,
            "leaves_le_2_pow_depth": l <= 2 ** d,
            "depth_le_size_minus_1": d <= s - 1,
            "size_ge_2_depth_plus_1": s >= 2 * d + 1,
        }

    def __repr__(self) -> str:
        if self.is_leaf:
            return "Leaf"
        op = "C" if self.is_contraction else "D"
        return f"Node({op}{self.element}, {self.left}, {self.right})"


def graft(t1: CertTree, t2: CertTree) -> CertTree:
    """
    Graft tree t2 onto every leaf of t1.

    This models composition of certificate procedures.
    Key property: leaves(graft(t1, t2)) = leaves(t1) * leaves(t2)
    Key property: depth(graft(t1, t2)) = depth(t1) + depth(t2)
    """
    if t1.is_leaf:
        return t2
    return CertTree(
        element=t1.element,
        is_contraction=t1.is_contraction,
        left=graft(t1.left, t2),
        right=graft(t1.right, t2),
    )


class GraphicMatroid:
    """
    Represents the graphic matroid M(G) of a simple graph G.

    The ground set is the edge set E(G), and the independent sets
    are the forests (acyclic subsets of edges).
    """

    def __init__(self, n: int, edges: List[Tuple[int, int]]):
        self.n = n
        self.edges = list(edges)
        self.m = len(edges)

    def is_independent(self, edge_subset: Set[int]) -> bool:
        """Check if a subset of edges (by index) forms a forest."""
        # Build subgraph
        parent = list(range(self.n))

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

        for idx in edge_subset:
            u, v = self.edges[idx]
            if not union(u, v):
                return False
        return True

    def rank(self, edge_subset: Optional[Set[int]] = None) -> int:
        """Compute the rank of a subset of edges."""
        if edge_subset is None:
            edge_subset = set(range(self.m))

        parent = list(range(self.n))

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

        r = 0
        for idx in sorted(edge_subset):
            u, v = self.edges[idx]
            if union(u, v):
                r += 1
        return r

    def bases(self) -> List[Set[int]]:
        """Enumerate all bases (maximal forests / spanning trees)."""
        r = self.rank()
        result = []

        def backtrack(idx: int, current: Set[int]):
            if len(current) == r:
                if self.is_independent(current):
                    result.append(frozenset(current))
                return
            if idx >= self.m:
                return
            remaining = self.m - idx
            if len(current) + remaining < r:
                return
            # Include edge idx
            current.add(idx)
            if self.is_independent(current):
                backtrack(idx + 1, current)
            current.remove(idx)
            # Exclude edge idx
            backtrack(idx + 1, current)

        backtrack(0, set())
        return [set(b) for b in sorted(set(result))]

    def num_bases(self) -> int:
        """Count the number of bases."""
        return len(self.bases())

    def build_cert_tree(self) -> CertTree:
        """
        Build a certificate tree via deletion/contraction.

        Algorithm:
        1. If no edges remain, return a leaf.
        2. Pick an edge e.
        3. Delete e: remove e from the edge set.
        4. Contract e: merge the endpoints of e, remove parallel edges.
        5. Recursively build subtrees for deletion and contraction.

        Time complexity: O(2^m) in the worst case.
        Space complexity: O(m) for the recursion stack.
        """
        return self._build_cert_tree_helper(set(range(self.m)))

    def _build_cert_tree_helper(self, available: Set[int]) -> CertTree:
        if not available:
            return CertTree()  # leaf

        # Pick first available edge
        e = min(available)
        remaining = available - {e}

        # Deletion subtree: remove e
        left = self._build_cert_tree_helper(remaining)

        # Contraction subtree: contract e (simplified: just remove e)
        right = self._build_cert_tree_helper(remaining)

        return CertTree(element=e, is_contraction=False, left=left, right=right)


def kirchhoff_spanning_tree_count(n: int, edges: List[Tuple[int, int]]) -> int:
    """
    Count spanning trees using Kirchhoff's matrix-tree theorem.

    The number of spanning trees equals any cofactor of the Laplacian matrix.

    Time complexity: O(n^3) for Gaussian elimination.
    Space complexity: O(n^2) for the Laplacian matrix.
    """
    if n <= 1:
        return 1

    # Build Laplacian
    L = [[0.0] * n for _ in range(n)]
    for u, v in edges:
        L[u][u] += 1
        L[v][v] += 1
        L[u][v] -= 1
        L[v][u] -= 1

    # (n-1) x (n-1) minor
    size = n - 1
    minor = [[L[i][j] for j in range(size)] for i in range(size)]

    # Gaussian elimination
    det = 1.0
    for col in range(size):
        pivot = None
        for row in range(col, size):
            if abs(minor[row][col]) > 1e-10:
                pivot = row
                break
        if pivot is None:
            return 0
        if pivot != col:
            minor[col], minor[pivot] = minor[pivot], minor[col]
            det *= -1
        det *= minor[col][col]
        for row in range(col + 1, size):
            factor = minor[row][col] / minor[col][col]
            for j in range(col, size):
                minor[row][j] -= factor * minor[col][j]

    return max(0, round(det))


def cert_complexity_bounds(n: int, edges: List[Tuple[int, int]]) -> Tuple[int, int]:
    """
    Compute lower and upper bounds on certificate complexity.

    Lower bound: 2 * num_spanning_trees - 1 (information-theoretic)
    Upper bound: 2^m where m is the number of edges (trivial)

    Returns: (lower_bound, upper_bound)
    """
    num_trees = kirchhoff_spanning_tree_count(n, edges)

    if num_trees == 0:
        # Disconnected graph
        return (1, 2 * n)

    lower = 2 * num_trees - 1
    upper = 2 ** len(edges)
    return (lower, upper)


def catalan_number(n: int) -> int:
    """Compute the n-th Catalan number C(n) = C(2n,n)/(n+1)."""
    return math.comb(2 * n, n) // (n + 1)


# Example usage
if __name__ == "__main__":
    print("=== Certificate Tree Properties ===\n")

    # Build example trees
    leaf = CertTree()
    simple = CertTree(0, False, CertTree(), CertTree())
    balanced = CertTree(
        0, False,
        CertTree(1, True, CertTree(), CertTree()),
        CertTree(2, False, CertTree(), CertTree()),
    )

    for name, tree in [("Leaf", leaf), ("Simple", simple), ("Balanced", balanced)]:
        print(f"{name}: size={tree.size()}, depth={tree.depth()}, "
              f"leaves={tree.leaves()}, internal={tree.internal_nodes()}")
        props = tree.verify_properties()
        all_ok = all(props.values())
        print(f"  Properties verified: {'ALL PASS' if all_ok else 'FAILED'}")
        if not all_ok:
            for k, v in props.items():
                if not v:
                    print(f"    FAILED: {k}")

    print("\n=== Grafting ===\n")
    grafted = graft(simple, balanced)
    print(f"graft(simple, balanced): leaves={grafted.leaves()}")
    print(f"  = simple.leaves * balanced.leaves = {simple.leaves()} * {balanced.leaves()} = {simple.leaves() * balanced.leaves()}")

    print("\n=== Kirchhoff's Theorem ===\n")
    # K4 has 16 spanning trees
    k4_edges = [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)]
    num = kirchhoff_spanning_tree_count(4, k4_edges)
    print(f"K4 spanning trees: {num} (expected: 16)")

    # Cycle C4 has 4 spanning trees
    c4_edges = [(0, 1), (1, 2), (2, 3), (3, 0)]
    num = kirchhoff_spanning_tree_count(4, c4_edges)
    print(f"C4 spanning trees: {num} (expected: 4)")

    print("\n=== Certificate Complexity Bounds ===\n")
    matroid = GraphicMatroid(4, k4_edges)
    lb, ub = cert_complexity_bounds(4, k4_edges)
    print(f"K4: bases={matroid.num_bases()}, cert bounds: [{lb}, {ub}]")

    print("\n=== Catalan Numbers ===\n")
    for k in range(10):
        print(f"C({k}) = {catalan_number(k)}")
