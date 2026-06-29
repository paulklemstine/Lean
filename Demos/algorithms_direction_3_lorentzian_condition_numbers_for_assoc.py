#!/usr/bin/env python3
"""
algorithms.py — Algorithms for computing Lorentzian stability radii
from association scheme spectral data.

Implements:
1. Eigenmatrix computation for Johnson and Hamming schemes
2. Stability radius via spectral formula
3. Certified stability checking
4. Extremal witness identification
"""

import numpy as np
from math import comb
from typing import Tuple, List, Optional


# ============================================================================
# Algorithm 1: Association Scheme Eigenmatrix Computation
# ============================================================================

def eberlein_polynomial(j: int, i: int, n: int, k: int) -> float:
    """Evaluate the Eberlein polynomial E_j(i) for the Johnson scheme J(n,k).
    
    E_j(i) = sum_{s=0}^{min(i,j)} (-1)^s * C(i,s) * C(k-i, j-s) * C(n-k-i, j-s)
    
    Complexity: O(min(i,j))
    
    Args:
        j: Row index (eigenvalue class)
        i: Column index (relation class)
        n: Total number of elements
        k: Subset size
    
    Returns:
        Value of E_j(i)
    """
    val = 0.0
    for s in range(min(i, j) + 1):
        if k - i >= j - s >= 0 and n - k - i >= j - s:
            val += ((-1) ** s) * comb(i, s) * comb(k - i, j - s) * comb(n - k - i, j - s)
    return val


def krawtchouk_polynomial(j: int, i: int, n: int, q: int) -> float:
    """Evaluate the Krawtchouk polynomial K_j(i; n, q) for the Hamming scheme.
    
    K_j(i; n, q) = sum_{s=0}^{min(i,j)} (-1)^s * (q-1)^{j-s} * C(i,s) * C(n-i, j-s)
    
    Complexity: O(min(i,j))
    
    Args:
        j: Row index
        i: Column index
        n: Length of codewords
        q: Alphabet size
    
    Returns:
        Value of K_j(i; n, q)
    """
    val = 0.0
    for s in range(min(i, j) + 1):
        if n - i >= j - s:
            val += ((-1) ** s) * ((q - 1) ** (j - s)) * comb(i, s) * comb(n - i, j - s)
    return val


def johnson_eigenmatrix(n: int, k: int) -> np.ndarray:
    """Compute the first eigenmatrix P of the Johnson scheme J(n,k).
    
    P[j,i] = E_j(i) (Eberlein polynomial values)
    
    Complexity: O(k^3)
    
    Args:
        n: Ground set size
        k: Subset size (number of classes = k)
    
    Returns:
        (k+1) x (k+1) eigenmatrix
    """
    d = k
    P = np.zeros((d + 1, d + 1))
    for j in range(d + 1):
        for i in range(d + 1):
            P[j, i] = eberlein_polynomial(j, i, n, k)
    return P


def hamming_eigenmatrix(n: int, q: int) -> np.ndarray:
    """Compute the first eigenmatrix P of the Hamming scheme H(n,q).
    
    P[j,i] = K_j(i; n, q) (Krawtchouk polynomial values)
    
    Complexity: O(n^3)
    
    Args:
        n: Codeword length (number of classes = n)
        q: Alphabet size
    
    Returns:
        (n+1) x (n+1) eigenmatrix
    """
    P = np.zeros((n + 1, n + 1))
    for j in range(n + 1):
        for i in range(n + 1):
            P[j, i] = krawtchouk_polynomial(j, i, n, q)
    return P


# ============================================================================
# Algorithm 2: Spectral Stability Radius
# ============================================================================

def spectral_stability_radius(
    base_eigenvalues: np.ndarray,
    perturbation_rates: np.ndarray,
    return_witness: bool = False
) -> float | Tuple[float, int]:
    """Compute the Lorentzian stability radius from spectral data.
    
    The stability radius is:
        rho = min_{j >= 1} |a_j| / b_j
    
    where a_j = base_eigenvalues[j] and b_j = perturbation_rates[j].
    
    Complexity: O(d) where d = number of classes
    
    Args:
        base_eigenvalues: Array [a_0, a_1, ..., a_d] of eigenvalues at base point.
            a_0 > 0 (trivial, positive), a_j < 0 for j >= 1 (nontrivial, negative).
        perturbation_rates: Array [b_0, b_1, ..., b_d] of perturbation rates.
            b_j > 0 for j >= 1.
        return_witness: If True, also return the index of the extremal witness class.
    
    Returns:
        Stability radius rho, and optionally the extremal witness index.
    
    Example:
        >>> base = np.array([3.0, -1.0])  # J(4,2): theta_0 = 3, theta_1 = -1
        >>> rates = np.array([0.0, 1.0])
        >>> spectral_stability_radius(base, rates)
        1.0
    """
    d = len(base_eigenvalues) - 1
    min_ratio = float('inf')
    min_j = -1
    
    for j in range(1, d + 1):
        if perturbation_rates[j] > 1e-15:
            ratio = abs(base_eigenvalues[j]) / perturbation_rates[j]
            if ratio < min_ratio:
                min_ratio = ratio
                min_j = j
    
    if return_witness:
        return min_ratio, min_j
    return min_ratio


# ============================================================================
# Algorithm 3: Certified Stability Checker
# ============================================================================

def certified_stability_check(
    hessian: np.ndarray,
    perturbation: np.ndarray,
    spectral_gap: float
) -> Tuple[bool, str]:
    """Certify that a perturbation preserves Lorentzian signature.
    
    Uses the gapped signature theorem: if the Hessian has spectral gap epsilon
    and the perturbation has quadratic form bound delta < epsilon, then the
    perturbed Hessian preserves Lorentzian signature.
    
    Complexity: O(n^3) for eigenvalue computation
    
    Args:
        hessian: n x n symmetric Hessian matrix
        perturbation: n x n symmetric perturbation matrix
        spectral_gap: Known spectral gap epsilon of the Hessian
    
    Returns:
        (is_stable, reason): Whether stability is certified, with explanation.
    """
    # Compute perturbation bound (largest absolute eigenvalue)
    pert_eigenvalues = np.linalg.eigvalsh(perturbation)
    delta = max(abs(pert_eigenvalues[0]), abs(pert_eigenvalues[-1]))
    
    if delta < spectral_gap:
        return True, f"Certified stable: perturbation bound {delta:.6f} < gap {spectral_gap:.6f}"
    else:
        # Not certified, but might still be stable
        combined = hessian + perturbation
        eigs = np.linalg.eigvalsh(combined)
        num_positive = np.sum(eigs > 1e-10)
        if num_positive <= 1:
            return True, f"Stable (empirical): {num_positive} positive eigenvalue(s), but not certified"
        else:
            return False, f"Unstable: {num_positive} positive eigenvalues detected"


# ============================================================================
# Algorithm 4: Scheme Condition Number
# ============================================================================

def scheme_condition_number(
    eigenmatrix: np.ndarray,
    base_coefficients: np.ndarray,
    perturbation_coefficients: np.ndarray
) -> Tuple[float, int]:
    """Compute the scheme condition number from eigenmatrix data.
    
    The condition number is:
        kappa = min_{j >= 1} |sum_k a_k P_{jk}| / |sum_k c_k P_{jk}|
    
    where P is the first eigenmatrix, a_k are base coefficients,
    and c_k are perturbation coefficients.
    
    This gives the stability radius when eigenvalues are linear combinations
    of eigenmatrix entries.
    
    Complexity: O(d^2)
    
    Args:
        eigenmatrix: (d+1) x (d+1) first eigenmatrix P
        base_coefficients: Array of base polynomial coefficients
        perturbation_coefficients: Array of perturbation coefficients
    
    Returns:
        (condition_number, extremal_class_index)
    """
    d = eigenmatrix.shape[0] - 1
    
    # Compute eigenvalues: theta_j = sum_k a_k * P_{jk}
    base_eigs = eigenmatrix @ base_coefficients
    pert_eigs = eigenmatrix @ perturbation_coefficients
    
    min_ratio = float('inf')
    min_j = -1
    
    for j in range(1, d + 1):
        if abs(pert_eigs[j]) > 1e-15:
            ratio = abs(base_eigs[j]) / abs(pert_eigs[j])
            if ratio < min_ratio:
                min_ratio = ratio
                min_j = j
    
    return min_ratio, min_j


# ============================================================================
# Algorithm 5: Eigenvalue Trajectory Analysis
# ============================================================================

def eigenvalue_trajectories(
    base_eigenvalues: np.ndarray,
    perturbation_rates: np.ndarray,
    t_range: np.ndarray
) -> np.ndarray:
    """Compute eigenvalue trajectories theta_j(t) = a_j + t * b_j.
    
    Complexity: O(d * |t_range|)
    
    Args:
        base_eigenvalues: Array of base eigenvalues a_j
        perturbation_rates: Array of perturbation rates b_j
        t_range: Array of parameter values
    
    Returns:
        2D array of shape (d+1, len(t_range)) with eigenvalue trajectories
    """
    d = len(base_eigenvalues) - 1
    trajectories = np.zeros((d + 1, len(t_range)))
    
    for j in range(d + 1):
        trajectories[j, :] = base_eigenvalues[j] + t_range * perturbation_rates[j]
    
    return trajectories


# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    print("=== Spectral Stability Radius Examples ===\n")
    
    # Example 1: Johnson J(8,2)
    print("Johnson J(8,2):")
    base = np.array([7.0, -1.0])
    rates = np.array([0.0, 1.0])
    rho, witness = spectral_stability_radius(base, rates, return_witness=True)
    print(f"  Stability radius: {rho}")
    print(f"  Extremal witness class: j={witness}")
    
    # Example 2: Johnson J(10,3)
    print("\nJohnson J(10,3):")
    P = johnson_eigenmatrix(10, 3)
    print(f"  Eigenmatrix P:\n{P}")
    base = P[:, 0]
    rates = np.abs(P[:, 1])
    rates[0] = 0
    rho, witness = spectral_stability_radius(base, rates, return_witness=True)
    print(f"  Stability radius: {rho:.6f}")
    print(f"  Extremal witness class: j={witness}")
    
    # Example 3: Hamming H(5,2)
    print("\nHamming H(5,2):")
    P = hamming_eigenmatrix(5, 2)
    print(f"  Eigenmatrix P:\n{P}")
    base = P[:, 0]
    rates = np.abs(P[:, 1])
    rates[0] = 0
    rho, witness = spectral_stability_radius(base, rates, return_witness=True)
    print(f"  Stability radius: {rho:.6f}")
    print(f"  Extremal witness class: j={witness}")
    
    # Example 4: Certified stability check
    print("\nCertified stability check (n=6):")
    H = np.ones((6, 6)) - np.eye(6)  # Leaf Hessian J - I
    E = 0.5 * np.eye(6)  # Small perturbation
    stable, reason = certified_stability_check(H, E, spectral_gap=1.0)
    print(f"  {reason}")
