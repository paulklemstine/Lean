#!/usr/bin/env python3
"""
Deterministic localization from summary statistics
==================================================

Numerical demonstration of every quantitative claim in the accompanying paper.

The setting: fourteen independent populations produce a quality score at a
control setting u = 3.5, summarised as

    mean = 0.6282,  standard error = 0.0041,  95% interval = [0.6204, 0.6363],
    sample sd = 0.0155,  populations below the 0.60 floor = 0/14,

together with a paired column of drops  D_i = sp_i(2.5) - sp_i(3.5),

    mean drop = 0.1057,  interval = [0.0999, 0.1112],  positive drops = 14/14.

Everything below is exact rational arithmetic (fractions.Fraction) wherever a
claim is a strict inequality with a thin margin; floats are used only for
display.  No external dependencies.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction as F
from itertools import combinations
from math import comb, isqrt, sqrt
from typing import Iterable, List, Sequence, Tuple

# --------------------------------------------------------------------------- #
# Recorded constants
# --------------------------------------------------------------------------- #

N: int = 14
MEAN: F = F(6282, 10000)          # recorded centre of sp(3.5)
SD: F = F(155, 10000)             # recorded sample standard deviation
FLOOR: F = F(6, 10)               # contractual floor
BUDGET: F = (N - 1) * SD**2       # total squared deviation = 0.00312325

DROP_MEAN: F = F(1057, 10000)     # recorded mean paired drop
DROP_SD: F = F(110, 10000)        # paired sd implied by the paired interval
DROP_BUDGET: F = (N - 1) * DROP_SD**2

CI_LO: F = F(6204, 10000)
CI_HI: F = F(6363, 10000)
DROP_CI_LO: F = F(999, 10000)
DROP_CI_HI: F = F(1112, 10000)


def rule(title: str) -> None:
    print("\n" + "=" * 78)
    print(title)
    print("=" * 78)


# --------------------------------------------------------------------------- #
# 1. The dispersion budget and the finite one-sided bound
# --------------------------------------------------------------------------- #

def total_squared_deviation(x: Sequence[F], centre: F) -> F:
    """SS(x; m) = sum_i (x_i - m)^2, exactly."""
    return sum((xi - centre) ** 2 for xi in x)


def below_count(x: Sequence[F], level: F) -> int:
    """#{i : x_i <= level}."""
    return sum(1 for xi in x if xi <= level)


def one_sided_bound_holds(x: Sequence[F], centre: F, level: F) -> bool:
    """Verify  N_le(x; c) * (m - c)^2 <= SS(x; m)  for c < m."""
    assert level < centre
    return below_count(x, level) * (centre - level) ** 2 <= total_squared_deviation(x, centre)


def max_breach_count(n: int, centre: F, sd: F, level: F) -> int:
    """Algorithm A: greatest sub-level count compatible with (n, centre, sd)."""
    budget = (n - 1) * sd**2
    margin_sq = (centre - level) ** 2
    return min(n, int(budget / margin_sq))


def demo_cap() -> None:
    rule("1.  THE COUNTING CAP:  at most three populations can be below the floor")
    margin = MEAN - FLOOR
    print(f"  dispersion budget  B = 13 * {float(SD)}^2      = {float(BUDGET):.8f}")
    print(f"  floor margin       m - c                    = {float(margin):.4f}")
    print(f"  squared margin     (m - c)^2                = {float(margin**2):.8f}")
    print(f"  ratio              B / (m - c)^2            = {float(BUDGET / margin**2):.6f}")
    cap = max_breach_count(N, MEAN, SD, FLOOR)
    print(f"  => cap  = floor(ratio)                      = {cap}")
    assert cap == 3


# --------------------------------------------------------------------------- #
# 2. Sharpness: the counting witness
# --------------------------------------------------------------------------- #

def counting_witness() -> List[F]:
    """Three populations at 0.5999, eleven at 69951/110000; mean exactly 0.6282."""
    return [F(5999, 10000)] * 3 + [F(69951, 110000)] * 11


def demo_witness() -> None:
    rule("2.  SHARPNESS:  a compliant population with three sub-floor members")
    w = counting_witness()
    ss = total_squared_deviation(w, MEAN)
    sample_mean = sum(w) / N
    sd_w = sqrt(float(ss) / (N - 1))
    print(f"  witness values        3 x 0.5999,  11 x {float(F(69951,110000)):.8f}")
    print(f"  sample mean           {sample_mean}  (== recorded: {sample_mean == MEAN})")
    print(f"  dispersion  SS        {ss} = {float(ss):.8f}")
    print(f"  budget      B         {float(BUDGET):.8f}   -> inside budget: {ss < BUDGET}")
    print(f"  implied sample sd     {sd_w:.6f}   (recorded {float(SD)})")
    print(f"  sub-floor count       {below_count(w, FLOOR)}")
    print("  => the published (mean, sd) pair is consistent with 0, 1, 2 or 3")
    print("     sub-floor populations, and with no other count.  The observed")
    print("     0/14 is therefore strictly extra information.")
    assert sample_mean == MEAN and ss < BUDGET and below_count(w, FLOOR) == 3
    assert one_sided_bound_holds(w, MEAN, FLOOR)


# --------------------------------------------------------------------------- #
# 3. Depth: no deep outlier, and the ladder
# --------------------------------------------------------------------------- #

def depth_ladder(n: int, centre: F, sd: F, depths: Iterable[F]) -> List[Tuple[F, int]]:
    """Algorithm B (counting half): (depth, max #populations at that depth)."""
    budget = (n - 1) * sd**2
    return [(d, min(n, int(budget / d**2))) for d in depths]


def depth_witness() -> List[F]:
    """One population 0.04 below the mean, thirteen at 41033/65000."""
    return [F(5882, 10000)] + [F(41033, 65000)] * 13


def demo_depth() -> None:
    rule("3.  DEPTH:  no deep outlier, and the depth-count ladder")
    max_depth = sqrt(float(BUDGET))
    print(f"  maximal single-population depth  sqrt(B)    = {max_depth:.7f}")
    print(f"  => every population exceeds  {float(MEAN) - max_depth:.6f}  > 0.5723")
    # exact check that 0.5723 is a valid uniform lower bound
    assert F(559, 10000) ** 2 > BUDGET, "0.0559^2 must exceed the budget"
    print(f"  exact check: 0.0559^2 = {float(F(559,10000)**2):.8f} > B = {float(BUDGET):.8f}")
    print("  A reading near 0.55 (the earlier reported deep outlier) is therefore")
    print("  arithmetically impossible in this population.\n")

    print("  depth      max #populations at that depth")
    for d, k in depth_ladder(N, MEAN, SD, [F(282, 10000), F(4, 100), F(559, 10000)]):
        print(f"   {float(d):.4f}     {k}")

    v = depth_witness()
    ss = total_squared_deviation(v, MEAN)
    print(f"\n  middle rung attained by:  1 x 0.5882,  13 x {float(F(41033,65000)):.8f}")
    print(f"    mean                 {sum(v)/N}  (== recorded: {sum(v)/N == MEAN})")
    print(f"    dispersion           {float(ss):.8f} < B = {float(BUDGET):.8f}")
    print(f"    #at depth >= 0.04    {below_count(v, MEAN - F(4,100))}")
    print(f"    that member is       {float(v[0]):.4f}, i.e. {float(FLOOR - v[0]):.4f} below the floor")
    assert sum(v) / N == MEAN and ss < BUDGET
    assert below_count(v, MEAN - F(4, 100)) == 1


# --------------------------------------------------------------------------- #
# 4. The paired column: exact randomization (sign) test
# --------------------------------------------------------------------------- #

def signed_sum(d: Sequence[float], signs: Sequence[int]) -> float:
    """T_d(s) = sum_i s_i d_i  with s_i in {+1, -1}."""
    return sum(si * di for si, di in zip(signs, d))


def exact_sign_test_pvalue(d: Sequence[float]) -> Tuple[int, int, float]:
    """Brute-force enumeration of all 2^n sign patterns.

    Returns (#patterns at least as extreme, 2^n, p-value).
    """
    n = len(d)
    observed = sum(d)
    extreme = 0
    for mask in range(1 << n):
        signs = [1 if (mask >> i) & 1 else -1 for i in range(n)]
        if signed_sum(d, signs) >= observed - 1e-12:
            extreme += 1
    return extreme, 1 << n, extreme / (1 << n)


def randomization_tail_exact(d: Sequence[float], tolerance: float) -> int:
    """#subsets S with sum_{i in S} d_i <= t  (== # sign patterns within 2t)."""
    n = len(d)
    count = 0
    for size in range(n + 1):
        for S in combinations(range(n), size):
            if sum(d[i] for i in S) <= tolerance:
                count += 1
    return count


def binomial_tail_bound(n: int, c: float, tolerance: float) -> Tuple[int, int]:
    """Algorithm C (certified bound):  k = ceil(t/c) - 1, bound = sum_{j<=k} C(n,j)."""
    k = 0
    while c * (k + 1) <= tolerance:
        k += 1
    return k, sum(comb(n, j) for j in range(k + 1))


def synthetic_drops() -> List[float]:
    """A drop column consistent with the recorded paired summary.

    Mean exactly 0.1057, all values strictly inside the uniformity band, and
    sample sd close to (but under) the recorded 0.0110.
    """
    base = [
        0.0930, 0.0975, 0.1002, 0.1018, 0.1031, 0.1044, 0.1052,
        0.1062, 0.1071, 0.1083, 0.1096, 0.1112, 0.1148, 0.1174,
    ]
    shift = 0.1057 - sum(base) / len(base)
    return [b + shift for b in base]


def demo_sign_test() -> None:
    rule("4.  THE PAIRED COLUMN:  exact randomization inference")
    d = synthetic_drops()
    m = sum(d) / len(d)
    ss = sum((x - m) ** 2 for x in d)
    print(f"  synthetic drop column (mean {m:.6f}, sample sd {sqrt(ss/13):.6f}):")
    print("   ", "  ".join(f"{x:.4f}" for x in d))
    print(f"  all strictly positive: {all(x > 0 for x in d)}")

    extreme, total, p = exact_sign_test_pvalue(d)
    print(f"\n  sign patterns enumerated       {total}")
    print(f"  at least as extreme as observed {extreme}")
    print(f"  exact one-sided p-value         {p:.8f}  =  1/{total}")
    assert extreme == 1 and abs(p - 1 / 16384) < 1e-12

    print("\n  Robustness: hand an adversary a haircut of 0.26 (18% of the total)")
    total_mass = sum(d)
    exact_tail = randomization_tail_exact(d, 0.13)
    k, bound = binomial_tail_bound(14, 0.066, 0.13)
    print(f"    total drop mass                {total_mass:.4f}")
    print(f"    exact tail count (t = 0.13)    {exact_tail}")
    print(f"    certified bound (c = 0.066)    k = {k},  sum_j<={k} C(14,j) = {bound}")
    print(f"    robustified p-value            <= {bound}/16384 = {bound/16384:.6f} < 1e-3")
    assert exact_tail <= bound <= 15

    gap = 2 * 0.066
    print(f"\n  Spectral gap: every other pattern falls at least 2c = {gap:.3f} short,")
    print(f"    i.e. {100*gap/total_mass:.2f}% of the total mass -- an isolated maximum.")
    # verify directly against the enumeration
    observed = sum(d)
    runner_up = max(
        signed_sum(d, [1 if (mask >> i) & 1 else -1 for i in range(14)])
        for mask in range(1 << 14)
        if mask != (1 << 14) - 1
    )
    print(f"    observed statistic {observed:.6f},  runner-up {runner_up:.6f},"
          f"  actual gap {observed - runner_up:.6f} >= {gap:.3f}")
    assert observed - runner_up >= gap - 1e-12


# --------------------------------------------------------------------------- #
# 5. The uniformity band and the forced correlation
# --------------------------------------------------------------------------- #

def uniformity_band(centre: F, budget: F) -> Tuple[float, float]:
    half = sqrt(float(budget))
    return float(centre) - half, float(centre) + half


def forced_correlation_bound(sd_col: F, sd_paired: F) -> float:
    """1 - s_paired^2 / (2 s_col^2), valid when both columns share sd_col."""
    return 1.0 - float(sd_paired**2) / (2.0 * float(sd_col**2))


def demo_uniformity() -> None:
    rule("5.  UNIFORMITY BAND AND THE CORRELATION IT FORCES")
    lo, hi = uniformity_band(DROP_MEAN, DROP_BUDGET)
    print(f"  paired budget  13 * {float(DROP_SD)}^2         = {float(DROP_BUDGET):.7f}")
    print(f"  max single-population deviation        = {sqrt(float(DROP_BUDGET)):.7f}")
    print(f"  => every drop lies strictly in         ({lo:.6f}, {hi:.6f})")
    print(f"     stated band                         (0.066, 0.1454)")
    assert lo > 0.066 and hi < 0.1454
    print(f"  guaranteed fraction of the mean drop   {0.066/float(DROP_MEAN):.4f} (> 62%)")
    print("  No population is insensitive; none is hypersensitive either.")

    # verify the synthetic column obeys the band
    d = synthetic_drops()
    print(f"  synthetic column inside the band:      {all(0.066 < x < 0.1454 for x in d)}")

    r = forced_correlation_bound(SD, DROP_SD)
    print(f"\n  paired dispersion identity: SS(a-b) = SS(a) + SS(b) - 2 SP(a,b)")
    print(f"  forced correlation  1 - s_d^2/(2 s^2) = {r:.6f}  >= 0.74")
    assert r >= 0.74

    # numerical illustration of the identity on two synthetic columns
    b_col = [0.6282 + x for x in (-0.020, -0.014, -0.009, -0.005, -0.002,
                                  0.000, 0.001, 0.003, 0.005, 0.007,
                                  0.009, 0.011, 0.007, 0.007)]
    a_col = [bi + di for bi, di in zip(b_col, synthetic_drops())]
    ma, mb = sum(a_col) / 14, sum(b_col) / 14
    ss_a = sum((x - ma) ** 2 for x in a_col)
    ss_b = sum((x - mb) ** 2 for x in b_col)
    diff = [ai - bi for ai, bi in zip(a_col, b_col)]
    md = sum(diff) / 14
    ss_d = sum((x - md) ** 2 for x in diff)
    sp = sum((x - ma) * (y - mb) for x, y in zip(a_col, b_col))
    print(f"\n  identity check on two synthetic columns:")
    print(f"    SS(a) = {ss_a:.8f},  SS(b) = {ss_b:.8f},  SP(a,b) = {sp:.8f}")
    print(f"    SS(a-b)               = {ss_d:.8f}")
    print(f"    SS(a)+SS(b)-2 SP(a,b) = {ss_a + ss_b - 2*sp:.8f}")
    print(f"    Pearson correlation   = {sp/sqrt(ss_a*ss_b):.6f}")
    assert abs(ss_d - (ss_a + ss_b - 2 * sp)) < 1e-12


# --------------------------------------------------------------------------- #
# 6. The affine crossing forecast and the standard-error audit
# --------------------------------------------------------------------------- #

def crossing(centre: float, loss: float, floor: float = 0.60, anchor: float = 3.5) -> float:
    """Unique u* with  centre - loss*(u - anchor) = floor."""
    return anchor + (centre - floor) / loss


def forecast_window() -> Tuple[float, float]:
    """Sweep the whole interval box; the extremes are attained at the corners."""
    lo = crossing(float(CI_LO), float(DROP_CI_HI))
    hi = crossing(float(CI_HI), float(DROP_CI_LO))
    return lo, hi


def demo_forecast() -> None:
    rule("6.  WHERE THE FLOOR IS CROSSED, AND A STANDARD-ERROR AUDIT")
    point = crossing(float(MEAN), float(DROP_MEAN))
    print(f"  point forecast   u* = 3.5 + 0.0282/0.1057 = {point:.6f}")
    lo, hi = forecast_window()
    print(f"  interval box     centre in [{float(CI_LO)}, {float(CI_HI)}],"
          f"  loss in [{float(DROP_CI_LO)}, {float(DROP_CI_HI)}]")
    print(f"  forecast window  ({lo:.6f}, {hi:.6f})  strictly inside (3.68, 3.87)")
    assert 3.68 < lo and hi < 3.87

    # exhaustive grid sweep of the box as an independent check
    worst_lo, worst_hi = 1e9, -1e9
    steps = 60
    for i in range(steps + 1):
        m = float(CI_LO) + (float(CI_HI) - float(CI_LO)) * i / steps
        for j in range(steps + 1):
            b = float(DROP_CI_LO) + (float(DROP_CI_HI) - float(DROP_CI_LO)) * j / steps
            u = crossing(m, b)
            worst_lo, worst_hi = min(worst_lo, u), max(worst_hi, u)
    print(f"  grid sweep ({(steps+1)**2} points) gives ({worst_lo:.6f}, {worst_hi:.6f})")
    assert 3.68 < worst_lo and worst_hi < 3.87

    print(f"\n  sign flip inside the tested range:")
    for u in (3.5, 3.766, 3.767, 4.0):
        val = float(MEAN) - float(DROP_MEAN) * (u - 3.5)
        print(f"    u = {u:<6}  model = {val:.6f}   {'ABOVE' if val > 0.6 else 'BELOW'} floor")

    se = float(SD) / sqrt(14)
    print(f"\n  standard-error audit:  0.0155/sqrt(14) = {se:.8f}")
    print(f"    published value                      = 0.0041")
    print(f"    absolute discrepancy                 = {abs(se - 0.0041):.8f} < 5e-5")
    assert abs(se - 0.0041) < 5e-5
    half_width = (float(CI_HI) - float(CI_LO)) / 2
    print(f"    interval half-width                  = {half_width:.5f}")
    print(f"    half-width / exact se                = {half_width/se:.4f} standard errors")
    print(f"    half-width / published 0.0041        = {half_width/0.0041:.4f} standard errors")
    print("    => an ordinary two-sided 95% interval, not an inflated one.")


# --------------------------------------------------------------------------- #
# 7. What the summary line decides
# --------------------------------------------------------------------------- #

def demo_summary_table() -> None:
    rule("7.  WHAT THE SUMMARY LINE DECIDES")
    rows = [
        ("four or more sub-floor populations", "REFUTED"),
        ("zero versus three sub-floor populations", "UNDECIDED"),
        ("any population below 0.5723", "REFUTED"),
        ("two or more populations at depth >= 0.04", "REFUTED"),
        ("one population at depth 0.04", "UNDECIDED"),
        ("any drop <= 0.066 or >= 0.1454", "REFUTED"),
        ("correlation between settings below 0.74", "REFUTED"),
        ("interval width is a resampling artefact", "REFUTED"),
    ]
    width = max(len(r[0]) for r in rows)
    for claim, verdict in rows:
        print(f"  {claim.ljust(width)}   {verdict}")
    print("\n  Hypothesis H1 (centre below the floor) dies by arithmetic.")
    print("  Hypothesis H2 (wide tail) survives the summary and dies only at")
    print("  the observation level -- which is exactly why the raw count matters.")


def main() -> None:
    print(__doc__)
    demo_cap()
    demo_witness()
    demo_depth()
    demo_sign_test()
    demo_uniformity()
    demo_forecast()
    demo_summary_table()
    print("\nAll assertions passed.\n")


if __name__ == "__main__":
    main()
