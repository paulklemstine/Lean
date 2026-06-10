#!/usr/bin/env python3
"""
Algorithms for DPP Fluctuation-Dissipation Theory
===================================================
Implements the core computational methods for DPP response theory,
including susceptibility computation, conductance network construction,
effective resistance calculation, and Green kernel comparison.

All algorithms operate on finite DPPs with symmetric PSD kernels.
"""

import numpy as np
from numpy.linalg import det, inv, eigvalsh, pinv, norm
from typing import Tuple, Optional


def compute_marginal_kernel(beta: float, L: np.ndarray) -> np.ndarray:
    """
    Compute the DPP marginal kernel K = βL(I + βL)⁻¹.

    Parameters
    ----------
    beta : float
        Inverse temperature parameter.
    L : np.ndarray
        Symmetric PSD kernel matrix (n × n).

    Returns
    -------
    K : np.ndarray
        Marginal kernel matrix (n × n).

    Complexity
    ----------
    Time: O(n³) for matrix inversion.
    Space: O(n²).

    Examples
    --------
    >>> L = np.array([[2, 1], [1, 2]])
    >>> K = compute_marginal_kernel(1.0, L)
    >>> np.allclose(K, L @ inv(np.eye(2) + L))
    True
    """
    n = L.shape[0]
    M = beta * L
    return M @ inv(np.eye(n) + M)


def compute_susceptibility_matrix(beta: float, L: np.ndarray) -> np.ndarray:
    """
    Compute the DPP susceptibility (covariance) matrix.

    χ_ii = K_ii(1 - K_ii)  (variance)
    χ_ij = -K_ij²           (covariance, i ≠ j)

    Parameters
    ----------
    beta : float
        Inverse temperature.
    L : np.ndarray
        Symmetric PSD kernel.

    Returns
    -------
    chi : np.ndarray
        Susceptibility matrix.

    Complexity
    ----------
    Time: O(n³) (dominated by marginal kernel computation).
    Space: O(n²).
    """
    K = compute_marginal_kernel(beta, L)
    n = K.shape[0]
    chi = -(K ** 2)
    for i in range(n):
        chi[i, i] = K[i, i] * (1 - K[i, i])
    return chi


def compute_conductance_network(beta: float, L: np.ndarray) -> np.ndarray:
    """
    Extract the conductance network from the DPP marginal kernel.

    c_ij = K_ij² for all i, j.

    Parameters
    ----------
    beta : float
        Inverse temperature.
    L : np.ndarray
        Symmetric PSD kernel.

    Returns
    -------
    c : np.ndarray
        Conductance matrix (symmetric, nonneg).
    """
    K = compute_marginal_kernel(beta, L)
    return K ** 2


def compute_graph_laplacian(c: np.ndarray) -> np.ndarray:
    """
    Compute the weighted graph Laplacian from a conductance matrix.

    Lap_ii = ∑_{j≠i} c_ij
    Lap_ij = -c_ij  (i ≠ j)

    Parameters
    ----------
    c : np.ndarray
        Conductance matrix (n × n, symmetric, nonneg).

    Returns
    -------
    Lap : np.ndarray
        Graph Laplacian.
    """
    n = c.shape[0]
    Lap = -c.copy()
    for i in range(n):
        Lap[i, i] = 0
        Lap[i, i] = -Lap[i, :].sum()
    return Lap


def compute_effective_resistance(c: np.ndarray, i: int, j: int) -> float:
    """
    Compute effective resistance between nodes i and j.

    R_eff(i,j) = (e_i - e_j)ᵀ L (e_i - e_j)

    Parameters
    ----------
    c : np.ndarray
        Conductance matrix.
    i, j : int
        Node indices.

    Returns
    -------
    R : float
        Effective resistance.
    """
    Lap = compute_graph_laplacian(c)
    n = c.shape[0]
    delta = np.zeros(n)
    delta[i] = 1
    delta[j] = -1
    return delta @ Lap @ delta


def compute_effective_resistance_matrix(c: np.ndarray) -> np.ndarray:
    """
    Compute the full effective resistance matrix using the Green kernel.

    R_eff(i,j) = G_ii + G_jj - 2G_ij

    where G = Lap⁺ (pseudoinverse of Laplacian).

    Parameters
    ----------
    c : np.ndarray
        Conductance matrix.

    Returns
    -------
    R : np.ndarray
        Effective resistance matrix.

    Complexity
    ----------
    Time: O(n³) for pseudoinverse.
    Space: O(n²).
    """
    Lap = compute_graph_laplacian(c)
    G = pinv(Lap)
    n = c.shape[0]
    R = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            R[i, j] = G[i, i] + G[j, j] - 2 * G[i, j]
    return R


def compute_susceptibility_distance(beta: float, L: np.ndarray) -> np.ndarray:
    """
    Compute the susceptibility distance matrix.

    d_χ(i,j) = χ_ii + χ_jj - 2χ_ij

    Parameters
    ----------
    beta : float
        Inverse temperature.
    L : np.ndarray
        Symmetric PSD kernel.

    Returns
    -------
    d : np.ndarray
        Distance matrix.
    """
    chi = compute_susceptibility_matrix(beta, L)
    n = chi.shape[0]
    d = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            d[i, j] = chi[i, i] + chi[j, j] - 2 * chi[i, j]
    return d


def verify_negative_type(d: np.ndarray, num_tests: int = 1000,
                          seed: int = 42) -> Tuple[bool, float]:
    """
    Numerically verify that a distance matrix is of negative type.

    Tests whether ∑ a_i a_j d(i,j) ≤ 0 for random zero-sum vectors a.

    Parameters
    ----------
    d : np.ndarray
        Distance matrix.
    num_tests : int
        Number of random tests.
    seed : int
        Random seed.

    Returns
    -------
    is_neg_type : bool
        Whether all tests passed.
    max_violation : float
        Maximum value of the quadratic form.
    """
    rng = np.random.RandomState(seed)
    n = d.shape[0]
    max_val = -np.inf
    for _ in range(num_tests):
        a = rng.randn(n)
        a -= a.mean()
        val = a @ d @ a  # ∑ a_i a_j d_ij (since d is a matrix)
        max_val = max(max_val, val)
    return max_val <= 1e-10, max_val


def compute_dpp_response_system(beta: float, L: np.ndarray) -> dict:
    """
    Compute the complete DPP response system.

    Returns all key objects: marginal kernel, covariance, conductances,
    Laplacian, effective resistance, susceptibility distance, and
    numerical Hessian comparison.

    Parameters
    ----------
    beta : float
        Inverse temperature.
    L : np.ndarray
        Symmetric PSD kernel.

    Returns
    -------
    system : dict
        Dictionary containing all response system components.

    Complexity
    ----------
    Time: O(n³).
    Space: O(n²).
    """
    n = L.shape[0]
    K = compute_marginal_kernel(beta, L)
    chi = compute_susceptibility_matrix(beta, L)
    c = compute_conductance_network(beta, L)
    Lap = compute_graph_laplacian(c)
    R_eff = compute_effective_resistance_matrix(c)
    d_chi = compute_susceptibility_distance(beta, L)
    G = pinv(Lap)

    # Verify properties
    neg_type_pass, neg_type_max = verify_negative_type(d_chi)
    contraction_ok = all(
        sum(K[i, k]**2 for k in range(n) if k != i) <= K[i, i] * (1 - K[i, i]) + 1e-10
        for i in range(n)
    )
    resistance_ok = all(
        R_eff[i, j] <= d_chi[i, j] + 1e-10
        for i in range(n) for j in range(n)
    )

    return {
        'n': n,
        'beta': beta,
        'L': L,
        'K': K,
        'chi': chi,
        'conductance': c,
        'laplacian': Lap,
        'effective_resistance': R_eff,
        'susceptibility_distance': d_chi,
        'green_kernel': G,
        'eigenvalues_K': eigvalsh(K),
        'eigenvalues_L': eigvalsh(L),
        'negative_type': neg_type_pass,
        'contraction_verified': contraction_ok,
        'resistance_comparison': resistance_ok,
    }


def spectral_decomposition_analysis(beta: float, L: np.ndarray) -> dict:
    """
    Analyze the spectral structure of the DPP response system.

    For symmetric L with eigenvalues λ_k, the marginal kernel K has
    eigenvalues βλ_k/(1 + βλ_k), and the covariance eigenvalues
    follow from the spectral theorem.

    Parameters
    ----------
    beta : float
        Inverse temperature.
    L : np.ndarray
        Symmetric PSD kernel.

    Returns
    -------
    analysis : dict
        Spectral analysis results.
    """
    lam_L = eigvalsh(L)
    lam_K = beta * lam_L / (1 + beta * lam_L)

    # Predicted covariance eigenvalues (for diagonal case)
    lam_var = lam_K * (1 - lam_K)

    # Actual eigenvalues
    K = compute_marginal_kernel(beta, L)
    chi = compute_susceptibility_matrix(beta, L)
    lam_chi = eigvalsh(chi)

    return {
        'eigenvalues_L': lam_L,
        'eigenvalues_K': lam_K,
        'predicted_variance_eigenvalues': lam_var,
        'actual_chi_eigenvalues': lam_chi,
        'trace_K': np.sum(lam_K),
        'trace_chi': np.sum(lam_chi),
        'spectral_gap_L': lam_L[-1] - lam_L[-2] if len(lam_L) > 1 else 0,
    }


if __name__ == "__main__":
    # Example usage
    np.random.seed(42)
    n = 4
    L = np.random.randn(n, n)
    L = L @ L.T  # Make PSD
    beta = 1.0

    print("Computing DPP Response System...")
    system = compute_dpp_response_system(beta, L)

    print(f"\nMarginal kernel K:\n{system['K']}")
    print(f"\nCovariance matrix χ:\n{system['chi']}")
    print(f"\nConductance matrix c:\n{system['conductance']}")
    print(f"\nEffective resistance matrix:\n{system['effective_resistance']}")
    print(f"\nSusceptibility distance:\n{system['susceptibility_distance']}")
    print(f"\nK eigenvalues: {system['eigenvalues_K']}")
    print(f"\nNegative type verified: {system['negative_type']}")
    print(f"Contraction verified: {system['contraction_verified']}")
    print(f"Resistance comparison: {system['resistance_comparison']}")

    print("\n\nSpectral Analysis:")
    spec = spectral_decomposition_analysis(beta, L)
    print(f"L eigenvalues: {spec['eigenvalues_L']}")
    print(f"K eigenvalues: {spec['eigenvalues_K']}")
    print(f"χ eigenvalues: {spec['actual_chi_eigenvalues']}")
    print(f"Trace K: {spec['trace_K']:.4f}")
    print(f"Trace χ: {spec['trace_chi']:.4f}")
