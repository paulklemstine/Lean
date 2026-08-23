"""Reference implementations of the three procedures of the knee calculus.

A. Monotone-hull knee extraction from a measured sweep.
B. Admissible gate window certification.
C. Minimum deployment entry cover (top-anchored greedy) with a packing certificate.

Self-contained; exact rational arithmetic throughout.
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import Dict, Iterable, List, Sequence, Tuple

Rat = Fraction


# --- Algorithm A -------------------------------------------------------------

def monotone_hull(sweep: Dict[int, Rat]) -> Dict[int, Rat]:
    """Running maximum of a measured sweep, repairing within-noise dips."""
    hull: Dict[int, Rat] = {}
    best = Rat(0)
    for k in sorted(sweep):
        best = max(best, sweep[k])
        hull[k] = best
    return hull


def knee_from_sweep(sweep: Dict[int, Rat], gate: Rat) -> int:
    """Least swept budget whose retained agreement reaches the gate.

    Binary search is valid because the hulled curve is monotone and the knee is
    its left adjoint: knee <= k iff gate <= A(k). Cost O(m) for the hull plus
    O(log m) comparisons.
    """
    hull = monotone_hull(sweep)
    budgets: List[int] = sorted(hull)
    lo, hi = 0, len(budgets) - 1
    if hull[budgets[hi]] < gate:
        raise ValueError("gate is not reached anywhere in the swept range")
    while lo < hi:
        mid = (lo + hi) // 2
        if hull[budgets[mid]] >= gate:
            hi = mid
        else:
            lo = mid + 1
    return budgets[lo]


# --- Algorithm B -------------------------------------------------------------

def admissible_gate_window(sweep: Dict[int, Rat], knee: int) -> Tuple[Rat, Rat]:
    """The half-open interval of gates for which this budget is exactly the knee.

    Every gate in (A(prev), A(knee)] yields the reported knee, so publishing the
    window rather than a single gate makes the claim falsifiable. Cost O(m).
    """
    hull = monotone_hull(sweep)
    budgets = sorted(hull)
    i = budgets.index(knee)
    lower = hull[budgets[i - 1]] if i > 0 else Rat(0)
    return lower, hull[knee]


def certify_knee(sweep: Dict[int, Rat], knee: int) -> str:
    lo, hi = admissible_gate_window(sweep, knee)
    return (f"knee = {knee} for every gate g in ({float(lo):.4f}, {float(hi):.4f}]; "
            f"width {float(hi - lo):.4f}")


# --- Algorithm C -------------------------------------------------------------

def serves(delta: int, entry: int, knee: int) -> bool:
    """Entry serves the knee: clears the gate, wastes at most delta keys."""
    return knee <= entry <= knee + delta


def greedy_entry_cover(knees: Iterable[int], delta: int) -> List[int]:
    """Minimum set of cache-size entries serving every knee at tolerance delta.

    Top-anchored greedy: repeatedly take the largest uncovered knee as an entry
    and delete everything it serves. Optimal, because the knees that triggered
    emissions are pairwise delta-separated and no entry can serve two such knees.
    Cost O(|K| log |K|).
    """
    remaining = sorted(set(knees), reverse=True)
    entries: List[int] = []
    while remaining:
        b = remaining[0]
        entries.append(b)
        remaining = [k for k in remaining if not serves(delta, b, k)]
    return entries


def packing_certificate(knees: Iterable[int], delta: int) -> List[int]:
    """A maximum delta-separated subset: a lower-bound witness matching the cover."""
    chosen: List[int] = []
    for k in sorted(set(knees)):
        if not chosen or chosen[-1] + delta < k:
            chosen.append(k)
    return chosen


def minimum_entries(knees: Sequence[int], delta: int) -> Tuple[int, List[int], List[int]]:
    """Return (minimum, cover, packing certificate); the two sizes always agree."""
    cover = greedy_entry_cover(knees, delta)
    pack = packing_certificate(knees, delta)
    assert len(cover) == len(pack), "greedy and packing must agree"
    return len(cover), cover, pack


# --- Demonstration -----------------------------------------------------------

if __name__ == "__main__":
    math_512 = {4: Rat(907, 1000), 8: Rat(959, 1000), 12: Rat(979, 1000),
                16: Rat(987, 1000), 20: Rat(989, 1000), 24: Rat(988, 1000)}
    g = Rat(981, 1000)
    k = knee_from_sweep(math_512, g)
    print("A:", f"knee at gate {float(g)} is {k}")
    print("B:", certify_knee(math_512, k))
    for delta in (3, 4):
        m, cover, pack = minimum_entries([16, 12, 16], delta)
        print("C:", f"delta={delta}: minimum {m} entries, cover {cover}, "
                    f"packing certificate {pack}")
    n, gate = 10000, Rat(98, 100)
    print("gate slack at n =", n, "is", int((1 - gate) * n), "unserved positions;",
          "the knee is the", math.ceil(gate * n), "-th smallest demand")
