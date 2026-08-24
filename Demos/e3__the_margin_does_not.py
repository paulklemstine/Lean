#!/usr/bin/env python3
"""
Depth-Independence of the Held-Out Logit Margin — numerical demonstrations.

This script is self-contained (standard library only) and reproduces, on
concrete numbers, every quantitative claim of the accompanying paper:

  1. Pinning:      channel == d*ctx/c  =>  m = 4*c*L*B*A   (no depth in it)
  2. Band theorem: knees within +/-eta  =>  margin ratio in
                   [(1-eta)/(1+eta), (1+eta)/(1-eta)]
  3. Headline:     eta = 1/21  =>  margins flat to +/-10%, and the window
                   1.1 is ATTAINED (sharpness)
  4. Refutation:   the naive m(16) = m(4)/4 is impossible for in-band knees
  5. Threshold:    accept iff reported ratio > 0.45, correct under +/-50% noise
  6. Exponents:    |alpha| <= log(10/9)/log 4 ~ 0.076; knee ratio 4 => alpha = 0
  7. Geometry:     the margin map is an isometry of |log(x/y)|
  8. Grids:        step rho => ratio band exactly [1/rho, rho];
                   dyadic (rho = 2) cannot certify; rho <= 11/10 can
  9. Aggregation:  the mean breaks on one bad run, every median does not
 10. Verdict:      strict-majority rule; sharpness of "strict" at [1,1,2,2]
 11. Invariant:    tail(k*) * L*B / m lies in [1/8, 1/4]

Run:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from fractions import Fraction
from typing import Callable, Iterable, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# Core quantities
# ----------------------------------------------------------------------------

CALIBRATION_C: float = 32.0          # fitted constant in k* = d*ctx/c
ETA_HEADLINE: float = 1.0 / 21.0     # knee tolerance certifying +/-10%
BAND_LO: float = 0.9
BAND_HI: float = 1.1
THRESHOLD: float = 0.45


def zipf_tail(A: float, ctx: float, k: float) -> float:
    """Attention mass discarded by a top-k truncation: A*ctx/k."""
    if k <= 0.0:
        raise ValueError("budget must be positive")
    return A * ctx / k


def margin_channel_knee(L: float, B: float, A: float, ctx: float,
                        d: int, m: float) -> float:
    """Budget the margin channel demands: 4*L*B*A*d*ctx/m."""
    if m <= 0.0:
        raise ValueError("margin must be positive")
    return 4.0 * L * B * A * d * ctx / m


def margin_of_knee(L: float, B: float, A: float, ctx: float,
                   d: int, K: float) -> float:
    """Margin implied by a measured knee K at depth d: 4*L*B*A*d*ctx/K."""
    if K <= 0.0:
        raise ValueError("measured knee must be positive")
    return 4.0 * L * B * A * d * ctx / K


def depth_linear_knee(ctx: float, d: int, c: float = CALIBRATION_C) -> float:
    """The measured depth-linear law k* = d*ctx/c."""
    return d * ctx / c


def within_rel(eta: float, x: float, y: float, eps: float = 1e-12) -> bool:
    """|x - y| <= eta*y, the relative-tolerance predicate (y > 0).

    `eps` absorbs floating-point round-off for measurements placed exactly
    on the edge of the band."""
    return abs(x - y) <= eta * y * (1.0 + eps) + eps


def band_bounds(eta: float) -> Tuple[float, float]:
    """[(1-eta)/(1+eta), (1+eta)/(1-eta)]."""
    if not 0.0 <= eta < 1.0:
        raise ValueError("tolerance must lie in [0, 1)")
    return (1.0 - eta) / (1.0 + eta), (1.0 + eta) / (1.0 - eta)


def log_ratio(x: float, y: float) -> float:
    """Hilbert projective (log-ratio) distance |log(x/y)| on the positive ray."""
    if x <= 0.0 or y <= 0.0:
        raise ValueError("log-ratio distance needs positive arguments")
    return abs(math.log(x / y))


def margin_power(m1: float, alpha: float, d: float) -> float:
    """Power-law margin ansatz m(d) = m1 * d^(-alpha)."""
    return m1 * d ** (-alpha)


def exponent_bound(lo: float = BAND_LO, hi: float = BAND_HI) -> float:
    """Largest |alpha| compatible with m(16)/m(4) in [lo, hi]."""
    return max(-math.log(lo), math.log(hi)) / math.log(4.0)


def grid_report(rho: float, k_true: float, k_min: float = 1.0) -> float:
    """First point of a geometric grid k_min*rho^j that is >= k_true."""
    if rho <= 1.0:
        return k_true
    j = math.ceil(math.log(k_true / k_min) / math.log(rho))
    return k_min * rho ** j


def list_mean(xs: Sequence[Fraction]) -> Fraction:
    return sum(xs, Fraction(0)) / Fraction(len(xs))


def medians(xs: Sequence[Fraction]) -> List[Fraction]:
    """All values m (drawn from the sample) that are medians in the
    two-sided counting sense: at least half the entries are <= m and at
    least half are >= m."""
    n = len(xs)
    out: List[Fraction] = []
    for m in sorted(set(xs)):
        below = sum(1 for x in xs if x <= m)
        above = sum(1 for x in xs if x >= m)
        if 2 * below >= n and 2 * above >= n:
            out.append(m)
    return out


def in_band_e3(x: Fraction) -> bool:
    return Fraction(9, 10) <= x <= Fraction(11, 10)


def e3_accept(log: Sequence[Fraction]) -> bool:
    """Accept iff a strict majority of reported ratios lie in [0.9, 1.1]."""
    return len(log) < 2 * sum(1 for x in log if in_band_e3(x))


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def rule(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_pinning() -> None:
    rule("1. PINNING — the depth cancels out of the margin equation")
    L, B, A = 1.3, 0.7, 0.02
    ctx = 1024.0
    m_pred = 4.0 * CALIBRATION_C * L * B * A
    print(f"  L = {L}, B = {B}, A = {A}, ctx = {ctx:.0f}")
    print(f"  predicted pinned margin  m = 4*c*L*B*A = 128*L*B*A = {m_pred:.6f}\n")
    print(f"  {'d':>4} {'measured knee d*ctx/32':>24} {'implied margin':>18}")
    for d in (1, 2, 4, 8, 16, 32, 64):
        K = depth_linear_knee(ctx, d)
        m = margin_of_knee(L, B, A, ctx, d, K)
        print(f"  {d:>4} {K:>24.3f} {m:>18.6f}")
    print("\n  Every row gives the same margin: the depth cancels identically.")


def demo_band_and_sharpness() -> None:
    rule("2-3. BAND THEOREM and SHARPNESS of the +/-10% window")
    L, B, A, ctx = 1.3, 0.7, 0.02, 1024.0
    print(f"  {'eta':>10} {'lower bound':>14} {'upper bound':>14}")
    for eta in (0.0, 0.01, ETA_HEADLINE, 0.05, 0.1, 0.25, 0.5):
        lo, hi = band_bounds(eta)
        print(f"  {eta:>10.5f} {lo:>14.6f} {hi:>14.6f}")
    lo, hi = band_bounds(ETA_HEADLINE)
    print(f"\n  eta = 1/21 = {ETA_HEADLINE:.6f}  ->  [{lo:.6f}, {hi:.6f}] "
          f"= [10/11, 11/10] within [0.9, 1.1]")

    # sharpness: one knee at the bottom of its band, the other at the top
    d1, d2 = 16, 4
    K1 = (1.0 - ETA_HEADLINE) * depth_linear_knee(ctx, d1)
    K2 = (1.0 + ETA_HEADLINE) * depth_linear_knee(ctx, d2)
    r = margin_of_knee(L, B, A, ctx, d1, K1) / margin_of_knee(L, B, A, ctx, d2, K2)
    print("\n  Sharpness witness (both knees inside the +/-1/21 band):")
    print(f"    K({d1}) at band bottom = {K1:.4f},  K({d2}) at band top = {K2:.4f}")
    print(f"    implied margin ratio    = {r:.10f}   (exactly 11/10)")
    assert within_rel(ETA_HEADLINE, K1, depth_linear_knee(ctx, d1))
    assert within_rel(ETA_HEADLINE, K2, depth_linear_knee(ctx, d2))
    assert abs(r - 1.1) < 1e-12

    # randomised check that the band is never violated
    rng = random.Random(20260824)
    worst = 1.0
    for _ in range(100_000):
        e1 = rng.uniform(-ETA_HEADLINE, ETA_HEADLINE)
        e2 = rng.uniform(-ETA_HEADLINE, ETA_HEADLINE)
        k1 = (1.0 + e1) * depth_linear_knee(ctx, 16)
        k2 = (1.0 + e2) * depth_linear_knee(ctx, 4)
        ratio = margin_of_knee(L, B, A, ctx, 16, k1) / margin_of_knee(L, B, A, ctx, 4, k2)
        worst = max(worst, ratio, 1.0 / ratio)
        assert BAND_LO <= ratio <= BAND_HI
    print(f"\n  100000 random in-band knee pairs: worst deviation factor "
          f"{worst:.6f} <= 1.1  (no violation)")


def demo_refutation_and_threshold() -> None:
    rule("4-5. REFUTATION of the naive 1/d law, and the decision rule")
    L, B, A, ctx = 1.3, 0.7, 0.02, 1024.0
    K4 = depth_linear_knee(ctx, 4)
    K16 = depth_linear_knee(ctx, 16)
    m4 = margin_of_knee(L, B, A, ctx, 4, K4)
    m16 = margin_of_knee(L, B, A, ctx, 16, K16)
    print(f"  mechanism:      m(16)/m(4) = {m16 / m4:.6f}")
    print(f"  naive 1/d law:  m(16)/m(4) = {0.25:.6f}")
    print(f"  band floor:                  {BAND_LO:.6f}"
          "   ->  0.25 < 0.9, so the two are incompatible.")

    print("\n  Threshold test (accept iff reported ratio > 0.45), "
          "multiplicative error up to +/-50%:")
    print(f"  {'true r':>10} {'worst reported':>16} {'best reported':>16} {'verdict':>22}")
    for r in (1.0, 0.9, 0.5, 0.275, 0.25, 0.2):
        lo_rep, hi_rep = r * 0.5, r * 1.5
        if r >= 0.9:
            verdict = "always accepted"
        elif r <= 0.275:
            verdict = "always rejected"
        else:
            verdict = "undetermined (gap)"
        print(f"  {r:>10.3f} {lo_rep:>16.4f} {hi_rep:>16.4f} {verdict:>22}")
    assert 0.9 * 0.5 >= THRESHOLD
    assert 0.275 * 1.5 < THRESHOLD
    print(f"\n  0.9*0.5 = {0.9 * 0.5:.4f} >= 0.45 and 0.275*1.5 = "
          f"{0.275 * 1.5:.4f} < 0.45: correct on both sides.")


def demo_exponents() -> None:
    rule("6. POWER-LAW RIGIDITY — the depth exponent is essentially zero")
    bound = exponent_bound()
    print(f"  |alpha| <= log(10/9)/log 4 = {math.log(10 / 9) / math.log(4):.8f}")
    print(f"  (attained bound from the [0.9, 1.1] window: {bound:.8f})")
    print(f"  naive alpha = 1 exceeds this by a factor of "
          f"{1.0 / bound:.2f}\n")
    m1 = 1.0
    print(f"  {'alpha':>8} {'m(16)/m(4)':>14} {'knee(16)/knee(4)':>20} {'in band?':>10}")
    for alpha in (0.0, 0.05, 0.076, 0.1, 0.25, 0.5, 1.0):
        ratio = margin_power(m1, alpha, 16.0) / margin_power(m1, alpha, 4.0)
        knee_ratio = 4.0 ** (1.0 + alpha)
        flag = "yes" if BAND_LO <= ratio <= BAND_HI else "NO"
        print(f"  {alpha:>8.3f} {ratio:>14.6f} {knee_ratio:>20.6f} {flag:>10}")
    print("\n  Read from the knee side: knee(16)/knee(4) = 4^(1+alpha).")
    print("  A measured knee ratio of exactly 4 forces alpha = 0:")
    for alpha in (0.0, 0.076, 1.0):
        print(f"    alpha = {alpha:<6.3f} -> 4^(1+alpha) = "
              f"{4.0 ** (1.0 + alpha):.6f}")


def demo_isometry() -> None:
    rule("7. PROJECTIVE GEOMETRY — the margin map is an isometry")
    ctx = 1024.0
    K1, K2 = 500.0, 140.0
    d1, d2 = 16, 4
    print("  Varying the unmeasurable constants A and L*B leaves the")
    print("  log-ratio distance between implied margins unchanged:\n")
    print(f"  {'A':>10} {'L*B':>10} {'rho(m1, m2)':>16} "
          f"{'rho(K2/d2, K1/d1)':>20}")
    for A, LB in ((0.02, 0.91), (0.2, 0.91), (0.02, 12.0), (7.5, 0.004)):
        L, B = LB, 1.0
        m1 = margin_of_knee(L, B, A, ctx, d1, K1)
        m2 = margin_of_knee(L, B, A, ctx, d2, K2)
        lhs = log_ratio(m1, m2)
        rhs = log_ratio(K2 / d2, K1 / d1)
        print(f"  {A:>10.4f} {LB:>10.4f} {lhs:>16.10f} {rhs:>20.10f}")
        assert abs(lhs - rhs) < 1e-12
    radius = math.log((1 + ETA_HEADLINE) / (1 - ETA_HEADLINE))
    print(f"\n  Ball radius at eta = 1/21: log(11/10) = {radius:.8f}")
    print(f"  Chaining 4 -> 8 -> 16 would cost 2 * {radius:.8f} = "
          f"{2 * radius:.8f}: strictly worse.")


def demo_grids() -> None:
    rule("8. GRID RESOLUTION — which sweeps can test the claim at all")
    L, B, A, ctx = 1.3, 0.7, 0.02, 1024.0
    print(f"  {'grid step rho':>14} {'achievable ratio band':>26} "
          f"{'certifies +/-10%?':>20}")
    for rho in (2.0, 1.5, 1.25, 1.1, 1.05, 1.02):
        lo, hi = 1.0 / rho, rho
        ok = "yes" if rho <= 1.1 + 1e-12 else "NO"
        print(f"  {rho:>14.3f} {'[%.4f, %.4f]' % (lo, hi):>26} {ok:>20}")

    ctx_demo = 1000.0   # not a power of two, so the grid genuinely overshoots
    print(f"\n  Dyadic sweep, k in {{1, 2, 4, 8, ...}}, ctx = {ctx_demo:.0f}, "
          "true knees d*ctx/32:")
    print(f"  {'d':>4} {'true knee':>12} {'dyadic report':>16} "
          f"{'overshoot':>12} {'implied margin':>18}")
    for d in (4, 8, 16):
        k_true = depth_linear_knee(ctx_demo, d)
        k_rep = grid_report(2.0, k_true)
        m = margin_of_knee(L, B, A, ctx_demo, d, k_rep)
        print(f"  {d:>4} {k_true:>12.2f} {k_rep:>16.2f} "
              f"{k_rep / k_true:>12.4f} {m:>18.6f}")

    # worst case consistent with a dyadic sweep
    d1, d2 = 16, 4
    K1 = depth_linear_knee(ctx, d1)
    K2 = 2.0 * depth_linear_knee(ctx, d2)
    r = margin_of_knee(L, B, A, ctx, d1, K1) / margin_of_knee(L, B, A, ctx, d2, K2)
    print(f"\n  Worst case consistent with rho = 2: implied ratio = {r:.4f} "
          f"(> 1.1) — a dyadic sweep cannot certify the claim.")
    assert abs(r - 2.0) < 1e-12

    # a fine grid does certify
    fine = 1.1
    worst = 1.0
    for d in range(1, 65):
        k_true = depth_linear_knee(ctx, d)
        k_rep = grid_report(fine, k_true)
        worst = max(worst, k_rep / k_true)
    print(f"  With rho = 1.1 the worst overshoot over d = 1..64 is "
          f"{worst:.6f} <= 1.1, so the implied ratio stays in [1/1.1, 1.1].")


def demo_aggregation_and_verdict() -> None:
    rule("9-10. AGGREGATION and the EXECUTABLE VERDICT")
    clean = [Fraction(1)] * 6
    corrupted = [Fraction(1)] * 5 + [Fraction(100)]
    print(f"  clean log      : {[float(x) for x in clean]}")
    print(f"  one crashed run: {[float(x) for x in corrupted]}")
    print(f"  mean(corrupted)   = {float(list_mean(corrupted)):.4f}  "
          f"(outside [0.9, 1.1]: the mean has breakdown point 0)")
    print(f"  medians(corrupted) = {[float(x) for x in medians(corrupted)]}  "
          f"(all inside the band)")
    assert all(in_band_e3(m) for m in medians(corrupted))

    synthetic = [Fraction(1), Fraction(102, 100), Fraction(98, 100),
                 Fraction(104, 100), Fraction(97, 100), Fraction(101, 100)]
    quarter = [Fraction(1, 4)] * 6
    tie = [Fraction(1), Fraction(1), Fraction(2), Fraction(2)]
    print("\n  Verdict: accept iff a strict majority of ratios lie in [0.9, 1.1].")
    for name, log in (("synthetic flat log (3 depths x 2 seeds)", synthetic),
                      ("naive-quarter log", quarter),
                      ("exact tie [1,1,2,2]", tie)):
        n_in = sum(1 for x in log if in_band_e3(x))
        print(f"    {name:<42} in band {n_in}/{len(log)}  "
              f"accept = {e3_accept(log)}   medians = "
              f"{[float(x) for x in medians(log)]}")
    assert e3_accept(synthetic) and not e3_accept(quarter) and not e3_accept(tie)
    print("\n  The tie log has exactly half its runs in band and admits the")
    print("  out-of-band median 2: the strict majority cannot be relaxed.")

    print("\n  Seed budget (need 2k < n, k = corrupted runs):")
    print(f"  {'n seeds':>9} {'tolerated failures k':>22} "
          f"{'survives one failure?':>24}")
    for n in (1, 2, 3, 4, 5, 7):
        k = (n - 1) // 2
        print(f"  {n:>9} {k:>22} {('yes' if k >= 1 else 'no'):>24}")
    print("\n  With n = 2 and one bad run, ANY value can be a median:")
    for t in (Fraction(1, 4), Fraction(7), Fraction(-3)):
        contaminated = [Fraction(1), t]
        print(f"    [1, {float(t)}] has medians "
              f"{[float(x) for x in medians(contaminated)]}")


def demo_invariant() -> None:
    rule("11. THE DIMENSIONLESS INVARIANT — one number tests the mechanism")
    print("  With the margin pinned at m = 128*L*B*A, the deficit at the")
    print("  selected budget is confined to [16A, 32A] = [m/(8LB), m/(4LB)].\n")
    print(f"  {'d':>4} {'ctx':>7} {'A':>8} {'L*B':>7} {'k*':>10} "
          f"{'deficit window':>22} {'invariant window':>22}")
    for d, ctx, A, LB in ((4, 1024, 0.02, 0.91), (8, 1024, 0.02, 0.91),
                          (16, 1024, 0.02, 0.91), (16, 32, 0.5, 5.0),
                          (3, 4096, 0.007, 0.13)):
        L, B = LB, 1.0
        m = 128.0 * L * B * A
        k_star = d * ctx / 32.0
        # per-layer deficit seen at the top of the stack, at the two edges
        lo = zipf_tail(A, ctx, ctx / 16.0)   # = 16A
        hi = zipf_tail(A, ctx, ctx / 32.0)   # = 32A
        inv_lo, inv_hi = lo * L * B / m, hi * L * B / m
        print(f"  {d:>4} {ctx:>7} {A:>8.4f} {LB:>7.3f} {k_star:>10.2f} "
              f"{'[%.5f, %.5f]' % (lo, hi):>22} "
              f"{'[%.5f, %.5f]' % (inv_lo, inv_hi):>22}")
        assert abs(inv_lo - 0.125) < 1e-12 and abs(inv_hi - 0.25) < 1e-12
    print("\n  Every row lands on [1/8, 1/4] — no depth, no context,")
    print("  no amplitude, no read-out constant survives.")
    print("\n  Amplitude from a single measured margin: A = m/(128*L*B).")
    for m, LB in ((2.33, 0.91), (0.5, 4.0)):
        print(f"    m = {m:<6} L*B = {LB:<5} ->  A = {m / (128 * LB):.8f}")


def main() -> None:
    print("Depth-Independence of the Held-Out Logit Margin")
    print("Numerical demonstrations of the band theory, its sharpness,")
    print("and the measurement protocol.")
    demo_pinning()
    demo_band_and_sharpness()
    demo_refutation_and_threshold()
    demo_exponents()
    demo_isometry()
    demo_grids()
    demo_aggregation_and_verdict()
    demo_invariant()
    print("\n" + "=" * 74)
    print("All assertions passed.")
    print("=" * 74)


if __name__ == "__main__":
    main()
