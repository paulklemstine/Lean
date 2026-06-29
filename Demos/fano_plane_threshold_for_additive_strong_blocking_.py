"""Numerical demonstrations of the Fano-plane strong-blocking threshold.

This self-contained script reproduces, by direct computation, the results
formalised for the Fano plane PG(2,2) in the cyclic (Singer) model:

  * points  = Z/7Z = {0, 1, 2, 3, 4, 5, 6}
  * lines   = {i, i+1, i+3} (mod 7), for i in Z/7Z
            = development of the perfect difference set {0, 1, 3}

A strong blocking set is a set of points meeting every line in at least two
points (a double blocking set, the planar specialisation of a strong /
cutting blocking set).

Results demonstrated:
  1. Every line has exactly 3 points.                       (fanoLine_card)
  2. Any two distinct points lie on a common line.          (two_points_collinear)
  3. The 6-set {1,...,6} is a strong blocking set.          (sb6_isStrongBlocking)
  4. No set of size <= 5 is a strong blocking set; min = 6. (fano_threshold_isLeast)
  5. The minimum strong blocking sets are exactly the 7
     single-point complements.                              (minimum_strongBlocking_iff)
  6. There are exactly 7 of them.                           (minimum_strongBlocking_count)
  7. 6 = (k-1)(q+1) for k = 3, q = 2 (saturation).          (fano_threshold_eq_formula)
"""

from __future__ import annotations

from itertools import combinations
from typing import FrozenSet, List, Set, Tuple

Point = int
Line = FrozenSet[Point]

POINTS: List[Point] = list(range(7))


def fano_line(i: Point) -> Line:
    """The i-th line {i, i+1, i+3} (mod 7) of the cyclic Fano plane."""
    return frozenset((i % 7, (i + 1) % 7, (i + 3) % 7))


def all_lines() -> List[Line]:
    """The seven lines of the Fano plane."""
    return [fano_line(i) for i in POINTS]


def is_strong_blocking(s: Set[Point]) -> bool:
    """True iff S meets every line in at least two of its three points."""
    return all(len(line & s) >= 2 for line in all_lines())


def min_strong_blocking_size() -> int:
    """Brute-force minimum size of a strong blocking set over all 2^7 subsets."""
    best = 8  # one more than |POINTS|
    for r in range(8):
        for combo in combinations(POINTS, r):
            if is_strong_blocking(set(combo)):
                best = min(best, r)
                break  # smallest size at this r found; no need to keep scanning r
    return best


def all_minimum_sets() -> List[FrozenSet[Point]]:
    """All strong blocking sets attaining the minimum size 6."""
    return [
        frozenset(combo)
        for combo in combinations(POINTS, 6)
        if is_strong_blocking(set(combo))
    ]


def point_complements() -> List[FrozenSet[Point]]:
    """The seven single-point complements Z/7Z \\ {p}."""
    return [frozenset(set(POINTS) - {p}) for p in POINTS]


def demo() -> None:
    lines = all_lines()

    print("=" * 64)
    print("Fano plane PG(2,2): cyclic model, lines = {i, i+1, i+3} (mod 7)")
    print("=" * 64)
    for i, line in enumerate(lines):
        print(f"  line {i}: {sorted(line)}")

    # 1. Every line has exactly 3 points.
    sizes = {len(line) for line in lines}
    print(f"\n[1] Every line has exactly 3 points: {sizes == {3}}  (sizes = {sizes})")

    # 2. Any two distinct points lie on a common line.
    def collinear(a: Point, b: Point) -> bool:
        return any({a, b} <= line for line in lines)

    all_collinear = all(collinear(a, b) for a, b in combinations(POINTS, 2))
    print(f"[2] Any two distinct points are collinear: {all_collinear}")

    # 3. The 6-set {1,...,6} blocks every line twice.
    sb6 = set(range(1, 7))
    print(f"[3] S6 = {sorted(sb6)} is strong blocking: {is_strong_blocking(sb6)}")
    print("    per-line intersection sizes:",
          [len(line & sb6) for line in lines])

    # 4. The threshold is exactly 6 (no 5-set works).
    m = min_strong_blocking_size()
    five_sets = [c for c in combinations(POINTS, 5) if is_strong_blocking(set(c))]
    print(f"[4] Minimum strong-blocking size = {m}  (expected 6)")
    print(f"    number of strong blocking sets of size 5: {len(five_sets)}  (expected 0)")

    # 5 & 6. Minimum sets are exactly the 7 point-complements.
    mins = set(all_minimum_sets())
    comps = set(point_complements())
    print(f"[5] Minimum sets equal the single-point complements: {mins == comps}")
    print(f"[6] Number of minimum strong blocking sets: {len(mins)}  (expected 7)")
    for s in sorted(mins, key=lambda t: sorted(t)):
        missing = (set(POINTS) - s).pop()
        print(f"    Z/7Z \\ {{{missing}}} = {sorted(s)}")

    # 7. Saturation of the general bound (k-1)(q+1).
    k, q = 3, 2
    formula = (k - 1) * (q + 1)
    print(f"[7] (k-1)(q+1) = ({k}-1)({q}+1) = {formula}  ==  threshold {m}: "
          f"{formula == m}")

    print("\nAll demonstrated results agree with the formalised theorems.")


if __name__ == "__main__":
    demo()
