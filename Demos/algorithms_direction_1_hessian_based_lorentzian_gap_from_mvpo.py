"""
Algorithms for Hessian-Based Lorentzian Gap Analysis of DPP Kernels

This module implements the core algorithms from the research paper:
- Construction of principal minor matrices H = ddᵀ - K⊙K
- Computation of the Lorentzian gap parameter
- Spectral analysis of H for Lorentzian signature detection
- Perturbation bounds for robustness analysis

All algorithms operate on real symmetric positive semidefinite matrices K
with eigenvalues in [0,1] (DPP marginal kernels).
"""

import numpy as np
from numpy.typing import NDArray
from typing import Tuple, Optional


def principal_minor_matrix(K: NDArray[np.float64]) -> NDArray[np.float64]:
    """Compute H_{ij} = K_{ii}·K_{jj} - K_{ij}² for all i,j.

    This is the matrix of 2×2 principal minors of K, equivalently
    H = d·dᵀ - K⊙K where d = diag(K) and ⊙ is Hadamard product.

    Args:
        K: n×n symmetric PSD matrix with eigenvalues in [0,1]

    Returns:
        n×n matrix H of 2×2 principal minors

    Time complexity: O(n²)
    Space complexity: O(n²)
    """
    d = np.diag(K)
    # H = d·dᵀ - K⊙K
    H = np.outer(d, d) - K * K
    return H


def lorentzian_gap_param(K: NDArray[np.float64]) -> float:
    """Compute the Lorentzian gap parameter: (tr K)² - ‖K‖_F².

    This equals the sum of all entries of the principal minor matrix H.
    A positive value is necessary for Lorentzian signature.

    Args:
        K: n×n symmetric PSD matrix

    Returns:
        gap parameter = (tr K)² - ‖K‖_F²

    Time complexity: O(n²)
    """
    trace_sq = np.trace(K) ** 2
    frob_sq = np.sum(K * K)
    return float(trace_sq - frob_sq)


def eigenvalue_gap(H: NDArray[np.float64]) -> Tuple[float, float, float]:
    """Compute the eigenvalue gap of the principal minor matrix.

    Returns (λ₁, λ₂, gap) where λ₁ ≥ λ₂ are the two largest eigenvalues
    and gap = λ₁ - λ₂.

    Args:
        H: n×n symmetric matrix (principal minor matrix)

    Returns:
        Tuple (λ₁, λ₂, gap)

    Time complexity: O(n³) due to eigendecomposition
    """
    eigenvalues = np.sort(np.linalg.eigvalsh(H))[::-1]
    lambda1 = eigenvalues[0]
    lambda2 = eigenvalues[1] if len(eigenvalues) > 1 else 0.0
    return float(lambda1), float(lambda2), float(lambda1 - lambda2)


def check_lorentzian_signature(H: NDArray[np.float64], tol: float = 1e-10) -> bool:
    """Check if H has Lorentzian signature (at most one positive eigenvalue).

    Args:
        H: n×n symmetric matrix
        tol: tolerance for considering eigenvalue as positive

    Returns:
        True if H has at most one positive eigenvalue
    """
    eigenvalues = np.linalg.eigvalsh(H)
    num_positive = np.sum(eigenvalues > tol)
    return int(num_positive) <= 1


def spectral_gap(K: NDArray[np.float64]) -> float:
    """Compute the spectral gap of a DPP kernel.

    The spectral gap Δ is the minimum distance of any eigenvalue from {0,1}.
    This measures how far K is from being a projection.

    Args:
        K: n×n symmetric PSD matrix with eigenvalues in [0,1]

    Returns:
        Spectral gap Δ = min_i min(λ_i, 1-λ_i)
    """
    eigenvalues = np.linalg.eigvalsh(K)
    distances = np.minimum(eigenvalues, 1 - eigenvalues)
    return float(np.min(distances))


def perturbation_bound(K: NDArray[np.float64], E: NDArray[np.float64]) -> NDArray[np.float64]:
    """Compute the perturbation H(K+E) - H(K) exactly.

    Uses the bilinear formula:
    δH_{ij} = E_ii·K_jj + K_ii·E_jj + E_ii·E_jj - 2K_ij·E_ij - E_ij²

    Args:
        K: original n×n kernel
        E: perturbation matrix

    Returns:
        Matrix of perturbation δH
    """
    return principal_minor_matrix(K + E) - principal_minor_matrix(K)


def dpp_entropy(K: NDArray[np.float64]) -> float:
    """Compute the von Neumann entropy of a DPP kernel.

    S(K) = -∑ᵢ [K_ii log K_ii + (1-K_ii) log(1-K_ii)]

    Args:
        K: n×n DPP kernel with diagonal entries in (0,1)

    Returns:
        Von Neumann entropy
    """
    d = np.diag(K)
    d = np.clip(d, 1e-15, 1 - 1e-15)  # avoid log(0)
    return float(-np.sum(d * np.log(d) + (1 - d) * np.log(1 - d)))


def tfim_correlation_matrix(n: int, J: float, h: float) -> NDArray[np.float64]:
    """Construct the single-particle correlation matrix for the
    transverse-field Ising model (TFIM) on n sites.

    H = -J ∑ σ_z^i σ_z^{i+1} - h ∑ σ_x^i

    For the free-fermionic (Jordan-Wigner) representation, the correlation
    matrix K has entries K_{ij} related to the Fourier-space occupation numbers.

    Args:
        n: number of qubits
        J: coupling strength
        h: transverse field strength

    Returns:
        n×n correlation matrix K

    Note: This uses the exact diagonalization via Jordan-Wigner transform.
    """
    # Single-particle energies for TFIM
    # ε_k = 2√(J² + h² - 2Jh cos(2πk/n))
    K = np.zeros((n, n))
    for k in range(n):
        theta = 2 * np.pi * k / n
        eps_k = 2 * np.sqrt(J**2 + h**2 - 2 * J * h * np.cos(theta))
        if eps_k < 1e-14:
            # Degenerate case
            n_k = 0.5
        else:
            # Ground state occupation: n_k = (1 - cos(angle))/2
            cos_angle = (h - J * np.cos(theta)) / (eps_k / 2)
            cos_angle = np.clip(cos_angle, -1, 1)
            n_k = (1 - cos_angle) / 2

        # Add contribution from mode k to correlation matrix
        for i in range(n):
            for j in range(n):
                K[i, j] += n_k * np.cos(theta * (i - j)) / n

    # Symmetrize
    K = (K + K.T) / 2
    # Clip eigenvalues to [0, 1]
    eigvals, eigvecs = np.linalg.eigh(K)
    eigvals = np.clip(eigvals, 0, 1)
    K = eigvecs @ np.diag(eigvals) @ eigvecs.T
    return K


def projection_matrix(n: int, k: int) -> NDArray[np.float64]:
    """Create a rank-k projection matrix on n dimensions.

    Args:
        n: matrix dimension
        k: rank of projection

    Returns:
        n×n projection matrix with trace k
    """
    Q, _ = np.linalg.qr(np.random.randn(n, k))
    return Q @ Q.T


if __name__ == "__main__":
    print("=== Algorithms Demo ===\n")

    # Example 1: 4×4 DPP kernel
    np.random.seed(42)
    n = 4
    A = np.random.randn(n, n)
    K_raw = A @ A.T
    eigvals, eigvecs = np.linalg.eigh(K_raw)
    eigvals = np.clip(eigvals / (1 + np.max(np.abs(eigvals))), 0, 1)
    K = eigvecs @ np.diag(eigvals) @ eigvecs.T

    print(f"K (4×4 DPP kernel):")
    print(K.round(4))

    H = principal_minor_matrix(K)
    print(f"\nPrincipal minor matrix H:")
    print(H.round(4))

    gap = lorentzian_gap_param(K)
    print(f"\nLorentzian gap parameter: {gap:.6f}")
    print(f"  = (tr K)² - ‖K‖_F² = {np.trace(K)**2:.6f} - {np.sum(K*K):.6f}")

    lam1, lam2, eiggap = eigenvalue_gap(H)
    print(f"\nEigenvalue gap: λ₁={lam1:.6f}, λ₂={lam2:.6f}, gap={eiggap:.6f}")
    print(f"Lorentzian signature: {check_lorentzian_signature(H)}")

    # Example 2: Projection
    K_proj = projection_matrix(6, 3)
    H_proj = principal_minor_matrix(K_proj)
    gap_proj = lorentzian_gap_param(K_proj)
    print(f"\n--- Rank-3 projection on 6 dimensions ---")
    print(f"Gap parameter: {gap_proj:.6f} (expected: 3²-3 = 6)")
    print(f"Lorentzian: {check_lorentzian_signature(H_proj)}")
