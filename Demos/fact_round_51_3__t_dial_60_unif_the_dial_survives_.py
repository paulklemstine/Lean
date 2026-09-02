#!/usr/bin/env python3
"""
Tie ceilings of the trailing-zero statistic: numerical demonstration.

This self-contained script reproduces, in exact rational arithmetic, every
numerical claim of the accompanying paper:

  1.  The ceiling functional  rho^2_max(m) = 1 - (sum m_j^3 - n) / (n^3 - n).
  2.  The dyadic (uniform-draw) profile and the closed form
          rho^2_max = (6/7) (1 + 1/(N(N+1))),  N = 2^b.
  3.  The hockey-stick (fixed-weight) profile  m_k = C(b-1-k, w-1),
      verified against brute-force enumeration of the words.
  4.  The Catalan spine  m_0 = (2v+1) Cat_v,  m_1 = (v+1) Cat_v,
      2 m_1 - m_0 = Cat_v.
  5.  The two-sided bracket  6/7 - 1/(15(v+1)) < rho^2_max(B_v) < 6/7  (v >= 2),
      with equality at v = 1, and the draw-law sandwich.
  6.  The half-weight phase boundary: sign(rho^2_max - 6/7) flips exactly at 2w = b.
  7.  The transfer principle and the optimality of the flat two-block split.
  8.  The radix law  rho^2_max = (3q/(q^2+q+1)) (1 + 1/(N(N+1))),  N = q^b.
  9.  The 60-bit deployment reading placed against both ceilings.

Run:  python3 demo.py
No third-party dependencies.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations
from math import comb
from typing import Dict, Iterable, List, Sequence, Tuple

SIX_SEVENTHS = Fraction(6, 7)


# ----------------------------------------------------------------------------
# 1. The ceiling functional
# ----------------------------------------------------------------------------

def cube_sum(profile: Sequence[int]) -> int:
    """Sum of cubes of the tie-block sizes."""
    return sum(m ** 3 for m in profile)


def tie_correction(profile: Sequence[int]) -> Fraction:
    """Classical Spearman tie correction  T = sum (m^3 - m) / 12."""
    return Fraction(sum(m ** 3 - m for m in profile), 12)


def ceiling(profile: Sequence[int]) -> Fraction:
    """Exact rho^2_max = 1 - 12 T / (n^3 - n) for a tie profile."""
    n = sum(profile)
    if n < 2:
        raise ValueError("a ceiling needs at least two observations")
    return Fraction(1) - Fraction(cube_sum(profile) - n, n ** 3 - n)


# ----------------------------------------------------------------------------
# 2. Profiles
# ----------------------------------------------------------------------------

def dyadic_profile(b: int) -> List[int]:
    """Tie profile of nu_2 on uniform b-bit words: 2^{b-1}, ..., 2, 1, and {0}."""
    return [2 ** (b - 1 - k) for k in range(b)] + [1]


def radix_profile(q: int, b: int) -> List[int]:
    """Tie profile of the base-q valuation on uniform length-b strings."""
    return [(q - 1) * q ** (b - 1 - k) for k in range(b)] + [1]


def hockey_stick_profile(b: int, w: int) -> List[int]:
    """Tie profile of the trailing-zero statistic on the weight-w words of b bits."""
    return [comb(b - 1 - k, w - 1) for k in range(b - w + 1)]


def hockey_stick_vr(v: int, r: int) -> List[int]:
    """Same profile in the (v, r) parametrisation: weight v+1, bit length v+1+r."""
    return [comb(v + r - k, v) for k in range(r + 1)]


def balanced_profile(v: int) -> List[int]:
    """Balanced law: bit length 2v+2, weight v+1."""
    return hockey_stick_vr(v, v + 1)


def brute_force_profile(b: int, w: int) -> List[int]:
    """Enumerate the weight-w words of b bits and tabulate min(S) directly."""
    blocks: Dict[int, int] = {}
    for subset in combinations(range(b), w):
        blocks[min(subset)] = blocks.get(min(subset), 0) + 1
    return [blocks[k] for k in sorted(blocks)]


def catalan(v: int) -> int:
    return comb(2 * v, v) // (v + 1)


# ----------------------------------------------------------------------------
# Closed forms
# ----------------------------------------------------------------------------

def dyadic_closed_form(b: int) -> Fraction:
    n = 2 ** b
    return SIX_SEVENTHS * (1 + Fraction(1, n * (n + 1)))


def radix_closed_form(q: int, b: int) -> Fraction:
    n = q ** b
    return Fraction(3 * q, q * q + q + 1) * (1 + Fraction(1, n * (n + 1)))


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def demo_functional() -> None:
    banner("1.  The ceiling functional on small profiles")
    examples: List[Tuple[List[int], str]] = [
        ([1, 1, 1, 1], "no ties           -> 1"),
        ([4], "one block         -> 0"),
        ([2, 1], "corner profile    -> 3/4"),
        ([3, 2, 1], "balanced, b=4     -> 6/7 exactly"),
        ([4, 3, 2, 1], "weight 2 on 5 bits-> 10/11"),
        ([10, 6, 3, 1], "balanced, b=6     -> 563/665"),
        ([35, 20, 10, 4, 1], "balanced, b=8     -> 1386/1633"),
    ]
    for profile, note in examples:
        c = ceiling(profile)
        print(f"  {str(profile):>22}   rho^2_max = {str(c):>12} = {float(c):.6f}   {note}")


def demo_dyadic() -> None:
    banner("2.  Uniform draws: dyadic profile and the closed form (6/7)(1 + 1/(N(N+1)))")
    print("   b   profile head            rho^2_max (exact)         closed form matches")
    for b in (1, 2, 3, 4, 6, 8, 16, 32, 60):
        prof = dyadic_profile(b)
        exact = ceiling(prof)
        closed = dyadic_closed_form(b)
        head = ", ".join(str(x) for x in prof[:3]) + (", ..." if len(prof) > 3 else "")
        print(f"  {b:3d}  [{head:<20}]  {float(exact):.24f}   {exact == closed}")
    print()
    print(f"  6/7 = {float(SIX_SEVENTHS):.24f}")
    print("  every finite bit length is STRICTLY ABOVE 6/7; excess at b=60 is "
          f"{float(dyadic_closed_form(60) - SIX_SEVENTHS):.3e}")


def demo_hockey_stick() -> None:
    banner("3.  Fixed-weight draws: the hockey-stick profile is the true tie profile")
    print("  brute-force enumeration vs. the binomial formula  m_k = C(b-1-k, w-1)")
    for b, w in ((4, 2), (5, 2), (6, 3), (7, 3), (8, 4), (9, 4)):
        formula = hockey_stick_profile(b, w)
        brute = brute_force_profile(b, w)
        total_ok = sum(formula) == comb(b, w)
        print(f"  b={b}, w={w}:  formula={str(formula):<26} brute={str(brute):<26} "
              f"equal={formula == brute}  hockey-stick sum={total_ok}")


def demo_catalan() -> None:
    banner("4.  The Catalan spine of the balanced profile")
    print("    v   Cat_v      m_0            m_1            2 m_1 - m_0   equals Cat_v")
    for v in range(1, 9):
        prof = balanced_profile(v)
        m0, m1 = prof[0], prof[1]
        defect = 2 * m1 - m0
        print(f"  {v:3d}  {catalan(v):>7}  {m0:>13}  {m1:>13}  {defect:>12}   "
              f"{defect == catalan(v)}")
    print()
    print("  m_0 = (2v+1) Cat_v and m_1 = (v+1) Cat_v, so the first step decays by")
    print("  (v+1)/(2v+1) > 1/2: the single anomalous step of the balanced profile.")


def demo_bracket_and_sandwich() -> None:
    banner("5.  The bracket 6/7 - 1/(15(v+1)) < rho^2_max(B_v) < 6/7 and the sandwich")
    print("    v  bitlen   balanced ceiling    uniform ceiling     lower guard ok  below 6/7")
    for v in (1, 2, 3, 4, 10, 29, 94, 200):
        bal = ceiling(balanced_profile(v))
        uni = dyadic_closed_form(2 * v + 2)
        guard = SIX_SEVENTHS - Fraction(1, 15 * (v + 1))
        print(f"  {v:4d}  {2*v+2:5d}   {float(bal):.15f}   {float(uni):.15f}   "
              f"{guard < bal!s:<5}          {bal < SIX_SEVENTHS if v >= 2 else 'EQUAL'}")
    print()
    print("  At v = 1 the balanced ceiling equals 6/7 exactly:",
          ceiling(balanced_profile(1)) == SIX_SEVENTHS)
    print("  Balanced approaches 6/7 from BELOW at rate ~ 0.0263/v;")
    for v in (10, 50, 200, 1000):
        d = SIX_SEVENTHS - ceiling(balanced_profile(v))
        print(f"     v = {v:5d}:  6/7 - rho^2_max = {float(d):.3e},  v * deficit = {float(v*d):.5f}")
    print("  Uniform approaches 6/7 from ABOVE at rate 4^-b (exponentially fast).")


def demo_phase_boundary() -> None:
    banner("6.  The half-weight phase boundary: sign(rho^2_max - 6/7) flips at 2w = b")
    print("      v |      r=v-1        r=v          r=v+1 (half)     r=v+2        r=v+3")
    for v in (3, 5, 10, 20, 40):
        row = []
        for r in (v - 1, v, v + 1, v + 2, v + 3):
            c = ceiling(hockey_stick_vr(v, r))
            mark = "+" if c > SIX_SEVENTHS else ("=" if c == SIX_SEVENTHS else "-")
            row.append(f"{float(c):.6f}{mark}")
        print(f"  {v:7d} | " + "   ".join(row))
    print()
    print("  '-' means below 6/7 (weight >= half), '+' above (weight < half).")
    print("  Sharpness: weight 2 on 5 bits has profile [4,3,2,1] and ceiling",
          ceiling(hockey_stick_profile(5, 2)), "> 6/7")
    print("  Quantitative sparse gap, r = v+2:  rho^2_max - 6/7  vs  1/(7(2v+3))")
    for v in (1, 5, 20, 100):
        gap = ceiling(hockey_stick_vr(v, v + 2)) - SIX_SEVENTHS
        bound = Fraction(1, 7 * (2 * v + 3))
        print(f"     v = {v:4d}:  gap = {float(gap):.8f}   bound = {float(bound):.8f}   "
              f"bound < gap: {bound < gap}")


def demo_transfer() -> None:
    banner("7.  The transfer principle and the flat-split optimum")
    n = 12
    print(f"  two-block profiles of total n = {n}:")
    print("     split        sum m^3     rho^2_max")
    prev = None
    for a in range(n // 2, 0, -1):
        prof = [a, n - a]
        c = ceiling(prof)
        flag = "" if prev is None else ("  (strictly lower)" if c < prev else "  !! NOT LOWER")
        print(f"   [{a:2d}, {n-a:2d}]      {cube_sum(prof):7d}     {float(c):.6f}{flag}")
        prev = c
    print()
    print("  A single transfer [a+1, b] -> [a, b+1] with a+1 <= b raises the cube sum by")
    print("  3(b^2 - a^2) + 3(b - a) > 0 and therefore strictly lowers the ceiling.")
    print("  Transfer inside a longer profile, [5, 7, 3, 1] -> [4, 8, 3, 1]:")
    before, after = [5, 7, 3, 1], [4, 8, 3, 1]
    print(f"     {before} : {float(ceiling(before)):.6f}    "
          f"{after} : {float(ceiling(after)):.6f}   lower: {ceiling(after) < ceiling(before)}")


def demo_radix() -> None:
    banner("8.  The radix law: universal constant 3q / (q^2 + q + 1)")
    print("    q   constant        decimal      ceiling at b=6 (exact = closed form)")
    for q in (2, 3, 4, 5, 10):
        const = Fraction(3 * q, q * q + q + 1)
        prof = radix_profile(q, 6)
        exact = ceiling(prof)
        print(f"  {q:3d}   {str(const):>8}   {float(const):.6f}     {float(exact):.9f}   "
              f"{exact == radix_closed_form(q, 6)}")
    print()
    print("  The constant is STRICTLY DECREASING in the alphabet size:")
    print("     q = 2 -> 6/7 = 0.857143,  q = 3 -> 9/13 = 0.692308,  q = 4 -> 12/21 = 0.571429")
    print("  Hence the acceptance band [0.55, 0.85] is binary-specific: for q >= 3, b >= 2")
    for q in (3, 4, 5):
        c = ceiling(radix_profile(q, 2))
        print(f"     q = {q}, b = 2:  rho^2_max = {float(c):.6f} <= 0.7 < 0.85^2 = 0.7225 : "
              f"{c <= Fraction(7, 10)}")


def demo_deployment() -> None:
    banner("9.  The 60-bit deployment reading against both ceilings")
    rho = Fraction(669, 1000)
    ci = (Fraction(634, 1000), Fraction(705, 1000))
    band = (Fraction(55, 100), Fraction(85, 100))
    advantage = Fraction(151, 1000)
    count_reading = rho - advantage

    bal = ceiling(balanced_profile(29))            # bitlen 60, weight 30
    uni = dyadic_closed_form(60)                   # uniform 60-bit draws
    imb = ceiling(hockey_stick_profile(60, 33))    # 55% ones: weight fraction 0.55
    popcount = ceiling([comb(60, k) for k in range(61)])

    print(f"  recorded rho          = {float(rho):.3f}   CI [{float(ci[0]):.3f}, {float(ci[1]):.3f}]")
    print(f"  recorded rho^2        = {float(rho ** 2):.6f}")
    print(f"  balanced ceiling      = {float(bal):.15f}   (< 6/7)")
    print(f"  uniform ceiling       = {float(uni):.15f}   (> 6/7)")
    print(f"  6/7                   = {float(SIX_SEVENTHS):.15f}")
    print(f"  weight-33 ceiling     = {float(imb):.15f}   (55% ones, still > 0.73)")
    print(f"  popcount ceiling      = {float(popcount):.15f}   (uniform draws)")
    print()
    print(f"  whole band admissible under balanced law: {band[1] ** 2 < bal}")
    print(f"  whole band admissible under uniform law : {band[1] ** 2 < uni}")
    print(f"  whole band admissible at 55% ones       : {band[1] ** 2 < imb}")
    print(f"  saturation of the dial: {float(rho ** 2 / bal) * 100:.1f}% of the ceiling used")
    print()
    print("  popcount audit:")
    print(f"    uniform draws  : popcount ceiling {float(popcount):.6f} > dial ceiling "
          f"{float(uni):.6f}  -> more headroom, yet reads only {float(count_reading):.3f}")
    one_block = [comb(60, 30)]
    print(f"    fixed weight   : popcount is CONSTANT, profile [C(60,30)] = {one_block}, "
          f"ceiling {float(ceiling(one_block)):.1f}")
    print("      (a one-block profile has ceiling exactly 0 -- the baseline is informationless)")
    print(f"    dial on the same balanced population keeps ceiling {float(bal):.6f}")


def main() -> None:
    demo_functional()
    demo_dyadic()
    demo_hockey_stick()
    demo_catalan()
    demo_bracket_and_sandwich()
    demo_phase_boundary()
    demo_transfer()
    demo_radix()
    demo_deployment()
    print()
    print("All exact-rational checks completed.")


if __name__ == "__main__":
    main()
