#!/usr/bin/env python3
"""
algorithms.py — Verified algorithms for k-shadow computation and support checking.

Implements the core algorithmic content of the Higher-Order Anti-Cancellation theorem:
- derivMultiShadow: compute the shadow of a support under a derivative multi-index
- weightedKShadow: compute the union of shadows
- fallingMultinomial: compute the multiplicity factor
- aggDerivCoeff: compute the aggregate derivative coefficient
- verifyAntiCancellation: check the main theorem computationally
"""

import itertools
from typing import Dict, FrozenSet, List, Optional, Set, Tuple

ExponentVector = Tuple[int, ...]


def deriv_multi_shadow(support: Set[ExponentVector],
                       m: ExponentVector) -> Set[ExponentVector]:
    """
    Compute derivMultiShadow(S, m) = {e - m | e ∈ S, m ≤ e componentwise}.

    This is the set of exponent vectors reachable by "eroding" each support
    element by the multi-index m. Corresponds to the support of ∂^m p
    restricted to contributions from S.

    Time complexity: O(|S| * n) where n = len(m)
    Space complexity: O(|shadow|)

    Args:
        support: Set of exponent vectors (the polynomial support)
        m: Derivative multi-index

    Returns:
        The shadow set

    Example:
        >>> S = {(2, 1), (1, 2), (3, 0)}
        >>> deriv_multi_shadow(S, (1, 1))
        {(1, 0), (0, 1)}
    """
    shadow = set()
    n = len(m)
    for e in support:
        if all(e[i] >= m[i] for i in range(n)):
            d = tuple(e[i] - m[i] for i in range(n))
            shadow.add(d)
    return shadow


def weighted_k_shadow(support: Set[ExponentVector],
                      active_indices: Set[ExponentVector]) -> Set[ExponentVector]:
    """
    Compute weightedKShadow(S, T) = ⋃_{m ∈ T} derivMultiShadow(S, m).

    Time complexity: O(|T| * |S| * n)
    Space complexity: O(|shadow|)

    Args:
        support: Set of exponent vectors
        active_indices: Set of active derivative multi-indices

    Returns:
        Union of all derivative shadows
    """
    shadow = set()
    for m in active_indices:
        shadow |= deriv_multi_shadow(support, m)
    return shadow


def desc_factorial(n: int, k: int) -> int:
    """
    Compute the descending factorial n * (n-1) * ... * (n-k+1).

    Time complexity: O(k)
    """
    result = 1
    for i in range(k):
        result *= (n - i)
    return result


def falling_multinomial(m: ExponentVector, d: ExponentVector) -> int:
    """
    Compute the falling multinomial coefficient:
        ∏_i descFactorial(d[i] + m[i], m[i])

    This represents the multiplicity factor when differentiating a monomial
    x^(d+m) by multi-index m, yielding a coefficient at exponent d.

    Key property: This is always positive (> 0) since d[i]+m[i] >= m[i].

    Time complexity: O(n * max(m[i]))
    """
    result = 1
    for i in range(len(m)):
        if m[i] > 0:
            result *= desc_factorial(d[i] + m[i], m[i])
    return result


def agg_deriv_coeff(poly: Dict[ExponentVector, float],
                    weights: Dict[ExponentVector, float],
                    d: ExponentVector) -> float:
    """
    Compute the aggregate derivative coefficient at exponent d:
        ∑_{m ∈ supp(A)} A(m) * fallingMultinomial(m, d) * coeff(d+m, p)

    Time complexity: O(|supp(A)| * n)
    """
    total = 0.0
    n = len(d)
    for m, w in weights.items():
        e = tuple(d[i] + m[i] for i in range(n))
        coeff = poly.get(e, 0.0)
        if coeff != 0:
            fm = falling_multinomial(m, d)
            total += w * fm * coeff
    return total


def compute_actual_support(poly: Dict[ExponentVector, float],
                           weights: Dict[ExponentVector, float],
                           candidates: Set[ExponentVector],
                           tol: float = 1e-12) -> Set[ExponentVector]:
    """
    Compute the actual support of the weighted derivative aggregate.

    Time complexity: O(|candidates| * |supp(A)| * n)
    """
    return {d for d in candidates
            if abs(agg_deriv_coeff(poly, weights, d)) > tol}


def verify_anti_cancellation(poly: Dict[ExponentVector, float],
                              weights: Dict[ExponentVector, float]) -> Dict:
    """
    Verify the anti-cancellation theorem for a given polynomial and weights.

    Checks that:
    1. All coefficients are nonneg
    2. All weights are positive
    3. The actual support equals the predicted k-shadow

    Returns a dict with verification results.

    Example:
        >>> poly = {(2, 0): 1.0, (1, 1): 2.0, (0, 2): 1.0}
        >>> weights = {(1, 0): 1.0, (0, 1): 1.5}
        >>> result = verify_anti_cancellation(poly, weights)
        >>> result['theorem_holds']
        True
    """
    support = set(poly.keys())
    active = set(weights.keys())

    # Check hypotheses
    all_nonneg = all(c >= 0 for c in poly.values())
    all_positive_weights = all(w > 0 for w in weights.values())

    # Compute predicted shadow
    predicted = weighted_k_shadow(support, active)

    # Compute actual support
    actual = compute_actual_support(poly, weights, predicted)

    # Check equality
    theorem_holds = (actual == predicted)

    # Compute overlap multiplicities
    overlap_counts = {}
    for d in predicted:
        count = 0
        for m in active:
            n = len(d)
            e = tuple(d[i] + m[i] for i in range(n))
            if e in support:
                count += 1
        overlap_counts[d] = count

    return {
        'all_nonneg': all_nonneg,
        'all_positive_weights': all_positive_weights,
        'hypotheses_satisfied': all_nonneg and all_positive_weights,
        'predicted_shadow_size': len(predicted),
        'actual_support_size': len(actual),
        'theorem_holds': theorem_holds,
        'cancelled_monomials': predicted - actual,
        'overlap_multiplicities': overlap_counts,
        'avg_overlap': (sum(overlap_counts.values()) / len(overlap_counts)
                       if overlap_counts else 0),
    }


def enumerate_multi_indices(n: int, k: int) -> List[ExponentVector]:
    """
    Enumerate all multi-indices m of length n with sum(m) = k.

    These are the weak compositions of k into n parts.

    Time complexity: O(C(n+k-1, k))
    """
    if n == 0:
        return [()]
    if n == 1:
        return [(k,)]
    result = []
    for first in range(k + 1):
        for rest in enumerate_multi_indices(n - 1, k - first):
            result.append((first,) + rest)
    return result


def shadow_composition_check(support: Set[ExponentVector],
                              m: ExponentVector,
                              n_vec: ExponentVector) -> bool:
    """
    Verify the semigroup law: shadow_n(shadow_m(S)) = shadow_{m+n}(S).

    This is the derivMultiShadow_add theorem.
    """
    shadow_m = deriv_multi_shadow(support, m)
    shadow_n_of_m = deriv_multi_shadow(shadow_m, n_vec)

    mn_sum = tuple(m[i] + n_vec[i] for i in range(len(m)))
    shadow_mn = deriv_multi_shadow(support, mn_sum)

    return shadow_n_of_m == shadow_mn


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    # Example 1: Simple polynomial
    print("Example 1: Simple polynomial p = x^2 + 2xy + y^2")
    poly = {(2, 0): 1.0, (1, 1): 2.0, (0, 2): 1.0}
    weights = {(1, 0): 1.0, (0, 1): 1.5}

    result = verify_anti_cancellation(poly, weights)
    print(f"  Hypotheses satisfied: {result['hypotheses_satisfied']}")
    print(f"  Predicted shadow size: {result['predicted_shadow_size']}")
    print(f"  Actual support size: {result['actual_support_size']}")
    print(f"  Theorem holds: {result['theorem_holds']}")

    # Example 2: Semigroup law verification
    print("\nExample 2: Semigroup law verification")
    support = {(3, 2, 1), (2, 3, 0), (1, 1, 3), (4, 0, 2)}
    m = (1, 0, 1)
    n = (0, 1, 0)
    holds = shadow_composition_check(support, m, n)
    print(f"  shadow_n(shadow_m(S)) = shadow_{m+n}(S): {holds}")

    # Example 3: Full verification pipeline
    print("\nExample 3: Uniform matroid U(3,5)")
    from demo import uniform_matroid_basis_polynomial
    poly_u35 = uniform_matroid_basis_polynomial(3, 5)
    indices_k2 = enumerate_multi_indices(5, 2)
    weights_k2 = {m: 1.0 for m in indices_k2}
    result = verify_anti_cancellation(poly_u35, weights_k2)
    print(f"  Shadow size: {result['predicted_shadow_size']}")
    print(f"  Theorem holds: {result['theorem_holds']}")
    print(f"  Avg overlap: {result['avg_overlap']:.2f}")
