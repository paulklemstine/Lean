"""
demo.py — Numerical demonstrations of the one-dimensional Brunn–Minkowski
inequality

        vol(A) + vol(B) <= vol(A + B)

for nonempty compact sets A, B of real numbers, where A + B is the Minkowski sum
{ a + b : a in A, b in B }.

We model a "compact set" as a finite union of closed intervals (the dense,
computable subclass on which the inequality is sharp on intervals and strict
otherwise). All arithmetic is performed exactly with fractions, so every reported
equality/inequality is exact, not floating-point.

Everything is inlined and uses type hints. Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from typing import List, Tuple

# A set is represented as a sorted list of disjoint closed intervals [lo, hi].
Interval = Tuple[Fraction, Fraction]
IntervalSet = List[Interval]


def canonicalize(intervals: List[Interval]) -> IntervalSet:
    """Merge overlapping/touching intervals into disjoint canonical form.

    Implements 'Algorithm A': sort by left endpoint, then sweep, fusing any
    interval whose left endpoint does not exceed the running right endpoint.
    Complexity O(m log m) in the number m of input intervals.
    """
    cleaned = [(lo, hi) for (lo, hi) in intervals if lo <= hi]
    if not cleaned:
        return []
    cleaned.sort(key=lambda iv: (iv[0], iv[1]))
    merged: IntervalSet = [cleaned[0]]
    for lo, hi in cleaned[1:]:
        last_lo, last_hi = merged[-1]
        if lo <= last_hi:  # overlapping or touching -> fuse
            merged[-1] = (last_lo, max(last_hi, hi))
        else:
            merged.append((lo, hi))
    return merged


def volume(intervals: IntervalSet) -> Fraction:
    """Total length (1-D Lebesgue volume) of a finite union of intervals."""
    canon = canonicalize(intervals)
    return sum((hi - lo for (lo, hi) in canon), Fraction(0))


def minkowski_sum(a: IntervalSet, b: IntervalSet) -> IntervalSet:
    """Minkowski sum A + B for finite unions of intervals.

    Implements 'Algorithm B': use distributivity, [p,q] + [r,s] = [p+r, q+s],
    over all pairs of pieces, then canonicalize. Complexity O(mn log(mn)).
    """
    pieces: List[Interval] = [
        (lo_a + lo_b, hi_a + hi_b)
        for (lo_a, hi_a) in a
        for (lo_b, hi_b) in b
    ]
    return canonicalize(pieces)


def set_sup(intervals: IntervalSet) -> Fraction:
    """Supremum (= max) of a nonempty finite union of intervals."""
    canon = canonicalize(intervals)
    if not canon:
        raise ValueError("empty set has no supremum")
    return max(hi for (_, hi) in canon)


def set_inf(intervals: IntervalSet) -> Fraction:
    """Infimum (= min) of a nonempty finite union of intervals."""
    canon = canonicalize(intervals)
    if not canon:
        raise ValueError("empty set has no infimum")
    return min(lo for (lo, _) in canon)


def translate(intervals: IntervalSet, t: Fraction) -> IntervalSet:
    """Translate every interval by t: A + {t}."""
    return canonicalize([(lo + t, hi + t) for (lo, hi) in intervals])


def fmt(intervals: IntervalSet) -> str:
    """Human-readable rendering of a canonical interval set."""
    canon = canonicalize(intervals)
    if not canon:
        return "{}"
    return " U ".join(f"[{lo},{hi}]" for (lo, hi) in canon)


def F(*nums: int) -> Fraction:
    """Convenience constructor: F(3) = 3, F(1, 2) = 1/2."""
    return Fraction(*nums)


def check_brunn_minkowski(a: IntervalSet, b: IntervalSet, label: str) -> None:
    """Verify vol(A) + vol(B) <= vol(A+B) and report the corner-anchoring data."""
    s = minkowski_sum(a, b)
    va, vb, vs = volume(a), volume(b), volume(s)
    lhs = va + vb
    print(f"=== {label} ===")
    print(f"  A        = {fmt(a)}      vol(A) = {va}")
    print(f"  B        = {fmt(b)}      vol(B) = {vb}")
    print(f"  A + B    = {fmt(s)}      vol(A+B) = {vs}")
    # Corner-anchoring witnesses from the proof:
    a_max, b_min = set_sup(a), set_inf(b)
    U = translate(a, b_min)        # A + {inf B}, anchored at the right edge
    V = translate(b, a_max)        # {sup A} + B, anchored at the left edge
    seam = a_max + b_min
    print(f"  anchors  : sup A = {a_max}, inf B = {b_min}, seam point a+b = {seam}")
    print(f"  U=A+{{infB}} = {fmt(U)}   vol(U) = {volume(U)} (= vol A)")
    print(f"  V={{supA}}+B = {fmt(V)}   vol(V) = {volume(V)} (= vol B)")
    relation = "=" if lhs == vs else "<"
    print(f"  Brunn-Minkowski: vol(A)+vol(B) = {lhs} {relation} {vs} = vol(A+B)")
    assert lhs <= vs, "Brunn-Minkowski inequality violated!"
    if lhs == vs:
        print("  -> EQUALITY (both sets are single intervals: sharp case)")
    else:
        print(f"  -> STRICT, surplus = {vs - lhs} (a gap forces extra length)")
    print()


def main() -> None:
    print("One-Dimensional Brunn-Minkowski Inequality: vol(A)+vol(B) <= vol(A+B)\n")

    # 1) Intervals: equality (the sharp case).
    check_brunn_minkowski([(F(0), F(1))], [(F(0), F(2))],
                          "Intervals [0,1] + [0,2]  (expect equality)")

    # 2) Two points spread an interval (vol A = 0 still obeys the bound).
    check_brunn_minkowski([(F(0), F(0)), (F(1), F(1))], [(F(0), F(1))],
                          "Two points {0,1} + [0,1]")

    # 3) A set with a hole: strict inequality, surplus equals the gap effect.
    check_brunn_minkowski([(F(0), F(1)), (F(3), F(4))], [(F(0), F(1))],
                          "Gapped set [0,1]U[3,4] + [0,1]  (expect strict)")

    # 4) Both sets gapped: strict, larger surplus.
    check_brunn_minkowski([(F(0), F(1)), (F(5), F(6))],
                          [(F(0), F(1)), (F(10), F(11))],
                          "Both gapped (expect strict)")

    # 5) Self-sum A + A for a gapped set.
    A = [(F(0), F(1)), (F(2), F(3))]
    check_brunn_minkowski(A, A, "Self-sum A + A with A = [0,1]U[2,3]")

    # 6) Fractional endpoints, exact rational arithmetic.
    check_brunn_minkowski([(F(-1, 2), F(1, 3))], [(F(1, 4), F(7, 4))],
                          "Fractional intervals [-1/2,1/3] + [1/4,7/4]")

    print("All checks passed: vol(A)+vol(B) <= vol(A+B) held in every case.")


if __name__ == "__main__":
    main()
