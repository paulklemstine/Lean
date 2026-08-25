#!/usr/bin/env python3
"""
demo.py -- Numerical demonstration of the three-budget taxonomy for halving search.

Three different numbers are routinely written "k*" in halving / binary-search cost
accounting.  They are not the same number.  This script defines all three, exhibits
the exact identities relating them, and reproduces the two recorded measurement rows.

    Pin           k_pin(W)          = ceil(log2 W)
    Census stop   k_opt^cost(W)     = argmin_k [ k + (W/2^k + 1)/2 ]
    Economics     k_opt^econ(T0,c)  = argmin_k [ c*(1+k) + (T0-1)/2^k ]

Results demonstrated (all exact, no floating-point slack beyond 1e-12):

  1. Anchor identity        econ(T0,1,k) = census(2(T0-1),k) + 1/2          for all k
  2. Naive shift            econ(T0,1,k+1) = census(T0-1,k) + 3/2           for all k
  3. Dyadic tie set         for W = 2^m the census argmin is {m-2, m-1}
                            and the optimal value is exactly m + 1/2
  4. Bracket criterion      k optimal  <=>  2^(k+1) <= W <= 2^(k+2)
  5. Pin is never optimal   gap = k_pin - k_opt in {1,2}, = 1 iff W = 2^(k+1)
  6. Overcharge bounds      1/2 <= census(W,k_pin) - census(W,k_opt) < 5/4
  7. Price rescaling        econ(T0,c,k) = c*(census(2(T0-1)/c, k) + 1/2)
  8. Recorded rows          T0 = 1072.425  -> continuous 9.536549, discrete 10
                            T0 = 286205.89 -> continuous 17.597922, discrete 18

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from math import ceil, log, log2
from typing import Iterable

TOL: float = 1e-12
LN2: float = log(2.0)


# --------------------------------------------------------------------------- #
# The three budgets
# --------------------------------------------------------------------------- #
def k_pin(width: int) -> int:
    """Pin: ceil(log2 W), the budget at which the support is fully resolved."""
    if width <= 1:
        return 0
    k = 0
    while (1 << k) < width:
        k += 1
    return k


def census(width: float, k: int) -> float:
    """Census total cost: k queries plus the residual priced at half the support."""
    return k + (width / 2.0**k + 1.0) / 2.0


def econ(t0: float, cq: float, k: int) -> float:
    """Economics cost: (k+1) queries at price cq, plus the residual scan from T0."""
    return cq * (1.0 + k) + (t0 - 1.0) / 2.0**k


def census_exact(width: Fraction, k: int) -> Fraction:
    """Exact rational census cost (used for the dyadic value m + 1/2)."""
    return Fraction(k) + (width / Fraction(2) ** k + 1) / 2


def argmin_set(f, kmax: int = 64) -> list[int]:
    """All minimisers of f over k = 0..kmax (the objectives are discretely convex)."""
    vals = [f(k) for k in range(kmax + 1)]
    best = min(vals)
    return [k for k, v in enumerate(vals) if v - best <= TOL]


def k_opt_cost(width: float, kmax: int = 64) -> list[int]:
    """Census argmin set."""
    return argmin_set(lambda k: census(width, k), kmax)


def k_opt_econ_discrete(t0: float, cq: float = 1.0, kmax: int = 64) -> list[int]:
    """Economics argmin set."""
    return argmin_set(lambda k: econ(t0, cq, k), kmax)


def k_opt_econ_continuous(t0: float, cq: float = 1.0) -> float:
    """Continuous economics optimum log2((T0-1) ln2 / cq)."""
    return log2((t0 - 1.0) * LN2 / cq)


def k_opt_cost_continuous(width: float) -> float:
    """Continuous census optimum log2(W ln2) - 1."""
    return log2(width * LN2) - 1.0


def bracket_argmin(width: float) -> int:
    """Closed form from the bracket criterion 2^(k+1) <= W <= 2^(k+2)."""
    if width <= 4.0:
        return 0
    return max(0, ceil(log2(width)) - 2)


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def show(title: str) -> None:
    print("\n" + "=" * 72)
    print(title)
    print("=" * 72)


def demo_anchor_identity(anchors: Iterable[float]) -> None:
    show("1. ANCHOR IDENTITY   econ(T0,1,k) = census(2(T0-1),k) + 1/2")
    worst = 0.0
    for t0 in anchors:
        for k in range(0, 40):
            lhs = econ(t0, 1.0, k)
            rhs = census(2.0 * (t0 - 1.0), k) + 0.5
            worst = max(worst, abs(lhs - rhs) / max(1.0, abs(lhs)))
    print(f"  max relative error over all tested (T0,k): {worst:.3e}")
    print("  => the two objectives differ by the CONSTANT 1/2; argmin sets are identical.")


def demo_naive_shift(anchors: Iterable[float]) -> None:
    show("2. NAIVE SHIFT   econ(T0,1,k+1) = census(T0-1,k) + 3/2  ->  argmin shift = +1")
    worst = 0.0
    for t0 in anchors:
        for k in range(0, 40):
            worst = max(worst, abs(econ(t0, 1.0, k + 1) - (census(t0 - 1.0, k) + 1.5)))
    print(f"  max absolute error: {worst:.3e}")
    print(f"  {'T0':>14} {'census argmin j':>16} {'econ argmin':>14} {'j+1 optimal?':>14}")
    for t0 in anchors:
        c = k_opt_cost(t0 - 1.0)
        e = k_opt_econ_discrete(t0, 1.0)
        ok = all(j + 1 in e for j in c)
        print(f"  {t0:>14.3f} {str(c):>16} {str(e):>14} {'yes' if ok else 'NO':>14}")
    print("  => every census minimiser j is shifted to the economics minimiser j+1:")
    print("     the discrepancy is exactly +1 query, never 'about one'.")


def demo_dyadic() -> None:
    show("3. DYADIC WIDTHS   W = 2^m: tie set {m-2, m-1}, optimal value exactly m + 1/2")
    print(f"  {'m':>3} {'W':>8} {'argmin set':>14} {'optimal value':>16} {'m + 1/2':>10}")
    for m in range(1, 13):
        w = 2**m
        opt = k_opt_cost(float(w))
        val = census_exact(Fraction(w), opt[0])
        print(f"  {m:>3} {w:>8} {str(opt):>14} {str(val):>16} {str(Fraction(2*m+1,2)):>10}")
    ok = all(
        census_exact(Fraction(2**m), k) == Fraction(2 * m + 1, 2)
        for m in range(2, 14)
        for k in (m - 2, m - 1)
    )
    print(f"  exact rational check for all m <= 13: {'PASS' if ok else 'FAIL'}")


def demo_bracket_and_pin(max_width: int = 4096) -> None:
    show("4-6. BRACKET, PIN GAP, AND OVERCHARGE BOUNDS  (all integer widths 2..4096)")
    bad_bracket = bad_gap = bad_charge = bad_dich = 0
    lo_charge, hi_charge = 10.0, 0.0
    for w in range(2, max_width + 1):
        opts = k_opt_cost(float(w))
        # 4. bracket criterion
        for k in opts:
            if not (w <= 2 ** (k + 2) and (k == 0 or 2 ** (k + 1) <= w)):
                bad_bracket += 1
        if bracket_argmin(float(w)) not in opts:
            bad_bracket += 1
        pin = k_pin(w)
        for k in opts:
            # 5. pin gap in {1,2}, = 1 iff W = 2^(k+1)
            gap = pin - k
            if gap not in (1, 2):
                bad_gap += 1
            if (gap == 1) != (w == 2 ** (k + 1)):
                bad_dich += 1
            # 6. overcharge bounds
            over = census(float(w), pin) - census(float(w), k)
            lo_charge, hi_charge = min(lo_charge, over), max(hi_charge, over)
            if not (0.5 - TOL <= over < 1.25):
                bad_charge += 1
    print(f"  bracket criterion violations           : {bad_bracket}")
    print(f"  pin gap outside {{1,2}}                  : {bad_gap}")
    print(f"  'gap = 1 iff W = 2^(k+1)' violations   : {bad_dich}")
    print(f"  overcharge outside [1/2, 5/4)          : {bad_charge}")
    print(f"  observed overcharge range              : [{lo_charge:.6f}, {hi_charge:.6f})")
    print("  => the pin is optimal for NO width; it overshoots by 1 or 2 queries,")
    print("     and by 2 at every non-dyadic width.")


def demo_price_rescaling() -> None:
    show("7. PRICE IS A PURE ANCHOR RESCALING   econ(T0,c,k) = c*(census(2(T0-1)/c,k)+1/2)")
    worst = 0.0
    print(f"  {'c_q':>8} {'econ argmin':>14} {'census argmin @ 2(T0-1)/c':>28}")
    t0 = 1072.425
    for cq in (0.25, 0.5, 1.0, 2.0, 8.0, 64.0):
        for k in range(0, 40):
            worst = max(
                worst,
                abs(econ(t0, cq, k) - cq * (census(2.0 * (t0 - 1.0) / cq, k) + 0.5)),
            )
        e = k_opt_econ_discrete(t0, cq)
        c = k_opt_cost(2.0 * (t0 - 1.0) / cq)
        print(f"  {cq:>8.2f} {str(e):>14} {str(c):>28}")
    print(f"  max absolute identity error: {worst:.3e}")
    print("  => a two-parameter family collapses to the one-parameter census family.")


def demo_recorded_rows() -> None:
    show("8. RECORDED MEASUREMENT ROWS")
    rows = [("balanced", 1072.425, 9.536549, 10), ("unbalanced", 286205.89, 17.597922, 18)]
    for name, t0, recorded_pred, recorded_arg in rows:
        pred = k_opt_econ_continuous(t0)
        disc = k_opt_econ_discrete(t0, 1.0)
        cens = k_opt_cost(2.0 * (t0 - 1.0))
        pin_w = ceil(2.0 * (t0 - 1.0))
        print(f"\n  {name}:  T0 = {t0}")
        print(f"    continuous optimum   : {pred:.6f}   (recorded {recorded_pred})")
        print(f"    discrete econ argmin : {disc}      (recorded {recorded_arg})")
        print(f"    matched-anchor census: {cens}      (same optimum)")
        print(f"    pin at W = {pin_w:<8}  : {k_pin(pin_w)}       "
              f"(overstates the work-optimal budget)")
        print(f"    naive same-number econ argmin: {k_opt_econ_discrete(t0 + 0.0, 1.0)}"
              f"  vs census(T0-1): {k_opt_cost(t0 - 1.0)}  -> shift +1")


def main() -> None:
    anchors = [3.0, 10.0, 100.0, 1072.425, 65537.0, 286205.89, 1.0e7]
    demo_anchor_identity(anchors)
    demo_naive_shift(anchors)
    demo_dyadic()
    demo_bracket_and_pin()
    demo_price_rescaling()
    demo_recorded_rows()
    print("\n" + "=" * 72)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 72)


if __name__ == "__main__":
    main()
