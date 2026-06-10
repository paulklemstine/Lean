#!/usr/bin/env python3
"""
Higher-Order Shadow Certificates: Core Algorithms

Implements the computational theory of support shadows and iterated
differentiation for sparse multivariate polynomials.

All algorithms work over exact rational arithmetic (fractions.Fraction)
to match the characteristic-zero field setting of the formal theory.
"""

from fractions import Fraction
from collections import defaultdict
from typing import Dict, Tuple, List, Set, FrozenSet, Optional
import itertools

# ────────────────────────────────────────────────────────────────────
# Type Definitions
# ────────────────────────────────────────────────────────────────────

MultiIndex = Tuple[int, ...]
SparsePolynomial = Dict[MultiIndex, Fraction]
Support = FrozenSet[MultiIndex]


# ────────────────────────────────────────────────────────────────────
# Multi-Index Arithmetic
# ────────────────────────────────────────────────────────────────────

def add_mi(a: MultiIndex, b: MultiIndex) -> MultiIndex:
    """Coordinate-wise addition of multi-indices."""
    return tuple(x + y for x, y in zip(a, b))

def sub_mi(a: MultiIndex, b: MultiIndex) -> MultiIndex:
    """Coordinate-wise subtraction. Requires b ≤ a."""
    return tuple(x - y for x, y in zip(a, b))

def le_mi(a: MultiIndex, b: MultiIndex) -> bool:
    """Coordinate-wise ≤ comparison."""
    return all(x <= y for x, y in zip(a, b))

def weight(gamma: MultiIndex) -> int:
    """Total weight |γ| = sum of all components."""
    return sum(gamma)

def zero_mi(n: int) -> MultiIndex:
    """Zero multi-index in n variables."""
    return tuple(0 for _ in range(n))


# ────────────────────────────────────────────────────────────────────
# Algorithm 1: Falling Factorial Multi-Index Product
# ────────────────────────────────────────────────────────────────────

def desc_factorial(n: int, k: int) -> int:
    """Descending factorial: n · (n-1) · ... · (n-k+1).

    Time: O(k)
    Space: O(1)
    """
    result = 1
    for i in range(k):
        result *= (n - i)
    return result

def falling_factorial_multi(beta: MultiIndex, gamma: MultiIndex) -> Fraction:
    """The falling factorial multi-index product:
    ∏ᵢ descFactorial((β+γ)(i), γ(i))

    This is the scalar factor in the coefficient formula for ∂^γ p.
    Always positive over ℚ.

    Time: O(n) where n = number of variables
    Space: O(1)

    >>> falling_factorial_multi((1, 2), (1, 1))
    Fraction(6, 1)
    >>> falling_factorial_multi((0, 0), (2, 3))
    Fraction(12, 1)
    """
    result = Fraction(1)
    for b, g in zip(beta, gamma):
        result *= Fraction(desc_factorial(b + g, g))
    return result


# ────────────────────────────────────────────────────────────────────
# Algorithm 2: Shadow Along a Multi-Index
# ────────────────────────────────────────────────────────────────────

def shadow_along(S: Support, gamma: MultiIndex) -> Support:
    """Compute Shadow_γ(S) = {α - γ | α ∈ S, γ ≤ α}.

    Time: O(|S| · n) where n = number of variables
    Space: O(|Shadow_γ(S)|)

    The shadow is always injective (each β has at most one ancestor α = β + γ),
    so |Shadow_γ(S)| ≤ |S|.

    >>> S = frozenset([(2, 1), (3, 0), (1, 2)])
    >>> shadow_along(S, (1, 0))
    frozenset({(1, 1), (2, 0), (0, 2)})
    """
    result = set()
    for alpha in S:
        if le_mi(gamma, alpha):
            result.add(sub_mi(alpha, gamma))
    return frozenset(result)


# ────────────────────────────────────────────────────────────────────
# Algorithm 3: Total Shadow of Order k
# ────────────────────────────────────────────────────────────────────

def enumerate_multi_indices(k: int, n: int) -> List[MultiIndex]:
    """Enumerate all multi-indices of total weight k in n variables.

    Uses stars-and-bars enumeration.

    Time: O(C(k+n-1, n-1)) — the number of such multi-indices
    Space: O(C(k+n-1, n-1))
    """
    if n == 0:
        return [()] if k == 0 else []
    if n == 1:
        return [(k,)]
    result = []
    for i in range(k + 1):
        for rest in enumerate_multi_indices(k - i, n - 1):
            result.append((i,) + rest)
    return result

def total_shadow_order(k: int, S: Support, n_vars: int) -> Support:
    """Compute Shadow^(k)(S) = ⋃_{|γ|=k} Shadow_γ(S).

    Time: O(C(k+n-1,n-1) · |S| · n)
    Space: O(|Shadow^(k)(S)|)

    >>> S = frozenset([(2, 2), (3, 1)])
    >>> total_shadow_order(1, S, 2)
    frozenset({(1, 2), (2, 1), (2, 0), (3, 0)})
    """
    result = set()
    for gamma in enumerate_multi_indices(k, n_vars):
        result.update(shadow_along(S, gamma))
    return frozenset(result)


# ────────────────────────────────────────────────────────────────────
# Algorithm 4: Iterated Partial Derivative (Exact)
# ────────────────────────────────────────────────────────────────────

def iterated_pderiv(poly: SparsePolynomial, gamma: MultiIndex) -> SparsePolynomial:
    """Compute ∂^γ p using the coefficient formula:
    coeff_β(∂^γ p) = coeff_{β+γ}(p) · fallingFactorialMulti(β, γ)

    Time: O(|supp(p)| · n)
    Space: O(|supp(∂^γ p)|) = O(|Shadow_γ(supp p)|) ≤ O(|supp(p)|)

    >>> p = {(2, 1): Fraction(3), (1, 2): Fraction(-5)}
    >>> iterated_pderiv(p, (1, 1))
    {(1, 0): Fraction(6, 1), (0, 1): Fraction(-10, 1)}
    """
    result: SparsePolynomial = {}
    for alpha, c in poly.items():
        if le_mi(gamma, alpha):
            beta = sub_mi(alpha, gamma)
            scalar = falling_factorial_multi(beta, gamma)
            result[beta] = c * scalar  # No accumulation needed (unique ancestors)
    return {k: v for k, v in result.items() if v != 0}


# ────────────────────────────────────────────────────────────────────
# Algorithm 5: Higher-Order Shadow Audit
# ────────────────────────────────────────────────────────────────────

def audit_shadow_certificate(
    k: int,
    poly: SparsePolynomial,
    n_vars: int
) -> List[Dict]:
    """Audit all order-k derivatives against shadow predictions.

    For each multi-index γ of weight k:
    1. Compute predicted support = Shadow_γ(supp p)
    2. Compute actual support = supp(∂^γ p)
    3. Compare and report

    Time: O(C(k+n-1,n-1) · |supp(p)| · n)

    Returns list of audit records, one per γ.
    """
    S = frozenset(poly.keys())
    records = []
    for gamma in enumerate_multi_indices(k, n_vars):
        predicted = shadow_along(S, gamma)
        deriv = iterated_pderiv(poly, gamma)
        actual = frozenset(deriv.keys())
        records.append({
            'gamma': gamma,
            'weight': k,
            'predicted_support': predicted,
            'actual_support': actual,
            'is_exact_match': predicted == actual,
            'predicted_size': len(predicted),
            'actual_size': len(actual),
            'missing_from_actual': predicted - actual,
            'extra_in_actual': actual - predicted,
        })
    return records


# ────────────────────────────────────────────────────────────────────
# Algorithm 6: Derivative Family Complexity
# ────────────────────────────────────────────────────────────────────

def derivative_family_complexity(k: int, S: Support, n_vars: int) -> int:
    """Compute the derivative family complexity at order k.

    This is |Shadow^(k)(S)| — the number of distinct exponents appearing
    across all order-k derivative supports.

    By the exact support theorem, this equals the total number of nonzero
    coefficients across all order-k derivatives (over char 0).

    Time: O(C(k+n-1,n-1) · |S| · n)
    """
    return len(total_shadow_order(k, S, n_vars))


# ────────────────────────────────────────────────────────────────────
# Algorithm 7: Shadow Profile
# ────────────────────────────────────────────────────────────────────

def shadow_profile(S: Support, n_vars: int, max_order: int) -> List[int]:
    """Compute the shadow profile: k ↦ |Shadow^(k)(S)| for k = 0, ..., max_order.

    This predicts the "derivative complexity curve" of any polynomial
    with the given support.

    Time: O(max_order · C(max_order+n-1,n-1) · |S| · n)
    """
    return [derivative_family_complexity(k, S, n_vars) for k in range(max_order + 1)]


# ────────────────────────────────────────────────────────────────────
# Algorithm 8: Support Prediction (Skip Full Derivative)
# ────────────────────────────────────────────────────────────────────

def predict_derivative_support(S: Support, gamma: MultiIndex) -> Support:
    """Predict the support of ∂^γ p without computing the derivative.

    This is the key algorithmic application: we can determine which monomials
    will appear in the derivative purely from the support, without touching
    the coefficients at all.

    Time: O(|S| · n)
    Space: O(|Shadow_γ(S)|)
    """
    return shadow_along(S, gamma)


# ────────────────────────────────────────────────────────────────────
# Algorithm 9: One-Ancestor Verification
# ────────────────────────────────────────────────────────────────────

def verify_one_ancestor(S: Support, gamma: MultiIndex) -> bool:
    """Verify the one-ancestor property for Shadow_γ(S).

    Each element β of the shadow has exactly one ancestor α = β + γ in S.
    This ALWAYS returns True because the map β ↦ β + γ is injective.

    Time: O(|S| · n)
    """
    shadow = shadow_along(S, gamma)
    for beta in shadow:
        alpha = add_mi(beta, gamma)
        if alpha not in S:
            return False  # Cannot happen by construction
    return True


# ────────────────────────────────────────────────────────────────────
# Random Polynomial Generation
# ────────────────────────────────────────────────────────────────────

def random_sparse_polynomial(
    n_vars: int,
    max_degree: int,
    n_terms: int,
    coeff_range: int = 10,
    seed: Optional[int] = None
) -> SparsePolynomial:
    """Generate a random sparse polynomial with rational coefficients.

    Args:
        n_vars: Number of variables
        max_degree: Maximum degree per variable
        n_terms: Target number of terms
        coeff_range: Coefficients in [-coeff_range, coeff_range]
        seed: Random seed for reproducibility
    """
    import random
    if seed is not None:
        random.seed(seed)

    poly: SparsePolynomial = {}
    attempts = 0
    while len(poly) < n_terms and attempts < n_terms * 10:
        exp = tuple(random.randint(0, max_degree) for _ in range(n_vars))
        if exp not in poly:
            c = random.randint(-coeff_range, coeff_range)
            if c != 0:
                poly[exp] = Fraction(c)
        attempts += 1
    return poly


if __name__ == "__main__":
    # Quick demo
    print("=== Higher-Order Shadow Algorithms Demo ===\n")

    # Create a simple polynomial
    p = {(2, 1, 0): Fraction(3), (1, 2, 1): Fraction(-5),
         (3, 0, 2): Fraction(7), (0, 3, 1): Fraction(2)}
    S = frozenset(p.keys())

    print(f"Polynomial support: {sorted(S)}")
    print(f"Shadow profile: {shadow_profile(S, 3, 5)}")
    print()

    # Audit order-2 derivatives
    audit = audit_shadow_certificate(2, p, 3)
    print("Order-2 derivative audit:")
    for rec in audit:
        gamma = rec['gamma']
        print(f"  γ={gamma}: predicted={rec['predicted_size']} terms, "
              f"actual={rec['actual_size']} terms, match={rec['is_exact_match']}")
    print()

    # Verify one-ancestor property
    gamma = (1, 1, 0)
    print(f"One-ancestor property for γ={gamma}: {verify_one_ancestor(S, gamma)}")
    print(f"Predicted support for ∂^{gamma}: {sorted(predict_derivative_support(S, gamma))}")
    actual = iterated_pderiv(p, gamma)
    print(f"Actual derivative ∂^{gamma} p:")
    for beta in sorted(actual.keys()):
        print(f"  x^{beta}: {actual[beta]}")
