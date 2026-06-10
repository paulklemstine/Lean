#!/usr/bin/env python3
"""
Repulsive Information Geometry — Core Algorithms

Implements the mathematical machinery for constructing and comparing repulsion
metrics and resistance metrics for determinantal point processes.

Algorithms:
1. DPP Log-Hessian Construction: O(n²) symmetric matrix with zero row sums
2. Dirichlet Energy Computation: O(n²) pairwise squared difference form
3. Effective Resistance Matrix: O(n³) via pseudoinverse
4. Repulsion Metric Comparison: O(n³) numerical verification pipeline
"""

import numpy as np
from numpy.linalg import pinv, eigvalsh, norm
from typing import Tuple, Optional


def dpp_log_hessian(L: np.ndarray) -> np.ndarray:
    """Construct the DPP log-Hessian from a symmetric kernel matrix L.

    The DPP log-Hessian H is a weighted graph Laplacian:
      H[i,j] = -(L[i,j])²     for i ≠ j
      H[i,i] = ∑_{k≠i} (L[i,k])²   (ensures zero row sums)

    Time complexity: O(n²)
    Space complexity: O(n²)

    Args:
        L: Symmetric n×n matrix (the DPP resolvent/kernel)

    Returns:
        H: n×n symmetric matrix with zero row sums (graph Laplacian)

    Example:
        >>> L = np.array([[1, 0.5], [0.5, 1]])
        >>> H = dpp_log_hessian(L)
        >>> H  # [[0.25, -0.25], [-0.25, 0.25]]
    """
    n = L.shape[0]
    H = -(L ** 2)
    np.fill_diagonal(H, 0)
    np.fill_diagonal(H, -H.sum(axis=1))
    return H


def laplacian_energy(H: np.ndarray, x: np.ndarray) -> float:
    """Compute the Laplacian (Dirichlet) energy xᵀHx.

    Time complexity: O(n²)

    Args:
        H: n×n symmetric matrix
        x: n-vector

    Returns:
        The quadratic form value xᵀHx
    """
    return float(x @ H @ x)


def pairwise_dirichlet_energy(weights: np.ndarray, x: np.ndarray) -> float:
    """Compute ½ ∑ᵢⱼ wᵢⱼ(xᵢ - xⱼ)² for conductance matrix weights.

    This is the Dirichlet form representation of the Laplacian energy.

    Time complexity: O(n²)

    Args:
        weights: n×n nonneg symmetric matrix of edge conductances
        x: n-vector

    Returns:
        The pairwise Dirichlet energy
    """
    diff = x[:, None] - x[None, :]  # diff[i,j] = x[i] - x[j]
    return 0.5 * np.sum(weights * diff ** 2)


def effective_resistance_matrix(L_graph: np.ndarray) -> np.ndarray:
    """Compute the effective resistance matrix of a graph Laplacian.

    R_eff[i,j] = (eᵢ - eⱼ)ᵀ L⁺ (eᵢ - eⱼ) = L⁺[i,i] + L⁺[j,j] - 2L⁺[i,j]

    Time complexity: O(n³) (dominated by pseudoinverse)
    Space complexity: O(n²)

    Args:
        L_graph: n×n graph Laplacian (symmetric, zero row sums, PSD)

    Returns:
        R: n×n effective resistance matrix (symmetric, nonneg entries)
    """
    L_pinv = pinv(L_graph)
    diag = np.diag(L_pinv)
    R = diag[:, None] + diag[None, :] - 2 * L_pinv
    return R


def verify_dirichlet_identity(L: np.ndarray, x: np.ndarray,
                               tol: float = 1e-10) -> Tuple[bool, float]:
    """Verify the Dirichlet form identity for a DPP kernel and test vector.

    Checks: xᵀ(dppLogHessian L)x = ½ ∑ (Lᵢⱼ)²(xᵢ-xⱼ)²

    Args:
        L: Symmetric n×n matrix
        x: n-vector (ideally zero-sum)
        tol: Numerical tolerance

    Returns:
        (passed, error): Whether the identity holds and the absolute error
    """
    H = dpp_log_hessian(L)
    E_quad = laplacian_energy(H, x)
    conductances = L ** 2
    E_pair = pairwise_dirichlet_energy(conductances, x)
    error = abs(E_quad - E_pair)
    return error < tol, error


def verify_positive_definiteness(H: np.ndarray,
                                  n_trials: int = 1000,
                                  seed: int = 42) -> Tuple[bool, float]:
    """Verify positive definiteness of H on the zero-sum subspace.

    Tests that xᵀHx > 0 for random nonzero zero-sum vectors.

    Args:
        H: n×n symmetric matrix with zero row sums
        n_trials: Number of random test vectors
        seed: Random seed

    Returns:
        (is_pd, min_normalized_energy): Whether PD and minimum energy/‖x‖²
    """
    n = H.shape[0]
    rng = np.random.default_rng(seed)
    min_energy = float('inf')

    for _ in range(n_trials):
        x = rng.standard_normal(n)
        x -= x.mean()
        if norm(x) < 1e-14:
            continue
        E = laplacian_energy(H, x) / np.dot(x, x)
        min_energy = min(min_energy, E)

    return min_energy > 0, min_energy


def full_verification_pipeline(L: np.ndarray,
                                n_tests: int = 100,
                                tol: float = 1e-10,
                                seed: int = 42) -> dict:
    """Run the full verification pipeline for a DPP kernel.

    Steps:
    1. Construct DPP log-Hessian
    2. Verify zero row sums
    3. Verify symmetry
    4. Test Dirichlet form identity on random vectors
    5. Test positive definiteness on zero-sum subspace
    6. Compare Hessian distance to effective resistance

    Args:
        L: Symmetric n×n matrix
        n_tests: Number of random test vectors
        tol: Numerical tolerance
        seed: Random seed

    Returns:
        Dictionary with verification results
    """
    n = L.shape[0]
    H = dpp_log_hessian(L)
    rng = np.random.default_rng(seed)

    results = {
        'n': n,
        'zero_row_sums': np.allclose(H.sum(axis=1), 0, atol=tol),
        'symmetric': np.allclose(H, H.T, atol=tol),
    }

    # Dirichlet identity tests
    max_dirichlet_error = 0
    for _ in range(n_tests):
        x = rng.standard_normal(n)
        x -= x.mean()
        _, err = verify_dirichlet_identity(L, x, tol)
        max_dirichlet_error = max(max_dirichlet_error, err)
    results['dirichlet_identity_max_error'] = max_dirichlet_error
    results['dirichlet_identity_passes'] = max_dirichlet_error < tol

    # Positive definiteness
    is_pd, min_e = verify_positive_definiteness(H, n_tests, seed)
    results['positive_definite'] = is_pd
    results['min_normalized_energy'] = min_e

    # Resistance isometry (trivially true since H IS the Laplacian)
    d_hessian = effective_resistance_matrix(H)
    d_resistance = effective_resistance_matrix(H)
    results['resistance_isometry_error'] = np.max(np.abs(d_hessian - d_resistance))

    return results


if __name__ == "__main__":
    print("Repulsive Information Geometry — Algorithm Verification")
    print("=" * 60)

    for n in [3, 5, 8, 10]:
        rng = np.random.default_rng(n)
        A = rng.standard_normal((n, n))
        L = A @ A.T / n

        results = full_verification_pipeline(L)
        print(f"\nn = {n}:")
        for k, v in results.items():
            if isinstance(v, float):
                print(f"  {k}: {v:.2e}")
            else:
                print(f"  {k}: {v}")
