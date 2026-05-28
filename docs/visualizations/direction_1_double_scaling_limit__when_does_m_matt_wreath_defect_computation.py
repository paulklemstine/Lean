#!/usr/bin/env python3
"""
Algorithms for wreath-product subgroup pressure analysis.

Implements:
1. Wreath defect computation
2. Rescaled defect and relevance ratio
3. Critical exponent search via data collapse
4. Model pressure functions for testing

All functions have type hints and docstrings.
"""

import math
from typing import List, Tuple, Optional, Callable


# ============================================================
# Core Definitions
# ============================================================

def wreath_defect(beta_symm: float, beta_wreath: float, m: int) -> float:
    """
    Compute the wreath defect Delta(k, m) = beta_W(k, m) - m * beta(S_k).

    Parameters
    ----------
    beta_symm : float
        Symmetric group pressure beta(S_k).
    beta_wreath : float
        Wreath product pressure beta_W(k, m).
    m : int
        Multiplicity parameter.

    Returns
    -------
    float
        The wreath defect.

    Example
    -------
    >>> wreath_defect(1.0, 2.5, 2)
    0.5
    """
    return beta_wreath - m * beta_symm


def rescaled_defect(delta: float, k: int, m: int, alpha: float) -> float:
    """
    Compute the rescaled defect R_alpha(k, m) = k^alpha / m * Delta(k, m).

    Parameters
    ----------
    delta : float
        The wreath defect Delta(k, m).
    k : int
        Base group parameter.
    m : int
        Multiplicity parameter.
    alpha : float
        Candidate critical exponent.

    Returns
    -------
    float
        The rescaled defect. Returns 0.0 if m == 0.

    Example
    -------
    >>> rescaled_defect(0.5, 10, 100, 2.0)
    0.5
    """
    if m == 0:
        return 0.0
    return (k ** alpha) / m * delta


def relevance_ratio(delta: float, k: int, m: int, alpha: float) -> float:
    """
    Compute the relevance ratio Phi_alpha(k, m) = |Delta| / (m / k^alpha).

    This is the scaling-dimension observable: when Phi -> 0, the
    perturbation is irrelevant at exponent alpha.

    Parameters
    ----------
    delta : float
        The wreath defect.
    k : int
        Base group parameter.
    m : int
        Multiplicity parameter.
    alpha : float
        Scaling exponent.

    Returns
    -------
    float
        The relevance ratio. Returns 0.0 if m == 0.

    Example
    -------
    >>> relevance_ratio(0.5, 10, 100, 2.0)
    0.5
    """
    if m == 0:
        return 0.0
    denominator = m / (k ** alpha)
    if denominator == 0:
        return float('inf')
    return abs(delta) / denominator


# ============================================================
# Model Pressure Functions
# ============================================================

def model_beta_symm(k: int) -> float:
    """
    Model symmetric group pressure: beta(S_k) = log(k).

    Parameters
    ----------
    k : int
        Group parameter.

    Returns
    -------
    float
        Model pressure value.
    """
    if k <= 0:
        return 0.0
    return math.log(k)


def model_beta_wreath(k: int, m: int, C: float = 0.5,
                       a: int = 1, b: int = 2) -> float:
    """
    Model wreath product pressure with polynomial defect:
    beta_W(k, m) = m * log(k) + C * m^a / k^b

    The critical exponent is alpha_c = b/a.

    Parameters
    ----------
    k : int
        Base group parameter.
    m : int
        Multiplicity parameter.
    C : float
        Defect amplitude.
    a : int
        Defect power in m.
    b : int
        Defect power in k.

    Returns
    -------
    float
        Model wreath product pressure.
    """
    if k <= 0:
        return 0.0
    return m * math.log(k) + C * (m ** a) / (k ** b)


# ============================================================
# Critical Exponent Search
# ============================================================

def search_critical_exponent(
    data: List[Tuple[int, int, float, float]],
    alpha_candidates: List[float],
) -> Tuple[float, float]:
    """
    Search for the critical exponent by data collapse.

    For each candidate alpha, compute the rescaled defect for all
    data points and measure the variance. The alpha with minimum
    variance gives the best collapse.

    Parameters
    ----------
    data : list of (k, m, beta_wreath, beta_symm)
        Observed pressure data.
    alpha_candidates : list of float
        Candidate exponents to test.

    Returns
    -------
    (best_alpha, min_variance) : tuple
        The best-fit exponent and its variance.

    Example
    -------
    >>> data = [(k, k, model_beta_wreath(k, k), model_beta_symm(k))
    ...         for k in range(3, 20)]
    >>> best, var = search_critical_exponent(data, [0.5, 1.0, 1.5, 2.0, 2.5])
    """
    best_alpha = alpha_candidates[0]
    min_variance = float('inf')

    for alpha in alpha_candidates:
        r_values = []
        for k, m, bw, bs in data:
            delta = wreath_defect(bs, bw, m)
            r = rescaled_defect(delta, k, m, alpha)
            r_values.append(r)

        if len(r_values) < 2:
            continue

        mean_r = sum(r_values) / len(r_values)
        variance = sum((r - mean_r) ** 2 for r in r_values) / len(r_values)

        if variance < min_variance:
            min_variance = variance
            best_alpha = alpha

    return best_alpha, min_variance


def classify_regime(m: int, k: int, alpha_c: float,
                    tolerance: float = 0.1) -> str:
    """
    Classify the perturbation regime for given (k, m) and critical exponent.

    Parameters
    ----------
    m : int
        Multiplicity parameter.
    k : int
        Base group parameter.
    alpha_c : float
        Critical exponent.
    tolerance : float
        Window around alpha_c for marginal classification.

    Returns
    -------
    str
        One of 'irrelevant', 'marginal', 'relevant'.

    Example
    -------
    >>> classify_regime(5, 100, 2.0)
    'irrelevant'
    >>> classify_regime(10000, 100, 2.0)
    'relevant'
    """
    if k <= 0:
        return 'marginal'

    ratio = math.log(m + 1) / (alpha_c * math.log(k + 1))

    if ratio < 1 - tolerance:
        return 'irrelevant'
    elif ratio > 1 + tolerance:
        return 'relevant'
    else:
        return 'marginal'


# ============================================================
# Defect Envelope Verification
# ============================================================

def verify_polynomial_bound(
    beta_symm_fn: Callable[[int], float],
    beta_wreath_fn: Callable[[int, int], float],
    k_range: range,
    m_range_fn: Callable[[int], range],
    C: float,
    a: int,
    b: int,
) -> Tuple[bool, Optional[Tuple[int, int, float]]]:
    """
    Verify that |Delta(k,m)| <= C * m^a / k^b for all k, m in given ranges.

    Returns
    -------
    (valid, counterexample) : tuple
        valid is True if the bound holds everywhere.
        counterexample is None if valid, else (k, m, |Delta|).

    Example
    -------
    >>> valid, _ = verify_polynomial_bound(
    ...     model_beta_symm, model_beta_wreath,
    ...     range(3, 20), lambda k: range(1, k*k),
    ...     0.5, 1, 2)
    >>> valid
    True
    """
    for k in k_range:
        for m in m_range_fn(k):
            bs = beta_symm_fn(k)
            bw = beta_wreath_fn(k, m)
            delta = wreath_defect(bs, bw, m)
            bound = C * (m ** a) / (k ** b)
            if abs(delta) > bound + 1e-12:  # small tolerance for floats
                return False, (k, m, abs(delta))
    return True, None


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("Algorithms for Wreath-Product Critical Phenomena")
    print("=" * 50)

    # Example 1: Compute wreath defect
    k, m = 10, 5
    bs = model_beta_symm(k)
    bw = model_beta_wreath(k, m)
    delta = wreath_defect(bs, bw, m)
    print(f"\nExample 1: k={k}, m={m}")
    print(f"  beta_symm = {bs:.4f}")
    print(f"  beta_wreath = {bw:.4f}")
    print(f"  wreath_defect = {delta:.6f}")

    # Example 2: Search for critical exponent
    data = []
    for k in range(3, 30):
        for m_mult in [1, 2, 5, 10]:
            m = m_mult * k
            bw = model_beta_wreath(k, m)
            bs = model_beta_symm(k)
            data.append((k, m, bw, bs))

    alphas = [i * 0.25 for i in range(1, 13)]
    best, var = search_critical_exponent(data, alphas)
    print(f"\nExample 2: Critical exponent search")
    print(f"  Best alpha = {best:.2f}")
    print(f"  Variance = {var:.6f}")

    # Example 3: Verify polynomial bound
    valid, cex = verify_polynomial_bound(
        model_beta_symm, model_beta_wreath,
        range(3, 20), lambda k: range(1, k * k),
        0.5, 1, 2)
    print(f"\nExample 3: Polynomial bound verification")
    print(f"  Bound holds: {valid}")

    # Example 4: Regime classification
    print(f"\nExample 4: Regime classification (alpha_c = 2.0)")
    for k, m in [(100, 5), (100, 100), (100, 10000)]:
        regime = classify_regime(m, k, 2.0)
        print(f"  k={k}, m={m}: {regime}")
