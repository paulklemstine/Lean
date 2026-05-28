#!/usr/bin/env python3
"""
algorithms.py — Certified Lorentzian Condition Number Algorithms

Implements the algorithmic components of the Lorentzian condition number theory:
1. Spectral data extraction from quadratic leaf Hessians
2. Certified condition number computation
3. Certified perturbation radius computation
4. Contraction surrogate estimation

All algorithms mirror the formally verified Lean implementations.
"""

import numpy as np
from typing import Optional, Tuple, List, NamedTuple


class LeafSpectralData(NamedTuple):
    """Certified spectral data for a single quadratic leaf Hessian.
    
    Mirrors the Lean `LeafSpectralData` structure.
    
    Attributes:
        hessian: The quadratic leaf Hessian matrix
        gap_lower_bound: Certified lower bound on the spectral gap
        op_norm_bound: Certified upper bound on the operator norm
    """
    hessian: np.ndarray
    gap_lower_bound: float
    op_norm_bound: float


def extract_spectral_data(H: np.ndarray, safety_margin: float = 0.99) -> Optional[LeafSpectralData]:
    """Extract certified spectral data from a symmetric matrix.
    
    Computes eigenvalues and returns certified bounds on the spectral gap
    and operator norm. A safety margin < 1 is applied to the gap to account
    for numerical errors in eigenvalue computation.
    
    Args:
        H: Symmetric matrix (quadratic leaf Hessian)
        safety_margin: Factor applied to the computed gap (default 0.99)
    
    Returns:
        LeafSpectralData if the matrix has Lorentzian signature, None otherwise
    
    Complexity: O(n^3) for eigenvalue decomposition
    """
    n = H.shape[0]
    eigenvalues = np.linalg.eigvalsh(H)
    
    # Check Lorentzian signature: at most one positive eigenvalue
    pos_count = np.sum(eigenvalues > 1e-10)
    if pos_count > 1:
        return None
    
    # Compute spectral gap: min |λ| among negative eigenvalues
    neg_eigs = eigenvalues[eigenvalues < -1e-12]
    if len(neg_eigs) == 0:
        return None
    
    gap = float(np.min(np.abs(neg_eigs))) * safety_margin
    op_norm = float(np.max(np.abs(eigenvalues)))
    
    return LeafSpectralData(
        hessian=H.copy(),
        gap_lower_bound=gap,
        op_norm_bound=op_norm
    )


def certify_lorentzian_condition(
    leaves: List[LeafSpectralData]
) -> Optional[float]:
    """Compute a certified Lorentzian condition number bound.
    
    Given spectral data for all quadratic leaves, returns the maximum
    condition ratio opNorm/gap across all leaves.
    
    This mirrors the Lean `certifyLorentzianCondition` function.
    
    Args:
        leaves: List of LeafSpectralData for each quadratic leaf
    
    Returns:
        Certified condition bound κ̂, or None if any leaf has zero gap
    
    Complexity: O(m) where m is the number of leaves
    """
    if not leaves:
        return 1.0
    
    max_ratio = 0.0
    for leaf in leaves:
        if leaf.gap_lower_bound <= 0:
            return None
        ratio = leaf.op_norm_bound / leaf.gap_lower_bound
        max_ratio = max(max_ratio, ratio)
    
    return max_ratio


def certified_perturbation_radius(
    leaves: List[LeafSpectralData],
    entry_to_quadform_factor: Optional[float] = None
) -> float:
    """Compute the certified perturbation radius.
    
    For quadratic form perturbations: radius = min_gap across leaves.
    For entry-norm perturbations: radius = min_gap / n^2.
    
    Args:
        leaves: List of LeafSpectralData
        entry_to_quadform_factor: If provided, converts entry bound to
            quadratic form bound (typically n^2). If None, returns the
            quadratic-form-level radius.
    
    Returns:
        Certified perturbation radius
    """
    if not leaves:
        return 0.0
    
    min_gap = min(leaf.gap_lower_bound for leaf in leaves)
    
    if entry_to_quadform_factor is not None:
        return min_gap / entry_to_quadform_factor
    return min_gap


def local_contraction_surrogate(gap: float, op_norm: float) -> float:
    """Compute the local contraction surrogate gap/opNorm.
    
    This quantity bounds the one-step contraction rate of local
    update Markov chains and serves as a curvature proxy for
    Bakry-Émery type arguments.
    
    Mirrors the Lean `LocalContractionSurrogate` definition.
    
    Args:
        gap: Spectral gap (positive)
        op_norm: Operator norm bound (positive)
    
    Returns:
        Contraction surrogate value
    """
    if op_norm <= 0:
        return 0.0
    return gap / op_norm


def uniform_matroid_leaf_hessian(m: int) -> np.ndarray:
    """Construct the canonical leaf Hessian J - I for U_{r,m}.
    
    For the uniform matroid, every quadratic leaf is permutation-equivalent
    to this canonical form.
    
    Args:
        m: Number of remaining variables (= n - r + 2)
    
    Returns:
        m × m matrix J - I
    """
    return np.ones((m, m)) - np.eye(m)


def analyze_uniform_matroid(m: int) -> dict:
    """Complete analysis of the uniform matroid U_{r,m}.
    
    Computes all spectral invariants and certified bounds.
    
    Args:
        m: Number of variables in the quadratic leaf
    
    Returns:
        Dictionary with all computed quantities
    """
    H = uniform_matroid_leaf_hessian(m)
    data = extract_spectral_data(H, safety_margin=1.0)
    
    if data is None:
        return {"error": "Failed to extract spectral data"}
    
    kappa = certify_lorentzian_condition([data])
    radius_qf = certified_perturbation_radius([data])
    radius_entry = certified_perturbation_radius([data], entry_to_quadform_factor=m**2)
    contraction = local_contraction_surrogate(data.gap_lower_bound, data.op_norm_bound)
    
    return {
        "m": m,
        "eigenvalues": sorted(np.linalg.eigvalsh(H))[::-1],
        "spectral_gap": data.gap_lower_bound,
        "operator_norm": data.op_norm_bound,
        "condition_number": kappa,
        "quadform_radius": radius_qf,
        "entry_norm_radius": radius_entry,
        "theoretical_entry_radius": 1.0 / m**2,
        "contraction_surrogate": contraction,
        "contraction_theoretical": 1.0 / m,
    }


if __name__ == "__main__":
    print("Uniform Matroid Analysis")
    print("=" * 60)
    
    for m in [3, 5, 8, 10, 15, 20]:
        result = analyze_uniform_matroid(m)
        print(f"\nm = {m}:")
        for key, value in result.items():
            if key == "eigenvalues":
                print(f"  {key}: [{', '.join(f'{v:.2f}' for v in value[:5])}{'...' if len(value) > 5 else ''}]")
            elif isinstance(value, float):
                print(f"  {key}: {value:.6f}")
            else:
                print(f"  {key}: {value}")
