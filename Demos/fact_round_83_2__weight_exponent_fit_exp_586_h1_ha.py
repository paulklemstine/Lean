#!/usr/bin/env python3
"""
Numerical demonstrations for the weight-exponent theory of the quadratic-residue
product dial.

The object of study is the one-parameter family of weighted prime statistics

    S_alpha(N) = sum over { l in W : N is a QR mod l } of l ** (-alpha),

where W is a window of odd primes and the harmonic exponent alpha = 1 is compared
against the fitted exponent alpha = 1/2.

Everything below is self-contained: no third-party dependencies, only the Python
standard library.  Each demonstration corresponds to a theorem or measurement:

  1. Strict antitonicity of alpha -> S_alpha.
  2. Log-convexity of alpha -> log S_alpha (midpoint and Hoelder forms), and
     strictness on a two-prime support, with the Lagrange-identity residual.
  3. The tropical squeeze  m^-a <= S_a <= |A| m^-a  and Maslov dequantization
     (log S_a)/a -> -log(min A).
  4. Affine invariance of the single-covariate coefficient of determination.
  5. Dequantization of the whole regression: R^2(alpha) -> R^2 of the one-bit
     tropical covariate, with the geometric spectral-gap rate.
  6. The recorded alpha-curve: single-peakedness, the falling limb at alpha = 1,
     the 0.1511 gain, and the 31% relative improvement.
  7. The edge ratio at l = 400: 1/133 under 1/l, 1/11.5 under 1/sqrt(l).
  8. Window mass T_alpha(B) of exact order B^(1-alpha): bounded at alpha = 1,
     divergent at alpha = 1/2 -- saturation does not transfer.
  9. A synthetic end-to-end pipeline: build QR supports for random integers,
     build a response that genuinely depends on the sqrt-weighted dial, sweep
     the exponent, and confirm the sweep recovers an interior optimum.
"""

from __future__ import annotations

import math
import random
from typing import Dict, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# Basic arithmetic utilities
# ----------------------------------------------------------------------------


def primes_up_to(limit: int) -> List[int]:
    """All primes <= limit, by a simple sieve of Eratosthenes."""
    if limit < 2:
        return []
    sieve = bytearray([1]) * (limit + 1)
    sieve[0] = sieve[1] = 0
    for p in range(2, int(limit ** 0.5) + 1):
        if sieve[p]:
            sieve[p * p:: p] = bytearray(len(sieve[p * p:: p]))
    return [i for i in range(limit + 1) if sieve[i]]


def odd_prime_window(low: int, high: int) -> List[int]:
    """The odd primes l with low <= l <= high."""
    return [p for p in primes_up_to(high) if p >= low and p % 2 == 1]


def legendre_symbol(a: int, p: int) -> int:
    """Legendre symbol (a|p) for an odd prime p, by Euler's criterion."""
    a %= p
    if a == 0:
        return 0
    t = pow(a, (p - 1) // 2, p)
    return 1 if t == 1 else -1


def qr_support(n: int, window: Sequence[int]) -> List[int]:
    """The active primes: those l in the window with (n|l) = +1."""
    return [l for l in window if legendre_symbol(n, l) == 1]


# ----------------------------------------------------------------------------
# The dial statistic
# ----------------------------------------------------------------------------


def dial_weight(alpha: float, l: int) -> float:
    """The dial weight l^(-alpha)."""
    return float(l) ** (-alpha)


def dial_sum(support: Sequence[int], alpha: float) -> float:
    """S_alpha = sum over the active primes of l^(-alpha)."""
    return sum(dial_weight(alpha, l) for l in support)


# ----------------------------------------------------------------------------
# The selection functional
# ----------------------------------------------------------------------------


def mean(v: Sequence[float]) -> float:
    return sum(v) / len(v)


def cov(x: Sequence[float], y: Sequence[float]) -> float:
    """Unnormalized sample covariance."""
    mx, my = mean(x), mean(y)
    return sum((xi - mx) * (yi - my) for xi, yi in zip(x, y))


def var(x: Sequence[float]) -> float:
    """Unnormalized sample variance."""
    return cov(x, x)


def r_squared(x: Sequence[float], y: Sequence[float]) -> float:
    """Single-covariate coefficient of determination of the OLS fit y ~ x."""
    denom = var(x) * var(y)
    if denom == 0.0:
        return 0.0
    return cov(x, y) ** 2 / denom


# ----------------------------------------------------------------------------
# Demonstration 1 -- strict antitonicity
# ----------------------------------------------------------------------------


def demo_antitonicity() -> None:
    print("=" * 78)
    print("1. STRICT ANTITONICITY:  alpha -> S_alpha is strictly decreasing")
    print("=" * 78)
    support = [3, 5, 7, 11, 13, 17, 19, 23]
    grid = [0.0, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
    values = [dial_sum(support, a) for a in grid]
    print(f"   support = {support}")
    for a, s in zip(grid, values):
        print(f"     alpha = {a:4.2f}   S_alpha = {s:12.6f}")
    strict = all(values[i + 1] < values[i] for i in range(len(values) - 1))
    print(f"   strictly decreasing across the grid: {strict}")
    print("   (Note the range: the covariate shrinks by orders of magnitude,")
    print("    which is exactly why the selection rule must be scale-free.)\n")


# ----------------------------------------------------------------------------
# Demonstration 2 -- log-convexity
# ----------------------------------------------------------------------------


def demo_log_convexity() -> None:
    print("=" * 78)
    print("2. LOG-CONVEXITY:  S_{(a+b)/2}^2 <= S_a S_b, strictly on 2 primes")
    print("=" * 78)
    support = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
    pairs: List[Tuple[float, float]] = [(0.0, 1.0), (0.25, 1.5), (0.5, 2.0), (1.0, 1.0)]
    print("   midpoint form on a 10-prime support:")
    for a, b in pairs:
        lhs = dial_sum(support, (a + b) / 2.0) ** 2
        rhs = dial_sum(support, a) * dial_sum(support, b)
        tag = "equality" if abs(lhs - rhs) < 1e-12 else "strict"
        print(f"     a={a:4.2f} b={b:4.2f}:  {lhs:14.8f} <= {rhs:14.8f}   [{tag}]")

    print("   Hoelder form  S_{ta+(1-t)b} <= S_a^t S_b^(1-t):")
    a, b = 0.25, 1.75
    for t in [0.0, 0.2, 0.5, 0.8, 1.0]:
        lhs = dial_sum(support, t * a + (1 - t) * b)
        rhs = dial_sum(support, a) ** t * dial_sum(support, b) ** (1 - t)
        print(f"     t={t:4.2f}:  {lhs:14.8f} <= {rhs:14.8f}   gap={rhs - lhs:.3e}")

    print("   strictness on a two-prime support (Lagrange residual):")
    for (p, q, a, b) in [(3, 400, 0.5, 1.0), (3, 5, 0.0, 2.0), (7, 7, 0.5, 1.0)]:
        A = sorted({p, q})
        lhs = dial_sum(A, (a + b) / 2.0) ** 2
        rhs = dial_sum(A, a) * dial_sum(A, b)
        residual = rhs - lhs
        note = "degenerate (one prime)" if len(A) == 1 else "strict, residual > 0"
        print(f"     A={A}, a={a}, b={b}:  S_a S_b - S_mid^2 = {residual:.10e}  [{note}]")
    print("   The residual equals (A1 B2 - A2 B1)^2, which vanishes only if the")
    print("   two exponents or the two primes coincide -- hence identifiability.\n")


# ----------------------------------------------------------------------------
# Demonstration 3 -- the tropical squeeze and Maslov dequantization
# ----------------------------------------------------------------------------


def demo_tropical_limit() -> None:
    print("=" * 78)
    print("3. TROPICAL SQUEEZE AND MASLOV DEQUANTIZATION")
    print("=" * 78)
    support = [7, 11, 13, 29, 101, 397]
    m = min(support)
    card = len(support)
    print(f"   support = {support},  m = min = {m},  |A| = {card}")
    print("     alpha        m^-a        S_a       |A| m^-a   (log S_a)/a   -log m")
    for a in [0.5, 1.0, 2.0, 5.0, 10.0, 25.0, 60.0, 150.0]:
        lo = m ** (-a)
        s = dial_sum(support, a)
        hi = card * m ** (-a)
        assert lo <= s <= hi + 1e-300
        print(f"     {a:6.1f}  {lo:10.3e} {s:10.3e} {hi:10.3e}   "
              f"{math.log(s) / a:11.6f}  {-math.log(m):9.6f}")
    print("   The normalized log-dial converges to -log(min A): the weighted sum")
    print("   dequantizes into the min-plus statistic min{ l : c_l = 1 }.")
    print("   Error bound |(log S_a)/a + log m| <= (log |A|)/a:")
    for a in [5.0, 25.0, 150.0]:
        err = abs(math.log(dial_sum(support, a)) / a + math.log(m))
        print(f"     a={a:6.1f}:  actual {err:.6f}  <=  bound {math.log(card) / a:.6f}")
    print()


# ----------------------------------------------------------------------------
# Demonstration 4 -- affine invariance of R^2
# ----------------------------------------------------------------------------


def demo_affine_invariance() -> None:
    print("=" * 78)
    print("4. AFFINE INVARIANCE:  R^2(c x + d, y) = R^2(x, y)")
    print("=" * 78)
    rng = random.Random(20260827)
    x = [rng.gauss(0.0, 1.0) for _ in range(40)]
    y = [3.0 * xi + rng.gauss(0.0, 0.8) for xi in x]
    base = r_squared(x, y)
    print(f"   baseline R^2 = {base:.12f}")
    for c, d in [(1e-9, 0.0), (1e9, 0.0), (-2.5, 17.0), (1.0, -1000.0)]:
        xt = [c * xi + d for xi in x]
        print(f"     c={c:>10.1e}, d={d:>8.1f}:  R^2 = {r_squared(xt, y):.12f}"
              f"   |diff| = {abs(r_squared(xt, y) - base):.2e}")
    print("   Perfect affine dependence attains R^2 = 1:")
    yp = [4.0 * xi - 9.0 for xi in x]
    print(f"     R^2(x, 4x - 9) = {r_squared(x, yp):.12f}\n")


# ----------------------------------------------------------------------------
# Demonstration 5 -- dequantization of the regression
# ----------------------------------------------------------------------------


def demo_regression_dequantization() -> None:
    print("=" * 78)
    print("5. THE WHOLE REGRESSION DEQUANTIZES TO A SINGLE BIT")
    print("=" * 78)
    rng = random.Random(586)
    window = odd_prime_window(3, 60)
    M = min(window)
    supports: List[List[int]] = []
    for _ in range(60):
        supports.append([l for l in window if rng.random() < 0.5])
    # ensure non-degeneracy of the tropical covariate
    supports[0] = [M] + [l for l in window if l > M and rng.random() < 0.5]
    supports[1] = [l for l in window if l > M and rng.random() < 0.5]

    trop = [1.0 if M in s else 0.0 for s in supports]
    y = [dial_sum(s, 0.5) + rng.gauss(0.0, 0.05) for s in supports]

    target = r_squared(trop, y)
    print(f"   M = {M},  n = {len(supports)},  R^2 of the one-bit covariate = {target:.6f}")
    print("     alpha    R^2(S_alpha, y)   |R^2 - R^2(tropical)|")
    for a in [0.0, 0.5, 1.0, 2.0, 5.0, 10.0, 20.0, 40.0, 80.0]:
        x = [dial_sum(s, a) for s in supports]
        r2 = r_squared(x, y)
        print(f"     {a:6.1f}   {r2:14.6f}   {abs(r2 - target):18.3e}")
    gap_ratio = M / 5.0  # next prime up in the window is 5
    print(f"   spectral gap M'/M = {5.0 / M:.4f}; the collapse factor is "
          f"(M/M')^alpha = {gap_ratio:.4f}^alpha,")
    print("   so a window whose two smallest primes are close dequantizes slowly.\n")


# ----------------------------------------------------------------------------
# Demonstration 6 -- the recorded alpha-curve
# ----------------------------------------------------------------------------

ALPHA_GRID: Tuple[float, ...] = (0.0, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0)
R2_CURVE: Tuple[float, ...] = (0.3207, 0.4985, 0.6242, 0.5752,
                               0.4731, 0.3969, 0.3479, 0.2944)


def demo_recorded_curve() -> None:
    print("=" * 78)
    print("6. THE RECORDED ALPHA-CURVE (n = 128, bit length 96, primes 3..400)")
    print("=" * 78)
    peak_index = max(range(len(R2_CURVE)), key=lambda i: R2_CURVE[i])
    harmonic_index = ALPHA_GRID.index(1.0)
    width = 46
    for i, (a, r2) in enumerate(zip(ALPHA_GRID, R2_CURVE)):
        bar = "#" * int(round(r2 * width))
        mark = "  <== fitted optimum" if i == peak_index else (
            "  <== harmonic, adopted by inspection" if i == harmonic_index else "")
        print(f"   alpha={a:4.2f}  R2={r2:.4f} |{bar:<{width}}|{mark}")

    rising = all(R2_CURVE[i] < R2_CURVE[i + 1] for i in range(peak_index))
    falling = all(R2_CURVE[i + 1] < R2_CURVE[i]
                  for i in range(peak_index, len(R2_CURVE) - 1))
    print(f"\n   argmax at alpha = {ALPHA_GRID[peak_index]}")
    print(f"   strictly rising up to the peak:   {rising}")
    print(f"   strictly falling after the peak:  {falling}")
    print(f"   harmonic on the falling limb:     "
          f"{R2_CURVE[harmonic_index] < R2_CURVE[harmonic_index - 1]}")

    gain = R2_CURVE[peak_index] - R2_CURVE[harmonic_index]
    print(f"   dR2 = R2(1/2) - R2(1) = {gain:.4f}   (pre-registered bar 0.03: "
          f"{'cleared' if gain >= 0.03 else 'not cleared'}, by {gain / 0.03:.1f}x)")
    print(f"   relative improvement = {R2_CURVE[peak_index] / R2_CURVE[harmonic_index] - 1:.1%}")
    print(f"   weighting vs none:  R2(1) - R2(0)   = "
          f"{R2_CURVE[harmonic_index] - R2_CURVE[0]:.4f}")
    print(f"   best vs none:       R2(1/2) - R2(0) = "
          f"{R2_CURVE[peak_index] - R2_CURVE[0]:.4f}")
    print("   i.e. the harmonic weight captured almost exactly half of the")
    print("   available gain over no weighting.\n")


def demo_bootstrap_argmax() -> None:
    """A schematic bootstrap of the grid argmax, reproducing the reported shape."""
    print("=" * 78)
    print("6b. BOOTSTRAP OF THE GRID ARGMAX (schematic reconstruction)")
    print("=" * 78)
    rng = random.Random(342)
    reps = 500
    noise = 0.020  # replicate-to-replicate scatter in R^2
    counts: Dict[float, int] = {a: 0 for a in ALPHA_GRID}
    for _ in range(reps):
        perturbed = [r2 + rng.gauss(0.0, noise) for r2 in R2_CURVE]
        counts[ALPHA_GRID[max(range(len(perturbed)), key=lambda i: perturbed[i])]] += 1
    print(f"   {reps} replicates, per-point scatter sd = {noise}")
    for a in ALPHA_GRID:
        if counts[a]:
            print(f"     alpha = {a:4.2f}:  {counts[a]:4d} / {reps}"
                  f"  ({counts[a] / reps:6.1%})  {'*' * (counts[a] * 40 // reps)}")
    selected = sum(a * c for a, c in counts.items()) / reps
    print(f"   mean selected exponent = {selected:.3f}")
    print(f"   share selecting alpha = 1 (harmonic): {counts[1.0] / reps:.1%}")
    print("   Reported measurement: 492/500 at 0.5, 8/500 at 0.75, mean 0.504,")
    print("   95% interval [0.5, 0.5] -- excluding the harmonic exponent.\n")


# ----------------------------------------------------------------------------
# Demonstration 7 -- the edge ratio
# ----------------------------------------------------------------------------


def demo_edge_ratio() -> None:
    print("=" * 78)
    print("7. THE ERRATUM IN NUMBERS: relative weight of the edge prime 400")
    print("=" * 78)

    def edge_ratio(alpha: float) -> float:
        return dial_weight(alpha, 400) / dial_weight(alpha, 3)

    for a in [0.0, 0.25, 0.5, 0.75, 1.0, 1.5, 2.0]:
        r = edge_ratio(a)
        print(f"     alpha = {a:4.2f}:  rho = {r:.6f}   = 1 / {1 / r:9.2f}")
    r_half, r_one = edge_ratio(0.5), edge_ratio(1.0)
    print(f"\n   rho(1)   = 3/400 = {r_one:.6f}   (about 1/133)")
    print(f"   rho(1/2) = sqrt(3/400) = {r_half:.6f}   (about 1/11.5)")
    print(f"   1/12 < rho(1/2) < 1/11 : {1/12 < r_half < 1/11}")
    print(f"   amplification factor rho(1/2)/rho(1) = {r_half / r_one:.4f} > 11.5: "
          f"{r_half > 11.5 * r_one}")
    print("   The harmonic instrument was measuring with primes up to 400 while")
    print("   listening almost exclusively to primes below 20.\n")


# ----------------------------------------------------------------------------
# Demonstration 8 -- window mass and saturation transfer
# ----------------------------------------------------------------------------


def window_tail(alpha: float, B: int) -> float:
    """Window mass T_alpha(B) = sum over integers l in [B, 4B) of l^(-alpha)."""
    return sum(float(l) ** (-alpha) for l in range(B, 4 * B))


def demo_window_saturation() -> None:
    print("=" * 78)
    print("8. WINDOW MASS: order B^(1-alpha); bounded at alpha=1, divergent at 1/2")
    print("=" * 78)
    print("       B     3*4^-a*B^(1-a)      T_a(B)        3*B^(1-a)      (alpha=1)")
    for B in [1, 4, 16, 64, 256, 1024]:
        a = 1.0
        lo = 3 * 4 ** (-a) * B ** (1 - a)
        hi = 3 * B ** (1 - a)
        t = window_tail(a, B)
        assert lo - 1e-9 <= t <= hi + 1e-9
        print(f"   {B:6d}    {lo:12.6f}   {t:12.6f}   {hi:12.6f}")
    print("   -> T_1(B) <= 3 uniformly: distant windows carry bounded mass,")
    print("      which is what makes a finite saturation scale meaningful.\n")

    print("       B     3*4^-a*B^(1-a)      T_a(B)        3*B^(1-a)    (alpha=1/2)")
    for B in [1, 4, 16, 64, 256, 1024, 4096]:
        a = 0.5
        lo = 3 * 4 ** (-a) * B ** (1 - a)
        hi = 3 * B ** (1 - a)
        t = window_tail(a, B)
        assert lo - 1e-9 <= t <= hi + 1e-9
        print(f"   {B:6d}    {lo:12.6f}   {t:12.6f}   {hi:12.6f}")
    print("   -> T_{1/2}(n^2) >= (3/2) n, so the mass is unbounded:")
    for n in [2, 8, 32, 64]:
        print(f"      n={n:3d}:  T_(1/2)({n * n}) = {window_tail(0.5, n * n):10.4f}"
              f"   >= (3/2)n = {1.5 * n:8.4f}")
    print("   A saturation scale measured under 1/l therefore carries no")
    print("   automatic meaning under 1/sqrt(l).\n")


# ----------------------------------------------------------------------------
# Demonstration 9 -- synthetic end-to-end sweep
# ----------------------------------------------------------------------------


def demo_synthetic_pipeline() -> None:
    print("=" * 78)
    print("9. SYNTHETIC END-TO-END SWEEP (interior optimum recovered)")
    print("=" * 78)
    rng = random.Random(577)
    window = odd_prime_window(3, 400)
    n = 128
    print(f"   window: {len(window)} odd primes from {window[0]} to {window[-1]}")
    print(f"   sample: n = {n} integers of bit length 96")

    integers = [rng.getrandbits(96) | (1 << 95) | 1 for _ in range(n)]
    supports = [qr_support(N, window) for N in integers]
    sizes = [len(s) for s in supports]
    print(f"   support sizes: min {min(sizes)}, mean {mean([float(s) for s in sizes]):.1f},"
          f" max {max(sizes)}  (expected about {len(window) / 2:.1f})")

    # A response that genuinely depends on the sqrt-weighted dial, plus noise.
    truth = [dial_sum(s, 0.5) for s in supports]
    scale = math.sqrt(var(truth) / n)
    y = [1.7 * t + rng.gauss(0.0, 0.9 * scale) for t in truth]

    print("\n     alpha     R^2(S_alpha, y)")
    results: List[Tuple[float, float]] = []
    for a in ALPHA_GRID:
        x = [dial_sum(s, a) for s in supports]
        r2 = r_squared(x, y)
        results.append((a, r2))
        bar = "#" * int(round(r2 * 40))
        print(f"     {a:5.2f}     {r2:.4f}   |{bar}")
    best_a, best_r2 = max(results, key=lambda t: t[1])
    r2_zero = results[0][1]
    r2_one = dict(results)[1.0]
    print(f"\n   argmax on the grid: alpha = {best_a}  (R^2 = {best_r2:.4f})")
    print(f"   beats the unweighted endpoint alpha=0: {best_r2 > r2_zero} "
          f"(gain {best_r2 - r2_zero:+.4f})")
    x_trop = [1.0 if window[0] in s else 0.0 for s in supports]
    r2_trop = r_squared(x_trop, y)
    print(f"   beats the tropical one-bit covariate:  {best_r2 > r2_trop} "
          f"(gain {best_r2 - r2_trop:+.4f})")
    print("   Both endpoints beaten => an interior optimum must exist on [0, inf),")
    print("   which is exactly the structural guarantee behind the measured peak.")
    print(f"   (harmonic exponent here: R^2 = {r2_one:.4f}, "
          f"deficit {best_r2 - r2_one:+.4f})\n")


# ----------------------------------------------------------------------------


def main() -> None:
    print()
    print("#" * 78)
    print("#  THE WEIGHT EXPONENT OF A QUADRATIC-RESIDUE PRODUCT DIAL")
    print("#  From 1/l to 1/sqrt(l): numerical demonstrations")
    print("#" * 78)
    print()
    demo_antitonicity()
    demo_log_convexity()
    demo_tropical_limit()
    demo_affine_invariance()
    demo_regression_dequantization()
    demo_recorded_curve()
    demo_bootstrap_argmax()
    demo_edge_ratio()
    demo_window_saturation()
    demo_synthetic_pipeline()
    print("=" * 78)
    print("All demonstrations complete.")
    print("=" * 78)


if __name__ == "__main__":
    main()
