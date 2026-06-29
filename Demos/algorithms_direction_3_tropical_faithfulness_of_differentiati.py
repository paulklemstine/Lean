#!/usr/bin/env python3
"""
Tropical Faithfulness of Differentiation — Core Algorithms

Implements verified algorithms for:
1. Mixed derivative support computation via shadow
2. Actual mixed derivative support computation
3. Newton polytope comparison (2D/3D)
4. Non-cancellation certificate detection
5. Support function computation

All algorithms have documented complexity analysis.
"""

from typing import Dict, Tuple, Set, List, Optional, FrozenSet
from collections import defaultdict
import random


# Type aliases
Exponent = Tuple[int, ...]
Polynomial = Dict[Exponent, float]


# ──────────────────────────────────────────────────────────────────
# Algorithm 1: Sparse Polynomial Differentiation
# ──────────────────────────────────────────────────────────────────

def partial_derivative(poly: Polynomial, var: int, n_vars: int) -> Polynomial:
    """
    Compute the partial derivative ∂/∂xᵥₐᵣ of a sparse polynomial.

    Time:  O(|supp(p)|)
    Space: O(|supp(p)|)

    Args:
        poly: Sparse polynomial as {exponent_tuple: coefficient}
        var: Variable index to differentiate by
        n_vars: Total number of variables

    Returns:
        The partial derivative as a sparse polynomial.

    Example:
        >>> partial_derivative({(2, 1): 3, (1, 0): 5}, 0, 2)
        {(1, 1): 6, (0, 0): 5}
    """
    result: Polynomial = {}
    for exp, coeff in poly.items():
        e = list(exp)
        if e[var] >= 1:
            new_coeff = coeff * e[var]
            e[var] -= 1
            new_exp = tuple(e)
            result[new_exp] = result.get(new_exp, 0) + new_coeff
    return {k: v for k, v in result.items() if abs(v) > 1e-12}


def mixed_partial_derivative(poly: Polynomial, i: int, j: int,
                              n_vars: int) -> Polynomial:
    """
    Compute the mixed partial derivative ∂ᵢ(∂ⱼ p).

    Time:  O(|supp(p)|)
    Space: O(|supp(p)|)

    Each monomial cᵅ·Xᵅ contributes at most one term to the output.
    The coefficient at β is c_{β+eᵢ+eⱼ} · (βᵢ+1) · ((β+eᵢ)ⱼ+1).

    Example:
        >>> mixed_partial_derivative({(2, 1): 1}, 0, 1, 2)
        {(1, 0): 2}
    """
    return partial_derivative(partial_derivative(poly, j, n_vars), i, n_vars)


# ──────────────────────────────────────────────────────────────────
# Algorithm 2: Mixed Shadow Computation
# ──────────────────────────────────────────────────────────────────

def compute_mixed_shadow(support_set: Set[Exponent], i: int, j: int,
                          n_vars: int) -> Set[Exponent]:
    """
    Compute the mixed shadow of a support set for directions (i, j).

    shadow(S, i, j) = {β : β + eᵢ + eⱼ ∈ S}

    Time:  O(|S|)
    Space: O(|S|)

    This is the combinatorial prediction of which monomials appear
    in ∂ᵢ∂ⱼ p, purely from the support, ignoring coefficients.

    Example:
        >>> compute_mixed_shadow({(2, 1), (1, 2)}, 0, 1, 2)
        {(1, 0), (0, 1)}
    """
    shadow = set()
    for alpha in support_set:
        beta = list(alpha)
        beta[i] -= 1
        beta[j] -= 1
        if all(b >= 0 for b in beta):
            shadow.add(tuple(beta))
    return shadow


def compute_aggregate_shadow(support_set: Set[Exponent],
                              weights: List[List[float]],
                              n_vars: int) -> Set[Exponent]:
    """
    Compute the aggregate shadow: ⋃{shadow(S,i,j) : w(i,j) ≠ 0}.

    Time:  O(n² · |S|)
    Space: O(n² · |S|)

    Example:
        >>> compute_aggregate_shadow({(2, 1)}, [[1, 0], [0, 1]], 2)
        {(0, 1), (1, 0)}
    """
    result = set()
    for i in range(n_vars):
        for j in range(n_vars):
            if abs(weights[i][j]) > 1e-12:
                result |= compute_mixed_shadow(support_set, i, j, n_vars)
    return result


# ──────────────────────────────────────────────────────────────────
# Algorithm 3: Non-Cancellation Certificate Detection
# ──────────────────────────────────────────────────────────────────

def check_individual_certificate(poly: Polynomial, i: int, j: int,
                                  n_vars: int) -> Tuple[bool, Set[Exponent]]:
    """
    Check individual mixed partial certificate (always True in char 0).

    Time:  O(|supp(p)|)
    Space: O(|supp(p)|)

    Returns:
        (certificate_holds, set_of_failing_exponents)

    In characteristic zero, this always returns (True, ∅).
    """
    mp = mixed_partial_derivative(poly, i, j, n_vars)
    shadow = compute_mixed_shadow(set(poly.keys()), i, j, n_vars)
    actual = set(k for k, v in mp.items() if abs(v) > 1e-12)
    failing = shadow - actual
    return (len(failing) == 0, failing)


def check_aggregate_certificate(poly: Polynomial,
                                 weights: List[List[float]],
                                 n_vars: int) -> Tuple[bool, Set[Exponent]]:
    """
    Check aggregate non-cancellation certificate.

    Time:  O(n² · |supp(p)|)
    Space: O(n² · |supp(p)|)

    Returns:
        (certificate_holds, set_of_failing_exponents)

    The certificate fails when there exist exponents in the aggregate
    shadow that don't appear in the aggregate's support.
    """
    # Compute aggregate polynomial
    agg: Polynomial = {}
    for i in range(n_vars):
        for j in range(n_vars):
            w = weights[i][j]
            if abs(w) < 1e-12:
                continue
            mp = mixed_partial_derivative(poly, i, j, n_vars)
            for exp, coeff in mp.items():
                agg[exp] = agg.get(exp, 0) + w * coeff

    agg_support = set(k for k, v in agg.items() if abs(v) > 1e-12)
    agg_shadow = compute_aggregate_shadow(set(poly.keys()), weights, n_vars)
    failing = agg_shadow - agg_support
    return (len(failing) == 0, failing)


# ──────────────────────────────────────────────────────────────────
# Algorithm 4: Newton Polytope (Convex Hull)
# ──────────────────────────────────────────────────────────────────

def convex_hull_2d(points: List[Tuple[float, float]]) -> List[Tuple[float, float]]:
    """
    Compute 2D convex hull using Andrew's monotone chain algorithm.

    Time:  O(n log n)
    Space: O(n)

    Returns vertices in counterclockwise order.
    """
    if len(points) <= 1:
        return list(points)
    points = sorted(set(points))
    if len(points) <= 2:
        return points

    def cross(O, A, B):
        return (A[0] - O[0]) * (B[1] - O[1]) - (A[1] - O[1]) * (B[0] - O[0])

    lower = []
    for p in points:
        while len(lower) >= 2 and cross(lower[-2], lower[-1], p) <= 0:
            lower.pop()
        lower.append(p)
    upper = []
    for p in reversed(points):
        while len(upper) >= 2 and cross(upper[-2], upper[-1], p) <= 0:
            upper.pop()
        upper.append(p)
    return lower[:-1] + upper[:-1]


def newton_polytope_vertices(poly: Polynomial) -> List[Exponent]:
    """
    Compute vertices of the Newton polytope (2D).

    Time:  O(|supp(p)| log |supp(p)|)
    Space: O(|supp(p)|)
    """
    supp = [k for k, v in poly.items() if abs(v) > 1e-12]
    if not supp:
        return []
    if len(supp[0]) != 2:
        raise ValueError("Only 2D polytopes supported by this function")
    pts = [(float(s[0]), float(s[1])) for s in supp]
    hull = convex_hull_2d(pts)
    return [(int(h[0]), int(h[1])) for h in hull]


def compare_newton_polytopes(poly1: Polynomial,
                              poly2: Polynomial) -> str:
    """
    Compare Newton polytopes of two polynomials.

    Returns: 'equal', 'subset', 'superset', or 'incomparable'
    """
    v1 = set(map(tuple, newton_polytope_vertices(poly1)))
    v2 = set(map(tuple, newton_polytope_vertices(poly2)))
    if v1 == v2:
        return 'equal'
    elif v1 < v2:
        return 'subset'
    elif v2 < v1:
        return 'superset'
    else:
        return 'incomparable'


# ──────────────────────────────────────────────────────────────────
# Algorithm 5: Support Function
# ──────────────────────────────────────────────────────────────────

def support_function(support_set: Set[Exponent],
                     direction: Tuple[float, ...]) -> float:
    """
    Compute the support function h_S(w) = max{⟨w, α⟩ : α ∈ S}.

    Time:  O(|S| · n)
    Space: O(1)

    The support function characterizes a convex body via its
    boundary in each direction. For Newton polytopes, this gives
    the maximum weighted degree.
    """
    if not support_set:
        return float('-inf')
    return max(
        sum(direction[k] * alpha[k] for k in range(len(direction)))
        for alpha in support_set
    )


def verify_support_function_shift(support_set: Set[Exponent],
                                   i: int, j: int, n_vars: int,
                                   directions: List[Tuple[float, ...]]) -> bool:
    """
    Verify Theorem 5: h_shadow(w) = h_S(w) - (wᵢ + wⱼ) for all given directions.

    Time:  O(|directions| · |S| · n)
    """
    shadow = compute_mixed_shadow(support_set, i, j, n_vars)
    if not shadow:
        return True  # vacuously true

    for w in directions:
        h_S = support_function(support_set, w)
        h_shadow = support_function(shadow, w)
        predicted = h_S - (w[i] + w[j])
        if abs(h_shadow - predicted) > 1e-10:
            return False
    return True


# ──────────────────────────────────────────────────────────────────
# Algorithm 6: Random Polynomial Generator
# ──────────────────────────────────────────────────────────────────

def random_sparse_polynomial(n_vars: int, max_degree: int,
                              n_terms: int,
                              coeff_range: range = range(-5, 6)) -> Polynomial:
    """
    Generate a random sparse polynomial.

    Args:
        n_vars: Number of variables
        max_degree: Maximum degree in each variable
        n_terms: Number of nonzero terms
        coeff_range: Range for random coefficients

    Returns:
        Random sparse polynomial with guaranteed nonzero coefficients.
    """
    poly: Polynomial = {}
    attempts = 0
    while len(poly) < n_terms and attempts < n_terms * 10:
        exp = tuple(random.randint(0, max_degree) for _ in range(n_vars))
        coeff = random.choice([c for c in coeff_range if c != 0])
        poly[exp] = coeff
        attempts += 1
    return poly


# ──────────────────────────────────────────────────────────────────
# Main: Run all algorithm tests
# ──────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Algorithm Tests")
    print("=" * 50)

    # Test 1: Individual certificate (always holds)
    p = {(3, 1): 2, (2, 2): -1, (1, 3): 3, (0, 1): 1}
    holds, failing = check_individual_certificate(p, 0, 1, 2)
    print(f"Individual certificate: {holds} (failing: {failing})")
    assert holds, "Individual certificate should always hold in char 0"

    # Test 2: Aggregate certificate (can fail)
    weights = [[0, 1], [-1, 0]]
    holds, failing = check_aggregate_certificate(p, weights, 2)
    print(f"Aggregate certificate (antisym): {holds} (failing: {failing})")

    # Test 3: Support function shift
    supp = {(3, 2), (2, 3), (1, 1)}
    dirs = [(1, 0), (0, 1), (1, 1), (2, 1)]
    ok = verify_support_function_shift(supp, 0, 1, 2, dirs)
    print(f"Support function shift: {ok}")
    assert ok, "Support function shift should hold"

    # Test 4: Random testing
    n_faithful = 0
    n_total = 100
    for _ in range(n_total):
        p = random_sparse_polynomial(2, 4, 5)
        holds, _ = check_individual_certificate(p, 0, 1, 2)
        if holds:
            n_faithful += 1
    print(f"Random individual certificates: {n_faithful}/{n_total} hold")
    assert n_faithful == n_total, "All individual certificates should hold"

    print("\nAll tests passed! ✓")
