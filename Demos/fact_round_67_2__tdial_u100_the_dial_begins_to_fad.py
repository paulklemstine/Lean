#!/usr/bin/env python3
"""
Numerical demonstration of the sampler-independent tie ceiling of the
trailing-zero statistic, and of the effective-base drift.

Everything is exact rational arithmetic (``fractions.Fraction``) unless a
float is explicitly requested for display.

The mathematics demonstrated here:

  * the halving recursion  B(n) = floor(n/2) :: B(ceil(n/2))  producing the
    2-adic tie profile of {0, ..., n-1};
  * the tie ceiling  rho^2_max(L) = 1 - (sum m_i^3 - n) / (n^3 - n);
  * the ceiling defect  E(n) = sum m_i^3 - n^3/7, its doubling invariance
    E(2m) = E(m), its odd step E(2a+1) = E(a+1) - (9a^2+3a)/7, the exact
    value E(2^b) = 6/7 and the sharp envelope -3/7 n^2 <= E(n) <= 6/7;
  * the universal range law  rho^2_max(n) = 6/7 + (6n/7 - E(n))/(n^3 - n);
  * dyadic domination  m_i <= x/2^{i+1} + C  and the cube-sum bound
    sum m_i^3 <= x^3/7 + C x^2 + 3 C^2 x + C^3 K;
  * offset windows [A, A+n) and their slack-2 domination;
  * the base-p fixed point (p-1)^3/(p^3-1) and ceiling 3p/(p^2+p+1);
  * the effective-base inversion 7 -> 9 and the floor-crossing forecast;
  * straddle geometry: resolution horizon and exit bound.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from typing import Dict, List, Tuple

# --------------------------------------------------------------------------
# Recorded measurements (exact rationals)
# --------------------------------------------------------------------------

SEED_A_100 = Fraction(546, 1000)
SEED_B_100 = Fraction(528, 1000)
SEED_C_100 = Fraction(549, 1000)
POOLED_100 = Fraction(544, 1000)
CI_LOW_100 = Fraction(498, 1000)
CI_HIGH_100 = Fraction(588, 1000)
HALF_WIDTH_100 = Fraction(46, 1000)
ADVANTAGE_100 = Fraction(98, 1000)
BAND_FLOOR = Fraction(55, 100)
RUNG_STEP = Fraction(30, 1000)
POOLED_76 = Fraction(608, 1000)
READ_96 = Fraction(573, 1000)
CI_HIGH_104 = Fraction(545, 1000)


# --------------------------------------------------------------------------
# 1. Tie profiles and the ceiling
# --------------------------------------------------------------------------

def range_blocks(n: int) -> List[int]:
    """2-adic tie profile of {0, ..., n-1} via the halving recursion."""
    if n <= 0:
        return []
    if n == 1:
        return [1]
    return [n // 2] + range_blocks((n + 1) // 2)


def brute_force_blocks(n: int) -> List[int]:
    """Directly count valuations in {0, ..., n-1} (reference implementation)."""
    counts: Dict[int, int] = {}
    for x in range(n):
        if x == 0:
            k = max(0, n - 1).bit_length()  # v_2(0) is infinite; place it last
        else:
            k = (x & -x).bit_length() - 1
        counts[k] = counts.get(k, 0) + 1
    if not counts:
        return []
    top = max(counts)
    return [counts.get(k, 0) for k in range(top + 1)]


def cube_sum(blocks: List[int]) -> Fraction:
    """Sigma_3(L) = sum of cubes of the block sizes."""
    return Fraction(sum(m ** 3 for m in blocks))


def tie_ceiling(blocks: List[int]) -> Fraction:
    """Squared Spearman tie ceiling  1 - (Sigma_3 - n)/(n^3 - n)."""
    n = sum(blocks)
    if n < 2:
        raise ValueError("need n >= 2")
    return 1 - (cube_sum(blocks) - n) / Fraction(n ** 3 - n)


def defect(n: int) -> Fraction:
    """Ceiling defect  E(n) = Sigma_3(B(n)) - n^3/7."""
    return cube_sum(range_blocks(n)) - Fraction(n ** 3, 7)


def range_law(n: int) -> Fraction:
    """Universal range law  6/7 + (6n/7 - E(n))/(n^3 - n)."""
    return Fraction(6, 7) + (Fraction(6 * n, 7) - defect(n)) / Fraction(n ** 3 - n)


# --------------------------------------------------------------------------
# 2. Dyadic domination
# --------------------------------------------------------------------------

def is_dyadically_dominated(blocks: List[int], x: Fraction, C: Fraction) -> bool:
    """Check  m_i <= x / 2^{i+1} + C  for every index of the profile."""
    return all(Fraction(m) <= x / Fraction(2 ** (i + 1)) + C
               for i, m in enumerate(blocks))


def domination_cube_bound(x: Fraction, C: Fraction, K: int) -> Fraction:
    """x^3/7 + C x^2 + 3 C^2 x + C^3 K."""
    return x ** 3 / 7 + C * x ** 2 + 3 * C ** 2 * x + C ** 3 * K


def dominated_ceiling_lower(n: int, C: Fraction, K: int) -> Fraction:
    """6/7 - (C n^2 + 3 C^2 n + C^3 K)/(n^3 - n)."""
    err = C * n ** 2 + 3 * C ** 2 * n + C ** 3 * K
    return Fraction(6, 7) - err / Fraction(n ** 3 - n)


# --------------------------------------------------------------------------
# 3. Offset windows
# --------------------------------------------------------------------------

def window_blocks(A: int, n: int, K: int) -> List[int]:
    """Valuation blocks of the window [A, A+n), truncated to K blocks."""
    counts = [0] * K
    for x in range(A, A + n):
        k = (x & -x).bit_length() - 1
        if k < K:
            counts[k] += 1
    return counts


# --------------------------------------------------------------------------
# 4. Base-p theory
# --------------------------------------------------------------------------

def padic_cube(p: int) -> Fraction:
    """Geometric fixed point  kappa(p) = (p-1)^3 / (p^3 - 1)."""
    return Fraction((p - 1) ** 3, p ** 3 - 1)


def padic_limit(p: int) -> Fraction:
    """Base-p asymptotic ceiling  lambda(p) = 3p / (p^2 + p + 1)."""
    return Fraction(3 * p, p * p + p + 1)


def effective_base(lo: Fraction, hi: Fraction, pmax: int = 40) -> List[int]:
    """All integer bases p >= 2 whose ceiling lands inside [lo, hi]."""
    return [p for p in range(2, pmax + 1) if lo <= padic_limit(p) <= hi]


def crossing_base(target: Fraction) -> float:
    """Real base t with 3t/(t^2+t+1) = target (larger root, t >= 1)."""
    a = float(target)
    # a t^2 + (a - 3) t + a = 0
    disc = (a - 3) ** 2 - 4 * a * a
    return ((3 - a) + disc ** 0.5) / (2 * a)


def drift_bitlen(t: float) -> float:
    """Calibration 76 |-> base 7, 100 |-> base 9."""
    return 76.0 + 12.0 * (t - 7.0)


# --------------------------------------------------------------------------
# 5. Straddle geometry
# --------------------------------------------------------------------------

def straddles(c: Fraction, w: Fraction, B: Fraction) -> bool:
    return c - w < B < c + w


def resolves(c: Fraction, w: Fraction, B: Fraction) -> bool:
    return (c + w < B) or (B < c - w)


def resolution_horizon(w: Fraction, d: Fraction) -> Fraction:
    """Maximum rung separation of two straddling readings: strictly < 2w/d."""
    return 2 * w / d


def exit_rung(c: Fraction, w: Fraction, B: Fraction, d: Fraction) -> int:
    """Least k with c + w - k d < B (whole interval below the threshold)."""
    k = 0
    while c + w - k * d >= B:
        k += 1
    return k


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def sec(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_profiles() -> None:
    sec("1. The halving recursion reproduces the true 2-adic tie profile")
    for n in [1, 2, 3, 5, 8, 11, 16, 17, 33, 100]:
        rec = range_blocks(n)
        print(f"  n = {n:4d}   B(n) = {str(rec):28s} sum = {sum(rec)}")
    print("\n  Cross-check against brute-force valuation counting (n <= 512):")
    bad = [n for n in range(1, 513) if sum(range_blocks(n)) != n]
    print(f"    sum(B(n)) == n for all 1 <= n <= 512 : {not bad}")
    ok = all(range_blocks(n) == brute_force_blocks(n) for n in range(2, 300))
    print(f"    B(n) equals the directly counted profile for 2 <= n < 300 : {ok}")


def demo_defect() -> None:
    sec("2. The ceiling defect E(n): doubling invariance and the odd step")
    print("  E(2m) = E(m)   (E depends only on the odd part of n)")
    for m in range(1, 9):
        print(f"    m = {m}:  E(m) = {str(defect(m)):>12s}   "
              f"E(2m) = {str(defect(2 * m)):>12s}   equal = {defect(2*m) == defect(m)}")

    print("\n  E(2a+1) = E(a+1) - (9a^2 + 3a)/7")
    for a in range(1, 9):
        lhs = defect(2 * a + 1)
        rhs = defect(a + 1) - Fraction(9 * a * a + 3 * a, 7)
        print(f"    a = {a}:  {str(lhs):>14s} = {str(rhs):>14s}   {lhs == rhs}")

    print("\n  E(2^b) = 6/7 exactly, for every b:")
    print("   ", [str(defect(2 ** b)) for b in range(1, 9)])

    print("\n  Envelope  -3/7 n^2 <= E(n) <= 6/7  (checked for 1 <= n <= 4000):")
    viol = [n for n in range(1, 4001)
            if not (Fraction(-3, 7) * n * n <= defect(n) <= Fraction(6, 7))]
    print(f"    violations: {viol}")

    print("\n  Powers of two are the UNIQUE maximisers E(n) = 6/7 (n <= 4000):")
    maxi = [n for n in range(1, 4001) if defect(n) == Fraction(6, 7)]
    print(f"    {maxi[:12]} ...   all powers of two: "
          f"{all(m & (m - 1) == 0 for m in maxi)}")

    print("\n  Extremal family n_j = 2^{j+1}+1 drives E(n)/n^2 -> -3/7:")
    for j in range(1, 13):
        n = 2 ** (j + 1) + 1
        print(f"    n = {n:7d}   E(n)/n^2 = {float(defect(n)) / n**2: .8f}"
              f"   (target {-3/7: .8f})")


def demo_range_law() -> None:
    sec("3. The universal range law and its bracketing")
    print("  rho^2_max(n) = 6/7 + (6n/7 - E(n))/(n^3 - n)\n")
    print(f"  {'n':>8s} {'ceiling':>14s} {'excess over 6/7':>20s} {'1/(n-1) bound':>16s}")
    for n in [2, 3, 4, 8, 9, 16, 17, 33, 100, 128, 1000, 1024, 2049]:
        law = range_law(n)
        direct = tie_ceiling(range_blocks(n))
        assert law == direct, "range law disagrees with direct computation"
        exc = law - Fraction(6, 7)
        print(f"  {n:8d} {float(law):14.10f} {float(exc):20.3e} "
              f"{float(Fraction(1, n-1)):16.3e}")

    print("\n  Consistency with the dyadic law (6/7)(1 + 1/(2^b(2^b+1))):")
    for b in range(1, 9):
        n = 2 ** b
        cls = Fraction(6, 7) * (1 + Fraction(1, n * (n + 1)))
        print(f"    b = {b}:  law = {str(range_law(n)):>28s}   matches = "
              f"{range_law(n) == cls}")

    print("\n  Dyadic / odd dichotomy at bit-length 100:")
    n_even, n_odd = 2 ** 100, 2 ** 100 - 1
    e_even = range_law(n_even) - Fraction(6, 7)
    e_odd = range_law(n_odd) - Fraction(6, 7)
    print(f"    excess at n = 2^100      : {float(e_even):.6e}")
    print(f"    excess at n = 2^100 - 1  : {float(e_odd):.6e}")
    print(f"    ratio                    : {float(e_odd / e_even):.6e}"
          f"   (> 10^28 : {e_odd > 10 ** 28 * e_even})")
    print(f"    both are below 10^-29    : "
          f"{e_odd < Fraction(1, 10 ** 29) and e_even < Fraction(1, 10 ** 29)}")
    print(f"    recorded 4-bit erosion step for comparison: {float(RUNG_STEP)}")


def demo_domination() -> None:
    sec("4. Dyadic domination: the sampler-free bound")
    print("  Range profiles are dominated with slack C = 1:")
    ok = all(is_dyadically_dominated(range_blocks(n), Fraction(n), Fraction(1))
             for n in range(1, 2000))
    print(f"    DD(B(n); n, 1) for 1 <= n < 2000 : {ok}")

    print("\n  Cube-sum bound  Sigma_3 <= x^3/7 + C x^2 + 3 C^2 x + C^3 K:")
    print(f"  {'n':>7s} {'Sigma_3':>14s} {'bound (C=1)':>16s} {'slackness':>14s}")
    for n in [10, 37, 100, 257, 1000, 4095]:
        blocks = range_blocks(n)
        s3 = cube_sum(blocks)
        bd = domination_cube_bound(Fraction(n), Fraction(1), len(blocks))
        print(f"  {n:7d} {float(s3):14.2f} {float(bd):16.2f} {float(bd - s3):14.2f}")

    print("\n  Abstract ceiling bound vs the exact ceiling:")
    print(f"  {'n':>7s} {'exact':>14s} {'DD lower (C=1)':>18s}")
    for n in [100, 1000, 10 ** 4, 10 ** 5]:
        blocks = range_blocks(n)
        print(f"  {n:7d} {float(range_law(n)):14.10f} "
              f"{float(dominated_ceiling_lower(n, Fraction(1), len(blocks))):18.10f}")

    print("\n  Bit-length-100 payload: every dominated sampler with slack C <= 4")
    n = 2 ** 100
    for C in [1, 2, 3, 4]:
        lo = dominated_ceiling_lower(n, Fraction(C), n.bit_length())
        print(f"    C = {C}:  ceiling >= {float(lo):.12f}   > 0.85 : {lo > Fraction(85,100)}")
    print(f"    recorded pooled reading squared: {float(POOLED_100 ** 2):.6f}")
    print(f"    optimistic CI endpoint squared : {float(CI_HIGH_100 ** 2):.6f}")


def demo_windows() -> None:
    sec("5. Offset windows: separation forces domination with slack 2")
    print("  A window [A, A+n) contains at most n/2^{k+1} + 2 draws of valuation k.\n")
    for (A, n) in [(1, 64), (1000, 500), (2 ** 20, 4096), (12345, 777)]:
        K = (A + n).bit_length() + 1
        blocks = window_blocks(A, n, K)
        dom = is_dyadically_dominated(blocks, Fraction(n), Fraction(2))
        print(f"    [A, A+n) = [{A}, {A+n}) : blocks = {blocks[:8]}... "
              f"sum = {sum(blocks)}  dominated(C=2) = {dom}")
        if sum(blocks) >= 2:
            print(f"        exact ceiling {float(tie_ceiling(blocks)):.10f}   "
                  f"vs 6/7 = {6/7:.10f}")

    print("\n  Canonical bit-length-100 window [2^99, 2^100), n = 2^99, K = 100:")
    n = 2 ** 99
    lo = Fraction(6, 7) - (2 * Fraction(n) ** 2 + 12 * n + 8 * 100) / Fraction(n ** 3 - n)
    print(f"    ceiling >= {float(lo):.14f}")
    print(f"    pooled^2 = {float(POOLED_100 ** 2):.6f}  ->  strictly below: "
          f"{POOLED_100 ** 2 < lo}")


def demo_base_p() -> None:
    sec("6. Base-p theory and the effective-base drift")
    print(f"  {'p':>3s} {'kappa(p)':>12s} {'lambda(p)':>12s} {'1-kappa = lambda':>18s}")
    for p in range(2, 13):
        k, l = padic_cube(p), padic_limit(p)
        print(f"  {p:3d} {str(k):>12s} {str(l):>12s} {str(1 - k == l):>18s}")

    lo76, hi76 = Fraction(600, 1000) ** 2, Fraction(615, 1000) ** 2
    lo100, hi100 = SEED_B_100 ** 2, SEED_C_100 ** 2
    print(f"\n  bit-length  76 window [{float(lo76):.6f}, {float(hi76):.6f}] "
          f"-> effective bases {effective_base(lo76, hi76)}")
    print(f"  bit-length 100 window [{float(lo100):.6f}, {float(hi100):.6f}] "
          f"-> effective bases {effective_base(lo100, hi100)}")

    gap = padic_limit(7) - padic_limit(9)
    drop = POOLED_76 ** 2 - POOLED_100 ** 2
    print(f"\n  ceiling gap  lambda(7) - lambda(9) = {gap} = {float(gap):.6f}")
    print(f"  measured drop 0.608^2 - 0.544^2      = {float(drop):.6f}")
    print(f"  |difference| = {float(abs(gap - drop)):.6f}   <= 0.003 : "
          f"{abs(gap - drop) <= Fraction(3, 1000)}")

    print("\n  True 2-adic ceiling stays far above every seed:")
    for name, v in [("seed A", SEED_A_100), ("seed B", SEED_B_100), ("seed C", SEED_C_100)]:
        print(f"    {name}: rho^2 = {float(v**2):.6f}  vs lambda(2) = {float(padic_limit(2)):.6f}")


def demo_forecast() -> None:
    sec("7. The floor-crossing forecast")
    target = BAND_FLOOR ** 2
    t = crossing_base(target)
    print(f"  band floor rho = {float(BAND_FLOOR)},  rho^2 = {target} = {float(target):.6f}")
    print(f"  unique real base with 3t/(t^2+t+1) = rho^2 :  t* = {t:.6f}")
    print(f"    bracket 8.80 < t* < 8.81 : {8.80 < t < 8.81}")
    print(f"    strictly between integer bases 8 and 9 : {8 < t < 9}")
    b = drift_bitlen(t)
    print(f"  calibration beta(t) = 76 + 12(t - 7):  beta(7) = {drift_bitlen(7):.1f}, "
          f"beta(9) = {drift_bitlen(9):.1f}")
    print(f"  forecast first band miss at bit-length {b:.3f}")
    print(f"    inside the predicted bracket (97.6, 97.8) : {97.6 < b < 97.8}")
    print(f"    inside the observed window   (96, 100)    : {96 < b < 100}")
    print("    on a rung ladder of step 4 this says: last clean rung 96, first miss 100.")


def demo_straddle() -> None:
    sec("8. Straddle geometry: what the experiment can and cannot decide")
    print(f"  pooled = {float(POOLED_100)}, half-width = {float(HALF_WIDTH_100)}, "
          f"floor = {float(BAND_FLOOR)}")
    print(f"    straddles the floor : {straddles(POOLED_100, HALF_WIDTH_100, BAND_FLOOR)}")
    print(f"    resolves the floor  : {resolves(POOLED_100, HALF_WIDTH_100, BAND_FLOOR)}")

    h = resolution_horizon(HALF_WIDTH_100, RUNG_STEP)
    print(f"\n  resolution horizon 2w/d = {h} = {float(h):.4f} rungs")
    print(f"    -> at most 3 rungs = 12 bit-lengths of ambiguity")

    k = exit_rung(POOLED_100, HALF_WIDTH_100, BAND_FLOOR, RUNG_STEP)
    print(f"\n  exit bound from the bit-length-100 data alone: k = {k} rungs "
          f"-> bit-length {100 + 4 * k}")
    print(f"    recorded bit-length-104 interval top = {float(CI_HIGH_104)} "
          f"< floor : {CI_HIGH_104 < BAND_FLOOR}  (exit came one rung early)")

    print(f"\n  advantage of T over count = {float(ADVANTAGE_100)}  vs interval width "
          f"{float(2 * HALF_WIDTH_100)}")
    print(f"    which statistic is better -> RESOLVABLE : "
          f"{2 * HALF_WIDTH_100 < ADVANTAGE_100}")
    print(f"  four-bit erosion step     = {float(RUNG_STEP)}  vs interval width "
          f"{float(2 * HALF_WIDTH_100)}")
    print(f"    how fast it is fading     -> NOT resolvable : "
          f"{RUNG_STEP < 2 * HALF_WIDTH_100}")

    print("\n  The ambiguity window is exactly the two rungs 96 and 100:")
    for name, val in [("96", READ_96), ("100", POOLED_100)]:
        print(f"    bit-length {name:>3s}: straddles = "
              f"{straddles(val, HALF_WIDTH_100, BAND_FLOOR)}")
    print(f"    bit-length 104: entirely below = {CI_HIGH_104 < BAND_FLOOR}")


def main() -> None:
    print("Sampler-independent tie ceilings for the trailing-zero statistic")
    print("All arithmetic below is exact (rational) unless displayed as a float.")
    demo_profiles()
    demo_defect()
    demo_range_law()
    demo_domination()
    demo_windows()
    demo_base_p()
    demo_forecast()
    demo_straddle()
    print("\n" + "=" * 74)
    print("Conclusion: the tie ceiling is 6/7 + O(1/n) for every sampler considered;")
    print("at bit-length 100 its total spread is < 10^-29 while the reading squares")
    print("to 0.296.  The sampler cannot explain the band miss.")
    print("=" * 74)


if __name__ == "__main__":
    main()
