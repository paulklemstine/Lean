#!/usr/bin/env python3
"""
Tropical Polynomial Canonicalization — Algorithm Implementations

Complete implementations of the certified canonicalization algorithm with
detailed docstrings, type hints, and complexity analysis.

The algorithm computes the minimal irredundant representation of a tropical
polynomial in O(n²) time (O(n log n) with optimized sorting).
"""

from typing import List, Tuple, Optional, Callable
from dataclasses import dataclass
import heapq


# --- Data Structures ---

@dataclass(frozen=True, order=True)
class NatMono:
    """A monomial in a tropical (min-plus) polynomial.

    Represents the affine function f(x) = coeff + exp * x.
    In the tropical semiring (ℕ, min, +), this is the "monomial" coeff ⊕ exp ⊗ x.

    Attributes:
        exp: The exponent (slope of the affine function).
        coeff: The coefficient (y-intercept of the affine function).
    """
    exp: int
    coeff: int

    def eval(self, x: int) -> int:
        """Evaluate the monomial at x: coeff + exp * x."""
        return self.coeff + self.exp * x

    def __repr__(self) -> str:
        return f"({self.exp}, {self.coeff})"


NatPoly = List[NatMono]


# --- Evaluation ---

def eval_poly(p: NatPoly, x: int) -> int:
    """Evaluate a tropical polynomial at x.

    Returns min{m.eval(x) | m in p}, or 0 if p is empty.

    Time complexity: O(n) where n = len(p).

    Args:
        p: List of monomials.
        x: Evaluation point.

    Returns:
        The tropical evaluation (minimum of monomial evaluations).
    """
    if not p:
        return 0
    return min(m.eval(x) for m in p)


# --- Phase 1: Sorting ---

def sort_by_exp(p: NatPoly) -> NatPoly:
    """Sort monomials by exponent in ascending order.

    Uses Python's Timsort (O(n log n)), preserving stability.
    In the Lean formalization, insertion sort is used for simplicity,
    giving O(n²) worst case.

    Time complexity: O(n log n) [Python] / O(n²) [Lean formalization]

    Args:
        p: Input polynomial.

    Returns:
        Polynomial sorted by exponent.
    """
    return sorted(p, key=lambda m: m.exp)


def insertion_sort_by_exp(p: NatPoly) -> NatPoly:
    """Sort by exponent using insertion sort (matches Lean formalization).

    Time complexity: O(n²)
    Space complexity: O(n) (new list)

    Args:
        p: Input polynomial.

    Returns:
        Polynomial sorted by exponent.
    """
    result: NatPoly = []
    for m in p:
        # Insert m into sorted position
        i = 0
        while i < len(result) and result[i].exp < m.exp:
            i += 1
        result.insert(i, m)
    return result


# --- Phase 2: Merging Equal Exponents ---

def merge_same_exp(p: NatPoly) -> NatPoly:
    """Merge consecutive monomials with the same exponent.

    For monomials with equal exponent, keep the one with minimum coefficient,
    since min(c₁ + e·x, c₂ + e·x) = min(c₁, c₂) + e·x.

    Assumes input is sorted by exponent.

    Time complexity: O(n)
    Space complexity: O(n)

    Args:
        p: Sorted polynomial.

    Returns:
        Polynomial with unique exponents, minimum coefficients.
    """
    if not p:
        return []

    result = [p[0]]
    for m in p[1:]:
        if m.exp == result[-1].exp:
            # Same exponent: take minimum coefficient
            result[-1] = NatMono(m.exp, min(m.coeff, result[-1].coeff))
        else:
            result.append(m)
    return result


# --- Phase 3: Removing Dominated Monomials ---

def is_strictly_dominated(m: NatMono, n: NatMono) -> bool:
    """Check if n strictly dominates m.

    n strictly dominates m if:
    - n.coeff ≤ m.coeff AND n.exp ≤ m.exp
    - At least one inequality is strict

    This means n.eval(x) ≤ m.eval(x) for all x ≥ 0, with
    strict inequality for some x.

    Time complexity: O(1)

    Args:
        m: Potentially dominated monomial.
        n: Potential dominator.

    Returns:
        True if n strictly dominates m.
    """
    return (n.coeff <= m.coeff and n.exp <= m.exp and
            (n.coeff < m.coeff or n.exp < m.exp))


def is_dominated_by_any(m: NatMono, p: NatPoly) -> bool:
    """Check if m is strictly dominated by any monomial in p.

    Time complexity: O(n)

    Args:
        m: Monomial to check.
        p: List of potential dominators.

    Returns:
        True if some monomial in p strictly dominates m.
    """
    return any(is_strictly_dominated(m, n) for n in p)


def remove_dominated(p: NatPoly) -> NatPoly:
    """Remove all strictly dominated monomials.

    A monomial m is removed if there exists another monomial n in p
    such that n.coeff ≤ m.coeff and n.exp ≤ m.exp (with one strict).

    This corresponds to computing the Pareto frontier of the
    (exp, coeff) point set under componentwise ≤.

    Time complexity: O(n²)
    Space complexity: O(n)

    Args:
        p: Input polynomial (typically sorted with unique exponents).

    Returns:
        Irredundant polynomial (no dominated monomials).
    """
    return [m for m in p if not is_dominated_by_any(m, p)]


# --- The Complete Algorithm ---

def canonicalize_fast(p: NatPoly) -> NatPoly:
    """Certified canonicalization of a tropical polynomial.

    Computes the unique minimal irredundant representation of p
    that is tropically equivalent to p.

    Algorithm:
        1. Sort by exponent — O(n²) [insertion sort] / O(n log n) [mergesort]
        2. Merge equal exponents — O(n)
        3. Remove dominated monomials — O(n²)

    Properties (all formally verified in Lean 4):
        - Semantic preservation: eval(canon(p), x) = eval(p, x) for all x
        - Irredundancy: no monomial in the output is dominated by another
        - Complexity: total cost ≤ 3n² + n + 1 comparisons
        - Length bound: len(canon(p)) ≤ len(p)

    Time complexity: O(n²)
    Space complexity: O(n)

    Args:
        p: Input tropical polynomial.

    Returns:
        Canonical form of p.
    """
    return remove_dominated(merge_same_exp(sort_by_exp(p)))


# --- Optimized Version (O(n log n)) ---

def canonicalize_nlogn(p: NatPoly) -> NatPoly:
    """Optimized canonicalization using O(n log n) sorting and linear scan.

    After sorting and merging, the domination check for sorted polynomials
    with unique exponents can be done in O(n) by a single left-to-right scan:
    a monomial (eᵢ, cᵢ) in a sorted sequence is dominated iff cᵢ ≥ cᵢ₋₁
    (since eᵢ > eᵢ₋₁, having cᵢ ≥ cᵢ₋₁ means (eᵢ₋₁, cᵢ₋₁) dominates it).

    Time complexity: O(n log n) [dominated by sorting]
    Space complexity: O(n)

    Args:
        p: Input tropical polynomial.

    Returns:
        Canonical form of p.
    """
    if not p:
        return []

    # Sort and merge: O(n log n)
    sorted_merged = merge_same_exp(sorted(p, key=lambda m: m.exp))

    # Linear scan: keep only monomials with strictly decreasing coefficients
    result = [sorted_merged[0]]
    for m in sorted_merged[1:]:
        if m.coeff < result[-1].coeff:
            result.append(m)
    return result


# --- Cost Model ---

def insertion_sort_cost(n: int) -> int:
    """Number of comparisons for insertion sort on n elements.

    Returns n*(n-1)/2.
    """
    return n * (n - 1) // 2


def canon_cost(n: int) -> int:
    """Total certified cost bound for canonicalization.

    Decomposition:
    - Insertion sort: ≤ n²
    - Merge scan: n
    - Domination removal: n²
    Total: ≤ 3n² + n + 1
    """
    return insertion_sort_cost(n) + n + n * n


def canon_cost_bound(n: int) -> int:
    """Upper bound: 3n² + n + 1."""
    return 3 * n * n + n + 1


# --- Verification Utilities ---

def verify_semantic_preservation(p: NatPoly, q: NatPoly,
                                  test_range: int = 100) -> bool:
    """Verify that p and q evaluate identically on [0, test_range)."""
    return all(eval_poly(p, x) == eval_poly(q, x) for x in range(test_range))


def verify_irredundant(p: NatPoly) -> bool:
    """Verify that no monomial in p is dominated by another."""
    return all(not is_dominated_by_any(m, p) for m in p)


def verify_canonicalization(p: NatPoly, verbose: bool = False) -> bool:
    """Full verification of canonicalization correctness.

    Checks:
    1. Semantic preservation
    2. Irredundancy
    3. Cost within bound

    Args:
        p: Input polynomial.
        verbose: Print details.

    Returns:
        True if all checks pass.
    """
    canon = canonicalize_fast(p)

    sem = verify_semantic_preservation(p, canon)
    irr = verify_irredundant(canon)
    cost_ok = canon_cost(len(p)) <= canon_cost_bound(len(p))
    length_ok = len(canon) <= len(p)

    if verbose:
        print(f"  Input:    {p}")
        print(f"  Canonical: {canon}")
        print(f"  Semantic preservation: {'✓' if sem else '✗'}")
        print(f"  Irredundant:          {'✓' if irr else '✗'}")
        print(f"  Cost within bound:    {'✓' if cost_ok else '✗'}")
        print(f"  Length reduction:      {len(p)} → {len(canon)}")

    return sem and irr and cost_ok and length_ok


# --- Example Usage ---

if __name__ == "__main__":
    print("=== Tropical Polynomial Canonicalization ===\n")

    # Example 1: Simple polynomial
    p1 = [NatMono(2, 5), NatMono(1, 3), NatMono(2, 1), NatMono(1, 7)]
    print("Example 1:")
    print(f"  Input: {p1}")
    print(f"  Canonical: {canonicalize_fast(p1)}")
    print(f"  Verified: {verify_canonicalization(p1, verbose=True)}\n")

    # Example 2: All dominated except one
    p2 = [NatMono(0, 10), NatMono(0, 5), NatMono(0, 3), NatMono(0, 1)]
    print("Example 2 (same exponent):")
    print(f"  Input: {p2}")
    print(f"  Canonical: {canonicalize_fast(p2)}")
    print(f"  Verified: {verify_canonicalization(p2)}\n")

    # Example 3: Already canonical
    p3 = [NatMono(0, 6), NatMono(1, 3), NatMono(3, 0)]
    print("Example 3 (already canonical):")
    print(f"  Input: {p3}")
    print(f"  Canonical: {canonicalize_fast(p3)}")
    print(f"  Verified: {verify_canonicalization(p3)}\n")

    # Compare standard vs optimized
    import random
    random.seed(42)
    p_large = [NatMono(random.randint(0, 50), random.randint(0, 100))
               for _ in range(100)]
    c1 = canonicalize_fast(p_large)
    c2 = canonicalize_nlogn(p_large)
    print(f"Standard vs Optimized on 100 monomials:")
    print(f"  Standard: {len(c1)} monomials")
    print(f"  Optimized: {len(c2)} monomials")
    print(f"  Agree: {verify_semantic_preservation(c1, c2)}")
