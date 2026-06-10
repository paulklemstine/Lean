#!/usr/bin/env python3
"""
Algorithms for Lorentzian Gap Certification and Mixing Time Prediction

Implements the certified procedures from the research paper:
1. Lorentzian gap estimation via eigenvalue analysis
2. Mixing time prediction from coupling matrices
3. Perturbation stability analysis
"""

import numpy as np
from typing import Tuple, Optional, Dict, List


def compute_lorentzian_gap(H: np.ndarray) -> Tuple[float, np.ndarray, bool]:
    """
    Compute the Lorentzian gap of a symmetric matrix H.
    
    A matrix has Lorentzian signature if it has at most one positive eigenvalue.
    The gap ε is the magnitude of the second-largest eigenvalue (which should
    be negative for Lorentzian matrices).
    
    Args:
        H: Symmetric matrix (n × n)
    
    Returns:
        gap: The Lorentzian gap ε ≥ 0
        direction: The distinguished (positive) direction
        is_lorentzian: Whether the matrix has Lorentzian signature
    
    Complexity: O(n³) for eigenvalue decomposition
    """
    n = H.shape[0]
    assert H.shape == (n, n), "Matrix must be square"
    
    # Symmetrize (in case of numerical asymmetry)
    H_sym = (H + H.T) / 2
    
    eigenvalues, eigenvectors = np.linalg.eigh(H_sym)
    
    # Sort eigenvalues in decreasing order
    idx = np.argsort(eigenvalues)[::-1]
    eigenvalues = eigenvalues[idx]
    eigenvectors = eigenvectors[:, idx]
    
    # Check Lorentzian signature: at most one positive eigenvalue
    n_positive = np.sum(eigenvalues > 1e-10)
    is_lorentzian = n_positive <= 1
    
    # The distinguished direction is the eigenvector of the largest eigenvalue
    direction = eigenvectors[:, 0]
    
    # The gap is |λ₂| where λ₂ is the second eigenvalue
    if n > 1:
        gap = abs(eigenvalues[1])
    else:
        gap = 0.0
    
    return gap, direction, is_lorentzian


def predict_mixing_time(J: np.ndarray, h: np.ndarray,
                        delta: float = 0.25) -> Dict[str, float]:
    """
    Predict the mixing time of Glauber dynamics for an Ising model
    with coupling matrix J and external field h.
    
    Uses the Lorentzian gap certificate to compute:
        t_mix(δ) ≤ C · n · log(1/(δ·μ_min)) / ε
    
    Args:
        J: Coupling matrix (n × n, symmetric)
        h: External field (n,)
        delta: Target TV distance (default 1/4)
    
    Returns:
        Dictionary with gap, predicted mixing time, and diagnostics
    
    Complexity: O(n³) for the eigenvalue computation
    """
    n = J.shape[0]
    
    gap, direction, is_lorentzian = compute_lorentzian_gap(J)
    
    # Estimate μ_min (minimum probability over configurations)
    # For bounded coupling, μ_min ≥ exp(-n · (||J||_∞ + ||h||_∞))
    J_norm = np.max(np.abs(J))
    h_norm = np.max(np.abs(h))
    log_mu_min = -n * (J_norm * n + h_norm)
    
    # Predicted mixing time: n / ε · log(1/(δ·μ_min))
    if gap > 1e-10:
        t_mix_upper = (n / gap) * (np.log(1 / delta) - log_mu_min)
    else:
        t_mix_upper = float('inf')
    
    # Poincaré constant: 1/ε
    poincare_const = 1 / gap if gap > 1e-10 else float('inf')
    
    # Spectral gap: ε / n (for n-site single-site dynamics)
    spectral_gap = gap / n if gap > 1e-10 else 0.0
    
    return {
        "n": n,
        "lorentzian_gap": gap,
        "is_lorentzian": is_lorentzian,
        "distinguished_direction": direction.tolist(),
        "poincare_constant": poincare_const,
        "spectral_gap": spectral_gap,
        "predicted_mixing_time": t_mix_upper,
        "log_mu_min": log_mu_min,
    }


def certify_perturbation_stability(J: np.ndarray, delta: float) -> Dict[str, any]:
    """
    Certify that perturbations of J by at most δ entrywise
    preserve the Lorentzian gap up to factor 2.
    
    The certificate verifies: if ||J - J'||_∞ ≤ δ ≤ ε/(2n²),
    then J' has Lorentzian gap ≥ ε/2.
    
    Args:
        J: Original coupling matrix
        delta: Perturbation bound
    
    Returns:
        Certificate dictionary with stability analysis
    
    Complexity: O(n³) for eigenvalue computation
    """
    n = J.shape[0]
    gap, direction, is_lorentzian = compute_lorentzian_gap(J)
    
    # Maximum allowable perturbation: ε / (2n²)
    max_delta = gap / (2 * n**2) if gap > 0 else 0
    
    is_stable = delta <= max_delta + 1e-12
    
    # Residual gap after perturbation
    residual_gap = gap / 2 if is_stable else max(0, gap - n**2 * delta)
    
    return {
        "original_gap": gap,
        "perturbation_bound": delta,
        "max_allowable_perturbation": max_delta,
        "is_certified_stable": is_stable,
        "residual_gap": residual_gap,
        "gap_degradation_factor": residual_gap / gap if gap > 0 else 0,
    }


def gershgorin_gap_estimate(H: np.ndarray) -> float:
    """
    Conservative Gershgorin-style estimate of the transverse gap.
    
    For each row i, compute R_i = H_{ii} - ∑_{j≠i} |H_{ij}|.
    The minimum R_i gives a lower bound on the smallest eigenvalue.
    
    Args:
        H: Symmetric matrix
    
    Returns:
        Conservative gap estimate (negative means guaranteed negative definite)
    
    Complexity: O(n²)
    """
    n = H.shape[0]
    estimates = []
    for i in range(n):
        off_diag_sum = sum(abs(H[i, j]) for j in range(n) if j != i)
        estimates.append(H[i, i] - off_diag_sum)
    
    # The most negative estimate gives the strongest concavity bound
    return -min(estimates)


def susceptibility_bound(J: np.ndarray, v: np.ndarray) -> float:
    """
    Compute the susceptibility quadratic form Q_J(v) = v^T J v.
    
    For a Lorentzian matrix with gap ε, this satisfies
    Q_J(v) ≤ -ε ||v||² for v orthogonal to the distinguished direction.
    
    Args:
        J: Coupling/Hessian matrix
        v: Test vector
    
    Returns:
        The quadratic form value
    """
    return float(v @ J @ v)


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("Lorentzian Gap Certification Algorithms")
    print("=" * 50)
    
    # Example: Complete graph Ising model
    for n in [8, 12, 16, 20]:
        strength = 0.5
        J = strength * (np.ones((n, n)) - np.eye(n)) / n
        h = np.zeros(n)
        
        # Compute gap
        result = predict_mixing_time(J, h)
        print(f"\nn = {n}, coupling = {strength}")
        print(f"  Lorentzian gap: {result['lorentzian_gap']:.6f}")
        print(f"  Is Lorentzian: {result['is_lorentzian']}")
        print(f"  Poincaré constant: {result['poincare_constant']:.4f}")
        print(f"  Spectral gap: {result['spectral_gap']:.6f}")
        print(f"  Predicted mixing time: {result['predicted_mixing_time']:.1f}")
        
        # Test stability
        delta = 0.01 * result['lorentzian_gap'] / (2 * n**2)
        cert = certify_perturbation_stability(J, delta)
        print(f"  Stability certified: {cert['is_certified_stable']}")
        print(f"  Residual gap: {cert['residual_gap']:.6f}")
        
        # Gershgorin estimate
        gersh = gershgorin_gap_estimate(J)
        print(f"  Gershgorin gap estimate: {gersh:.6f}")
