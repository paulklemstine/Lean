#!/usr/bin/env python3
"""
algorithms.py — Algorithms for computing wreath-product subgroup pressure
and double-scaling observables.

Implements:
1. Polynomial defect envelope computation
2. Critical exponent estimation via bisection
3. Regime classification
4. Crossover profile estimation
"""

import numpy as np
from typing import Callable, Tuple, List, Optional


def polynomial_defect_bound(
    k: int, m: int, C: float, a: int, b: int
) -> float:
    """Compute the polynomial defect upper bound C · m^a / k^b.

    This is the envelope from the subcritical irrelevance theorem:
    if |Δ(k,m)| ≤ C · m^a / k^b, then the critical exponent is α_c = b/a.

    Args:
        k: Group rank parameter (≥ 1)
        m: Multiplicity parameter (≥ 0)
        C: Envelope constant (≥ 0)
        a: Exponent on m
        b: Exponent on k

    Returns:
        The bound value C * m^a / k^b

    Example:
        >>> polynomial_defect_bound(10, 5, 1.0, 1, 1)
        0.5
    """
    if k == 0:
        return float('inf')
    return C * (m ** a) / (k ** b)


def critical_exponent(a: int, b: int) -> float:
    """Compute the critical exponent α_c = b/a.

    This is the threshold scaling: sequences m(k) = o(k^(b/a)) see
    vanishing wreath defect, while m(k) ≈ k^(b/a) may not.

    Args:
        a: Exponent on m in defect bound
        b: Exponent on k in defect bound

    Returns:
        The critical exponent b/a

    Example:
        >>> critical_exponent(2, 3)
        1.5
    """
    if a == 0:
        return float('inf')
    return b / a


def subcritical_ratio(
    mf: Callable[[int], int], k: int, a: int, b: int
) -> float:
    """Compute the subcritical ratio m(k)^a / k^b.

    When this ratio → 0 as k → ∞, the sequence m(k) is subcritical.

    Args:
        mf: Multiplicity function k → m(k)
        k: Current value of group rank
        a: Exponent on m
        b: Exponent on k

    Returns:
        The ratio mf(k)^a / k^b
    """
    if k == 0:
        return float('inf')
    return (mf(k) ** a) / (k ** b)


def estimate_defect_exponents(
    defect_data: List[Tuple[int, int, float]],
    k_min: int = 3
) -> Tuple[float, float, float]:
    """Estimate (C, a, b) from empirical defect data using least squares.

    Given data points (k, m, |Δ(k,m)|), fits the model
    |Δ(k,m)| ≈ C · m^a / k^b in log space.

    Args:
        defect_data: List of (k, m, |defect|) triples
        k_min: Minimum k to include in fit

    Returns:
        (C, a, b) estimated parameters

    Complexity: O(n) where n = len(defect_data)
    """
    filtered = [(k, m, d) for k, m, d in defect_data
                if k >= k_min and m > 0 and d > 0]
    if len(filtered) < 3:
        return (1.0, 1.0, 1.0)

    # log|Δ| = log C + a·log m - b·log k
    A = np.array([[1, np.log(m), -np.log(k)]
                   for k, m, d in filtered])
    y = np.array([np.log(d) for _, _, d in filtered])

    # Least squares: min ||Ax - y||^2
    result = np.linalg.lstsq(A, y, rcond=None)
    x = result[0]
    C_est = np.exp(x[0])
    a_est = x[1]
    b_est = x[2]

    return (C_est, a_est, b_est)


def classify_regime_quantitative(
    mf_k: int, k: int, a: int, b: int,
    threshold_low: float = 0.01,
    threshold_high: float = 100.0
) -> str:
    """Classify the perturbation regime based on scaling ratio.

    Args:
        mf_k: Value of m(k) at current k
        k: Current group rank
        a: Exponent on m
        b: Exponent on k
        threshold_low: Below this ratio → irrelevant
        threshold_high: Above this ratio → relevant

    Returns:
        One of "IRRELEVANT", "MARGINAL", "RELEVANT"
    """
    if k == 0:
        return "RELEVANT"
    ratio = (mf_k ** a) / (k ** b)
    if ratio < threshold_low:
        return "IRRELEVANT"
    elif ratio > threshold_high:
        return "RELEVANT"
    else:
        return "MARGINAL"


def compute_crossover_profile(
    beta_symm: Callable[[int], float],
    beta_wreath: Callable[[int, int], float],
    k: int,
    lambda_values: np.ndarray,
    alpha: float
) -> np.ndarray:
    """Compute the crossover profile F(λ) at fixed k.

    For each λ, sets m = round(λ · k^α) and computes
    F ≈ k^α · Δ(k,m) / m.

    Args:
        beta_symm: β(S_k) function
        beta_wreath: β_W(k,m) function
        k: Fixed group rank
        lambda_values: Array of λ values to evaluate
        alpha: Scaling exponent

    Returns:
        Array of F(λ) estimates
    """
    F_values = np.zeros_like(lambda_values)
    for i, lam in enumerate(lambda_values):
        m = max(1, round(lam * k ** alpha))
        defect = beta_wreath(k, m) - m * beta_symm(k)
        F_values[i] = (k ** alpha) * defect / m
    return F_values


def bisect_critical_exponent(
    defect_func: Callable[[int, int], float],
    k_values: List[int],
    alpha_low: float = 0.0,
    alpha_high: float = 5.0,
    tol: float = 0.01,
    max_iter: int = 50
) -> float:
    """Bisection to find the critical exponent.

    Finds α such that m(k) = k^α gives a marginal defect rate.
    Tests whether Δ(k, floor(k^α)) / k^α → 0 or diverges.

    Args:
        defect_func: (k, m) → |Δ(k,m)|
        k_values: List of k values to test (large k preferred)
        alpha_low: Lower bound on α search
        alpha_high: Upper bound on α search
        tol: Convergence tolerance
        max_iter: Maximum iterations

    Returns:
        Estimated critical exponent

    Complexity: O(max_iter · len(k_values))
    """
    def test_alpha(alpha: float) -> float:
        """Returns average normalized defect at this exponent."""
        total = 0.0
        count = 0
        for k in k_values:
            m = max(1, int(k ** alpha))
            d = abs(defect_func(k, m))
            total += d / max(1, m)
            count += 1
        return total / max(1, count)

    for _ in range(max_iter):
        if alpha_high - alpha_low < tol:
            break
        alpha_mid = (alpha_low + alpha_high) / 2
        val = test_alpha(alpha_mid)
        if val < 1e-6:
            alpha_low = alpha_mid
        else:
            alpha_high = alpha_mid

    return (alpha_low + alpha_high) / 2


if __name__ == "__main__":
    # Example usage
    print("Polynomial defect bounds:")
    for k in [5, 10, 50, 100]:
        for m in [1, k, k**2]:
            bound = polynomial_defect_bound(k, m, C=1.0, a=1, b=1)
            print(f"  k={k:4d}, m={m:6d}: bound = {bound:.6f}")

    print(f"\nCritical exponent for (a=1, b=1): {critical_exponent(1, 1)}")
    print(f"Critical exponent for (a=2, b=3): {critical_exponent(2, 3)}")

    print("\nRegime classification:")
    for k in [10, 100]:
        for m in [1, k, k**2]:
            reg = classify_regime_quantitative(m, k, a=1, b=1)
            print(f"  k={k}, m={m}: {reg}")
