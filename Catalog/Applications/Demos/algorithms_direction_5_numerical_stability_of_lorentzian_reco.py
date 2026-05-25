#!/usr/bin/env python3
"""
Algorithms for Certified Lorentzian Recognition

Implements the algorithms from the research paper on numerical stability
of Lorentzian polynomial recognition.

Main algorithms:
1. certify_lorentzian_stability: Compute certified perturbation radius
2. compute_spectral_gap: Estimate the spectral gap of a symmetric matrix
3. quadratic_leaf_hessian: Compute Hessian of a quadratic leaf
4. lorentzian_condition_number: Compute the Lorentzian condition number

All algorithms have polynomial time complexity in n (dimension) and d (degree).
"""

import numpy as np
from typing import Optional, Tuple, List, Dict
from itertools import combinations_with_replacement
from math import comb, factorial


def compute_spectral_gap(H: np.ndarray) -> Tuple[float, bool, np.ndarray]:
    """Compute the spectral gap for the Lorentzian signature property.
    
    Given a symmetric matrix H, determines:
    1. Whether H has at most one positive eigenvalue
    2. The spectral gap = |λ₂| where λ₂ is the second-largest eigenvalue
    3. The full eigenvalue spectrum
    
    Args:
        H: Symmetric matrix (n x n)
        
    Returns:
        (gap, has_lorentzian_signature, eigenvalues_descending)
        
    Time complexity: O(n³) via eigendecomposition
    Space complexity: O(n²)
    """
    if H.shape[0] == 0:
        return (0.0, True, np.array([]))
    
    eigenvalues = np.sort(np.linalg.eigvalsh(H))[::-1]
    
    pos_count = np.sum(eigenvalues > 1e-12)
    has_sig = pos_count <= 1
    
    if len(eigenvalues) < 2:
        return (0.0, has_sig, eigenvalues)
    
    second_ev = eigenvalues[1]
    gap = -second_ev if second_ev < -1e-12 else 0.0
    
    return (gap, has_sig, eigenvalues)


def quadratic_form_bound(E: np.ndarray) -> float:
    """Compute the quadratic form bound δ such that |v^T E v| ≤ δ ||v||² for all v.
    
    This equals the spectral radius of E: max|λᵢ(E)|.
    
    Args:
        E: Symmetric matrix
        
    Returns:
        The quadratic form bound δ
        
    Time complexity: O(n³)
    """
    if E.shape[0] == 0:
        return 0.0
    return float(np.max(np.abs(np.linalg.eigvalsh(E))))


def entry_based_qf_bound(E: np.ndarray) -> float:
    """Compute a quadratic form bound from entry-wise bounds.
    
    From our theorem (quadFormBound_of_entry_bound):
    If |E_{ij}| ≤ B for all i,j, then |v^T E v| ≤ n² · B · ||v||².
    
    This is a looser but easier-to-compute bound.
    
    Args:
        E: Matrix (not necessarily symmetric)
        
    Returns:
        Upper bound n² · max|E_{ij}|
    """
    n = E.shape[0]
    max_entry = np.max(np.abs(E))
    return n ** 2 * max_entry


def certify_lorentzian_stability(
    hessians: List[np.ndarray],
    use_tight_bound: bool = True
) -> Optional[float]:
    """Certified Lorentzian stability checker.
    
    Given a list of quadratic leaf Hessian matrices, computes the certified
    perturbation radius δ such that any perturbation with quadratic form
    bound < δ preserves the Lorentzian signature on all leaves.
    
    Implements the algorithm from the paper:
    1. Compute spectral gap εₖ for each leaf k
    2. Take minimum gap ε = min_k εₖ
    3. Return ε/2 as certified radius (factor 2 for safety)
    
    Args:
        hessians: List of symmetric matrices (quadratic leaf Hessians)
        use_tight_bound: If True, use spectral radius for QF bound;
                        if False, use entry-based bound (n² factor)
    
    Returns:
        Some(δ) if certification succeeds (δ > 0)
        None if no gap is found (some leaf has degenerate signature)
        
    Time complexity: O(m · n³) where m = number of leaves
    Space complexity: O(n²)
    """
    if not hessians:
        return None
    
    min_gap = float('inf')
    
    for k, H in enumerate(hessians):
        gap, has_sig, eigenvalues = compute_spectral_gap(H)
        
        if not has_sig:
            return None  # A leaf already fails signature
        
        if gap <= 0:
            return None  # No positive gap
        
        min_gap = min(min_gap, gap)
    
    if min_gap <= 0 or min_gap == float('inf'):
        return None
    
    # Return ε/2 as the certified radius
    return min_gap / 2


def lorentzian_condition_number(
    hessians: List[np.ndarray]
) -> Optional[float]:
    """Compute the Lorentzian condition number.
    
    κ_L = max_norm / min_gap
    
    where max_norm = max_k ||H_k||_op and min_gap = min_k gap(H_k).
    
    A smaller condition number means more robust recognition.
    
    Args:
        hessians: List of symmetric matrices
        
    Returns:
        Condition number, or None if min_gap = 0
    """
    if not hessians:
        return None
    
    min_gap = float('inf')
    max_norm = 0.0
    
    for H in hessians:
        gap, has_sig, _ = compute_spectral_gap(H)
        if not has_sig or gap <= 0:
            return None
        min_gap = min(min_gap, gap)
        max_norm = max(max_norm, np.linalg.norm(H, ord=2))
    
    if min_gap <= 0:
        return None
    
    return max_norm / min_gap


def elementary_symmetric_polynomial_hessian(n: int, k: int, x: np.ndarray = None) -> np.ndarray:
    """Compute the Hessian of the k-th elementary symmetric polynomial.
    
    e_k(x₁,...,xₙ) = ∑_{|S|=k} ∏_{i∈S} xᵢ
    
    The Hessian H_{ij} = ∂²e_k/∂xᵢ∂xⱼ.
    
    Args:
        n: Number of variables
        k: Degree of the elementary symmetric polynomial
        x: Evaluation point (default: all ones)
        
    Returns:
        n × n Hessian matrix
    """
    if x is None:
        x = np.ones(n)
    
    H = np.zeros((n, n))
    if k < 2:
        return H
    
    # H_{ij} = e_{k-2}(x without x_i, x_j) * (product terms)
    # At x = (1,...,1): H_{ij} = C(n-2, k-2) for i ≠ j, 0 for i = j
    if np.allclose(x, np.ones(n)):
        off_diag = comb(n - 2, k - 2)
        for i in range(n):
            for j in range(n):
                if i != j:
                    H[i, j] = off_diag
        return H
    
    # General evaluation point
    indices = list(range(n))
    for i in range(n):
        for j in range(n):
            if i == j:
                continue
            remaining = [idx for idx in indices if idx != i and idx != j]
            if len(remaining) < k - 2:
                continue
            # e_{k-2} over remaining variables
            val = 0.0
            for subset in combinations(remaining, k - 2):
                prod = 1.0
                for idx in subset:
                    prod *= x[idx]
                val += prod
            H[i, j] = val
    
    return H


def verify_perturbation_theorem(
    H: np.ndarray,
    epsilon: float,
    num_trials: int = 1000,
    noise_levels: List[float] = None
) -> Dict[str, List]:
    """Empirically verify the perturbation theorem.
    
    For each noise level δ, generates random symmetric perturbations E with
    ||E||_op ≤ δ and checks whether H + E preserves the Lorentzian signature.
    
    Args:
        H: Original symmetric matrix with gapped Lorentzian signature
        epsilon: Spectral gap of H
        num_trials: Number of random perturbations per noise level
        noise_levels: List of δ values to test (default: geometric sequence)
        
    Returns:
        Dictionary with 'noise_levels', 'preservation_rates', 'certified_bound'
    """
    n = H.shape[0]
    
    if noise_levels is None:
        noise_levels = [epsilon * f for f in 
                       [0.01, 0.05, 0.1, 0.2, 0.5, 0.8, 0.95, 1.0, 1.05, 1.2, 1.5, 2.0, 5.0]]
    
    preservation_rates = []
    
    for delta in noise_levels:
        preserved = 0
        for _ in range(num_trials):
            # Generate random symmetric perturbation with spectral radius ≤ delta
            E = np.random.randn(n, n)
            E = (E + E.T) / 2
            # Scale to have spectral radius exactly delta
            spec_rad = np.max(np.abs(np.linalg.eigvalsh(E)))
            if spec_rad > 0:
                E = E * (delta / spec_rad)
            
            H_pert = H + E
            _, has_sig, _ = compute_spectral_gap(H_pert)
            if has_sig:
                preserved += 1
        
        preservation_rates.append(preserved / num_trials)
    
    return {
        'noise_levels': noise_levels,
        'preservation_rates': preservation_rates,
        'certified_bound': epsilon,  # δ < ε guarantees preservation
        'gap': epsilon
    }


if __name__ == "__main__":
    print("Algorithms for Certified Lorentzian Recognition")
    print("=" * 50)
    
    # Example: e_3(x1,...,x5)
    n, k = 5, 3
    H = elementary_symmetric_polynomial_hessian(n, k)
    print(f"\nHessian of e_{k}(x1,...,x{n}) at x=(1,...,1):")
    print(H)
    
    gap, has_sig, eigenvalues = compute_spectral_gap(H)
    print(f"\nEigenvalues: {eigenvalues}")
    print(f"Lorentzian signature: {has_sig}")
    print(f"Spectral gap: {gap:.4f}")
    
    radius = certify_lorentzian_stability([H])
    print(f"Certified stability radius: {radius:.6f}")
    
    cond = lorentzian_condition_number([H])
    print(f"Condition number: {cond:.4f}")
    
    # Verification
    print("\nVerification experiment:")
    results = verify_perturbation_theorem(H, gap)
    print(f"{'δ/ε':>8} {'Preservation':>15}")
    for delta, rate in zip(results['noise_levels'], results['preservation_rates']):
        print(f"{delta/gap:8.3f} {rate:15.3f}")
