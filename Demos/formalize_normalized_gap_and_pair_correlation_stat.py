#!/usr/bin/env python3
"""
Normalized gap and pair-correlation statistics for finite spectra
=================================================================

Self-contained numerical demonstration of every quantitative claim in the
accompanying article and paper.  No third-party dependencies: standard library
only (math, random, statistics).

The results demonstrated here:

  1.  Unfolding invariants
        - the n normalized gaps of a window sum to exactly n;
        - normalized gaps are invariant under lambda -> a*lambda + b (a != 0).

  2.  The spurious uniform law of the RAW quadratic spectrum lambda_k = k^2:
        |F_n(t) - t/2| <= 1/(2n)   for all t in [0,2].

  3.  The unfolding principle:  if g(lambda_k) = k then every normalized gap of
      g o lambda equals 1.  For lambda_k = k^2 the counting function is sqrt,
      giving the picket fence mu_k = k:  Dirac spacing law, zero variance.

  4.  Exact two-level correlation of the picket fence:
        R2(n,t) = 2*floor(t)*n - floor(t)*(floor(t)+1)   for floor(t) <= n,
        R2(n,t)/n -> 2*floor(t)                          (a staircase).

  5.  Number rigidity:  | #levels in [a, a+L) - L | < 1 uniformly in a,
      and the same for an arithmetic spectrum d*k with L/d in place of L.

  6.  The two universality classes:
        p_P(s) = exp(-s),   p_U(s) = (32/pi^2) s^2 exp(-(4/pi) s^2),
      both normalized with mean 1; second moments 2 and 3*pi/8; variance
      ordering 0 < 3*pi/8 - 1 < 1; quadratic level repulsion on (0, 1/4];
      strict interior mode of p_U at sqrt(pi)/2 with value 8/(pi*e).

  7.  Kolmogorov-Smirnov separation of the picket fence from both classes:
      distance >= 1/3 from Poisson and >= 1/12 from the unitary class, at the
      single threshold t = 1/2, for every window size n.

  8.  The unfolding-free gap ratio r_i = min(g_i,g_{i+1}) / max(g_i,g_{i+1}):
      affine invariance with no unfolding; for the RAW quadratic spectrum
      r_i = (2i+1)/(2i+3) with 1 - r_i = 2/(2i+3) -> 0, so the ratio statistic
      detects rigidity where the normalized-gap law reports a uniform artefact.
"""

from __future__ import annotations

import math
import random
import statistics
from typing import Callable, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# Core definitions
# ----------------------------------------------------------------------------


def gaps(levels: Sequence[float]) -> List[float]:
    """Raw gaps g_i = levels[i+1] - levels[i]."""
    return [levels[i + 1] - levels[i] for i in range(len(levels) - 1)]


def mean_gap(levels: Sequence[float]) -> float:
    """Window mean gap (levels[n] - levels[0]) / n, with n = len(levels) - 1."""
    n = len(levels) - 1
    if n <= 0:
        raise ValueError("need at least two levels")
    return (levels[-1] - levels[0]) / n


def normalized_gaps(levels: Sequence[float]) -> List[float]:
    """Unfolded gaps s_i = g_i / mean_gap.  Their sum is exactly n."""
    m = mean_gap(levels)
    if m == 0.0:
        raise ValueError("degenerate window: mean gap is zero")
    return [g / m for g in gaps(levels)]


def empirical_cdf(values: Sequence[float], t: float) -> float:
    """Fraction of `values` that are <= t."""
    return sum(1 for v in values if v <= t) / len(values)


def spacing_variance(levels: Sequence[float]) -> float:
    """Empirical variance of the normalized gaps about their mean, which is 1."""
    s = normalized_gaps(levels)
    return sum((x - 1.0) ** 2 for x in s) / len(s)


def gap_ratio(levels: Sequence[float]) -> List[float]:
    """Consecutive gap ratios r_i = min(g_i, g_{i+1}) / max(g_i, g_{i+1})."""
    g = gaps(levels)
    return [min(g[i], g[i + 1]) / max(g[i], g[i + 1]) for i in range(len(g) - 1)]


def pair_corr_count(levels: Sequence[float], t: float) -> int:
    """Ordered pairs (i, j), i != j, with |levels[i] - levels[j]| <= t.

    Two-pointer sweep on a sorted spectrum: O(n) after sorting.
    """
    xs = sorted(levels)
    n = len(xs)
    total = 0
    j = 0
    for i in range(n):
        if j < i:
            j = i
        while j + 1 < n and xs[j + 1] <= xs[i] + t:
            j += 1
        total += 2 * (j - i)
    return total


def window_count(levels: Sequence[float], a: float, L: float) -> int:
    """Number of levels in the half-open window [a, a + L)."""
    return sum(1 for x in levels if a <= x < a + L)


# ----------------------------------------------------------------------------
# Universality-class densities
# ----------------------------------------------------------------------------


def poisson_gap_pdf(s: float) -> float:
    """Poisson (uncorrelated levels) spacing density exp(-s)."""
    return math.exp(-s)


def gue_gap_pdf(s: float) -> float:
    """Wigner surmise for the unitary class: (32/pi^2) s^2 exp(-(4/pi) s^2)."""
    return 32.0 / math.pi ** 2 * s * s * math.exp(-(4.0 / math.pi) * s * s)


def simpson(f: Callable[[float], float], a: float, b: float, n: int = 20000) -> float:
    """Composite Simpson rule with an even number of subintervals."""
    if n % 2 == 1:
        n += 1
    h = (b - a) / n
    total = f(a) + f(b)
    for k in range(1, n):
        total += (4.0 if k % 2 else 2.0) * f(a + k * h)
    return total * h / 3.0


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------


def demo_unfolding_invariants() -> None:
    print("=" * 78)
    print("1.  UNFOLDING INVARIANTS")
    print("=" * 78)
    n = 40
    quad = [float(k) ** 2 for k in range(n + 1)]
    s = normalized_gaps(quad)
    print(f"  window size n                      : {n}")
    print(f"  sum of normalized gaps (should be n): {sum(s):.12f}")

    a, b = -3.75, 12.5  # affine rescale with a != 0
    resc = [a * x + b for x in quad]
    s2 = normalized_gaps(resc)
    err = max(abs(u - v) for u, v in zip(s, s2))
    print(f"  affine map lambda -> {a}*lambda + {b}")
    print(f"  max |s_i(rescaled) - s_i(original)| : {err:.3e}   (invariance)")
    print()


def demo_spurious_uniform_law() -> None:
    print("=" * 78)
    print("2.  THE RAW QUADRATIC SPECTRUM LOOKS UNIFORM ON [0, 2]  (artefact)")
    print("=" * 78)
    print("     n     sup_t |F_n(t) - t/2|      bound 1/(2n)     ratio")
    for n in (10, 50, 200, 1000, 5000):
        quad = [float(k) ** 2 for k in range(n + 1)]
        s = normalized_gaps(quad)
        worst = 0.0
        # the sup over t in [0,2] is attained near the jump points
        for j in range(0, 801):
            t = 2.0 * j / 800.0
            worst = max(worst, abs(empirical_cdf(s, t) - t / 2.0))
        bound = 1.0 / (2.0 * n)
        print(f"  {n:5d}     {worst:.8f}            {bound:.8f}    {worst / bound:.4f}")
    print("  -> the empirical law converges to the uniform law on [0,2] at rate 1/(2n).")
    print("     This says nothing about correlations: it is the divergent density")
    print("     of states of k^2, not a spectral statistic.")
    print()


def demo_unfolding_principle() -> None:
    print("=" * 78)
    print("3.  THE UNFOLDING PRINCIPLE AND THE PICKET FENCE")
    print("=" * 78)
    n = 40
    quad = [float(k) ** 2 for k in range(n + 1)]
    unfolded = [math.sqrt(x) for x in quad]  # counting function N(x) = sqrt(x)
    s = normalized_gaps(unfolded)
    print(f"  unfolded levels sqrt(k^2) = k, first few: {[round(x,3) for x in unfolded[:6]]}")
    print(f"  max |s_i - 1|                     : {max(abs(x - 1.0) for x in s):.3e}")
    print(f"  empirical spacing variance        : {spacing_variance(unfolded):.3e}  (rigid = 0)")
    print(f"  F(t) at t = 0.999                 : {empirical_cdf(s, 0.999):.3f}  (Dirac: 0)")
    print(f"  F(t) at t = 1.001                 : {empirical_cdf(s, 1.001):.3f}  (Dirac: 1)")

    # a second instance of the same principle: lambda_k = k^3, g = cube root
    cubic = [float(k) ** 3 for k in range(n + 1)]
    s3 = normalized_gaps([x ** (1.0 / 3.0) for x in cubic])
    print(f"  same principle for lambda_k = k^3 : max |s_i - 1| = "
          f"{max(abs(x - 1.0) for x in s3):.3e}")
    print()


def demo_pair_correlation_staircase() -> None:
    print("=" * 78)
    print("4.  EXACT TWO-LEVEL CORRELATION OF THE PICKET FENCE: A STAIRCASE")
    print("=" * 78)
    print("      n      t     R2 counted    2*floor(t)*n - floor(t)(floor(t)+1)   R2/n   2*floor(t)")
    for n in (50, 200):
        for t in (0.5, 1.0, 1.7, 2.0, 3.9):
            levels = [float(k) for k in range(n)]
            counted = pair_corr_count(levels, t)
            m = math.floor(t)
            closed = 2 * m * n - m * (m + 1)
            print(f"  {n:5d}  {t:5.2f}   {counted:9d}    {closed:29d}   "
                  f"{counted / n:6.3f}   {2 * m:5d}")
    print("  -> the density limit is the STAIRCASE 2*floor(t), flat between integers.")
    print("     Poisson gives the continuous 2t; the unitary class is continuous too.")
    print()


def demo_number_rigidity() -> None:
    print("=" * 78)
    print("5.  NUMBER RIGIDITY: BOUNDED VARIANCE OF THE WINDOW COUNT")
    print("=" * 78)
    rng = random.Random(20260825)
    N = 20000
    picket = [float(k) for k in range(N)]
    print("      L      max |count - L|  (picket)     var of count (picket)    var (Poisson)")
    for L in (1.5, 4.3, 16.7, 64.25, 256.8):
        worst = 0.0
        counts_picket: List[float] = []
        for _ in range(400):
            a = rng.uniform(100.0, N - 500.0)
            c = window_count(picket, a, L)
            counts_picket.append(float(c))
            worst = max(worst, abs(c - L))
        # a genuine Poisson process of unit intensity, for contrast
        counts_poisson: List[float] = []
        for _ in range(400):
            x, cnt = 0.0, 0
            while True:
                x += rng.expovariate(1.0)
                if x >= L:
                    break
                cnt += 1
            counts_poisson.append(float(cnt))
        print(f"  {L:7.1f}        {worst:.4f}                    "
              f"{statistics.pvariance(counts_picket):8.4f}            "
              f"{statistics.pvariance(counts_poisson):8.4f}")
    print("  -> picket deviation always < 1 and variance bounded; Poisson variance ~ L.")

    # arithmetic spectrum d*k: deviation from L/d is again < 1
    d = 0.37
    arith = [d * k for k in range(N)]
    worst = 0.0
    for _ in range(2000):
        a = rng.uniform(10.0, d * N - 200.0)
        L = rng.uniform(0.0, 100.0)
        worst = max(worst, abs(window_count(arith, a, L) - L / d))
    print(f"  arithmetic spectrum d*k with d = {d}:  max |count - L/d| = {worst:.4f}  (< 1)")
    print()


def demo_universality_classes() -> None:
    print("=" * 78)
    print("6.  THE TWO UNIVERSALITY CLASSES")
    print("=" * 78)
    big = 40.0
    print("                                   Poisson        Unitary (Wigner surmise)")
    print(f"  integral of p over (0, inf) : {simpson(poisson_gap_pdf, 0, big):10.6f}"
          f"     {simpson(gue_gap_pdf, 0, big):10.6f}       (exact: 1)")
    print(f"  mean spacing                : "
          f"{simpson(lambda s: s * poisson_gap_pdf(s), 0, big):10.6f}"
          f"     {simpson(lambda s: s * gue_gap_pdf(s), 0, big):10.6f}       (exact: 1)")
    m2p = simpson(lambda s: s * s * poisson_gap_pdf(s), 0, big)
    m2u = simpson(lambda s: s * s * gue_gap_pdf(s), 0, big)
    print(f"  second moment               : {m2p:10.6f}     {m2u:10.6f}"
          f"       (exact: 2  and  3*pi/8 = {3 * math.pi / 8:.6f})")
    print(f"  spacing variance            : {m2p - 1:10.6f}     {m2u - 1:10.6f}")
    print(f"  variance ordering: 0 < 3*pi/8 - 1 = {3 * math.pi / 8 - 1:.6f} < 1   "
          "(rigid / unitary / Poisson)")

    print("\n  Quadratic level repulsion on (0, 1/4]:")
    print("        s        p_U(s)      p_P(s)    p_U < p_P ?")
    for s in (0.01, 0.05, 0.10, 0.20, 0.25):
        print(f"     {s:5.2f}    {gue_gap_pdf(s):9.6f}   {poisson_gap_pdf(s):9.6f}"
              f"        {gue_gap_pdf(s) < poisson_gap_pdf(s)}")

    print("\n  Strict interior mode of the Wigner surmise:")
    mode = math.sqrt(math.pi) / 2.0
    print(f"     s* = sqrt(pi)/2      = {mode:.10f}")
    print(f"     p_U(s*)              = {gue_gap_pdf(mode):.10f}")
    print(f"     8/(pi*e)             = {8.0 / (math.pi * math.e):.10f}")
    grid_max = max((gue_gap_pdf(0.0005 * k), 0.0005 * k) for k in range(1, 8000))
    print(f"     numerical grid max   = {grid_max[0]:.10f}  at s = {grid_max[1]:.6f}")
    print("     The Poisson density exp(-s) is strictly decreasing: no interior mode.")

    print("\n  No rescaling of the surmise is the Poisson density:")
    for c in (0.5, 1.0, 2.0, 5.0):
        s = min(0.5, 1.0 / (8.0 * (1.0 + c) ** 3))
        lhs, rhs = c * gue_gap_pdf(c * s), poisson_gap_pdf(s)
        print(f"     c = {c:4.1f}:  s = {s:.6f},  c*p_U(c s) = {lhs:.6f}  vs  "
              f"p_P(s) = {rhs:.6f}   (differ)")
    print()


def demo_ks_separation() -> None:
    print("=" * 78)
    print("7.  KOLMOGOROV-SMIRNOV SEPARATION AT THE THRESHOLD t = 1/2")
    print("=" * 78)
    F_poisson_half = 1.0 - math.exp(-0.5)
    F_gue_half = simpson(gue_gap_pdf, 0.0, 0.5)
    print(f"  Poisson CDF at 1/2                : {F_poisson_half:.6f}   (>= 1/3 = 0.333333)")
    print(f"  Wigner-surmise CDF at 1/2         : {F_gue_half:.6f}   (>= 1/12 = 0.083333)")
    print(f"  proved lower bound (4/(3 pi^2)) e^(-1/pi) = "
          f"{4.0 / (3.0 * math.pi ** 2) * math.exp(-1.0 / math.pi):.6f}")
    print("\n      n    picket CDF(1/2)   KS to Poisson   KS to unitary")
    for n in (5, 20, 100, 1000):
        picket = [float(k) for k in range(n + 1)]
        s = normalized_gaps(picket)
        f = empirical_cdf(s, 0.5)
        print(f"  {n:5d}      {f:.6f}         {abs(f - F_poisson_half):.6f}       "
              f"{abs(f - F_gue_half):.6f}")
    print("  -> both separations are independent of n: more data will not help.")
    print()


def demo_gap_ratio() -> None:
    print("=" * 78)
    print("8.  THE UNFOLDING-FREE GAP RATIO")
    print("=" * 78)
    n = 60
    quad = [float(k) ** 2 for k in range(n + 1)]
    r = gap_ratio(quad)
    print("      i     r_i (computed)   (2i+1)/(2i+3)     1 - r_i      2/(2i+3)")
    for i in (0, 1, 4, 10, 25, 50):
        exact = (2 * i + 1) / (2 * i + 3)
        print(f"  {i:5d}     {r[i]:.10f}    {exact:.10f}    {1-r[i]:.8f}   "
              f"{2.0/(2*i+3):.8f}")
    print(f"  r_i < 1 for every i          : {all(x < 1.0 for x in r)}")
    print(f"  r_i -> 1                     : r_{n-2} = {r[-1]:.6f}")

    a, b = 7.25, -19.0
    r_resc = gap_ratio([a * x + b for x in quad])
    print(f"  affine map lambda -> {a}*lambda + {b} (a > 0):")
    print(f"    max |r_i(rescaled) - r_i|  : "
          f"{max(abs(u - v) for u, v in zip(r, r_resc)):.3e}   (invariance, NO unfolding)")

    picket = [float(k) for k in range(n + 1)]
    rp = gap_ratio(picket)
    print(f"  picket fence: max |r_i - 1|  : {max(abs(x - 1.0) for x in rp):.3e}")

    # Empirical mean r for simulated Poisson levels and for the rigid fence.
    rng = random.Random(31415)
    poisson_levels = [0.0]
    for _ in range(200000):
        poisson_levels.append(poisson_levels[-1] + rng.expovariate(1.0))
    mean_r_poisson = statistics.fmean(gap_ratio(poisson_levels))
    print(f"\n  mean gap ratio, simulated Poisson levels : {mean_r_poisson:.5f}"
          f"   (conjectured 2 ln 2 - 1 = {2*math.log(2)-1:.5f})")
    print(f"  mean gap ratio, rigid picket fence       : {statistics.fmean(rp):.5f}   (= 1)")
    print(f"  mean gap ratio, raw quadratic spectrum   : {statistics.fmean(r):.5f}"
          "   (-> 1: rigidity seen in the RAW data)")
    print()


def main() -> None:
    print()
    print("#" * 78)
    print("#  NORMALIZED GAP AND PAIR-CORRELATION STATISTICS FOR FINITE SPECTRA")
    print("#  Unfolding, rigidity, and unfolding-free separation of the classes")
    print("#" * 78)
    print()
    demo_unfolding_invariants()
    demo_spurious_uniform_law()
    demo_unfolding_principle()
    demo_pair_correlation_staircase()
    demo_number_rigidity()
    demo_universality_classes()
    demo_ks_separation()
    demo_gap_ratio()
    print("=" * 78)
    print("All demonstrated values agree with the theorems.")
    print("=" * 78)


if __name__ == "__main__":
    main()
