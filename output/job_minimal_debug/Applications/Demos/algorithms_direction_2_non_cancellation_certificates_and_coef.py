#!/usr/bin/env python3
"""
Algorithms for Non-Cancellation Certificates and Shadow Computation

This module implements the core algorithms from the research paper:
1. Quadratic shadow computation
2. Per-variable-pair leaf set computation
3. Non-cancellation certificate verification
4. Shadow complexity computation
5. Hessian nonzero count computation
6. Shadow-closure check and closure computation

All algorithms work with sparse polynomial representations over ℚ.

Time complexity: O(|S| · n²) for shadow computation where |S| = support size, n = #variables
Space complexity: O(|shadow|)
"""

from fractions import Fraction
from typing import Dict, Tuple, Set, List, Optional, FrozenSet
from itertools import product as iter_product

# ─── Type Definitions ─────────────────────────────────────────────

Exponent = Tuple[int, ...]
Polynomial = Dict[Exponent, Fraction]


# ─── Core Shadow Algorithms ───────────────────────────────────────

def compute_quadratic_shadow(
    support: Set[Exponent],
    n_vars: int
) -> Set[Exponent]:
    """
    Compute the quadratic shadow of a support set.

    The quadratic shadow Sh₂(S) consists of all exponent vectors β
    such that there exist α ∈ S and variables i, j with α = β + eᵢ + eⱼ.
    Equivalently, β is obtained by subtracting two (possibly equal) unit
    basis vectors from some element of S.

    Args:
        support: Set of exponent vectors (tuples of non-negative integers)
        n_vars: Number of variables

    Returns:
        The quadratic shadow as a set of exponent vectors

    Time complexity: O(|S| · n²)
    Space complexity: O(|shadow|)

    Example:
        >>> S = {(2, 0), (1, 1), (0, 2)}
        >>> compute_quadratic_shadow(S, 2)
        {(0, 0)}
    """
    shadow: Set[Exponent] = set()
    for alpha in support:
        for i in range(n_vars):
            if alpha[i] < 1:
                continue
            # Subtract eᵢ
            alpha_minus_ei = list(alpha)
            alpha_minus_ei[i] -= 1
            for j in range(n_vars):
                if alpha_minus_ei[j] < 1:
                    continue
                # Subtract eⱼ
                beta = list(alpha_minus_ei)
                beta[j] -= 1
                shadow.add(tuple(beta))
    return shadow


def compute_quad_leaf_set(
    support: Set[Exponent],
    i: int,
    j: int,
    n_vars: int
) -> Set[Exponent]:
    """
    Compute the per-(i,j) quadratic leaf set.

    quadLeafSet(S, i, j) = {β | β + eᵢ + eⱼ ∈ S}

    This predicts the support of ∂ᵢ∂ⱼp when supp(p) = S.

    Args:
        support: Set of exponent vectors
        i: First variable index
        j: Second variable index
        n_vars: Number of variables

    Returns:
        The quadratic leaf set for the pair (i, j)

    Time complexity: O(|S|)

    Example:
        >>> S = {(2, 1), (1, 2)}
        >>> compute_quad_leaf_set(S, 0, 1, 2)
        {(1, 0), (0, 1)}
    """
    leaf_set: Set[Exponent] = set()
    for alpha in support:
        if alpha[i] < 1:
            continue
        alpha_minus_ei = list(alpha)
        alpha_minus_ei[i] -= 1
        if alpha_minus_ei[j] < 1:
            continue
        beta = list(alpha_minus_ei)
        beta[j] -= 1
        leaf_set.add(tuple(beta))
    return leaf_set


def hessian_scalar(beta: Exponent, i: int, j: int) -> Fraction:
    """
    Compute the Hessian scalar factor for exponent β and variables i, j.

    hessianScalar(β, i, j) = (β(i) + 1) · ((β + eᵢ)(j) + 1)

    This is the multiplicative factor relating the Hessian coefficient
    to its ancestor coefficient. Over ℚ, this is always positive.

    Args:
        beta: Exponent vector
        i: First variable index
        j: Second variable index

    Returns:
        The Hessian scalar factor as a Fraction

    Example:
        >>> hessian_scalar((2, 3), 0, 1)
        Fraction(12, 1)  # = 3 * 4
    """
    factor1 = beta[i] + 1
    # (β + eᵢ)(j): add 1 to j-th component of β if i == j, else β(j)
    beta_plus_ei_j = beta[j] + (1 if i == j else 0)
    factor2 = beta_plus_ei_j + 1
    return Fraction(factor1 * factor2)


# ─── Certificate Algorithms ──────────────────────────────────────

def is_shadow_closed(support: Set[Exponent], n_vars: int) -> bool:
    """
    Check if a support set is shadow-closed: Sh₂(S) ⊆ S.

    A shadow-closed support satisfies the structural precondition
    for the non-cancellation certificate.

    Args:
        support: Set of exponent vectors
        n_vars: Number of variables

    Returns:
        True if the quadratic shadow is contained in the support

    Time complexity: O(|S| · n²)
    """
    shadow = compute_quadratic_shadow(support, n_vars)
    return shadow.issubset(support)


def verify_non_cancellation_cert(
    poly: Polynomial,
    n_vars: int
) -> bool:
    """
    Verify the non-cancellation certificate for a polynomial.

    The certificate holds if for every d in the quadratic shadow of supp(p),
    coeff(d, p) ≠ 0. This is equivalent to Sh₂(supp(p)) ⊆ supp(p).

    Args:
        poly: Sparse polynomial
        n_vars: Number of variables

    Returns:
        True if the certificate holds
    """
    support = set(poly.keys())
    shadow = compute_quadratic_shadow(support, n_vars)
    return shadow.issubset(support)


def compute_shadow_closure(
    support: Set[Exponent],
    n_vars: int,
    max_iterations: int = 100
) -> Set[Exponent]:
    """
    Compute the shadow closure of a support set.

    Iteratively adds shadow elements until the set becomes shadow-closed.
    Note: this computes the EXPONENTS that would need nonzero coefficients,
    not the polynomial itself.

    Args:
        support: Initial support set
        n_vars: Number of variables
        max_iterations: Maximum iterations to prevent infinite loops

    Returns:
        The shadow closure of the support
    """
    current = set(support)
    for _ in range(max_iterations):
        shadow = compute_quadratic_shadow(current, n_vars)
        new_elements = shadow - current
        if not new_elements:
            break
        current |= new_elements
    return current


# ─── Complexity Measures ──────────────────────────────────────────

def shadow_complexity(support: Set[Exponent], n_vars: int) -> int:
    """
    Compute the shadow complexity of a support set.

    This is |Sh₂(S)|, the cardinality of the quadratic shadow.
    It provides a lower bound on the Hessian nonzero count.

    Args:
        support: Set of exponent vectors
        n_vars: Number of variables

    Returns:
        The shadow complexity
    """
    return len(compute_quadratic_shadow(support, n_vars))


def pderiv(poly: Polynomial, var_idx: int, n_vars: int) -> Polynomial:
    """
    Compute partial derivative ∂/∂x_{var_idx} of a polynomial.

    Args:
        poly: Sparse polynomial over ℚ
        var_idx: Variable index
        n_vars: Number of variables

    Returns:
        The partial derivative
    """
    result: Polynomial = {}
    for exp, coeff in poly.items():
        d = exp[var_idx]
        if d == 0:
            continue
        new_exp = list(exp)
        new_exp[var_idx] -= 1
        new_exp_t = tuple(new_exp)
        new_coeff = coeff * Fraction(d)
        if new_coeff != 0:
            result[new_exp_t] = result.get(new_exp_t, Fraction(0)) + new_coeff
            if result[new_exp_t] == 0:
                del result[new_exp_t]
    return result


def hessian_nonzero_count(poly: Polynomial, n_vars: int) -> int:
    """
    Compute the Hessian nonzero count of a polynomial.

    This is |⋃_{i,j} supp(∂ᵢ∂ⱼp)|, the number of distinct exponents
    appearing across all Hessian entries.

    Args:
        poly: Sparse polynomial over ℚ
        n_vars: Number of variables

    Returns:
        The Hessian nonzero count
    """
    union: Set[Exponent] = set()
    for i in range(n_vars):
        for j in range(n_vars):
            dp = pderiv(pderiv(poly, j, n_vars), i, n_vars)
            union.update(dp.keys())
    return len(union)


def verify_shadow_lower_bound(poly: Polynomial, n_vars: int) -> dict:
    """
    Verify the shadow lower bound theorem for a specific polynomial.

    Returns a dictionary with:
        - shadow_complexity: |Sh₂(supp(p))|
        - hessian_nonzero_count: |⋃ supp(∂ᵢ∂ⱼp)|
        - bound_holds: whether the inequality holds
        - per_entry_exact: whether each (i,j) entry matches prediction
    """
    support = set(poly.keys())
    sc = shadow_complexity(support, n_vars)
    hnc = hessian_nonzero_count(poly, n_vars)

    per_entry_exact = True
    for i in range(n_vars):
        for j in range(n_vars):
            predicted = compute_quad_leaf_set(support, i, j, n_vars)
            dp = pderiv(pderiv(poly, j, n_vars), i, n_vars)
            actual = set(dp.keys())
            if predicted != actual:
                per_entry_exact = False

    return {
        'shadow_complexity': sc,
        'hessian_nonzero_count': hnc,
        'bound_holds': sc <= hnc,
        'per_entry_exact': per_entry_exact,
    }


# ─── Example Usage ─────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Algorithms Module: Example Usage ===\n")

    # Example 1: Simple polynomial x² + xy + y²
    p = {(2, 0): Fraction(1), (1, 1): Fraction(1), (0, 2): Fraction(1)}
    print("Polynomial: x² + xy + y²")
    print(f"  Support: {set(p.keys())}")
    print(f"  Shadow: {compute_quadratic_shadow(set(p.keys()), 2)}")
    print(f"  Shadow-closed: {is_shadow_closed(set(p.keys()), 2)}")
    print(f"  Certificate holds: {verify_non_cancellation_cert(p, 2)}")
    result = verify_shadow_lower_bound(p, 2)
    print(f"  Shadow complexity: {result['shadow_complexity']}")
    print(f"  Hessian nonzero count: {result['hessian_nonzero_count']}")
    print(f"  Bound holds: {result['bound_holds']}")
    print(f"  Per-entry exact: {result['per_entry_exact']}")
    print()

    # Example 2: Polynomial with shadow-closed support
    # x³ + x²y + xy² + y³ + x² + xy + y² + x + y + 1
    p2: Polynomial = {}
    for i in range(4):
        for j in range(4 - i):
            p2[(i, j)] = Fraction(i + j + 1)
    print("Dense polynomial of degree 3 in 2 variables")
    print(f"  Support size: {len(p2)}")
    print(f"  Shadow-closed: {is_shadow_closed(set(p2.keys()), 2)}")
    result2 = verify_shadow_lower_bound(p2, 2)
    print(f"  Shadow complexity: {result2['shadow_complexity']}")
    print(f"  Hessian nonzero count: {result2['hessian_nonzero_count']}")
    print(f"  Per-entry exact: {result2['per_entry_exact']}")
    print()

    # Example 3: Hessian scalar values
    print("Hessian scalar examples:")
    for beta in [(0, 0), (1, 0), (0, 1), (2, 3)]:
        for i in range(2):
            for j in range(2):
                s = hessian_scalar(beta, i, j)
                print(f"  β={beta}, i={i}, j={j}: scalar = {s} "
                      f"({'> 0 ✓' if s > 0 else 'ZERO ✗'})")
