#!/usr/bin/env python3
"""
Spectral Algorithms
===================
Implementations of key algorithms from spectral theory:
- Power iteration for dominant eigenvalue
- Rayleigh quotient iteration for fast convergence
- Jacobi eigenvalue algorithm for full symmetric diagonalization
- Spectral graph partitioning (Fiedler vector)
"""

import numpy as np
from numpy.linalg import norm, eigh
from typing import Tuple, Optional


def power_iteration(
    A: np.ndarray,
    max_iter: int = 1000,
    tol: float = 1e-12,
    v0: Optional[np.ndarray] = None
) -> Tuple[float, np.ndarray, list]:
    """
    Power iteration to find the dominant eigenvalue/eigenvector.

    For a symmetric matrix A, converges to the eigenvalue of largest absolute value.
    Convergence rate: |λ₂/λ₁| per iteration.

    Args:
        A: n×n symmetric matrix
        max_iter: maximum iterations
        tol: convergence tolerance
        v0: initial vector (random if None)

    Returns:
        (eigenvalue, eigenvector, convergence_history)
    """
    n = A.shape[0]
    v = v0 if v0 is not None else np.random.randn(n)
    v = v / norm(v)
    history = []

    for k in range(max_iter):
        w = A @ v
        lam = v @ w  # Rayleigh quotient
        history.append(lam)
        v_new = w / norm(w)

        if norm(v_new - v) < tol or norm(v_new + v) < tol:
            return lam, v_new, history
        v = v_new

    return lam, v, history


def rayleigh_quotient_iteration(
    A: np.ndarray,
    max_iter: int = 100,
    tol: float = 1e-14,
    v0: Optional[np.ndarray] = None,
    sigma0: Optional[float] = None
) -> Tuple[float, np.ndarray, list]:
    """
    Rayleigh quotient iteration for cubic convergence to an eigenvalue.

    This algorithm converges cubically (!) for symmetric matrices,
    making it one of the fastest eigenvalue algorithms per iteration.

    The Rayleigh quotient R(v) = ⟪v, Av⟫/⟪v,v⟫ equals the eigenvalue
    at eigenvectors (our Theorem: rayleighQuotient_eigenvector).

    Args:
        A: n×n symmetric matrix
        max_iter: maximum iterations
        tol: convergence tolerance
        v0: initial vector
        sigma0: initial shift (Rayleigh quotient of v0 if None)

    Returns:
        (eigenvalue, eigenvector, convergence_history)
    """
    n = A.shape[0]
    v = v0 if v0 is not None else np.random.randn(n)
    v = v / norm(v)

    sigma = sigma0 if sigma0 is not None else (v @ A @ v)
    history = [sigma]

    I = np.eye(n)
    for k in range(max_iter):
        try:
            w = np.linalg.solve(A - sigma * I, v)
        except np.linalg.LinAlgError:
            # Singular: sigma is an exact eigenvalue
            return sigma, v, history

        v = w / norm(w)
        sigma = v @ A @ v  # Rayleigh quotient
        history.append(sigma)

        # Check convergence
        residual = norm(A @ v - sigma * v)
        if residual < tol:
            break

    return sigma, v, history


def jacobi_eigenvalue(
    A: np.ndarray,
    max_iter: int = 10000,
    tol: float = 1e-12
) -> Tuple[np.ndarray, np.ndarray, int]:
    """
    Classical Jacobi eigenvalue algorithm for symmetric matrices.

    Computes ALL eigenvalues and eigenvectors by successive Givens rotations
    that zero out off-diagonal elements. The matrix converges to diagonal form,
    producing the orthogonal diagonalization A = Q D Qᵀ guaranteed by our
    theorem `exists_orthogonal_diagonalization`.

    Complexity: O(n³) per sweep, typically O(n²) sweeps.

    Args:
        A: n×n symmetric matrix
        max_iter: maximum iterations
        tol: off-diagonal convergence tolerance

    Returns:
        (eigenvalues, Q, num_iterations) where A ≈ Q diag(eigenvalues) Qᵀ
    """
    n = A.shape[0]
    D = A.copy().astype(float)
    Q = np.eye(n)

    def off_diag_norm(M):
        return np.sqrt(np.sum(M**2) - np.sum(np.diag(M)**2))

    for iteration in range(max_iter):
        # Check convergence
        off = off_diag_norm(D)
        if off < tol:
            break

        # Find largest off-diagonal element
        mask = np.ones_like(D, dtype=bool)
        np.fill_diagonal(mask, False)
        abs_D = np.abs(D) * mask
        p, q = np.unravel_index(np.argmax(abs_D), D.shape)

        if abs(D[p, q]) < tol:
            break

        # Compute Jacobi rotation
        if abs(D[p, p] - D[q, q]) < 1e-15:
            theta = np.pi / 4
        else:
            tau = (D[q, q] - D[p, p]) / (2 * D[p, q])
            if tau >= 0:
                t = 1 / (tau + np.sqrt(1 + tau**2))
            else:
                t = -1 / (-tau + np.sqrt(1 + tau**2))
            theta = np.arctan(t)

        c, s = np.cos(theta), np.sin(theta)

        # Apply rotation: D ← GᵀDG
        G = np.eye(n)
        G[p, p] = c
        G[q, q] = c
        G[p, q] = s
        G[q, p] = -s

        D = G.T @ D @ G
        Q = Q @ G

    eigenvalues = np.diag(D)
    return eigenvalues, Q, iteration + 1


def spectral_graph_partition(
    adjacency: np.ndarray
) -> Tuple[np.ndarray, np.ndarray, float]:
    """
    Spectral graph partitioning using the Fiedler vector.

    Uses the spectral theorem: the Laplacian L = D - A is symmetric PSD,
    so it has a real orthonormal eigenbasis. The second-smallest eigenvalue
    (algebraic connectivity) and its eigenvector (Fiedler vector) give an
    optimal graph partition.

    Args:
        adjacency: n×n symmetric adjacency matrix (0/1 entries)

    Returns:
        (partition, fiedler_vector, algebraic_connectivity)
        where partition[i] ∈ {0, 1} assigns each vertex to a cluster
    """
    n = adjacency.shape[0]
    degrees = adjacency.sum(axis=1)
    laplacian = np.diag(degrees) - adjacency

    eigenvalues, eigenvectors = eigh(laplacian)

    # Fiedler vector: eigenvector for second-smallest eigenvalue
    fiedler_idx = 1  # index 0 is the zero eigenvalue (connected graph)
    fiedler_vector = eigenvectors[:, fiedler_idx]
    algebraic_connectivity = eigenvalues[fiedler_idx]

    # Partition by sign of Fiedler vector
    partition = (fiedler_vector >= 0).astype(int)

    return partition, fiedler_vector, algebraic_connectivity


if __name__ == "__main__":
    print("=" * 60)
    print("ALGORITHM 1: Power Iteration")
    print("=" * 60)

    A = np.array([[4, 1, 1], [1, 3, 0], [1, 0, 2]], dtype=float)
    lam, v, hist = power_iteration(A)
    true_vals = eigh(A)[0]
    print(f"Matrix A:\n{A}")
    print(f"Dominant eigenvalue: {lam:.10f}")
    print(f"True eigenvalues: {true_vals}")
    print(f"Convergence in {len(hist)} iterations")

    print("\n" + "=" * 60)
    print("ALGORITHM 2: Rayleigh Quotient Iteration (Cubic Convergence)")
    print("=" * 60)

    lam, v, hist = rayleigh_quotient_iteration(A)
    print(f"Converged eigenvalue: {lam:.15f}")
    print(f"Convergence history: {hist}")
    print(f"Cubic convergence in {len(hist)} iterations")

    print("\n" + "=" * 60)
    print("ALGORITHM 3: Jacobi Eigenvalue Algorithm")
    print("=" * 60)

    B = np.array([
        [5, 2, 1, 0],
        [2, 4, 2, 1],
        [1, 2, 3, 2],
        [0, 1, 2, 2]
    ], dtype=float)

    eigenvalues, Q, iters = jacobi_eigenvalue(B)
    print(f"Matrix B:\n{B}")
    print(f"Eigenvalues: {sorted(eigenvalues)}")
    print(f"True eigenvalues: {sorted(eigh(B)[0])}")
    print(f"QᵀQ ≈ I: {np.allclose(Q.T @ Q, np.eye(4))}")
    print(f"B ≈ QDQᵀ: {np.allclose(B, Q @ np.diag(eigenvalues) @ Q.T)}")
    print(f"Converged in {iters} Jacobi rotations")

    print("\n" + "=" * 60)
    print("ALGORITHM 4: Spectral Graph Partitioning")
    print("=" * 60)

    # Barbell graph: two cliques connected by a bridge
    adj = np.zeros((8, 8))
    # Clique 1: vertices 0-3
    for i in range(4):
        for j in range(i+1, 4):
            adj[i, j] = adj[j, i] = 1
    # Clique 2: vertices 4-7
    for i in range(4, 8):
        for j in range(i+1, 8):
            adj[i, j] = adj[j, i] = 1
    # Bridge: 3-4
    adj[3, 4] = adj[4, 3] = 1

    partition, fiedler, alg_conn = spectral_graph_partition(adj)
    print(f"Barbell graph (8 vertices, 2 cliques + bridge)")
    print(f"Algebraic connectivity: {alg_conn:.6f}")
    print(f"Fiedler vector: {fiedler}")
    print(f"Partition: {partition}")
    print(f"Cluster 0: vertices {list(np.where(partition == 0)[0])}")
    print(f"Cluster 1: vertices {list(np.where(partition == 1)[0])}")
