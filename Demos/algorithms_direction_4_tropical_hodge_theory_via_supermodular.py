#!/usr/bin/env python3
"""
algorithms.py — Certified Algorithms for Tropical Hodge Depth

Implements the core algorithms for computing supermodularity order and
tropical Hodge depth of set functions over finite ground sets.

Complexity:
- check_supermod_order(k, g, n): O(n^k · 4^n) where n = |ground set|
- compute_tropical_hodge_depth(g, n, K): O(K · n^K · 4^n)

The exponential factor 4^n comes from iterating over all pairs (s,t).
"""

from typing import Callable, FrozenSet, Set, Dict, Optional, Tuple, List
import math
from functools import lru_cache


# Type aliases
SetFn = Callable[[FrozenSet[int]], float]


def powerset_list(ground: Set[int]) -> List[FrozenSet[int]]:
    """Generate all subsets of a ground set as frozensets."""
    elems = sorted(ground)
    n = len(elems)
    result = []
    for i in range(1 << n):
        s = frozenset(elems[j] for j in range(n) if i & (1 << j))
        result.append(s)
    return result


def supermod_defect(g: SetFn, s: FrozenSet[int], t: FrozenSet[int]) -> float:
    """
    Compute the supermodularity defect: g(s∪t) + g(s∩t) - g(s) - g(t).

    Returns:
        float: The defect value. Nonneg iff g is supermodular at (s,t).
    """
    return g(s | t) + g(s & t) - g(s) - g(t)


def elem_diff(g: SetFn, a: int) -> SetFn:
    """
    Discrete difference operator: Δ_a g(s) = g(s ∪ {a}) - g(s).

    Args:
        g: Set function.
        a: Element to differentiate by.

    Returns:
        The discrete difference function.
    """
    singleton = frozenset([a])
    def diff_fn(s: FrozenSet[int]) -> float:
        return g(s | singleton) - g(s)
    return diff_fn


def check_supermod_order(
    k: int,
    g: SetFn,
    ground: Set[int],
    subsets: Optional[List[FrozenSet[int]]] = None,
    tol: float = 1e-12
) -> bool:
    """
    Check whether g has SupermodularOrder k over the given ground set.

    Algorithm:
        - k=0: Check all pairs (s,t) for 0 ≤ g(s∪t) + g(s∩t) - g(s) - g(t).
        - k+1: Check order k, then for each element a ∈ ground,
          check order k for the difference function Δ_a g.

    Complexity: O(|ground|^k · 4^|ground|)

    Args:
        k: Supermodularity order to check.
        g: Set function Finset → ℝ.
        ground: Finite ground set.
        subsets: Precomputed list of all subsets (optional).
        tol: Numerical tolerance.

    Returns:
        True if g has SupermodularOrder k.
    """
    if subsets is None:
        subsets = powerset_list(ground)

    if k == 0:
        for s in subsets:
            for t in subsets:
                if supermod_defect(g, s, t) < -tol:
                    return False
        return True
    else:
        if not check_supermod_order(k - 1, g, ground, subsets, tol):
            return False
        for a in ground:
            dg = elem_diff(g, a)
            if not check_supermod_order(k - 1, dg, ground, subsets, tol):
                return False
        return True


def compute_tropical_hodge_depth(
    g: SetFn,
    ground: Set[int],
    max_k: int = 10,
    tol: float = 1e-12
) -> int:
    """
    Compute the tropical Hodge depth of g: the largest k ≤ max_k
    such that SupermodularOrder k g holds.

    Algorithm: Try k = 0, 1, 2, ... up to max_k. Stop at the first failure.

    Complexity: O(max_k · |ground|^max_k · 4^|ground|)

    Args:
        g: Set function.
        ground: Finite ground set.
        max_k: Maximum depth to check.
        tol: Numerical tolerance.

    Returns:
        The tropical Hodge depth (capped at max_k).
    """
    subsets = powerset_list(ground)
    depth = -1
    for k in range(max_k + 1):
        if check_supermod_order(k, g, ground, subsets, tol):
            depth = k
        else:
            break
    return max(depth, 0) if depth == -1 else depth


def find_depth_witness(
    g: SetFn,
    ground: Set[int],
    k: int,
    tol: float = 1e-12
) -> Optional[Dict]:
    """
    Find a witness showing that SupermodularOrder (k+1) fails.

    Returns a dictionary with the violating configuration, or None if
    order k+1 actually holds.

    Args:
        g: Set function.
        ground: Finite ground set.
        k: The depth at which to find a witness of failure.
        tol: Numerical tolerance.

    Returns:
        Dictionary with witness data, or None.
    """
    subsets = powerset_list(ground)

    def find_violation(level: int, fn: SetFn, path: List[int]) -> Optional[Dict]:
        if level == 0:
            for s in subsets:
                for t in subsets:
                    d = supermod_defect(fn, s, t)
                    if d < -tol:
                        return {
                            'path': path,
                            's': set(s),
                            't': set(t),
                            'defect': d,
                            'level': k + 1 - len(path)
                        }
            return None
        else:
            # Check base
            v = find_violation(level - 1, fn, path)
            if v is not None:
                return v
            # Check each elemDiff
            for a in ground:
                dfn = elem_diff(fn, a)
                v = find_violation(level - 1, dfn, path + [a])
                if v is not None:
                    return v
            return None

    return find_violation(k + 1, g, [])


def memoized_set_fn(g: SetFn, ground: Set[int]) -> SetFn:
    """
    Create a memoized version of a set function for efficiency.

    Args:
        g: Original set function.
        ground: Ground set (for enumeration).

    Returns:
        Memoized set function.
    """
    cache: Dict[FrozenSet[int], float] = {}
    def cached_g(s: FrozenSet[int]) -> float:
        if s not in cache:
            cache[s] = g(s)
        return cache[s]
    return cached_g


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    # Example: cardinality function
    ground = {0, 1, 2}
    card_fn: SetFn = lambda s: float(len(s))

    print("Cardinality function on ground set {0,1,2}:")
    depth = compute_tropical_hodge_depth(card_fn, ground, max_k=4)
    print(f"  Tropical Hodge depth ≥ {depth}")

    # Example: |s|^2
    sq_fn: SetFn = lambda s: float(len(s)**2)
    depth = compute_tropical_hodge_depth(sq_fn, ground, max_k=4)
    print(f"\n|s|² function:")
    print(f"  Tropical Hodge depth = {depth}")

    witness = find_depth_witness(sq_fn, ground, depth)
    if witness:
        print(f"  Witness of failure at level {depth+1}:")
        print(f"    Path: {witness['path']}")
        print(f"    Sets: s={witness['s']}, t={witness['t']}")
        print(f"    Defect: {witness['defect']:.6f}")
