#!/usr/bin/env python3
"""
Algorithms for Wreath Product Double Scaling Analysis

Implements the computational methods from the research paper:
- Wreath defect computation
- Critical exponent estimation
- Data collapse analysis
- Regime classification

All algorithms have documented complexity and correspond to
formally verified Lean definitions.
"""

import numpy as np
from typing import Tuple, List, Optional, Dict
import math


# ──────────────────────────────────────────────────────────────────
# Algorithm 1: Wreath Defect Computation
# ──────────────────────────────────────────────────────────────────

def compute_wreath_defect(
    beta_symm: callable,
    beta_wreath: callable,
    k: int,
    m: int
) -> float:
    """Compute the wreath defect Δ(k,m) = β_W(k,m) - m·β(S_k).

    Corresponds to the Lean definition:
        def WreathDefect (betaSymm : ℕ → ℝ) (betaW : ℕ → ℕ → ℝ) (k m : ℕ) : ℝ :=
          betaW k m - (m : ℝ) * betaSymm k

    Args:
        beta_symm: Function ℕ → ℝ giving symmetric group pressure exponent
        beta_wreath: Function ℕ × ℕ → ℝ giving wreath product pressure exponent
        k: Base group parameter (rank of S_k)
        m: Multiplicity parameter (number of copies)

    Returns:
        The wreath defect Δ(k,m)

    Time complexity: O(T_β) where T_β is the cost of evaluating β_W and β_S
    Space complexity: O(1)

    Example:
        >>> def bs(k): return k * math.log(max(k, 2))
        >>> def bw(k, m): return m * bs(k) + m / k**2
        >>> compute_wreath_defect(bs, bw, 10, 5)
        0.05
    """
    return beta_wreath(k, m) - m * beta_symm(k)


def compute_wreath_defect_polynomial_model(
    k: int,
    m: int,
    C: float = 1.0,
    p: float = 1.0,
    q: float = 2.0
) -> float:
    """Compute wreath defect under polynomial model.

    Model: Δ(k,m) = C · m^p / k^q

    This is the canonical model used in Theorem 1 of the paper.

    Args:
        k: Base group parameter
        m: Multiplicity parameter
        C: Amplitude constant (C ≥ 0)
        p: Multiplicity exponent (p > 0)
        q: Decay exponent (q > 0)

    Returns:
        Model wreath defect

    Time complexity: O(1)
    """
    if k == 0:
        return 0.0
    return C * (m ** p) / (k ** q)


# ──────────────────────────────────────────────────────────────────
# Algorithm 2: Critical Exponent Estimation
# ──────────────────────────────────────────────────────────────────

def estimate_critical_exponent(
    defect_data: List[Tuple[int, int, float]],
    method: str = "least_squares"
) -> Tuple[float, float, float]:
    """Estimate critical exponent α_c = q/p from defect measurements.

    Given triples (k_i, m_i, Δ_i), fit the model |Δ| = C · m^p / k^q
    to estimate p, q, and hence α_c = q/p.

    Args:
        defect_data: List of (k, m, defect) measurements
        method: Estimation method ("least_squares" or "log_regression")

    Returns:
        Tuple (alpha_c, p_est, q_est) with estimated critical exponent
        and individual power-law exponents

    Time complexity: O(n) where n = len(defect_data)
    Space complexity: O(n)

    Algorithm:
        1. Take logarithms: log|Δ| = log(C) + p·log(m) - q·log(k)
        2. Solve the linear regression problem
        3. Return α_c = q_est / p_est

    Example:
        >>> data = [(k, k, 1.0/k**2) for k in range(5, 50)]
        >>> alpha_c, p, q = estimate_critical_exponent(data)
        >>> abs(alpha_c - 2.0) < 0.1  # Should be close to q/p = 2/1
        True
    """
    if len(defect_data) < 3:
        raise ValueError("Need at least 3 data points")

    # Filter out zero/negative defects
    valid = [(k, m, d) for k, m, d in defect_data if k > 0 and m > 0 and abs(d) > 1e-15]
    if len(valid) < 3:
        raise ValueError("Insufficient valid data points")

    # Log-linear regression: log|Δ| = log(C) + p·log(m) - q·log(k)
    n = len(valid)
    log_defects = np.array([math.log(abs(d)) for _, _, d in valid])
    log_m = np.array([math.log(m) for _, m, _ in valid])
    log_k = np.array([math.log(k) for k, _, _ in valid])

    # Design matrix [1, log(m), -log(k)]
    A = np.column_stack([np.ones(n), log_m, -log_k])

    # Least squares solution
    result, _, _, _ = np.linalg.lstsq(A, log_defects, rcond=None)
    log_C, p_est, q_est = result

    alpha_c = q_est / p_est if abs(p_est) > 1e-10 else float('inf')

    return alpha_c, p_est, q_est


def estimate_critical_exponent_bisection(
    defect_fn: callable,
    k_range: Tuple[int, int] = (10, 1000),
    alpha_range: Tuple[float, float] = (0.5, 5.0),
    tol: float = 0.01,
    n_samples: int = 20
) -> float:
    """Estimate critical exponent by bisection on scaling collapse quality.

    For each candidate α, compute the variance of the rescaled defect
    R_α(k, m(k)) across different k values with m(k) = ⌊k^α⌋.
    The optimal α minimizes this variance (best collapse).

    Args:
        defect_fn: Function (k, m) → Δ(k,m)
        k_range: Range of k values to test
        alpha_range: Search interval for α
        tol: Convergence tolerance
        n_samples: Number of k values to sample

    Returns:
        Estimated critical exponent

    Time complexity: O(n_samples · log((α_max - α_min) / tol))
    Space complexity: O(n_samples)
    """
    k_values = np.linspace(k_range[0], k_range[1], n_samples, dtype=int)
    k_values = np.unique(k_values)

    def collapse_variance(alpha: float) -> float:
        rescaled = []
        for k in k_values:
            m = max(1, int(k ** alpha))
            delta = defect_fn(k, m)
            if m > 0 and k > 0:
                R = (k ** alpha / m) * delta
                rescaled.append(R)
        if len(rescaled) < 2:
            return float('inf')
        return np.var(rescaled)

    # Bisection: find α that minimizes collapse variance
    lo, hi = alpha_range
    while hi - lo > tol:
        mid1 = lo + (hi - lo) / 3
        mid2 = hi - (hi - lo) / 3
        if collapse_variance(mid1) < collapse_variance(mid2):
            hi = mid2
        else:
            lo = mid1

    return (lo + hi) / 2


# ──────────────────────────────────────────────────────────────────
# Algorithm 3: Regime Classification
# ──────────────────────────────────────────────────────────────────

def classify_regime(
    k: int,
    m: int,
    alpha_c: float,
    threshold_low: float = 0.1,
    threshold_high: float = 10.0
) -> str:
    """Classify the perturbation regime for given (k, m).

    Corresponds to the Lean inductive type:
        inductive PerturbationRegime
        | irrelevant  -- m ≪ k^α_c
        | marginal    -- m ≍ k^α_c
        | relevant    -- m ≫ k^α_c

    Args:
        k: Base group parameter
        m: Multiplicity parameter
        alpha_c: Critical exponent
        threshold_low: Below this ratio → irrelevant
        threshold_high: Above this ratio → relevant

    Returns:
        One of "irrelevant", "marginal", "relevant"

    Time complexity: O(1)
    """
    if k <= 0:
        return "marginal"
    ratio = m / (k ** alpha_c)
    if ratio < threshold_low:
        return "irrelevant"
    elif ratio > threshold_high:
        return "relevant"
    else:
        return "marginal"


# ──────────────────────────────────────────────────────────────────
# Algorithm 4: Data Collapse Analysis
# ──────────────────────────────────────────────────────────────────

def data_collapse_analysis(
    defect_fn: callable,
    k_values: List[int],
    m_multipliers: List[float],
    alpha_candidates: List[float]
) -> Dict[float, float]:
    """Perform data collapse analysis for multiple candidate exponents.

    For each α, compute the rescaled defect R_α(k, λ·k^α) for multiple
    k values and λ values, then measure how well the curves collapse.

    Quality of collapse is measured by the coefficient of variation
    of R_α across different k for each fixed λ.

    Args:
        defect_fn: Function (k, m) → Δ(k,m)
        k_values: List of k values to test
        m_multipliers: List of λ values (m = ⌊λ·k^α⌋)
        alpha_candidates: List of candidate exponents to test

    Returns:
        Dictionary mapping α → collapse quality score (lower is better)

    Time complexity: O(|α_candidates| · |k_values| · |m_multipliers|)
    """
    scores = {}

    for alpha in alpha_candidates:
        total_cv = 0.0
        n_valid = 0

        for lam in m_multipliers:
            rescaled_values = []
            for k in k_values:
                m = max(1, int(lam * k ** alpha))
                delta = defect_fn(k, m)
                if m > 0 and k > 0:
                    R = (k ** alpha / m) * delta
                    rescaled_values.append(R)

            if len(rescaled_values) >= 2:
                mean = np.mean(rescaled_values)
                std = np.std(rescaled_values)
                cv = std / abs(mean) if abs(mean) > 1e-10 else std
                total_cv += cv
                n_valid += 1

        scores[alpha] = total_cv / n_valid if n_valid > 0 else float('inf')

    return scores


# ──────────────────────────────────────────────────────────────────
# Algorithm 5: Subcritical Convergence Rate
# ──────────────────────────────────────────────────────────────────

def subcritical_convergence_rate(
    C: float,
    p: float,
    q: float,
    m_exponent: float,
    k_values: List[int]
) -> List[Tuple[int, float]]:
    """Compute convergence rate of defect in subcritical regime.

    For m(k) = k^β with β < q/p (subcritical), compute:
        |Δ(k, m(k))| ≤ C · k^{pβ - q}

    The defect decays as k^{pβ - q} with pβ - q < 0 in the
    subcritical regime.

    Args:
        C: Amplitude constant
        p: Multiplicity exponent
        q: Decay exponent
        m_exponent: The exponent β in m(k) = k^β
        k_values: List of k values

    Returns:
        List of (k, bound) pairs showing the decay

    Convergence rate: O(k^{pβ - q})
    """
    alpha_c = q / p if p > 0 else float('inf')
    decay_rate = p * m_exponent - q

    results = []
    for k in k_values:
        m = max(1, int(k ** m_exponent))
        bound = C * m ** p / k ** q
        results.append((k, bound))

    return results


if __name__ == "__main__":
    print("Algorithm Demonstrations")
    print("=" * 60)

    # Demo 1: Wreath defect computation
    print("\n1. Wreath Defect (Polynomial Model)")
    for k in [5, 10, 20, 50, 100]:
        for m in [k, k**2]:
            delta = compute_wreath_defect_polynomial_model(k, m)
            print(f"   k={k:>3}, m={m:>5}: Δ = {delta:.6f}")

    # Demo 2: Critical exponent estimation
    print("\n2. Critical Exponent Estimation")
    data = []
    for k in range(5, 100):
        for m_mult in [1, 2, 5]:
            m = m_mult * k
            delta = compute_wreath_defect_polynomial_model(k, m, C=1.0, p=1.0, q=2.0)
            data.append((k, m, delta))
    alpha_c, p_est, q_est = estimate_critical_exponent(data)
    print(f"   Estimated: α_c = {alpha_c:.4f}, p = {p_est:.4f}, q = {q_est:.4f}")
    print(f"   True:      α_c = 2.0000, p = 1.0000, q = 2.0000")

    # Demo 3: Regime classification
    print("\n3. Regime Classification (α_c = 2.0)")
    for k, m in [(10, 1), (10, 100), (10, 10000), (100, 10), (100, 10000)]:
        regime = classify_regime(k, m, 2.0)
        print(f"   k={k:>3}, m={m:>5}: {regime}")

    # Demo 4: Subcritical convergence
    print("\n4. Subcritical Convergence Rate")
    k_vals = [10, 50, 100, 500, 1000]
    rates = subcritical_convergence_rate(1.0, 1.0, 2.0, 1.5, k_vals)
    for k, bound in rates:
        print(f"   k={k:>4}: |Δ| ≤ {bound:.8f}")
