#!/usr/bin/env python3
"""
Algorithms for Tropical Canonical Forms

Implements the canonicalization algorithm for tropical polynomials and
the equivalence-checking pipeline for ReLU networks.

Time complexity:
- Canonicalization: O(n log n) where n is the number of terms
- Equivalence checking: O(n log n) after extraction

Space complexity: O(n)
"""

from typing import List, Tuple, Optional
import numpy as np


class AffinePiece:
    """An affine function x ↦ slope * x + intercept."""
    def __init__(self, slope: float, intercept: float):
        self.slope = slope
        self.intercept = intercept

    def eval(self, x: float) -> float:
        return self.slope * x + self.intercept

    def __eq__(self, other):
        return (isinstance(other, AffinePiece) and
                abs(self.slope - other.slope) < 1e-12 and
                abs(self.intercept - other.intercept) < 1e-12)

    def __repr__(self):
        return f"({self.slope}x + {self.intercept})"


def canonicalize_tropical_poly(terms: List[AffinePiece]) -> List[AffinePiece]:
    """
    Compute the canonical form of a tropical polynomial.

    A tropical polynomial P(x) = max_i(a_i * x + b_i) is canonical when:
    1. Slopes a_1 < a_2 < ... < a_n are strictly increasing
    2. Every term is strictly essential (removing it changes the function)

    Algorithm (upper convex hull of dual points):
    - Each affine piece a*x + b corresponds to a point (a, b) in the dual plane.
    - The canonical terms are exactly those on the upper convex hull.
    - We compute this using a sweep from left to right.

    Time: O(n log n) due to sorting; the hull computation is O(n).
    Space: O(n).

    Args:
        terms: List of AffinePiece objects.

    Returns:
        List of AffinePiece objects in canonical form (sorted by slope).

    Example:
        >>> canonicalize_tropical_poly([AffinePiece(0,0), AffinePiece(1,0), AffinePiece(2,0)])
        [(0x + 0), (2x + 0)]
        # The middle term x is dominated by max(0, 2x) everywhere.
    """
    if not terms:
        raise ValueError("Need at least one term")

    # Step 1: Sort by slope
    sorted_terms = sorted(terms, key=lambda t: (t.slope, -t.intercept))

    # Step 2: Remove duplicate slopes (keep highest intercept)
    deduped = []
    for t in sorted_terms:
        if deduped and abs(deduped[-1].slope - t.slope) < 1e-12:
            if t.intercept > deduped[-1].intercept:
                deduped[-1] = t
        else:
            deduped.append(t)

    if len(deduped) <= 1:
        return deduped

    # Step 3: Compute upper convex hull
    # A term t_i is essential iff the breakpoint between t_{i-1} and t_i
    # occurs strictly before the breakpoint between t_i and t_{i+1}.
    hull = [deduped[0]]
    for t in deduped[1:]:
        while len(hull) >= 2:
            prev = hull[-2]
            curr = hull[-1]
            # Breakpoint of prev and curr
            if abs(prev.slope - curr.slope) < 1e-12:
                hull.pop()
                continue
            if abs(curr.slope - t.slope) < 1e-12:
                if t.intercept >= curr.intercept:
                    hull.pop()
                break
            x_left = (curr.intercept - prev.intercept) / (prev.slope - curr.slope)
            x_right = (t.intercept - curr.intercept) / (curr.slope - t.slope)
            if x_left >= x_right - 1e-12:
                hull.pop()  # curr is dominated
            else:
                break
        hull.append(t)

    return hull


def extract_breakpoints(canonical_terms: List[AffinePiece]) -> List[float]:
    """
    Extract breakpoint locations from a canonical tropical polynomial.

    Breakpoint between term i and term i+1 occurs at:
    x_i = (b_{i+1} - b_i) / (a_i - a_{i+1})

    Time: O(n).
    """
    breakpoints = []
    for i in range(len(canonical_terms) - 1):
        t1 = canonical_terms[i]
        t2 = canonical_terms[i + 1]
        if abs(t1.slope - t2.slope) > 1e-12:
            bp = (t2.intercept - t1.intercept) / (t1.slope - t2.slope)
            breakpoints.append(bp)
    return breakpoints


def tropical_poly_eval(terms: List[AffinePiece], x: float) -> float:
    """Evaluate a tropical polynomial at a point."""
    return max(t.eval(x) for t in terms)


def check_canonical_equivalence(
    terms1: List[AffinePiece],
    terms2: List[AffinePiece]
) -> bool:
    """
    Check if two tropical polynomials define the same function
    by comparing their canonical forms.

    This is the core decision procedure: canonicalize both, then compare.

    Time: O(n log n + m log m) where n, m are the number of terms.
    """
    canon1 = canonicalize_tropical_poly(terms1)
    canon2 = canonicalize_tropical_poly(terms2)

    if len(canon1) != len(canon2):
        return False

    return all(t1 == t2 for t1, t2 in zip(canon1, canon2))


def tropical_mul(terms1: List[AffinePiece], terms2: List[AffinePiece]) -> List[AffinePiece]:
    """
    Tropical multiplication: pairwise sum of affine pieces.

    In tropical algebra, multiplication is classical addition.
    So (a₁x + b₁) ⊗ (a₂x + b₂) = (a₁+a₂)x + (b₁+b₂).

    The product of two tropical polynomials P ⊗ Q consists of
    all pairwise products of their terms.

    Time: O(n * m).
    """
    result = []
    for t1 in terms1:
        for t2 in terms2:
            result.append(AffinePiece(t1.slope + t2.slope,
                                      t1.intercept + t2.intercept))
    return result


def cross_multiply_check(
    num1: List[AffinePiece], den1: List[AffinePiece],
    num2: List[AffinePiece], den2: List[AffinePiece],
    x_range: Tuple[float, float] = (-100, 100),
    n_points: int = 10000
) -> bool:
    """
    Check tropical rational equivalence via cross-multiplication.

    R₁ = num₁/den₁ and R₂ = num₂/den₂ are equal iff:
    num₁ ⊗ den₂ and num₂ ⊗ den₁ define the same tropical polynomial.

    This avoids subtraction entirely, working purely in the tropical semiring.
    """
    cross1 = tropical_mul(num1, den2)
    cross2 = tropical_mul(num2, den1)
    return check_canonical_equivalence(cross1, cross2)


# ─── Demonstration ───────────────────────────────────────────

if __name__ == "__main__":
    print("Tropical Canonicalization Algorithm")
    print("=" * 50)

    # Example 1: Canonicalize a redundant tropical polynomial
    terms = [AffinePiece(-2, 4), AffinePiece(-1, 1), AffinePiece(0, 0),
             AffinePiece(1, 1), AffinePiece(2, 4)]
    print(f"\nInput: {len(terms)} terms")
    canon = canonicalize_tropical_poly(terms)
    print(f"Canonical: {len(canon)} terms")
    for t in canon:
        print(f"  {t}")

    breakpoints = extract_breakpoints(canon)
    print(f"Breakpoints: {breakpoints}")

    # Example 2: Cross-multiplication check
    print(f"\nCross-multiplication equivalence check:")
    num1 = [AffinePiece(0, 1), AffinePiece(1, 0)]
    den1 = [AffinePiece(0, 0)]
    num2 = [AffinePiece(0, 1), AffinePiece(1, 0)]
    den2 = [AffinePiece(0, 0)]
    print(f"  Same rational: {cross_multiply_check(num1, den1, num2, den2)}")

    num3 = [AffinePiece(0, 2), AffinePiece(1, 0)]
    print(f"  Different rational: {cross_multiply_check(num1, den1, num3, den2)}")

    # Example 3: Canonical equivalence
    print(f"\nCanonical equivalence:")
    t1 = [AffinePiece(0, 0), AffinePiece(1, 0), AffinePiece(2, 0)]
    t2 = [AffinePiece(0, 0), AffinePiece(2, 0)]
    print(f"  max(0, x, 2x) ≡ max(0, 2x): {check_canonical_equivalence(t1, t2)}")

    t3 = [AffinePiece(0, 0), AffinePiece(1, 0)]
    print(f"  max(0, x, 2x) ≡ max(0, x): {check_canonical_equivalence(t1, t3)}")
