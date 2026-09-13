"""
Inadmissibility of Sign-Blind Variance-Share Reporting
======================================================

Numerical demonstration of the results on the augmentation increment

    Delta R^2  =  (rho_zy - rho_xy * rho_xz)^2 / (1 - rho_xz^2)

and the impossibility of recovering it from the three sign-blind variance-share
readings  a = R^2(x,y),  c = R^2(z,y),  e = R^2(x,z).

Demonstrated here, with exact rational arithmetic wherever possible:

  1. A pair of four-key populations with IDENTICAL readings and increments
     0  and  80/149.
  2. The two-parameter family that embeds the pair, and the uniform gap >= 1/3
     on an open ball of parameters.
  3. The dashboard form  Delta R^2 = (c + a e - 2 P)/(1 - e)  and the identity
     P^2 = a c e, i.e. the dashboard determines |P| but not sign P.
  4. The rigidity dichotomy: equal readings => equal increments, or a gap of
     exactly  A = 4 sqrt(a c e) / (1 - e).
  5. The family ceiling 16/17, attained at b = 1, u = sqrt(5).
  6. The universal ceiling  2 sqrt(e) / (1 + sqrt(e)) < 1,  and the Gram
     inequality  1 - a - c - e + 2P >= 0  from which it comes.
  7. The one-bit repair:  Delta R^2 = (c + a e - 2 s sqrt(a c e))/(1 - e).

Run:  python3 demo.py          (standard library only)
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import Callable, List, Sequence, Tuple

Num = Fraction


# ----------------------------------------------------------------------------
# Weighted second-moment toolkit
# ----------------------------------------------------------------------------

def wip(p: Sequence[Num], f: Sequence[Num], g: Sequence[Num]) -> Num:
    """Weighted inner product <f, g> = sum_i p_i f_i g_i."""
    return sum((pi * fi * gi for pi, fi, gi in zip(p, f, g)), Fraction(0))


def wmean(p: Sequence[Num], f: Sequence[Num]) -> Num:
    """Weighted mean mu(f) = sum_i p_i f_i."""
    return sum((pi * fi for pi, fi in zip(p, f)), Fraction(0))


def wcov(p: Sequence[Num], f: Sequence[Num], g: Sequence[Num]) -> Num:
    """Weighted covariance cov(f, g) = <f, g> - mu(f) mu(g)."""
    return wip(p, f, g) - wmean(p, f) * wmean(p, g)


def wvar(p: Sequence[Num], f: Sequence[Num]) -> Num:
    """Weighted variance var(f) = cov(f, f)."""
    return wcov(p, f, f)


def variance_share(p: Sequence[Num], f: Sequence[Num], g: Sequence[Num]) -> Num:
    """The sign-blind dial reading R^2(f, g) = cov(f, g)^2 / (var f * var g)."""
    return wcov(p, f, g) ** 2 / (wvar(p, f) * wvar(p, g))


def signed_correlation(p: Sequence[Num], f: Sequence[Num], g: Sequence[Num]) -> float:
    """The signed correlation rho_{fg}; the datum a variance share destroys."""
    return float(wcov(p, f, g)) / math.sqrt(float(wvar(p, f)) * float(wvar(p, g)))


def partialled(p: Sequence[Num], x: Sequence[Num], z: Sequence[Num]) -> List[Num]:
    """z partialled on the footprint x: centred and orthogonal to x."""
    slope = wcov(p, x, z) / wvar(p, x)
    mz, mx = wmean(p, z), wmean(p, x)
    return [(zi - mz) - slope * (xi - mx) for xi, zi in zip(x, z)]


def residual(p: Sequence[Num], x: Sequence[Num], y: Sequence[Num]) -> List[Num]:
    """Residual of y on x: y - a - b x, centred and orthogonal to x."""
    b = wcov(p, x, y) / wvar(p, x)
    my, mx = wmean(p, y), wmean(p, x)
    return [(yi - my) - b * (xi - mx) for xi, yi in zip(x, y)]


def increment(p: Sequence[Num], x: Sequence[Num], z: Sequence[Num],
              y: Sequence[Num]) -> Num:
    """Augmentation increment Delta R^2 = <r, zt>^2 / (<zt, zt> var y)."""
    r = residual(p, x, y)
    zt = partialled(p, x, z)
    return wip(p, r, zt) ** 2 / (wip(p, zt, zt) * wvar(p, y))


def triple_product(p: Sequence[Num], x: Sequence[Num], z: Sequence[Num],
                   y: Sequence[Num]) -> float:
    """P = rho_xy * rho_xz * rho_zy, the one invariant the dashboard destroys."""
    return (signed_correlation(p, x, y)
            * signed_correlation(p, x, z)
            * signed_correlation(p, z, y))


# ----------------------------------------------------------------------------
# The predictors
# ----------------------------------------------------------------------------

def dashboard_form(a: float, c: float, e: float, P: float) -> float:
    """Delta R^2 = (c + a e - 2 P) / (1 - e)."""
    return (c + a * e - 2.0 * P) / (1.0 - e)


def repaired_dial(a: float, c: float, e: float, s: float) -> float:
    """The complete predictor: three readings plus one sign bit s = +-1."""
    return (c + a * e - 2.0 * s * math.sqrt(a * e * c)) / (1.0 - e)


def ambiguity_amplitude(a: float, c: float, e: float) -> float:
    """A = 4 sqrt(a c e) / (1 - e): the exact size of the sign-blind ambiguity."""
    return 4.0 * math.sqrt(a * c * e) / (1.0 - e)


def universal_ceiling(e: float) -> float:
    """2 sqrt(e) / (1 + sqrt(e)): the largest amplitude any population pair allows."""
    se = math.sqrt(e)
    return 2.0 * se / (1.0 + se)


# ----------------------------------------------------------------------------
# The four-key stage and the two-parameter witness family
# ----------------------------------------------------------------------------

P_UNIFORM: List[Num] = [Fraction(1, 4)] * 4
FOOT: List[Num] = [Fraction(k) for k in (1, 2, 3, 4)]      # footprint x
FEAT: List[Num] = [Fraction(k) for k in (1, 1, 0, 0)]      # feature z
EPS: List[Num] = [Fraction(k) for k in (1, -1, -1, 1)]     # second residual direction
ZT: List[Num] = partialled(P_UNIFORM, FOOT, FEAT)          # partialled feature


def family_target(b: Num, u: Num, active: bool) -> List[Num]:
    """Targets y_B (suppressed) and y_C (active) of the two-parameter family."""
    shift = u - 5 * b * b / u if active else u + 5 * b * b / u
    boost = 20 * b if active else Fraction(0)
    return [b * xi + shift * ei + boost * zi
            for xi, ei, zi in zip(FOOT, EPS, ZT)]


def family_increment_formula(b: float, u: float) -> float:
    """Closed form 80 b^2 u^2 / (5 b^2 u^2 + 4 (u^2 + 5 b^2)^2) for the active member."""
    return 80.0 * b * b * u * u / (5.0 * b * b * u * u + 4.0 * (u * u + 5.0 * b * b) ** 2)


# ----------------------------------------------------------------------------
# Reporting helpers
# ----------------------------------------------------------------------------

def rule(title: str) -> None:
    print("\n" + "=" * 78)
    print(title)
    print("=" * 78)


def readings(y: Sequence[Num]) -> Tuple[Num, Num, Num]:
    """The three sign-blind dial readings (a, c, e) for a given target."""
    a = variance_share(P_UNIFORM, FOOT, y)
    c = variance_share(P_UNIFORM, FEAT, y)
    e = variance_share(P_UNIFORM, FOOT, FEAT)
    return a, c, e


def check(label: str, ok: bool) -> None:
    print(f"   [{'OK ' if ok else 'FAIL'}] {label}")
    assert ok, label


# ----------------------------------------------------------------------------
# 1. The stage
# ----------------------------------------------------------------------------

def demo_stage() -> None:
    rule("1. The four-key stage")
    print(f"   weights p      = {[str(v) for v in P_UNIFORM]}")
    print(f"   footprint x    = {[str(v) for v in FOOT]}")
    print(f"   feature   z    = {[str(v) for v in FEAT]}")
    print(f"   epsilon        = {[str(v) for v in EPS]}   (centred, orthogonal to x and to zt)")
    print(f"   partialled zt  = {[str(v) for v in ZT]}")
    print(f"   var(x) = {wvar(P_UNIFORM, FOOT)},  var(z) = {wvar(P_UNIFORM, FEAT)},"
          f"  cov(x,z) = {wcov(P_UNIFORM, FOOT, FEAT)}")
    print(f"   <zt,zt> = {wip(P_UNIFORM, ZT, ZT)}   (partialled energy)")
    print(f"   collinearity reading R^2(x,z) = {variance_share(P_UNIFORM, FOOT, FEAT)}")
    check("epsilon is centred", wmean(P_UNIFORM, EPS) == 0)
    check("epsilon orthogonal to footprint", wip(P_UNIFORM, FOOT, EPS) == 0)
    check("epsilon orthogonal to partialled feature", wip(P_UNIFORM, EPS, ZT) == 0)
    check("R^2(x,z) = 4/5", variance_share(P_UNIFORM, FOOT, FEAT) == Fraction(4, 5))


# ----------------------------------------------------------------------------
# 2. The flagship pair
# ----------------------------------------------------------------------------

def demo_flagship_pair() -> None:
    rule("2. Two worlds, one dashboard")
    b, u = Fraction(1, 10), Fraction(1, 2)
    yB = family_target(b, u, active=False)
    yC = family_target(b, u, active=True)
    print(f"   suppressed target y_B = {[str(v) for v in yB]}")
    print(f"   active     target y_C = {[str(v) for v in yC]}")
    for name, y in (("y_B", yB), ("y_C", yC)):
        a, c, e = readings(y)
        print(f"\n   {name}:  var = {wvar(P_UNIFORM, y)}")
        print(f"        cov(x,y) = {wcov(P_UNIFORM, FOOT, y)},  "
              f"cov(z,y) = {wcov(P_UNIFORM, FEAT, y)}   <- signed, and they differ")
        print(f"        readings a = {a} ~ {float(a):.6f},  c = {c} ~ {float(c):.6f},"
              f"  e = {e}")
        print(f"        rho_xy = {signed_correlation(P_UNIFORM, FOOT, y):+.6f},"
              f"  rho_xz = {signed_correlation(P_UNIFORM, FOOT, FEAT):+.6f},"
              f"  rho_zy = {signed_correlation(P_UNIFORM, FEAT, y):+.6f}")
        print(f"        triple product P = {triple_product(P_UNIFORM, FOOT, FEAT, y):+.6f}")
        print(f"        INCREMENT Delta R^2 = {increment(P_UNIFORM, FOOT, FEAT, y)}"
              f" ~ {float(increment(P_UNIFORM, FOOT, FEAT, y)):.6f}")

    check("variances agree", wvar(P_UNIFORM, yB) == wvar(P_UNIFORM, yC))
    check("footprint readings agree", readings(yB)[0] == readings(yC)[0])
    check("feature readings agree", readings(yB)[1] == readings(yC)[1])
    check("signed feature covariances are exact negatives",
          wcov(P_UNIFORM, FEAT, yB) == -wcov(P_UNIFORM, FEAT, yC))
    check("suppressed increment is 0", increment(P_UNIFORM, FOOT, FEAT, yB) == 0)
    check("active increment is 80/149",
          increment(P_UNIFORM, FOOT, FEAT, yC) == Fraction(80, 149))
    print("\n   => No function of (a, c, e) can return both 0 and 80/149.")
    print("      The base model explains 3.36% of the target's variance; adding the")
    print("      feature explains 0% more in one world and 53.69% more in the other.")


# ----------------------------------------------------------------------------
# 3. Dashboard form and the missing sign
# ----------------------------------------------------------------------------

def demo_invariant_content() -> None:
    rule("3. Exact invariant content:  Delta R^2 = (c + a e - 2P)/(1 - e),  P^2 = a c e")
    b, u = Fraction(1, 10), Fraction(1, 2)
    for name, y in (("y_B", family_target(b, u, False)), ("y_C", family_target(b, u, True))):
        a, c, e = (float(v) for v in readings(y))
        P = triple_product(P_UNIFORM, FOOT, FEAT, y)
        direct = float(increment(P_UNIFORM, FOOT, FEAT, y))
        via_dash = dashboard_form(a, c, e, P)
        rxy = signed_correlation(P_UNIFORM, FOOT, y)
        rxz = signed_correlation(P_UNIFORM, FOOT, FEAT)
        rzy = signed_correlation(P_UNIFORM, FEAT, y)
        partial_form = (rzy - rxy * rxz) ** 2 / (1.0 - rxz ** 2)
        print(f"   {name}:  direct = {direct:.10f}")
        print(f"          partial-correlation form = {partial_form:.10f}")
        print(f"          dashboard form           = {via_dash:.10f}")
        print(f"          P = {P:+.10f},  P^2 = {P*P:.10f},  a c e = {a*c*e:.10f}")
        check(f"{name}: partial-correlation form agrees", abs(direct - partial_form) < 1e-12)
        check(f"{name}: dashboard form agrees", abs(direct - via_dash) < 1e-12)
        check(f"{name}: P^2 = a c e", abs(P * P - a * c * e) < 1e-12)
    print("\n   => The dashboard pins |P| exactly; only the SIGN of P is destroyed.")


# ----------------------------------------------------------------------------
# 4. Rigidity: the ambiguity is a two-point set
# ----------------------------------------------------------------------------

def demo_rigidity() -> None:
    rule("4. Rigidity: the ambiguity is a two-point set of exact width A")
    b, u = Fraction(1, 10), Fraction(1, 2)
    yB, yC = family_target(b, u, False), family_target(b, u, True)
    a, c, e = (float(v) for v in readings(yB))
    A = ambiguity_amplitude(a, c, e)
    gap = abs(float(increment(P_UNIFORM, FOOT, FEAT, yC))
              - float(increment(P_UNIFORM, FOOT, FEAT, yB)))
    print(f"   readings (a, c, e) = ({a:.6f}, {c:.6f}, {e:.6f})")
    print(f"   amplitude A = 4 sqrt(a c e)/(1 - e) = {A:.10f}   (= 80/149 = {80/149:.10f})")
    print(f"   observed increment gap              = {gap:.10f}")
    check("observed gap equals the predicted amplitude", abs(A - gap) < 1e-12)

    print("\n   Amplitude vanishes exactly when one reading is zero:")
    for (aa, cc, ee, label) in [(0.0, 0.3, 0.5, "a = 0"),
                                (0.3, 0.0, 0.5, "c = 0"),
                                (0.3, 0.2, 0.0, "e = 0"),
                                (0.2, 0.2, 0.2, "all nonzero")]:
        print(f"      {label:<12}  A = {ambiguity_amplitude(aa, cc, ee):.6f}")
    check("A = 0 iff some reading is 0",
          ambiguity_amplitude(0.0, .3, .5) == 0.0
          and ambiguity_amplitude(.3, 0.0, .5) == 0.0
          and ambiguity_amplitude(.3, .2, 0.0) == 0.0
          and ambiguity_amplitude(.2, .2, .2) > 0.0)


# ----------------------------------------------------------------------------
# 5. Robustness on an open ball
# ----------------------------------------------------------------------------

def demo_open_family() -> None:
    rule("5. Robustness: identical readings and gap >= 1/3 on an open ball")
    print("   scanning the ball |(b,u) - (1/10, 1/2)| < 1/100")
    print(f"   {'b':>8} {'u':>8} {'readings agree':>16} {'R^2(x,y)':>12} {'gap':>10}")
    worst = 1.0
    seen_readings = set()
    grid = [Fraction(i, 1000) for i in range(-9, 10, 3)]
    for db in grid:
        for du in grid:
            if float(db) ** 2 + float(du) ** 2 >= 0.01 ** 2:
                continue
            b, u = Fraction(1, 10) + db, Fraction(1, 2) + du
            yB, yC = family_target(b, u, False), family_target(b, u, True)
            agree = readings(yB) == readings(yC)
            gap = increment(P_UNIFORM, FOOT, FEAT, yC) - increment(P_UNIFORM, FOOT, FEAT, yB)
            worst = min(worst, float(gap))
            seen_readings.add(readings(yB)[0])
            print(f"   {float(b):8.4f} {float(u):8.4f} {str(agree):>16}"
                  f" {float(readings(yB)[0]):12.8f} {float(gap):10.6f}")
    print(f"\n   minimum gap over the sampled ball = {worst:.6f}  (theory: >= 1/3)")
    print(f"   distinct footprint readings seen  = {len(seen_readings)}"
          f"  (so the ball is NOT one moment point in disguise)")
    check("uniform gap >= 1/3 on the ball", worst >= 1 / 3)
    check("dial readings genuinely vary over the ball", len(seen_readings) > 1)


# ----------------------------------------------------------------------------
# 6. Ceilings
# ----------------------------------------------------------------------------

def demo_ceilings() -> None:
    rule("6. How much can be concealed?  16/17 inside the family, 2 sqrt(e)/(1+sqrt(e)) universally")
    print("   family concealable share 80 b^2 u^2 / (5 b^2 u^2 + 4 (u^2 + 5 b^2)^2):")
    print(f"   {'b':>8} {'u':>10} {'share':>12} {'16/17 - share':>16}")
    samples: List[Tuple[float, float]] = [
        (0.1, 0.5), (1.0, 1.0), (1.0, 2.0), (1.0, 2.2),
        (1.0, math.sqrt(5.0)), (1.0, 2.3), (2.0, 2 * math.sqrt(5.0)), (0.5, 3.0),
    ]
    best = 0.0
    for b, u in samples:
        share = family_increment_formula(b, u)
        best = max(best, share)
        print(f"   {b:8.4f} {u:10.6f} {share:12.8f} {16/17 - share:16.3e}")
    print(f"\n   best sampled share = {best:.10f};  16/17 = {16/17:.10f}")
    check("family share never exceeds 16/17",
          all(family_increment_formula(b, u) <= 16 / 17 + 1e-12 for b, u in samples))
    check("16/17 attained at b = 1, u = sqrt 5",
          abs(family_increment_formula(1.0, math.sqrt(5.0)) - 16 / 17) < 1e-12)

    # the maximiser is the ray u = sqrt(5) b, the vanishing locus of (u^2 - 5b^2)^2
    print("\n   the maximiser is the ray u = sqrt(5) b (zero locus of the square (u^2-5b^2)^2):")
    for b in (0.3, 1.0, 7.0):
        print(f"      b = {b:5.2f}, u = sqrt(5) b = {math.sqrt(5)*b:8.5f}:"
              f"  share = {family_increment_formula(b, math.sqrt(5)*b):.12f}")

    print("\n   universal ceiling 2 sqrt(e)/(1 + sqrt(e)):")
    for e in (0.0, 0.2, 0.5, 0.8, 0.95, 0.999):
        print(f"      e = {e:6.3f}  ->  ceiling = {universal_ceiling(e):.8f}  (< 1)")
    e_fam = 4 / 5
    print(f"\n   at the family's collinearity reading e = 4/5:")
    print(f"      ceiling  = {universal_ceiling(e_fam):.10f} = 4/(2+sqrt 5)"
          f" = {4/(2+math.sqrt(5)):.10f}")
    print(f"      family   = {16/17:.10f}")
    print(f"      the family realises {100*16/17/universal_ceiling(e_fam):.3f}% of the ceiling")
    check("16/17 < 4/(2+sqrt 5)", 16 / 17 < 4 / (2 + math.sqrt(5)))
    check("ceiling < 1 for all e < 1", all(universal_ceiling(e) < 1 for e in
                                           (0.0, 0.2, 0.5, 0.8, 0.95, 0.999)))


# ----------------------------------------------------------------------------
# 7. Gram inequality and total-share bound
# ----------------------------------------------------------------------------

def demo_gram() -> None:
    rule("7. Cauchy-Schwarz => total share <= 1 => Gram inequality => the ceiling")
    b, u = Fraction(1, 10), Fraction(1, 2)
    for name, y in (("y_B", family_target(b, u, False)), ("y_C", family_target(b, u, True))):
        a, c, e = (float(v) for v in readings(y))
        P = triple_product(P_UNIFORM, FOOT, FEAT, y)
        d = float(increment(P_UNIFORM, FOOT, FEAT, y))
        gram = 1 - a - c - e + 2 * P
        print(f"   {name}: R^2(x,y) + Delta R^2 = {a:.6f} + {d:.6f} = {a+d:.6f} <= 1")
        print(f"         Gram determinant 1 - a - c - e + 2P = {gram:.6f} >= 0")
        check(f"{name}: total share <= 1", a + d <= 1 + 1e-12)
        check(f"{name}: Gram inequality", gram >= -1e-12)
    a, c, e = (float(v) for v in readings(family_target(b, u, False)))
    print(f"\n   both signs of P admissible requires 2 sqrt(a c e) <= 1 - a - c - e:")
    print(f"      2 sqrt(a c e) = {2*math.sqrt(a*c*e):.6f}  <=  1 - a - c - e ="
          f" {1-a-c-e:.6f}")
    check("the unfavourable-sign Gram constraint holds",
          2 * math.sqrt(a * c * e) <= 1 - a - c - e + 1e-12)


# ----------------------------------------------------------------------------
# 8. The one-bit repair
# ----------------------------------------------------------------------------

def demo_repair() -> None:
    rule("8. The repair: three readings plus ONE sign bit determine the increment")
    b, u = Fraction(1, 10), Fraction(1, 2)
    print(f"   {'target':>8} {'a':>10} {'c':>10} {'e':>6} {'bit s':>7}"
          f" {'repaired':>12} {'true':>12}")
    for name, y in (("y_B", family_target(b, u, False)), ("y_C", family_target(b, u, True))):
        a, c, e = (float(v) for v in readings(y))
        s = 1.0 if triple_product(P_UNIFORM, FOOT, FEAT, y) >= 0 else -1.0
        pred = repaired_dial(a, c, e, s)
        true = float(increment(P_UNIFORM, FOOT, FEAT, y))
        print(f"   {name:>8} {a:10.6f} {c:10.6f} {e:6.3f} {s:+7.0f}"
              f" {pred:12.8f} {true:12.8f}")
        check(f"{name}: repaired dial is exact", abs(pred - true) < 1e-12)
    print("\n   Identical readings, opposite bits, correct answers in both worlds:")
    print("   the inadmissibility of sign-blind reporting is exactly one bit deep.")


# ----------------------------------------------------------------------------
# 9. A random stress test over many populations
# ----------------------------------------------------------------------------

def demo_random_audit(trials: int = 4000, seed: int = 20260912) -> None:
    rule("9. Randomised audit over pseudo-random populations")
    state = seed

    def rnd() -> float:
        nonlocal state
        state = (1103515245 * state + 12345) % (1 << 31)
        return state / float(1 << 31) * 2.0 - 1.0

    max_err_dash, max_err_rep, max_over_ceiling, min_gram = 0.0, 0.0, -1.0, 1.0
    used = 0
    for _ in range(trials):
        n = 5
        p = [Fraction(1, n)] * n
        x = [Fraction(round(rnd() * 50), 10) for _ in range(n)]
        z = [Fraction(round(rnd() * 50), 10) for _ in range(n)]
        y = [Fraction(round(rnd() * 50), 10) for _ in range(n)]
        if wvar(p, x) == 0 or wvar(p, y) == 0 or wvar(p, z) == 0:
            continue
        zt = partialled(p, x, z)
        if wip(p, zt, zt) == 0:
            continue
        used += 1
        r = residual(p, x, y)
        d = float(wip(p, r, zt) ** 2 / (wip(p, zt, zt) * wvar(p, y)))
        a = float(variance_share(p, x, y))
        c = float(variance_share(p, z, y))
        e = float(variance_share(p, x, z))
        P = (signed_correlation(p, x, y) * signed_correlation(p, x, z)
             * signed_correlation(p, z, y))
        s = 1.0 if P >= 0 else -1.0
        max_err_dash = max(max_err_dash, abs(d - dashboard_form(a, c, e, P)))
        max_err_rep = max(max_err_rep, abs(d - repaired_dial(a, c, e, s)))
        min_gram = min(min_gram, 1 - a - c - e + 2 * P)
        # the amplitude bound is asserted only for readings admitting BOTH signs
        if 2 * math.sqrt(a * c * e) <= 1 - a - c - e + 1e-12:
            max_over_ceiling = max(max_over_ceiling,
                                   ambiguity_amplitude(a, c, e) - universal_ceiling(e))
    print(f"   populations tested                            : {used}")
    print(f"   max |direct - dashboard form|                 : {max_err_dash:.3e}")
    print(f"   max |direct - repaired dial|                  : {max_err_rep:.3e}")
    print(f"   min Gram determinant 1 - a - c - e + 2P       : {min_gram:.3e}  (>= 0)")
    print(f"   max (amplitude - ceiling) on sign-ambiguous   : {max_over_ceiling:.3e}  (<= 0)")
    check("dashboard form exact on all sampled populations", max_err_dash < 1e-9)
    check("repaired dial exact on all sampled populations", max_err_rep < 1e-9)
    check("Gram inequality holds on all sampled populations", min_gram >= -1e-9)
    check("universal ceiling holds wherever both signs are admissible",
          max_over_ceiling <= 1e-9)


def main() -> None:
    print(__doc__)
    demo_stage()
    demo_flagship_pair()
    demo_invariant_content()
    demo_rigidity()
    demo_open_family()
    demo_ceilings()
    demo_gram()
    demo_repair()
    demo_random_audit()
    rule("All demonstrations completed and all assertions verified.")


if __name__ == "__main__":
    main()


"""Assemble PACKAGE.json from the delivered artifacts and the packaging assets."""

from __future__ import annotations

import ast
import json
import pathlib
from typing import Any, Dict, List

ROOT = pathlib.Path(__file__).resolve().parent.parent
PKG = ROOT / "packaging"

LEAN_FILES: List[str] = [
    "Catalog/Algebra/SignBlindDial/CorrelationInvariants.lean",
    "Catalog/Algebra/SignBlindDial/OpenWitnessFamily.lean",
    "Catalog/Algebra/SignBlindDial/AmbiguityAmplitude.lean",
    "Catalog/Algebra/SignBlindDial/RepairedDashboard.lean",
    "Catalog/Algebra/SignBlindDial/AmplitudeCeiling.lean",
]


def read(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8")


FUTURE_DIRECTIONS = """# Future directions — after the sign-blind dial cycle

## What this cycle settled

Working from the five-moment formula for the augmentation increment and an explicit
suppression pair, the development establishes:

1. **Impossibility.** No function of the three variance shares `R²(x,y)`, `R²(z,y)`,
   `R²(x,z)` returns `ΔR²` on all finite populations — already false on four-key
   populations.
2. **Robustness.** The witnesses contain a metric ball of parameters on which every pair
   has identical dial readings, exactly opposite signed covariances, increments `0` and
   `≥ 1/3`; the readings genuinely vary over the ball, so the failure occupies an open
   region of moment space.
3. **Exact invariant content.** `ΔR² = (ρ_zy − ρ_xy ρ_xz)²/(1 − ρ_xz²)`, rewritten as a
   function of the three readings plus the triple product `P = ρ_xy ρ_xz ρ_zy`, whose
   square is the product of the readings.
4. **Rigidity of the damage.** Two populations with equal readings agree, or differ by
   *exactly* `4√(R²(x,y)R²(z,y)R²(x,z))/(1 − R²(x,z))`.
5. **Amplitude.** Within the family the concealable share of rate variance has greatest
   value `16/17`, attained at `b = 1`, `u = √5`.
6. **Repair.** One logged sign bit is sufficient, so the inadmissibility of sign-blind
   reporting is exactly one bit deep; the population-level form determines the increment
   from the readings and the sign.
7. **Universal ceiling (closing last cycle's conjecture D2).** The base share plus
   increment never exceeds `1` (weighted Cauchy–Schwarz); the Gram inequality
   `1 − R²(x,y) − R²(x,z) − R²(z,y) + 2P ≥ 0` is *derived* rather than assumed; and for
   any two populations with identical dial readings and opposite triple-product signs the
   increments differ by at most `2√(R²(x,z))/(1 + √(R²(x,z))) < 1`. So the misattribution
   a sign-blind dashboard can cause is capped by the footprint–feature collinearity
   reading alone; the explicit family sits just below this ceiling,
   `16/17 < 4/(2 + √5)`.

The structural pattern: `ΔR²` is a function on the quotient of moment space by the
reparametrisation group; the dial readings are the invariants of the *even* sign
subgroup, and the leftover `Z/2` is precisely the triple-product sign.

## Bold, testable conjectures for the next cycle

### D1. Multi-feature sign cohomology

For an augmentation by `k` features at once, the analogue of the dashboard is the
collection of pairwise variance shares, and the analogue of the missing datum should be
the set of *cycle signs* of the correlation graph: the sign of
`ρ_{i₁i₂} ρ_{i₂i₃} ⋯ ρ_{i_m i₁}` around each cycle. Conjecture: the missing information
is exactly `H¹` of the complete graph on `k + 2` vertices with `Z/2` coefficients modulo
the vertex-flip action, i.e. `C(k+1, 2)` bits, and a spanning tree's worth of signs
determines all of them.

### D2. Sharpness of the universal ceiling

Is `2√e/(1 + √e)` attained for every `e ∈ (0,1)` by some pair of populations, or only
approached? The AM–GM step is tight when `a = c`, suggesting the extremal configuration
has equal footprint and feature readings; a matching construction would make the ceiling
an equality-characterised invariant of `e`.

### D3. Statistical version

Replace exact moments with sample moments from `n` draws. How large must `n` be before
the sign of `P` is determined with confidence `1 − δ`, and does the two-point rigidity
persist as a bimodal posterior for the increment? Conjecture: the posterior for `ΔR²` is
asymptotically a two-component mixture with weights given by the sign posterior and
separation equal to the ambiguity amplitude.

### D4. Which invariants pin the sign?

Are there natural additional population invariants — order statistics, monotonicity
constraints, sign patterns of the raw features — that force `P > 0`? Any such condition
would be a genuinely new constraint on admissible populations and would carve out a
class on which sign-blind reporting is admissible after all.
"""


INTERACTIVE_LAYOUT = r"""
# Two Worlds, One Dashboard
### A guided tour of why squared correlations cannot price a new variable

You have a model. It explains some share of the variation in what you care about — that
familiar number $R^2$. Someone hands you a new variable and asks the only question that
matters: **how much more will I explain if I add it?**

That number is the *augmentation increment*,

$$\Delta R^2 \;=\; R^2(\{x,z\},y) \;-\; R^2(x,y),$$

where $x$ is the predictor you already have (the **footprint**), $z$ is the candidate
(the **feature**), and $y$ is the target. Nearly every dashboard in the world answers by
showing three variance shares: $R^2(x,y)$, $R^2(z,y)$, $R^2(x,z)$.

This page shows that those three numbers are *provably insufficient* — and then shows
exactly what is missing, exactly how much damage the omission can do, and exactly how to
repair it with a single bit.

---

## 1. Warm-up: the exact law for the increment

Write $\rho_{xy}, \rho_{xz}, \rho_{zy}$ for the three **signed** correlations. The
increment is the square of the *partial correlation* of feature and target given the
footprint:

$$\Delta R^2 \;=\; \frac{(\rho_{zy} - \rho_{xy}\rho_{xz})^2}{1 - \rho_{xz}^2}.$$

Notice: the numerator is a **difference**. It subtracts the association the footprint
already supplies, $\rho_{xy}\rho_{xz}$, from the association the feature shows,
$\rho_{zy}$. Whether those two cancel or reinforce is purely a question of sign — and a
variance share $R^2 = \rho^2$ has thrown the sign away.

<details>
<summary><b>Click to reveal the derivation from raw moments</b></summary>

Decompose $y = a + bx + r$ with $r$ centred and orthogonal to $x$, and let $\tilde z$ be
$z$ with the footprint partialled out (centred, orthogonal to $x$). Then the increment is
the projection of the residual onto the partialled feature, normalised:

$$\Delta R^2 = \frac{\langle r, \tilde z\rangle^2}{\langle \tilde z,\tilde z\rangle\,\operatorname{var}(y)}
= \frac{\Big(\operatorname{cov}(z,y) - \frac{\operatorname{cov}(x,z)\operatorname{cov}(x,y)}{\operatorname{var}(x)}\Big)^2}
{\Big(\operatorname{var}(z) - \frac{\operatorname{cov}(x,z)^2}{\operatorname{var}(x)}\Big)\operatorname{var}(y)}.$$

Writing every covariance as $\rho\cdot s\cdot s'$ and cancelling the common factor
$s_x^2s_y^2s_z^2$ gives the partial-correlation form above. In particular the increment
is unchanged if you rescale $x$, $y$ or $z$ — it depends only on the three correlations.
See also the background on
[partial correlation](https://en.wikipedia.org/wiki/Partial_correlation) and on
[suppression in regression](https://en.wikipedia.org/wiki/Suppressor_variable).
</details>

---

## 2. Meet the two worlds

Play with the laboratory below before reading on. Panel 1 builds two four-key
populations — a **suppressed** world and an **active** world — that agree on every
sign-blind reading. Watch the "identical" badges stay green while the two increment bars
pull apart.

{{interactive_demo:0}}

Things to try:

- Set the shape parameter to $u/b = 5$: this is the flagship pair, with increments
  $0$ and $80/149 \approx 53.7\%$ behind identical readings.
- Slide the scale $b$: nothing moves. The increment is scale-free.
- Set $u/b = \sqrt5 \approx 2.236$: the active world now attributes $16/17 \approx 94.1\%$
  of its target's variance to a feature its twin values at exactly zero.
- Open Panel 2 and flip the sign of *one* correlation slider: the readings freeze, the
  increment jumps. Flip *two*: nothing at all happens. That asymmetry is the whole story.

---

## 3. Why it happens: one invariant, one bit

Define the **correlation triple product**

$$P \;=\; \rho_{xy}\,\rho_{xz}\,\rho_{zy}.$$

Two short computations change everything. First, in dashboard coordinates
$a = R^2(x,y)$, $c = R^2(z,y)$, $e = R^2(x,z)$,

$$\Delta R^2 \;=\; \frac{c + a e - 2P}{1 - e},$$

so $P$ is the *only* quantity beyond the readings that the increment needs. Second,

$$P^2 \;=\; a\,c\,e,$$

so the dashboard already determines $|P|$ **exactly**. The single missing datum is the
**sign of $P$** — one bit, not three.

<details>
<summary><b>Why one bit and not three? (the group-theoretic reason)</b></summary>

The increment is invariant under rescaling the target and the feature, so it is really a
function on the quotient of moment space by the reparametrisation group; the three signed
correlations are coordinates there. The sign group $\{\pm1\}^3$ acts by flipping variable
directions. The invariants of the *full* action are the three squares — the dashboard.
But $\Delta R^2$ is invariant under only the *even* subgroup (flip two signs at a time),
because flipping two of the three correlations leaves $P$ unchanged. The quotient of the
full group by the even subgroup is $\mathbb{Z}/2$, and its generator is detected by
$\operatorname{sign} P$. That is precisely the lost bit.
</details>

---

## 4. The impossibility theorem, stated properly

> **Theorem.** There is no function $F$ of three real arguments with
> $\Delta R^2 = F\big(R^2(x,y), R^2(z,y), R^2(x,z)\big)$ for all finite populations. The
> statement already fails on populations supported on four keys.

The proof is nothing but the pair you just played with: $F$ receives identical arguments
and must return both $0$ and $80/149$.

And this is not a knife-edge coincidence. The pair sits inside a smooth two-parameter
family, and on a whole ball of parameters around it every pair has identical readings and
an increment gap of at least $1/3$, while the readings themselves genuinely vary over
the ball. The failure occupies an **open region of moment space**.

{{visualization:0}}

---

## 5. The damage is quantised — and capped

Here is the surprise. You might expect the ambiguity to be an interval of possible
answers. It is not: it is a **two-point set**.

> **Ambiguity dichotomy.** Two populations with identical readings either report the
> *same* increment, or increments differing by exactly
> $$A \;=\; \frac{4\sqrt{a\,c\,e}}{1 - e}.$$

Because $P^2 = ace$ pins $|P|$, the only freedom is $P \mapsto -P$, which shifts the
increment by exactly $4P/(1-e)$. The amplitude $A$ vanishes if and only if one of the
three readings is zero — a nowhere-dense condition. **On essentially every reading, the
dashboard is a coin flip between two known outcomes.**

How big can $A$ get? Not arbitrarily big, because a triple of readings that admits *both*
signs of $P$ must be realisable as a genuine correlation structure twice over.

<details>
<summary><b>Click to reveal the ceiling argument</b></summary>

Step 1 (Cauchy–Schwarz). Since $y = a + bx + r$ is an orthogonal decomposition,
$\operatorname{var}(y) = b^2\operatorname{var}(x) + \langle r,r\rangle$, and
$\langle r,\tilde z\rangle^2 \le \langle r,r\rangle\langle \tilde z,\tilde z\rangle$.
Adding gives the interpretable bound
$$R^2(x,y) + \Delta R^2 \le 1 :$$
no model explains more than all of the variance.

Step 2 (Gram inequality). Feeding the dashboard form into that bound and clearing the
positive denominator yields
$$1 - a - c - e + 2P \ \ge\ 0,$$
which is exactly nonnegativity of the $3\times3$ correlation determinant — here *derived*
rather than assumed.

Step 3 (AM–GM). If both signs of $P$ are admissible, the inequality holds with the
unfavourable sign too, giving $2\sqrt{ace} \le 1 - a - c - e$. Put
$\alpha=\sqrt a,\gamma=\sqrt c,\eta=\sqrt e$ and use $2\alpha\gamma\le\alpha^2+\gamma^2$:
$$2\alpha\gamma(1+\eta) \le (\alpha^2+\gamma^2) + (1-\alpha^2-\gamma^2-\eta^2) = 1-e,$$
which rearranges to $4\sqrt{ace}/(1-e) \le 2\sqrt e/(1+\sqrt e)$.
</details>

> **Universal ceiling.** For any two populations with identical readings and opposite
> triple-product signs,
> $$\big|\Delta R^2 - \Delta R'^2\big| \;\le\; \frac{2\sqrt e}{1+\sqrt e} \;<\; 1 .$$

The worst misattribution a sign-blind report can cause is governed by the
footprint–feature collinearity reading **alone**. And the explicit family comes
remarkably close: at $e = 4/5$ the ceiling is $4/(2+\sqrt5)\approx 0.94427$, while the
family peaks at $16/17 \approx 0.94118$ — $99.7\%$ of the theoretical maximum.

{{visualization:1}}

---

## 6. The repair: log one bit

Every impossibility theorem deserves a possibility theorem. Define

$$G(a,c,e,s) \;=\; \frac{c + a e - 2s\sqrt{a\,e\,c}}{1-e}, \qquad s = \operatorname{sign} P .$$

> **Theorem.** $\Delta R^2 = G\big(R^2(x,y), R^2(z,y), R^2(x,z), s\big)$ on every finite
> population.

Set against the impossibility theorem, this locates the defect exactly: **sign-blind
reporting fails by precisely one bit per augmentation.** Not by an unquantifiable loss of
context — by one bit, which any reporting pipeline can afford.

Here is the production-ready version: a report that returns the true increment *and* the
exact value a sign-blind reader could not have excluded.

{{algorithm:0}}

If you are stuck with a legacy report that never recorded signs, you are not helpless —
you can still decide whether the report is capable of certifying your decision. Panel 3
of the laboratory does this interactively; here is the same audit as code.

{{algorithm:2}}

And if you want to stress-test a pipeline, you can manufacture dashboard-identical pairs
with any prescribed gap up to $16/17$:

{{algorithm:1}}

---

## 7. See every claim checked numerically

The demonstration below recomputes everything from scratch in exact rational arithmetic
where possible: the flagship pair, the identity $P^2 = ace$, the dichotomy, the uniform
gap over the open ball, the $16/17$ ceiling and where it is attained, the Gram inequality,
the universal ceiling, and the one-bit repair — finishing with a randomised audit over
thousands of pseudo-random populations.

{{demo:0}}

<details>
<summary><b>What to look for in the output</b></summary>

- Section 2 prints two targets with the *same* variance $149/400$, the *same* covariance
  with the footprint, and covariances with the feature that are exact negatives.
- Section 3 confirms the partial-correlation form, the dashboard form, and $P^2 = ace$
  agree to machine precision.
- Section 5 sweeps the ball $|(b,u) - (1/10,1/2)| < 1/100$ and reports the minimum gap
  (always $\ge 1/3$) together with the number of *distinct* footprint readings seen —
  proof that the ball is not one moment point in disguise.
- Section 9 audits thousands of random populations: the repaired predictor is exact
  everywhere, the Gram determinant is never negative, and the amplitude never exceeds the
  ceiling.
</details>

---

## 8. What to take away

1. **A sign-blind statistic is an invariant of a group action**, and asking whether it is
   complete is asking what the action leaves over. Here the leftover is a single
   $\mathbb{Z}/2$ — which is why the failure is one bit deep, the ambiguity is two points
   rather than an interval, and the amplitude has a closed form.
2. **Suppression is not pathology.** It lives on open sets of moment space and can hide up
   to $94\%$ of a target's variance behind an innocuous-looking screen.
3. **Store the signed covariances.** One bit per triple is the difference between a report
   that can certify a modelling decision and one that provably cannot. If you must publish
   squares, publish $A = 4\sqrt{ace}/(1-e)$ beside them, so a reader knows whether they are
   looking at an answer or at a coin flip.

The next time a dashboard says a variable explains $2.7\%$ of the variance and overlaps
$80\%$ with what you already have, remember: that screen is equally consistent with the
variable being worthless and with it being the most valuable thing in your dataset.
"""


def build() -> Dict[str, Any]:
    article = read("ARTICLE.md")
    paper = read("RESEARCH_PAPER.md")
    tex = read("RESEARCH_PAPER.tex")
    demo = read("demo.py")
    algos = (PKG / "algorithms.py").read_text(encoding="utf-8")
    widget = (PKG / "widget.html").read_text(encoding="utf-8")
    viz1 = (PKG / "viz_family.py").read_text(encoding="utf-8")
    viz2 = (PKG / "viz_ambiguity.py").read_text(encoding="utf-8")

    lean_source = "\n\n".join(
        f"-- ===================================================================\n"
        f"-- {path}\n"
        f"-- ===================================================================\n\n"
        + read(path)
        for path in LEAN_FILES
    )

    # ---- extract each reference implementation as a standalone module ----
    header = ('from __future__ import annotations\n\nimport math\n'
              'from typing import Dict, List, Optional, Sequence, Tuple\n\n\n')
    tree = ast.parse(algos)
    sources = {node.name: ast.get_source_segment(algos, node)
               for node in tree.body if isinstance(node, ast.FunctionDef)}
    code1 = header + sources["ambiguity_annotated_report"] + '''

if __name__ == "__main__":
    # the flagship four-key pair: identical readings, increments 0 and 80/149
    p = [0.25] * 4
    x = [1.0, 2.0, 3.0, 4.0]          # footprint
    z = [1.0, 1.0, 0.0, 0.0]          # candidate feature
    for name, y in (("suppressed", [0.7, -0.4, -0.3, 1.0]),
                    ("active", [0.3, 0.4, -0.7, 1.0])):
        report = ambiguity_annotated_report(p, x, z, y)
        print(name, {k: round(v, 6) for k, v in report.items()})
'''
    code2 = header + sources["adversarial_pair"] + '''

if __name__ == "__main__":
    for gap in (0.10, 0.50, 0.90, 16 / 17):
        built = adversarial_pair(gap)
        assert built is not None
        y_b, y_c, realised = built
        print(f"requested {gap:.6f}  realised {realised:.6f}")
        print(f"   suppressed target {[round(v, 5) for v in y_b]}")
        print(f"   active     target {[round(v, 5) for v in y_c]}")
    print("beyond 16/17:", adversarial_pair(0.99))
'''
    code3 = header + sources["audit_legacy_dashboard"] + '''

if __name__ == "__main__":
    # a published report that cannot certify a 10% decision threshold
    print(audit_legacy_dashboard(5 / 149, 4 / 149, 0.8, threshold=0.10))
    # a report whose ambiguity is too small to matter
    print(audit_legacy_dashboard(0.01, 1e-7, 0.3, threshold=0.10))
'''

    return {
        "title": "Inadmissibility of Sign-Blind Dial Reporting: "
                 "The One-Bit Defect in Variance-Share Dashboards",
        "domain": "Algebra",
        "description": (
            "No function of the three variance-share readings R^2(x,y), R^2(z,y), R^2(x,z) "
            "can return the augmentation increment of a regression, and the counterexamples "
            "fill an open region of moment space; the resulting ambiguity is a two-point set "
            "of exact width 4*sqrt(R^2(x,y)R^2(z,y)R^2(x,z))/(1 - R^2(x,z)), capped by "
            "2*sqrt(R^2(x,z))/(1 + sqrt(R^2(x,z))) < 1, and is repaired by logging a single "
            "sign bit."
        ),
        "authors": ["Aristotle"],
        "date": "2026-09-12",
        "key_results": [
            "Inadmissibility of sign-blind reporting: no function of the three variance "
            "shares R^2(x,y), R^2(z,y), R^2(x,z) returns the augmentation increment on all "
            "finite populations, the failure already occurring on four-key populations.",
            "Robustness of the failure: an explicit two-parameter family of "
            "dashboard-identical population pairs whose witnessing parameters contain an "
            "open ball, on which the readings genuinely vary while the increment gap stays "
            "at least 1/3.",
            "Exact invariant content: the increment equals (R^2(z,y) + R^2(x,y)R^2(x,z) - "
            "2P)/(1 - R^2(x,z)) where P is the correlation triple product, and P^2 equals "
            "the product of the three readings, so the dashboard destroys exactly one sign "
            "bit.",
            "Ambiguity dichotomy and vanishing criterion: populations with identical "
            "readings either report equal increments or increments differing by exactly "
            "4*sqrt(R^2(x,y)R^2(z,y)R^2(x,z))/(1 - R^2(x,z)), and this amplitude vanishes "
            "precisely when one of the three readings is zero.",
            "Greatest concealable share 16/17, attained at the irrational parameters b = 1, "
            "u = sqrt(5), together with the universal ceiling "
            "2*sqrt(R^2(x,z))/(1 + sqrt(R^2(x,z))) < 1 derived from Cauchy-Schwarz through "
            "the correlation Gram determinant, and the one-bit repair recovering the "
            "increment exactly.",
        ],
        "keywords": [
            "partial correlation", "suppression", "variance share", "sign invariants",
            "Gram determinant", "incremental validity", "moment geometry",
            "ambiguity amplitude",
        ],
        "article": article,
        "research_paper": paper,
        "research_paper_tex": tex,
        "demo": demo,
        "demos": [
            {
                "name": "End-to-End Verification of the Sign-Blind Reporting Theorems",
                "description": (
                    "A single self-contained script that rebuilds every result from weighted "
                    "second moments in exact rational arithmetic wherever possible. It "
                    "constructs the four-key stage (footprint (1,2,3,4), feature (1,1,0,0), "
                    "uniform weights) and its two-dimensional residual plane; exhibits the "
                    "flagship pair of targets with common variance 149/400, identical "
                    "readings (5/149, 4/149, 4/5) and increments 0 and 80/149; verifies the "
                    "partial-correlation form, the dashboard form and the identity "
                    "P^2 = a*c*e; checks that the observed increment gap equals the predicted "
                    "amplitude 4*sqrt(a c e)/(1-e) and that the amplitude vanishes exactly "
                    "when a reading is zero; sweeps the open ball of radius 1/100 about the "
                    "base parameters confirming both the uniform gap of at least 1/3 and the "
                    "genuine variation of the readings; locates the family maximum 16/17 on "
                    "the ray u = sqrt(5) b; validates the total-share bound, the Gram "
                    "inequality and the universal ceiling; and closes with a randomised audit "
                    "over thousands of pseudo-random five-key populations in which the "
                    "repaired predictor is exact to machine precision."
                ),
                "code": demo,
            }
        ],
        "algorithms": [
            {
                "name": "Ambiguity-Annotated Augmentation Report",
                "description": (
                    "The drop-in upgrade for any reporting pipeline. From the raw population "
                    "it computes the six weighted second moments, the three variance-share "
                    "readings a = R^2(x,y), c = R^2(z,y), e = R^2(x,z), the correlation triple "
                    "product P and its sign bit, and then returns the exact increment "
                    "(c + a e - 2 P)/(1 - e) together with the value a sign-blind reader could "
                    "not have excluded, (c + a e + 2 P)/(1 - e), the exact ambiguity amplitude "
                    "A = 4 sqrt(a c e)/(1 - e), and the universal ceiling "
                    "2 sqrt(e)/(1 + sqrt(e)). It also reports the total explained share "
                    "a + increment (which the Cauchy-Schwarz bound keeps at most 1) and the "
                    "Gram slack 1 - a - c - e + 2P (which positive semidefiniteness keeps "
                    "nonnegative), so anomalies in the input data surface immediately. "
                    "Complexity is O(n) in the number of population keys for the moment pass "
                    "plus O(1) arithmetic, so the annotation is free relative to computing the "
                    "readings themselves. The routine raises on the degenerate case e = 1, "
                    "where the candidate feature is an affine function of the footprint and no "
                    "increment is defined."
                ),
                "pseudocode": (
                    "INPUT weights p, footprint x, feature z, target y\n"
                    "1.  for f, g in {(x,x),(y,y),(z,z),(x,y),(x,z),(z,y)}\n"
                    "2.      cov(f,g) <- sum_i p_i f_i g_i - (sum_i p_i f_i)(sum_i p_i g_i)\n"
                    "3.  if min(var x, var y, var z) <= 0 then ERROR 'degenerate feature'\n"
                    "4.  rho_xy <- cov(x,y)/sqrt(var x * var y)\n"
                    "5.  rho_xz <- cov(x,z)/sqrt(var x * var z)\n"
                    "6.  rho_zy <- cov(z,y)/sqrt(var z * var y)\n"
                    "7.  (a, c, e) <- (rho_xy^2, rho_zy^2, rho_xz^2)\n"
                    "8.  if e >= 1 then ERROR 'feature is affine in the footprint'\n"
                    "9.  P <- rho_xy * rho_xz * rho_zy ;  s <- +1 if P >= 0 else -1\n"
                    "10. absP <- sqrt(a*c*e)                       // equals |P| exactly\n"
                    "11. increment <- (c + a*e - 2*s*absP)/(1 - e)\n"
                    "12. shadow    <- (c + a*e + 2*s*absP)/(1 - e) // the value signs exclude\n"
                    "13. amplitude <- 4*absP/(1 - e)\n"
                    "14. ceiling   <- 2*sqrt(e)/(1 + sqrt(e))\n"
                    "15. RETURN (a, c, e, P, s, increment, shadow, amplitude, ceiling,\n"
                    "            a + increment, 1 - a - c - e + 2*P)"
                ),
                "code": code1,
            },
            {
                "name": "Adversarial Dashboard-Identical Pair Generator",
                "description": (
                    "Given a target gap g, manufactures two four-key populations that agree on "
                    "all three variance-share readings and on the target variance, carry "
                    "exactly opposite signed feature covariances, and report increments 0 and "
                    "g. The construction places both targets in the two-dimensional residual "
                    "plane spanned by eps = (1,-1,-1,1) and the partialled feature "
                    "zt = (-1/10, 3/10, -3/10, 1/10): the suppressed target is "
                    "b*x + (u + 5b^2/u)*eps and the active one is b*x + (u - 5b^2/u)*eps + "
                    "20b*zt, where the coefficient 20b is exactly what reverses the sign of the "
                    "feature covariance and the shift +-5b^2/u is exactly what preserves the "
                    "variance. Normalising b = 1 and writing t = u^2, the active increment is "
                    "80t/(4t^2 + 45t + 100), so the required parameter solves the quadratic "
                    "4g t^2 + (45g - 80) t + 100g = 0; the discriminant is nonnegative exactly "
                    "for g <= 16/17, which is the sharp feasibility threshold. Complexity is "
                    "O(1): one quadratic solve and two four-vector assemblies."
                ),
                "pseudocode": (
                    "INPUT desired increment gap g\n"
                    "1.  if g <= 0 or g > 16/17 then RETURN infeasible\n"
                    "2.  (A, B, C) <- (4g, 45g - 80, 100g)\n"
                    "3.  disc <- B^2 - 4AC        // nonnegative exactly when g <= 16/17\n"
                    "4.  t <- (-B - sqrt(disc)) / (2A) ; if t <= 0 then t <- (-B + sqrt(disc))/(2A)\n"
                    "5.  u <- sqrt(t) ;  b <- 1\n"
                    "6.  x <- (1,2,3,4) ; eps <- (1,-1,-1,1) ; zt <- (-1/10,3/10,-3/10,1/10)\n"
                    "7.  y_B <- b*x + (u + 5b^2/u)*eps\n"
                    "8.  y_C <- b*x + (u - 5b^2/u)*eps + 20b*zt\n"
                    "9.  realised <- 80 b^2 t / (5 b^2 t + 4 (t + 5 b^2)^2)\n"
                    "10. RETURN (y_B, y_C, realised)"
                ),
                "code": code2,
            },
            {
                "name": "Legacy Sign-Blind Report Auditor",
                "description": (
                    "For a published report consisting only of the three variance shares, "
                    "decides whether the report is capable of certifying a decision taken at a "
                    "given threshold on the increment. Because the triple product satisfies "
                    "P^2 = a c e, exactly two increments are consistent with the report, namely "
                    "(c + a e -+ 2 sqrt(a c e))/(1 - e); their separation is the ambiguity "
                    "amplitude. The auditor returns both admissible values, the separation, the "
                    "universal ceiling for that collinearity reading, and a verdict: CERTIFIED "
                    "when both values fall on the same side of the threshold, so no sign "
                    "information could change the decision, and INDETERMINATE when they "
                    "straddle it, in which case the underlying signed covariances must be "
                    "retrieved. Since the separation vanishes only when one of the readings is "
                    "zero, certification is the exception rather than the rule. Complexity "
                    "O(1)."
                ),
                "pseudocode": (
                    "INPUT readings a, c, e and decision threshold tau\n"
                    "1.  if e < 0 or e >= 1 then ERROR 'collinearity reading out of range'\n"
                    "2.  absP <- sqrt(a*c*e)                    // determined by the report\n"
                    "3.  lo <- (c + a*e - 2*absP)/(1 - e)\n"
                    "4.  hi <- (c + a*e + 2*absP)/(1 - e)\n"
                    "5.  amplitude <- hi - lo                   // = 4 sqrt(a c e)/(1 - e)\n"
                    "6.  ceiling   <- 2*sqrt(e)/(1 + sqrt(e))\n"
                    "7.  straddle  <- (lo < tau) XOR (hi < tau)\n"
                    "8.  verdict   <- 'INDETERMINATE' if straddle else 'CERTIFIED'\n"
                    "9.  RETURN (lo, hi, amplitude, ceiling, verdict)"
                ),
                "code": code3,
            },
        ],
        "visualizations": [
            {
                "name": "Concealable Share Along the Witness Family Against the Universal Ceiling",
                "description": (
                    "Plots the share of target variance that the sign-blind dashboard fails to "
                    "attribute, S(t) = 80 t^2 / (5 t^2 + 4 (t^2 + 5)^2), as a function of the "
                    "shape parameter t = u/b of the two-parameter family. The curve rises to the "
                    "exact maximum 16/17 at t = sqrt(5) — the vanishing locus of the perfect "
                    "square (u^2 - 5b^2)^2 that proves the bound — and is shown against the "
                    "universal ceiling 4/(2 + sqrt 5) at the family's collinearity reading "
                    "e = 4/5, making visible how the explicit construction reaches 99.7% of the "
                    "theoretical maximum."
                ),
                "code": viz1,
            },
            {
                "name": "The Ambiguity Landscape and the Sharpness of the Universal Ceiling",
                "description": (
                    "A two-panel study of how large the sign-blind ambiguity can be. The left "
                    "panel maps the amplitude 4 sqrt(a c e)/(1 - e) over the plane of readings "
                    "(a, c) at fixed collinearity e = 4/5, masked outside the sign-ambiguous "
                    "region 2 sqrt(a c e) <= 1 - a - c - e where both signs of the triple "
                    "product are realisable; it marks the flagship four-key pair (5/149, 4/149) "
                    "and the algebraic maximiser a = c = (1 - e)/(2(1 + sqrt e)), at which the "
                    "amplitude equals the ceiling. The right panel traces the ceiling "
                    "2 sqrt(e)/(1 + sqrt(e)) against e alongside the amplitude maximised "
                    "numerically over the feasible region, showing the bound to be sharp, and "
                    "marks the family's peak 16/17."
                ),
                "code": viz2,
            },
        ],
        "interactive_demos": [
            {
                "title": "The Sign-Blind Dashboard Laboratory",
                "description": (
                    "A three-panel interactive laboratory built directly on weighted second "
                    "moments of four-key populations, computed live in the browser. Panel 1, "
                    "'Two worlds, one dashboard', lets the reader slide the shape parameter u/b "
                    "and the scale b of the witness family and watch two target profiles change "
                    "while the three variance-share readings and the target variance stay "
                    "provably identical (green 'identical' badges) and the two increment bars "
                    "diverge; presets jump to the flagship pair at u/b = 5 (increments 0 and "
                    "80/149) and to the extremal ratio u/b = sqrt(5), where the concealable "
                    "share reaches its maximum 16/17. The panel simultaneously exposes what the "
                    "dashboard hides: the signed feature covariance, the correlation triple "
                    "product and its sign bit. Panel 2, 'The correlation triple', gives direct "
                    "control of the three signed correlations and displays the readings, the "
                    "triple product, both admissible increments, their exact separation, the "
                    "universal ceiling, and whether the positive-semidefiniteness constraint "
                    "actually permits the sign-flipped twin — inviting the reader to discover "
                    "that flipping one sign moves the increment while flipping two changes "
                    "nothing. Panel 3, 'Audit a legacy report', turns the theory into a tool: "
                    "enter three published readings and a decision threshold and receive the "
                    "only two increments consistent with them, their separation, and a "
                    "CERTIFIED or INDETERMINATE verdict."
                ),
                "html": widget,
            }
        ],
        "interactive_layout": INTERACTIVE_LAYOUT,
        "lean_proofs": lean_source,
        "future_directions": FUTURE_DIRECTIONS,
        "modules": {"demo": demo},
        "lean_files": LEAN_FILES,
    }


if __name__ == "__main__":
    pkg = build()
    out = ROOT / "PACKAGE.json"
    out.write_text(json.dumps(pkg, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"wrote {out} ({out.stat().st_size} bytes)")
    for k in ("title", "domain", "date"):
        print(f"  {k}: {pkg[k]}")
    print(f"  key_results: {len(pkg['key_results'])}, demos: {len(pkg['demos'])}, "
          f"algorithms: {len(pkg['algorithms'])}, visualizations: {len(pkg['visualizations'])}, "
          f"interactive_demos: {len(pkg['interactive_demos'])}")


"""The ambiguity landscape and the universal ceiling.

Left panel: for the collinearity reading e = 4/5, the ambiguity amplitude
A(a,c) = 4 sqrt(a c e) / (1 - e) over the plane of the remaining two readings,
masked outside the sign-ambiguous region 2 sqrt(a c e) <= 1 - a - c - e (the
constraint that both signs of the correlation triple product be realisable).  The
flagship four-key pair (a, c) = (5/149, 4/149) is marked, as is the algebraic
maximiser a = c = (1 - e) / (2 (1 + sqrt e)), where the amplitude equals the
universal ceiling exactly.

Right panel: the universal ceiling 2 sqrt(e)/(1 + sqrt(e)) against e, compared with
the amplitude maximised numerically over the feasible region at each e.  The numerical maximum
tracks the ceiling to grid resolution, showing that the ceiling is algebraically
sharp; the family's peak 16/17 at e = 4/5 sits just below it.
"""

from __future__ import annotations

import math
from typing import List, Tuple

import matplotlib.pyplot as plt
import numpy as np


def amplitude(a: float, c: float, e: float) -> float:
    """A = 4 sqrt(a c e) / (1 - e)."""
    return 4.0 * math.sqrt(max(a * c * e, 0.0)) / (1.0 - e)


def sign_ambiguous(a: float, c: float, e: float) -> bool:
    """Both signs of the triple product admissible: 2 sqrt(a c e) <= 1 - a - c - e."""
    return 2.0 * math.sqrt(max(a * c * e, 0.0)) <= 1.0 - a - c - e + 1e-15


def ceiling(e: float) -> float:
    """2 sqrt(e) / (1 + sqrt(e))."""
    se = math.sqrt(e)
    return 2.0 * se / (1.0 + se)


def numeric_max_amplitude(e: float, n: int = 500) -> float:
    """Maximise the amplitude over the sign-ambiguous region at fixed e."""
    best = 0.0
    for i in range(1, n):
        a = i / n * (1.0 - e)
        for j in range(1, n // 4):
            c = j / (n // 4) * (1.0 - e)
            if sign_ambiguous(a, c, e):
                best = max(best, amplitude(a, c, e))
    return best


def main() -> None:
    e = 0.8
    grid = np.linspace(1e-4, 1.0 - e, 400)
    A, C = np.meshgrid(grid, grid)
    Z = 4.0 * np.sqrt(A * C * e) / (1.0 - e)
    feasible = 2.0 * np.sqrt(A * C * e) <= 1.0 - A - C - e
    Z = np.where(feasible, Z, np.nan)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13.5, 5.6))

    im = ax1.contourf(A, C, Z, levels=24, cmap="magma")
    fig.colorbar(im, ax=ax1, label="ambiguity amplitude $A$")
    a_star = (1.0 - e) / (2.0 * (1.0 + math.sqrt(e)))
    ax1.plot([a_star], [a_star], "*", ms=17, color="#2ecc71",
             label=fr"algebraic maximiser $a=c={a_star:.4f}$, $A={ceiling(e):.5f}$")
    ax1.plot([5 / 149], [4 / 149], "o", ms=9, color="#00d0ff",
             label=r"four-key pair $(5/149,\,4/149)$, $A=80/149$")
    ax1.set_xlabel(r"$a = R^2(x,y)$", fontsize=12)
    ax1.set_ylabel(r"$c = R^2(z,y)$", fontsize=12)
    ax1.set_title(r"Ambiguity amplitude on the sign-ambiguous region, $e = 4/5$",
                  fontsize=12.5)
    ax1.legend(loc="upper right", fontsize=9.5, framealpha=0.92)

    es: List[float] = [0.02 * k for k in range(1, 50)]
    ceil_vals = [ceiling(v) for v in es]
    num_vals = [numeric_max_amplitude(v, n=240) for v in es]
    ax2.plot(es, ceil_vals, lw=2.6, color="#117a65",
             label=r"ceiling $2\sqrt{e}/(1+\sqrt{e})$")
    ax2.plot(es, num_vals, "--", lw=1.8, color="#c0392b",
             label="amplitude maximised numerically over the region")
    ax2.axhline(1.0, ls=":", color="grey", lw=1.2)
    ax2.plot([0.8], [16 / 17], "o", ms=9, color="#1f4e79",
             label=r"family peak $16/17$ at $e=4/5$")
    ax2.set_xlabel(r"collinearity reading $e = R^2(x,z)$", fontsize=12)
    ax2.set_ylabel("maximum misattribution", fontsize=12)
    ax2.set_ylim(0.0, 1.06)
    ax2.set_title("The universal ceiling is algebraically sharp", fontsize=12.5)
    ax2.grid(alpha=0.28)
    ax2.legend(loc="lower right", fontsize=10)

    fig.tight_layout()
    fig.savefig("ambiguity_landscape.png", dpi=160)
    print("wrote ambiguity_landscape.png")


if __name__ == "__main__":
    main()


"""Concealable share along the witness family, against the universal ceiling.

Plots, as a function of the shape parameter t = u/b of the two-parameter family of
dashboard-identical population pairs:

  * the increment reported by the active member,
    S(t) = 80 t^2 / (5 t^2 + 4 (t^2 + 5)^2)  -- this is also the exact gap, since the
    suppressed member always reports 0;
  * the family maximum 16/17, attained at t = sqrt(5);
  * the universal ceiling 2 sqrt(e) / (1 + sqrt(e)) at the family's collinearity
    reading e = R^2(footprint, feature) = 4/5, i.e. 4/(2 + sqrt 5).

The picture makes visible how close the explicit construction comes to the
theoretical maximum: 16/17 = 0.94118 against 4/(2+sqrt5) = 0.94427.
"""

from __future__ import annotations

import math
from typing import List

import matplotlib.pyplot as plt


def concealable_share(t: float) -> float:
    """Increment of the active member at shape parameter t = u / b."""
    return 80.0 * t * t / (5.0 * t * t + 4.0 * (t * t + 5.0) ** 2)


def main() -> None:
    ts: List[float] = [0.05 * k for k in range(1, 241)]
    shares: List[float] = [concealable_share(t) for t in ts]
    peak_t = math.sqrt(5.0)
    peak = 16.0 / 17.0
    ceiling = 4.0 / (2.0 + math.sqrt(5.0))

    fig, ax = plt.subplots(figsize=(9.5, 5.6))
    ax.plot(ts, shares, lw=2.4, color="#1f4e79",
            label=r"concealable share $S(t)=\frac{80t^2}{5t^2+4(t^2+5)^2}$")
    ax.axhline(peak, ls="--", lw=1.6, color="#c0392b",
               label=r"family maximum $16/17 \approx 0.94118$")
    ax.axhline(ceiling, ls=":", lw=1.8, color="#117a65",
               label=r"universal ceiling $4/(2+\sqrt5) \approx 0.94427$")
    ax.plot([peak_t], [peak], "o", ms=9, color="#c0392b", zorder=5)
    ax.annotate(r"$t=\sqrt5$,  $S=16/17$", xy=(peak_t, peak),
                xytext=(peak_t + 1.4, peak - 0.16),
                arrowprops=dict(arrowstyle="->", color="#c0392b"), fontsize=11,
                color="#c0392b")
    ax.set_xlim(0.0, 12.0)
    ax.set_ylim(0.0, 1.02)
    ax.set_xlabel(r"shape parameter $t = u/b$", fontsize=12)
    ax.set_ylabel(r"share of target variance concealed", fontsize=12)
    ax.set_title("How much a sign-blind dashboard can hide, along the witness family",
                 fontsize=13.5)
    ax.grid(alpha=0.28)
    ax.legend(loc="lower right", fontsize=10.5, framealpha=0.95)
    fig.tight_layout()
    fig.savefig("family_concealable_share.png", dpi=160)
    print("wrote family_concealable_share.png")


if __name__ == "__main__":
    main()
