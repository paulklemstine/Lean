from __future__ import annotations
from itertools import combinations
from typing import FrozenSet, List, Optional, Tuple

LINES: List[FrozenSet[int]] = [
    frozenset({0, 1, 2}), frozenset({0, 3, 4}), frozenset({0, 5, 6}),
    frozenset({1, 3, 5}), frozenset({1, 4, 6}), frozenset({2, 3, 6}),
    frozenset({2, 4, 5}),
]


def is_strong_blocking(s: FrozenSet[int]) -> bool:
    """Every line meets S in >= 2 points (spans the line over F_2)."""
    return all(len(s & line) >= 2 for line in LINES)


def minimum_strong_blocking() -> Tuple[int, List[FrozenSet[int]]]:
    """Smallest strong blocking sets in PG(2,2) by increasing-size search.

    Returns (minimum size, list of all witnesses of that size).
    Complexity: O(sum_{k} C(7,k) * |LINES|) <= O(2^7 * 7), i.e. constant for
    the Fano plane; the search short-circuits at the first size that works.
    """
    points = list(range(7))
    for k in range(len(points) + 1):
        witnesses: List[FrozenSet[int]] = []
        for combo in combinations(points, k):
            s = frozenset(combo)
            if is_strong_blocking(s):
                witnesses.append(s)
        if witnesses:
            return k, witnesses
    raise RuntimeError("no strong blocking set exists (impossible for PG(2,2))")


if __name__ == "__main__":
    size, witnesses = minimum_strong_blocking()
    print("minimum strong blocking size:", size)
    for w in witnesses:
        print("  ", sorted(w), " omits", (set(range(7)) - set(w)))
