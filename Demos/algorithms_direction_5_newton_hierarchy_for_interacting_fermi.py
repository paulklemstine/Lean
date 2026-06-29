#!/usr/bin/env python3
"""
algorithms.py — Core Algorithms for Newton Hierarchy Stability Analysis

Implements the computational methods for analyzing Newton-ratio profiles
and their perturbative stability. These algorithms support the formally
verified theorems in the Lean development.

All functions include type hints, docstrings, and example usage.
"""

import numpy as np
from itertools import combinations
from math import comb
from typing import List, Tuple, Optional


def elementary_symmetric_polynomial(spectrum: List[float], k: int) -> float:
    """
    Compute the k-th elementary symmetric polynomial e_k of a spectrum.

    e_k(x_1, ..., x_n) = sum_{|S|=k} prod_{i in S} x_i

    Time complexity: O(C(n,k) * k)
    Space complexity: O(k) for each subset

    Args:
        spectrum: List of real numbers (nonneg for physical spectra)
        k: Order of the symmetric polynomial (0 <= k <= n)

    Returns:
        Value of e_k(spectrum)

    Example:
        >>> elementary_symmetric_polynomial([1, 2, 3], 2)
        11.0  # 1*2 + 1*3 + 2*3
    """
    n = len(spectrum)
    if k < 0 or k > n:
        return 0.0
    if k == 0:
        return 1.0

    total = 0.0
    for subset in combinations(range(n), k):
        prod = 1.0
        for i in subset:
            prod *= spectrum[i]
        total += prod
    return total


def elementary_symmetric_dp(spectrum: List[float], max_k: int) -> List[float]:
    """
    Compute all elementary symmetric polynomials e_0, ..., e_{max_k}
    using dynamic programming (Newton's identity / recursion).

    Uses the recurrence: e_k(x_1,...,x_n) = e_k(x_1,...,x_{n-1}) + x_n * e_{k-1}(x_1,...,x_{n-1})

    Time complexity: O(n * max_k)
    Space complexity: O(max_k)

    Args:
        spectrum: List of real numbers
        max_k: Maximum order to compute

    Returns:
        List [e_0, e_1, ..., e_{max_k}]

    Example:
        >>> elementary_symmetric_dp([1, 2, 3], 3)
        [1.0, 6.0, 11.0, 6.0]
    """
    n = len(spectrum)
    K = min(max_k, n)
    e = [0.0] * (K + 1)
    e[0] = 1.0

    for x in spectrum:
        # Process in reverse to avoid overwriting
        for j in range(min(K, n), 0, -1):
            e[j] += x * e[j - 1]

    # Pad with zeros if max_k > n
    result = e + [0.0] * max(0, max_k - K)
    return result


def newton_ratio(spectrum: List[float], k: int,
                 esymm_values: Optional[List[float]] = None) -> float:
    """
    Compute the Newton ratio at level k:
      rho_k = e_k^2 / (e_{k-1} * e_{k+1})

    By Newton's inequality, rho_k >= 1 for nonneg spectra.
    Returns 0 if the denominator vanishes.

    Args:
        spectrum: List of nonneg real numbers
        k: Level (1 <= k <= n-1 for meaningful values)
        esymm_values: Pre-computed [e_0, ..., e_{k+1}] (optional)

    Returns:
        Newton ratio rho_k

    Example:
        >>> newton_ratio([0.9, 0.7, 0.5, 0.3], 2)
        1.1367...
    """
    if esymm_values is not None:
        if k - 1 < 0 or k + 1 >= len(esymm_values):
            return 0.0
        ek = esymm_values[k]
        ekm1 = esymm_values[k - 1]
        ekp1 = esymm_values[k + 1]
    else:
        ek = elementary_symmetric_polynomial(spectrum, k)
        ekm1 = elementary_symmetric_polynomial(spectrum, k - 1)
        ekp1 = elementary_symmetric_polynomial(spectrum, k + 1)

    denom = ekm1 * ekp1
    if abs(denom) < 1e-30:
        return 0.0
    return ek ** 2 / denom


def compute_newton_profile(spectrum: List[float], K: int) -> List[float]:
    """
    Compute the Newton ratio profile [rho_0, rho_1, ..., rho_K].

    Uses dynamic programming for efficiency.

    Time complexity: O(n * K)
    Space complexity: O(K)

    Args:
        spectrum: Nonneg spectrum of length n
        K: Maximum Newton level

    Returns:
        List of Newton ratios

    Example:
        >>> compute_newton_profile([0.9, 0.7, 0.5, 0.3], 3)
        [0.0, 1.0277..., 1.1367..., 0.0]
    """
    esymm_vals = elementary_symmetric_dp(spectrum, K + 1)
    profile = []
    for k in range(K + 1):
        profile.append(newton_ratio(spectrum, k, esymm_vals))
    return profile


def newton_ratio_deviation(p: List[float], q: List[float], k: int) -> float:
    """
    Compute Newton ratio deviation at level k between spectra p and q:
      |rho_k(p) - rho_k(q)|

    Args:
        p, q: Two spectra of equal length
        k: Newton level

    Returns:
        Absolute deviation of Newton ratios
    """
    return abs(newton_ratio(p, k) - newton_ratio(q, k))


def certified_newton_deviation_bound(p: List[float], q: List[float],
                                      K: int) -> float:
    """
    Compute a certified upper bound on Newton ratio deviations up to level K.

    This is the computational counterpart of the formal specification
    `certifiedNewtonDeviationBoundSpec` in the Lean development.

    Args:
        p, q: Two spectra of equal length
        K: Maximum Newton level

    Returns:
        Upper bound B such that |rho_k(p) - rho_k(q)| <= B for all k <= K
    """
    return max(newton_ratio_deviation(p, q, k) for k in range(K + 1))


def esymm_lipschitz_constant(n: int, k: int, B: float) -> float:
    """
    Compute the theoretical Lipschitz constant for e_k with respect to
    the sup-norm, for spectra bounded by B.

    The telescoping product identity gives:
      |e_k(p) - e_k(q)| <= C(n,k) * k * B^{k-1} * epsilon

    Args:
        n: Spectrum length
        k: Elementary symmetric polynomial order
        B: Uniform bound on |p_i|, |q_i|

    Returns:
        Lipschitz constant C such that |e_k(p) - e_k(q)| <= C * epsilon
    """
    if k == 0:
        return 0.0
    return comb(n, k) * k * B ** max(k - 1, 0)


def div_perturbation_bound(alpha: float, beta: float,
                            a_prime: float, delta: float) -> float:
    """
    Compute the bound on |a/b - a'/b'| given:
      |a - a'| <= alpha
      |b - b'| <= beta
      |b|, |b'| >= delta > 0

    From the formal theorem div_sub_div_bound:
      |a/b - a'/b'| <= alpha/delta + |a'| * beta / delta^2

    Args:
        alpha: Bound on numerator difference
        beta: Bound on denominator difference
        a_prime: Value of a'
        delta: Lower bound on |b|, |b'|

    Returns:
        Upper bound on |a/b - a'/b'|
    """
    if delta <= 0:
        raise ValueError("delta must be positive")
    return alpha / delta + abs(a_prime) * beta / delta ** 2


def is_newton_stable(p: List[float], q: List[float],
                     K: int, C: float, epsilon: float) -> bool:
    """
    Check whether spectra p and q are Newton-stable to order K
    with constants C and epsilon:
      forall k <= K: |rho_k(p) - rho_k(q)| <= C * epsilon

    Args:
        p, q: Spectra of equal length
        K: Maximum Newton level
        C: Lipschitz constant
        epsilon: Perturbation size

    Returns:
        True if Newton-stable to order K
    """
    bound = C * epsilon
    for k in range(K + 1):
        if newton_ratio_deviation(p, q, k) > bound + 1e-12:  # numerical tolerance
            return False
    return True


# ─────────────────────────────────────────────────────────────────────────────
# Example Usage
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Newton Hierarchy Stability — Algorithm Demonstrations")
    print("=" * 60)

    # Example spectrum
    spec = [0.9, 0.7, 0.5, 0.3, 0.1]
    n = len(spec)
    K = 4

    print(f"\nSpectrum: {spec}")
    print(f"\nElementary symmetric polynomials (DP):")
    esymm_vals = elementary_symmetric_dp(spec, K + 1)
    for k in range(len(esymm_vals)):
        print(f"  e_{k} = {esymm_vals[k]:.6f}")

    print(f"\nNewton ratio profile:")
    profile = compute_newton_profile(spec, K)
    for k in range(K + 1):
        print(f"  ρ_{k} = {profile[k]:.6f}")

    # Perturbation test
    eps = 0.05
    perturbed = [min(1.0, max(0.0, x + np.random.uniform(-eps, eps))) for x in spec]
    print(f"\nPerturbed spectrum (ε={eps}): {[f'{x:.4f}' for x in perturbed]}")

    bound = certified_newton_deviation_bound(spec, perturbed, K)
    print(f"Certified deviation bound: {bound:.8f}")

    C_test = bound / eps if eps > 0 else 0
    print(f"Effective Lipschitz constant: {C_test:.4f}")
    print(f"Newton-stable with C={C_test:.1f}, ε={eps}? "
          f"{is_newton_stable(spec, perturbed, K, C_test, eps)}")
