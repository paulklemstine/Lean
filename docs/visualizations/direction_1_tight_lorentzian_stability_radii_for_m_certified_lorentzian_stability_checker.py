#!/usr/bin/env python3
"""
Algorithms for Lorentzian Stability Analysis of Uniform Matroids

This module implements the core algorithms for computing and certifying
Lorentzian stability radii for uniform matroid generating polynomials.

The algorithms are based on the spectral theory developed in the formal
verification, specifically:
1. Canonical leaf Hessian computation (J - I decomposition)
2. Spectral gap certification via quadratic form decomposition  
3. Perturbation threshold estimation via binary search
4. Certified stability checking

Complexity:
- Leaf Hessian computation: O(m²) where m = n - r + 2
- Spectral gap computation: O(m³) via eigendecomposition (O(1) via formula)
- Stability certification: O(m²) per perturbation check
- Binary search for threshold: O(m³ · log(1/ε)) for ε-accuracy
"""

import numpy as np
from typing import Tuple, Dict, List, Optional
from math import comb
from dataclasses import dataclass


@dataclass
class SpectralAnalysis:
    """Complete spectral analysis of a leaf Hessian."""
    dimension: int
    positive_eigenvalue: float
    negative_eigenvalue: float
    pos_multiplicity: int
    neg_multiplicity: int
    spectral_gap: float
    normalized_gap: float
    is_lorentzian: bool


@dataclass  
class StabilityResult:
    """Result of a stability radius computation."""
    n: int
    r: int
    m: int
    theoretical_gap: float
    empirical_diagonal_radius: float
    empirical_random_radius: float
    entry_bound_radius: float
    amgm_bound_radius: float


def canonical_leaf_hessian(m: int) -> np.ndarray:
    """Compute the canonical leaf Hessian J - I for e₂ on m variables.
    
    The Hessian of e₂(x₁,...,xₘ) = Σ_{i<j} xᵢxⱼ is:
    - H[i,j] = 1 if i ≠ j
    - H[i,i] = 0
    
    This equals J - I, where J is the all-ones matrix.
    
    Complexity: O(m²)
    
    Args:
        m: Number of variables
        
    Returns:
        m × m Hessian matrix
    """
    return np.ones((m, m)) - np.eye(m)


def quadratic_form_decomposition(v: np.ndarray) -> Tuple[float, float, float]:
    """Decompose Q_{J-I}(v) = (Σ vᵢ)² - Σ vᵢ² into components.
    
    This is the key algebraic identity connecting the Hessian to
    symmetric function theory.
    
    Complexity: O(m)
    
    Args:
        v: Input vector
        
    Returns:
        (total_sum_sq, norm_sq, quadratic_form_value)
    """
    total_sum_sq = np.sum(v) ** 2
    norm_sq = np.sum(v ** 2)
    return total_sum_sq, norm_sq, total_sum_sq - norm_sq


def exact_spectral_analysis(m: int) -> SpectralAnalysis:
    """Compute exact spectral analysis of the leaf Hessian.
    
    For J - I on m variables:
    - Eigenvalues: m-1 (mult 1) and -1 (mult m-1)
    - Spectral gap: 1
    - Normalized gap: 1/(m-1)
    
    Complexity: O(1) (closed-form formulas)
    
    Args:
        m: Number of variables (must be ≥ 2)
        
    Returns:
        SpectralAnalysis with exact values
    """
    if m < 2:
        return SpectralAnalysis(
            dimension=m,
            positive_eigenvalue=0,
            negative_eigenvalue=0,
            pos_multiplicity=0,
            neg_multiplicity=0,
            spectral_gap=0,
            normalized_gap=float('inf'),
            is_lorentzian=True
        )
    
    return SpectralAnalysis(
        dimension=m,
        positive_eigenvalue=m - 1,
        negative_eigenvalue=-1,
        pos_multiplicity=1,
        neg_multiplicity=m - 1,
        spectral_gap=1.0,
        normalized_gap=1.0 / (m - 1),
        is_lorentzian=True
    )


def certify_lorentzian_stability(
    m: int,
    perturbation_entries: np.ndarray,
    method: str = 'amgm'
) -> Tuple[bool, float]:
    """Certify that a perturbation preserves Lorentzianity.
    
    Uses the entry-to-quadform bound to convert entry-wise bounds
    to spectral gap comparison.
    
    Methods:
    - 'crude': Uses |Q_E(v)| ≤ m² · max|E_ij| · ||v||²
    - 'amgm': Uses tighter |Q_E(v)| ≤ m · max|E_ij| · ||v||² (AM-GM)
    - 'exact': Computes actual operator norm via eigendecomposition
    
    Complexity: O(m²) for entry bound, O(m³) for exact
    
    Args:
        m: Dimension
        perturbation_entries: m × m perturbation matrix entries
        method: Certification method
        
    Returns:
        (is_certified, bound_value) where bound_value < 1 means certified
    """
    max_entry = np.max(np.abs(perturbation_entries))
    
    if method == 'crude':
        bound = m ** 2 * max_entry
    elif method == 'amgm':
        bound = m * max_entry
    elif method == 'exact':
        eigenvalues = np.linalg.eigvalsh(perturbation_entries)
        bound = max(abs(eigenvalues[0]), abs(eigenvalues[-1]))
    else:
        raise ValueError(f"Unknown method: {method}")
    
    return bound < 1.0, bound


def binary_search_stability_radius(
    m: int,
    perturbation_generator,
    tol: float = 1e-8,
    max_iter: int = 100
) -> float:
    """Binary search for the stability radius with a given perturbation family.
    
    Complexity: O(max_iter · T_gen · m³) where T_gen is the generator cost
    
    Args:
        m: Dimension
        perturbation_generator: Function t -> perturbation matrix of "size" t
        tol: Convergence tolerance
        max_iter: Maximum iterations
        
    Returns:
        Estimated stability radius
    """
    H = canonical_leaf_hessian(m)
    lo, hi = 0.0, 10.0
    
    for _ in range(max_iter):
        if hi - lo < tol:
            break
        mid = (lo + hi) / 2
        E = perturbation_generator(mid)
        
        eigenvalues = np.linalg.eigvalsh(H + E)
        n_positive = np.sum(eigenvalues > 1e-12)
        
        if n_positive <= 1:
            lo = mid
        else:
            hi = mid
    
    return (lo + hi) / 2


def diagonal_perturbation(t: float, m: int) -> np.ndarray:
    """Generate diagonal perturbation t·I."""
    return t * np.eye(m)


def rank_one_perturbation(t: float, m: int) -> np.ndarray:
    """Generate rank-one perturbation t·(e₁e₁ᵀ - e₂e₂ᵀ).
    
    This is a symmetry-breaking perturbation that pushes one eigenvalue
    while pulling another.
    """
    E = np.zeros((m, m))
    E[0, 0] = t
    if m > 1:
        E[1, 1] = -t
    return E


def comprehensive_stability_analysis(n: int, r: int) -> StabilityResult:
    """Run comprehensive stability analysis for U_{r,n}.
    
    Complexity: O(m³ · log(1/tol))
    
    Args:
        n: Total variables
        r: Matroid rank (2 ≤ r ≤ n-2)
        
    Returns:
        StabilityResult with all computed values
    """
    m = n - r + 2
    
    # Theoretical gap
    theoretical_gap = 1.0
    
    # Entry bounds
    entry_bound = 1.0 / m ** 2
    amgm_bound = 1.0 / m
    
    # Empirical search with diagonal perturbation
    emp_diag = binary_search_stability_radius(
        m, lambda t: diagonal_perturbation(t, m))
    
    # Empirical search with random symmetric perturbation (averaged)
    np.random.seed(42)
    emp_random_vals = []
    for _ in range(10):
        R = np.random.randn(m, m)
        R = (R + R.T) / 2
        R_norm = np.max(np.abs(np.linalg.eigvalsh(R)))
        if R_norm > 0:
            emp = binary_search_stability_radius(
                m, lambda t, R=R, norm=R_norm: t / norm * R)
            emp_random_vals.append(emp)
    emp_random = np.mean(emp_random_vals) if emp_random_vals else 0
    
    return StabilityResult(
        n=n, r=r, m=m,
        theoretical_gap=theoretical_gap,
        empirical_diagonal_radius=emp_diag,
        empirical_random_radius=emp_random,
        entry_bound_radius=entry_bound,
        amgm_bound_radius=amgm_bound
    )


def compute_all_stability_data(max_n: int = 15) -> List[StabilityResult]:
    """Compute stability data for all valid (n, r) with n ≤ max_n.
    
    Args:
        max_n: Maximum n value
        
    Returns:
        List of StabilityResult for all valid parameters
    """
    results = []
    for n in range(4, max_n + 1):
        for r in range(2, n - 1):
            result = comprehensive_stability_analysis(n, r)
            results.append(result)
    return results


if __name__ == "__main__":
    print("Lorentzian Stability Algorithms")
    print("=" * 50)
    print()
    
    # Example: U_{3,7}
    result = comprehensive_stability_analysis(7, 3)
    print(f"U_{{3,7}}: m={result.m}")
    print(f"  Theoretical gap: {result.theoretical_gap}")
    print(f"  Diagonal radius: {result.empirical_diagonal_radius:.6f}")
    print(f"  Random radius: {result.empirical_random_radius:.6f}")
    print(f"  Entry bound (1/m²): {result.entry_bound_radius:.6f}")
    print(f"  AM-GM bound (1/m): {result.amgm_bound_radius:.6f}")
    print()
    
    # Spectral analysis
    spec = exact_spectral_analysis(6)
    print(f"Spectral analysis for m=6:")
    print(f"  Eigenvalues: {spec.positive_eigenvalue} (×{spec.pos_multiplicity}), "
          f"{spec.negative_eigenvalue} (×{spec.neg_multiplicity})")
    print(f"  Gap: {spec.spectral_gap}")
    print(f"  Normalized gap: {spec.normalized_gap:.6f}")
    print()
    
    # Certification example
    E = 0.01 * np.random.randn(6, 6)
    E = (E + E.T) / 2
    certified, bound = certify_lorentzian_stability(6, E, method='exact')
    print(f"Certification of random perturbation (max entry {np.max(np.abs(E)):.4f}):")
    print(f"  Certified: {certified}, bound: {bound:.6f}")
