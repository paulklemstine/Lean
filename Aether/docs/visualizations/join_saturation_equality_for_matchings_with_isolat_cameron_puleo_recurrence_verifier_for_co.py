from __future__ import annotations
from typing import FrozenSet, Iterable, Tuple

Edge = FrozenSet[int]
Graph = Tuple[int, FrozenSet[Edge]]

# Requires sat_number from Algorithm A and cone from Algorithm B.


def matching_plus_isolated(t: int, q: int) -> Graph:
    """F = tK_2 u qK_1 on 2t + q vertices (Definition 6)."""
    n = 2 * t + q
    return (n, frozenset(frozenset((2 * k, 2 * k + 1)) for k in range(t)))


def verify_recurrence(t: int, q: int, n_values: Iterable[int]) -> bool:
    """Main recurrence: sat(n, K_1 v F) = (n-1) + sat(n-1, F) for F = tK_2 u qK_1."""
    from_algoA_sat_number = sat_number  # noqa: F821  (provided by Algorithm A)
    from_algoB_cone = cone              # noqa: F821  (provided by Algorithm B)
    F = matching_plus_isolated(t, q)
    coneF = from_algoB_cone(F)
    ok = True
    for n in n_values:
        lhs = from_algoA_sat_number(n, coneF)
        rhs = (n - 1) + from_algoA_sat_number(n - 1, F)
        ok = ok and (lhs == rhs)
    return ok
