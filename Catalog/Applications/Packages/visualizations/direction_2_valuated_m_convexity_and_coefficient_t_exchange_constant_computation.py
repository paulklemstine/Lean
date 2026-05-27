#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Valuated M-Convex Exchange Analysis

Implements the core algorithms from the research paper:
1. Exchange constant computation (Algorithm 1)
2. Derivative transport constant computation (Algorithm 2)
3. Log-concavity verification along exchange rays (Algorithm 3)

All algorithms work with polynomials represented as coefficient dictionaries
mapping exponent tuples to real coefficients.
"""

from itertools import combinations
from typing import Dict, Tuple, List, Optional
import random
import math

# ─── Type Aliases ────────────────────────────────────────────────────────────

Exponent = Tuple[int, ...]
CoeffDict = Dict[Exponent, float]


# ─── Algorithm 1: Exchange Constant Computation ─────────────────────────────

def compute_exchange_constant(
    coeffs: CoeffDict,
    n_vars: int,
    tol: float = 1e-12
) -> Tuple[float, Optional[Tuple[Exponent, Exponent, int, int]]]:
    """
    Algorithm 1: Compute the minimal K ≥ 0 such that ValuatedExchange(p, K) holds.

    For each pair (a, b) in the support with b[i] < a[i], finds the best exchange
    witness j minimizing coeff(a)*coeff(b) / (coeff(a')*coeff(b')), then returns
    the maximum over all configurations.

    Time complexity: O(|supp|² · n² · n) where n = number of variables.
    Space complexity: O(|supp|).

    Args:
        coeffs: Coefficient dictionary mapping exponent tuples to coefficients.
        n_vars: Number of variables.
        tol: Numerical tolerance.

    Returns:
        (K_min, worst_config): Minimal exchange constant and the configuration
        achieving it (a, b, i, j), or None if the support has ≤ 1 element.

    Example:
        >>> coeffs = {(1,1,0): 2.0, (1,0,1): 3.0, (0,1,1): 5.0}
        >>> K, config = compute_exchange_constant(coeffs, 3)
        >>> print(f"K = {K:.4f}")
        K = 1.0000
    """
    support = [e for e, c in coeffs.items() if abs(c) > tol]
    if len(support) <= 1:
        return 0.0, None

    max_ratio = 0.0
    worst_config = None

    for a in support:
        for b in support:
            for i in range(n_vars):
                if b[i] >= a[i]:
                    continue
                best_ratio = float('inf')
                best_j = -1
                for j in range(n_vars):
                    if a[j] >= b[j]:
                        continue
                    # Compute exchanged exponents
                    a_prime = list(a)
                    a_prime[i] -= 1
                    a_prime[j] += 1
                    b_prime = list(b)
                    b_prime[i] += 1
                    b_prime[j] -= 1
                    ca_prime = coeffs.get(tuple(a_prime), 0.0)
                    cb_prime = coeffs.get(tuple(b_prime), 0.0)
                    if abs(ca_prime) > tol and abs(cb_prime) > tol:
                        ratio = (coeffs[a] * coeffs[b]) / (ca_prime * cb_prime)
                        if ratio < best_ratio:
                            best_ratio = ratio
                            best_j = j
                if best_ratio < float('inf') and best_ratio > max_ratio:
                    max_ratio = best_ratio
                    worst_config = (a, b, i, best_j)

    return max_ratio, worst_config


# ─── Algorithm 2: Derivative Transport Constant ─────────────────────────────

def compute_derivative(
    coeffs: CoeffDict,
    var: int,
    n_vars: int
) -> CoeffDict:
    """
    Compute the partial derivative of a polynomial with respect to variable `var`.

    Uses the coefficient transport identity:
        (∂_var p).coeff(m) = (m[var] + 1) * p.coeff(m + e_var)

    Time complexity: O(|supp|).
    Space complexity: O(|supp|).

    Args:
        coeffs: Coefficient dictionary.
        var: Variable index to differentiate.
        n_vars: Number of variables.

    Returns:
        Coefficient dictionary of the derivative.

    Example:
        >>> coeffs = {(1,1,0): 2.0, (1,0,1): 3.0, (0,1,1): 5.0}
        >>> d0 = compute_derivative(coeffs, 0, 3)
        >>> print(d0)
        {(0, 1, 0): 2.0, (0, 0, 1): 3.0}
    """
    result: CoeffDict = {}
    for e, c in coeffs.items():
        if e[var] > 0:
            new_e = list(e)
            new_e[var] -= 1
            new_e = tuple(new_e)
            result[new_e] = result.get(new_e, 0.0) + c * e[var]
    return result


def compute_derivative_transport_constant(
    coeffs: CoeffDict,
    var: int,
    n_vars: int,
    K_original: float,
    tol: float = 1e-12
) -> Tuple[float, float]:
    """
    Algorithm 2: Compute the transported exchange constant after differentiation.

    Given K for polynomial p, computes K' for ∂_var(p) and the maximal rescaling
    factor arising from the coordinate corrections (m[var]+1) in the transport.

    The theoretical bound is:
        K' ≤ K * max over exchange configs of (a[v]+1)(b[v]+1) / ((a'[v]+1)(b'[v]+1))

    Time complexity: O(|supp|² · n²).

    Args:
        coeffs: Coefficient dictionary of the original polynomial.
        var: Variable to differentiate.
        n_vars: Number of variables.
        K_original: Exchange constant of the original polynomial.
        tol: Numerical tolerance.

    Returns:
        (K_derivative, rescaling_factor): The actual derivative exchange constant
        and the maximal rescaling factor observed.

    Example:
        >>> coeffs = {(1,1,0): 2.0, (1,0,1): 3.0, (0,1,1): 5.0}
        >>> K_d, rescale = compute_derivative_transport_constant(coeffs, 0, 3, 1.0)
        >>> print(f"K_deriv = {K_d:.4f}, rescaling = {rescale:.4f}")
    """
    d_coeffs = compute_derivative(coeffs, var, n_vars)
    K_deriv, _ = compute_exchange_constant(d_coeffs, n_vars, tol)

    # Compute max rescaling factor
    d_support = [e for e, c in d_coeffs.items() if abs(c) > tol]
    max_rescale = 1.0

    for a in d_support:
        for b in d_support:
            for i in range(n_vars):
                if b[i] >= a[i]:
                    continue
                for j in range(n_vars):
                    if a[j] >= b[j]:
                        continue
                    # Original exponents: a + e_var, b + e_var
                    orig_a = list(a)
                    orig_a[var] += 1
                    orig_b = list(b)
                    orig_b[var] += 1
                    # Exchanged originals
                    orig_a_prime = list(orig_a)
                    orig_a_prime[i] -= 1
                    orig_a_prime[j] += 1
                    orig_b_prime = list(orig_b)
                    orig_b_prime[i] += 1
                    orig_b_prime[j] -= 1

                    num = (a[var] + 1) * (b[var] + 1)
                    a_prime = list(a)
                    a_prime[i] -= 1
                    a_prime[j] += 1
                    b_prime = list(b)
                    b_prime[i] += 1
                    b_prime[j] -= 1
                    den = (max(a_prime[var], 0) + 1) * (max(b_prime[var], 0) + 1)
                    if den > 0:
                        rescale = num / den
                        max_rescale = max(max_rescale, rescale)

    return K_deriv, max_rescale


# ─── Algorithm 3: Log-Concavity Verification ────────────────────────────────

def verify_log_concavity_on_rays(
    coeffs: CoeffDict,
    n_vars: int,
    K: float = 1.0,
    tol: float = 1e-12
) -> Tuple[bool, int, int]:
    """
    Algorithm 3: Verify log-concavity along all exchange rays.

    For each interior point m in the support and each pair of directions (i, j),
    checks whether:
        coeff(m + e_i - e_j) * coeff(m - e_i + e_j) ≤ K * coeff(m)²

    This is the cross-domain bridge: valuated exchange ↔ Lorentzian log-concavity.

    Time complexity: O(|supp| · n²).
    Space complexity: O(1) additional.

    Args:
        coeffs: Coefficient dictionary.
        n_vars: Number of variables.
        K: Exchange constant to verify against.
        tol: Numerical tolerance.

    Returns:
        (all_pass, n_checks, n_passes): Whether all checks pass,
        total number of checks, and number that passed.

    Example:
        >>> coeffs = {(2,0): 1.0, (1,1): 2.0, (0,2): 1.0}
        >>> ok, checks, passes = verify_log_concavity_on_rays(coeffs, 2)
        >>> print(f"Log-concave: {ok}, checks: {checks}")
    """
    support = [e for e, c in coeffs.items() if abs(c) > tol]
    n_checks = 0
    n_passes = 0

    for m in support:
        for i in range(n_vars):
            for j in range(n_vars):
                if i == j:
                    continue
                if m[i] < 1 or m[j] < 1:
                    continue
                # m + e_i - e_j
                m_plus = list(m)
                m_plus[i] += 1
                m_plus[j] -= 1
                # m - e_i + e_j
                m_minus = list(m)
                m_minus[i] -= 1
                m_minus[j] += 1

                c_plus = coeffs.get(tuple(m_plus), 0.0)
                c_minus = coeffs.get(tuple(m_minus), 0.0)
                c_center = coeffs[m]

                if abs(c_plus) > tol and abs(c_minus) > tol:
                    n_checks += 1
                    if c_plus * c_minus <= K * c_center * c_center + tol:
                        n_passes += 1

    return n_checks == n_passes, n_checks, n_passes


# ─── Utility: Generate Weighted Uniform Matroid Polynomials ──────────────────

def weighted_uniform_polynomial(
    n: int,
    d: int,
    weights: Optional[Dict[Tuple[int,...], float]] = None
) -> Tuple[CoeffDict, int]:
    """
    Generate a weighted uniform matroid basis-generating polynomial:
        p(x) = sum_{|S|=d} w_S * prod_{i in S} x_i

    Args:
        n: Number of variables.
        d: Degree (subset size).
        weights: Optional weight dictionary. If None, uses uniform weights.

    Returns:
        (coeffs, n_vars): Coefficient dictionary and number of variables.
    """
    bases = list(combinations(range(n), d))
    if weights is None:
        weights = {S: 1.0 for S in bases}

    coeffs: CoeffDict = {}
    for S in bases:
        e = [0] * n
        for i in S:
            e[i] = 1
        coeffs[tuple(e)] = weights[S]

    return coeffs, n


# ─── Main: Algorithm Demonstrations ─────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm 1: Exchange Constant Computation")
    print("=" * 60)

    # U(2,3) with weights
    coeffs, n = weighted_uniform_polynomial(3, 2, {(0,1): 2, (0,2): 3, (1,2): 5})
    K, config = compute_exchange_constant(coeffs, n)
    print(f"U(2,3) with a=2, b=3, c=5: K = {K:.4f}")
    if config:
        print(f"  Worst config: a={config[0]}, b={config[1]}, i={config[2]}, j={config[3]}")

    # U(2,4) uniform
    coeffs, n = weighted_uniform_polynomial(4, 2)
    K, _ = compute_exchange_constant(coeffs, n)
    print(f"U(2,4) uniform: K = {K:.4f}")

    print("\n" + "=" * 60)
    print("Algorithm 2: Derivative Transport Constants")
    print("=" * 60)

    coeffs, n = weighted_uniform_polynomial(4, 3)
    K_orig, _ = compute_exchange_constant(coeffs, n)
    print(f"U(3,4) uniform: K_orig = {K_orig:.4f}")

    for var in range(n):
        K_d, rescale = compute_derivative_transport_constant(coeffs, var, n, K_orig)
        print(f"  ∂_{var}: K_deriv = {K_d:.4f}, max_rescale = {rescale:.4f}")

    print("\n" + "=" * 60)
    print("Algorithm 3: Log-Concavity Verification")
    print("=" * 60)

    # Test with (1+x+y)^3 coefficients
    # Coefficients of (1+x+y)^3: binomial expansion
    coeffs_3 = {}
    for a in range(4):
        for b in range(4 - a):
            c = math.factorial(3) // (math.factorial(a) * math.factorial(b) * math.factorial(3-a-b))
            if c > 0:
                coeffs_3[(a, b)] = float(c)

    print(f"(1+x+y)^3 coefficients: {coeffs_3}")
    ok, checks, passes = verify_log_concavity_on_rays(coeffs_3, 2)
    print(f"Log-concave: {ok}, checks: {checks}, passes: {passes}")
