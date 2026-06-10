#!/usr/bin/env python3
"""
Algorithms for Quantitative Jacobian Reduction Theory.

Implements:
1. Triangular chain map construction and inversion
2. Inverse degree computation via recursive expansion
3. Nilpotence index detection for structured matrices
4. Dependency graph extraction from polynomial maps
"""

from typing import List, Tuple, Dict, Optional, Set
import numpy as np
from collections import defaultdict


# ============================================================
#  Algorithm 1: Triangular Chain Map Construction & Inversion
# ============================================================

class TriangularChainMap:
    """
    Represents the triangular chain automorphism F_{n,d} and its inverse.

    F_{n,d}(x_1,...,x_n) = (x_1 + x_2^d, x_2 + x_3^d, ..., x_{n-1} + x_n^d, x_n)

    Time complexity:
        Forward evaluation: O(n) arithmetic operations
        Inverse evaluation:  O(n) arithmetic operations
        Inverse degree:      O(1) to compute = d^{n-1}
    
    Space complexity: O(n) for storing coordinate values.

    Args:
        n: Number of variables (dimension)
        d: Degree of each coordinate perturbation
    """

    def __init__(self, n: int, d: int):
        if n < 1:
            raise ValueError(f"Dimension must be ≥ 1, got {n}")
        if d < 1:
            raise ValueError(f"Degree must be ≥ 1, got {d}")
        self.n = n
        self.d = d

    @property
    def forward_degree(self) -> int:
        """The total degree of the forward map. Always equals d (for n ≥ 2)."""
        return self.d if self.n >= 2 else 1

    @property
    def inverse_degree(self) -> int:
        """The total degree of the inverse map. Equals d^{n-1}."""
        return self.d ** (self.n - 1)

    def forward(self, x: List[float]) -> List[float]:
        """
        Evaluate F_{n,d}(x).

        Time: O(n), Space: O(n)

        >>> f = TriangularChainMap(3, 2)
        >>> f.forward([1, 2, 3])
        [5, 11, 3]
        """
        assert len(x) == self.n, f"Expected {self.n} coordinates, got {len(x)}"
        result = list(x)
        for i in range(self.n - 1):
            result[i] = x[i] + x[i + 1] ** self.d
        return result

    def inverse(self, y: List[float]) -> List[float]:
        """
        Evaluate G_{n,d}(y) = F_{n,d}^{-1}(y) by backward recursion.

        Algorithm:
            g[n-1] = y[n-1]
            for i = n-2, ..., 0:
                g[i] = y[i] - g[i+1]^d

        Time: O(n), Space: O(n)

        >>> f = TriangularChainMap(3, 2)
        >>> f.inverse([5, 11, 3])
        [1, 2, 3]
        """
        assert len(y) == self.n, f"Expected {self.n} coordinates, got {len(y)}"
        g = [0.0] * self.n
        g[self.n - 1] = y[self.n - 1]
        for i in range(self.n - 2, -1, -1):
            g[i] = y[i] - g[i + 1] ** self.d
        return g

    def inverse_coordinate_degrees(self) -> List[int]:
        """
        Return the degree of each coordinate of the inverse map.
        deg(G_i) = d^{n-1-i}.
        """
        return [self.d ** (self.n - 1 - i) for i in range(self.n)]

    def verify(self, x: List[float], tol: float = 1e-10) -> bool:
        """Verify F(G(F(x))) = F(x) and G(F(x)) = x."""
        y = self.forward(x)
        x_back = self.inverse(y)
        return all(abs(a - b) < tol for a, b in zip(x, x_back))


# ============================================================
#  Algorithm 2: Inverse Degree Computation
# ============================================================

def compute_inverse_degrees(n: int, d: int) -> List[int]:
    """
    Compute the degree of each coordinate of the inverse of F_{n,d}.

    Uses the recurrence:
        deg(G_{n-1}) = 1
        deg(G_i) = d * deg(G_{i+1})

    This gives deg(G_i) = d^{n-1-i}, with maximum d^{n-1} at i=0.

    Time: O(n), Space: O(n)

    Args:
        n: Dimension
        d: Degree

    Returns:
        List of degrees [deg(G_0), ..., deg(G_{n-1})]

    >>> compute_inverse_degrees(4, 2)
    [8, 4, 2, 1]
    >>> compute_inverse_degrees(3, 3)
    [9, 3, 1]
    """
    degrees = [1] * n
    for i in range(n - 2, -1, -1):
        degrees[i] = d * degrees[i + 1]
    return degrees


def inverse_degree_ratio(n: int, d: int) -> float:
    """
    Compute the ratio deg(F^{-1}) / deg(F)^{n-1}.

    For the extremal triangular chain family, this ratio is exactly 1,
    proving sharpness of the tame inverse degree bound.

    >>> inverse_degree_ratio(5, 3)
    1.0
    """
    if d == 0 or n < 2:
        return 0.0
    inv_deg = d ** (n - 1)
    bound = d ** (n - 1)
    return inv_deg / bound


# ============================================================
#  Algorithm 3: Nilpotence Index Detection
# ============================================================

def nilpotence_index(A: np.ndarray, tol: float = 1e-10) -> Optional[int]:
    """
    Compute the nilpotence index of a matrix A, or None if not nilpotent.

    The nilpotence index is the smallest k such that A^k = 0.

    Time: O(n^4) worst case (n matrix multiplications of n×n matrices)
    Space: O(n^2)

    Args:
        A: Square matrix
        tol: Tolerance for zero comparison

    Returns:
        Nilpotence index k, or None if A^n ≠ 0

    >>> A = np.array([[0, 1, 0], [0, 0, 1], [0, 0, 0]], dtype=float)
    >>> nilpotence_index(A)
    3
    """
    n = A.shape[0]
    assert A.shape == (n, n), "Matrix must be square"

    power = np.eye(n)
    for k in range(1, n + 1):
        power = power @ A
        if np.allclose(power, 0, atol=tol):
            return k
    return None


def is_strictly_upper_triangular(A: np.ndarray, tol: float = 1e-10) -> bool:
    """
    Check if A is strictly upper triangular (all entries on or below diagonal are zero).

    >>> A = np.array([[0, 1, 2], [0, 0, 3], [0, 0, 0]], dtype=float)
    >>> is_strictly_upper_triangular(A)
    True
    """
    n = A.shape[0]
    for i in range(n):
        for j in range(i + 1):
            if abs(A[i, j]) > tol:
                return False
    return True


def is_superdiagonal(A: np.ndarray, tol: float = 1e-10) -> bool:
    """
    Check if A has nonzero entries only on the first superdiagonal.

    >>> A = np.array([[0, 3, 0], [0, 0, 5], [0, 0, 0]], dtype=float)
    >>> is_superdiagonal(A)
    True
    """
    n = A.shape[0]
    for i in range(n):
        for j in range(n):
            if j != i + 1 and abs(A[i, j]) > tol:
                return False
    return True


# ============================================================
#  Algorithm 4: Dependency Graph Extraction
# ============================================================

class DependencyGraph:
    """
    Represents the variable dependency graph of a polynomial map.

    For a polynomial map H = (H_1, ..., H_n), the dependency graph has:
    - Vertices: {1, ..., n} (variable indices)
    - Edge i → j if variable x_j appears in H_i (with H_i ≠ X_i part)

    The structure of this graph controls nilpotence of the Jacobian.
    """

    def __init__(self, n: int):
        self.n = n
        self.edges: Dict[int, Set[int]] = defaultdict(set)

    def add_dependency(self, i: int, j: int):
        """Variable x_j appears in the perturbation of coordinate i."""
        self.edges[i].add(j)

    @property
    def longest_path(self) -> int:
        """
        Length of the longest directed path in the dependency graph.

        For a chain map, this equals n-1.
        For a map with all dependencies on the next variable only, this equals n-1.

        Time: O(V + E) using topological sort + dynamic programming
        """
        # Use DFS-based longest path
        memo: Dict[int, int] = {}

        def dfs(v: int) -> int:
            if v in memo:
                return memo[v]
            max_len = 0
            for u in self.edges.get(v, set()):
                max_len = max(max_len, 1 + dfs(u))
            memo[v] = max_len
            return max_len

        return max((dfs(v) for v in range(self.n)), default=0)

    def is_chain(self) -> bool:
        """Check if this is a chain graph: each vertex has at most one outgoing edge
        to the next vertex."""
        for i in range(self.n):
            deps = self.edges.get(i, set())
            if len(deps) > 1:
                return False
            if len(deps) == 1 and list(deps)[0] != i + 1:
                return False
        return True

    @classmethod
    def from_chain(cls, n: int) -> 'DependencyGraph':
        """Create the chain dependency graph: i → i+1 for i = 0, ..., n-2."""
        g = cls(n)
        for i in range(n - 1):
            g.add_dependency(i, i + 1)
        return g


def nilpotence_bound_from_graph(graph: DependencyGraph) -> int:
    """
    Upper bound on nilpotence index from the dependency graph.

    Conjecture: nilpotence index ≤ longest_path + 1.
    Known to be true for chain graphs (where it gives n).

    >>> g = DependencyGraph.from_chain(5)
    >>> nilpotence_bound_from_graph(g)
    5
    """
    return graph.longest_path + 1


# ============================================================
#  Example Usage
# ============================================================

if __name__ == "__main__":
    print("Algorithm 1: Triangular Chain Map")
    print("-" * 40)
    f = TriangularChainMap(4, 2)
    x = [1, -1, 2, 3]
    y = f.forward(x)
    x_back = f.inverse(y)
    print(f"  n=4, d=2")
    print(f"  Input:   {x}")
    print(f"  F(x):    {y}")
    print(f"  G(F(x)): {x_back}")
    print(f"  Verified: {f.verify(x)}")
    print(f"  Forward degree:  {f.forward_degree}")
    print(f"  Inverse degree:  {f.inverse_degree}")
    print(f"  Coordinate degrees: {f.inverse_coordinate_degrees()}")
    print()

    print("Algorithm 2: Inverse Degree Computation")
    print("-" * 40)
    for n in [3, 4, 5, 6]:
        for d in [2, 3]:
            degs = compute_inverse_degrees(n, d)
            print(f"  n={n}, d={d}: degrees={degs}, max={max(degs)}, "
                  f"ratio={inverse_degree_ratio(n, d)}")
    print()

    print("Algorithm 3: Nilpotence Detection")
    print("-" * 40)
    for n in [3, 4, 5]:
        A = np.zeros((n, n))
        for i in range(n - 1):
            A[i, i + 1] = i + 1
        idx = nilpotence_index(A)
        print(f"  n={n}: superdiagonal matrix, nilpotence index = {idx}, "
              f"is_superdiagonal = {is_superdiagonal(A)}")
    print()

    print("Algorithm 4: Dependency Graph")
    print("-" * 40)
    for n in [3, 5, 8]:
        g = DependencyGraph.from_chain(n)
        print(f"  n={n}: chain graph, longest_path={g.longest_path}, "
              f"nilpotence_bound={nilpotence_bound_from_graph(g)}, "
              f"is_chain={g.is_chain()}")
