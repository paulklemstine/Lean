#!/usr/bin/env python3
"""
algorithms.py — Algorithms for wreath-product subgroup pressure analysis.

Implements the core computational methods from the research paper:
1. Wreath defect computation
2. Critical exponent estimation via regression
3. Regime classification
4. Crossover profile estimation
5. Polynomial envelope fitting

All functions include docstrings, type hints, and example usage.
"""

import numpy as np
from typing import Callable, Tuple, List, Optional


def beta_symm_model(k: int) -> float:
    """Model symmetric group pressure β(S_k).

    Uses the asymptotic approximation β(S_k) ≈ k·log(k+1),
    which captures the leading-order subgroup growth behavior.

    Args:
        k: Order parameter of the symmetric group S_k.

    Returns:
        Estimated subgroup pressure.

    Example:
        >>> beta_symm_model(5)
        8.9588...
    """
    if k <= 0:
        return 0.0
    return k * np.log(k + 1)


def wreath_defect_model(k: int, m: int, C: float = 1.0,
                         a: int = 1, b: int = 1) -> float:
    """Compute the wreath defect using the polynomial envelope model.

    The defect is Δ(k,m) = C·m^a/k^b, which is the simplest model
    satisfying the polynomial defect envelope.

    Args:
        k: Internal symmetry parameter.
        m: Number of copies / multiplicity.
        C: Envelope constant (C > 0).
        a: Exponent of m in the envelope.
        b: Exponent of k in the envelope.

    Returns:
        The wreath defect Δ(k,m).

    Example:
        >>> wreath_defect_model(10, 5)
        0.5
    """
    if k <= 0:
        return 0.0
    return C * (m ** a) / (k ** b)


def estimate_critical_exponent(k_values: np.ndarray, m_values: np.ndarray,
                                 defect_values: np.ndarray) -> Tuple[float, float, float]:
    """Estimate the critical exponent α_c = b/a from defect data.

    Fits the model log|Δ| = log(C) + a·log(m) - b·log(k) using
    ordinary least squares regression.

    Args:
        k_values: Array of k values (shape N,).
        m_values: Array of m values (shape N,).
        defect_values: Array of |Δ(k,m)| values (shape N,).

    Returns:
        Tuple (a_est, b_est, alpha_c_est) where alpha_c = b/a.

    Complexity:
        O(N) for N data points.

    Example:
        >>> k = np.array([5, 10, 20, 40])
        >>> m = np.array([3, 6, 12, 24])
        >>> delta = 1.0 * m / k  # a=1, b=1
        >>> a_est, b_est, alpha_c = estimate_critical_exponent(k, m, delta)
        >>> abs(alpha_c - 1.0) < 0.01
        True
    """
    # Filter out zero or negative defects
    mask = defect_values > 0
    log_delta = np.log(defect_values[mask])
    log_k = np.log(k_values[mask].astype(float))
    log_m = np.log(m_values[mask].astype(float))

    # Design matrix: [1, log_m, -log_k]
    A = np.column_stack([np.ones_like(log_m), log_m, -log_k])
    # Solve least squares: log|Δ| = log(C) + a·log(m) - b·log(k)
    result = np.linalg.lstsq(A, log_delta, rcond=None)
    coeffs = result[0]

    log_C = coeffs[0]
    a_est = coeffs[1]
    b_est = coeffs[2]

    alpha_c = b_est / a_est if a_est != 0 else float('inf')
    return a_est, b_est, alpha_c


def classify_scaling_regime(k_values: np.ndarray,
                             m_func: Callable[[int], int],
                             alpha_c: float,
                             threshold_low: float = 0.01,
                             threshold_high: float = 100.0) -> str:
    """Classify a scaling sequence m(k) into perturbation regime.

    Computes the scaling ratio m(k)^a / k^b for large k and determines
    whether the sequence is subcritical, marginal, or supercritical.

    Args:
        k_values: Array of k values to test.
        m_func: Function mapping k -> m(k).
        alpha_c: Critical exponent α_c = b/a.
        threshold_low: Below this ratio, classify as irrelevant.
        threshold_high: Above this ratio, classify as relevant.

    Returns:
        One of "irrelevant", "marginal", "relevant".

    Complexity:
        O(N) for N values of k.

    Example:
        >>> k_vals = np.arange(10, 100)
        >>> classify_scaling_regime(k_vals, lambda k: int(np.sqrt(k)), 1.0)
        'irrelevant'
    """
    ratios = np.array([m_func(k) / (k ** alpha_c) if k > 0 else 0
                       for k in k_values])
    tail = ratios[len(ratios) // 2:]
    mean_tail = np.mean(tail)

    if mean_tail < threshold_low:
        return "irrelevant"
    elif mean_tail > threshold_high:
        return "relevant"
    else:
        return "marginal"


def compute_crossover_profile(k_max: int, alpha: float,
                                lambda_values: np.ndarray,
                                C: float = 1.0, a: int = 1,
                                b: int = 1) -> np.ndarray:
    """Compute the crossover profile F(λ) at a given k.

    For each λ, sets m = ⌊λ·k^α⌋ and computes the normalized defect.

    Args:
        k_max: Value of k to use for the profile computation.
        alpha: Scaling exponent.
        lambda_values: Array of λ values.
        C, a, b: Envelope parameters.

    Returns:
        Array of normalized defect values.

    Complexity:
        O(len(lambda_values)).

    Example:
        >>> lambdas = np.linspace(0, 5, 50)
        >>> profile = compute_crossover_profile(100, 1.0, lambdas)
        >>> abs(profile[0]) < 1e-10  # F(0) ≈ 0
        True
    """
    profile = np.zeros_like(lambda_values)
    for i, lam in enumerate(lambda_values):
        m = max(0, int(lam * k_max ** alpha))
        delta = wreath_defect_model(k_max, m, C, a, b)
        # Normalize by k^b / m^a if m > 0
        if m > 0:
            profile[i] = delta * k_max ** b / m ** a
        else:
            profile[i] = 0.0
    return profile


def fit_polynomial_envelope(k_data: np.ndarray, m_data: np.ndarray,
                              defect_data: np.ndarray) -> Tuple[float, float, float, float]:
    """Fit a polynomial defect envelope |Δ(k,m)| ≤ C·m^a/k^b.

    Uses log-linear regression to estimate C, a, b.

    Args:
        k_data: Array of k values.
        m_data: Array of m values.
        defect_data: Array of |Δ(k,m)| values.

    Returns:
        Tuple (C, a, b, alpha_c) where alpha_c = b/a.

    Example:
        >>> k = np.repeat(np.arange(5, 50), 10)
        >>> m = np.tile(np.arange(1, 11), 45)
        >>> delta = 2.5 * m**2 / k**3
        >>> C, a, b, alpha_c = fit_polynomial_envelope(k, m, delta)
        >>> abs(a - 2) < 0.1 and abs(b - 3) < 0.1
        True
    """
    a_est, b_est, alpha_c = estimate_critical_exponent(k_data, m_data, defect_data)
    # Estimate C from residuals
    mask = defect_data > 0
    log_C = np.mean(np.log(defect_data[mask]) - a_est * np.log(m_data[mask].astype(float))
                    + b_est * np.log(k_data[mask].astype(float)))
    C_est = np.exp(log_C)
    return C_est, a_est, b_est, alpha_c


def relevance_ratio(k: int, m: int, alpha: float,
                    C: float = 1.0, a: int = 1, b: int = 1) -> float:
    """Compute the relevance ratio Φ_α(k,m) = |Δ(k,m)| / (m/k^α).

    Args:
        k, m: Group parameters.
        alpha: Scaling exponent.
        C, a, b: Envelope parameters.

    Returns:
        The relevance ratio.

    Example:
        >>> relevance_ratio(10, 5, 1.0, C=1.0, a=1, b=1)
        1.0
    """
    delta = abs(wreath_defect_model(k, m, C, a, b))
    denom = m / (k ** alpha) if k > 0 else 0
    if denom <= 0:
        return float('inf') if delta > 0 else 0.0
    return delta / denom


def pressure_per_copy(k: int, m: int, C: float = 1.0,
                       a: int = 1, b: int = 1) -> float:
    """Compute the intensive (per-copy) pressure β_W(k,m)/m.

    Below the critical threshold, this converges to β(S_k).

    Args:
        k, m: Group parameters.
        C, a, b: Envelope parameters.

    Returns:
        β_W(k,m)/m.

    Example:
        >>> p = pressure_per_copy(100, 5)
        >>> bs = beta_symm_model(100)
        >>> abs(p - bs) / bs < 0.01  # Close to β(S_k) for large k
        True
    """
    if m <= 0:
        return 0.0
    beta_w = m * beta_symm_model(k) + wreath_defect_model(k, m, C, a, b)
    return beta_w / m


# ---- Example usage ----
if __name__ == "__main__":
    print("=== Algorithm Examples ===\n")

    # Example 1: Critical exponent estimation
    print("1. Critical Exponent Estimation")
    k_data = np.array([5, 10, 15, 20, 25, 30, 40, 50])
    m_data = np.array([2, 4, 6, 8, 10, 12, 16, 20])
    # True model: Δ = 2.0 * m^1 / k^1, so a=1, b=1, α_c=1
    delta_data = 2.0 * m_data / k_data
    a_est, b_est, alpha_c = estimate_critical_exponent(k_data, m_data, delta_data)
    print(f"  Estimated: a={a_est:.3f}, b={b_est:.3f}, α_c={alpha_c:.3f}")
    print(f"  True:      a=1.000, b=1.000, α_c=1.000\n")

    # Example 2: Regime classification
    print("2. Regime Classification")
    k_vals = np.arange(10, 200)
    for name, mf in [("√k", lambda k: int(np.sqrt(k))),
                      ("k", lambda k: k),
                      ("k²", lambda k: k*k)]:
        regime = classify_scaling_regime(k_vals, mf, 1.0)
        print(f"  m(k) = {name}: {regime}")

    # Example 3: Crossover profile
    print("\n3. Crossover Profile at k=50")
    lambdas = np.array([0.0, 0.5, 1.0, 2.0, 5.0, 10.0])
    profile = compute_crossover_profile(50, 1.0, lambdas)
    for l, p in zip(lambdas, profile):
        print(f"  λ={l:5.1f}: F(λ)={p:.4f}")

    # Example 4: Pressure per copy convergence
    print("\n4. Per-Copy Pressure Convergence")
    for k in [10, 50, 100, 500]:
        m = int(np.sqrt(k))  # subcritical
        ppc = pressure_per_copy(k, m)
        bs = beta_symm_model(k)
        rel_err = abs(ppc - bs) / bs * 100
        print(f"  k={k:4d}, m={m:3d}: β_W/m={ppc:.2f}, "
              f"β(S_k)={bs:.2f}, rel_err={rel_err:.2f}%")
