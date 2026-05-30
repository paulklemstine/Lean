"""
Algorithms for Double Scaling Limit Analysis

Implements the core algorithms for computing and analyzing wreath product
subgroup pressure, critical scaling exponents, and phase classification.
"""
import numpy as np
from typing import Tuple, List, Optional


def compute_wreath_defect(
    beta_symm: callable,
    beta_wreath: callable,
    k: int,
    m: int
) -> float:
    """
    Compute the wreath defect Δ(k,m) = β_W(k,m) - m·β(S_k).
    
    Args:
        beta_symm: Function k -> β(S_k) (symmetric group critical exponent)
        beta_wreath: Function (k,m) -> β_W(k,m) (wreath product critical exponent)
        k: Base group parameter
        m: Number of copies
    
    Returns:
        The wreath defect Δ(k,m)
    
    Example:
        >>> compute_wreath_defect(lambda k: k*0.5, lambda k,m: m*k*0.5 + 0.1, 5, 3)
        0.1
    """
    return beta_wreath(k, m) - m * beta_symm(k)


def classify_scaling(
    mf: callable,
    alpha: float,
    k_values: List[int],
    threshold: float = 0.1
) -> str:
    """
    Classify a scaling sequence m(k) relative to k^α.
    
    Args:
        mf: Function k -> m(k) (the scaling sequence)
        alpha: Critical exponent to test against
        k_values: List of k values to evaluate
        threshold: Threshold for classifying (default 0.1)
    
    Returns:
        One of 'subcritical', 'critical', 'supercritical'
    
    Example:
        >>> classify_scaling(lambda k: int(k**0.5), 1.0, list(range(10, 100)))
        'subcritical'
    """
    ratios = []
    for k in k_values:
        m = mf(k)
        if k > 0:
            ratio = m / k**alpha
            ratios.append(ratio)
    
    if not ratios:
        return 'subcritical'
    
    # Check if ratios tend to 0, a constant, or infinity
    late_ratios = ratios[len(ratios)//2:]  # second half
    mean_late = np.mean(late_ratios)
    
    if mean_late < threshold:
        return 'subcritical'
    elif mean_late > 1.0 / threshold:
        return 'supercritical'
    else:
        return 'critical'


def find_critical_exponent(
    beta_symm: callable,
    beta_wreath: callable,
    k_range: Tuple[int, int] = (5, 50),
    m_range: Tuple[int, int] = (1, 200),
    alpha_range: Tuple[float, float] = (0.1, 3.0),
    n_alpha: int = 50
) -> Tuple[float, float]:
    """
    Estimate the critical exponent α by data collapse.
    
    For each candidate α, compute the rescaled defect
    |Δ(k,m)| · k^α / m and measure how well it collapses
    across different (k,m) values.
    
    Args:
        beta_symm: Function k -> β(S_k)
        beta_wreath: Function (k,m) -> β_W(k,m)
        k_range: Range of k values to test
        m_range: Range of m values
        alpha_range: Range of α to scan
        n_alpha: Number of α values to test
    
    Returns:
        (best_alpha, min_cv): Best critical exponent and its coefficient of variation
    
    Example:
        >>> bs = lambda k: k * 0.5
        >>> bw = lambda k, m: m * k * 0.5 + 0.3 * m / k
        >>> alpha, cv = find_critical_exponent(bs, bw)
    """
    alphas = np.linspace(alpha_range[0], alpha_range[1], n_alpha)
    best_alpha = alphas[0]
    min_cv = float('inf')
    
    for alpha in alphas:
        rescaled_values = []
        for k in range(k_range[0], k_range[1]):
            for m in range(max(1, m_range[0]), min(m_range[1], k*k)):
                delta = compute_wreath_defect(beta_symm, beta_wreath, k, m)
                if m > 0:
                    rescaled = abs(delta) * k**alpha / m
                    rescaled_values.append(rescaled)
        
        if len(rescaled_values) > 2:
            mean = np.mean(rescaled_values)
            std = np.std(rescaled_values)
            cv = std / mean if mean > 0 else float('inf')
            
            if cv < min_cv:
                min_cv = cv
                best_alpha = alpha
    
    return best_alpha, min_cv


def polynomial_defect_envelope(
    C0: float,
    gamma: float,
    k: int,
    m: int
) -> float:
    """
    Compute the polynomial defect envelope C₀ · m^γ / k.
    
    Args:
        C0: Base constant
        gamma: Growth exponent
        k: Base group parameter
        m: Number of copies
    
    Returns:
        Upper bound on |Δ(k,m)|
    
    Example:
        >>> polynomial_defect_envelope(0.5, 1.0, 10, 5)
        0.25
    """
    if k <= 0:
        return float('inf')
    return C0 * m**gamma / k


def critical_scaling_function(alpha: float, k: int) -> int:
    """
    Compute m*(k) = ⌊k^α⌋.
    
    Args:
        alpha: Critical exponent
        k: Base group parameter
    
    Returns:
        Critical scaling threshold m*(k)
    
    Example:
        >>> critical_scaling_function(1.0, 10)
        10
        >>> critical_scaling_function(0.5, 100)
        10
    """
    return int(np.floor(k**alpha))


def verify_trichotomy(
    beta_symm: callable,
    beta_wreath: callable,
    alpha: float,
    k_values: List[int]
) -> dict:
    """
    Verify the sharp trichotomy theorem numerically.
    
    Tests three sequences:
    - Subcritical: m(k) = ⌊k^(α/2)⌋ 
    - Critical: m(k) = ⌊k^α⌋
    - Supercritical: m(k) = ⌊k^(2α)⌋
    
    Args:
        beta_symm: Function k -> β(S_k)
        beta_wreath: Function (k,m) -> β_W(k,m)
        alpha: Critical exponent
        k_values: k values to test
    
    Returns:
        Dictionary with defect sequences for each regime
    """
    results = {
        'subcritical': [],
        'critical': [],
        'supercritical': []
    }
    
    for k in k_values:
        # Subcritical
        m_sub = max(1, int(k**(alpha/2)))
        delta_sub = compute_wreath_defect(beta_symm, beta_wreath, k, m_sub)
        results['subcritical'].append(abs(delta_sub))
        
        # Critical
        m_crit = max(1, int(k**alpha))
        delta_crit = compute_wreath_defect(beta_symm, beta_wreath, k, m_crit)
        results['critical'].append(abs(delta_crit))
        
        # Supercritical
        m_super = max(1, int(k**(2*alpha)))
        delta_super = compute_wreath_defect(beta_symm, beta_wreath, k, m_super)
        results['supercritical'].append(abs(delta_super))
    
    return results


def defect_accumulation_bound(
    delta_per_copy: float,
    m: int
) -> float:
    """
    Compute the inductive defect accumulation bound: m · δ.
    
    By Theorem 6, if each copy adds at most δ to the defect,
    then after m copies the total defect is at most m · δ.
    
    Args:
        delta_per_copy: Maximum defect per additional copy
        m: Number of copies
    
    Returns:
        Upper bound on total defect
    """
    return m * delta_per_copy


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    # Define model functions
    def bs(k):
        return k * np.log(max(k, 2)) / 2
    
    def bw(k, m):
        gamma = 1.0
        C0 = 0.5
        defect = C0 * m**gamma / max(k, 1) * (0.5 + 0.3 * np.sin(k + m))
        return m * bs(k) + defect
    
    # Find critical exponent
    print("Finding critical exponent by data collapse...")
    alpha_est, cv = find_critical_exponent(bs, bw, k_range=(5, 30))
    print(f"  Best α = {alpha_est:.3f} (CV = {cv:.4f})")
    print()
    
    # Verify trichotomy
    print("Verifying trichotomy at α = 1.0...")
    k_vals = list(range(5, 51))
    tri = verify_trichotomy(bs, bw, 1.0, k_vals)
    
    for regime in ['subcritical', 'critical', 'supercritical']:
        vals = tri[regime]
        trend = "→ 0" if vals[-1] < vals[0] * 0.5 else "→ ∞" if vals[-1] > vals[0] * 2 else "~ const"
        print(f"  {regime:>15}: final |Δ| = {vals[-1]:.4f}, trend: {trend}")
    
    print()
    print("Classification examples:")
    for mf_desc, mf in [("m=√k", lambda k: int(k**0.5)),
                         ("m=k", lambda k: k),
                         ("m=k²", lambda k: k*k)]:
        phase = classify_scaling(mf, 1.0, list(range(10, 100)))
        print(f"  {mf_desc:>8} → {phase}")
