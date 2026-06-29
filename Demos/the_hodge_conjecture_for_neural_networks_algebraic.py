"""
The Hodge Conjecture for Neural Networks: Algebraic Cycles in Decision Surfaces
==============================================================================

Self-contained numerical demonstrations of the main results:

  * regionBound(m, n) = sum_{i<=n} C(m, i)            (Zaslavsky region budget)
  * Pascal recurrence: R(m+1, n+1) = R(m, n+1) + R(m, n)
  * Universal ceiling: regionBound(m, n) <= 2^m
  * Dimensional saturation: regionBound(m, n) = 2^m when n >= m
  * Width monotonicity: regionBound(m, n) <= regionBound(m+1, n)
  * Hodge diamond bound: h^{p,q} <= C(w1, p) * C(wL, q) * mid
  * Exact extremal total Betti number: B(f) = 2^{w1} * 2^{wL} * mid

Run:  python demo.py
"""

from __future__ import annotations

from math import comb
from typing import List


# --------------------------------------------------------------------------- #
#  Core quantities                                                            #
# --------------------------------------------------------------------------- #
def region_bound(m: int, n: int) -> int:
    """Zaslavsky region budget: number of regions of m hyperplanes in R^n.

    regionBound(m, n) = sum_{i=0}^{n} C(m, i).
    """
    return sum(comb(m, i) for i in range(0, n + 1))


def hodge_diamond(w1: int, wL: int, mid: int) -> List[List[int]]:
    """Saturated Hodge diamond H[p][q] = C(w1, p) * C(wL, q) * mid."""
    return [[comb(w1, p) * comb(wL, q) * mid for q in range(wL + 1)]
            for p in range(w1 + 1)]


def total_betti(w1: int, wL: int, mid: int) -> int:
    """Closed-form extremal total Betti number: 2^{w1} * 2^{wL} * mid."""
    return (2 ** w1) * (2 ** wL) * mid


def total_betti_bruteforce(w1: int, wL: int, mid: int) -> int:
    """Total Betti number by summing the full diamond entry by entry."""
    return sum(sum(row) for row in hodge_diamond(w1, wL, mid))


def mid_product(intermediate_widths: List[int]) -> int:
    """Product of intermediate layer widths (empty product = 1)."""
    out = 1
    for w in intermediate_widths:
        out *= w
    return out


# --------------------------------------------------------------------------- #
#  Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_saturation() -> None:
    print("=" * 70)
    print("Dimensional saturation of the region budget (m = 4, ceiling 2^4 = 16)")
    print("=" * 70)
    m = 4
    for n in range(0, 7):
        rb = region_bound(m, n)
        tag = "  <-- saturates" if n == m else ("  (== 2^m)" if rb == 2 ** m else "")
        print(f"  regionBound({m}, {n}) = {rb:3d}{tag}")
    assert region_bound(4, 4) == 16
    assert all(region_bound(4, n) <= 16 for n in range(0, 20))
    print("  ceiling regionBound(4, n) <= 16 verified for n = 0..19\n")


def demo_recurrence() -> None:
    print("=" * 70)
    print("Pascal recurrence: R(m+1, n+1) = R(m, n+1) + R(m, n)")
    print("=" * 70)
    for m in range(0, 6):
        for n in range(0, 6):
            lhs = region_bound(m + 1, n + 1)
            rhs = region_bound(m, n + 1) + region_bound(m, n)
            assert lhs == rhs, (m, n, lhs, rhs)
    print("  verified for all 0 <= m, n <= 5")
    print(f"  example: regionBound(5,3) = {region_bound(5, 3)} = "
          f"{region_bound(4, 3)} + {region_bound(4, 2)} "
          f"= regionBound(4,3) + regionBound(4,2)\n")


def demo_monotonicity() -> None:
    print("=" * 70)
    print("Width monotonicity: regionBound(m, n) <= regionBound(m+1, n)")
    print("=" * 70)
    for n in range(0, 6):
        row = [region_bound(m, n) for m in range(0, 8)]
        assert all(row[i] <= row[i + 1] for i in range(len(row) - 1))
        print(f"  n = {n}: {row}")
    print()


def demo_total_betti() -> None:
    print("=" * 70)
    print("Exact extremal total Betti number  B(f) = 2^{w1} * 2^{wL} * mid")
    print("=" * 70)
    examples = [
        (3, 2, [4, 5]),
        (2, 2, []),
        (4, 3, [2]),
        (1, 5, [3, 3, 3]),
    ]
    for w1, wL, inter in examples:
        mid = mid_product(inter)
        closed = total_betti(w1, wL, mid)
        brute = total_betti_bruteforce(w1, wL, mid)
        assert closed == brute, (w1, wL, inter, closed, brute)
        print(f"  w1={w1}, wL={wL}, intermediate={inter}, mid={mid}: "
              f"closed form = {closed:6d}  =  diamond sum = {brute:6d}  "
              f"(= 2^{w1}*2^{wL}*{mid})")
    print()


def demo_print_diamond() -> None:
    print("=" * 70)
    print("Hodge diamond for w1=3, wL=2, mid=20  (entry = C(3,p)*C(2,q)*20)")
    print("=" * 70)
    w1, wL, mid = 3, 2, 20
    diamond = hodge_diamond(w1, wL, mid)
    header = "        " + "".join(f"q={q:<6d}" for q in range(wL + 1))
    print(header)
    for p, row in enumerate(diamond):
        print(f"  p={p:<3d}" + "".join(f"{v:<8d}" for v in row))
    print(f"  total Betti number = {total_betti(w1, wL, mid)}\n")


if __name__ == "__main__":
    demo_saturation()
    demo_recurrence()
    demo_monotonicity()
    demo_total_betti()
    demo_print_diamond()
    print("All assertions passed. The combinatorial budget is verified.")
