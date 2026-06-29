#!/usr/bin/env python3
"""
Algorithms for Marginal Kernel Contraction Analysis.

Implements efficient computation of DPP marginal kernels, contraction
verification, and spectral analysis of the K - K² operator.
"""

import numpy as np
from numpy.linalg import inv, eigvalsh, eigh
from typing import Tuple, List, Optional


def marginal_kernel(L: np.ndarray, beta: float = 1.0) -> np.ndarray:
    """
    Compute the DPP marginal kernel K = βL(I + βL)⁻¹.

    For a symmetric PSD matrix L and β ≥ 0, the marginal kernel gives
    the inclusion probabilities for a determinantal point process.

    Args:
        L: Symmetric PSD matrix (n × n)
        beta: Inverse temperature parameter (≥ 0)

    Returns:
        K: The marginal kernel matrix (n × n)

    Complexity: O(n³) for matrix inversion
    """
    n = L.shape[0]
    I = np.eye(n)
    return beta * L @ inv(I + beta * L)


def marginal_kernel_spectral(L: np.ndarray, beta: float = 1.0) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """
    Compute the marginal kernel via spectral decomposition.

    Uses the eigendecomposition L = QΛQᵀ to compute:
        K = Q · diag(βλ_i / (1 + βλ_i)) · Qᵀ

    This is numerically more stable for ill-conditioned matrices.

    Args:
        L: Symmetric PSD matrix (n × n)
        beta: Inverse temperature parameter (≥ 0)

    Returns:
        K: The marginal kernel matrix
        eigvals_K: Eigenvalues of K (each in [0,1])
        Q: Eigenvector matrix of L

    Complexity: O(n³) for eigendecomposition
    """
    eigenvalues, Q = eigh(L)
    # K has eigenvalues βλ/(1+βλ)
    k_eigenvalues = beta * eigenvalues / (1 + beta * eigenvalues)
    K = Q @ np.diag(k_eigenvalues) @ Q.T
    return K, k_eigenvalues, Q


def contraction_operator(L: np.ndarray, beta: float = 1.0) -> np.ndarray:
    """
    Compute the contraction operator K - K².

    Uses the congruence form: K - K² = Pᵀ(βL)P where P = (I + βL)⁻¹.
    This representation makes the PSD property manifest.

    Args:
        L: Symmetric PSD matrix (n × n)
        beta: Inverse temperature parameter (≥ 0)

    Returns:
        C: The contraction operator K - K² (n × n, PSD)

    Complexity: O(n³)
    """
    n = L.shape[0]
    I = np.eye(n)
    P = inv(I + beta * L)
    return P.T @ (beta * L) @ P


def contraction_spectral(L: np.ndarray, beta: float = 1.0) -> Tuple[np.ndarray, np.ndarray]:
    """
    Compute eigenvalues of K - K² via spectral decomposition.

    The eigenvalues of K - K² are βλ_i/(1+βλ_i)² where λ_i are eigenvalues of L.
    This function is f(x) = x(1-x) applied to eigenvalues of K.

    Args:
        L: Symmetric PSD matrix (n × n)
        beta: Inverse temperature parameter (≥ 0)

    Returns:
        eigvals: Eigenvalues of K - K²
        eigvals_K: Eigenvalues of K

    Complexity: O(n³) for eigendecomposition, O(n) for eigenvalue computation
    """
    eigenvalues_L = eigvalsh(L)
    eigenvalues_K = beta * eigenvalues_L / (1 + beta * eigenvalues_L)
    # f(x) = x(1-x) = x - x² applied to each eigenvalue
    eigenvalues_C = eigenvalues_K * (1 - eigenvalues_K)
    return eigenvalues_C, eigenvalues_K


def correlation_capacity(K: np.ndarray) -> np.ndarray:
    """
    Compute the correlation capacity for each site.

    For site i, the correlation capacity is:
        C_i = K_ii(1-K_ii) - ∑_{j≠i} K_ij²

    By the contraction theorem, C_i ≥ 0.

    Args:
        K: Marginal kernel matrix (n × n)

    Returns:
        capacities: Array of correlation capacities (n,), all ≥ 0

    Complexity: O(n²)
    """
    n = K.shape[0]
    capacities = np.zeros(n)
    for i in range(n):
        off_diag_sum = sum(K[i, j]**2 for j in range(n) if j != i)
        capacities[i] = K[i, i] * (1 - K[i, i]) - off_diag_sum
    return capacities


def dpp_covariance_matrix(K: np.ndarray) -> np.ndarray:
    """
    Compute the DPP covariance matrix.

    Cov(n_i, n_j) = K_ij(δ_ij - K_ij)
    Diagonal: K_ii(1-K_ii), Off-diagonal: -K_ij²

    Args:
        K: Marginal kernel matrix (n × n, symmetric)

    Returns:
        Sigma: Covariance matrix (n × n)

    Complexity: O(n²)
    """
    n = K.shape[0]
    Sigma = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i == j:
                Sigma[i, j] = K[i, i] * (1 - K[i, i])
            else:
                Sigma[i, j] = -K[i, j]**2
    return Sigma


def effective_resistance(K: np.ndarray, i: int, j: int) -> float:
    """
    Compute the effective resistance between sites i and j
    in the DPP conductance network with weights K_ij².

    Args:
        K: Marginal kernel matrix
        i, j: Site indices

    Returns:
        R_ij: Effective resistance

    Complexity: O(n²)
    """
    n = K.shape[0]
    delta = np.zeros(n)
    delta[i] = 1
    delta[j] = -1

    # Build Laplacian
    Lap = np.zeros((n, n))
    for a in range(n):
        for b in range(n):
            if a == b:
                Lap[a, a] = sum(K[a, k]**2 for k in range(n) if k != a)
            else:
                Lap[a, b] = -K[a, b]**2

    return delta @ Lap @ delta


def verify_spectral_contraction_conjecture(
    n_trials: int = 10000,
    max_size: int = 10,
    seed: int = 42
) -> dict:
    """
    Computationally verify the spectral contraction conjecture:
    ‖K - K²‖_op ≤ 1/4 when ‖L‖_op ≤ 1.

    Args:
        n_trials: Number of random trials
        max_size: Maximum matrix size
        seed: Random seed

    Returns:
        Dictionary with verification results
    """
    rng = np.random.RandomState(seed)
    max_norm = 0.0
    failures = 0

    for _ in range(n_trials):
        n = rng.randint(2, max_size + 1)
        A = rng.randn(n, n)
        L = A @ A.T
        # Normalize so ‖L‖ ≤ 1
        L = L / (eigvalsh(L).max() + 1e-10)

        eigvals_C, _ = contraction_spectral(L, beta=1.0)
        op_norm = np.max(np.abs(eigvals_C))
        max_norm = max(max_norm, op_norm)
        if op_norm > 0.25 + 1e-10:
            failures += 1

    return {
        'n_trials': n_trials,
        'max_size': max_size,
        'max_operator_norm': max_norm,
        'bound': 0.25,
        'failures': failures,
        'conjecture_holds': failures == 0,
    }


if __name__ == "__main__":
    print("Testing algorithms...")

    # Test marginal kernel computation
    L = np.array([[2.0, 1.0], [1.0, 3.0]])
    K = marginal_kernel(L, beta=1.0)
    print(f"L = \n{L}")
    print(f"K = βL(I+βL)⁻¹ = \n{K}")

    # Test contraction
    C = contraction_operator(L, beta=1.0)
    print(f"K - K² = \n{C}")
    print(f"Eigenvalues of K - K²: {eigvalsh(C)}")

    # Test correlation capacity
    caps = correlation_capacity(K)
    print(f"Correlation capacities: {caps}")
    print(f"All nonneg: {all(c >= -1e-10 for c in caps)}")

    # Test conjecture
    result = verify_spectral_contraction_conjecture(n_trials=1000)
    print(f"\nConjecture verification: {result}")
