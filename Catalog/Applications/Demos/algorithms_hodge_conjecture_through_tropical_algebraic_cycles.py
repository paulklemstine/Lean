#!/usr/bin/env python3
"""
Tropical Hodge Correspondence — Algorithms

Implements the core algorithms for:
1. Constructing balanced tropical subvarieties
2. Computing the cycle class map
3. Testing the tropical Hodge condition
4. Finding representatives for Hodge classes
5. Computing the tropical Laplacian
"""

import numpy as np
from typing import Dict, List, Tuple, Optional, Set
from dataclasses import dataclass, field


@dataclass
class CellComplex:
    """A finite polyhedral complex with labeled cells.

    Attributes:
        n_cells: Total number of cells.
        dims: Dimension of each cell.
        ambient_dim: Ambient dimension of the complex.
        adjacency: Adjacency matrix (n_cells x n_cells boolean).

    Time complexity of construction: O(n^2) where n = n_cells.
    Space complexity: O(n^2) for adjacency matrix.
    """
    n_cells: int
    dims: np.ndarray        # shape (n_cells,), dtype int
    ambient_dim: int
    adjacency: np.ndarray   # shape (n_cells, n_cells), dtype bool

    def cells_of_codim(self, p: int) -> np.ndarray:
        """Return indices of cells with codimension p.

        Time: O(n)
        """
        return np.where(self.dims + p == self.ambient_dim)[0]

    def neighbors(self, cell: int) -> np.ndarray:
        """Return indices of cells adjacent to `cell`.

        Time: O(n)
        """
        return np.where(self.adjacency[cell])[0]


def check_type_pp(X: CellComplex, p: int, alpha: np.ndarray) -> bool:
    """Check if alpha satisfies the type (p,p) condition.

    Algorithm:
        For each cell c, check that alpha[c] = 0 unless dim(c) + p = top_dim.

    Time: O(n)
    Space: O(1)

    Args:
        X: The cell complex.
        p: Codimension parameter.
        alpha: Integer cochain (length n_cells).

    Returns:
        True if alpha is supported on codimension-p cells.
    """
    for c in range(X.n_cells):
        if X.dims[c] + p != X.ambient_dim:
            if alpha[c] != 0:
                return False
    return True


def check_balanced(X: CellComplex, p: int, w: np.ndarray) -> bool:
    """Check the balancing condition for weight function w.

    Algorithm:
        For each cell sigma of codimension p-1 (i.e., dim(sigma) + p = top_dim + 1),
        compute the sum of w over neighbors of sigma and check it equals zero.

    Time: O(n^2) in the worst case (each cell checks its neighbors).
    Space: O(1)

    Args:
        X: The cell complex.
        p: Codimension parameter.
        w: Integer weight function (length n_cells).

    Returns:
        True if w is balanced.
    """
    for sigma in range(X.n_cells):
        if X.dims[sigma] + p == X.ambient_dim + 1:
            nbrs = X.neighbors(sigma)
            if len(nbrs) > 0 and np.sum(w[nbrs]) != 0:
                return False
    return True


def is_hodge_class(X: CellComplex, p: int, alpha: np.ndarray) -> bool:
    """Check if alpha is a tropical Hodge class.

    Algorithm:
        1. Check type (p,p): O(n)
        2. Check balancing: O(n^2)
        Total: O(n^2)

    Args:
        X: The cell complex.
        p: Codimension parameter.
        alpha: Integer cochain.

    Returns:
        True if alpha is a tropical Hodge class.
    """
    return check_type_pp(X, p, alpha) and check_balanced(X, p, alpha)


def find_representative(X: CellComplex, p: int,
                         alpha: np.ndarray) -> Optional[np.ndarray]:
    """Find a tropical subvariety representing a Hodge class.

    Algorithm:
        By the Tropical Hodge Correspondence theorem, every Hodge class
        is the cycle class of a unique balanced codimension-p subvariety.
        The representative is simply the cochain itself (as a weight function).

    Time: O(n^2) — dominated by the Hodge class verification.
    Space: O(n)

    Args:
        X: The cell complex.
        p: Codimension parameter.
        alpha: Integer cochain.

    Returns:
        The weight function of the representing subvariety, or None if
        alpha is not a Hodge class.
    """
    if not is_hodge_class(X, p, alpha):
        return None
    return alpha.copy()


def tropical_coboundary(X: CellComplex, f: np.ndarray) -> np.ndarray:
    """Compute the tropical coboundary of a cochain.

    Algorithm:
        For each cell sigma, sum f over neighbors of sigma.
        Equivalent to: delta(f) = A @ f where A is the adjacency matrix.

    Time: O(n^2) (matrix-vector multiply)
    Space: O(n)

    Args:
        X: The cell complex.
        f: Integer cochain.

    Returns:
        The coboundary cochain.
    """
    return X.adjacency.astype(int) @ f


def tropical_laplacian(X: CellComplex, f: np.ndarray) -> np.ndarray:
    """Compute the tropical Laplacian of a cochain.

    Algorithm:
        Apply the coboundary operator twice: L(f) = delta(delta(f)).
        This is equivalent to A^2 @ f where A is the adjacency matrix.

    Time: O(n^2)
    Space: O(n)
    """
    return tropical_coboundary(X, tropical_coboundary(X, f))


def is_harmonic(X: CellComplex, f: np.ndarray) -> bool:
    """Check if a cochain is harmonic (Laplacian vanishes).

    Time: O(n^2)
    """
    return np.all(tropical_laplacian(X, f) == 0)


def enumerate_hodge_classes(X: CellComplex, p: int,
                              bound: int = 5) -> List[np.ndarray]:
    """Enumerate all Hodge classes with weights bounded by `bound`.

    Algorithm (brute force):
        Iterate over all integer weight vectors on codimension-p cells,
        with entries in [-bound, bound]. Check Hodge condition for each.

    Time: O((2*bound+1)^k * n^2) where k = number of codimension-p cells.
    Space: O(k) per candidate.

    This is exponential in k but practical for small complexes.
    """
    codim_cells = X.cells_of_codim(p)
    k = len(codim_cells)
    results = []

    # Generate all weight vectors
    def _enumerate(idx, weights):
        if idx == k:
            alpha = np.zeros(X.n_cells, dtype=int)
            for i, c in enumerate(codim_cells):
                alpha[c] = weights[i]
            if is_hodge_class(X, p, alpha):
                results.append(alpha.copy())
            return
        for w in range(-bound, bound + 1):
            weights[idx] = w
            _enumerate(idx + 1, weights)

    _enumerate(0, [0] * k)
    return results


def hodge_group_rank(X: CellComplex, p: int) -> int:
    """Compute the rank of the Hodge subgroup.

    Algorithm:
        The Hodge subgroup consists of integer cochains that are:
        1. Supported on codimension-p cells
        2. Balanced (linear equations over ℤ)

        This is the kernel of a linear map. We form the constraint matrix
        and compute its null space dimension.

    Time: O(n^3) (SVD or row reduction)
    Space: O(n^2)
    """
    codim_cells = X.cells_of_codim(p)
    k = len(codim_cells)

    if k == 0:
        return 0

    # Build the constraint matrix: one row per balancing equation
    balance_cells = [sigma for sigma in range(X.n_cells)
                     if X.dims[sigma] + p == X.ambient_dim + 1]

    if len(balance_cells) == 0:
        return k  # No constraints, full rank

    A = np.zeros((len(balance_cells), k), dtype=float)
    for i, sigma in enumerate(balance_cells):
        nbrs = X.neighbors(sigma)
        for j, c in enumerate(codim_cells):
            if c in nbrs:
                A[i, j] = 1.0

    # Rank of A gives number of independent constraints
    rank_A = np.linalg.matrix_rank(A)
    return k - rank_A


# ============================================================
# Pseudocode for main algorithms
# ============================================================

CYCLE_CLASS_PSEUDOCODE = """
Algorithm: CycleClassMap(Z)
  Input: Tropical subvariety Z = (weight, codim_support, balanced)
  Output: Cohomology class α ∈ H^{2p}(X, ℤ)

  1. Set α.repr := Z.weight
  2. Return α

  Time: O(n)    — copy weight function
  Space: O(n)   — store the cochain

  Correctness: By definition, cycleClass(Z) has the same values as Z.weight.
  The Hodge condition is guaranteed by the subvariety axioms.
"""

HODGE_CHECK_PSEUDOCODE = """
Algorithm: IsHodgeClass(X, p, α)
  Input: Complex X, codimension p, cochain α
  Output: Boolean

  1. For each cell c in X:
       If dim(c) + p ≠ topDim(X) and α(c) ≠ 0:
         Return False                          — fails type (p,p)

  2. For each cell σ in X with dim(σ) + p = topDim(X) + 1:
       s ← Σ_{τ adj σ} α(τ)
       If s ≠ 0:
         Return False                          — fails balancing

  3. Return True

  Time: O(n²)   — step 2 iterates over cells and their neighbors
  Space: O(1)
"""

REPRESENTATIVE_PSEUDOCODE = """
Algorithm: FindRepresentative(X, p, α)
  Input: Complex X, codimension p, Hodge class α
  Output: Tropical subvariety Z with cycleClass(Z) = α

  1. Verify IsHodgeClass(X, p, α)
     If False: Return None

  2. Construct Z:
       Z.weight := α.repr
       Z.codim_support follows from type (p,p) condition
       Z.balanced follows from balancing condition of α

  3. Return Z

  Time: O(n²)   — dominated by Hodge class verification
  Space: O(n)

  Correctness: The Tropical Hodge Correspondence theorem guarantees
  that every Hodge class has a unique representative subvariety,
  and it is precisely the weight function of the class itself.
"""


if __name__ == "__main__":
    print("Tropical Hodge Correspondence — Algorithm Demonstrations")
    print("=" * 60)

    # Build a square complex
    n = 9
    dims = np.array([2, 1, 1, 1, 1, 0, 0, 0, 0])
    adj = np.zeros((n, n), dtype=bool)
    edges = [(0,1),(0,2),(0,3),(0,4),
             (1,5),(1,6),(2,6),(2,7),(3,7),(3,8),(4,8),(4,5)]
    for i, j in edges:
        adj[i, j] = adj[j, i] = True

    X = CellComplex(n_cells=n, dims=dims, ambient_dim=2, adjacency=adj)

    print("\nSquare complex: 1 face, 4 edges, 4 vertices")
    print(f"Codimension-1 cells: {X.cells_of_codim(1)}")
    print(f"Codimension-2 cells: {X.cells_of_codim(2)}")

    # Compute Hodge group rank
    rank_1 = hodge_group_rank(X, 1)
    rank_2 = hodge_group_rank(X, 2)
    print(f"\nHodge group rank (codim 1): {rank_1}")
    print(f"Hodge group rank (codim 2): {rank_2}")

    # Enumerate Hodge classes for codimension 1
    hodge_classes = enumerate_hodge_classes(X, 1, bound=2)
    print(f"\nHodge classes (codim 1, |weights| ≤ 2): {len(hodge_classes)}")
    for hc in hodge_classes[:10]:
        nonzero = {i: int(hc[i]) for i in range(n) if hc[i] != 0}
        print(f"  {nonzero}")

    # Test Laplacian
    f = np.array([0, 1, -1, 1, -1, 0, 0, 0, 0])
    lap = tropical_laplacian(X, f)
    print(f"\nLaplacian of {f}: {lap}")
    print(f"Is harmonic: {is_harmonic(X, f)}")

    print("\n" + "=" * 60)
    print("Algorithm pseudocode:")
    print(CYCLE_CLASS_PSEUDOCODE)
    print(HODGE_CHECK_PSEUDOCODE)
    print(REPRESENTATIVE_PSEUDOCODE)
