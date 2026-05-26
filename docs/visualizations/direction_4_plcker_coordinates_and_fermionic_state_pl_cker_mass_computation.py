"""
Algorithms for Fermionic Plücker Coordinates and Matroid Basis Sampling

Implements verified computational methods for:
- Computing Plücker masses (weighted and unweighted)
- Constructing projection kernels
- Sampling from determinantal point processes
- Verifying matroid basis structure
"""

import numpy as np
from itertools import combinations
from typing import List, Tuple, Dict, Optional


def compute_plucker_mass(A: np.ndarray, w: np.ndarray) -> float:
    """
    Compute the weighted Plücker mass.
    
    pluckerMass(A, w) = sum_{|S|=r} det(A_S)^2 * prod_{i in S} w_i
    
    This equals det(A * diag(w) * A^T) by the Cauchy-Binet identity.
    
    Args:
        A: Matrix of shape (r, n)
        w: Weight vector of length n
    
    Returns:
        The weighted Plücker mass
    """
    r, n = A.shape
    total = 0.0
    for S in combinations(range(n), r):
        cols = list(S)
        det_S = np.linalg.det(A[:, cols])
        weight_prod = np.prod([w[i] for i in S])
        total += det_S**2 * weight_prod
    return total


def compute_plucker_mass_gram(A: np.ndarray, w: np.ndarray) -> float:
    """
    Compute the weighted Plücker mass via the Gram determinant.
    
    Uses the Cauchy-Binet identity: pluckerMass(A, w) = det(A diag(w) A^T).
    This is O(r^3 + r*n) instead of O(C(n,r) * r^3).
    
    Args:
        A: Matrix of shape (r, n)
        w: Weight vector of length n
    
    Returns:
        det(A * diag(w) * A^T)
    """
    Dw = np.diag(w)
    G = A @ Dw @ A.T
    return np.linalg.det(G)


def compute_projection_kernel(A: np.ndarray) -> np.ndarray:
    """
    Compute the projection kernel K = A^T (A A^T)^{-1} A.
    
    Properties of K:
    - K is symmetric and idempotent (K^2 = K)
    - rank(K) = rank(A)
    - trace(K) = rank(A) = r (when A has full row rank)
    - K defines a determinantal point process
    
    Args:
        A: Matrix of shape (r, n) with full row rank
    
    Returns:
        K: The n x n projection kernel matrix
    """
    gram = A @ A.T
    gram_inv = np.linalg.inv(gram)
    return A.T @ gram_inv @ A


def slater_basis_distribution(A: np.ndarray) -> Dict[Tuple[int, ...], float]:
    """
    Compute the Slater basis distribution.
    
    P(S) = det(A_S)^2 / det(A A^T)
    
    This is the Born measurement probability of the fermionic Slater
    determinant state |psi> = a_1 ∧ ... ∧ a_r in the occupation basis.
    
    Args:
        A: Matrix of shape (r, n) with full row rank
    
    Returns:
        Dictionary mapping r-subsets to their probabilities
    """
    r, n = A.shape
    gram_det = np.linalg.det(A @ A.T)
    assert gram_det > 1e-12, "A must have full row rank"
    
    dist = {}
    for S in combinations(range(n), r):
        det_S = np.linalg.det(A[:, list(S)])
        dist[S] = det_S**2 / gram_det
    return dist


def verify_dpp_identity(A: np.ndarray, tol: float = 1e-10) -> bool:
    """
    Verify the DPP identity: det(A_S)^2 / det(AA^T) = det(K_S)
    for all r-subsets S, where K = A^T (AA^T)^{-1} A.
    
    This is the key theorem connecting representable matroids to
    determinantal point processes.
    
    Args:
        A: Matrix of shape (r, n) with full row rank
        tol: Tolerance for numerical comparison
    
    Returns:
        True if identity holds for all subsets
    """
    r, n = A.shape
    gram_det = np.linalg.det(A @ A.T)
    if gram_det < 1e-12:
        return False
    
    K = compute_projection_kernel(A)
    
    for S in combinations(range(n), r):
        idx = list(S)
        slater_p = np.linalg.det(A[:, idx])**2 / gram_det
        dpp_p = np.linalg.det(K[np.ix_(idx, idx)])
        if abs(slater_p - dpp_p) > tol:
            return False
    return True


def matroid_bases(A: np.ndarray, tol: float = 1e-10) -> List[Tuple[int, ...]]:
    """
    Extract the bases of the matroid represented by A.
    
    A basis is an r-subset S such that det(A_S) ≠ 0.
    
    Args:
        A: Matrix of shape (r, n)
        tol: Tolerance for zero-testing
    
    Returns:
        List of r-subsets that are bases
    """
    r, n = A.shape
    bases = []
    for S in combinations(range(n), r):
        if abs(np.linalg.det(A[:, list(S)])) > tol:
            bases.append(S)
    return bases


def sample_dpp_naive(A: np.ndarray, num_samples: int = 1000) -> List[Tuple[int, ...]]:
    """
    Sample from the Slater/DPP distribution using rejection sampling.
    
    This is a naive sampler for demonstration. For efficiency, use the
    eigendecomposition-based DPP sampler.
    
    Args:
        A: Matrix of shape (r, n) with full row rank
        num_samples: Number of samples to draw
    
    Returns:
        List of sampled r-subsets
    """
    dist = slater_basis_distribution(A)
    subsets = list(dist.keys())
    probs = np.array([dist[S] for S in subsets])
    probs = probs / probs.sum()  # Renormalize for numerical stability
    
    indices = np.random.choice(len(subsets), size=num_samples, p=probs)
    return [subsets[i] for i in indices]


if __name__ == "__main__":
    # Example usage
    A = np.array([[1, 0, 1, 1],
                   [0, 1, 1, -1]], dtype=float)
    w = np.array([1, 2, 3, 4], dtype=float)
    
    print("Matrix A:")
    print(A)
    print(f"\nWeights w = {w}")
    print(f"\nPlücker mass (direct): {compute_plucker_mass(A, w):.6f}")
    print(f"Plücker mass (Gram):   {compute_plucker_mass_gram(A, w):.6f}")
    
    print(f"\nMatroid bases: {matroid_bases(A)}")
    
    print(f"\nSlater distribution:")
    for S, p in sorted(slater_basis_distribution(A).items()):
        if p > 1e-12:
            print(f"  P({set(S)}) = {p:.6f}")
    
    print(f"\nDPP identity verified: {verify_dpp_identity(A)}")
    
    print(f"\nProjection kernel K:")
    print(compute_projection_kernel(A))
