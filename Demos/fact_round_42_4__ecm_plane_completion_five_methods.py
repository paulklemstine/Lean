"""
Numerical demonstrations for the min-plus (tropical) theory of factoring cost
exponents and the Newton polygon of a benchmark.

Everything is self-contained: no third-party dependencies, no I/O beyond stdout.

Contents
--------
1.  Cost profiles, tropical product, races, crossover points.
2.  The corner criterion and the near-parallel window bound |k*| >= delta/eps.
3.  The measured five-arm plane of the experiment and its total order.
4.  The tropical line alpha = 1 - beta and the calibration bound B >= p^(1-a)/2.
5.  The batched-gcd quantisation dichotomy (erase vs preserve).
6.  Lower envelope, leader schedule, and the lower-convex-hull (Newton polygon)
    criterion: dead arms and the 2.515-bit threshold.
7.  The subexponential arm L(c, x) = exp(c sqrt(log x log log x)): fitted
    exponent -> 0, chord slope -> 0, eventual leader, log-work -> infinity.

Run with:  python3 demo.py
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from typing import Iterable, List, Optional, Sequence, Tuple

# ----------------------------------------------------------------------------
# 1. Cost profiles and the tropical (min-plus) plane
# ----------------------------------------------------------------------------


@dataclass(frozen=True)
class Profile:
    """A cost profile: bit-work(k) = icept + slope * k, with k = log2 p.

    Equivalently the tropical monomial  icept (*) k^(slope)  in (R, min, +).
    """

    name: str
    slope: float  # across-k exponent alpha
    icept: float  # common-currency intercept c, in bits

    def work(self, k: float) -> float:
        """Log-work in bits at target size k = log2 p."""
        return self.icept + self.slope * k


def tropical_mul(m: Profile, n: Profile, name: Optional[str] = None) -> Profile:
    """Composition of two arms: bit-costs add, so both coordinates add."""
    return Profile(name or f"{m.name}(*){n.name}", m.slope + n.slope, m.icept + n.icept)


def race(m: Profile, n: Profile, k: float) -> float:
    """Tropical addition: run both arms, keep the first to finish."""
    return min(m.work(k), n.work(k))


def crossover(m: Profile, n: Profile) -> Optional[float]:
    """Unique corner k* of a two-arm race, or None if the exponents agree."""
    if m.slope == n.slope:
        return None
    return (m.icept - n.icept) / (n.slope - m.slope)


def check_distributivity(m: Profile, n: Profile, p: Profile, k: float) -> bool:
    """min-plus distributivity: race(M,N)(k) + work(P,k) = race(M*P, N*P)(k)."""
    lhs = race(m, n, k) + p.work(k)
    rhs = race(tropical_mul(m, p), tropical_mul(n, p), k)
    return math.isclose(lhs, rhs, rel_tol=0.0, abs_tol=1e-12)


def corner_window_bound(eps: float, delta: float) -> float:
    """If |d alpha| <= eps and |d c| >= delta, any corner sits at |k*| >= delta/eps."""
    return delta / eps


# ----------------------------------------------------------------------------
# 3. The measured plane of the experiment
# ----------------------------------------------------------------------------

RHO_INTERCEPT = 0.0  # only intercept *differences* were measured; carry c freely
ECM50_OVERHEAD = 3.04  # bits, common currency
ECM_WALL_TIME_RATIO = 10.29  # x, measured


def measured_plane(c: float = RHO_INTERCEPT, d: float = ECM50_OVERHEAD) -> List[Profile]:
    """The five arms (six rows: trial division has two regimes)."""
    return [
        Profile("Fermat", 0.50, c),
        Profile("rho", 0.512, c),
        Profile("ECM(B1=250)", 0.718, c + d),
        Profile("ECM(B1=50)", 0.761, c + ECM50_OVERHEAD),
        Profile("TD uniform", 1.00, c),
        Profile("TD balanced", 1.14, c),
    ]


# ----------------------------------------------------------------------------
# 4. Where the exponent comes from: alpha = 1 - beta, and calibration
# ----------------------------------------------------------------------------


def ecm_work_lower_bound(p: float, B: float) -> float:
    """Point-operation lower bound p/(2B) to reach success probability 1/2."""
    return p / (2.0 * B)


def ecm_exponent_from_beta(beta: float) -> float:
    """The tropical line: stage-one bound B = p^beta gives work exponent 1 - beta."""
    return 1.0 - beta


def calibrated_bound(p: float, a: float) -> float:
    """A measured exponent a forces the stage-one bound B >= p^(1-a)/2."""
    return p ** (1.0 - a) / 2.0


# ----------------------------------------------------------------------------
# 5. The quantisation ledger
# ----------------------------------------------------------------------------


def batch(m: int, T: int) -> int:
    """Batched detection time: success is only observable at multiples of m."""
    return m * ((T + m - 1) // m)


def two_point_slope(k1: int, k2: int, t1: float, t2: float) -> float:
    """The chord slope actually fitted by the experiment, in bits per bit."""
    return (math.log2(t2) - math.log2(t1)) / (k2 - k1)


def quantisation_audit(m: int, T1: int, T2: int) -> str:
    """Which branch of the erase/preserve dichotomy applies."""
    lo, hi = min(T1, T2), max(T1, T2)
    if hi <= m:
        return "EXPONENT ERASED (both detections fit in one block)"
    if lo >= m:
        return "EXPONENT PRESERVED (ratio within a factor 2 of the truth)"
    return "MIXED REGIME (exponent unreliable)"


# ----------------------------------------------------------------------------
# 6. Envelope, leaders, and the Newton polygon
# ----------------------------------------------------------------------------


def envelope(family: Sequence[Profile], k: float) -> float:
    """Lower envelope: the cost of always running the currently best arm."""
    return min(arm.work(k) for arm in family)


def leader(family: Sequence[Profile], k: float) -> Profile:
    """An arm attaining the envelope at k."""
    return min(family, key=lambda arm: arm.work(k))


def leads_somewhere(family: Sequence[Profile], arm: Profile,
                    grid: Iterable[float]) -> bool:
    """Numerical check: does `arm` attain the envelope anywhere on the grid?"""
    return any(math.isclose(arm.work(k), envelope(family, k), abs_tol=1e-12)
               for k in grid)


def lower_hull(family: Sequence[Profile]) -> List[Profile]:
    """Arms that ever lead = vertices of the lower convex hull of (alpha, c).

    Monotone-chain sweep over the points sorted by exponent: an arm is popped
    when it lies on or above the segment joining its neighbours, which is
    exactly the Newton-polygon criterion for being a dead arm.  O(n log n),
    dominated by the sort.  The output is ordered by increasing exponent, i.e.
    by the order in which the arms take the lead as k grows (reversed).
    """
    pts = sorted(family, key=lambda a: (a.slope, a.icept))
    hull: List[Profile] = []
    for p in pts:
        while len(hull) >= 2:
            a, b = hull[-2], hull[-1]
            if (b.slope - a.slope) * (p.icept - a.icept) \
                    <= (p.slope - a.slope) * (b.icept - a.icept):
                hull.pop()
            else:
                break
        if hull and hull[-1].slope == p.slope:
            continue  # equal exponents: only the smallest intercept survives
        hull.append(p)
    return hull


def hull_threshold(m: Profile, n_slope: float, p: Profile) -> Tuple[float, float, float]:
    """Weights (t, s) writing n_slope on the segment [alpha_M, alpha_P], and the
    critical intercept t*c_M + s*c_P below which the middle arm is a hull vertex."""
    t = (n_slope - p.slope) / (m.slope - p.slope)
    s = 1.0 - t
    return t, s, t * m.icept + s * p.icept


# ----------------------------------------------------------------------------
# 7. The subexponential arm
# ----------------------------------------------------------------------------


def log_L(c: float, k: float) -> float:
    """Natural log of L(c, p) = exp(c sqrt(log p * log log p)), for p = 2^k.

    Parameterised by k = log2 p to stay in range for astronomically large p.
    """
    log_p = k * math.log(2.0)
    return c * math.sqrt(log_p * math.log(log_p))


def log2_L(c: float, k: float) -> float:
    """Bit-cost of the subexponential arm at target size k = log2 p."""
    return log_L(c, k) / math.log(2.0)


def subexp_fitted_exponent(c: float, k: float) -> float:
    """log L / log p, the fitted across-k exponent; tends to 0."""
    return log_L(c, k) / (k * math.log(2.0))


def subexp_chord_slope(c: float, k: float) -> float:
    """Two-point chord slope over the doubling window k -> 2k; tends to 0."""
    return (log_L(c, 2.0 * k) - log_L(c, k)) / (k * math.log(2.0))


# ----------------------------------------------------------------------------
# Reporting
# ----------------------------------------------------------------------------


def rule(title: str) -> None:
    print("\n" + "=" * 72)
    print(title)
    print("=" * 72)


def demo_tropical_algebra() -> None:
    rule("1. Tropical algebra of cost profiles")
    rho = Profile("rho", 0.512, 0.0)
    ecm = Profile("ECM(50)", 0.761, 3.04)
    post = Profile("post-step", 0.1, 2.0)

    print(f"{'k':>5} {'work(rho)':>11} {'work(ECM)':>11} {'race':>11}  leader")
    for k in (4, 8, 12, 16, 20, 24):
        print(f"{k:>5} {rho.work(k):>11.3f} {ecm.work(k):>11.3f} "
              f"{race(rho, ecm, k):>11.3f}  {leader([rho, ecm], k).name}")

    comp = tropical_mul(rho, post, "rho then post-step")
    print(f"\ncomposition is coordinatewise addition: {comp.name} = "
          f"(alpha={comp.slope:.3f}, c={comp.icept:.3f})")
    ok = all(check_distributivity(rho, ecm, post, k) for k in range(-10, 40))
    print(f"min-plus distributivity holds on k in [-10, 40): {ok}")


def demo_corner_criterion() -> None:
    rule("2. Corner criterion and the near-parallel window bound")
    td_u = Profile("TD uniform", 1.00, 5.0)
    td_b = Profile("TD balanced", 1.14, 3.0)
    rho_u = Profile("rho uniform", 0.512, 5.0)
    rho_b = Profile("rho balanced", 0.512, 6.5)

    print(f"trial division regimes 1.00 vs 1.14 -> corner at k* = "
          f"{crossover(td_u, td_b):.3f}   (corner locus NON-empty)")
    print(f"rho regimes 0.512 vs 0.512          -> corner: {crossover(rho_u, rho_b)}"
          "   (factor-local: corner locus EMPTY, race is again affine)")

    for eps, delta in ((0.03, 1.0), (0.03, 2.0), (0.01, 1.0)):
        print(f"  |d alpha| <= {eps}, |d c| >= {delta} bit(s)  =>  any hidden corner "
              f"has |k*| >= {corner_window_bound(eps, delta):.1f}")
    print("  the toy window is k ~ 16-20, so 'no corner' and 'corner beyond the")
    print("  horizon' are empirically indistinguishable -- as the bound quantifies.")


def demo_measured_plane() -> None:
    rule("3. The measured five-arm plane")
    plane = measured_plane()
    print(f"{'arm':<14}{'alpha':>8}{'intercept':>11}")
    for arm in plane:
        print(f"{arm.name:<14}{arm.slope:>8.3f}{arm.icept:>11.3f}")
    slopes = [a.slope for a in plane]
    print(f"\ntotally ordered by exponent: {slopes == sorted(slopes)}")
    print(f"H1 bracketing: 0.512 < 0.718 <= 0.761 < 1.00 -> "
          f"{0.512 < 0.718 <= 0.761 < 1.00}")

    lg = math.log2(ECM_WALL_TIME_RATIO)
    print(f"\nH3: common-currency gap = {ECM50_OVERHEAD} bits, "
          f"log2(wall-time ratio {ECM_WALL_TIME_RATIO}) = {lg:.3f} bits")
    print(f"    3 < log2(10.29) < 4 : {3 < lg < 4}   "
          f"(|gap - log2 ratio| = {abs(ECM50_OVERHEAD - lg):.3f} bits < 1)")


def demo_exponent_origin() -> None:
    rule("4. The tropical line alpha = 1 - beta, and calibration")
    print(f"{'beta':>6}{'alpha = 1-beta':>16}   interpretation")
    for beta, note in ((0.00, "trial division"), (0.239, "measured ECM(B1=50)"),
                       (0.282, "measured ECM(B1=250)"), (0.50, "birthday arms")):
        print(f"{beta:>6.3f}{ecm_exponent_from_beta(beta):>16.3f}   {note}")

    print("\nlower bound p/(2B) on point operations to reach success probability 1/2:")
    for k in (16, 20, 24):
        p = 2.0 ** k
        print(f"  k = {k:2d}, B1 = 50 : work >= {ecm_work_lower_bound(p, 50):>12.1f} "
              f"= 2^{math.log2(ecm_work_lower_bound(p, 50)):.2f}")

    print("\ncalibration B >= p^(1-a)/2 from a measured exponent a:")
    for k, a in ((20, 0.761), (20, 0.718), (32, 0.761)):
        p = 2.0 ** k
        b = calibrated_bound(p, a)
        print(f"  k = {k:2d}, a = {a}: B >= {b:8.2f}   "
              f"(consistent with B1 = 50: {b <= 50})")

    print("\ndrift law for a FIXED stage-one bound, alpha ~ 1 - log2(B1)/k:")
    for k in (18, 20, 32, 64):
        print(f"  B1 = 50, k = {k:2d}: predicted alpha ~ {1 - math.log2(50)/k:.3f}")


def demo_quantisation() -> None:
    rule("5. The batched-gcd quantisation dichotomy")
    T16, T20 = int(math.isqrt(2 ** 16)), int(math.isqrt(2 ** 20))
    print(f"true rho detection times: sqrt(2^16) = {T16}, sqrt(2^20) = {T20}")

    for m in (2048, 1):
        b16, b20 = batch(m, T16), batch(m, T20)
        slope = two_point_slope(16, 20, b16, b20)
        label = "batched (block m = 2048)" if m > 1 else "per-iteration gcd (m = 1)"
        print(f"\n{label}")
        print(f"  observed times: {b16} and {b20}")
        print(f"  fitted two-point slope: {slope:.4f}")
        print(f"  audit: {quantisation_audit(m, T16, T20)}")
    print("\n  the batched instrument reports exponent 0 although the true times")
    print("  differ by a factor 4; unbatched it reports exactly 1/2, matching the")
    print("  measured rho exponent 0.512.")

    print("\npreservation branch, m = 64 (both detections exceed the block):")
    b1, b2 = batch(64, T16), batch(64, T20)
    print(f"  ratio observed {b2/b1:.3f} vs true {T20/T16:.3f}; "
          f"within factor 2: {b2/b1 <= 2 * (T20/T16)}")


def demo_newton_polygon() -> None:
    rule("6. Envelope, leader schedule, and the Newton polygon")
    c, d = 0.0, ECM50_OVERHEAD
    family = [Profile("rho", 0.512, c),
              Profile("ECM(250)", 0.718, c + d),
              Profile("ECM(50)", 0.761, c + 3.04)]

    grid = [i * 0.25 for i in range(0, 161)]  # k in [0, 40]
    print("leaders on the physical range k in [0, 40]:")
    for arm in family:
        print(f"  {arm.name:<10} ever leads: {leads_somewhere(family, arm, grid)}")
    print("  => ECM(B1=50) is a DEAD ARM: larger exponent AND larger intercept")
    print("     than rho, so rho dominates it at every k >= 0.")

    rho, ecm50 = family[0], family[2]
    t, s, crit = hull_threshold(rho, 0.718, ecm50)
    print(f"\nexact collinearity of the measured exponents:")
    print(f"  t = {t:.6f} = 43/249 = {43/249:.6f},  s = {s:.6f} = 206/249 = "
          f"{206/249:.6f}")
    print(f"  t*0.512 + s*0.761 = {t*0.512 + s*0.761:.6f}  (target 0.718)")
    print(f"  43*0.512 + 206*0.761 = {43*0.512 + 206*0.761} = 249*0.718 = "
          f"{249*0.718}")
    print(f"\nhull threshold for the B1 = 250 column: d <= "
          f"{crit - c:.4f} bits  (= 3.04 * 206/249)")
    for dd in (2.0, 2.5, 2.5152, 3.04):
        verdict = "hull VERTEX (leads somewhere on R)" if dd <= crit - c + 1e-12 \
            else "ABOVE the hull: never leads, at any k"
        print(f"  overhead d = {dd:6.4f} bits -> {verdict}")

    print("\nphysical caveat: with d = 2.0 the hull witness sits at")
    fam2 = [Profile("rho", 0.512, 0.0), Profile("ECM(250)", 0.718, 2.0),
            Profile("ECM(50)", 0.761, 3.04)]
    kstar = crossover(fam2[0], fam2[2])
    print(f"  k* = {kstar:.3f} < 0  -- an unphysical (negative) target size.")
    print("  On k >= 0, domination (not hull membership) is the operative test.")

    print("\nleaderboard monotonicity check on a family with genuine turnover:")
    turnover = [Profile("fast-but-costly", 0.30, 12.0),
                Profile("middle", 0.60, 5.0),
                Profile("cheap-but-slow", 1.00, 0.0)]
    prev_slope, prev_icept, prev_name = None, None, None
    for k in range(0, 41, 4):
        ld = leader(turnover, k)
        if ld.name != prev_name:
            if prev_slope is not None:
                assert ld.slope <= prev_slope and ld.icept >= prev_icept
            print(f"  k = {k:2d}: leader becomes {ld.name:<16} "
                  f"(alpha = {ld.slope:.2f}, c = {ld.icept:.2f})")
            prev_slope, prev_icept, prev_name = ld.slope, ld.icept, ld.name
    print("  exponents decrease and intercepts increase along the leaderboard: OK")
    print(f"  hull vertices found by the sweep (increasing exponent): "
          f"{[a.name for a in lower_hull(turnover)]}")
    print(f"  hull vertices of the measured triple: "
          f"{[a.name for a in lower_hull(family)]}")

    print("\nconcavity of the envelope (a tropical polynomial in one variable):")
    x, y = 3.0, 33.0
    worst = min(envelope(turnover, t_*x + (1-t_)*y)
                - (t_*envelope(turnover, x) + (1-t_)*envelope(turnover, y))
                for t_ in [i/20 for i in range(21)])
    print(f"  min over convex combinations of (env(tx+sy) - t env(x) - s env(y)) "
          f"= {worst:.6f} >= 0")


def demo_subexponential() -> None:
    rule("7. The subexponential arm: the exponent that isn't there")
    c = 1.0
    print(f"{'log2 p':>9}{'fitted exponent':>18}{'chord slope':>14}{'log L':>12}")
    for k in (20, 50, 100, 200, 500, 1000, 10 ** 4, 10 ** 6, 10 ** 9):
        print(f"{k:>9}{subexp_fitted_exponent(c, k):>18.5f}"
              f"{subexp_chord_slope(c, k):>14.5f}{log_L(c, k):>12.3f}")
    print("\n  the fitted exponent and the two-point chord slope both tend to 0,")
    print("  yet log L diverges: the true cost sits strictly between 'exponent 0'")
    print("  and 'every positive exponent', a point the affine plane lacks.")

    print("\n  every positive-exponent arm is eventually beaten:")
    for arm in (Profile("rho", 0.512, 0.0), Profile("ECM(50)", 0.761, 3.04)):
        k_found = next(k for k in range(10, 2_000_000)
                       if log2_L(c, k) < arm.work(k))
        print(f"    L overtakes {arm.name:<9} at k >= {k_found}")


def main() -> None:
    demo_tropical_algebra()
    demo_corner_criterion()
    demo_measured_plane()
    demo_exponent_origin()
    demo_quantisation()
    demo_newton_polygon()
    demo_subexponential()
    print("\nAll demonstrations complete.\n")


if __name__ == "__main__":
    main()
