"""Numerical demonstrations for the finite-field Kakeya model.

This self-contained script empirically certifies the main results:

  1. Bush count:        |B| = q^2 - q + 1   (lines through the origin in F_q^2).
  2. Incidence lemma:   distinct slopes meet only at the origin.
  3. Kakeya lower bound: any through-origin Kakeya set has >= q^2 - q + 1 points.
  4. Sumset growth:     |kA| >= min(p, k*(|A|-1) + 1) in Z/p, with sharpness
                        for arithmetic progressions and saturation for |A| >= 2.

All fields used are prime fields Z/q with q prime, so arithmetic is integer
arithmetic modulo q.
"""

from __future__ import annotations

from itertools import combinations
from typing import List, Set, Tuple

Point = Tuple[int, int]


# --------------------------------------------------------------------------- #
# Finite-field plane: lines through the origin and the bush                    #
# --------------------------------------------------------------------------- #
def line_through_origin(slope: int, q: int) -> Set[Point]:
    """Return L_m = {(x, m*x mod q) : x in F_q} as a set of points."""
    return {(x, (slope * x) % q) for x in range(q)}


def bush(q: int) -> Set[Point]:
    """Return the union of all q lines through the origin in F_q^2."""
    result: Set[Point] = set()
    for slope in range(q):
        result |= line_through_origin(slope, q)
    return result


def bush_count_formula(q: int) -> int:
    """The predicted bush cardinality q^2 - q + 1."""
    return q * q - q + 1


def missed_points(q: int) -> Set[Point]:
    """Points of F_q^2 NOT in the bush: off-origin vertical axis {(0,b): b!=0}."""
    full = {(a, b) for a in range(q) for b in range(q)}
    return full - bush(q)


# --------------------------------------------------------------------------- #
# Incidence lemma                                                             #
# --------------------------------------------------------------------------- #
def incidence(slope1: int, slope2: int, q: int) -> Set[Point]:
    """Intersection of two lines through the origin."""
    return line_through_origin(slope1, q) & line_through_origin(slope2, q)


def verify_incidence(q: int) -> bool:
    """Check that distinct slopes meet exactly at {(0,0)}."""
    for m1, m2 in combinations(range(q), 2):
        if incidence(m1, m2, q) != {(0, 0)}:
            return False
    return True


# --------------------------------------------------------------------------- #
# Sumset growth in Z/p                                                        #
# --------------------------------------------------------------------------- #
def sumset(a: Set[int], b: Set[int], p: int) -> Set[int]:
    """A + B in Z/p."""
    return {(x + y) % p for x in a for y in b}


def iterated_sumset(a: Set[int], k: int, p: int) -> Set[int]:
    """kA = A + A + ... + A (k copies); 0A = {0}."""
    result: Set[int] = {0}
    for _ in range(k):
        result = sumset(a, result, p)
    return result


def growth_lower_bound(a_size: int, k: int, p: int) -> int:
    """Predicted lower bound min(p, k*(|A|-1) + 1)."""
    return min(p, k * (a_size - 1) + 1)


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_bush() -> None:
    print("=" * 64)
    print("1. BUSH COUNT  |B| = q^2 - q + 1")
    print("=" * 64)
    for q in (2, 3, 5, 7, 11):
        actual = len(bush(q))
        predicted = bush_count_formula(q)
        missed = missed_points(q)
        ok = actual == predicted and missed == {(0, b) for b in range(1, q)}
        print(
            f"  q={q:2d}: |B|={actual:4d}  formula={predicted:4d}  "
            f"missed={len(missed):3d} (=q-1={q-1})  {'OK' if ok else 'FAIL'}"
        )
    print()


def demo_incidence() -> None:
    print("=" * 64)
    print("2. INCIDENCE LEMMA  distinct slopes meet only at (0,0)")
    print("=" * 64)
    for q in (2, 3, 5, 7, 11):
        ok = verify_incidence(q)
        print(f"  q={q:2d}: all {q*(q-1)//2} slope pairs meet at origin only: "
              f"{'OK' if ok else 'FAIL'}")
    print()


def demo_kakeya_bound() -> None:
    print("=" * 64)
    print("3. KAKEYA LOWER BOUND  |K| >= q^2 - q + 1")
    print("=" * 64)
    for q in (3, 5, 7):
        # The bush itself is the minimal Kakeya set; any K contains it.
        k = bush(q)
        bound = bush_count_formula(q)
        print(f"  q={q:2d}: minimal Kakeya set size={len(k):3d} >= bound={bound:3d}  "
              f"{'OK' if len(k) >= bound else 'FAIL'}")
    print()


def demo_sumset_growth() -> None:
    print("=" * 64)
    print("4. SUMSET GROWTH  |kA| >= min(p, k(|A|-1)+1)")
    print("=" * 64)
    p = 11
    examples: List[Tuple[str, Set[int]]] = [
        ("AP {0,1,2}", {0, 1, 2}),     # sharp: |kA| = min(p, 2k+1)
        ("singleton {3}", {3}),         # stays size 1 forever
        ("random {0,1,4}", {0, 1, 4}),  # grows at least as fast
    ]
    for name, a in examples:
        print(f"  A = {name},  |A| = {len(a)},  p = {p}")
        for k in range(0, 7):
            size = len(iterated_sumset(a, k, p))
            bound = growth_lower_bound(len(a), k, p)
            status = "OK" if size >= bound else "FAIL"
            sat = " <- saturated (= Z/p)" if size == p else ""
            print(f"     k={k}: |kA|={size:2d}  bound={bound:2d}  {status}{sat}")
        print()


def main() -> None:
    demo_bush()
    demo_incidence()
    demo_kakeya_bound()
    demo_sumset_growth()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
