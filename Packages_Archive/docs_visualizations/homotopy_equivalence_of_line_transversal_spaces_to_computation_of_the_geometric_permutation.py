from __future__ import annotations
from typing import Sequence

def geometric_permutation(params: Sequence[float]) -> tuple[int, ...]:
    """
    Compute the geometric permutation induced by a crossing.

    params[i] is the parameter at which the directed line meets convex set i.
    Returns the indices sorted by meeting parameter -- the order in which the
    line encounters the sets along its orientation.

    Complexity: O(m log m) for m sets (a single sort).
    """
    return tuple(sorted(range(len(params)), key=lambda i: params[i]))

def is_strict_total_order(params: Sequence[float]) -> bool:
    """Theorem 4.5: pairwise-disjoint sets yield distinct parameters."""
    return len(set(params)) == len(params)

def reverse_permutation(params: Sequence[float]) -> tuple[int, ...]:
    """Theorem 4.7: the reversed line negates parameters, reversing the order."""
    return geometric_permutation([-p for p in params])