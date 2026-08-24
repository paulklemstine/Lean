"""
Equal-volume shell peelings of Euclidean balls: numerical demonstration.
=======================================================================

For a ball B(0,R) in R^d cut into N shells of equal volume, the k-th cutting
sphere has radius

    r_k = R * (1 - k/N)^(1/d),      k = 0, 1, ..., N,

and its depth below the surface is delta_k = R - r_k.  This script verifies,
numerically, every quantitative statement of the accompanying theory:

  1. Two-sided bound          R/(dN) <= delta_1 <= R/(d(N-1)).
  2. Exactness at d = 1       delta_1 = R/N.
  3. Monotonicity             d |-> d * delta_1 is increasing in d.
  4. Optimal constant         delta_1 <= R * Lambda / d, Lambda = log(N/(N-1)),
                              and Lambda = sup_d d * delta_1 / R.
  5. Strict improvement       Lambda < 1/(N-1).
  6. Rate of convergence      0 <= R*Lambda - d*delta_1 <= R*Lambda^2/(d+Lambda).
  7. Exact exponential profile delta_k = R (1 - exp(-tau_k)),
                              tau_k = -log(1 - k/N)/d.
  8. Limit profile            d * delta_k -> R log(N/(N-k)).
  9. Volume profile           (1 - u/d)^d -> exp(-u).
 10. Dichotomy                delta_1 -> 0 while r_{N-1} -> R.
 11. Analytic payoff          1/N <= log(N/(N-1)) <= 1/(N-1).

Everything is self-contained: only the standard library is used.

Numerical note.  For large d the quantity R - r_k suffers catastrophic
cancellation if computed by direct subtraction.  All depths below are computed
with the stable formula  R - r_k = -R * expm1(log1p(-k/N)/d).
"""

from __future__ import annotations

import math
from typing import List, Tuple


# ---------------------------------------------------------------------------
# Core quantities
# ---------------------------------------------------------------------------


def shell_radius(R: float, d: int, N: int, k: int) -> float:
    """Radius r_k = R (1 - k/N)^(1/d) of the k-th sphere of the peeling.

    Computed as R * exp(log1p(-k/N)/d) for numerical stability.
    """
    if not (0 <= k <= N):
        raise ValueError("require 0 <= k <= N")
    if d < 1:
        raise ValueError("require d >= 1")
    if k == N:
        return 0.0
    return R * math.exp(math.log1p(-k / N) / d)


def shell_depth(R: float, d: int, N: int, k: int) -> float:
    """Depth delta_k = R - r_k, computed without cancellation.

    delta_k = -R * expm1(log1p(-k/N)/d).
    """
    if not (0 <= k < N):
        raise ValueError("require 0 <= k < N")
    if d < 1:
        raise ValueError("require d >= 1")
    return -R * math.expm1(math.log1p(-k / N) / d)


def outer_thickness(R: float, d: int, N: int) -> float:
    """Thickness delta_1 of the outermost equal-volume shell."""
    return shell_depth(R, d, N, 1)


def optimal_constant(N: int) -> float:
    """Lambda = log(N/(N-1)), the optimal constant in delta_1 <= R*Lambda/d."""
    if N < 2:
        raise ValueError("require N >= 2")
    return math.log(N / (N - 1))


def rescaled_depth_param(d: int, N: int, k: int) -> float:
    """tau_k = -log(1 - k/N)/d, the rescaled depth parameter."""
    return -math.log1p(-k / N) / d


def volume_fraction_remaining(d: int, u: float) -> float:
    """Fraction (1 - u/d)^d of the ball left after peeling a layer of
    thickness R*u/d.  Requires u <= d."""
    if u > d:
        raise ValueError("require u <= d")
    return (1.0 - u / d) ** d


def certified_bracket(R: float, d: int, N: int) -> Tuple[float, float]:
    """A rigorous interval containing delta_1, from the two-sided bound, the
    optimal bound and the rate estimate."""
    lam = optimal_constant(N)
    lo_basic = R / (d * N)
    lo_rate = R * (lam - lam * lam / (d + lam)) / d
    hi_basic = R / (d * (N - 1))
    hi_opt = R * lam / d
    return (max(lo_basic, lo_rate), min(hi_basic, hi_opt))


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def demo_two_sided_bound(R: float = 1.0, N: int = 2) -> None:
    """Result 1, 4, 5: the sandwich and where the truth sits inside it."""
    lam = optimal_constant(N)
    print(f"\n[1] Two-sided bound and the optimal constant  (R={R}, N={N})")
    print(f"    Lambda = log(N/(N-1)) = {lam:.6f};  1/N = {1/N:.6f};  "
          f"1/(N-1) = {1/(N-1):.6f}")
    print(f"    {'d':>5} {'R/(dN)':>12} {'thickness':>12} {'R*Lam/d':>12} "
          f"{'R/(d(N-1))':>12}")
    for d in (1, 2, 3, 5, 10, 50, 100, 1000):
        th = outer_thickness(R, d, N)
        lo, opt, hi = R / (d * N), R * lam / d, R / (d * (N - 1))
        assert lo - 1e-15 <= th <= hi + 1e-15, "two-sided bound violated"
        assert th <= opt + 1e-15, "optimal bound violated"
        assert opt < hi, "strict improvement violated"
        print(f"    {d:>5} {lo:>12.8f} {th:>12.8f} {opt:>12.8f} {hi:>12.8f}")
    print("    all bounds verified (lower <= thickness <= optimal < elementary)")


def demo_dimension_one_exact(R: float = 3.0) -> None:
    """Result 2: in dimension one the thickness is exactly R/N."""
    print(f"\n[2] Exactness in dimension one  (R={R})")
    for N in (2, 3, 7, 10, 100):
        th = outer_thickness(R, 1, N)
        print(f"    N={N:>4}: thickness = {th:.12f},  R/N = {R/N:.12f},  "
              f"error = {abs(th - R/N):.2e}")
        assert abs(th - R / N) < 1e-12


def demo_monotonicity(R: float = 1.0, N: int = 2, D: int = 400) -> None:
    """Result 3, 4: d*thickness increases and its supremum is R*Lambda."""
    lam = optimal_constant(N)
    print(f"\n[3] Monotonicity of d * thickness  (R={R}, N={N}, d up to {D})")
    values: List[float] = [d * outer_thickness(R, d, N) for d in range(1, D + 1)]
    for a, b in zip(values, values[1:]):
        assert a <= b + 1e-14, "monotonicity violated"
    assert all(v <= R * lam + 1e-14 for v in values), "supremum violated"
    for d in (1, 2, 3, 5, 10, 25, 100, 400):
        v = values[d - 1]
        print(f"    d={d:>4}: d*thickness = {v:.8f}   "
              f"(R*Lambda - value = {R*lam - v:.8f})")
    print(f"    increasing, bounded above by R*Lambda = {R*lam:.8f}: verified")


def demo_rate(R: float = 1.0, N: int = 2) -> None:
    """Result 6: 0 <= R*Lambda - d*thickness <= R*Lambda^2/(d+Lambda)."""
    lam = optimal_constant(N)
    print(f"\n[4] Rate of convergence  (R={R}, N={N}, Lambda={lam:.6f})")
    print(f"    {'d':>6} {'true gap':>14} {'rate bound':>14} {'ratio':>8} "
          f"{'Lam^2/(2d)':>12}")
    for d in (1, 2, 5, 10, 100, 1000, 10000):
        gap = R * lam - d * outer_thickness(R, d, N)
        bound = R * lam * lam / (d + lam)
        assert -1e-14 <= gap <= bound + 1e-14, "rate bound violated"
        print(f"    {d:>6} {gap:>14.9f} {bound:>14.9f} {gap/bound:>8.4f} "
              f"{lam*lam/(2*d):>12.9f}")
    print("    gap always nonnegative and below the bound; "
          "true leading term Lambda^2/(2d)")


def demo_exact_exponential_profile(R: float = 1.0, d: int = 12, N: int = 8) -> None:
    """Result 7, 8: the depth profile is exactly R(1 - e^{-tau})."""
    print(f"\n[5] Exact exponential profile  (R={R}, d={d}, N={N})")
    print(f"    {'k':>3} {'r_k':>12} {'depth':>12} {'R(1-e^-tau)':>14} "
          f"{'d*depth':>12} {'R log(N/(N-k))':>16}")
    for k in range(1, N):
        r = shell_radius(R, d, N, k)
        dep = shell_depth(R, d, N, k)
        tau = rescaled_depth_param(d, N, k)
        prof = R * (1 - math.exp(-tau))
        lim = R * math.log(N / (N - k))
        assert abs(dep - prof) < 1e-12, "exponential profile identity failed"
        print(f"    {k:>3} {r:>12.8f} {dep:>12.8f} {prof:>14.8f} "
              f"{d*dep:>12.8f} {lim:>16.8f}")
    print("    depth == R(1 - exp(-tau)) to machine precision, for every k")

    print("    convergence of d*depth to the limit profile:")
    for dd in (10, 100, 1000, 100000):
        row = " ".join(f"{dd*shell_depth(R, dd, N, k):.6f}" for k in range(1, N))
        print(f"      d={dd:>7}: {row}")
    row = " ".join(f"{R*math.log(N/(N-k)):.6f}" for k in range(1, N))
    print(f"      limit    : {row}")


def demo_volume_profile(R: float = 1.0) -> None:
    """Result 9: peeling a layer of thickness R*u/d leaves fraction -> e^{-u}."""
    print(f"\n[6] Exponential volume profile: (1 - u/d)^d -> exp(-u)")
    print(f"    {'u':>5} " + " ".join(f"{'d='+str(d):>12}" for d in
                                      (10, 100, 1000, 100000))
          + f" {'exp(-u)':>12}")
    for u in (0.25, 0.5, 1.0, 2.0, 3.0):
        cells = " ".join(f"{volume_fraction_remaining(d, u):>12.8f}"
                         for d in (10, 100, 1000, 100000))
        print(f"    {u:>5.2f} {cells} {math.exp(-u):>12.8f}")
    print("    the rescaled distance to the boundary is asymptotically Exp(1)")


def demo_dichotomy(R: float = 1.0, N: int = 2) -> None:
    """Result 10: outer shell collapses, innermost shell fills the ball."""
    print(f"\n[7] Concentration dichotomy  (R={R}, N={N}); "
          f"both regions have volume fraction 1/N = {1/N}")
    print(f"    {'d':>6} {'outer thickness':>18} {'innermost radius r_{N-1}':>26}")
    for d in (1, 2, 5, 10, 100, 1000, 10000):
        outer = outer_thickness(R, d, N)
        inner = shell_radius(R, d, N, N - 1)
        print(f"    {d:>6} {outer:>18.10f} {inner:>26.10f}")
    print("    outer thickness -> 0 while the innermost radius -> R")


def demo_log_sandwich() -> None:
    """Result 11: the geometry forces 1/N <= log(N/(N-1)) <= 1/(N-1)."""
    print("\n[8] Analytic payoff: 1/N <= log(N/(N-1)) <= 1/(N-1)")
    print(f"    {'N':>6} {'1/N':>12} {'log(N/(N-1))':>16} {'1/(N-1)':>12}")
    for N in (2, 3, 5, 10, 100, 1000):
        lam = optimal_constant(N)
        assert 1 / N <= lam <= 1 / (N - 1) + 1e-15
        print(f"    {N:>6} {1/N:>12.8f} {lam:>16.8f} {1/(N-1):>12.8f}")
    print("    verified for every N tested")


def demo_certified_bracket(R: float = 1.0, N: int = 2) -> None:
    """Combining all bounds into the tightest rigorous interval."""
    print(f"\n[9] Certified bracket for the thickness  (R={R}, N={N})")
    print(f"    {'d':>6} {'lower':>14} {'true':>14} {'upper':>14} {'width':>12}")
    for d in (1, 2, 5, 10, 100, 1000):
        lo, hi = certified_bracket(R, d, N)
        th = outer_thickness(R, d, N)
        assert lo - 1e-14 <= th <= hi + 1e-14, "bracket does not contain truth"
        print(f"    {d:>6} {lo:>14.10f} {th:>14.10f} {hi:>14.10f} "
              f"{hi-lo:>12.3e}")
    print("    bracket width is O(1/d^2) once the rate bound takes over")


def demo_monte_carlo_radial_law(d: int = 200, samples: int = 200000,
                                seed: int = 20260824) -> None:
    """Sampling check: d(1 - ||X||) for X uniform on the unit ball of R^d
    is close to Exp(1).  Uses the radial CDF ||X|| = V^{1/d}, V uniform."""
    import random

    rng = random.Random(seed)
    print(f"\n[10] Monte Carlo: rescaled depth of a uniform point "
          f"(d={d}, {samples} samples)")
    draws = [d * (1.0 - rng.random() ** (1.0 / d)) for _ in range(samples)]
    mean = sum(draws) / samples
    var = sum((x - mean) ** 2 for x in draws) / samples
    print(f"    sample mean     = {mean:.5f}   (Exp(1) mean     = 1)")
    print(f"    sample variance = {var:.5f}   (Exp(1) variance = 1)")
    print(f"    {'u':>5} {'empirical P[U>u]':>20} {'(1-u/d)^d':>14} "
          f"{'exp(-u)':>12}")
    for u in (0.5, 1.0, 2.0, 3.0):
        emp = sum(1 for x in draws if x > u) / samples
        print(f"    {u:>5.2f} {emp:>20.6f} {volume_fraction_remaining(d, u):>14.6f} "
              f"{math.exp(-u):>12.6f}")


def main() -> None:
    print("=" * 78)
    print("Equal-volume shell peelings of Euclidean balls -- numerical evidence")
    print("=" * 78)
    demo_two_sided_bound()
    demo_dimension_one_exact()
    demo_monotonicity()
    demo_rate()
    demo_exact_exponential_profile()
    demo_volume_profile()
    demo_dichotomy()
    demo_log_sandwich()
    demo_certified_bracket()
    demo_monte_carlo_radial_law()
    print("\nAll assertions passed.")


if __name__ == "__main__":
    main()
