#!/usr/bin/env python3
"""
Algorithms for Closure–Gauge Realization Duality

Implements the key algorithms from the research:
1. Valuation closure computation
2. Realizability testing (chain condition check)
3. Minimal realization reconstruction
4. Gauge equivalence testing
5. Capacity profile computation
"""

from itertools import combinations
from typing import Dict, FrozenSet, Set, List, Tuple, Optional, Callable
import numpy as np


# Type aliases
Element = int
Universe = Set[Element]
Valuation = Dict[Element, int]
ClosureFn = Callable[[FrozenSet[Element]], FrozenSet[Element]]


def valuation_closure(v: Valuation, S: FrozenSet[Element],
                      universe: Universe) -> FrozenSet[Element]:
    """
    Compute the valuation-induced closure: cl_v(S) = {x ∈ U | v(x) ≤ sup_{s∈S} v(s)}.

    Time complexity: O(|U|)
    Space complexity: O(|U|)

    Args:
        v: Gauge valuation mapping elements to non-negative integers
        S: Input set (subset of universe)
        universe: The finite universe

    Returns:
        The closure cl_v(S)
    """
    sup_val = max((v[s] for s in S), default=0)
    return frozenset(x for x in universe if v[x] <= sup_val)


def compute_all_closed_sets(cl_fn: ClosureFn,
                            universe: Universe) -> List[FrozenSet[Element]]:
    """
    Enumerate all closed sets (fixpoints) of a closure operator.

    Time complexity: O(2^n · n) where n = |universe|
    Space complexity: O(2^n)

    Args:
        cl_fn: Closure operator
        universe: The finite universe

    Returns:
        List of all closed sets, sorted by cardinality
    """
    closed = []
    elems = sorted(universe)
    n = len(elems)
    for r in range(n + 1):
        for combo in combinations(elems, r):
            S = frozenset(combo)
            if cl_fn(S) == S:
                closed.append(S)
    return sorted(closed, key=len)


def check_chain_condition(closed_sets: List[FrozenSet[Element]]) -> Tuple[bool, Optional[Tuple]]:
    """
    Check if closed sets form a chain (totally ordered by inclusion).

    Time complexity: O(k² · n) where k = number of closed sets, n = max set size
    Space complexity: O(1)

    Args:
        closed_sets: List of closed sets

    Returns:
        (True, None) if chain, (False, (S, T)) if not, with incomparable witness
    """
    for i, S in enumerate(closed_sets):
        for j, T in enumerate(closed_sets):
            if i < j and not (S.issubset(T) or T.issubset(S)):
                return False, (S, T)
    return True, None


def is_gauge_realizable(cl_fn: ClosureFn, universe: Universe) -> Tuple[bool, Optional[Valuation]]:
    """
    Test if a closure operator is gauge-realizable, and if so, return a realization.

    Algorithm:
    1. Compute all closed sets
    2. Check the chain condition
    3. If chain, reconstruct the valuation

    Time complexity: O(2^n · n)
    Space complexity: O(2^n)

    Args:
        cl_fn: Closure operator
        universe: The finite universe

    Returns:
        (True, v) if realizable with witness valuation v, (False, None) otherwise
    """
    closed = compute_all_closed_sets(cl_fn, universe)
    is_chain, witness = check_chain_condition(closed)

    if not is_chain:
        return False, None

    v = reconstruct_valuation(cl_fn, universe)
    return True, v


def reconstruct_valuation(cl_fn: ClosureFn, universe: Universe) -> Valuation:
    """
    Reconstruct a minimal gauge valuation from a closure operator with chain closed sets.

    Algorithm: v(x) = |cl({x})| - |cl(∅)|

    This is the certified reconstruction: the resulting valuation provably
    induces exactly the original closure operator.

    Time complexity: O(n · T_cl) where T_cl is the time for one closure computation
    Space complexity: O(n)

    Args:
        cl_fn: Closure operator (must have chain closed sets)
        universe: The finite universe

    Returns:
        Minimal gauge valuation
    """
    cl_empty = cl_fn(frozenset())
    base = len(cl_empty)
    v = {}
    for x in universe:
        cl_x = cl_fn(frozenset([x]))
        v[x] = len(cl_x) - base
    return v


def normalize_valuation(v: Valuation, universe: Universe) -> Valuation:
    """
    Normalize a valuation to use consecutive integers {0, 1, ..., rank-1}.

    Algorithm: v_norm(x) = |{y ∈ U | v(y) < v(x)}|

    The normalized valuation is order-equivalent to the original
    and has the same realization rank.

    Time complexity: O(n²)
    Space complexity: O(n)

    Args:
        v: Original valuation
        universe: The finite universe

    Returns:
        Normalized valuation with values in {0, ..., rank-1}
    """
    v_norm = {}
    elems = sorted(universe)
    for x in elems:
        v_norm[x] = sum(1 for y in elems if v[y] < v[x])
    return v_norm


def check_order_equivalence(v1: Valuation, v2: Valuation,
                             universe: Universe) -> bool:
    """
    Check if two valuations are order-equivalent (gauge equivalent).

    Two valuations are order-equivalent iff they induce the same
    total preorder on the universe.

    Time complexity: O(n²)
    Space complexity: O(1)

    Args:
        v1, v2: Valuations to compare
        universe: The finite universe

    Returns:
        True if order-equivalent
    """
    elems = sorted(universe)
    for x in elems:
        for y in elems:
            if (v1[x] <= v1[y]) != (v2[x] <= v2[y]):
                return False
    return True


def compute_capacity_profile(cl_fn: ClosureFn,
                              universe: Universe) -> Dict[FrozenSet[Element], int]:
    """
    Compute the capacity profile: S ↦ |cl(S)| for all S ⊆ universe.

    By the holographic duality theorem, the capacity profile
    uniquely determines the closure operator.

    Time complexity: O(2^n · T_cl)
    Space complexity: O(2^n)

    Args:
        cl_fn: Closure operator
        universe: The finite universe

    Returns:
        Dictionary mapping each subset to its capacity
    """
    profile = {}
    elems = sorted(universe)
    n = len(elems)
    for r in range(n + 1):
        for combo in combinations(elems, r):
            S = frozenset(combo)
            profile[S] = len(cl_fn(S))
    return profile


def realization_rank(v: Valuation, universe: Universe) -> int:
    """
    Compute the rank of a gauge valuation (number of distinct values).

    Time complexity: O(n)
    Space complexity: O(n)
    """
    return len(set(v[x] for x in universe))


def check_separation(cl_fn: ClosureFn, universe: Universe) -> Tuple[bool, Optional[Tuple]]:
    """
    Check if a closure operator is separated (distinct singletons → distinct closures).

    Time complexity: O(n² · T_cl)
    Space complexity: O(n)

    Returns:
        (True, None) if separated, (False, (a, b)) with non-separated witness otherwise
    """
    elems = sorted(universe)
    for i, a in enumerate(elems):
        for b in elems[i+1:]:
            cl_a = cl_fn(frozenset([a]))
            cl_b = cl_fn(frozenset([b]))
            if cl_a == cl_b:
                return False, (a, b)
    return True, None


def holographic_verify(cl1_fn: ClosureFn, cl2_fn: ClosureFn,
                        universe: Universe) -> bool:
    """
    Verify holographic duality: check if two closures have equal capacity profiles.

    By the holographic duality theorem, equal capacity profiles
    imply identical closure operators.

    Time complexity: O(2^n · T_cl)
    Space complexity: O(2^n)
    """
    p1 = compute_capacity_profile(cl1_fn, universe)
    p2 = compute_capacity_profile(cl2_fn, universe)
    return p1 == p2


# ============================================================
# Example usage and verification
# ============================================================
if __name__ == "__main__":
    print("Closure–Gauge Realization Duality: Algorithm Suite")
    print("=" * 55)

    # Create a test closure
    U = {0, 1, 2, 3, 4}
    v_test = {0: 0, 1: 2, 2: 2, 3: 5, 4: 8}

    cl_test = lambda S: valuation_closure(v_test, S, U)

    print(f"\nTest valuation: {v_test}")
    print(f"Rank: {realization_rank(v_test, U)}")

    # Compute closed sets
    closed = compute_all_closed_sets(cl_test, U)
    print(f"\nClosed sets ({len(closed)} total):")
    for S in closed:
        print(f"  {sorted(S)}")

    # Check chain
    is_chain, _ = check_chain_condition(closed)
    print(f"\nChain condition: {is_chain}")

    # Test realizability
    realizable, v_recon = is_gauge_realizable(cl_test, U)
    print(f"Realizable: {realizable}")
    if v_recon:
        print(f"Reconstructed valuation: {v_recon}")
        print(f"Order equivalent to original: "
              f"{check_order_equivalence(v_test, v_recon, U)}")

    # Normalize
    v_normed = normalize_valuation(v_test, U)
    print(f"\nNormalized valuation: {v_normed}")
    print(f"Normalized rank: {realization_rank(v_normed, U)}")
    print(f"Order equivalent: {check_order_equivalence(v_test, v_normed, U)}")

    # Separation
    is_sep, witness = check_separation(cl_test, U)
    print(f"\nSeparated: {is_sep}")
    if not is_sep:
        print(f"  Non-separated pair: {witness}")

    # Capacity profile (sample)
    profile = compute_capacity_profile(cl_test, U)
    print(f"\nCapacity profile (sample):")
    for S in [frozenset(), frozenset([0]), frozenset([1]), frozenset([3]),
              frozenset([0, 3]), frozenset(U)]:
        print(f"  cap({sorted(S)}) = {profile[S]}")

    print("\n✓ All algorithms executed successfully")
