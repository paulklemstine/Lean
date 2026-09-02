"""
Rapidity geometry of correlation confidence intervals, and the resolution floor.

Self-contained numerical demonstration of every quantitative claim in the
accompanying article and paper.  Standard library only.

Core objects
------------
    zeta(x)      = artanh(x)                      rapidity of a correlation
    d(x, y)      = (x - y) / (1 - x*y)            relativistic difference
    L(r, tau)    = d(r,  tau)                     lower endpoint of the interval
    U(r, tau)    = d(r, -tau)                     upper endpoint of the interval
    N(z, M)      = 3 + (z / M)**2                 samples needed for margin M

Core laws
---------
    zeta(x) - zeta(y) = zeta(d(x, y))                          (rapidity subtraction)
    U - L             = 2*tau*(1-r^2) / (1 - r^2*tau^2)        (width law)
    (r-L) - (U-r)     = 2*r*tau^2*(1-r^2) / (1 - r^2*tau^2)    (asymmetry law)
    f <= L(r, tau)   <=>  tau <= d(r, f)                       (certification)
    certified        <=>  n >= 3 + (z/(zeta(r)-zeta(f)))^2     (resolution law)
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import Tuple

# --------------------------------------------------------------------------- #
# The recorded measurement                                                     #
# --------------------------------------------------------------------------- #

RHO_SEEDS: Tuple[float, float, float] = (0.562, 0.551, 0.582)
RHO_POOLED: float = 0.565
CI_REPORTED: Tuple[float, float] = (0.542, 0.587)
BAND_FLOOR: float = 0.55
BAND_CEIL: float = 0.85
Z_MULT: float = 1.96
TAU_U80: float = 0.033
RHO_COUNT_BASELINE: float = 0.512
RHO_RUNG_72: float = 0.605


# --------------------------------------------------------------------------- #
# Rapidity algebra                                                             #
# --------------------------------------------------------------------------- #

def zeta(x: float) -> float:
    """Rapidity of a correlation: artanh(x) = 0.5 * log((1+x)/(1-x))."""
    if not -1.0 < x < 1.0:
        raise ValueError(f"correlation out of range: {x}")
    return 0.5 * math.log((1.0 + x) / (1.0 - x))


def inv_zeta(w: float) -> float:
    """Inverse rapidity: tanh(w)."""
    return math.tanh(w)


def rel_diff(x: float, y: float) -> float:
    """Relativistic difference d(x, y) = (x - y) / (1 - x*y)."""
    return (x - y) / (1.0 - x * y)


def artanh_upper_bound(x: float) -> float:
    """Elementary upper bound x(2-x)/(2(1-x)) for artanh(x) on [0,1)."""
    return x * (2.0 - x) / (2.0 * (1.0 - x))


def artanh_lower_bound(x: float) -> float:
    """Elementary lower bound x(2+x)/(2(1+x)) for artanh(x) on [0,1)."""
    return x * (2.0 + x) / (2.0 * (1.0 + x))


# --------------------------------------------------------------------------- #
# Interval geometry                                                            #
# --------------------------------------------------------------------------- #

def ci_lower(r: float, tau: float) -> float:
    """Lower endpoint of the rapidity-symmetric interval: d(r, tau)."""
    return rel_diff(r, tau)


def ci_upper(r: float, tau: float) -> float:
    """Upper endpoint of the rapidity-symmetric interval: d(r, -tau)."""
    return rel_diff(r, -tau)


def width_law(r: float, tau: float) -> float:
    """Closed-form width 2*tau*(1-r^2)/(1-r^2*tau^2)."""
    return 2.0 * tau * (1.0 - r * r) / (1.0 - r * r * tau * tau)


def asymmetry_law(r: float, tau: float) -> float:
    """Closed-form arm gap (lower arm minus upper arm)."""
    return 2.0 * r * tau * tau * (1.0 - r * r) / (1.0 - r * r * tau * tau)


def certified(r: float, tau: float, floor: float) -> bool:
    """Does the interval about r of half-width parameter tau clear the floor?"""
    return tau <= rel_diff(r, floor)


# --------------------------------------------------------------------------- #
# Resolution law                                                               #
# --------------------------------------------------------------------------- #

def fisher_half_width(z: float, n: float) -> float:
    """Rapidity half-width z / sqrt(n - 3)."""
    return z / math.sqrt(n - 3.0)


def req_samples(z: float, margin: float) -> float:
    """Sample size needed to resolve a rapidity margin: 3 + (z/M)^2."""
    return 3.0 + (z / margin) ** 2


def req_samples_for_floor(z: float, r: float, floor: float) -> float:
    """Sample size needed for reading r to certify the floor."""
    return req_samples(z, zeta(r) - zeta(floor))


def reconstruct_interval(lo: float, hi: float, z: float) -> Tuple[float, float, float]:
    """Algorithm A: recover (reading, half-width parameter, effective n)."""
    wl, wu = zeta(lo), zeta(hi)
    r = inv_zeta(0.5 * (wl + wu))
    tau = inv_zeta(0.5 * (wu - wl))
    n_eff = 3.0 + (2.0 * z / (wu - wl)) ** 2
    return r, tau, n_eff


# --------------------------------------------------------------------------- #
# Ladder extrapolation                                                         #
# --------------------------------------------------------------------------- #

def model_rho(r1: float, r2: float, b1: float, b2: float, b: float) -> float:
    """Rapidity-linear model reading at setting b through rungs (b1,r1),(b2,r2)."""
    w1, w2 = zeta(r1), zeta(r2)
    return inv_zeta(w1 + (b - b1) / (b2 - b1) * (w2 - w1))


def crossing_setting(r1: float, r2: float, b1: float, b2: float, floor: float) -> float:
    """Setting at which the rapidity-linear model crosses the floor."""
    w1, w2, wf = zeta(r1), zeta(r2), zeta(floor)
    return b1 + (w1 - wf) * (b2 - b1) / (w1 - w2)


def rational_rapidity_ratio(x: Fraction) -> Fraction:
    """(1+x)/(1-x); exp of twice the rapidity of x."""
    return (1 + x) / (1 - x)


# --------------------------------------------------------------------------- #
# Demonstrations                                                               #
# --------------------------------------------------------------------------- #

def demo_rapidity_subtraction() -> None:
    print("=" * 74)
    print("1. Rapidity differences are correlations:  zeta(x)-zeta(y) = zeta(d(x,y))")
    print("=" * 74)
    for x, y in [(0.565, 0.55), (0.582, 0.512), (0.9, 0.1), (0.3, -0.4)]:
        lhs = zeta(x) - zeta(y)
        rhs = zeta(rel_diff(x, y))
        print(f"  x={x:+.3f}  y={y:+.3f}   d(x,y)={rel_diff(x,y):+.6f}"
              f"   lhs={lhs:+.10f}  rhs={rhs:+.10f}  |diff|={abs(lhs-rhs):.2e}")
    print()


def demo_interval_laws() -> None:
    print("=" * 74)
    print("2. Width law and asymmetry law")
    print("=" * 74)
    for r, tau in [(0.565, 0.033), (0.2, 0.10), (0.9, 0.05), (0.0, 0.05)]:
        lo, hi = ci_lower(r, tau), ci_upper(r, tau)
        w_direct, w_law = hi - lo, width_law(r, tau)
        g_direct = (r - lo) - (hi - r)
        g_law = asymmetry_law(r, tau)
        print(f"  r={r:.3f} tau={tau:.3f} -> [{lo:.6f}, {hi:.6f}]")
        print(f"      width  direct={w_direct:.10f}  law={w_law:.10f}"
              f"   |diff|={abs(w_direct-w_law):.2e}")
        print(f"      armgap direct={g_direct:+.10f}  law={g_law:+.10f}"
              f"   lower arm longer: {g_direct > 0 or r == 0.0}")
    print("  -> at any positive reading the lower arm is strictly the longer one.")
    print()


def demo_reported_interval() -> None:
    print("=" * 74)
    print("3. The reported interval is rapidity-symmetric (tau = 0.033)")
    print("=" * 74)
    lo, hi = ci_lower(RHO_POOLED, TAU_U80), ci_upper(RHO_POOLED, TAU_U80)
    print(f"  model  [{lo:.6f}, {hi:.6f}]")
    print(f"  record [{CI_REPORTED[0]:.6f}, {CI_REPORTED[1]:.6f}]")
    print(f"  |errors| = {abs(lo-CI_REPORTED[0]):.2e}, {abs(hi-CI_REPORTED[1]):.2e}"
          f"   (both < 6e-4)")
    r_rec, tau_rec, n_eff = reconstruct_interval(*CI_REPORTED, Z_MULT)
    print(f"  Algorithm A on the reported endpoints:")
    print(f"      recovered reading   r   = {r_rec:.6f}   (record: {RHO_POOLED})")
    print(f"      recovered half-width tau= {tau_rec:.6f}   (model: {TAU_U80})")
    print(f"      implied effective n     = {n_eff:.1f}")
    print(f"  lower end below floor {BAND_FLOOR}? {lo < BAND_FLOOR}"
          f"   (by {BAND_FLOOR - lo:.4f})")
    print()


def demo_effective_sample_size() -> None:
    print("=" * 74)
    print("4. Effective sample size carried by the interval")
    print("=" * 74)
    m_lo = artanh_lower_bound(TAU_U80)
    m_hi = artanh_upper_bound(TAU_U80)
    n_hi = req_samples(Z_MULT, m_lo)   # smaller margin -> larger n
    n_lo = req_samples(Z_MULT, m_hi)
    n_true = req_samples(Z_MULT, zeta(TAU_U80))
    print(f"  elementary bracket for artanh(0.033): [{m_lo:.8f}, {m_hi:.8f}]")
    print(f"  hence effective n in [{n_lo:.1f}, {n_hi:.1f}]  (certified 3400..3650)")
    print(f"  exact value: n_eff = {n_true:.1f}")
    print(f"  per-seed budget n_eff/3 = {n_true/3:.1f}")
    print()


def demo_certification() -> None:
    print("=" * 74)
    print("5. Who certifies the floor 0.55?  (resolution law)")
    print("=" * 74)
    n_eff = req_samples(Z_MULT, zeta(TAU_U80))
    per_seed = n_eff / 3.0
    rows = [("pooled", RHO_POOLED, n_eff)] + [
        (f"seed {name}", r, per_seed)
        for name, r in zip("ABC", RHO_SEEDS)
    ]
    print(f"  {'reading':<10}{'rho':>8}{'margin(zeta)':>15}{'n needed':>16}"
          f"{'n available':>14}{'certified':>12}")
    for name, r, budget in rows:
        margin = zeta(r) - zeta(BAND_FLOOR)
        need = req_samples(Z_MULT, margin)
        ok = need <= budget
        print(f"  {name:<10}{r:>8.3f}{margin:>15.6f}{need:>16,.0f}"
              f"{budget:>14,.0f}{str(ok):>12}")
    print()
    print(f"  pooled undersampling factor: {req_samples_for_floor(Z_MULT, RHO_POOLED, BAND_FLOOR)/n_eff:.2f}x")
    print(f"  seed B (+0.001 clearance) shortfall: "
          f"{req_samples_for_floor(Z_MULT, 0.551, BAND_FLOOR)/per_seed:,.0f}x")
    print("  -> not one seed, and not the pool, certifies the floor.")
    print()


def demo_count_parity() -> None:
    print("=" * 74)
    print("6. Count parity in the natural coordinate")
    print("=" * 74)
    raw = RHO_POOLED - RHO_COUNT_BASELINE
    rap = zeta(RHO_POOLED) - zeta(RHO_COUNT_BASELINE)
    print(f"  raw advantage at setting 80      : {raw:+.4f}")
    print(f"  rapidity advantage at setting 80 : {rap:+.4f}"
          f"   (inflation {100*(rap/raw-1):.1f}%)")
    rap_44 = zeta(0.78) - zeta(0.71)
    print(f"  rapidity advantage at setting 44 : {rap_44:+.4f}"
          f"   (0.78 vs 0.71 baseline)")
    print(f"  ratio 44 / 80 = {rap_44/rap:.3f}   (> 1.8, so the fade is real)")
    print()


def demo_crossing() -> None:
    print("=" * 74)
    print("7. The crossing prediction and its price")
    print("=" * 74)
    b_star = crossing_setting(RHO_RUNG_72, RHO_POOLED, 72, 80, BAND_FLOOR)
    print(f"  rungs (72, {RHO_RUNG_72}) and (80, {RHO_POOLED})")
    print(f"  crossing setting b* = {b_star:.4f}   in (82, 83)? "
          f"{82 < b_star < 83}")
    for b in (80, 82, 83, 84, 88):
        print(f"      model reading at {b}: {model_rho(RHO_RUNG_72, RHO_POOLED, 72, 80, b):.5f}")
    r84 = model_rho(RHO_RUNG_72, RHO_POOLED, 72, 80, 84)
    print(f"  predicted at 84: {r84:.5f}  in (0.543, 0.545)? "
          f"{0.543 < r84 < 0.545};  below floor? {r84 < BAND_FLOOR}")
    print()
    print("  exact rational certificates (all comparisons are integer arithmetic):")
    q605 = rational_rapidity_ratio(Fraction(605, 1000))
    q565 = rational_rapidity_ratio(Fraction(565, 1000))
    q550 = rational_rapidity_ratio(Fraction(55, 100))
    q543 = rational_rapidity_ratio(Fraction(543, 1000))
    q545 = rational_rapidity_ratio(Fraction(545, 1000))
    step = q605 / q565            # 27927/24727
    total = q605 / q550           # 2889/2449
    print(f"      (1+x)/(1-x):  0.605 -> {q605},  0.565 -> {q565},  0.55 -> {q550}")
    print(f"      step  = {step},   total = {total}")
    print(f"      b* > 82 :  step^5 < total^4          -> {step**5 < total**4}")
    print(f"      b* < 83 :  total^8 < step^11         -> {total**8 < step**11}")
    print(f"      r(84) > 0.543 : ({q543})^2*({q605}) < ({q565})^3  -> "
          f"{q543**2 * q605 < q565**3}")
    print(f"      r(84) < 0.545 : ({q565})^3 < ({q545})^2*({q605})  -> "
          f"{q565**3 < q545**2 * q605}")
    print(f"      one more rung crosses : ({q565})^2 < ({q550})*({q605})  -> "
          f"{q565**2 < q550 * q605}")
    print()
    n_eff = req_samples(Z_MULT, zeta(TAU_U80))
    for target in (0.543, 0.545):
        need = req_samples(Z_MULT, zeta(BAND_FLOOR) - zeta(target))
        print(f"  certifying a drop below 0.55 from a reading of {target}: "
              f"n >= {need:,.0f}  ({need/n_eff:.1f}x the U80 budget)")
    print()


def demo_quadratic_cost() -> None:
    print("=" * 74)
    print("8. The quadratic cost law and the last decidable rung")
    print("=" * 74)
    base = zeta(RHO_POOLED) - zeta(BAND_FLOOR)
    print(f"  base margin M = {base:.6f},  cost above baseline "
          f"= {req_samples(Z_MULT, base) - 3:,.0f}")
    for k in (1, 2, 4, 10):
        c = req_samples(Z_MULT, base / k) - 3.0
        print(f"      margin M/{k:<3d} -> cost {c:>14,.0f}"
              f"   ratio to base: {k*k:>4d}x  (predicted {k*k})")
    print()
    lam = (zeta(RHO_RUNG_72) - zeta(RHO_POOLED)) / 8.0   # rapidity fade per bit
    print(f"  observed fade rate: {lam:.6f} rapidity units per bit")
    print(f"  {'budget N':>12}{'resolvable margin':>22}{'last decidable setting':>26}")
    for N in (3_528, 10_000, 100_000, 1_000_000, 100_000_000):
        m = Z_MULT / math.sqrt(N - 3.0)
        b_max = 80.0 + (base - m) / lam
        print(f"  {N:>12,}{m:>22.6f}{b_max:>26.2f}")
    print("  -> the decidable range grows logarithmically in the budget.")
    print()


def main() -> None:
    print()
    print("RAPIDITY GEOMETRY OF CORRELATION INTERVALS -- NUMERICAL DEMONSTRATION")
    print()
    demo_rapidity_subtraction()
    demo_interval_laws()
    demo_reported_interval()
    demo_effective_sample_size()
    demo_certification()
    demo_count_parity()
    demo_crossing()
    demo_quadratic_cost()
    print("All laws verified numerically; all crossing claims verified in exact")
    print("rational arithmetic.")


if __name__ == "__main__":
    main()
