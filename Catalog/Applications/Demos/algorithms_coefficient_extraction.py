#!/usr/bin/env python3
"""
Algorithms for Coefficient Extraction and Nullstellensatz Applications

Implements the coefficient extraction transform, Lagrange interpolation,
and applications to combinatorial problems.
"""

from fractions import Fraction
from itertools import product
from typing import List, Dict, Tuple, Optional, Set
from functools import reduce
from operator import mul


# ============================================================
# Algorithm 1: Coefficient Extraction Transform
# ============================================================

def lagrange_denominator(S: List[Fraction], x: Fraction) -> Fraction:
    """
    Compute the Lagrange denominator at x with respect to S.

    lagrangeDen(S, x) = ∏_{y ∈ S, y ≠ x} (x - y)

    Time complexity: O(|S|)
    Space complexity: O(1)

    Args:
        S: List of distinct field elements
        x: Point at which to evaluate

    Returns:
        Product of (x - y) for all y in S with y ≠ x
    """
    result = Fraction(1)
    for y in S:
        if y != x:
            result *= (x - y)
    return result


def extract_coefficient(S: List[Fraction], evaluations: Dict[Fraction, Fraction]) -> Fraction:
    """
    Extract the top coefficient of a polynomial from grid evaluations.

    Given evaluations {s: p(s)} for s ∈ S, computes:
        coeff_{|S|-1}(p) = Σ_{s ∈ S} p(s) / lagrangeDen(S, s)

    This is the core coefficient extraction algorithm.

    Time complexity: O(|S|²)  (computing each denominator is O(|S|))
    Space complexity: O(|S|)

    Args:
        S: List of distinct evaluation points
        evaluations: Dictionary mapping each s ∈ S to p(s)

    Returns:
        The coefficient of x^{|S|-1} in the unique polynomial of degree < |S|
        interpolating the given evaluations.
    """
    result = Fraction(0)
    for s in S:
        den = lagrange_denominator(S, s)
        if den == 0:
            raise ValueError(f"Lagrange denominator is zero at {s}; points not distinct")
        result += evaluations[s] / den
    return result


def extract_all_coefficients(S: List[Fraction], evaluations: Dict[Fraction, Fraction]) -> List[Fraction]:
    """
    Extract ALL coefficients of a polynomial from grid evaluations,
    using iterated coefficient extraction.

    For a polynomial p of degree < |S|, returns [c_0, c_1, ..., c_{|S|-1}]
    where p(x) = Σ c_i x^i.

    Time complexity: O(|S|³)
    Space complexity: O(|S|²)

    Args:
        S: List of distinct evaluation points
        evaluations: Dictionary mapping each s ∈ S to p(s)

    Returns:
        List of coefficients [c_0, c_1, ..., c_{|S|-1}]
    """
    n = len(S)
    # Work with a copy of evaluations
    current_evals = dict(evaluations)
    coefficients = [Fraction(0)] * n

    # Extract from highest to lowest degree
    for deg in range(n - 1, -1, -1):
        # Use first deg+1 points
        points = S[:deg + 1]
        evals = {s: current_evals[s] for s in points}
        c = extract_coefficient(points, evals)
        coefficients[deg] = c
        # Subtract c * x^deg from all evaluations
        for s in S:
            current_evals[s] -= c * s**deg

    return coefficients


# ============================================================
# Algorithm 2: Multivariate Coefficient Extraction
# ============================================================

def multivariate_extract_coefficient(
    sets: List[List[Fraction]],
    evaluations: Dict[Tuple[Fraction, ...], Fraction]
) -> Fraction:
    """
    Extract the coefficient of the top monomial ∏ x_i^{|S_i|-1}
    from evaluations on a Cartesian product grid.

    Uses the multivariate extraction identity:
        coeff = Σ_{x ∈ grid} f(x) / ∏_i lagrangeDen(S_i, x_i)

    Time complexity: O(∏|S_i| × n × max|S_i|)
    Space complexity: O(∏|S_i|)

    Args:
        sets: List of sets [S_1, ..., S_n], each a list of distinct elements
        evaluations: Dictionary mapping grid points to f(x)

    Returns:
        Coefficient of ∏ x_i^{|S_i|-1}
    """
    grid = list(product(*sets))
    result = Fraction(0)

    for point in grid:
        # Compute product of inverse Lagrange denominators
        weight = Fraction(1)
        for i, (s_i, x_i) in enumerate(zip(sets, point)):
            den = lagrange_denominator(s_i, x_i)
            weight /= den
        result += evaluations[point] * weight

    return result


# ============================================================
# Algorithm 3: Nullstellensatz Witness Search
# ============================================================

def find_nullstellensatz_witness(
    sets: List[List[Fraction]],
    poly_eval_fn,
    target_coeff: Optional[Fraction] = None
) -> Optional[Tuple[Fraction, ...]]:
    """
    Find a grid point where a polynomial evaluates to nonzero,
    using the Combinatorial Nullstellensatz guarantee.

    If the coefficient of the top monomial is nonzero and variable degrees
    are bounded, a witness is guaranteed to exist.

    Time complexity: O(∏|S_i|) worst case (grid search)
    Space complexity: O(n) where n is the number of variables

    Args:
        sets: List of sets [S_1, ..., S_n]
        poly_eval_fn: Function that evaluates the polynomial at a point
        target_coeff: If provided, verify this is nonzero before searching

    Returns:
        A grid point where the polynomial is nonzero, or None if all vanish.
    """
    if target_coeff is not None and target_coeff == 0:
        return None  # Nullstellensatz does not apply

    grid = product(*sets)
    for point in grid:
        point_tuple = tuple(point)
        if poly_eval_fn(point_tuple) != Fraction(0):
            return point_tuple

    return None


# ============================================================
# Algorithm 4: Cauchy-Davenport via Coefficient Extraction
# ============================================================

def cauchy_davenport_bound(p: int, A: Set[int], B: Set[int]) -> int:
    """
    Compute the Cauchy-Davenport lower bound for |A + B| in Z/pZ.

    By the polynomial method (via Nullstellensatz):
        |A + B| ≥ min(p, |A| + |B| - 1)

    This function computes the bound, not the sumset itself.

    Args:
        p: A prime number
        A: Subset of Z/pZ
        B: Subset of Z/pZ

    Returns:
        Lower bound min(p, |A| + |B| - 1)
    """
    return min(p, len(A) + len(B) - 1)


def verify_cauchy_davenport(p: int, A: Set[int], B: Set[int]) -> dict:
    """
    Verify the Cauchy-Davenport theorem computationally for given sets.

    Computes the actual sumset A + B in Z/pZ and verifies the bound.

    Args:
        p: A prime number
        A: Subset of Z/pZ
        B: Subset of Z/pZ

    Returns:
        Dictionary with bound, actual size, and verification result
    """
    sumset = {(a + b) % p for a in A for b in B}
    bound = cauchy_davenport_bound(p, A, B)
    return {
        'p': p,
        'A': sorted(A),
        'B': sorted(B),
        'A+B': sorted(sumset),
        '|A|': len(A),
        '|B|': len(B),
        '|A+B|': len(sumset),
        'bound': bound,
        'verified': len(sumset) >= bound
    }


# ============================================================
# Demo / Self-test
# ============================================================

if __name__ == "__main__":
    print("Algorithm Self-Tests")
    print("=" * 50)

    # Test 1: Extract coefficient
    S = [Fraction(0), Fraction(1), Fraction(2)]
    # p(x) = 3x² + 2x + 1
    evals = {Fraction(0): Fraction(1), Fraction(1): Fraction(6), Fraction(2): Fraction(17)}
    c = extract_coefficient(S, evals)
    assert c == Fraction(3), f"Expected 3, got {c}"
    print(f"✓ extract_coefficient: coeff_2 = {c}")

    # Test 2: Extract all coefficients
    all_c = extract_all_coefficients(S, evals)
    assert all_c == [Fraction(1), Fraction(2), Fraction(3)], f"Expected [1,2,3], got {all_c}"
    print(f"✓ extract_all_coefficients: {all_c}")

    # Test 3: Multivariate extraction
    sets = [[Fraction(0), Fraction(1)], [Fraction(0), Fraction(1)]]
    # f(x,y) = xy - x - y + 2
    mv_evals = {}
    for pt in product(*sets):
        x, y = pt
        mv_evals[pt] = x*y - x - y + 2
    mc = multivariate_extract_coefficient(sets, mv_evals)
    assert mc == Fraction(1), f"Expected 1, got {mc}"
    print(f"✓ multivariate_extract_coefficient: coeff = {mc}")

    # Test 4: Witness search
    def test_poly(pt):
        x, y = pt
        return x*y - x - y + 2
    w = find_nullstellensatz_witness(sets, test_poly, target_coeff=Fraction(1))
    assert w is not None and test_poly(w) != 0
    print(f"✓ find_nullstellensatz_witness: witness = {w}, f(w) = {test_poly(w)}")

    # Test 5: Cauchy-Davenport
    result = verify_cauchy_davenport(7, {0, 1, 2}, {0, 3, 5})
    assert result['verified']
    print(f"✓ Cauchy-Davenport in Z/7Z: |A+B| = {result['|A+B|']} ≥ {result['bound']}")

    print("\nAll self-tests passed! ✓")
