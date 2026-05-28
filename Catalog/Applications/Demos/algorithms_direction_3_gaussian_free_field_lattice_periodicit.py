#!/usr/bin/env python3
"""
Algorithms for Gaussian Free Field on Finite Graphs

Implements verified computational methods for:
- Constructing weighted Laplacians and reduced Laplacians
- Computing effective resistance matrices via pseudoinverse
- Computing covariance kernels from resistance data
- Partition function prefactor computation
- Subdivision invariance checking

All algorithms include docstrings, type hints, and complexity analysis.
"""

import numpy as np
from typing import List, Tuple, Optional


def weighted_laplacian(
    n: int,
    edges: List[Tuple[int, int, float]],
) -> np.ndarray:
    """Construct the weighted Laplacian matrix for a graph.

    Args:
        n: Number of vertices.
        edges: List of (i, j, weight) triples. Each edge contributes
               -weight to L[i,j] and L[j,i], and +weight to L[i,i] and L[j,j].

    Returns:
        n×n weighted Laplacian matrix (symmetric, row-sum-zero).

    Time complexity: O(n² + |E|) where |E| = len(edges).
    Space complexity: O(n²).

    Example:
        >>> L = weighted_laplacian(3, [(0,1,1.0), (1,2,1.0), (0,2,1.0)])
        >>> np.allclose(L.sum(axis=1), 0)
        True
    """
    L = np.zeros((n, n))
    for i, j, w in edges:
        L[i, i] += w
        L[j, j] += w
        L[i, j] -= w
        L[j, i] -= w
    return L


def cycle_graph_laplacian(n: int, weights: Optional[np.ndarray] = None) -> np.ndarray:
    """Construct the Laplacian for the cycle graph C_n.

    Args:
        n: Number of vertices (≥ 3).
        weights: Optional edge weights [w_0, ..., w_{n-1}] where w_k
                 is the weight of edge (k, (k+1) mod n). Default: unit weights.

    Returns:
        n×n Laplacian matrix.

    Time complexity: O(n).
    Space complexity: O(n²).
    """
    if weights is None:
        weights = np.ones(n)
    edges = [(k, (k + 1) % n, weights[k]) for k in range(n)]
    return weighted_laplacian(n, edges)


def path_graph_laplacian(n: int, weights: Optional[np.ndarray] = None) -> np.ndarray:
    """Construct the Laplacian for the path graph P_n.

    Args:
        n: Number of vertices (≥ 2).
        weights: Optional edge weights [w_0, ..., w_{n-2}].

    Returns:
        n×n Laplacian matrix.
    """
    if weights is None:
        weights = np.ones(n - 1)
    edges = [(k, k + 1, weights[k]) for k in range(n - 1)]
    return weighted_laplacian(n, edges)


def complete_graph_laplacian(n: int) -> np.ndarray:
    """Construct the Laplacian for the complete graph K_n with unit weights.

    Time complexity: O(n²).
    """
    edges = [(i, j, 1.0) for i in range(n) for j in range(i + 1, n)]
    return weighted_laplacian(n, edges)


def reduced_laplacian(L: np.ndarray, pin: int = 0) -> np.ndarray:
    """Compute the reduced Laplacian by deleting row and column `pin`.

    Args:
        L: n×n Laplacian matrix.
        pin: Index of vertex to pin (delete). Default: 0.

    Returns:
        (n-1)×(n-1) reduced Laplacian.

    Time complexity: O(n²).
    """
    idx = [i for i in range(L.shape[0]) if i != pin]
    return L[np.ix_(idx, idx)]


def effective_resistance_matrix(L: np.ndarray) -> np.ndarray:
    """Compute effective resistance matrix from Laplacian pseudoinverse.

    R(i,j) = L⁺(i,i) + L⁺(j,j) - 2·L⁺(i,j)

    This is the key formula connecting electrical networks to GFF covariance:
    the effective resistance between vertices i and j equals the variance
    of the potential difference φ_i - φ_j in the Gaussian free field.

    Args:
        L: n×n Laplacian matrix (symmetric, row-sum-zero, PSD).

    Returns:
        n×n effective resistance matrix (symmetric, nonneg, zero diagonal).

    Time complexity: O(n³) for pseudoinverse computation.
    Space complexity: O(n²).
    """
    Lp = np.linalg.pinv(L)
    n = L.shape[0]
    diag = np.diag(Lp)
    # R[i,j] = diag[i] + diag[j] - 2*Lp[i,j]
    R = diag[:, None] + diag[None, :] - 2 * Lp
    return R


def covariance_kernel(
    R: np.ndarray,
    base: int = 0,
) -> np.ndarray:
    """Compute the covariance kernel from effective resistance.

    K(i,j) = (R(i,base) + R(j,base) - R(i,j)) / 2

    This is the pinned covariance of the GFF with φ_{base} = 0.

    Args:
        R: n×n effective resistance matrix.
        base: Index of pinned vertex.

    Returns:
        n×n covariance matrix (symmetric, PSD).

    Time complexity: O(n²).
    """
    n = R.shape[0]
    Rb = R[:, base]
    K = (Rb[:, None] + Rb[None, :] - R) / 2
    return K


def partition_prefactor(n_reduced: int, det_reduced: float) -> float:
    """Compute the GFF partition function prefactor.

    Z = (2π)^(n_reduced / 2) / √(det L_red)

    Args:
        n_reduced: Dimension of the reduced Laplacian (= n_vertices - 1).
        det_reduced: Determinant of the reduced Laplacian.

    Returns:
        Partition function prefactor (positive real).

    Raises:
        ValueError: If det_reduced ≤ 0.
    """
    if det_reduced <= 0:
        raise ValueError(f"Reduced Laplacian determinant must be positive, got {det_reduced}")
    return (2 * np.pi) ** (n_reduced / 2) / np.sqrt(det_reduced)


def verify_gauge_invariance(
    L: np.ndarray,
    x: np.ndarray,
    constants: List[float],
    tol: float = 1e-10,
) -> bool:
    """Verify gauge invariance E(x + c·1) = E(x) for given constants.

    Args:
        L: n×n Laplacian matrix.
        x: n-vector of potentials.
        constants: List of constants to test.
        tol: Tolerance for equality.

    Returns:
        True if gauge invariance holds within tolerance for all constants.
    """
    E_x = x @ L @ x
    for c in constants:
        xc = x + c
        E_xc = xc @ L @ xc
        if abs(E_x - E_xc) > tol:
            return False
    return True


def check_subdivision_invariance(
    L_orig: np.ndarray,
    L_sub: np.ndarray,
    original_vertices: List[int],
    tol: float = 1e-10,
) -> Tuple[bool, float]:
    """Check subdivision invariance of effective resistance on marked vertices.

    Args:
        L_orig: Original Laplacian (n×n).
        L_sub: Subdivided Laplacian (m×m, m > n).
        original_vertices: Indices in subdivided graph corresponding to original vertices.
        tol: Tolerance.

    Returns:
        (is_invariant, max_error) tuple.
    """
    R_orig = effective_resistance_matrix(L_orig)
    R_sub = effective_resistance_matrix(L_sub)

    n = len(original_vertices)
    max_err = 0.0
    for a in range(n):
        for b in range(a + 1, n):
            i, j = original_vertices[a], original_vertices[b]
            err = abs(R_sub[i, j] - R_orig[a, b])
            max_err = max(max_err, err)

    return max_err < tol, max_err


def cycle_effective_resistance(n: int, i: int, j: int) -> float:
    """Exact effective resistance formula for unit cycle C_n.

    R(i,j) = d(i,j) · (n - d(i,j)) / n

    where d(i,j) is the cyclic distance.

    Time complexity: O(1).
    """
    d = min(abs(i - j), n - abs(i - j))
    return d * (n - d) / n


def cycle_reduced_det(n: int) -> int:
    """Exact reduced Laplacian determinant for unit cycle C_n.

    det(L_red) = n (by the Matrix-Tree Theorem: number of spanning trees).

    Time complexity: O(1).
    """
    return n


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("=== Algorithm Examples ===\n")

    # Cycle graph
    n = 6
    L = cycle_graph_laplacian(n)
    print(f"Cycle C_{n} Laplacian:")
    print(L)
    print(f"\nRow sums: {L.sum(axis=1)}")
    print(f"Symmetric: {np.allclose(L, L.T)}")

    Lr = reduced_laplacian(L)
    det = np.linalg.det(Lr)
    print(f"\nReduced Laplacian determinant: {det:.4f} (expected {n})")

    R = effective_resistance_matrix(L)
    print(f"\nEffective resistance matrix:")
    print(np.round(R, 4))

    K = covariance_kernel(R)
    print(f"\nCovariance kernel (base=0):")
    print(np.round(K, 4))

    Z = partition_prefactor(n - 1, det)
    print(f"\nPartition prefactor: {Z:.6f}")

    # Gauge invariance
    x = np.random.randn(n)
    ok = verify_gauge_invariance(L, x, [0, 1, -5, 100])
    print(f"\nGauge invariance verified: {ok}")

    # Complete graph
    K4 = complete_graph_laplacian(4)
    print(f"\nComplete graph K_4 Laplacian:")
    print(K4)
    det_K4 = np.linalg.det(reduced_laplacian(K4))
    print(f"det(L_red) = {det_K4:.1f} (expected 16 = 4^2, Cayley's formula)")
