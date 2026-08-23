#!/usr/bin/env python3
"""
Parity-corrected asymptotics for the information-free village game
==================================================================

A self-contained numerical companion.  Everything is computed in *exact*
rational arithmetic (``fractions.Fraction``) and only converted to floating
point at the moment of display, so every number printed below is a faithful
rendering of an exact value.

The model
---------
A population consists of ``v`` villagers and ``k`` wolves; the total
population is ``n = v + k``.  Play proceeds in rounds:

  * **Day.**  One living player, chosen uniformly at random from all ``n``
    of them, is eliminated.  Nobody has any information, hence the uniform
    draw -- this is the *information-free* game.
  * **Night.**  If at least one wolf survives the day, the wolves eliminate
    one villager.

The village wins when the last wolf is gone; the wolves win when the last
villager is gone.

The conserved quantity
----------------------
Whatever happens, the population drops by exactly two per round: a *hit*
removes a wolf by day and a villager by night, a *miss* removes a villager
by day and another villager by night.  Hence the parity of ``n`` is a
constant of the motion, and it survives all the way to absorption.

What the numbers below demonstrate
----------------------------------
1.  The exact wolf-win probabilities and the survival products.
2.  ``n * surv(n)^2 < 1`` for every even ``n`` and ``>= 1`` for every odd
    ``n`` -- a parity separation visible at *every* finite population, with
    separator exactly ``1 = (2/pi) * (pi/2)``.
3.  ``sqrt(n) * failProb`` converging to ``k*sqrt(2/pi)`` along even
    populations and to ``k*sqrt(pi/2)`` along odd ones, ratio ``pi/2``.
4.  The exact closed forms for one, two, three and four wolves.
5.  The sharp union-bound defect ``n * defect <= k(k-1)/2``, attained on the
    odd fibre for ``k = 2, 3``.
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import Dict, List, Tuple

# ----------------------------------------------------------------------
# Core quantities
# ----------------------------------------------------------------------


def surv(n: int) -> Fraction:
    """Probability that one designated wolf is never lynched, in a game whose
    initial population is ``n``.

    It is the product ``prod (1 - 1/n_i)`` along the deterministic population
    ladder ``n, n-2, n-4, ...``:

        surv(0) = surv(1) = 1,     surv(n) = surv(n-2) * (n-1)/n.
    """
    out = Fraction(1)
    for j in range(n, 1, -2):
        out *= Fraction(j - 1, j)
    return out


_FAIL: Dict[Tuple[int, int], Fraction] = {}
_FILLED: Tuple[int, int] = (-1, -1)


def _fill_fail_table(v_max: int, k_max: int) -> None:
    """Fill the wolf-win table bottom-up (iteratively, to avoid deep recursion)."""
    global _FILLED
    if v_max <= _FILLED[0] and k_max <= _FILLED[1]:
        return
    v_max = max(v_max, _FILLED[0])
    k_max = max(k_max, _FILLED[1])
    for k in range(0, k_max + 1):
        for v in range(0, v_max + 1):
            if (v, k) in _FAIL:
                continue
            if k == 0:
                _FAIL[(v, k)] = Fraction(0)
            elif v == 0:
                _FAIL[(v, k)] = Fraction(1)
            else:
                n = v + k
                _FAIL[(v, k)] = (Fraction(k, n) * _FAIL[(v - 1, k - 1)]
                                 + Fraction(v, n) * _FAIL[(max(v - 2, 0), k)])
    _FILLED = (v_max, k_max)


def fail_prob(v: int, k: int) -> Fraction:
    """Probability that the **wolves** win, starting from ``v`` villagers and
    ``k`` wolves at the beginning of a day.

    Recursion: with probability ``k/(v+k)`` the vote hits a wolf and the state
    becomes ``(v-1, k-1)``; with probability ``v/(v+k)`` it misses and the
    state becomes ``(v-2, k)``.
    """
    _fill_fail_table(v, k)
    return _FAIL[(v, k)]


def village_win(v: int, k: int) -> Fraction:
    """Complementary village win probability."""
    return Fraction(1) - fail_prob(v, k)


def defect(v: int, k: int) -> Fraction:
    """Gap between the union bound ``k * surv(n)`` and the true wolf-win
    probability, where ``n = v + k``."""
    return Fraction(k) * surv(v + k) - fail_prob(v, k)


def wallis_W(m: int) -> Fraction:
    """Wallis partial product ``prod_{j=1}^{m} (2j)^2 / ((2j-1)(2j+1))``,
    which converges to ``pi/2``."""
    out = Fraction(1)
    for j in range(1, m + 1):
        out *= Fraction((2 * j) ** 2, (2 * j - 1) * (2 * j + 1))
    return out


# ----------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------


def demo_lab_notes() -> None:
    """Exact values of the game for the populations that motivated the work."""
    print("=" * 74)
    print("1.  EXACT WOLF-WIN PROBABILITIES, POPULATIONS 7 THROUGH 20")
    print("=" * 74)
    print(f"{'n':>4} {'parity':>7} {'k=1':>18} {'k=2':>18} {'k=3':>18}")
    for n in range(7, 21):
        row = [f"{n:>4}", f"{'even' if n % 2 == 0 else 'odd':>7}"]
        for k in (1, 2, 3):
            p = fail_prob(n - k, k)
            row.append(f"{str(p):>18}")
        print(" ".join(row))
    print()


def demo_finite_parity_separation() -> None:
    """``n * surv(n)^2`` sits strictly below 1 for even n, at or above 1 for odd n."""
    print("=" * 74)
    print("2.  THE SEPARATOR: n * surv(n)^2 STRADDLES 1 ACCORDING TO PARITY")
    print("=" * 74)
    print(f"{'n':>4} {'parity':>7} {'n*surv(n)^2 (exact)':>26} {'decimal':>12} {'side':>7}")
    for n in range(2, 25):
        q = Fraction(n) * surv(n) ** 2
        side = "< 1" if q < 1 else ">= 1"
        print(f"{n:>4} {'even' if n % 2 == 0 else 'odd':>7} {str(q):>26} "
              f"{float(q):>12.8f} {side:>7}")
    print(f"\n  Limits: even -> 2/pi = {2 / math.pi:.8f}, "
          f"odd -> pi/2 = {math.pi / 2:.8f}")
    print(f"  Geometric mean of the two limits: (2/pi)*(pi/2) = "
          f"{(2 / math.pi) * (math.pi / 2):.8f}  <-- exactly the separator\n")


def demo_two_asymptotics(k: int = 1, up_to: int = 1300) -> None:
    """``sqrt(n) * failProb`` along the two parity subsequences."""
    print("=" * 74)
    print(f"3.  TWO ASYMPTOTIC EXPANSIONS, WOLF COUNT k = {k}")
    print("=" * 74)
    c_even = k * math.sqrt(2 / math.pi)
    c_odd = k * math.sqrt(math.pi / 2)
    print(f"  predicted even-population constant  k*sqrt(2/pi) = {c_even:.10f}")
    print(f"  predicted odd-population  constant  k*sqrt(pi/2) = {c_odd:.10f}")
    print(f"  predicted ratio                            pi/2 = {math.pi / 2:.10f}\n")
    print(f"{'n (even)':>9} {'sqrt(n)*p':>14} | {'n (odd)':>9} {'sqrt(n)*p':>14} "
          f"| {'ratio':>12}")
    n = 10
    while n <= up_to:
        ne, no = n, n + 1
        pe = float(fail_prob(ne - k, k)) * math.sqrt(ne)
        po = float(fail_prob(no - k, k)) * math.sqrt(no)
        print(f"{ne:>9} {pe:>14.9f} | {no:>9} {po:>14.9f} | {po / pe:>12.9f}")
        n *= 2
    print()


def demo_closed_forms() -> None:
    """Verify the exact closed-form ladder for one to four wolves."""
    print("=" * 74)
    print("4.  EXACT CLOSED FORMS FOR ONE THROUGH FOUR WOLVES")
    print("=" * 74)
    checks: List[Tuple[str, bool]] = []

    ok = all(fail_prob(v, 1) == surv(v + 1) for v in range(0, 40))
    checks.append(("k=1, all n:      failProb(v,1) = surv(v+1)", ok))

    ok = all(fail_prob(2 * m, 2) == 2 * surv(2 * m + 2) for m in range(0, 20))
    checks.append(("k=2, n even:     failProb    = 2*surv(n)", ok))

    ok = all(fail_prob(2 * m + 1, 2)
             == 2 * surv(2 * m + 3) - Fraction(1, 2 * m + 3) for m in range(0, 20))
    checks.append(("k=2, n odd:      failProb    = 2*surv(n) - 1/n", ok))

    ok = all(fail_prob(2 * m, 3)
             == 3 * surv(2 * m + 3) - Fraction(3, 2 * m + 3) for m in range(0, 20))
    checks.append(("k=3, n odd:      failProb    = 3*surv(n) - 3/n", ok))

    ok = all(fail_prob(2 * m + 1, 3)
             == Fraction(6 * m + 8, 2 * m + 3) * surv(2 * m + 4) for m in range(0, 20))
    checks.append(("k=3, n even:     failProb    = (3n-4)/(n-1) * surv(n)", ok))

    ok = all(fail_prob(2 * M, 4)
             == Fraction(8 * M + 8, 2 * M + 3) * surv(2 * M + 4) for M in range(0, 20))
    checks.append(("k=4, n even:     failProb    = (4n-8)/(n-1) * surv(n)", ok))

    for label, ok in checks:
        print(f"  [{'OK ' if ok else 'FAIL'}]  {label}")
    print()


def demo_sharp_defect() -> None:
    """The sharp bound ``n * defect <= k(k-1)/2`` and its attainment."""
    print("=" * 74)
    print("5.  THE SHARP UNION-BOUND DEFECT:  n * defect  <=  k(k-1)/2")
    print("=" * 74)
    for k in range(1, 8):
        bound = Fraction(k * (k - 1), 2)
        worst_even = max(
            (Fraction(n) * defect(n - k, k) for n in range(max(k, 2), 60) if n % 2 == 0),
            default=Fraction(0))
        worst_odd = max(
            (Fraction(n) * defect(n - k, k) for n in range(max(k, 2), 60) if n % 2 == 1),
            default=Fraction(0))
        print(f"  k = {k}:  bound C(k,2) = {str(bound):>6} | "
              f"max over even n = {float(worst_even):>9.6f} | "
              f"max over odd n = {float(worst_odd):>9.6f}")
    print("\n  On the odd fibre the bound is attained exactly for k = 2 and k = 3:")
    for k in (2, 3):
        vals = {n: Fraction(n) * defect(n - k, k)
                for n in range(k + 1, 20) if (n - k) % 2 == 1 or True}
        odd_vals = {n: q for n, q in vals.items() if n % 2 == 1}
        shown: Dict[int, str] = {n: str(q) for n, q in list(odd_vals.items())[:6]}
        print(f"    k = {k}:  n * defect = {shown}")
    print("\n  On the even fibre the defect is o(1) but not zero for k >= 3:")
    for k in (2, 3, 4):
        evens = [(n, float(Fraction(n) * defect(n - k, k)))
                 for n in range(k + 2, 40) if n % 2 == 0][:6]
        print(f"    k = {k}:  " + ", ".join(f"n={n}: {q:.6f}" for n, q in evens))
    print()


def demo_wallis_identities() -> None:
    """The two exact identities that drive everything."""
    print("=" * 74)
    print("6.  THE EXACT WALLIS IDENTITIES")
    print("=" * 74)
    print(f"{'m':>4} {'surv(2m+1)/surv(2m)':>26} {'W_m':>26} {'match':>7}")
    for m in range(0, 8):
        ratio = surv(2 * m + 1) / surv(2 * m)
        w = wallis_W(m)
        print(f"{m:>4} {str(ratio):>26} {str(w):>26} {str(ratio == w):>7}")
    print()
    ok1 = all(surv(n) * surv(n + 1) == Fraction(1, n + 1) for n in range(0, 60))
    ok2 = all(Fraction(2 * m + 1) * surv(2 * m + 1) ** 2 == wallis_W(m) for m in range(0, 40))
    ok3 = all(Fraction(2 * m + 1) * surv(2 * m) ** 2 * wallis_W(m) == 1 for m in range(0, 40))
    print(f"  [{'OK ' if ok1 else 'FAIL'}]  surv(n) * surv(n+1) = 1/(n+1)")
    print(f"  [{'OK ' if ok2 else 'FAIL'}]  (2m+1) * surv(2m+1)^2 = W_m")
    print(f"  [{'OK ' if ok3 else 'FAIL'}]  (2m+1) * surv(2m)^2 * W_m = 1")
    print()


def demo_village_wins() -> None:
    """The village still wins with probability tending to 1, along either parity."""
    print("=" * 74)
    print("7.  THE VILLAGE STILL WINS -- BUT AT PARITY-DEPENDENT SPEED")
    print("=" * 74)
    k = 3
    print(f"  wolf count k = {k};  villageWin = 1 - c(parity)*n^(-1/2) + o(n^(-1/2))")
    print(f"{'n':>7} {'parity':>7} {'villageWin':>14} {'sqrt(n)*(1-villageWin)':>24}")
    for n in [50, 51, 200, 201, 800, 801, 1600, 1601]:
        p = fail_prob(n - k, k)
        print(f"{n:>7} {'even' if n % 2 == 0 else 'odd':>7} "
              f"{float(1 - p):>14.9f} {math.sqrt(n) * float(p):>24.9f}")
    print(f"\n  limits: {k}*sqrt(2/pi) = {k * math.sqrt(2 / math.pi):.9f} (even), "
          f"{k}*sqrt(pi/2) = {k * math.sqrt(math.pi / 2):.9f} (odd)\n")


def main() -> None:
    demo_lab_notes()
    demo_finite_parity_separation()
    demo_two_asymptotics(k=1)
    demo_two_asymptotics(k=3, up_to=1300)
    demo_closed_forms()
    demo_sharp_defect()
    demo_wallis_identities()
    demo_village_wins()
    print("=" * 74)
    print("All exact identities verified in rational arithmetic.")
    print("=" * 74)


if __name__ == "__main__":
    main()
