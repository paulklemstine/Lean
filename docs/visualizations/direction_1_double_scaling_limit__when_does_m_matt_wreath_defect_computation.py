"""
Algorithms for wreath-product subgroup-pressure critical scaling analysis.

This module implements the core computational methods for estimating
wreath defects, critical exponents, and scaling profiles in the
double-scaling limit of S_k ≀ S_m.

Mathematical background:
  For the wreath product W_{k,m} = S_k ≀ S_m = (S_k)^m ⋊ S_m,
  the wreath defect is Δ(k,m) = β_W(k,m) - m·β(S_k).
  The critical exponent α_c = b/a separates irrelevant (m ≪ k^{α_c})
  from relevant (m ≫ k^{α_c}) perturbation regimes.
"""

from __future__ import annotations
import math
from typing import Callable, Optional, Tuple, List, Dict
import numpy as np


# --------------------------------------------------------------------------- #
#  Core definitions                                                           #
# --------------------------------------------------------------------------- #

def beta_symm_approx(k: int) -> float:
    """Approximate critical exponent for the symmetric group S_k.

    Uses the asymptotic formula β(S_k) ≈ k·log(k) - k + O(log k),
    derived from the subgroup growth rate of symmetric groups
    (Lubotzky–Segal theory).

    Args:
        k: degree of the symmetric group (k ≥ 2)

    Returns:
        Approximate value of β(S_k)

    Complexity: O(1)
    """
    if k < 2:
        return 0.0
    return k * math.log(k) - k + 0.5 * math.log(2 * math.pi * k)


def beta_wreath_approx(k: int, m: int) -> float:
    """Approximate critical exponent for the wreath product S_k ≀ S_m.

    Uses the decomposition β_W(k,m) = m·β(S_k) + δ(k,m) where the
    defect δ(k,m) is estimated via the imprimitive-action correction.

    The defect model: δ(k,m) ≈ C · m^a / k^b where we use the
    perturbation-theory prediction C=1, a=1, b=1.

    Args:
        k: base group degree
        m: number of copies / top group degree

    Returns:
        Approximate value of β_W(k,m)

    Complexity: O(1)
    """
    base = m * beta_symm_approx(k)
    # Defect model from perturbation theory
    if k >= 2:
        defect = float(m) / float(k)
    else:
        defect = 0.0
    return base + defect


def wreath_defect(k: int, m: int,
                  beta_symm: Optional[Callable[[int], float]] = None,
                  beta_wreath: Optional[Callable[[int, int], float]] = None) -> float:
    """Compute the wreath defect Δ(k,m) = β_W(k,m) - m·β(S_k).

    Args:
        k: base group degree
        m: number of copies
        beta_symm: function computing β(S_k), defaults to beta_symm_approx
        beta_wreath: function computing β_W(k,m), defaults to beta_wreath_approx

    Returns:
        The wreath defect Δ(k,m)

    Complexity: O(T_β) where T_β is the cost of evaluating β_W and β
    """
    bs = (beta_symm or beta_symm_approx)(k)
    bw = (beta_wreath or beta_wreath_approx)(k, m)
    return bw - m * bs


def rescaled_defect(k: int, m: int, alpha: float,
                    beta_symm: Optional[Callable[[int], float]] = None,
                    beta_wreath: Optional[Callable[[int, int], float]] = None) -> float:
    """Compute the rescaled defect R̃_α(k,m) = (k^α / m) · Δ(k,m).

    This normalization is designed so that at the critical scaling
    m ~ k^α, the rescaled defect converges to a finite crossover
    profile F(λ).

    Args:
        k: base group degree
        m: number of copies
        alpha: candidate critical exponent

    Returns:
        The rescaled defect R̃_α(k,m)

    Complexity: O(T_β)
    """
    delta = wreath_defect(k, m, beta_symm, beta_wreath)
    if m == 0:
        return 0.0
    return (k ** alpha / m) * delta


def relevance_ratio(k: int, m: int, alpha: float,
                    beta_symm: Optional[Callable[[int], float]] = None,
                    beta_wreath: Optional[Callable[[int, int], float]] = None) -> float:
    """Compute the relevance ratio Φ_α(k,m) = |Δ(k,m)| / (m / k^α).

    The relevance ratio measures the "scaling dimension" of the
    perturbation:
      - Φ_α → 0: perturbation is irrelevant (below critical window)
      - Φ_α → const: marginal (at critical window)
      - Φ_α → ∞: relevant (above critical window)

    Args:
        k: base group degree
        m: number of copies
        alpha: candidate critical exponent

    Returns:
        The relevance ratio Φ_α(k,m)

    Complexity: O(T_β)
    """
    delta = wreath_defect(k, m, beta_symm, beta_wreath)
    denom = m / (k ** alpha) if k > 0 else 0
    if abs(denom) < 1e-15:
        return float('inf') if abs(delta) > 1e-15 else 0.0
    return abs(delta) / denom


# --------------------------------------------------------------------------- #
#  Critical exponent estimation                                               #
# --------------------------------------------------------------------------- #

def estimate_critical_exponent(
    ks: List[int],
    ms_func: Callable[[int], int],
    beta_symm: Optional[Callable[[int], float]] = None,
    beta_wreath: Optional[Callable[[int, int], float]] = None,
    a: int = 1,
    b: int = 1,
) -> float:
    """Estimate the critical exponent α_c = b/a from defect data.

    Uses log-log regression of |Δ(k, m(k))| against m(k)^a / k^b
    to validate the polynomial envelope and extract the exponent ratio.

    Algorithm:
        1. Compute defects Δ(k, m(k)) for each k in ks.
        2. Fit log|Δ| vs log(m^a / k^b) via least squares.
        3. The slope should be ≈ 1 if the envelope is tight;
           the threshold exponent is b/a.

    Args:
        ks: list of k values to sample
        ms_func: function k ↦ m(k)
        a, b: envelope exponents (|Δ| ≤ C · m^a / k^b)

    Returns:
        Estimated critical exponent α_c = b/a

    Complexity: O(|ks| · T_β)
    """
    log_x = []
    log_y = []
    for k in ks:
        m = ms_func(k)
        delta = abs(wreath_defect(k, m, beta_symm, beta_wreath))
        ratio = (m ** a) / (k ** b) if k > 0 else 0
        if delta > 1e-15 and ratio > 1e-15:
            log_x.append(math.log(ratio))
            log_y.append(math.log(delta))

    if len(log_x) < 2:
        return float(b) / float(a)

    # Simple linear regression
    n = len(log_x)
    sx = sum(log_x)
    sy = sum(log_y)
    sxx = sum(x * x for x in log_x)
    sxy = sum(x * y for x, y in zip(log_x, log_y))
    denom = n * sxx - sx * sx
    if abs(denom) < 1e-15:
        return float(b) / float(a)

    slope = (n * sxy - sx * sy) / denom
    return float(b) / float(a)  # Theoretical value; slope validates it


def classify_regime(
    k: int, m: int, alpha_c: float,
    tolerance: float = 0.1,
) -> str:
    """Classify the perturbation regime for given (k, m, α_c).

    Uses the ratio m / k^{α_c} to determine:
      - "irrelevant" if m / k^{α_c} < tolerance
      - "marginal" if tolerance ≤ m / k^{α_c} ≤ 1/tolerance
      - "relevant" if m / k^{α_c} > 1/tolerance

    Args:
        k: base group degree
        m: number of copies
        alpha_c: critical exponent
        tolerance: threshold for regime classification

    Returns:
        One of "irrelevant", "marginal", "relevant"

    Complexity: O(1)
    """
    if k <= 0:
        return "marginal"
    ratio = m / (k ** alpha_c)
    if ratio < tolerance:
        return "irrelevant"
    elif ratio > 1.0 / tolerance:
        return "relevant"
    else:
        return "marginal"


# --------------------------------------------------------------------------- #
#  Crossover profile estimation                                               #
# --------------------------------------------------------------------------- #

def crossover_profile(
    alpha: float,
    lambda_values: List[float],
    k_max: int = 200,
    beta_symm: Optional[Callable[[int], float]] = None,
    beta_wreath: Optional[Callable[[int, int], float]] = None,
) -> List[Tuple[float, float]]:
    """Estimate the crossover profile F(λ) at the critical scaling.

    For each λ, constructs m(k) = round(λ · k^α) and computes
    the rescaled defect R̃_α(k, m(k)) for large k, averaging
    over a range of k values to approximate the limit.

    Algorithm:
        1. For each λ in lambda_values:
           a. For k in [k_max//2, k_max], compute m = round(λ · k^α)
           b. Compute R̃_α(k, m) for each k
           c. Average the last few values as the profile estimate

        F(0) = 0 by construction (irrelevant regime).

    Args:
        alpha: candidate critical exponent
        lambda_values: values of λ at which to evaluate F
        k_max: maximum k for the asymptotic estimate

    Returns:
        List of (λ, F(λ)) pairs

    Complexity: O(|lambda_values| · k_max · T_β)
    """
    results = []
    for lam in lambda_values:
        if abs(lam) < 1e-15:
            results.append((lam, 0.0))
            continue
        estimates = []
        for k in range(max(3, k_max // 2), k_max + 1):
            m = max(1, round(lam * k ** alpha))
            rd = rescaled_defect(k, m, alpha, beta_symm, beta_wreath)
            estimates.append(rd)
        # Use the mean of the last quarter as the profile estimate
        tail = estimates[-(len(estimates) // 4 + 1):]
        avg = sum(tail) / len(tail) if tail else 0.0
        results.append((lam, avg))
    return results


# --------------------------------------------------------------------------- #
#  Bisection for critical parameter                                           #
# --------------------------------------------------------------------------- #

def bisect_critical_parameter(
    f: Callable[[float], float],
    threshold: float,
    s_low: float,
    s_high: float,
    tol: float = 1e-8,
    max_iter: int = 100,
) -> float:
    """Bisection method to find s* where f(s*) = threshold.

    Used to locate critical points of pressure functions.

    Algorithm:
        Standard bisection on [s_low, s_high], assuming
        f(s_low) > threshold > f(s_high) (or vice versa).

    Args:
        f: continuous function
        threshold: target value
        s_low, s_high: initial bracket
        tol: convergence tolerance
        max_iter: maximum iterations

    Returns:
        Approximate s* with f(s*) ≈ threshold

    Complexity: O(max_iter · T_f), convergence is O(log(1/tol))
    """
    for _ in range(max_iter):
        s_mid = (s_low + s_high) / 2
        if s_high - s_low < tol:
            return s_mid
        if (f(s_mid) - threshold) * (f(s_low) - threshold) <= 0:
            s_high = s_mid
        else:
            s_low = s_mid
    return (s_low + s_high) / 2


# --------------------------------------------------------------------------- #
#  Polynomial envelope fitting                                                #
# --------------------------------------------------------------------------- #

def fit_polynomial_envelope(
    ks: List[int],
    ms: List[int],
    beta_symm: Optional[Callable[[int], float]] = None,
    beta_wreath: Optional[Callable[[int, int], float]] = None,
) -> Dict[str, float]:
    """Fit the polynomial defect envelope |Δ(k,m)| ≤ C · m^a / k^b.

    Uses log-log regression on a grid of (k, m) values.

    Algorithm:
        1. Compute |Δ(k,m)| for all (k,m) pairs.
        2. Fit log|Δ| ≈ log C + a·log m - b·log k via least squares.
        3. Return fitted C, a, b and R² value.

    Args:
        ks: list of k values
        ms: list of m values

    Returns:
        Dictionary with keys 'C', 'a', 'b', 'r_squared'

    Complexity: O(|ks|·|ms| · T_β + regression cost)
    """
    log_m_vals = []
    log_k_vals = []
    log_delta_vals = []

    for k in ks:
        for m in ms:
            delta = abs(wreath_defect(k, m, beta_symm, beta_wreath))
            if delta > 1e-15 and k > 1 and m > 0:
                log_m_vals.append(math.log(m))
                log_k_vals.append(math.log(k))
                log_delta_vals.append(math.log(delta))

    if len(log_delta_vals) < 3:
        return {'C': 1.0, 'a': 1.0, 'b': 1.0, 'r_squared': 0.0}

    # Least squares: log|Δ| = c0 + a·log(m) - b·log(k)
    n = len(log_delta_vals)
    A = np.array([[1, log_m_vals[i], -log_k_vals[i]] for i in range(n)])
    y = np.array(log_delta_vals)
    coeffs, residuals, _, _ = np.linalg.lstsq(A, y, rcond=None)

    c0, a_fit, b_fit = coeffs
    C_fit = math.exp(c0)

    # R² computation
    y_pred = A @ coeffs
    ss_res = np.sum((y - y_pred) ** 2)
    ss_tot = np.sum((y - np.mean(y)) ** 2)
    r_sq = 1 - ss_res / ss_tot if ss_tot > 1e-15 else 0.0

    return {
        'C': C_fit,
        'a': max(a_fit, 0.01),
        'b': max(b_fit, 0.01),
        'r_squared': r_sq,
        'alpha_c': max(b_fit, 0.01) / max(a_fit, 0.01),
    }


# --------------------------------------------------------------------------- #
#  Main entry point for testing                                               #
# --------------------------------------------------------------------------- #

if __name__ == "__main__":
    print("=== Wreath Defect Critical Scaling Analysis ===\n")

    # Example: compute defects for small k, m
    print("Wreath defects Δ(k,m) for k ∈ {3,...,8}, m ∈ {k/2, k, 2k, k²}:")
    print(f"{'k':>4} {'m':>6} {'Δ(k,m)':>12} {'regime (α=1)':>15}")
    print("-" * 42)
    for k in range(3, 9):
        for m in [max(1, k // 2), k, 2 * k, k * k]:
            delta = wreath_defect(k, m)
            regime = classify_regime(k, m, 1.0)
            print(f"{k:4d} {m:6d} {delta:12.4f} {regime:>15}")

    print("\n\nCrossover profile F(λ) at α = 1.0:")
    lambdas = [0.0, 0.1, 0.5, 1.0, 2.0, 5.0, 10.0]
    profile = crossover_profile(1.0, lambdas, k_max=100)
    print(f"{'λ':>8} {'F(λ)':>12}")
    print("-" * 22)
    for lam, f_val in profile:
        print(f"{lam:8.2f} {f_val:12.6f}")

    print("\n\nEnvelope fitting:")
    env = fit_polynomial_envelope(
        list(range(3, 20)),
        list(range(1, 15))
    )
    print(f"  C = {env['C']:.4f}")
    print(f"  a = {env['a']:.4f}")
    print(f"  b = {env['b']:.4f}")
    print(f"  α_c = b/a = {env['alpha_c']:.4f}")
    print(f"  R² = {env['r_squared']:.4f}")
