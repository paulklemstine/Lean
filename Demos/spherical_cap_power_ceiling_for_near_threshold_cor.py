"""
Spherical-Cap Power Ceiling for Near-Threshold Correlation Tests
================================================================

Numerical demonstration of the geometry of near-threshold hypothesis testing.

Setting.  A predictor u in R^n is compared with a response w through the
scale-invariant summary

    corr(u, w) = <u, w> / (||u|| ||w||),

so the experiment sees u only through its direction  u_hat = u / ||u||, a point
on the unit sphere.  Two competing hypotheses -- "the dial reads 0.558" and
"the dial sits exactly on the pre-registered floor 0.550" -- are realised by two
directions u_hat, v_hat.

The results demonstrated here:

  1. Chordal identity          ||u_hat - v_hat||^2 = 2 - 2 corr(u, v)
  2. Cap bound                 corr >= 1 - eps  ==>  chord <= sqrt(2 eps)
  3. Angular form              arccos(c) <= (pi/2) sqrt(2 - 2c)
  4. Power ceiling             |F(u_hat) - F(v_hat)| <= L sqrt(2 eps)
                               for every L-Lipschitz-on-the-sphere F --
                               NO dependence on the sample size n
  5. Replication invariance    corr(rep_m u, rep_m v) = corr(u, v) exactly
  6. Sharpness                 F(x) = L ||x - v_hat||  attains the ceiling
  7. Alignment window          a margin delta caps alignment at 1 - delta^2/2
  8. Optimal smooth test       correlation against the contrast direction
                               (u_hat - v_hat)/||u_hat - v_hat|| separates the
                               hypotheses by exactly the chordal distance,
                               which is the maximum over the smooth class
  9. Cap capacity              at most floor(L sqrt(2 eps) / delta) resolvable
                               rungs fit inside the cap; here exactly one
 10. The discontinuous escape  a threshold statistic separates the same
                               configuration by 1 and is Lipschitz for no L

Run with:  python3 demo.py
Requires only the standard library.
"""

from __future__ import annotations

import math
from typing import Callable, List, Sequence, Tuple

Vector = Sequence[float]

# ----------------------------------------------------------------------------
# 0.  Euclidean primitives
# ----------------------------------------------------------------------------


def dot(u: Vector, v: Vector) -> float:
    """Standard inner product <u, v> = sum_i u_i v_i."""
    return sum(a * b for a, b in zip(u, v))


def norm(u: Vector) -> float:
    """Euclidean norm ||u|| = sqrt(<u, u>)."""
    return math.sqrt(dot(u, u))


def normalise(u: Vector) -> List[float]:
    """The direction u_hat = u / ||u|| (the zero vector is returned unchanged)."""
    n = norm(u)
    if n == 0.0:
        return list(u)
    return [x / n for x in u]


def corr(u: Vector, v: Vector) -> float:
    """Scale-invariant correlation <u, v> / (||u|| ||v||)."""
    return dot(u, v) / (norm(u) * norm(v))


def chord(u: Vector, v: Vector) -> float:
    """Chordal distance ||u_hat - v_hat|| between the two directions."""
    uh, vh = normalise(u), normalise(v)
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(uh, vh)))


def replicate(u: Vector, m: int) -> List[float]:
    """rep_m(u): the concatenation of m copies of u, modelling m replications."""
    return [x for _ in range(m) for x in u]


# ----------------------------------------------------------------------------
# 1.  The reference configuration (R)
# ----------------------------------------------------------------------------

READING_CROSSED: float = 0.558      # pooled reading of the "crossed" hypothesis
READING_FLOOR: float = 0.550        # pre-registered floor, "not crossed"
MARGIN: float = round(READING_CROSSED - READING_FLOOR, 12)   # delta = 0.008
EPS: float = 1.0e-4                 # alignment slack: corr(u, v) >= 1 - eps


def reference_configuration() -> Tuple[List[float], List[float], List[float]]:
    """Construct u, v, w in R^2 realising the two recorded readings.

    Both predictors are placed on the same side of the response w = (1, 0) at the
    angles forced by their readings, which makes them maximally aligned with each
    other:  corr(u, w) = 0.558, corr(v, w) = 0.550, corr(u, v) >= 0.9999.
    """
    w: List[float] = [1.0, 0.0]
    angle_u: float = math.acos(READING_CROSSED)
    angle_v: float = math.acos(READING_FLOOR)
    u: List[float] = [math.cos(angle_u), math.sin(angle_u)]
    v: List[float] = [math.cos(angle_v), math.sin(angle_v)]
    return u, v, w


# ----------------------------------------------------------------------------
# 2.  Statistics
# ----------------------------------------------------------------------------


def correlation_statistic(w: Vector) -> Callable[[Vector], float]:
    """x |-> corr(x, w).  Exactly 1-Lipschitz on the unit sphere (Cauchy-Schwarz)."""
    return lambda x: corr(x, w)


def distance_statistic(reference: Vector, L: float) -> Callable[[Vector], float]:
    """x |-> L ||x - reference||.  Globally L-Lipschitz; attains the ceiling."""
    ref = list(reference)
    return lambda x: L * math.sqrt(sum((a - b) ** 2 for a, b in zip(x, ref)))


def contrast_direction(u: Vector, v: Vector) -> List[float]:
    """e = (u_hat - v_hat) / ||u_hat - v_hat||, the optimal smooth test direction."""
    uh, vh = normalise(u), normalise(v)
    d = [a - b for a, b in zip(uh, vh)]
    nd = norm(d)
    if nd == 0.0:
        raise ValueError("the two hypotheses coincide: no smooth test separates them")
    return [x / nd for x in d]


def threshold_statistic(w: Vector, t: float) -> Callable[[Vector], float]:
    """The discontinuous rank/threshold rule: 1 if corr(x, w) >= t, else 0."""
    return lambda x: 1.0 if corr(x, w) >= t else 0.0


def separation(F: Callable[[Vector], float], u: Vector, v: Vector) -> float:
    """|F(u_hat) - F(v_hat)|: what the statistic can see between the hypotheses."""
    return abs(F(normalise(u)) - F(normalise(v)))


# ----------------------------------------------------------------------------
# 3.  Diagnostics derived from the theory
# ----------------------------------------------------------------------------


def cap_radius(eps: float) -> float:
    """Chordal radius sqrt(2 eps) of a cap of alignment 1 - eps."""
    return math.sqrt(2.0 * eps)


def power_ceiling(L: float, eps: float) -> float:
    """The sample-size-free ceiling L sqrt(2 eps)."""
    return L * cap_radius(eps)


def lipschitz_needed(delta: float, eps: float) -> float:
    """Sensitivity required for a separation delta inside an eps-cap."""
    return delta / cap_radius(eps)


def alignment_ceiling(delta: float) -> float:
    """A recorded margin delta caps the mutual alignment at 1 - delta^2 / 2."""
    return 1.0 - delta * delta / 2.0


def cap_capacity(L: float, eps: float, delta: float) -> int:
    """Largest number of monotone rungs an L-Lipschitz statistic resolves in the cap."""
    return int(math.floor(power_ceiling(L, eps) / delta))


# ----------------------------------------------------------------------------
# 4.  Demonstrations
# ----------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_1_chordal_geometry() -> None:
    banner("1.  Chordal geometry of the correlation cap")
    u, v, w = reference_configuration()
    c = corr(u, v)
    print(f"  corr(u, w)               = {corr(u, w):.6f}   (crossed reading)")
    print(f"  corr(v, w)               = {corr(v, w):.6f}   (floor)")
    print(f"  recorded margin delta    = {MARGIN:.6f}")
    print(f"  mutual alignment corr(u,v) = {c:.9f}")
    print()
    print("  Chordal identity  ||u_hat - v_hat||^2 = 2 - 2 corr(u, v):")
    print(f"    left  side  = {chord(u, v) ** 2:.12e}")
    print(f"    right side  = {2 - 2 * c:.12e}")
    print(f"    discrepancy = {abs(chord(u, v) ** 2 - (2 - 2 * c)):.3e}")
    print()
    theta = math.acos(c)
    print(f"  chordal distance         = {chord(u, v):.8f}")
    print(f"  angular distance         = {theta:.8f} rad = {math.degrees(theta):.5f} deg")
    print(f"  Jordan bound (pi/2)*chord= {math.pi / 2 * chord(u, v):.8f} rad  (>= angle: "
          f"{math.pi / 2 * chord(u, v) >= theta})")
    print()
    print(f"  Cap of alignment 1 - {EPS:g}:")
    print(f"    chordal radius sqrt(2 eps) = {cap_radius(EPS):.8f}  ( = sqrt(2)/100 )")
    ang = math.acos(1 - EPS)
    print(f"    angular radius arccos(1-eps) = {ang:.8f} rad = {math.degrees(ang):.5f} deg")
    print(f"    below 0.9 degrees?          {math.degrees(ang) < 0.9}")
    print(f"    is the configuration inside the cap?  chord <= radius: "
          f"{chord(u, v) <= cap_radius(EPS)}")


def demo_2_power_ceiling() -> None:
    banner("2.  The sample-size-free power ceiling")
    u, v, w = reference_configuration()
    print("  Ceiling  |F(u_hat) - F(v_hat)| <= L sqrt(2 eps)  for eps = 1e-4:")
    for L in (0.5, 1.0, 2.0, 10.0, 70.71):
        print(f"    L = {L:6.2f}   ceiling = {power_ceiling(L, EPS):.6f}")
    print()
    print("  Sensitivity required for a given separation:")
    for delta in (MARGIN, 0.05, 0.5, 1.0):
        print(f"    delta = {delta:5.3f}   L >= {lipschitz_needed(delta, EPS):9.4f}")
    print()
    print("  A full verdict (separation 1) demands L >= 70.71: a statistic that moves")
    print("  seventy units per unit of movement on the sphere.")
    print()
    print("  Actual separations achieved on the configuration:")
    F_corr = correlation_statistic(normalise(w))
    print(f"    response correlation      : {separation(F_corr, u, v):.8f}")
    e = contrast_direction(u, v)
    F_contrast = correlation_statistic(e)
    print(f"    contrast correlation      : {separation(F_contrast, u, v):.8f}")
    F_dist = distance_statistic(normalise(v), 1.0)
    print(f"    distance statistic (L=1)  : {separation(F_dist, u, v):.8f}")
    print(f"    ceiling at L = 1          : {power_ceiling(1.0, EPS):.8f}")


def demo_3_replication() -> None:
    banner("3.  Replication does not help")
    u, v, _ = reference_configuration()
    base = corr(u, v)
    print("  m-fold replication multiplies <.,.> by m and each norm by sqrt(m);")
    print("  the factors cancel exactly, so correlation and chord are invariant.")
    print()
    print(f"  {'m':>8} {'dimension':>10} {'corr(rep u, rep v)':>22} {'chord':>14} "
          f"{'ceiling (L=1)':>15}")
    for m in (1, 2, 5, 50, 1000, 100000):
        ru, rv = replicate(u, m), replicate(v, m)
        print(f"  {m:>8} {2 * m:>10} {corr(ru, rv):>22.15f} {chord(ru, rv):>14.10f} "
              f"{power_ceiling(1.0, EPS):>15.10f}")
    print()
    print(f"  Maximum deviation from the unreplicated alignment {base:.15f}: "
          f"{max(abs(corr(replicate(u, m), replicate(v, m)) - base) for m in (2, 5, 50, 1000)):.3e}")
    print("  Increasing the sample size buys no resolution for a smooth statistic.")


def demo_4_sharpness() -> None:
    banner("4.  The ceiling is sharp, and the class is non-vacuous")
    u, v, w = reference_configuration()
    print("  (a) The distance statistic F(x) = L ||x - v_hat|| is exactly L-Lipschitz")
    print("      and attains the ceiling L * chord(u, v):")
    for L in (0.5, 1.0, 3.0):
        F = distance_statistic(normalise(v), L)
        got, want = separation(F, u, v), L * chord(u, v)
        print(f"      L = {L:4.1f}   achieved = {got:.10f}   L*chord = {want:.10f}   "
              f"match = {abs(got - want) < 1e-12}")
    print()
    print("  (b) Correlation against a unit response is 1-Lipschitz on the sphere;")
    print("      a random sample of unit-vector pairs never violates the inequality:")
    F = correlation_statistic(normalise(w))
    worst = 0.0
    steps = 400
    for i in range(steps):
        for j in range(steps // 8):
            a, b = 2 * math.pi * i / steps, 2 * math.pi * j * 8 / steps
            x, y = [math.cos(a), math.sin(a)], [math.cos(b), math.sin(b)]
            d = math.hypot(x[0] - y[0], x[1] - y[1])
            if d > 0:
                worst = max(worst, abs(F(x) - F(y)) / d)
    print(f"      largest observed |F(x) - F(y)| / ||x - y|| = {worst:.10f}  (<= 1: {worst <= 1 + 1e-12})")


def demo_5_alignment_window() -> None:
    banner("5.  The alignment window forced by the recorded margin")
    u, v, w = reference_configuration()
    print(f"  A reading gap delta forces chord >= delta, hence corr(u, v) <= 1 - delta^2/2.")
    print(f"    recorded margin delta        = {MARGIN:.6f}")
    print(f"    |corr(u,w) - corr(v,w)|      = {abs(corr(u, w) - corr(v, w)):.10f}")
    print(f"    chord(u, v)                  = {chord(u, v):.10f}   (>= delta: "
          f"{chord(u, v) >= MARGIN - 1e-12})")
    print(f"    alignment ceiling 1 - d^2/2  = {alignment_ceiling(MARGIN):.9f}")
    print(f"    attained alignment           = {corr(u, v):.9f}")
    print()
    print("  So every realisation of the two readings has")
    print(f"      0.999900 <= corr(u, v) <= {alignment_ceiling(MARGIN):.6f},")
    print(f"  a window of width {alignment_ceiling(MARGIN) - 0.9999:.3e}.")


def demo_6_optimal_smooth_test() -> None:
    banner("6.  The optimal smooth test: correlation against the contrast direction")
    u, v, w = reference_configuration()
    e = contrast_direction(u, v)
    F_e = correlation_statistic(e)
    F_w = correlation_statistic(normalise(w))
    sep_e, sep_w = separation(F_e, u, v), separation(F_w, u, v)
    print(f"  contrast direction e = ({e[0]:+.6f}, {e[1]:+.6f}),  ||e|| = {norm(e):.12f}")
    print(f"  separation of the contrast test  = {sep_e:.10f}")
    print(f"  chordal distance                 = {chord(u, v):.10f}   (equal: "
          f"{abs(sep_e - chord(u, v)) < 1e-12})")
    print(f"  separation of the response test  = {sep_w:.10f}")
    print(f"  improvement factor               = {sep_e / sep_w:.6f}")
    print(f"  theoretical cap on improvement   = {cap_radius(EPS) / MARGIN:.6f}")
    print()
    print("  Optimality check: no 1-Lipschitz-on-the-sphere statistic can beat the chord.")
    print("  Sweeping every correlation direction on the circle:")
    best, best_angle = 0.0, 0.0
    for k in range(3600):
        a = 2 * math.pi * k / 3600
        s = separation(correlation_statistic([math.cos(a), math.sin(a)]), u, v)
        if s > best:
            best, best_angle = s, a
    contrast_angle = math.atan2(e[1], e[0]) % (2 * math.pi)
    print(f"    best separation over all directions = {best:.10f}")
    print(f"    chordal distance                    = {chord(u, v):.10f}")
    print(f"    maximising direction angle {best_angle:.5f} rad; contrast angle "
          f"{contrast_angle:.5f} rad")
    print("    (the two differ by pi: +e and -e give the same absolute separation)")


def demo_7_capacity() -> None:
    banner("7.  Cap capacity: how many rungs fit inside the cap")
    print("  A monotone ladder gaining delta per rung, with endpoints aligned at 1 - eps,")
    print("  satisfies  k * delta <= L sqrt(2 eps).")
    print()
    print(f"  {'L':>6} {'eps':>10} {'delta':>8} {'L sqrt(2 eps)':>15} {'k_max':>7}")
    for L, eps, delta in ((1.0, EPS, MARGIN), (1.0, EPS, 0.004), (1.0, EPS, 0.002),
                          (2.0, EPS, MARGIN), (1.0, 1e-3, MARGIN)):
        print(f"  {L:>6.1f} {eps:>10.0e} {delta:>8.4f} {power_ceiling(L, eps):>15.8f} "
              f"{cap_capacity(L, eps, delta):>7d}")
    print()
    u, v, w = reference_configuration()
    F = correlation_statistic(normalise(w))
    gain = F(normalise(u)) - F(normalise(v))
    print(f"  At the recorded instance the bound is k <= {cap_capacity(1.0, EPS, MARGIN)}, and one rung")
    print(f"  really is resolvable: the response correlation gains {gain:.6f} = the margin.")
    print("  Capacity of the cap: exactly one rung.")


def demo_8_holder() -> None:
    banner("8.  Holder statistics: softening continuity does not remove the ceiling")
    print("  |F(x) - F(y)| <= C ||x - y||^alpha  ==>  separation <= C (sqrt(2 eps))^alpha.")
    print()
    r = cap_radius(EPS)
    print(f"  {'alpha':>7} {'ceiling at C=1':>17} {'C needed for full separation':>32}")
    for alpha in (1.0, 0.75, 0.5, 0.25):
        print(f"  {alpha:>7.2f} {r ** alpha:>17.8f} {1.0 / r ** alpha:>32.4f}")
    print()
    print("  Smaller exponents buy a milder constant only by making the statistic more")
    print("  singular at small scales: resolution is always paid for in local instability.")


def demo_9_discontinuous_escape() -> None:
    banner("9.  The escape: a discontinuous threshold statistic")
    u, v, w = reference_configuration()
    t = 0.554
    F = threshold_statistic(normalise(w), t)
    print(f"  Threshold rule at t = {t} (the midpoint of the two readings):")
    print(f"    F(u_hat) = {F(normalise(u)):.1f}   [corr = {corr(u, w):.4f} >= t]")
    print(f"    F(v_hat) = {F(normalise(v)):.1f}   [corr = {corr(v, w):.4f} <  t]")
    print(f"    separation = {separation(F, u, v):.1f}  -- maximal, inside a 0.81-degree cap.")
    print()
    print("  No contradiction: the rule is Lipschitz for no constant.  For any candidate L")
    print("  we exhibit two unit vectors straddling the cut at distance < 1/L:")
    print()
    print(f"  {'candidate L':>13} {'||x - y||':>14} {'|F(x) - F(y)|':>15} {'L||x-y||':>12} "
          f"{'violated?':>11}")
    s = math.sqrt(1 - t * t)
    for L in (1.0, 10.0, 100.0, 1.0e4, 1.0e8):
        d = min(t / 2, 1.0 / (2 * (abs(L) + 1)))
        x = [t, s]                      # unit vector, corr(x, w) = t exactly
        y = [t - d, s]                  # corr(y, w) < t: the rule drops to 0
        gap = abs(F(x) - F(y))
        dist = math.hypot(x[0] - y[0], x[1] - y[1])
        print(f"  {L:>13.1e} {dist:>14.3e} {gap:>15.1f} {L * dist:>12.4f} "
              f"{str(gap > L * dist):>11}")
    print()
    print("  The verdict of the threshold rule flips under a perturbation of the predictor")
    print("  far smaller than the cap itself: sharpness is bought with brittleness.")


def demo_10_summary() -> None:
    banner("10.  Summary table for the recorded near-threshold instance")
    u, v, w = reference_configuration()
    e = contrast_direction(u, v)
    rows: List[Tuple[str, str]] = [
        ("recorded readings", f"{READING_CROSSED} vs {READING_FLOOR} (margin {MARGIN})"),
        ("attained alignment corr(u,v)", f"{corr(u, v):.9f}"),
        ("alignment ceiling 1 - d^2/2", f"{alignment_ceiling(MARGIN):.9f}"),
        ("chordal cap radius sqrt(2 eps)", f"{cap_radius(EPS):.8f}"),
        ("angular cap radius", f"{math.degrees(math.acos(1 - EPS)):.5f} deg  (< 0.9 deg)"),
        ("chord of the configuration", f"{chord(u, v):.8f}"),
        ("ceiling for L = 1", f"{power_ceiling(1.0, EPS):.8f}"),
        ("response-correlation separation", f"{separation(correlation_statistic(normalise(w)), u, v):.8f}"),
        ("contrast-correlation separation", f"{separation(correlation_statistic(e), u, v):.8f}"),
        ("max improvement factor", f"{cap_radius(EPS) / MARGIN:.4f}"),
        ("L needed for a full verdict", f"{lipschitz_needed(1.0, EPS):.4f}"),
        ("resolvable rungs in the cap", f"{cap_capacity(1.0, EPS, MARGIN)}"),
        ("threshold-statistic separation", "1  (Lipschitz constant: none finite)"),
    ]
    for name, value in rows:
        print(f"  {name:<34} {value}")
    print()
    print("  Bottom line: for any stable statistic the resolving power of this experiment")
    print("  is capped at 0.0141 regardless of how many times it is repeated; the only")
    print("  decisive tests available are discontinuous ones.")


def main() -> None:
    print(__doc__.split("Run with:")[0].rstrip())
    demo_1_chordal_geometry()
    demo_2_power_ceiling()
    demo_3_replication()
    demo_4_sharpness()
    demo_5_alignment_window()
    demo_6_optimal_smooth_test()
    demo_7_capacity()
    demo_8_holder()
    demo_9_discontinuous_escape()
    demo_10_summary()


if __name__ == "__main__":
    main()
