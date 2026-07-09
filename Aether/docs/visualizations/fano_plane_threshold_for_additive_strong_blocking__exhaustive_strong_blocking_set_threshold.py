"""
Algorithm: exhaustive determination of the strong-blocking-set threshold of PG(2,q)
modelled cyclically by a perfect difference set.

Given a cyclic (Singer) projective plane on n = q^2 + q + 1 points whose lines are the
translates of a perfect difference set D modulo n, this routine enumerates all subsets of
the point set, tests the double-blocking condition (every line met in >= 2 points), and
returns the minimum size, the extremal sets, and their count.

For the Fano plane take q = 2, n = 7, D = {0, 1, 3}; the threshold returned is 6.
"""

from __future__ import annotations

from itertools import combinations
from typing import FrozenSet, List, Tuple


def cyclic_lines(n: int, diff_set: Tuple[int, ...]) -> List[FrozenSet[int]]:
    """All n translates {i + d : d in diff_set} (mod n) of the difference set."""
    return [frozenset((i + d) % n for d in diff_set) for i in range(n)]


def is_double_blocking(s: FrozenSet[int], lines: List[FrozenSet[int]]) -> bool:
    """True iff s meets every line in at least two points."""
    return all(len(line & s) >= 2 for line in lines)


def strong_blocking_threshold(
    n: int, diff_set: Tuple[int, ...]
) -> Tuple[int, List[FrozenSet[int]]]:
    """Return (minimum strong-blocking-set size, list of all extremal sets).

    Complexity: O(2^n * n * |D|). Exact for small n (n = 7 -> 128 subsets)."""
    lines = cyclic_lines(n, diff_set)
    points = tuple(range(n))
    best_size = n + 1
    extremal: List[FrozenSet[int]] = []
    for r in range(n + 1):
        for combo in combinations(points, r):
            s = frozenset(combo)
            if is_double_blocking(s, lines):
                if r < best_size:
                    best_size = r
                    extremal = [s]
                elif r == best_size:
                    extremal.append(s)
    return best_size, extremal


if __name__ == "__main__":
    threshold, sets = strong_blocking_threshold(7, (0, 1, 3))
    print(f"Fano plane PG(2,2): strong-blocking threshold = {threshold}")
    print(f"number of extremal sets = {len(sets)}")
    print(f"(k-1)(q+1) with k=3, q=2 = {(3 - 1) * (2 + 1)}  -> bound saturated")
