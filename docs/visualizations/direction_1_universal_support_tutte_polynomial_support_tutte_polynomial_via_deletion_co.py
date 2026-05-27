#!/usr/bin/env python3
"""
algorithms.py — Support-Tutte Polynomial: Core Algorithms

Implements the deletion-contraction algorithm for computing the universal
support-Tutte invariant, together with M-convexity verification, support
classification, and activity counting.

All algorithms correspond to formally verified Lean 4 theorems in
Pythagorean/UniversalSupportTutte.lean.
"""

from __future__ import annotations
from typing import FrozenSet, Tuple, Dict, List, Optional, Set
from dataclasses import dataclass
from sympy import Symbol, Poly, ZZ, expand
from itertools import combinations
from functools import lru_cache


# ---------------------------------------------------------------------------
# Type aliases
# ---------------------------------------------------------------------------

Vector = Tuple[int, ...]
Support = FrozenSet[Vector]

a_var = Symbol('a')


# ---------------------------------------------------------------------------
# Core Operations
# ---------------------------------------------------------------------------

def support_delete(S: Support, i: int) -> Support:
    """
    Delete coordinate i from support S.

    Keeps only elements with v[i] = 0.

    Corresponds to Lean definition `supportDelete`.

    Parameters
    ----------
    S : Support
        The support set.
    i : int
        Coordinate index to delete.

    Returns
    -------
    Support
        The deleted support.

    Examples
    --------
    >>> S = frozenset({(1,0), (0,1), (1,1)})
    >>> support_delete(S, 0)
    frozenset({(0, 1)})
    """
    return frozenset(v for v in S if v[i] == 0)


def tutte_contract(S: Support, i: int) -> Support:
    """
    Tutte-style contraction at coordinate i.

    Keeps elements with v[i] > 0 and subtracts 1 from coordinate i.

    Corresponds to Lean definition `tutteContract`.

    Parameters
    ----------
    S : Support
        The support set.
    i : int
        Coordinate index to contract.

    Returns
    -------
    Support
        The contracted support.

    Examples
    --------
    >>> S = frozenset({(1,0), (0,1), (2,1)})
    >>> tutte_contract(S, 0)
    frozenset({(0, 0), (1, 1)})
    """
    result = set()
    for v in S:
        if v[i] > 0:
            w = list(v)
            w[i] -= 1
            result.add(tuple(w))
    return frozenset(result)


# ---------------------------------------------------------------------------
# Classification
# ---------------------------------------------------------------------------

@dataclass
class CoordClassification:
    """Classification of a coordinate relative to a support."""
    is_loop: bool      # All elements have positive value
    is_ordinary: bool  # Some zero, some positive
    is_trivial: bool   # All elements have zero value
    is_coloop: bool    # All elements have the same value


def classify_coord(S: Support, i: int) -> CoordClassification:
    """
    Classify coordinate i relative to support S.

    Corresponds to the Lean definitions `IsSupportLoop`, `IsOrdinaryCoord`,
    `IsSupportColoop`.

    Parameters
    ----------
    S : Support
        The support set.
    i : int
        Coordinate index.

    Returns
    -------
    CoordClassification
        The classification of coordinate i.
    """
    if not S:
        return CoordClassification(
            is_loop=True, is_ordinary=False,
            is_trivial=True, is_coloop=True
        )

    values = {v[i] for v in S}
    has_zero = 0 in values
    has_pos = any(val > 0 for val in values)

    return CoordClassification(
        is_loop=not has_zero and has_pos,
        is_ordinary=has_zero and has_pos,
        is_trivial=not has_pos,
        is_coloop=len(values) == 1,
    )


def classify_support(S: Support) -> str:
    """
    Classify a support according to the support classification theorem.

    Corresponds to Lean theorem `support_classification`.

    Returns one of: 'empty', 'trivial', 'has_ordinary', 'has_loop'.
    """
    if not S:
        return 'empty'

    n = len(next(iter(S)))
    zero_vec = tuple(0 for _ in range(n))

    if all(v == zero_vec for v in S):
        return 'trivial'

    for i in range(n):
        cl = classify_coord(S, i)
        if cl.is_ordinary:
            return 'has_ordinary'

    for i in range(n):
        cl = classify_coord(S, i)
        if cl.is_loop:
            return 'has_loop'

    return 'trivial'


# ---------------------------------------------------------------------------
# Activity Data
# ---------------------------------------------------------------------------

@dataclass
class ActivityData:
    """
    Activity data for a deletion-contraction decomposition.

    Corresponds to Lean structure `SupportActivityData`.
    """
    loops: int
    coloops: int
    ordinary: int

    @property
    def total(self) -> int:
        return self.loops + self.coloops + self.ordinary


def count_activities(S: Support, ground: Optional[List[int]] = None) -> ActivityData:
    """
    Count loop, coloop, ordinary, and trivial coordinates.

    Corresponds to Lean theorem `activity_partition`.

    Parameters
    ----------
    S : Support
        The support set.
    ground : list of int, optional
        Ground set of coordinate indices. Defaults to range(dim).

    Returns
    -------
    ActivityData
        Counts of loops, coloops, and ordinary coordinates.
    """
    if not S:
        return ActivityData(0, 0, 0)

    n = len(next(iter(S)))
    if ground is None:
        ground = list(range(n))

    loops = 0
    coloops = 0
    ordinary = 0

    for i in ground:
        cl = classify_coord(S, i)
        if cl.is_loop:
            loops += 1
        if cl.is_coloop and not cl.is_trivial:
            coloops += 1
        if cl.is_ordinary:
            ordinary += 1

    return ActivityData(loops, coloops, ordinary)


# ---------------------------------------------------------------------------
# M-Convexity Verification
# ---------------------------------------------------------------------------

def verify_exchange(S: Support) -> bool:
    """
    Verify the symmetric exchange property (M-convexity) for a support.

    For all x, y in S, for all coordinates a where x[a] > y[a],
    there exists b where y[b] > x[b] such that both exchange results
    are in S.

    Corresponds to Lean definition `SupportExchange`.

    Parameters
    ----------
    S : Support
        The support set.

    Returns
    -------
    bool
        True if S satisfies the exchange property.
    """
    S_list = list(S)
    n = len(S_list[0]) if S_list else 0

    for x in S_list:
        for y in S_list:
            for a in range(n):
                if x[a] > y[a]:
                    found = False
                    for b in range(n):
                        if y[b] > x[b]:
                            # Check exchange result x' and y'
                            x_prime = list(x)
                            x_prime[a] -= 1
                            x_prime[b] += 1
                            y_prime = list(y)
                            y_prime[a] += 1
                            y_prime[b] -= 1

                            if (tuple(x_prime) in S and
                                    tuple(y_prime) in S):
                                found = True
                                break
                    if not found:
                        return False
    return True


# ---------------------------------------------------------------------------
# Support-Tutte Polynomial Algorithm
# ---------------------------------------------------------------------------

class SupportTutteComputer:
    """
    Computes the support-Tutte polynomial via deletion-contraction.

    Implements the verified recursive algorithm from the Lean formalization.

    The algorithm processes coordinates in a given order, applying:
    - Loop rule: T(S) = a · T(contract(S, i))
    - Ordinary rule: T(S) = T(delete(S, i)) + T(contract(S, i))
    - Trivial: skip coordinate

    Time complexity: O(2^k · n · |S|) where k = number of ordinary coordinates,
    n = dimension, |S| = support size.
    Space complexity: O(2^k) for memoization cache.
    """

    def __init__(self, loop_var: Symbol = a_var):
        self.loop_var = loop_var
        self.cache: Dict = {}
        self.call_count = 0

    def compute(self, S: Support, coord_order: Optional[List[int]] = None) -> Poly:
        """
        Compute the support-Tutte polynomial T_S(a).

        Parameters
        ----------
        S : Support
            Input support.
        coord_order : list of int, optional
            Order of coordinate processing.

        Returns
        -------
        Poly
            The support-Tutte polynomial.
        """
        self.cache.clear()
        self.call_count = 0

        if not S:
            return Poly(1, self.loop_var, domain=ZZ)

        n = len(next(iter(S)))
        if coord_order is None:
            coord_order = list(range(n))

        return self._compute_rec(S, tuple(coord_order))

    def _compute_rec(self, S: Support, remaining: Tuple[int, ...]) -> Poly:
        key = (S, remaining)
        if key in self.cache:
            return self.cache[key]

        self.call_count += 1
        one = Poly(1, self.loop_var, domain=ZZ)

        # Base cases
        if not S:
            self.cache[key] = one
            return one

        n = len(next(iter(S)))
        zero_vec = tuple(0 for _ in range(n))
        if all(v == zero_vec for v in S):
            self.cache[key] = one
            return one

        if not remaining:
            self.cache[key] = one
            return one

        i = remaining[0]
        rest = remaining[1:]
        cl = classify_coord(S, i)

        if cl.is_loop:
            contracted = tutte_contract(S, i)
            sub = self._compute_rec(contracted, remaining)  # keep coord for repeated loops
            result = Poly(self.loop_var, self.loop_var, domain=ZZ) * sub
        elif cl.is_ordinary:
            deleted = support_delete(S, i)
            contracted = tutte_contract(S, i)
            result = self._compute_rec(deleted, rest) + self._compute_rec(contracted, rest)
        else:
            result = self._compute_rec(S, rest)

        self.cache[key] = result
        return result


# ---------------------------------------------------------------------------
# Simplex Enumeration
# ---------------------------------------------------------------------------

def simplex_lattice_points(n: int, d: int) -> Support:
    """
    Generate all lattice points in the degree-d simplex in n variables.
    {v ∈ ℕ^n : sum(v) = d}

    Parameters
    ----------
    n : int
        Number of variables.
    d : int
        Total degree.

    Returns
    -------
    Support
        Set of lattice points.
    """
    if n == 0:
        return frozenset({()}) if d == 0 else frozenset()
    result = set()
    for v0 in range(d + 1):
        for rest in simplex_lattice_points(n - 1, d - v0):
            result.add((v0,) + rest)
    return frozenset(result)


def enumerate_mconvex_subsets(n: int, d: int, max_size: int = 100) -> List[Support]:
    """
    Enumerate M-convex subsets of the degree-d simplex in n variables.

    Tests all subsets up to max_size for the exchange property.

    Parameters
    ----------
    n : int
        Number of variables.
    d : int
        Total degree.
    max_size : int
        Maximum number of subsets to test.

    Returns
    -------
    list of Support
        List of M-convex subsets found.
    """
    full = simplex_lattice_points(n, d)
    points = sorted(full)
    results = []

    # Start with small subsets
    for size in range(1, len(points) + 1):
        if len(results) >= max_size:
            break
        for combo in combinations(points, size):
            if len(results) >= max_size:
                break
            S = frozenset(combo)
            if verify_exchange(S):
                results.append(S)

    return results


# ---------------------------------------------------------------------------
# Main demonstration
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    print("Support-Tutte Polynomial — Algorithm Demonstrations")
    print("=" * 60)

    computer = SupportTutteComputer()

    # Example 1: Matroid support
    S = frozenset({(1, 1, 0), (1, 0, 1), (0, 1, 1)})
    T = computer.compute(S)
    print(f"\nU(2,3) support: T(a) = {T.as_expr()}")
    print(f"  Exchange property: {verify_exchange(S)}")
    print(f"  Activities: {count_activities(S)}")
    print(f"  Classification: {classify_support(S)}")

    # Example 2: Non-matroidal
    S2 = frozenset({(2, 0, 0), (0, 2, 0), (0, 0, 2),
                    (1, 1, 0), (1, 0, 1), (0, 1, 1)})
    T2 = computer.compute(S2)
    print(f"\nDegree-2 simplex: T(a) = {T2.as_expr()}")
    print(f"  Exchange property: {verify_exchange(S2)}")
    print(f"  Activities: {count_activities(S2)}")

    # Example 3: Enumerate M-convex subsets
    print(f"\nEnumerating M-convex subsets of Δ(3,2)...")
    mconvex = enumerate_mconvex_subsets(3, 2, max_size=20)
    print(f"  Found {len(mconvex)} M-convex subsets")
    for i, S in enumerate(mconvex[:5]):
        T = computer.compute(S)
        print(f"  [{i}] |S|={len(S)}, T(a) = {T.as_expr()}")
