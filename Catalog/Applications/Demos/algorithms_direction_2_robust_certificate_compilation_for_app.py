#!/usr/bin/env python3
"""
Algorithms for Robust Certificate Compilation

Implements the certified fidelity estimation pipeline:
1. Given approximate weight vector w and reference Lorentzian family v,
   compute TV distance and produce certified fidelity lower bound.
2. Condition-number-aware bounds using mass lower bounds.
3. Nearest Lorentzian projection (heuristic) for weight vectors.

Complexity:
- Fidelity certification: O(n) time, O(n) space
- Nearest log-concave projection: O(n log n) time
- Full certification pipeline: O(n log n) time
"""

import numpy as np
from math import comb
from typing import Tuple, Optional, NamedTuple


class CertificationResult(NamedTuple):
    """Result of robust certificate compilation."""
    fidelity_lower_bound: float       # Certified lower bound on fidelity
    tv_distance: float                # TV distance between w and reference
    l2_distance: float                # ℓ² distance between w and reference
    condition_number: float           # Effective condition number
    actual_fidelity: Optional[float]  # Actual fidelity (if computed)
    is_certified: bool                # Whether bound is nontrivial (> 0)


def l2_norm_sq(w: np.ndarray) -> float:
    """ℓ² norm squared: ∑ wᵢ²"""
    return float(np.sum(w**2))


def l2_norm(w: np.ndarray) -> float:
    """ℓ² norm: √(∑ wᵢ²)"""
    return float(np.sqrt(l2_norm_sq(w)))


def tv_distance(w: np.ndarray, v: np.ndarray) -> float:
    """Total variation distance: (1/2) ∑|wᵢ - vᵢ|"""
    return float(0.5 * np.sum(np.abs(w - v)))


def normalized_vec(w: np.ndarray) -> np.ndarray:
    """Normalize to unit ℓ² vector."""
    norm = l2_norm(w)
    if norm < 1e-15:
        return np.zeros_like(w)
    return w / norm


def compute_fidelity(w: np.ndarray, v: np.ndarray) -> float:
    """Compute exact fidelity between nonneg weight vectors.
    
    F(w,v) = (∑ ψ_w(i) · ψ_v(i))²
    where ψ_w = w/‖w‖₂.
    
    Time: O(n), Space: O(n)
    """
    psi_w = normalized_vec(w)
    psi_v = normalized_vec(v)
    return float(np.sum(psi_w * psi_v)**2)


def certify_fidelity_l2(
    w: np.ndarray,
    v: np.ndarray
) -> CertificationResult:
    """Certify fidelity using ℓ² perturbation bound.
    
    Theorem (fidelity_bound_from_perturbation):
        F(w,v) ≥ 1 - 4·‖w-v‖₂² / min(‖w‖₂, ‖v‖₂)²
    
    Time: O(n), Space: O(n)
    
    Args:
        w: Approximate weight vector (nonneg)
        v: Reference weight vector (nonneg)
    
    Returns:
        CertificationResult with certified lower bound
    """
    assert np.all(w >= -1e-10) and np.all(v >= -1e-10), "Weights must be nonneg"
    w = np.maximum(w, 0.0)
    v = np.maximum(v, 0.0)
    
    norm_w = l2_norm(w)
    norm_v = l2_norm(v)
    min_norm = min(norm_w, norm_v)
    
    if min_norm < 1e-15:
        return CertificationResult(
            fidelity_lower_bound=0.0,
            tv_distance=tv_distance(w, v),
            l2_distance=l2_norm(w - v),
            condition_number=float('inf'),
            actual_fidelity=None,
            is_certified=False
        )
    
    l2_dist = l2_norm(w - v)
    tv_dist = tv_distance(w, v)
    bound = 1.0 - 4.0 * l2_dist**2 / min_norm**2
    cond = 2.0 / min_norm  # Lipschitz constant of normalization
    actual = compute_fidelity(w, v)
    
    return CertificationResult(
        fidelity_lower_bound=max(bound, 0.0),
        tv_distance=tv_dist,
        l2_distance=l2_dist,
        condition_number=cond,
        actual_fidelity=actual,
        is_certified=bound > 0
    )


def certify_fidelity_tv(
    w: np.ndarray,
    v: np.ndarray
) -> CertificationResult:
    """Certify fidelity using TV distance bound.
    
    Theorem (fidelity_bound_from_tv):
        F(w,v) ≥ 1 - 16·TV(w,v)² / min(‖w‖₂, ‖v‖₂)²
    
    Time: O(n), Space: O(n)
    """
    assert np.all(w >= -1e-10) and np.all(v >= -1e-10)
    w = np.maximum(w, 0.0)
    v = np.maximum(v, 0.0)
    
    norm_w = l2_norm(w)
    norm_v = l2_norm(v)
    min_norm = min(norm_w, norm_v)
    
    if min_norm < 1e-15:
        return CertificationResult(0.0, tv_distance(w, v), l2_norm(w - v),
                                   float('inf'), None, False)
    
    tv_dist = tv_distance(w, v)
    l2_dist = l2_norm(w - v)
    bound = 1.0 - 16.0 * tv_dist**2 / min_norm**2
    cond = 4.0 / min_norm
    actual = compute_fidelity(w, v)
    
    return CertificationResult(
        fidelity_lower_bound=max(bound, 0.0),
        tv_distance=tv_dist,
        l2_distance=l2_dist,
        condition_number=cond,
        actual_fidelity=actual,
        is_certified=bound > 0
    )


def certify_fidelity_mass(
    w: np.ndarray,
    v: np.ndarray,
    mass_lower_bound: float
) -> CertificationResult:
    """Certify fidelity using mass-based condition number.
    
    Theorem (fidelity_bound_from_mass):
        If ∑w ≥ m and ∑v ≥ m, then
        F(w,v) ≥ 1 - 4n·‖w-v‖₂² / m²
    
    Time: O(n), Space: O(n)
    
    Args:
        w, v: Nonneg weight vectors
        mass_lower_bound: Lower bound m on total mass of both vectors
    """
    assert np.all(w >= -1e-10) and np.all(v >= -1e-10)
    w = np.maximum(w, 0.0)
    v = np.maximum(v, 0.0)
    
    n = len(w)
    m = mass_lower_bound
    
    assert np.sum(w) >= m - 1e-10 and np.sum(v) >= m - 1e-10, \
        f"Mass lower bound {m} violated: ∑w={np.sum(w):.4f}, ∑v={np.sum(v):.4f}"
    
    if m <= 0:
        return CertificationResult(0.0, tv_distance(w, v), l2_norm(w - v),
                                   float('inf'), None, False)
    
    l2_dist = l2_norm(w - v)
    tv_dist = tv_distance(w, v)
    bound = 1.0 - 4.0 * n * l2_dist**2 / m**2
    cond = 2.0 * np.sqrt(n) / m
    actual = compute_fidelity(w, v)
    
    return CertificationResult(
        fidelity_lower_bound=max(bound, 0.0),
        tv_distance=tv_dist,
        l2_distance=l2_dist,
        condition_number=cond,
        actual_fidelity=actual,
        is_certified=bound > 0
    )


def nearest_log_concave_projection(w: np.ndarray) -> np.ndarray:
    """Project a nonneg vector onto the set of log-concave sequences.
    
    Uses the pool-adjacent-violators algorithm adapted for log-concavity.
    This is a heuristic — the exact projection is NP-hard in general.
    
    Time: O(n log n), Space: O(n)
    
    Args:
        w: Nonneg weight vector
    
    Returns:
        Nearest log-concave nonneg vector (approximate)
    """
    n = len(w)
    if n <= 2:
        return w.copy()
    
    result = w.copy()
    
    # Iterative smoothing to enforce log-concavity
    for _ in range(100):
        changed = False
        for k in range(1, n - 1):
            if result[k] > 0 and result[k-1] > 0 and result[k+1] > 0:
                # Check log-concavity: a[k]² ≥ a[k-1] * a[k+1]
                if result[k]**2 < result[k-1] * result[k+1]:
                    # Adjust to restore log-concavity
                    geometric_mean = np.sqrt(result[k-1] * result[k+1])
                    result[k] = geometric_mean
                    changed = True
        if not changed:
            break
    
    return result


def full_certification_pipeline(
    w: np.ndarray,
    reference: Optional[np.ndarray] = None
) -> Tuple[CertificationResult, np.ndarray]:
    """Full robust certificate compilation pipeline.
    
    1. If no reference given, project w onto log-concave sequences.
    2. Compute TV distance to reference.
    3. Return certified fidelity lower bound.
    
    Time: O(n log n), Space: O(n)
    
    Args:
        w: Approximate nonneg weight vector
        reference: Optional exact reference (if None, uses projection)
    
    Returns:
        (certification_result, reference_vector)
    """
    w = np.maximum(w, 0.0)
    
    if reference is None:
        reference = nearest_log_concave_projection(w)
    
    result = certify_fidelity_l2(w, reference)
    return result, reference


# ─────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("="*60)
    print("Robust Certificate Compilation Algorithms")
    print("="*60)
    
    # Example 1: Binomial family with perturbation
    n = 10
    exact = np.array([comb(n, k) for k in range(n+1)], dtype=float)
    
    for eps in [0.01, 0.1, 1.0, 5.0]:
        rng = np.random.RandomState(42)
        noise = rng.exponential(1.0, size=len(exact))
        noise = noise / np.sum(noise) * eps
        approx = exact + noise
        
        result = certify_fidelity_l2(approx, exact)
        print(f"\nε = {eps:.2f}:")
        print(f"  TV distance:    {result.tv_distance:.6f}")
        print(f"  ℓ² distance:    {result.l2_distance:.6f}")
        print(f"  Fidelity bound: {result.fidelity_lower_bound:.8f}")
        print(f"  Actual fidelity:{result.actual_fidelity:.8f}")
        print(f"  Cond. number:   {result.condition_number:.4f}")
        print(f"  Certified:      {result.is_certified}")
    
    # Example 2: Mass-based certification
    print("\n" + "-"*60)
    print("Mass-based certification:")
    m = float(np.sum(exact)) * 0.9  # 90% mass guarantee
    result_mass = certify_fidelity_mass(approx, exact, m)
    print(f"  Mass lower bound: {m:.1f}")
    print(f"  Fidelity bound:   {result_mass.fidelity_lower_bound:.8f}")
    print(f"  Actual fidelity:  {result_mass.actual_fidelity:.8f}")
    
    # Example 3: Full pipeline with automatic reference
    print("\n" + "-"*60)
    print("Full pipeline (automatic log-concave reference):")
    noisy = exact + np.random.RandomState(0).exponential(2.0, size=len(exact))
    result_full, ref = full_certification_pipeline(noisy)
    print(f"  Input:     {noisy[:5]}...")
    print(f"  Reference: {ref[:5]}...")
    print(f"  TV dist:   {result_full.tv_distance:.6f}")
    print(f"  Fidelity bound: {result_full.fidelity_lower_bound:.8f}")
