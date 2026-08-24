"""
The zero-fit dial: exact ceilings for rank correlation against a geometric tie spectrum.
=======================================================================================

This script is a self-contained numerical companion to the theory of *coarse response
ceilings* for the Spearman rank correlation between

    T = the number of trailing zero binary digits of a uniformly drawn integer
        of exact bit-length 48  (equivalently, the 2-adic valuation)

and an arbitrary downstream response.  Everything is computed in exact rational
arithmetic (``fractions.Fraction``) so that the printed numbers are the theorems,
not floating-point approximations of them.

Contents
--------
1.  Tie profiles: the dyadic (ratio-1/2) profile and the general ratio-1/q profile.
2.  The between-block sum of squares ``ssR`` and its two closed forms
        ssR_dyadic(b) = (n^3 - 1) / 14                       (n = 2^b)
        ssR_geom(q,b) = q (n^3 - 1) / (4 (q^2 + q + 1))      (n = q^b)
3.  The coarse (binary) response ceiling and the rate parabola
        rho^2_max(p) = (7/2) p (1 - p) n^3 / (n^3 - 1).
4.  Brute-force verification, on small profiles, that the ceiling is attained
    exactly by the top-filling response and by nothing better (an exhaustive
    search over all selections).
5.  The resolution ladder: bottom-blind versus tip-blind ceilings, and the
    asymmetry at exact bit-length 48.
6.  The geometric-ratio family: C(q) = q + 1 + 1/q is strictly increasing, so
    the dyadic regime is the hardest one.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from typing import Iterable, List, Sequence, Tuple

# --------------------------------------------------------------------------------------
# 1.  Tie profiles
# --------------------------------------------------------------------------------------


def dyadic_blocks(b: int) -> List[int]:
    """Tie profile of the trailing-zero statistic on {0, ..., 2^b - 1}.

    Block j (j = 0, ..., b-1) collects the integers with exactly j trailing zeros and
    has size 2^(b-1-j); the final singleton is {0}.  Blocks are listed in increasing
    order of T, so the *first* block is the largest (the odd numbers, half the sample).
    """
    return [2 ** (b - 1 - j) for j in range(b)] + [1]


def geom_blocks(q: int, b: int) -> List[int]:
    """Tie profile of the trailing-digit statistic in base q on {0, ..., q^b - 1}:
    blocks of sizes (q-1)q^(b-1), ..., (q-1)q, (q-1), then the singleton {0}."""
    return [(q - 1) * q ** (b - 1 - j) for j in range(b)] + [1]


def gmean(profile: Sequence[int]) -> Fraction:
    """Grand mean rank (n + 1) / 2 of a sample of size n = sum(profile)."""
    return Fraction(sum(profile) + 1, 2)


def midranks(profile: Sequence[int]) -> List[Fraction]:
    """Midrank of each tie block: r_j = C_j + (m_j + 1)/2 with C_j the prefix sum."""
    out: List[Fraction] = []
    c = 0
    for m in profile:
        out.append(Fraction(2 * c + m + 1, 2))
        c += m
    return out


def ssR(profile: Sequence[int]) -> Fraction:
    """Between-block sum of squares  sum_j m_j (r_j - mu)^2  of the midranks."""
    mu = gmean(profile)
    return sum((Fraction(m) * (r - mu) ** 2 for m, r in zip(profile, midranks(profile))),
               Fraction(0))


def ssR_total(n: int) -> Fraction:
    """Total (tie-free) sum of squares of the ranks 1..n:  (n^3 - n)/12."""
    return Fraction(n ** 3 - n, 12)


# --------------------------------------------------------------------------------------
# 2.  Closed forms
# --------------------------------------------------------------------------------------


def ssR_dyadic_closed(b: int) -> Fraction:
    """(n^3 - 1)/14 with n = 2^b."""
    n = 2 ** b
    return Fraction(n ** 3 - 1, 14)


def ssR_geom_closed(q: int, b: int) -> Fraction:
    """q (n^3 - 1) / (4 (q^2 + q + 1)) with n = q^b."""
    n = q ** b
    return Fraction(q * (n ** 3 - 1), 4 * (q * q + q + 1))


def geom_constant(q: int) -> Fraction:
    """C(q) = (q^2 + q + 1)/q = q + 1 + 1/q."""
    return Fraction(q * q + q + 1, q)


# --------------------------------------------------------------------------------------
# 3.  Ceilings
# --------------------------------------------------------------------------------------


def coarse_ceiling(profile: Sequence[int], K: int) -> Fraction:
    """rho^2_max = n K (n - K) / (4 ssR) for a two-valued response splitting at rank K."""
    n = sum(profile)
    return Fraction(n * K * (n - K), 1) / (4 * ssR(profile))


def rate_parabola(b: int, p: Fraction, q: int = 2) -> Fraction:
    """C(q) p (1 - p) n^3 / (n^3 - 1) with n = q^b;  C(2) = 7/2."""
    n = q ** b
    return geom_constant(q) * p * (1 - p) * Fraction(n ** 3, n ** 3 - 1)


def refining_ceiling(profile: Sequence[int]) -> Fraction:
    """Tie-attenuation ceiling for a response that *refines* the blocks: ssR / ssR_total."""
    return ssR(profile) / ssR_total(sum(profile))


# --------------------------------------------------------------------------------------
# 4.  Exhaustive check that the coarse ceiling is sharp
# --------------------------------------------------------------------------------------


def selection_spearman_sq(profile: Sequence[int], sel: Sequence[int]) -> Fraction:
    """Squared Spearman coefficient between the tied statistic with the given profile and
    the binary response that is 1 on sel[j] of the m_j members of block j.

    Cov = (n/2) * sum_j sel_j (r_j - mu),   Var = n * K * (n - K) / 4,  n = sum(profile).
    """
    n = sum(profile)
    K = sum(sel)
    if K == 0 or K == n:
        return Fraction(0)
    mu = gmean(profile)
    cov = Fraction(n, 2) * sum((Fraction(s) * (r - mu) for s, r in zip(sel, midranks(profile))),
                               Fraction(0))
    var = Fraction(n * K * (n - K), 4)
    return cov ** 2 / (ssR(profile) * var)


def all_selections(profile: Sequence[int], K: int) -> Iterable[Tuple[int, ...]]:
    """All ways of choosing K marked items block by block."""
    for sel in product(*[range(m + 1) for m in profile]):
        if sum(sel) == K:
            yield sel


def brute_force_sharpness(b: int, t: int) -> Tuple[Fraction, Fraction, Tuple[int, ...]]:
    """Maximise the squared Spearman coefficient over *every* binary response of the
    aligned rate 2^-t on the dyadic profile at bit-length b, and compare with the
    closed-form ceiling."""
    profile = dyadic_blocks(b)
    n = sum(profile)
    K = n // (2 ** t)  # mark K items, i.e. the aligned rate p = 2^-t
    best = Fraction(0)
    argbest: Tuple[int, ...] = ()
    for sel in all_selections(profile, K):
        v = selection_spearman_sq(profile, sel)
        if v > best:
            best, argbest = v, sel
    return best, rate_parabola(b, Fraction(1, 2 ** t)), argbest


# --------------------------------------------------------------------------------------
# 5.  Resolution ladder
# --------------------------------------------------------------------------------------


def bottom_merged_profile(b: int, t: int) -> List[int]:
    """One group for the whole low-T bulk of relative size 1 - 2^-t, full resolution above."""
    blocks = dyadic_blocks(b)
    return [sum(blocks[:t])] + blocks[t:]


def tip_merged_profile(b: int, t: int) -> List[int]:
    """Full resolution on the bottom t blocks, one group for the whole top 2^-t fraction."""
    blocks = dyadic_blocks(b)
    return blocks[:t] + [2 ** (b - t)]


def nested_ratio(b: int, coarse: Sequence[int]) -> Fraction:
    """The nested-ties law: rho^2 = ssR(coarse) / ssR(fine)."""
    fine = dyadic_blocks(b)
    mu = gmean(fine)  # both profiles have the same n, hence the same grand mean
    assert sum(coarse) == sum(fine) and mu == gmean(coarse)
    return ssR(coarse) / ssR(fine)


def bottom_blind_closed(b: int, t: int) -> Fraction:
    """((7/2)(2^t - 1) 2^t 8^(b-t) + 8^(b-t) - 1) / (8^b - 1)."""
    u, y = 2 ** t, 8 ** (b - t)
    return (Fraction(7, 2) * (u - 1) * u * y + y - 1) / Fraction(8 ** b - 1)


def tip_blind_closed(b: int, t: int) -> Fraction:
    """(8^b - 8^(b-t)) / (8^b - 1)."""
    return Fraction(8 ** b - 8 ** (b - t), 8 ** b - 1)


# --------------------------------------------------------------------------------------
# Report
# --------------------------------------------------------------------------------------


def f(x: Fraction, digits: int = 6) -> str:
    return f"{float(x):.{digits}f}"


def main() -> None:
    B = 47  # the tie profile of exact bit-length 48 lives on the low 47 bits
    SEEDS = [Fraction(7192, 10000), Fraction(7202, 10000), Fraction(7198, 10000)]

    print("=" * 86)
    print("THE ZERO-FIT DIAL AT EXACT BIT-LENGTH 48")
    print("=" * 86)
    print(f"recorded rank correlations : {[f(s, 4) for s in SEEDS]}")
    print(f"their squares              : {[f(s * s, 6) for s in SEEDS]}")
    print(f"recorded relation rate     : p = 1/8 = 0.125")
    print()

    print("-" * 86)
    print("1.  THE DYADIC SUM OF SQUARES   ssR = (n^3 - 1)/14")
    print("-" * 86)
    for b in range(1, 8):
        assert ssR(dyadic_blocks(b)) == ssR_dyadic_closed(b)
        print(f"  b = {b:2d}   n = {2**b:4d}   ssR = {str(ssR(dyadic_blocks(b))):>22}"
              f"   = (n^3-1)/14  OK")
    print("  closed form verified exactly for b = 1..7")
    print()

    print("-" * 86)
    print("2.  THE GEOMETRIC-RATIO SUM OF SQUARES   ssR = q(n^3 - 1)/(4(q^2+q+1))")
    print("-" * 86)
    for q in range(2, 7):
        for b in range(1, 5):
            assert ssR(geom_blocks(q, b)) == ssR_geom_closed(q, b)
        print(f"  q = {q}:  verified for b = 1..4;   C(q) = (q^2+q+1)/q = "
              f"{str(geom_constant(q)):>7} = {f(geom_constant(q), 4)}")
    print("  C(2) = 7/2 exactly recovers the dyadic constant of the recorded cell")
    print("  C is strictly increasing: the dyadic regime is the hardest of the family")
    print()

    print("-" * 86)
    print("3.  THE RATE PARABOLA   rho^2_max(p) = (7/2) p (1-p) n^3/(n^3-1)")
    print("-" * 86)
    print("      p        ceiling rho^2      ceiling rho    beats 0.7192?")
    for t in range(1, 7):
        p = Fraction(1, 2 ** t)
        c = rate_parabola(B, p)
        print(f"   1/{2**t:<4d}   {f(c):>12}      {float(c) ** 0.5:>10.6f}"
              f"       {'YES' if c > SEEDS[0] ** 2 else 'no'}")
    print()
    p8 = Fraction(1, 8)
    c8 = rate_parabola(B, p8)
    print(f"  at the recorded rate p = 1/8:")
    print(f"     rho^2 <= {c8} ")
    print(f"           =  (49/128)(1 + 1/(2^141 - 1))  ->  {f(c8)}")
    print(f"     rho   <= {float(c8) ** 0.5:.6f}   =  7/(8 sqrt 2)")
    print(f"     recorded rho = 0.7192  >  0.618718 : a two-valued response at 12.5% is EXCLUDED")
    print(f"  at rate p = 1/4 the parabola gives {f(rate_parabola(B, Fraction(1,4)))} > "
          f"{f(SEEDS[0]**2)}: a binary model needs at least DOUBLE the recorded rate")
    print()

    print("-" * 86)
    print("4.  SHARPNESS: exhaustive search over all binary responses (small b)")
    print("-" * 86)
    for (b, t) in [(3, 1), (4, 1), (4, 2), (5, 2)]:
        best, closed, arg = brute_force_sharpness(b, t)
        print(f"  b = {b}, rate 2^-{t}:  best over all selections = {str(best):>18}"
              f"   closed form = {str(closed):>18}   {'MATCH' if best == closed else 'MISMATCH'}")
        print(f"        maximiser (marked count per block, low T first) = {arg}")
    print("  the optimum is always the TOP-FILLING response: greedy alignment is optimal")
    print()

    print("-" * 86)
    print("5.  COARSE CAN BEAT FINE:  7/8  >  6/7")
    print("-" * 86)
    for b in [3, 5, 8, 12]:
        fine = refining_ceiling(dyadic_blocks(b))
        half = rate_parabola(b, Fraction(1, 2))
        print(f"  b = {b:2d}   refining ceiling = {f(fine)}   balanced binary ceiling = {f(half)}"
              f"   {'coarse wins' if half > fine else 'fine wins'}")
    print("  refining ceiling -> 6/7 = 0.857143 ;  balanced coarse ceiling -> 7/8 = 0.875000")
    print()

    print("-" * 86)
    print("6.  THE RESOLUTION LADDER  (nested-ties law  rho^2 = ssR(coarse)/ssR(fine))")
    print("-" * 86)
    for b in [6, 8]:
        for t in [1, 2, 3, 4]:
            lhs = nested_ratio(b, bottom_merged_profile(b, t))
            rhs = bottom_blind_closed(b, t)
            assert lhs == rhs, (b, t, lhs, rhs)
        print(f"  bottom-blind closed form verified exactly at b = {b}, t = 1..4")
    for b in [6, 8]:
        for t in [1, 2, 3, 4]:
            lhs = nested_ratio(b, tip_merged_profile(b, t))
            rhs = tip_blind_closed(b, t)
            assert lhs == rhs, (b, t, lhs, rhs)
        print(f"  tip-blind    closed form verified exactly at b = {b}, t = 1..4")
    print()
    print("   depth t   bottom-blind ceiling   tip-blind ceiling     verdict at bitlen 48")
    for t in range(1, 6):
        bb, tb = bottom_blind_closed(B, t), tip_blind_closed(B, t)
        verdict = ("bulk blindness EXCLUDED" if bb < SEEDS[0] ** 2 else "bulk blindness allowed")
        print(f"     t = {t}      {f(bb):>10}             {f(tb):>10}          {verdict}")
    print()
    print(f"  threshold: t = 2 gives {f(bottom_blind_closed(B,2))} > {f(SEEDS[0]**2)} (allowed)")
    print(f"             t = 3 gives {f(bottom_blind_closed(B,3))} < {f(SEEDS[0]**2)} (excluded)")
    print(f"  tip-blind stays above 7/8 = 0.875 for every depth: "
          f"min over t=1..40 is {f(min(tip_blind_closed(B, t) for t in range(1, 41)))}")
    print()
    print("  ASYMMETRY: merging the bottom 87.5% destroys the dial "
          f"({f(nested_ratio(B, bottom_merged_profile(B,3)))} < {f(SEEDS[0]**2)}),")
    print("             merging the top 50% does not "
          f"({f(nested_ratio(B, tip_merged_profile(B,1)))} > {f(SEEDS[0]**2)}).")
    print()

    print("-" * 86)
    print("7.  BIT-LENGTH INVARIANCE   |ceiling(p,b) - (7/2)p(1-p)|  <=  2/8^b")
    print("-" * 86)
    p = Fraction(1, 8)
    limit = Fraction(7, 2) * p * (1 - p)
    for b in [4, 8, 16, 32, 47]:
        dev = abs(rate_parabola(b, p) - limit)
        bound = Fraction(2, 8 ** b)
        print(f"  b = {b:3d}   deviation = {float(dev):.3e}   bound 2/8^b = {float(bound):.3e}"
              f"   {'OK' if dev <= bound else 'FAIL'}")
    print("  the dial's ceiling is flat in bit-length to exponential accuracy")
    print()

    print("-" * 86)
    print("8.  THE DYADIC REGIME IS THE HARDEST MEMBER OF THE GEOMETRIC FAMILY")
    print("-" * 86)
    p = Fraction(1, 8)
    print("     q    C(q) = q+1+1/q    ceiling at p = 1/8 (b -> infinity)")
    for q in range(2, 9):
        print(f"    {q:2d}      {f(geom_constant(q), 4):>8}            "
              f"{f(geom_constant(q) * p * (1 - p))}")
    print("  C is strictly increasing, so every exclusion proved in the dyadic (q = 2)")
    print("  regime is the strongest available across all geometric tie spectra.")
    print("=" * 86)


if __name__ == "__main__":
    main()
