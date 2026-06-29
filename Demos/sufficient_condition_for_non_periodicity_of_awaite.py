"""
Numerical demonstrations for:

    A Diophantine Sufficient Condition for Strong Aperiodicity of Wang Stripe Sets

This self-contained script illustrates the key results:

  * Diophantine_irrational      -- a Diophantine real is irrational.
  * sqrt_Diophantine            -- every irrational sqrt(d) is Diophantine,
                                   with explicit constant c = 1/(2*sqrt(d)+1).
  * sqrt_two_Diophantine,
    sqrt_three_Diophantine      -- the two witnessing quadratic surds.
  * sqrt_two_diophantine_quarter-- the clean bound |sqrt(2) - a/b| >= 1/(4 b^2).
  * diophantine_pair_aperiodic  -- Diophantine pair => strongly aperiodic stripe set.
  * sqrt2_sqrt3_wang_aperiodic  -- the concrete aperiodic pair (sqrt 2, sqrt 3).

The Beatty step word d_alpha(n) = floor((n+1)alpha) - floor(n*alpha) is the
1-D skeleton of the stripe set W(alpha, beta).  Rational density => periodic
word; irrational density => non-periodic word; Diophantine density => the
non-repetition carries an explicit, quantitative floor.

Run:  python demo.py
Requires only the Python standard library.
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import List, Optional, Tuple


# --------------------------------------------------------------------------- #
# 1. The Beatty step word: the 1-D stripe skeleton                            #
# --------------------------------------------------------------------------- #
def beatty_step_word(alpha: float, length: int) -> List[int]:
    """Return d_alpha(0), ..., d_alpha(length-1) where
    d_alpha(n) = floor((n+1)*alpha) - floor(n*alpha)."""
    return [math.floor((n + 1) * alpha) - math.floor(n * alpha) for n in range(length)]


def beatty_step_word_exact(num: int, den: int, length: int) -> List[int]:
    """Exact Beatty step word for the rational density num/den (no round-off)."""
    out: List[int] = []
    for n in range(length):
        out.append(((n + 1) * num) // den - (n * num) // den)
    return out


def smallest_period(word: List[int]) -> Optional[int]:
    """Smallest p in {1,...,len//2} that is a period of the whole prefix `word`,
    or None if no such period is detected (evidence of non-periodicity)."""
    n = len(word)
    for p in range(1, n // 2 + 1):
        if all(word[i] == word[i + p] for i in range(n - p)):
            return p
    return None


# --------------------------------------------------------------------------- #
# 2. Diophantine separation: the c/b^2 floor                                  #
# --------------------------------------------------------------------------- #
def sqrt_separation_constant(d: int) -> float:
    """c = 1/(2*sqrt(d)+1), the constant from sqrt_Diophantine."""
    return 1.0 / (2.0 * math.sqrt(d) + 1.0)


def best_rational(alpha: float, b: int) -> int:
    """The numerator a minimizing |alpha - a/b| for fixed denominator b."""
    return round(alpha * b)


def diophantine_violation_scan(d: int, B: int, c: float) -> Tuple[bool, float]:
    """Check |sqrt(d) - a/b| >= c/b^2 for all 1<=b<=B using the closest a.
    Returns (all_ok, min_normalized_error) where the normalized error is
    b^2 * |sqrt(d) - a/b| (should stay >= c)."""
    root = math.sqrt(d)
    ok = True
    worst = math.inf
    for b in range(1, B + 1):
        a = best_rational(root, b)
        err = abs(root - a / b)
        normalized = b * b * err
        worst = min(worst, normalized)
        if err < c / (b * b) - 1e-12:
            ok = False
    return ok, worst


# --------------------------------------------------------------------------- #
# 3. Continued-fraction convergents: the worst approximators                  #
# --------------------------------------------------------------------------- #
def sqrt_continued_fraction(d: int, terms: int) -> List[int]:
    """Periodic continued-fraction expansion of sqrt(d) (d non-square)."""
    a0 = math.isqrt(d)
    if a0 * a0 == d:
        raise ValueError(f"{d} is a perfect square")
    cf = [a0]
    m, q, a = 0, 1, a0
    for _ in range(terms - 1):
        m = q * a - m
        q = (d - m * m) // q
        a = (a0 + m) // q
        cf.append(a)
    return cf


def convergents(cf: List[int]) -> List[Fraction]:
    """Convergents p_k/q_k of a continued fraction [a0; a1, a2, ...]."""
    p_prev, p_cur = 1, cf[0]
    q_prev, q_cur = 0, 1
    out = [Fraction(p_cur, q_cur)]
    for a in cf[1:]:
        p_prev, p_cur = p_cur, a * p_cur + p_prev
        q_prev, q_cur = q_cur, a * q_cur + q_prev
        out.append(Fraction(p_cur, q_cur))
    return out


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_periodic_vs_aperiodic() -> None:
    print("=" * 70)
    print("1. Beatty step words: rational => periodic, irrational => not")
    print("=" * 70)
    # Rational density 2/5: period exactly the denominator 5.
    word_rat = beatty_step_word_exact(2, 5, 40)
    p = smallest_period(word_rat)
    print(f"  alpha = 2/5 : word = {word_rat[:20]}...")
    print(f"               detected period = {p} (denominator in lowest terms = 5)")

    # Irrational density sqrt(2)-1 in (0,1): no short period.
    alpha = math.sqrt(2) - 1
    word_irr = beatty_step_word(alpha, 200)
    p2 = smallest_period(word_irr)
    print(f"  alpha = sqrt(2)-1 : word = {word_irr[:20]}...")
    print(f"               detected period over 200 symbols = {p2} (None = no repetition)")
    print()


def demo_sqrt_diophantine() -> None:
    print("=" * 70)
    print("2. Quadratic surds are Diophantine: |sqrt(d) - a/b| >= c/b^2")
    print("=" * 70)
    for d in (2, 3, 5):
        c = sqrt_separation_constant(d)
        ok, worst = diophantine_violation_scan(d, 2000, c)
        print(f"  d = {d}: c = 1/(2*sqrt({d})+1) = {c:.6f}")
        print(f"         all b<=2000 satisfy the bound? {ok}")
        print(f"         min normalized error b^2*|sqrt(d)-a/b| = {worst:.6f}  (>= c)")
    print()


def demo_sqrt_two_quarter() -> None:
    print("=" * 70)
    print("3. The clean bound for sqrt(2): |sqrt(2) - a/b| >= 1/(4 b^2)")
    print("=" * 70)
    root2 = math.sqrt(2)
    ok, worst = diophantine_violation_scan(2, 5000, 0.25)
    print(f"  Using c = 1/4: all b<=5000 satisfy the bound? {ok}")
    print(f"  min normalized error = {worst:.6f}  (>= 0.25)")
    # The famous convergent 99/70.
    a, b = 99, 70
    err = abs(root2 - a / b)
    print(f"  Spot check 99/70: |sqrt(2)-99/70| = {err:.3e}")
    print(f"                    floor 1/(4*70^2)  = {1/(4*70*70):.3e}  (error is larger, as promised)")
    print()


def demo_convergents() -> None:
    print("=" * 70)
    print("4. Continued-fraction convergents of sqrt(2): the worst case")
    print("=" * 70)
    cf = sqrt_continued_fraction(2, 10)
    print(f"  CF(sqrt 2) = {cf}  (the periodic [1; 2,2,2,...])")
    root2 = math.sqrt(2)
    print("   p/q          q^2*|sqrt(2)-p/q|")
    for frac in convergents(cf):
        p, q = frac.numerator, frac.denominator
        normalized = q * q * abs(root2 - p / q)
        print(f"   {p:>4}/{q:<5}   {normalized:.6f}")
    print("   (normalized error stays bounded away from 0: exponent 2 is the right scale)")
    print()


def demo_pair_aperiodic() -> None:
    print("=" * 70)
    print("5. Diophantine pair => strongly aperiodic stripe set  (sqrt 2, sqrt 3)")
    print("=" * 70)
    c2, c3 = sqrt_separation_constant(2), sqrt_separation_constant(3)
    joint = min(c2, c3)
    print(f"  c(sqrt2) = {c2:.6f}, c(sqrt3) = {c3:.6f}")
    print(f"  joint separation constant min = {joint:.6f}")
    print("  Both densities Diophantine => both irrational => both Beatty words")
    print("  non-periodic => W(sqrt2, sqrt3) admits no nonzero period vector.")
    # Empirical: neither stripe direction shows a short period.
    for name, alpha in (("sqrt2-1", math.sqrt(2) - 1), ("sqrt3-1", math.sqrt(3) - 1)):
        w = beatty_step_word(alpha, 300)
        print(f"  direction {name}: detected period over 300 symbols = {smallest_period(w)}")
    print()


def main() -> None:
    demo_periodic_vs_aperiodic()
    demo_sqrt_diophantine()
    demo_sqrt_two_quarter()
    demo_convergents()
    demo_pair_aperiodic()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
