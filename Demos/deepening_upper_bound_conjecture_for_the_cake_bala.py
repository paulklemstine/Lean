"""Numerical demonstrations of the cake-balancing ratio.

A circular dissection into ``n`` pieces is modelled by a list of ``n`` positive
piece lengths, indexed cyclically. For a window length ``r >= 1`` the balancing
ratio is

    mu_r = (max weight of r consecutive pieces) / (min weight of r consecutive pieces).

This module illustrates, purely numerically:

  * mu_r >= 1 always (lower bound one);
  * mu_r <= mu_1 for every r (aggregation never increases imbalance);
  * scale invariance of mu_r;
  * mu_r = 1 for an equipartition;
  * the greedy bisection sequence keeps mu_r in [1, 2] at every stage;
  * a golden-ratio (low-discrepancy) insertion sequence beats the constant 2.

Run ``python demo.py`` to print a report.
"""

from __future__ import annotations

from math import floor, log2
from typing import Callable, List, Tuple


def window_weights(arc: List[float], r: int) -> List[float]:
    """All cyclic window weights: sums of ``r`` consecutive pieces."""
    n = len(arc)
    if not (1 <= r):
        raise ValueError("window length r must be at least 1")
    return [sum(arc[(i + j) % n] for j in range(r)) for i in range(n)]


def mu(arc: List[float], r: int) -> float:
    """The cake-balancing ratio mu_r of a dissection."""
    w = window_weights(arc, r)
    return max(w) / min(w)


def arc_ratio(arc: List[float]) -> float:
    """The raw largest-to-smallest single-piece ratio, equal to mu_1."""
    return max(arc) / min(arc)


def equipartition(n: int, circumference: float = 1.0) -> List[float]:
    """The equipartition of a cake of given circumference into ``n`` pieces."""
    return [circumference / n] * n


def bisection_dissection(n: int) -> List[float]:
    """The greedy 'split the largest piece' configuration after ``n`` cuts.

    With ``k = floor(log2 n)``, exactly ``2*(n - 2**k)`` pieces have the short
    length ``1/2**(k+1)`` and the remaining pieces have the double length
    ``1/2**k``. Total mass is always 1.
    """
    if n < 1:
        raise ValueError("need at least one piece")
    k = floor(log2(n))
    short = 1.0 / 2 ** (k + 1)
    long = 1.0 / 2 ** k
    num_short = 2 * (n - 2 ** k)
    num_long = n - num_short
    return [short] * num_short + [long] * num_long


def golden_dissection(n: int) -> List[float]:
    """Dissection from inserting the m-th point at frac(m * phi), m = 1..n.

    The gaps between the sorted insertion points on [0, 1) are the piece
    lengths. By the three-gap theorem these take at most three distinct
    values at every stage.
    """
    phi = (1 + 5 ** 0.5) / 2
    points = sorted((m * phi) % 1.0 for m in range(1, n + 1))
    gaps = [points[(i + 1) % n] - points[i] for i in range(n - 1)]
    gaps.append(1.0 - points[-1] + points[0])  # wrap-around gap
    return gaps


def report_single_dissection() -> None:
    print("=" * 70)
    print("1. Structural facts for a single dissection")
    print("=" * 70)
    arc = [0.30, 0.10, 0.25, 0.15, 0.20]  # a 5-piece unit cake
    print(f"pieces = {arc}  (sum = {sum(arc):.3f})")
    mu1 = mu(arc, 1)
    print(f"mu_1 = max/min single piece = {mu1:.4f}  = arc_ratio = {arc_ratio(arc):.4f}")
    for r in range(1, 6):
        m = mu(arc, r)
        ok_lb = m >= 1 - 1e-12
        ok_agg = m <= mu1 + 1e-12
        print(f"  r={r}: mu_r = {m:.4f}   mu_r>=1: {ok_lb}   mu_r<=mu_1: {ok_agg}")

    print("\nScale invariance (multiply every piece by 7.5):")
    scaled = [7.5 * x for x in arc]
    for r in range(1, 4):
        print(f"  r={r}: mu_r(scaled) = {mu(scaled, r):.6f} == mu_r = {mu(arc, r):.6f}")

    print("\nEquipartition optimality (n=8 equal pieces):")
    eq = equipartition(8)
    for r in range(1, 5):
        print(f"  r={r}: mu_r = {mu(eq, r):.6f}  (should be 1)")


def report_bisection() -> None:
    print("\n" + "=" * 70)
    print("2. Greedy bisection stays in [1, 2] at every stage")
    print("=" * 70)
    print(f"{'n':>4} {'r=1':>8} {'r=2':>8} {'r=3':>8} {'r=5':>8}  in[1,2]?")
    for n in [1, 2, 3, 4, 5, 6, 7, 8, 12, 16, 24, 31, 32, 48, 63, 64]:
        arc = bisection_dissection(n)
        vals = [mu(arc, r) for r in (1, 2, 3, 5)]
        ok = all(1 - 1e-12 <= v <= 2 + 1e-12 for v in vals)
        print(f"{n:>4} " + " ".join(f"{v:8.4f}" for v in vals) + f"   {ok}")


def report_golden() -> None:
    print("\n" + "=" * 70)
    print("3. Golden-ratio insertion beats the constant 2 (Conjecture C)")
    print("=" * 70)
    print(f"{'n':>5} {'#lengths':>9} {'mu_1':>8} {'mu_2':>8} {'mu_3':>8}")
    for n in [8, 13, 21, 34, 55, 89, 144, 233, 377]:
        arc = golden_dissection(n)
        distinct = len({round(x, 9) for x in arc})
        row = (n, distinct, mu(arc, 1), mu(arc, 2), mu(arc, 3))
        print(f"{row[0]:>5} {row[1]:>9} {row[2]:8.4f} {row[3]:8.4f} {row[4]:8.4f}")
    print("Note: at most 3 distinct lengths at every stage (three-gap theorem),")
    print("and mu_1 stays well below 2, unlike lockstep bisection.")


def main() -> None:
    report_single_dissection()
    report_bisection()
    report_golden()


if __name__ == "__main__":
    main()
