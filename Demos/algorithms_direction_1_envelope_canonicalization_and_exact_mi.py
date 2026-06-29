#!/usr/bin/env python3
"""
Algorithms for Tropical Envelope Canonicalization.

This module implements the core algorithms from the envelope canonicalization
theory, with full docstrings, type hints, and complexity analysis.
"""

from typing import List, Tuple, Optional, Set
from dataclasses import dataclass
import math


@dataclass(frozen=True)
class TropicalMonomial:
    """
    A tropical monomial: the affine function f(x) = coeff + exp * x.

    In the min-plus (tropical) semiring, a polynomial is a finite set of
    such monomials, and evaluation takes the minimum over all of them.
    """
    exp: int      # The slope (exponent/growth rate)
    coeff: float  # The intercept (coefficient/offset)

    def eval(self, x: float) -> float:
        """Evaluate the monomial at point x."""
        return self.coeff + self.exp * x

    def __repr__(self) -> str:
        return f"({self.exp}, {self.coeff:.2f})"


def tropical_eval(monomials: List[TropicalMonomial], x: float) -> float:
    """
    Evaluate a tropical polynomial at point x.

    p(x) = min_i (c_i + e_i * x)

    Time complexity: O(|monomials|)
    """
    if not monomials:
        raise ValueError("Cannot evaluate empty polynomial")
    return min(m.eval(x) for m in monomials)


def crossing_point(m1: TropicalMonomial, m2: TropicalMonomial) -> Optional[float]:
    """
    Find the real-valued crossing point of two monomials.

    Returns None if they are parallel (same slope).
    Returns the unique x where m1(x) = m2(x) otherwise.

    Time complexity: O(1)
    """
    if m1.exp == m2.exp:
        return None  # Parallel lines: never cross (or always equal)
    return (m1.coeff - m2.coeff) / (m2.exp - m1.exp)


def envelope_canonical(
    monomials: List[TropicalMonomial],
    max_n: int = 10000
) -> List[TropicalMonomial]:
    """
    Compute the envelope-canonical form of a tropical polynomial.

    A monomial is envelope-essential if it attains the minimum of the
    polynomial at some natural number n ∈ {0, 1, ..., max_n}.

    Algorithm:
        For each n in range, find the minimizer(s). All minimizers are
        marked as envelope-essential.

    Time complexity: O(max_n * |monomials|)
    Space complexity: O(|monomials|)

    For a more efficient implementation, see `envelope_canonical_fast`.
    """
    essential: Set[int] = set()  # indices of essential monomials

    for n in range(max_n + 1):
        min_val = min(m.eval(n) for m in monomials)
        for i, m in enumerate(monomials):
            if abs(m.eval(n) - min_val) < 1e-12:
                essential.add(i)

        # Early termination: all monomials marked
        if len(essential) == len(monomials):
            break

    return [monomials[i] for i in sorted(essential)]


def envelope_canonical_fast(
    monomials: List[TropicalMonomial]
) -> List[TropicalMonomial]:
    """
    Compute the envelope-canonical form using the lower convex hull.

    This is the efficient algorithm: instead of scanning all natural numbers,
    we compute crossing points between consecutive monomials (sorted by slope)
    and determine the active regions.

    Algorithm:
        1. Sort monomials by slope (exp).
        2. Build the lower convex hull of the lines using a sweep.
        3. For each hull edge, check if its active region contains a natural number.
        4. A monomial is envelope-essential iff its active region contains
           at least one natural number.

    Time complexity: O(|monomials| * log |monomials|)
    Space complexity: O(|monomials|)
    """
    if not monomials:
        return []

    # Group by slope, keeping only the minimum coefficient for each slope
    slope_map: dict = {}
    for m in monomials:
        if m.exp not in slope_map or m.coeff < slope_map[m.exp].coeff:
            slope_map[m.exp] = m
    unique = sorted(slope_map.values(), key=lambda m: m.exp)

    if len(unique) == 1:
        return unique

    # Build lower convex hull of lines (dual to upper envelope in line arrangement)
    # A line y = c + e*x corresponds to the point (e, c) in slope-intercept space.
    # The lower envelope of lines = upper convex hull of dual points.
    # But for tropical polynomials, we want min, so lower envelope.

    # Stack-based convex hull of lines sorted by slope
    hull: List[TropicalMonomial] = []
    for m in unique:
        while len(hull) >= 2:
            # Check if the previous monomial is above the line from hull[-2] to m
            cp1 = crossing_point(hull[-2], hull[-1])
            cp2 = crossing_point(hull[-2], m)
            if cp1 is not None and cp2 is not None and cp1 >= cp2:
                hull.pop()  # hull[-1] is dominated
            else:
                break
        hull.append(m)

    # Now determine which hull monomials are active at some natural number
    essential = set()

    for i, m in enumerate(hull):
        # Find the active region [left, right] for this monomial
        if i == 0:
            left = -math.inf
        else:
            cp = crossing_point(hull[i - 1], m)
            left = cp if cp is not None else -math.inf

        if i == len(hull) - 1:
            right = math.inf
        else:
            cp = crossing_point(m, hull[i + 1])
            right = cp if cp is not None else math.inf

        # Check if [left, right] contains a natural number
        if right < 0:
            continue
        effective_left = max(left, 0)
        if math.isinf(effective_left):
            continue
        first_n = math.ceil(effective_left - 1e-9)
        first_n = max(0, first_n)
        if not math.isinf(right) and first_n <= right + 1e-9:
            essential.add(m)

    # Return essential monomials in original order
    return [m for m in monomials if m in essential or
            (m.exp in slope_map and slope_map[m.exp] in essential and
             slope_map[m.exp].coeff == m.coeff)]


def nat_canonical(monomials: List[TropicalMonomial]) -> List[TropicalMonomial]:
    """
    Compute the ℕ-canonical (Pareto) form.

    A monomial is Pareto-essential if no single other monomial dominates it
    on all of ℕ. Domination on ℕ means: m'.exp ≤ m.exp AND m'.coeff ≤ m.coeff.

    Time complexity: O(|monomials|^2)
    Space complexity: O(|monomials|)
    """
    result = []
    for m in monomials:
        dominated = False
        for m2 in monomials:
            if m2 is m or m2 == m:
                continue
            if m2.exp <= m.exp and m2.coeff <= m.coeff:
                dominated = True
                break
        if not dominated:
            result.append(m)
    return result


def strict_witness(
    monomials: List[TropicalMonomial],
    m: TropicalMonomial,
    max_n: int = 10000
) -> Optional[int]:
    """
    Find a strict witness for monomial m: a natural number n where
    m is the unique minimizer (strict inequality for all others).

    Time complexity: O(max_n * |monomials|)
    """
    for n in range(max_n + 1):
        val = m.eval(n)
        if all(val < m2.eval(n) - 1e-12 for m2 in monomials if m2 != m):
            return n
    return None


def is_generic_position(monomials: List[TropicalMonomial], max_n: int = 10000) -> bool:
    """
    Check if monomials are in generic position: no two distinct monomials
    agree at any natural number.

    Time complexity: O(|monomials|^2 * max_n)
    """
    for i, m1 in enumerate(monomials):
        for j, m2 in enumerate(monomials):
            if i >= j:
                continue
            for n in range(max_n + 1):
                if abs(m1.eval(n) - m2.eval(n)) < 1e-12:
                    return False
    return True


def verify_minimality(
    p: List[TropicalMonomial],
    max_n: int = 100
) -> dict:
    """
    Verify the exact minimality theorem computationally.

    Returns a dictionary with:
    - envelope: the envelope-canonical form
    - nat_canonical: the Pareto canonical form
    - semantics_preserved: whether envelope preserves semantics
    - all_indispensable: whether every envelope monomial is indispensable
    - generic: whether the polynomial is in generic position

    Time complexity: O(|p|^2 * max_n)
    """
    env = envelope_canonical(p, max_n)
    nat = nat_canonical(p)
    generic = is_generic_position(p, max_n)

    # Check semantics preservation
    semantics_ok = True
    for n in range(max_n + 1):
        if abs(tropical_eval(env, n) - tropical_eval(p, n)) > 1e-10:
            semantics_ok = False
            break

    # Check indispensability
    all_indispensable = True
    for m in env:
        sub = [m2 for m2 in p if m2 != m]
        if not sub:
            continue
        for n in range(max_n + 1):
            if abs(tropical_eval(sub, n) - tropical_eval(p, n)) > 1e-10:
                break
        else:
            all_indispensable = False

    return {
        "envelope": env,
        "nat_canonical": nat,
        "envelope_size": len(env),
        "nat_canonical_size": len(nat),
        "semantics_preserved": semantics_ok,
        "all_indispensable": all_indispensable,
        "generic_position": generic,
    }


if __name__ == "__main__":
    print("=== Algorithm Verification ===\n")

    # Example 1: All monomials essential
    p1 = [TropicalMonomial(0, 5.1), TropicalMonomial(1, 1.3), TropicalMonomial(3, -4.7)]
    result = verify_minimality(p1)
    print(f"Polynomial: {p1}")
    print(f"  Envelope size: {result['envelope_size']}")
    print(f"  NatCanonical size: {result['nat_canonical_size']}")
    print(f"  Semantics preserved: {result['semantics_preserved']}")
    print(f"  All indispensable: {result['all_indispensable']}")
    print(f"  Generic position: {result['generic_position']}")

    # Example 2: Coalition domination
    p2 = [TropicalMonomial(0, 0), TropicalMonomial(1, -1), TropicalMonomial(2, -3)]
    result = verify_minimality(p2)
    print(f"\nPolynomial: {p2}")
    print(f"  Envelope size: {result['envelope_size']}")
    print(f"  NatCanonical size: {result['nat_canonical_size']}")
    print(f"  Semantics preserved: {result['semantics_preserved']}")
    print(f"  Coalition domination detected: envelope < nat_canonical = "
          f"{result['envelope_size'] < result['nat_canonical_size']}")

    # Example 3: Fast algorithm comparison
    p3 = [TropicalMonomial(i, -i * 0.5 + 3) for i in range(10)]
    env_slow = envelope_canonical(p3)
    env_fast = envelope_canonical_fast(p3)
    print(f"\nFast algorithm comparison (10 monomials):")
    print(f"  Slow: {len(env_slow)} essential")
    print(f"  Fast: {len(env_fast)} essential")
