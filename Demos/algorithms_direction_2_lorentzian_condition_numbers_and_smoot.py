"""
Algorithms for Lorentzian Smoothed Analysis
=============================================
Implements certified Lorentzian recognition with condition number estimation
and robust perturbation analysis.

Core algorithms:
1. Certified Lorentzian signature checker with spectral gap computation
2. Lorentzian condition number estimator
3. Robust Lorentzian classifier with safe radius certificate
4. Smoothed failure probability estimator
"""

import numpy as np
from typing import Tuple, Optional, NamedTuple
from dataclasses import dataclass


@dataclass
class GapCertificate:
    """Certificate for a gapped Lorentzian signature.
    
    Attributes:
        has_lorentzian_signature: Whether the matrix has at most one positive eigenvalue
        spectral_gap: The minimum absolute value of negative eigenvalues (ε)
        witness_direction: The eigenvector for the unique positive eigenvalue
        eigenvalues: All eigenvalues sorted in ascending order
        safe_radius: Certified perturbation radius preserving the signature
    """
    has_lorentzian_signature: bool
    spectral_gap: float
    witness_direction: Optional[np.ndarray]
    eigenvalues: np.ndarray
    safe_radius: float


@dataclass
class ConditionNumberResult:
    """Result of condition number computation.
    
    Attributes:
        condition_number: κ = max_norm / min_gap
        min_gap: Minimum spectral gap across all certificate matrices
        max_norm: Maximum operator norm across all certificate matrices
        is_well_conditioned: Whether κ is finite and bounded
    """
    condition_number: float
    min_gap: float
    max_norm: float
    is_well_conditioned: bool


@dataclass
class RobustClassification:
    """Result of robust Lorentzian classification.
    
    Attributes:
        is_lorentzian: Classification result
        confidence_radius: Safe perturbation radius (ε for operator norm)
        failure_probability_bound: Upper bound on P(misclassification) for given σ
    """
    is_lorentzian: bool
    confidence_radius: float
    failure_probability_bound: Optional[float]


def compute_gap_certificate(A: np.ndarray) -> GapCertificate:
    """Compute a gap certificate for a symmetric matrix A.
    
    Algorithm:
    1. Compute eigendecomposition A = Q Λ Q^T
    2. Count positive eigenvalues
    3. If at most one positive eigenvalue, compute spectral gap
    4. Return certificate with safe radius = spectral gap
    
    Time complexity: O(n³) for eigendecomposition
    Space complexity: O(n²)
    
    Args:
        A: Symmetric n×n real matrix
        
    Returns:
        GapCertificate with all certification data
        
    Example:
        >>> A = np.diag([1.0, -0.5, -0.5])
        >>> cert = compute_gap_certificate(A)
        >>> cert.has_lorentzian_signature
        True
        >>> cert.spectral_gap
        0.5
    """
    eigenvalues, eigenvectors = np.linalg.eigh(A)
    
    # Count positive eigenvalues (with tolerance)
    pos_count = np.sum(eigenvalues > 1e-10)
    has_lor_sig = pos_count <= 1
    
    if not has_lor_sig:
        return GapCertificate(
            has_lorentzian_signature=False,
            spectral_gap=0.0,
            witness_direction=None,
            eigenvalues=eigenvalues,
            safe_radius=0.0
        )
    
    # Compute spectral gap: min |λ_i| for λ_i < 0
    neg_eigs = eigenvalues[eigenvalues < -1e-10]
    if len(neg_eigs) == 0:
        gap = 0.0
    else:
        gap = float(np.min(np.abs(neg_eigs)))
    
    # Witness direction: eigenvector of the positive eigenvalue (if exists)
    if pos_count == 1:
        pos_idx = np.argmax(eigenvalues > 1e-10)
        witness = eigenvectors[:, pos_idx]
    else:
        witness = np.zeros(A.shape[0])
    
    return GapCertificate(
        has_lorentzian_signature=True,
        spectral_gap=gap,
        witness_direction=witness,
        eigenvalues=eigenvalues,
        safe_radius=gap
    )


def compute_condition_number(
    matrices: list[np.ndarray]
) -> ConditionNumberResult:
    """Compute the Lorentzian condition number for a collection of matrices.
    
    The condition number κ = max_norm / min_gap measures how sensitive
    the Lorentzian classification is to perturbation.
    
    Algorithm:
    1. For each matrix, compute gap certificate
    2. Find minimum gap and maximum operator norm
    3. Return κ = max_norm / min_gap
    
    Time complexity: O(m · n³) where m = number of matrices
    Space complexity: O(n²)
    
    Args:
        matrices: List of symmetric n×n matrices (certificate matrices)
        
    Returns:
        ConditionNumberResult
        
    Example:
        >>> A1 = np.diag([1.0, -2.0, -2.0])
        >>> A2 = np.diag([1.0, -1.0, -1.0])
        >>> result = compute_condition_number([A1, A2])
        >>> result.min_gap
        1.0
    """
    if not matrices:
        return ConditionNumberResult(0.0, 0.0, 0.0, False)
    
    min_gap = float('inf')
    max_norm = 0.0
    
    for A in matrices:
        cert = compute_gap_certificate(A)
        if not cert.has_lorentzian_signature:
            return ConditionNumberResult(float('inf'), 0.0, 0.0, False)
        if cert.spectral_gap > 0:
            min_gap = min(min_gap, cert.spectral_gap)
        max_norm = max(max_norm, float(np.max(np.abs(cert.eigenvalues))))
    
    if min_gap == float('inf') or min_gap == 0:
        return ConditionNumberResult(float('inf'), 0.0, max_norm, False)
    
    kappa = max_norm / min_gap
    return ConditionNumberResult(kappa, min_gap, max_norm, True)


def robust_classify(
    A: np.ndarray,
    sigma: float = 0.0,
    n_dim: Optional[int] = None,
    tail_constant_C: float = 1.0,
    tail_constant_c: float = 0.5
) -> RobustClassification:
    """Robust Lorentzian classifier with certified safe radius.
    
    Combines gap certificate computation with smoothed analysis bound:
    P(failure) ≤ C · exp(-c · ε² / (n · σ²))
    
    Algorithm:
    1. Compute gap certificate for A
    2. If Lorentzian, compute safe radius ε
    3. If σ > 0, compute failure probability bound
    4. Return classification with confidence
    
    Time complexity: O(n³)
    Space complexity: O(n²)
    
    Args:
        A: Symmetric matrix to classify
        sigma: Noise standard deviation (0 = deterministic)
        n_dim: Ambient dimension (defaults to matrix size)
        tail_constant_C: Tail bound constant C
        tail_constant_c: Tail bound constant c
        
    Returns:
        RobustClassification with certified radius and probability bound
    """
    cert = compute_gap_certificate(A)
    n = n_dim or A.shape[0]
    
    if not cert.has_lorentzian_signature:
        return RobustClassification(False, 0.0, None)
    
    epsilon = cert.spectral_gap
    
    if sigma > 0 and epsilon > 0:
        # Smoothed failure bound: C * exp(-c * ε² / (n * σ²))
        exponent = -tail_constant_c * epsilon**2 / (n * sigma**2)
        prob_bound = tail_constant_C * np.exp(exponent)
        prob_bound = min(prob_bound, 1.0)
    else:
        prob_bound = 0.0 if epsilon > 0 else None
    
    return RobustClassification(
        is_lorentzian=True,
        confidence_radius=epsilon,
        failure_probability_bound=prob_bound
    )


def smoothed_failure_estimator(
    A: np.ndarray,
    sigma_values: np.ndarray,
    num_trials: int = 1000
) -> Tuple[np.ndarray, np.ndarray]:
    """Estimate smoothed failure probability by Monte Carlo.
    
    For each σ, generates random symmetric Gaussian perturbations
    and estimates the probability of losing the Lorentzian signature.
    
    Algorithm:
    1. For each σ in sigma_values:
       a. Generate num_trials random symmetric perturbations E ~ N(0, σ²)
       b. Count how many A + E lose the Lorentzian signature
       c. Estimate failure probability as count / num_trials
    
    Time complexity: O(|sigma_values| · num_trials · n³)
    Space complexity: O(n²)
    
    Args:
        A: Base Lorentzian matrix
        sigma_values: Array of noise scales to test
        num_trials: Monte Carlo samples per σ
        
    Returns:
        Tuple of (failure_rates, theoretical_bounds)
    """
    cert = compute_gap_certificate(A)
    n = A.shape[0]
    epsilon = cert.spectral_gap
    
    failure_rates = np.zeros(len(sigma_values))
    theoretical_bounds = np.zeros(len(sigma_values))
    
    for i, sigma in enumerate(sigma_values):
        failures = 0
        for _ in range(num_trials):
            E = np.random.randn(n, n) * sigma
            E = (E + E.T) / 2
            
            perturbed = A + E
            eigenvalues = np.linalg.eigvalsh(perturbed)
            if np.sum(eigenvalues > 1e-10) > 1:
                failures += 1
        
        failure_rates[i] = failures / num_trials
        
        # Theoretical bound
        if sigma > 0 and epsilon > 0:
            theoretical_bounds[i] = min(
                1.0, np.exp(-0.5 * epsilon**2 / (n * sigma**2))
            )
    
    return failure_rates, theoretical_bounds


# ============================================================
# Example usage
# ============================================================

if __name__ == '__main__':
    np.random.seed(42)
    
    print("Lorentzian Smoothed Analysis — Algorithm Demonstrations")
    print("=" * 60)
    
    # Example 1: Gap certificate
    print("\n1. Gap Certificate Computation")
    print("-" * 40)
    A = np.diag([2.0, -1.0, -0.5, -0.8])
    cert = compute_gap_certificate(A)
    print(f"Matrix eigenvalues: {cert.eigenvalues}")
    print(f"Lorentzian signature: {cert.has_lorentzian_signature}")
    print(f"Spectral gap: {cert.spectral_gap:.4f}")
    print(f"Safe radius: {cert.safe_radius:.4f}")
    
    # Example 2: Condition number
    print("\n2. Condition Number Estimation")
    print("-" * 40)
    matrices = [
        np.diag([1.0, -2.0, -2.0]),
        np.diag([1.0, -1.0, -1.0]),
        np.diag([1.0, -0.5, -3.0]),
    ]
    cn = compute_condition_number(matrices)
    print(f"Min gap: {cn.min_gap:.4f}")
    print(f"Max norm: {cn.max_norm:.4f}")
    print(f"Condition number κ: {cn.condition_number:.4f}")
    print(f"Well-conditioned: {cn.is_well_conditioned}")
    
    # Example 3: Robust classification
    print("\n3. Robust Classification")
    print("-" * 40)
    A = np.diag([1.0, -1.0, -1.0, -1.0, -1.0])
    for sigma in [0.1, 0.5, 1.0, 2.0]:
        result = robust_classify(A, sigma=sigma)
        print(f"σ = {sigma:.1f}: Lorentzian={result.is_lorentzian}, "
              f"radius={result.confidence_radius:.4f}, "
              f"P(fail) ≤ {result.failure_probability_bound:.6f}")
    
    # Example 4: Smoothed failure estimation
    print("\n4. Smoothed Failure Estimation")
    print("-" * 40)
    sigma_values = np.array([0.1, 0.3, 0.5, 0.7, 1.0, 1.5, 2.0])
    failure_rates, bounds = smoothed_failure_estimator(
        A, sigma_values, num_trials=500
    )
    print(f"{'σ':>6s} {'P(fail)':>10s} {'Bound':>10s}")
    for s, fr, b in zip(sigma_values, failure_rates, bounds):
        print(f"{s:6.2f} {fr:10.4f} {b:10.4f}")
