#!/usr/bin/env python3
"""
Algorithms for Non-Cancellation Certificates and Shadow Computation

This module implements:
1. Quadratic shadow computation (O(|S| · n²) time)
2. Non-cancellation certificate verification
3. Shadow-closure test
4. Hessian support prediction and verification
5. Complexity measure computation

All algorithms work with sparse representations over rational arithmetic.

Type hints and docstrings follow NumPy conventions.
"""

from fractions import Fraction
from typing import Dict, FrozenSet, List, Optional, Set, Tuple
from itertools import product as cartesian_product
from collections import defaultdict


# ─────────────────────────────────────────────────────────
# Type Aliases
# ─────────────────────────────────────────────────────────
Exponent = Tuple[int, ...]  # Immutable exponent vector
SupportSet = FrozenSet[Exponent]
CoefficientMap = Dict[Exponent, Fraction]


# ─────────────────────────────────────────────────────────
# Algorithm 1: Quadratic Shadow Computation
# ─────────────────────────────────────────────────────────

def compute_quadratic_shadow(support: Set[Exponent], n_vars: int) -> Set[Exponent]:
    """
    Compute the quadratic shadow Sh₂(S) of a support set S.

    The quadratic shadow is the set of all exponent vectors β such that
    β + eᵢ + eⱼ ∈ S for some variables i, j.

    Parameters
    ----------
    support : Set[Exponent]
        The support set S (finite set of exponent vectors).
    n_vars : int
        Number of variables.

    Returns
    -------
    Set[Exponent]
        The quadratic shadow Sh₂(S).

    Complexity
    ----------
    Time: O(|S| · n²)
    Space: O(|Sh₂(S)|)

    Examples
    --------
    >>> S = {(3, 0), (0, 3)}
    >>> compute_quadratic_shadow(S, 2)
    {(1, 0), (0, 1)}
    """
    shadow = set()
    for alpha in support:
        for i in range(n_vars):
            if alpha[i] < 1:
                continue
            # Subtract e_i
            alpha_minus_ei = list(alpha)
            alpha_minus_ei[i] -= 1
            for j in range(n_vars):
                if alpha_minus_ei[j] < 1:
                    continue
                # Subtract e_j
                beta = list(alpha_minus_ei)
                beta[j] -= 1
                shadow.add(tuple(beta))
    return shadow


def compute_quad_leaf_set(support: Set[Exponent], n_vars: int,
                          i: int, j: int) -> Set[Exponent]:
    """
    Compute the per-pair quadratic leaf set for variables (i, j).

    This is {β | β + eᵢ + eⱼ ∈ S}.

    Parameters
    ----------
    support : Set[Exponent]
        The support set S.
    n_vars : int
        Number of variables.
    i, j : int
        Variable indices.

    Returns
    -------
    Set[Exponent]
        The per-pair shadow.

    Complexity
    ----------
    Time: O(|S|)
    Space: O(output size)
    """
    result = set()
    for alpha in support:
        if alpha[i] < 1:
            continue
        mid = list(alpha)
        mid[i] -= 1
        if mid[j] < 1:
            continue
        mid[j] -= 1
        result.add(tuple(mid))
    return result


# ─────────────────────────────────────────────────────────
# Algorithm 2: Shadow-Closure Test
# ─────────────────────────────────────────────────────────

def is_shadow_closed(support: Set[Exponent], n_vars: int) -> bool:
    """
    Test whether a support set is shadow-closed: Sh₂(S) ⊆ S.

    A shadow-closed support guarantees that the non-cancellation
    certificate holds for any polynomial with that support and
    all-nonzero coefficients.

    Parameters
    ----------
    support : Set[Exponent]
        The support set S.
    n_vars : int
        Number of variables.

    Returns
    -------
    bool
        True if S is shadow-closed.

    Complexity
    ----------
    Time: O(|S| · n²)
    """
    shadow = compute_quadratic_shadow(support, n_vars)
    return shadow.issubset(support)


def find_shadow_closure(support: Set[Exponent], n_vars: int) -> Set[Exponent]:
    """
    Compute the shadow closure of S: the smallest shadow-closed set containing S.

    Iteratively adds shadow elements until fixed point.

    Parameters
    ----------
    support : Set[Exponent]
        Initial support set.
    n_vars : int
        Number of variables.

    Returns
    -------
    Set[Exponent]
        The shadow closure of S.

    Complexity
    ----------
    Time: O(k · |S_final| · n²) where k is the number of iterations.
    """
    current = set(support)
    while True:
        shadow = compute_quadratic_shadow(current, n_vars)
        new_elements = shadow - current
        if not new_elements:
            break
        current |= new_elements
    return current


# ─────────────────────────────────────────────────────────
# Algorithm 3: Non-Cancellation Certificate Verification
# ─────────────────────────────────────────────────────────

def verify_certificate(coefficients: CoefficientMap,
                       n_vars: int) -> Tuple[bool, Optional[Exponent]]:
    """
    Verify the non-cancellation certificate for a polynomial.

    The certificate holds if every exponent in the quadratic shadow
    of the support also has a nonzero coefficient.

    Parameters
    ----------
    coefficients : CoefficientMap
        Map from exponent vectors to rational coefficients.
    n_vars : int
        Number of variables.

    Returns
    -------
    Tuple[bool, Optional[Exponent]]
        (True, None) if certificate holds.
        (False, witness) if certificate fails, with a witness exponent.

    Complexity
    ----------
    Time: O(|S| · n²)
    """
    support = {m for m, c in coefficients.items() if c != 0}
    shadow = compute_quadratic_shadow(support, n_vars)

    for beta in shadow:
        if coefficients.get(beta, Fraction(0)) == 0:
            return False, beta

    return True, None


# ─────────────────────────────────────────────────────────
# Algorithm 4: Hessian Support Prediction
# ─────────────────────────────────────────────────────────

def predict_hessian_support(support: Set[Exponent], n_vars: int,
                            i: int, j: int) -> Set[Exponent]:
    """
    Predict the support of ∂ᵢ∂ⱼp from the support of p alone.

    Over characteristic zero, this prediction is exact (no false positives
    or false negatives). This is the content of Theorem 1.

    Parameters
    ----------
    support : Set[Exponent]
        The support of p.
    n_vars : int
        Number of variables.
    i, j : int
        Variable indices for differentiation.

    Returns
    -------
    Set[Exponent]
        The predicted support of ∂ᵢ∂ⱼp.

    Complexity
    ----------
    Time: O(|S|)
    """
    return compute_quad_leaf_set(support, n_vars, i, j)


def compute_actual_hessian_support(coefficients: CoefficientMap,
                                   n_vars: int,
                                   i: int, j: int) -> Set[Exponent]:
    """
    Compute the actual support of ∂ᵢ∂ⱼp by symbolic differentiation.

    Parameters
    ----------
    coefficients : CoefficientMap
        The polynomial's coefficient map.
    n_vars : int
        Number of variables.
    i, j : int
        Variable indices.

    Returns
    -------
    Set[Exponent]
        The support of ∂ᵢ∂ⱼp.

    Complexity
    ----------
    Time: O(|S|)
    """
    result = defaultdict(Fraction)

    for alpha, coeff in coefficients.items():
        if coeff == 0:
            continue
        # First differentiate by j
        if alpha[j] < 1:
            continue
        mid_coeff = coeff * alpha[j]
        mid = list(alpha)
        mid[j] -= 1

        # Then differentiate by i
        if mid[i] < 1:
            continue
        out_coeff = mid_coeff * mid[i]
        mid[i] -= 1
        beta = tuple(mid)
        result[beta] += out_coeff

    return {beta for beta, c in result.items() if c != 0}


def verify_theorem1(coefficients: CoefficientMap,
                    n_vars: int) -> Tuple[bool, List[dict]]:
    """
    Verify Theorem 1: predicted Hessian support = actual Hessian support
    for all variable pairs (i, j).

    Parameters
    ----------
    coefficients : CoefficientMap
        The polynomial's coefficient map.
    n_vars : int
        Number of variables.

    Returns
    -------
    Tuple[bool, List[dict]]
        (all_match, details) where details has per-pair comparison info.
    """
    support = {m for m, c in coefficients.items() if c != 0}
    all_match = True
    details = []

    for i in range(n_vars):
        for j in range(n_vars):
            predicted = predict_hessian_support(support, n_vars, i, j)
            actual = compute_actual_hessian_support(coefficients, n_vars, i, j)
            match = (predicted == actual)
            if not match:
                all_match = False
            details.append({
                'i': i, 'j': j,
                'predicted': predicted,
                'actual': actual,
                'match': match,
            })

    return all_match, details


# ─────────────────────────────────────────────────────────
# Algorithm 5: Complexity Measures
# ─────────────────────────────────────────────────────────

def shadow_lower_bound(support: Set[Exponent], n_vars: int) -> int:
    """
    Compute the shadow lower bound: |Sh₂(S)|.

    This is a lower bound on the Hessian sparsity complexity
    that applies to any polynomial with support S over characteristic zero.

    Parameters
    ----------
    support : Set[Exponent]
        The support set.
    n_vars : int
        Number of variables.

    Returns
    -------
    int
        The shadow lower bound.
    """
    return len(compute_quadratic_shadow(support, n_vars))


def hessian_entry_count(coefficients: CoefficientMap, n_vars: int) -> int:
    """
    Compute the total Hessian entry count: sum over all (i,j) of |support(∂ᵢ∂ⱼp)|.

    Parameters
    ----------
    coefficients : CoefficientMap
        The polynomial.
    n_vars : int
        Number of variables.

    Returns
    -------
    int
        Total count of nonzero Hessian entries.
    """
    total = 0
    for i in range(n_vars):
        for j in range(n_vars):
            total += len(compute_actual_hessian_support(coefficients, n_vars, i, j))
    return total


def shadow_hessian_count(support: Set[Exponent], n_vars: int) -> int:
    """
    Compute the shadow-predicted total Hessian entry count.

    By Theorem 2, this equals the actual hessian_entry_count over char zero.

    Parameters
    ----------
    support : Set[Exponent]
        The support set.
    n_vars : int
        Number of variables.

    Returns
    -------
    int
        Shadow-predicted total.
    """
    total = 0
    for i in range(n_vars):
        for j in range(n_vars):
            total += len(compute_quad_leaf_set(support, n_vars, i, j))
    return total


# ─────────────────────────────────────────────────────────
# Algorithm 6: Hessian Scalar Analysis
# ─────────────────────────────────────────────────────────

def hessian_scalar(beta: Exponent, i: int, j: int) -> int:
    """
    Compute the derivative scalar factor for ∂ᵢ(∂ⱼ) at exponent β.

    The scalar is ((β + eⱼ)[i] + 1) · (β[j] + 1). Over ℚ this is
    always nonzero (it's a product of positive integers). Over F_p
    it may vanish, causing spurious cancellations.

    Parameters
    ----------
    beta : Exponent
        The output exponent.
    i, j : int
        Variable indices.

    Returns
    -------
    int
        The scalar factor (always positive over ℤ).
    """
    beta_j_plus_1 = beta[j] + 1
    beta_plus_ej_i = beta[i] + (1 if i == j else 0)
    return (beta_plus_ej_i + 1) * beta_j_plus_1


def find_finite_field_cancellations(support: Set[Exponent],
                                     n_vars: int,
                                     characteristic: int) -> List[dict]:
    """
    Find all derivative scalar factors that vanish mod p.

    These are the exponent/variable combinations where finite characteristic
    causes spurious cancellations that don't occur over ℚ.

    Parameters
    ----------
    support : Set[Exponent]
        The support set.
    n_vars : int
        Number of variables.
    characteristic : int
        The field characteristic (prime).

    Returns
    -------
    List[dict]
        List of cancellation records.
    """
    cancellations = []
    for alpha in support:
        for i in range(n_vars):
            if alpha[i] < 1:
                continue
            mid = list(alpha)
            mid[i] -= 1
            for j in range(n_vars):
                if mid[j] < 1:
                    continue
                beta = list(mid)
                beta[j] -= 1
                beta_t = tuple(beta)
                scalar = hessian_scalar(beta_t, i, j)
                if scalar % characteristic == 0:
                    cancellations.append({
                        'alpha': alpha,
                        'beta': beta_t,
                        'i': i, 'j': j,
                        'scalar': scalar,
                        'characteristic': characteristic,
                    })
    return cancellations


# ─────────────────────────────────────────────────────────
# Example Usage
# ─────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Algorithm Examples ===\n")

    # Example 1: Shadow computation
    S = {(3, 1, 0), (1, 2, 1), (2, 0, 2)}
    print(f"Support S = {S}")
    shadow = compute_quadratic_shadow(S, 3)
    print(f"Quadratic shadow = {shadow}")
    print(f"Shadow lower bound = {shadow_lower_bound(S, 3)}")
    print(f"Shadow-closed? {is_shadow_closed(S, 3)}")
    print()

    # Example 2: Certificate verification
    coeffs = {
        (2, 1): Fraction(3),
        (1, 2): Fraction(2),
        (1, 0): Fraction(1),
        (0, 1): Fraction(1),
        (0, 0): Fraction(1),
    }
    ok, witness = verify_certificate(coeffs, 2)
    print(f"Certificate for dense poly: {ok}")
    print()

    # Example 3: Theorem 1 verification
    ok, details = verify_theorem1(coeffs, 2)
    print(f"Theorem 1 verification: {ok}")
    for d in details:
        print(f"  ∂_{d['i']}∂_{d['j']}: match={d['match']}")
    print()

    # Example 4: Finite field analysis
    S2 = {(4, 0), (0, 4), (2, 2)}
    cancellations = find_finite_field_cancellations(S2, 2, 2)
    print(f"F_2 cancellations for x^4 + y^4 + x²y²: {len(cancellations)} found")
