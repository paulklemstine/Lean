"""
demo.py — Numerical demonstrations for the generalized q-game winning probability.

This script reproduces, in exact rational arithmetic, the sequence

    P(q, n)  =  probability that the Random player wins the q-game of size n,

defined by the well-founded recurrence

    P(q, 0)   = 1                                          (base case, formalized)
    P(q, n)   = ( 1 + sum_{j=0}^{n-1-q} P(q, j) ) / n      (n >= 1)

which is the forward form of the conditional, cycle-peeling recurrence

    P(q, n)   = 1/n + (1/n) * sum_{k=q+1}^{n} P(q, n-k).

It then verifies, numerically, the four certified properties:

    P_nonneg            :  0 <= P(q, n)                      for all q, n
    P_pos               :  0 <  P(q, n)                      for all q, n >= 1
    P_le_one            :       P(q, n) <= 1                 for q >= 1
    P_mem_unitInterval  :       P(q, n) in [0, 1]            for q >= 1

Finally it illustrates the alternative game-theoretic normalization P(0,q)=0,
under which P(n, 1) -> 1 - 1/e, and the companion critical-bond-dimension model
critBond(n) = 1 + n/10 (strictly increasing).

Run:  python3 demo.py
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import List


# --------------------------------------------------------------------------- #
#  Core evaluator (formalized normalization, base case P(q,0) = 1)
# --------------------------------------------------------------------------- #
def q_game_prefix(q: int, N: int, base_value: Fraction = Fraction(1)) -> List[Fraction]:
    """Return the exact list [P(q,0), P(q,1), ..., P(q,N)].

    Uses an O(N) running prefix sum of the window terms.  ``base_value`` selects
    the normalization: Fraction(1) is the formalized convention (P(q,0)=1),
    Fraction(0) is the game-theoretic convention (P(0,q)=0).
    """
    if N < 0:
        return []
    values: List[Fraction] = [base_value]  # P(q, 0)
    running: Fraction = Fraction(0)         # sum of values[0 .. top-1]
    covered: int = 0                        # how many leading terms are in `running`
    for m in range(1, N + 1):
        top: int = max(m - q, 0)            # window is values[0 .. top-1]
        while covered < top:                # extend the running prefix sum
            running += values[covered]
            covered += 1
        values.append((Fraction(1) + running) / m)
    return values


def q_game(q: int, n: int, base_value: Fraction = Fraction(1)) -> Fraction:
    """Single exact value P(q, n)."""
    return q_game_prefix(q, n, base_value)[n]


# --------------------------------------------------------------------------- #
#  Critical bond dimension bridge model
# --------------------------------------------------------------------------- #
def crit_bond(n: int) -> float:
    """Critical bond dimension to encode a length-n chain: 1 + n/10."""
    return 1.0 + n / 10.0


# --------------------------------------------------------------------------- #
#  Demonstrations
# --------------------------------------------------------------------------- #
def demo_value_table(N: int = 8) -> None:
    print("=" * 70)
    print("Exact P(q, n) — formalized normalization P(q,0) = 1")
    print("=" * 70)
    header = "  n |" + "".join(f"{'q=' + str(q):>12}" for q in range(1, 5))
    print(header)
    print("-" * len(header))
    tables = {q: q_game_prefix(q, N) for q in range(1, 5)}
    for n in range(N + 1):
        row = f"{n:3d} |"
        for q in range(1, 5):
            row += f"{str(tables[q][n]):>12}"
        print(row)
    print()


def demo_certified_properties(N: int = 60) -> None:
    print("=" * 70)
    print(f"Verifying certified properties numerically for 1<=q<=6, 0<=n<={N}")
    print("=" * 70)
    nonneg = pos = le_one = True
    for q in range(1, 7):
        vals = q_game_prefix(q, N)
        for n, v in enumerate(vals):
            if v < 0:
                nonneg = False
            if n >= 1 and not (v > 0):
                pos = False
            if q >= 1 and v > 1:
                le_one = False
    print(f"  P_nonneg           (0 <= P)          : {'PASS' if nonneg else 'FAIL'}")
    print(f"  P_pos              (0 <  P, n>=1)     : {'PASS' if pos else 'FAIL'}")
    print(f"  P_le_one           (P <= 1, q>=1)     : {'PASS' if le_one else 'FAIL'}")
    print(f"  P_mem_unitInterval (P in [0,1])       : "
          f"{'PASS' if (nonneg and le_one) else 'FAIL'}")
    print()


def demo_limit_1_minus_1_over_e(N: int = 200) -> None:
    print("=" * 70)
    print("Game-theoretic normalization P(0,q)=0 : limit at q=1 is 1 - 1/e")
    print("=" * 70)
    target = 1.0 - 1.0 / math.e
    vals = q_game_prefix(1, N, base_value=Fraction(0))
    print(f"  target 1 - 1/e            = {target:.10f}")
    for n in (4, 8, 20, 80, 200):
        print(f"  P(0-conv; n={n:<3d}, q=1)    = {float(vals[n]):.10f}"
              f"   (exact for n=4: {vals[4]})")
    print(f"  abs error at n={N}          = {abs(float(vals[N]) - target):.2e}")
    print()


def demo_limit_ladder(N: int = 400) -> None:
    print("=" * 70)
    print("Game-theoretic normalization: limit ladder L_q decreasing in q")
    print("=" * 70)
    for q in range(1, 5):
        vals = q_game_prefix(q, N, base_value=Fraction(0))
        print(f"  q={q}:  P(0-conv; n={N}) = {float(vals[N]):.6f}")
    print()


def demo_crit_bond(N: int = 6) -> None:
    print("=" * 70)
    print("Critical bond dimension critBond(n) = 1 + n/10 (strictly increasing)")
    print("=" * 70)
    prev = -math.inf
    mono = True
    for n in range(N + 1):
        c = crit_bond(n)
        if not (c > prev):
            mono = False
        print(f"  critBond({n}) = {c:.2f}")
        prev = c
    print(f"  strictly increasing: {'PASS' if mono else 'FAIL'}")
    print()


def main() -> None:
    demo_value_table()
    demo_certified_properties()
    demo_limit_1_minus_1_over_e()
    demo_limit_ladder()
    demo_crit_bond()


if __name__ == "__main__":
    main()
