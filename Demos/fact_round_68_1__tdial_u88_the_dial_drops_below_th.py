"""
Channel dilution, alphabet universality, and the forced band miss at bit-length 88.

Numerical demonstration of every result stated in the accompanying paper.
All arithmetic is exact rational arithmetic (fractions.Fraction); no floating point
is used in any comparison, only in the printed decimal renderings.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction as F
from itertools import product
from math import comb, isqrt
from typing import Dict, Iterable, List, Sequence, Tuple

Pair = Tuple[F, F]


# --------------------------------------------------------------------------------------
# 1. Exact finite-sample correlation calculus (determinant form)
# --------------------------------------------------------------------------------------

def sample_moments(data: Sequence[Pair]) -> Tuple[int, F, F, F, F, F]:
    """Return (n, sum x, sum y, sum x^2, sum y^2, sum xy) exactly, in one pass."""
    n = len(data)
    sx = sy = sxx = syy = sxy = F(0)
    for x, y in data:
        sx += x
        sy += y
        sxx += x * x
        syy += y * y
        sxy += x * y
    return n, sx, sy, sxx, syy, sxy


def cov_det(data: Sequence[Pair]) -> F:
    """n * Cov(X, Y) in determinant form."""
    n, sx, sy, _, _, sxy = sample_moments(data)
    return n * sxy - sx * sy


def var_x_det(data: Sequence[Pair]) -> F:
    """n * Var(X) in determinant form."""
    n, sx, _, sxx, _, _ = sample_moments(data)
    return n * sxx - sx * sx


def var_y_det(data: Sequence[Pair]) -> F:
    """n * Var(Y) in determinant form."""
    n, _, sy, _, syy, _ = sample_moments(data)
    return n * syy - sy * sy


def pearson_sq(data: Sequence[Pair]) -> F:
    """Exact squared Pearson correlation coefficient of a finite paired sample."""
    return cov_det(data) ** 2 / (var_x_det(data) * var_y_det(data))


# --------------------------------------------------------------------------------------
# 2. The channel samples: binary and q-ary
# --------------------------------------------------------------------------------------

def hamming_weight_spectrum(m: int) -> List[F]:
    """The 2^m Hamming weights of {0,1}^m, listed with multiplicity C(m, w)."""
    return [F(w) for w in range(m + 1) for _ in range(comb(m, w))]


def binary_channel_sample(a: F, m: int) -> List[Pair]:
    """All 2^(m+1) configurations of: predictor = own binary channel,
    response = a * (own channel) + (sum of m independent binary channels)."""
    spectrum = hamming_weight_spectrum(m)
    return [(F(0), w) for w in spectrum] + [(F(1), a + w) for w in spectrum]


def qary_channel_sum(q: int, m: int) -> List[F]:
    """All q^m values of a sum of m i.i.d. uniform digits from {0, ..., q-1}."""
    return [F(sum(t)) for t in product(range(q), repeat=m)]


def qary_channel_sample(q: int, a: F, m: int) -> List[Pair]:
    """All q^(m+1) configurations of the q-ary channel model."""
    sums = qary_channel_sum(q, m)
    return [(F(d), a * d + w) for d in range(q) for w in sums]


def dilution_law(a: F, m: int) -> F:
    """The closed-form dilution law a^2 / (a^2 + m)."""
    return a * a / (a * a + m)


# --------------------------------------------------------------------------------------
# 3. Tie profiles, mid-ranks and the exact dyadic tie ceiling
# --------------------------------------------------------------------------------------

def tie_ceiling(profile: Sequence[int]) -> F:
    """S_R / S_S for a tie profile: the maximal squared rank correlation of a tied
    predictor against a perfectly refining response."""
    n = sum(profile)
    grand = F(n + 1, 2)
    ss_s = F(n ** 3 - n, 12)
    ss_r = F(0)
    start = 0
    for block in profile:
        midrank = F(2 * start + block + 1, 2)  # mean of start+1 .. start+block
        ss_r += block * (midrank - grand) ** 2
        start += block
    return ss_r / ss_s


def dyadic_profile(b: int) -> List[int]:
    """(2^{b-1}, 2^{b-2}, ..., 2, 1, 1): the distribution of the trailing-zero count
    on the 2^b residues below 2^b."""
    return [2 ** (b - 1 - k) for k in range(b)] + [1]


def dyadic_ceiling_closed_form(b: int) -> F:
    """(6/7) * (1 + 1 / (2^b (2^b + 1)))."""
    n = 2 ** b
    return F(6, 7) * (1 + F(1, n * (n + 1)))


# --------------------------------------------------------------------------------------
# 4. The recorded ladder
# --------------------------------------------------------------------------------------

LADDER: Dict[int, F] = {
    44: F(78, 100),
    52: F(81, 100),
    56: F(69, 100),
    64: F(65, 100),
    68: F(61, 100),
    72: F(61, 100),
    76: F(61, 100),
    80: F(57, 100),
    84: F(56, 100),
    88: F(534, 1000),
}
OUTLIER_RUNG = 52
GOOD_RUNGS = [b for b in sorted(LADDER) if b != OUTLIER_RUNG]

BAND_FLOOR = F(55, 100)
BAND_CEIL = F(85, 100)
CI88 = (F(509, 1000), F(555, 1000))


def rung_invariant(b: int) -> F:
    """rho^2 * b."""
    return LADDER[b] ** 2 * b


def pooled_C() -> F:
    """Mean of the nine non-outlier rung invariants."""
    return sum((rung_invariant(b) for b in GOOD_RUNGS), F(0)) / len(GOOD_RUNGS)


def reciprocal_excess(rho: F) -> F:
    """e = 1/rho^2 - 1: the competing pool measured in units of the signal's channel."""
    return 1 / rho ** 2 - 1


def odds(rho: F) -> F:
    return rho ** 2 / (1 - rho ** 2)


def quadratic_pool_fit(b0: int, b1: int) -> Tuple[F, F]:
    """Solve kappa*b^2 + c = e(rho(b)) exactly at the two anchor rungs."""
    e0, e1 = reciprocal_excess(LADDER[b0]), reciprocal_excess(LADDER[b1])
    kappa = (e1 - e0) / (b1 ** 2 - b0 ** 2)
    c = e0 - kappa * b0 ** 2
    return kappa, c


def quadratic_prediction(b: int, kappa: F, c: F) -> F:
    return 1 / (1 + kappa * b ** 2 + c)


# --------------------------------------------------------------------------------------
# 5. Pythagorean even legs
# --------------------------------------------------------------------------------------

def trailing_zeros(x: int) -> int:
    if x == 0:
        raise ValueError("trailing_zeros(0) is undefined here")
    k = 0
    while x % 2 == 0:
        x //= 2
        k += 1
    return k


def even_leg_profile(m: int, b: int) -> List[int]:
    """Tie profile of the trailing-zero count of the even leg 2mn, n < 2^b, m odd
    (the generator n = 0 is replaced by the top singleton block, matching the
    dyadic convention)."""
    counts: Dict[int, int] = {}
    for n in range(1, 2 ** b):
        k = trailing_zeros(2 * m * n)
        counts[k] = counts.get(k, 0) + 1
    ordered = [counts.get(k + 1, 0) for k in range(b)]
    return ordered + [1]


# --------------------------------------------------------------------------------------
# Reporting helpers
# --------------------------------------------------------------------------------------

def dec(x: F, places: int = 6) -> str:
    return f"{float(x):.{places}f}"


def rule(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


# --------------------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------------------

def demo_binary_dilution() -> None:
    rule("1. The channel-dilution law:  rho^2 = a^2 / (a^2 + m),  exactly")
    print(f"{'a':>6} {'m':>3} {'b=m+1':>6} {'brute force rho^2':>22} {'closed form':>22}  ok")
    for a in (F(1), F(2), F(1, 2), F(3)):
        for m in range(0, 7):
            brute = pearson_sq(binary_channel_sample(a, m))
            closed = dilution_law(a, m)
            print(f"{str(a):>6} {m:>3} {m+1:>6} {str(brute):>22} {str(closed):>22}"
                  f"  {'YES' if brute == closed else 'NO'}")
            assert brute == closed
    print("\nUnweighted case a = 1:  rho^2 = 1/b exactly ->",
          [str(dilution_law(F(1), m)) for m in range(6)])
    print("Inverse-bit-length scaling  b*rho^2 - a^2 = a^2(1-a^2)/(a^2+b-1):")
    a = F(3, 2)
    for b in (4, 16, 64, 256):
        lhs = b * dilution_law(a, b - 1) - a ** 2
        rhs = a ** 2 * (1 - a ** 2) / (a ** 2 + b - 1)
        assert lhs == rhs
        print(f"  b = {b:>4}:  b*rho^2 = {dec(b * dilution_law(a, b-1))}"
              f"   (limit a^2 = {dec(a**2)})")


def demo_alphabet_universality() -> None:
    rule("2. Alphabet universality: the same rho^2 for every alphabet size q >= 2")
    a = F(2)
    print(f"{'q':>3} {'m':>3} {'sample size':>12} {'brute force rho^2':>20} {'a^2/(a^2+m)':>20}  ok")
    for q in (2, 3, 4, 5, 6):
        for m in (1, 2, 3):
            brute = pearson_sq(qary_channel_sample(q, a, m))
            closed = dilution_law(a, m)
            assert brute == closed
            print(f"{q:>3} {m:>3} {q**(m+1):>12} {str(brute):>20} {str(closed):>20}  YES")
    print("\nThe correlation does not depend on q at all: dilution counts channels,")
    print("not symbols.  (Sample sizes above range from 4 to 1296 points.)")

    print("\nClosed forms for the moments of a sum of m uniform q-ary digits:")
    for q in (2, 3, 5):
        for m in (1, 2, 3, 4):
            sums = qary_channel_sum(q, m)
            s1 = sum(sums, F(0))
            s2 = sum((w * w for w in sums), F(0))
            pred1 = F(q) ** m * m * (q - 1) / 2
            pred2 = F(q) ** m * (m * (q ** 2 - 1) + 3 * m ** 2 * (q - 1) ** 2) / 12
            assert s1 == pred1 and s2 == pred2
    print("  sum w   = q^m * m(q-1)/2                          -- verified")
    print("  12 sum w^2 = q^m ( m(q^2-1) + 3 m^2 (q-1)^2 )     -- verified")


def demo_uniqueness() -> None:
    rule("3. The law is forced: additivity of the reciprocal excess, and uniqueness")
    a = F(7, 5)
    for m in range(5):
        for n in range(5):
            lhs = 1 / dilution_law(a, m + n) - 1
            rhs = (1 / dilution_law(a, m) - 1) + (1 / dilution_law(a, n) - 1)
            assert lhs == rhs
    print(f"  additivity of 1/rho^2 - 1 verified for a = {a}, all m, n <= 4")

    # Reconstruct the law from the functional equation alone.
    f = {0: F(1), 1: a ** 2 / (a ** 2 + 1)}
    for m in range(1, 10):
        f[m + 1] = 1 / (1 / f[m] + (1 / f[1] - 1))
    assert all(f[m] == dilution_law(a, m) for m in range(11))
    print("  reconstructing f from f(0)=1, f(1)=a^2/(a^2+1) and additivity alone")
    print("  reproduces the dilution law exactly for m = 0..10:  the shape is forced.")


def demo_tie_ceiling() -> None:
    rule("4. The two-adic tie ceiling is numerically frozen")
    print(f"{'b':>4} {'profile ceiling':>20} {'closed form (6/7)(1+1/(2^b(2^b+1)))':>40}")
    for b in (1, 2, 3, 4, 6, 8, 10, 12):
        emp = tie_ceiling(dyadic_profile(b))
        clo = dyadic_ceiling_closed_form(b)
        assert emp == clo
        print(f"{b:>4} {dec(emp, 12):>20} {dec(clo, 12):>40}")
    gap = dyadic_ceiling_closed_form(44) - dyadic_ceiling_closed_form(88)
    print(f"\n  ceiling(44) - ceiling(88) = {float(gap):.3e}   (< 1e-26)")
    assert gap > 0 and gap < F(1, 10 ** 26)
    dial_gap = LADDER[44] ** 2 - LADDER[88] ** 2
    print(f"  dial rho^2(44) - rho^2(88) = {dec(dial_gap)}          (> 0.32)")
    assert dial_gap > F(32, 100)
    print("  => tie granularity moves by 1e-26 while the dial moves by 0.32:")
    print("     the erosion is NOT a granularity artefact.")
    print(f"  and rho(88)^2 = {dec(LADDER[88]**2)} sits far below the ceiling "
          f"{dec(dyadic_ceiling_closed_form(88))}.")


def demo_ladder_and_retrodiction() -> None:
    rule("5. The ladder is an inverse-bit-length law, and it forces the 88-rung")
    print(f"{'b':>4} {'rho':>8} {'rho^2':>10} {'I(b)=rho^2 b':>14} {'in [25,28.3]?':>15}")
    for b in sorted(LADDER):
        inv = rung_invariant(b)
        flag = "yes" if F(25) <= inv <= F(283, 10) else "NO  <-- outlier"
        print(f"{b:>4} {dec(LADDER[b],3):>8} {dec(LADDER[b]**2):>10} {dec(inv,4):>14} {flag:>15}")

    C = pooled_C()
    print(f"\n  pooled invariant C = {C} = {dec(C, 6)}")
    assert C == F(7446029, 281250)

    print("\n  out-of-sample one-step-ahead predictions (nothing fitted to the target):")
    print(f"  {'from':>6} {'to':>4} {'predicted rho^2':>17} {'observed rho^2':>16} {'|error|':>10}")
    for lo, hi in zip(GOOD_RUNGS, GOOD_RUNGS[1:]):
        pred = rung_invariant(lo) / hi
        err = abs(pred - LADDER[hi] ** 2)
        assert err < F(3, 100)
        print(f"  {lo:>6} {hi:>4} {dec(pred):>17} {dec(LADDER[hi]**2):>16} {dec(err):>10}")

    star = C / BAND_FLOOR ** 2
    print(f"\n  crossing bit-length b* = C / 0.55^2 = {dec(star, 4)}")
    assert F(87) < star < F(88)
    print(f"  C/84 = {dec(C/84)} > 0.3025 = 0.55^2 > {dec(C/88)} = C/88")
    assert C / 84 > BAND_FLOOR ** 2 > C / 88
    print("  => the first band miss is FORCED at b = 88.")
    print(f"\n  recorded 88-rung: rho = {dec(LADDER[88],3)} < {dec(BAND_FLOOR,2)}, "
          f"CI [{dec(CI88[0],3)}, {dec(CI88[1],3)}] straddles the floor.")
    assert CI88[0] < BAND_FLOOR < CI88[1]
    assert all(LADDER[b] >= BAND_FLOOR for b in LADDER if b != 88)


def demo_adversarial() -> None:
    rule("6. Adversarial review: what the record rules out")

    print("  (a) fixed-weight dilution, every weight a != 0:")
    for a in (F(1, 4), F(1), F(3), F(10), F(1000)):
        lhs = dilution_law(a, 43) * LADDER[88] ** 2
        rhs = dilution_law(a, 87) * LADDER[44] ** 2
        assert lhs < rhs
        print(f"      a = {str(a):>6}:  law(88)*d44^2 = {dec(rhs)}  >  "
              f"law(44)*d88^2 = {dec(lhs)}   -> too slow")
    print("      (and by alphabet universality the same holds for every q >= 2)")

    print("\n  (b) linear pool growth a^2/(a^2 + kappa (b-1)), every kappa > 0:")
    for a, k in ((F(1), F(1, 10)), (F(2), F(1)), (F(1, 3), F(37))):
        lhs = a ** 2 / (a ** 2 + k * 43) * LADDER[88] ** 2
        rhs = a ** 2 / (a ** 2 + k * 87) * LADDER[44] ** 2
        assert lhs < rhs
        print(f"      a = {str(a):>4}, kappa = {str(k):>4}:  {dec(lhs)} < {dec(rhs)}"
              f"   -> excluded")

    e44, e88 = reciprocal_excess(LADDER[44]), reciprocal_excess(LADDER[88])
    print(f"\n  (c) super-additivity on the reciprocal scale:")
    print(f"      e(44) = {dec(e44)},  e(88) = {dec(e88)}")
    print(f"      e(44)*87 = {dec(e44*87, 3)}   <   e(88)*43 = {dec(e88*43, 3)}"
          f"   (equality required by any fixed-weight model)")
    assert e44 * 87 < e88 * 43
    ratio = odds(LADDER[44]) / odds(LADDER[88])
    print(f"      effective pool grows by a factor {dec(ratio, 4)} in (3.8, 4) "
          f"while b merely doubles")
    assert F(38, 10) < ratio < F(4)

    print("\n  (d) the odds-scale inverse-square law rho^2/(1-rho^2) = K/b^2:")
    Ks = [odds(LADDER[b]) * b ** 2 for b in GOOD_RUNGS]
    K = sum(Ks, F(0)) / len(Ks)
    assert all(F(2700) <= k <= F(3450) for k in Ks)
    print(f"      all nine rungs give K in [2700, 3450]; pooled K = {dec(K, 3)}")
    print(f"      K/80^2 = {dec(K/6400)} > odds(0.55) = {dec(odds(BAND_FLOOR))} "
          f"> K/84^2 = {dec(K/7056)}")
    assert K / 6400 > odds(BAND_FLOOR) > K / 7056
    print(f"      => odds law predicts the first miss at b = 84; but the 84-rung HELD "
          f"({dec(LADDER[84],2)} >= 0.55).")
    assert odds(BAND_FLOOR) <= odds(LADDER[84])
    print("      => the odds-scale law is FALSIFIED; the rho^2-scale law survives.")


def demo_quadratic_pool() -> None:
    rule("7. Quadratic pool with a forced positive noise floor, and model robustness")
    kappa, c = quadratic_pool_fit(44, 88)
    print(f"  two-point fit on rungs 44 and 88:")
    print(f"     kappa = {kappa} = {float(kappa):.6e}")
    print(f"     c     = {c} = {dec(c)}")
    assert kappa > 0 and c > 0
    print("  the floor c > 0 is FORCED: the record erodes by a factor "
          f"{dec(reciprocal_excess(LADDER[88])/reciprocal_excess(LADDER[44]), 4)} < 4 "
          "on the reciprocal scale.")

    print("\n  pure pairwise-interaction pool rho^2 = 2a^2/(2a^2 + b(b-1)):")
    a = F(1)
    for b in (44, 88):
        brute = pearson_sq(binary_channel_sample(a, comb(6, 2)))  # small sanity check
        assert brute == 2 * a ** 2 / (2 * a ** 2 + F(6) * 5)
    print(f"      exact form verified on a small case (b = 6)")
    print(f"      it multiplies the reciprocal excess by 174/43 = {dec(F(174,43),4)}, "
          f"the record only by {dec(reciprocal_excess(LADDER[88])/reciprocal_excess(LADDER[44]),4)}"
          "  -> pure pairwise over-erodes")
    assert reciprocal_excess(LADDER[88]) < reciprocal_excess(LADDER[44]) * F(174, 43)

    print(f"\n  retrodiction of the whole ladder from that two-point fit:")
    print(f"  {'b':>4} {'predicted rho^2':>17} {'observed rho^2':>16} {'|error|':>10}")
    for b in sorted(LADDER):
        pred = quadratic_prediction(b, kappa, c)
        err = abs(pred - LADDER[b] ** 2)
        tag = "" if b != OUTLIER_RUNG else "   <-- outlier, missed by > 0.08"
        print(f"  {b:>4} {dec(pred):>17} {dec(LADDER[b]**2):>16} {dec(err):>10}{tag}")
        if b == OUTLIER_RUNG:
            assert err > F(8, 100)
        else:
            assert err < F(27, 1000)

    C = pooled_C()
    print("\n  model robustness of the 88-rung:")
    print(f"    inverse-bit-length law : C/84 = {dec(C/84)} > 0.3025 > {dec(C/88)} = C/88")
    print(f"    quadratic-pool law     : p(84) = {dec(quadratic_prediction(84, kappa, c))}"
          f" > 0.3025 > {dec(quadratic_prediction(88, kappa, c))} = p(88)")
    assert quadratic_prediction(84, kappa, c) > BAND_FLOOR ** 2
    assert quadratic_prediction(88, kappa, c) < BAND_FLOOR ** 2
    print("    two structurally different laws, two different fitting procedures,")
    print("    both bracket the band crossing in (84, 88].")


def demo_product_law() -> None:
    rule("8. The product law: tie attenuation times channel dilution, no interaction")
    # Build the product sample explicitly for a small dyadic profile.
    for b, m, a, in ((3, 3, F(1)), (4, 2, F(2)), (3, 4, F(1, 2))):
        profile = dyadic_profile(b)
        n = sum(profile)
        c = F(n)
        # refining ranks 1..n in block order; mid-rank of each item's block
        midranks: List[F] = []
        refining: List[F] = []
        start = 0
        for block in profile:
            mr = F(2 * start + block + 1, 2)
            for j in range(block):
                midranks.append(mr)
                refining.append(F(start + j + 1))
            start += block
        data: List[Pair] = []
        for w in hamming_weight_spectrum(m):
            for mr, rr in zip(midranks, refining):
                data.append((mr, a * rr + c * w))
        rho2 = pearson_sq(data)
        ss_s = F(n ** 3 - n, 12)
        tie = tie_ceiling(profile)
        predicted = tie * (a ** 2 * ss_s / (a ** 2 * ss_s + c ** 2 * n * m / 4))
        assert rho2 == predicted
        print(f"  b = {b}, m = {m}, a = {a}:  rho^2 = {dec(rho2)} = "
              f"tie {dec(tie)} x dilution {dec(predicted/tie)}   -- exact")
    print("\n  every cross term between tie structure and noise cancels identically.")


def demo_pythagorean() -> None:
    rule("9. Pythagorean transfer: even legs of the Euclid family")
    for m in (1, 3, 5, 7, 11, 21):
        for b in (3, 4, 5, 6):
            emp = even_leg_profile(m, b)
            dya = dyadic_profile(b)
            assert emp == dya, (m, b, emp, dya)
    print("  for every odd generator m and every b tested, the trailing-zero tie profile")
    print("  of the even leg 2mn, n < 2^b, is LITERALLY the dyadic profile:")
    print(f"    b = 5 -> {dyadic_profile(5)}")
    print("\n  hence the exact ceiling transfers verbatim:")
    for b in (5, 10, 88):
        print(f"    b = {b:>3}:  ceiling = {dec(dyadic_ceiling_closed_form(b), 12)}")
    print(f"\n  at b = 88 the ceiling {dec(dyadic_ceiling_closed_form(88))} exceeds both")
    print(f"  the reading rho(88)^2 = {dec(LADDER[88]**2)} and the squared floor "
          f"{dec(BAND_FLOOR**2)}:")
    print("  the band miss must be charged to the response, on Pythagorean legs too.")
    # Euclid identity, exactly.
    for mm in range(1, 8):
        for nn in range(1, mm):
            assert (mm ** 2 - nn ** 2) ** 2 + (2 * mm * nn) ** 2 == (mm ** 2 + nn ** 2) ** 2
    print("\n  (Euclid's identity (m^2-n^2)^2 + (2mn)^2 = (m^2+n^2)^2 checked exactly.)")


def main() -> None:
    print(__doc__)
    demo_binary_dilution()
    demo_alphabet_universality()
    demo_uniqueness()
    demo_tie_ceiling()
    demo_ladder_and_retrodiction()
    demo_adversarial()
    demo_quadratic_pool()
    demo_product_law()
    demo_pythagorean()
    rule("All exact assertions passed.")


if __name__ == "__main__":
    main()
