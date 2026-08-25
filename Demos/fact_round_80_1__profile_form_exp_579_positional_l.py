"""
Profile Form: numerical demonstrations
======================================

Self-contained numerical companion to the results on the positional hit
profile of a semiprime factor search and its beyond-background residual.

Everything here uses only the Python standard library (``math``, ``random``,
``statistics``), so it runs anywhere with ``python3 demo.py``.

The demonstrations, in order:

1.  Scale multiplicativity of the power law, and the rigidity theorem in
    action: recovering the exponent of an unknown scale-multiplicative
    profile from two function values.
2.  The log-midpoint defect that separates the power law from the
    exponential, logistic and affine families simultaneously.
3.  The window decline factor 3^b bracketed over the bootstrap interval.
4.  Akaike weights: monotonicity, the one-half cap from a tied rival, and
    the measured verdict w(9.2, 11.5, 16.9) > 0.98.
5.  The exponent-one threshold: total window mass, finite iff b > 1, with
    the measured interval straddling it.
6.  The uniform scale-mixture background M(x) = (1-e^{-x})/x, its
    1/(2x) <= M <= 1/x squeeze, and the absorption of the decline.
7.  The endpoint-pinned residual family, its sharp curvature threshold at
    c = -1/10, and invariance of the peak over the reported interval.
8.  Counterexamples: a two-atom mixture whose residual peaks, and the
    uniform mixture's own hump near x = 10.
9.  The hump-location law x* = 1/(b-1), and a bisection for the critical
    exponent b_c at which the hump disappears.
"""

from __future__ import annotations

import math
import random
from statistics import mean
from typing import Callable, List, Sequence, Tuple

# ----------------------------------------------------------------------
# Core objects
# ----------------------------------------------------------------------


def power_profile(amplitude: float, exponent: float, x: float) -> float:
    """The profile-form family T(x) = A (1+x)^(-b), defined for x > -1."""
    return amplitude * (1.0 + x) ** (-exponent)


def scale_compose(x: float, y: float) -> float:
    """The shift-scale group law x * y = (1+x)(1+y) - 1 on (-1, oo)."""
    return (1.0 + x) * (1.0 + y) - 1.0


def exp_profile(c: float, k: float, x: float) -> float:
    """Exponential rival family C exp(-k x)."""
    return c * math.exp(-(k * x))


def logistic_profile(c: float, k: float, x0: float, x: float) -> float:
    """Logistic rival family C / (1 + exp(k (x - x0)))."""
    return c / (1.0 + math.exp(k * (x - x0)))


def affine_profile(p: float, q: float, x: float) -> float:
    """Linear (affine) rival family p + q x."""
    return p + q * x


def log_midpoint_defect(f: Callable[[float], float], t: float, h: float) -> float:
    """D_f(t,h) = f(t-h) f(t+h) - f(t)^2.  Positive <=> midpoint log-convex."""
    return f(t - h) * f(t + h) - f(t) ** 2


def mixture_baseline(x: float) -> float:
    """Uniform scale mixture of exponential regimes, M(x) = (1 - e^{-x}) / x."""
    if x == 0.0:
        return 1.0
    return (1.0 - math.exp(-x)) / x


def two_atom_baseline(x: float) -> float:
    """Two-atom positive scale mixture (1/2) e^{-x/20} + (1/2) e^{-8x}."""
    return 0.5 * math.exp(-x / 20.0) + 0.5 * math.exp(-8.0 * x)


def tail_residual(b: float, x: float) -> float:
    """The elementary factor tau_b(x) = x (1+x)^{-b} of the residual."""
    return x * (1.0 + x) ** (-b)


def hump_location(b: float) -> float:
    """The hump-location law x* = 1/(b-1), valid for b > 1."""
    return 1.0 / (b - 1.0)


def uniform_residual(b: float, x: float) -> float:
    """The true residual T/M of a unit-amplitude power law against M."""
    return power_profile(1.0, b, x) / mixture_baseline(x)


def residual_quad(c: float, x: float) -> float:
    """Endpoint-pinned quadratic fit: R_c(0) = 0.8, R_c(1) = 0.9, curvature c."""
    return 4.0 / 5.0 + (1.0 / 10.0 - c) * x + c * x * x


def residual_quad_vertex(c: float) -> float:
    """Apex of R_c, at (1/10 - c) / (-2c)."""
    return (1.0 / 10.0 - c) / (-2.0 * c)


def window_mass(b: float, big_x: float) -> float:
    """Closed-form total profile mass on [0, X]:  (  (1+X)^{1-b} - 1 ) / (1-b),
    with the critical case b = 1 given by log(1+X)."""
    if abs(b - 1.0) < 1e-15:
        return math.log(1.0 + big_x)
    return ((1.0 + big_x) ** (1.0 - b) - 1.0) / (1.0 - b)


def akaike_weight(d1: float, d2: float, d3: float) -> float:
    """Akaike weight of the best model in a four-model comparison."""
    return 1.0 / (1.0 + math.exp(-d1 / 2) + math.exp(-d2 / 2) + math.exp(-d3 / 2))


# Measured constants of the experiment.
A_FIT: float = 0.0295
B_FIT: float = 1.104
B_LO, B_HI = 0.991, 1.218
C_LO, C_HI = -0.62, -0.14


def banner(title: str) -> None:
    print()
    print("=" * 72)
    print(title)
    print("=" * 72)


# ----------------------------------------------------------------------
# 1.  Rigidity
# ----------------------------------------------------------------------


def demo_rigidity() -> None:
    banner("1. Scale multiplicativity and the rigidity theorem")

    print("The law:  T(0) T(x*y) = T(x) T(y)  with  x*y = (1+x)(1+y) - 1")
    print(f"{'x':>6} {'y':>6} {'T(0)T(x*y)':>14} {'T(x)T(y)':>14} {'|diff|':>10}")
    for x, y in [(0.3, 0.7), (1.0, 2.0), (0.05, 4.0), (-0.5, 3.0)]:
        lhs = power_profile(A_FIT, B_FIT, 0.0) * power_profile(
            A_FIT, B_FIT, scale_compose(x, y)
        )
        rhs = power_profile(A_FIT, B_FIT, x) * power_profile(A_FIT, B_FIT, y)
        print(f"{x:6.2f} {y:6.2f} {lhs:14.10f} {rhs:14.10f} {abs(lhs - rhs):10.2e}")

    print()
    print("Rigidity in action.  Suppose we are handed an unknown positive,")
    print("continuous, scale-multiplicative profile.  The theorem says it must")
    print("be A (1+x)^(-b); so two evaluations determine it completely.")

    def mystery(x: float) -> float:
        # Deliberately written in a different-looking form: it is
        # 0.0295 * exp(-1.104 * log(1+x)), i.e. the same law in disguise.
        return 0.0295 * math.exp(-1.104 * math.log1p(x))

    amp = mystery(0.0)
    b_recovered = -math.log(mystery(1.0) / amp) / math.log(2.0)
    print(f"  recovered amplitude A = {amp:.6f}   (true {A_FIT})")
    print(f"  recovered exponent  b = {b_recovered:.6f}   (true {B_FIT})")
    worst = max(
        abs(mystery(x) - power_profile(amp, b_recovered, x))
        for x in [i / 20 for i in range(0, 41)]
    )
    print(f"  worst-case reconstruction error on [0,2]: {worst:.2e}")


# ----------------------------------------------------------------------
# 2.  The separating invariant
# ----------------------------------------------------------------------


def demo_separating_invariant() -> None:
    banner("2. The log-midpoint defect separates the winner from all rivals")

    t, h = 1.0, 1.0
    families: List[Tuple[str, Callable[[float], float]]] = [
        ("power  A(1+x)^-b", lambda x: power_profile(A_FIT, B_FIT, x)),
        ("exponential Ce^-kx", lambda x: exp_profile(0.03, 0.8, x)),
        ("logistic", lambda x: logistic_profile(0.06, 2.0, 0.5, x)),
        ("affine p + qx", lambda x: affine_profile(0.03, -0.01, x)),
    ]
    print(f"defect D_f(t,h) = f(t-h) f(t+h) - f(t)^2   at t = {t}, h = {h}")
    print(f"{'family':>20} {'defect':>16} {'sign':>8}")
    for name, f in families:
        d = log_midpoint_defect(f, t, h)
        scale = max(abs(f(t)) ** 2, 1e-300)
        rel = d / scale
        sign = "+" if rel > 1e-12 else ("0" if abs(rel) <= 1e-12 else "-")
        print(f"{name:>20} {d:16.3e} {sign:>8}")
    print()
    print("The power law is the only strictly log-midpoint-convex family here,")
    print("so no exponential / logistic / affine curve can equal it identically.")

    print()
    print("The affine defect is exactly -q^2 h^2:")
    for q in (-0.01, 0.5, 3.0):
        d = log_midpoint_defect(lambda x: affine_profile(0.03, q, x), t, h)
        print(f"  q = {q:6.2f}:  defect = {d:12.6f},  -q^2 h^2 = {-q * q * h * h:12.6f}")


# ----------------------------------------------------------------------
# 3.  Decline factor
# ----------------------------------------------------------------------


def demo_decline_factor() -> None:
    banner("3. Window decline factor T(0)/T(2) = 3^b")

    print(f"{'b':>8} {'3^b':>10}")
    for b in (B_LO, 1.0, B_FIT, B_HI):
        print(f"{b:8.3f} {3.0 ** b:10.4f}")
    lo, hi = 3.0 ** B_LO, 3.0 ** B_HI
    print()
    print(f"bracket over the bootstrap interval: ({lo:.4f}, {hi:.4f})")
    print(f"proved bracket (2.8, 4.1) contains it: {2.8 < lo and hi < 4.1}")
    print(f"measured raw decline 3.25 inside the bracket: {lo < 3.25 < hi}")


# ----------------------------------------------------------------------
# 4.  Akaike weights
# ----------------------------------------------------------------------


def demo_akaike() -> None:
    banner("4. Akaike weights: monotone, capped by a tie, and the verdict")

    w = akaike_weight(9.2, 11.5, 16.9)
    print(f"measured gaps (9.2, 11.5, 16.9)  ->  w = {w:.6f}   (>0.98: {w > 0.98})")
    print()
    print("Monotone in each gap:")
    for d in (0.0, 2.0, 4.0, 9.2, 20.0):
        print(f"  w({d:5.1f}, 11.5, 16.9) = {akaike_weight(d, 11.5, 16.9):.6f}")
    print()
    print("A tied rival caps the weight at 1/2 no matter how bad the others are:")
    for d in (5.0, 20.0, 40.0):
        cap = akaike_weight(0.0, d, d)
        print(f"  w(0, {d:6.1f}, {d:6.1f}) = {cap:.12f}   (< 0.5: {cap < 0.5})")
    print()
    print("Saturation as all gaps grow:")
    for d in (5.0, 20.0, 60.0):
        print(f"  w({d}, {d}, {d}) = {akaike_weight(d, d, d):.9f}")


# ----------------------------------------------------------------------
# 5.  The exponent-one threshold
# ----------------------------------------------------------------------


def demo_exponent_threshold() -> None:
    banner("5. The exponent-one threshold for total window mass")

    print("Closed form checked against a Riemann sum on [0, 5]:")
    for b in (0.95, 1.0, 1.104):
        n = 200000
        approx = sum(
            (1.0 + (i + 0.5) * 5.0 / n) ** (-b) * (5.0 / n) for i in range(n)
        )
        print(f"  b = {b:6.3f}: closed form {window_mass(b, 5.0):.8f}"
              f"   quadrature {approx:.8f}")

    print()
    print("Behaviour of the total mass as the window widens:")
    header = f"{'X':>10}" + "".join(f"{b:>14.3f}" for b in (0.991, 1.0, 1.104, 1.218))
    print(header.replace("     0.991", "   b=0.991"))
    for big_x in (10.0, 1e3, 1e6, 1e12):
        row = f"{big_x:10.0e}"
        for b in (0.991, 1.0, 1.104, 1.218):
            row += f"{window_mass(b, big_x):14.4f}"
        print(row)
    print()
    for b in (1.104, 1.218):
        print(f"  b = {b}: limit 1/(b-1) = {1.0 / (b - 1.0):.4f}")
    print("  b = 1.000: limit is infinite (log divergence)")
    print("  b = 0.991: limit is infinite (power divergence)")
    print()
    print("So the bootstrap interval [0.991, 1.218] straddles the threshold:")
    print("  the shape of the profile is pinned; the finiteness of its mass is not.")

    print()
    print("Discrete counterpart, log(n+1) <= sum_{j<n} 1/(j+1):")
    total = 0.0
    for n in range(1, 100001):
        total += 1.0 / n
        if n in (10, 100, 1000, 100000):
            print(f"  n = {n:6d}:  log(n+1) = {math.log(n + 1):9.5f}"
                  f"   harmonic = {total:9.5f}")


# ----------------------------------------------------------------------
# 6.  Absorption
# ----------------------------------------------------------------------


def demo_absorption() -> None:
    banner("6. The mixture background absorbs the harmonic gradient")

    print("M(x) = (1 - e^{-x})/x  is squeezed between 1/(2x) and 1/x for x >= 1:")
    print(f"{'x':>8} {'1/(2x)':>12} {'M(x)':>12} {'1/x':>12}")
    for x in (1.0, 2.0, 3.0, 10.0):
        print(f"{x:8.2f} {1 / (2 * x):12.6f} {mixture_baseline(x):12.6f} {1 / x:12.6f}")

    print()
    print("M is also exactly the uniform mixture of exponentials, integral_0^1 e^{-xs} ds:")
    for x in (0.7, 3.0, 9.0):
        n = 200000
        quad = sum(math.exp(-x * (i + 0.5) / n) / n for i in range(n))
        print(f"  x = {x:4.1f}:  closed form {mixture_baseline(x):.9f}"
              f"   quadrature {quad:.9f}")

    print()
    print("Absorption bounds  A x (1+x)^-b <= R(x) <= 2 A x (1+x)^-b  on x >= 1:")
    print(f"{'x':>8} {'lower':>12} {'R(x)':>12} {'upper':>12}")
    for x in (1.0, 2.0, 3.0, 8.0):
        low = A_FIT * x * (1 + x) ** (-B_FIT)
        r = power_profile(A_FIT, B_FIT, x) / mixture_baseline(x)
        print(f"{x:8.2f} {low:12.6f} {r:12.6f} {2 * low:12.6f}")

    print()
    print("Decline across [1,3] is at most two thirds of the raw decline:")
    print(f"{'b':>8} {'R(1)/R(3)':>12} {'(2/3)T(1)/T(3)':>16}")
    for b in (0.5, 1.0, B_FIT, 2.0):
        rr = (power_profile(A_FIT, b, 1.0) / mixture_baseline(1.0)) / (
            power_profile(A_FIT, b, 3.0) / mixture_baseline(3.0)
        )
        tt = (2.0 / 3.0) * (
            power_profile(A_FIT, b, 1.0) / power_profile(A_FIT, b, 3.0)
        )
        print(f"{b:8.3f} {rr:12.6f} {tt:16.6f}")
    print()
    print("Measured: background falls 3.64x while the raw profile falls 3.25x,")
    print("so the background absorbs the whole decline and slightly over-absorbs.")


# ----------------------------------------------------------------------
# 7.  The peaked residual and its sharp threshold
# ----------------------------------------------------------------------


def demo_residual_peak() -> None:
    banner("7. The residual hump and the sharp curvature threshold c = -1/10")

    c_fit = -5.0 / 9.0
    v = residual_quad_vertex(c_fit)
    print(f"reported fit R(x) = 4/5 + (59/90)x - (5/9)x^2  (curvature c = {c_fit:.6f})")
    print(f"  R(0)     = {residual_quad(c_fit, 0.0):.6f}   (end deficit)")
    print(f"  R(1)     = {residual_quad(c_fit, 1.0):.6f}   (end deficit)")
    print(f"  apex at x = {v:.6f}, height {residual_quad(c_fit, v):.6f}")
    print(f"  apex / R(0) = {residual_quad(c_fit, v) / residual_quad(c_fit, 0.0):.4f}"
          f"  (proved >= 1.20)")
    print(f"  apex / R(1) = {residual_quad(c_fit, v) / residual_quad(c_fit, 1.0):.4f}"
          f"  (proved >= 1.10)")

    print()
    print("Sharp threshold: the apex is interior exactly when c < -1/10.")
    print(f"{'c':>10} {'apex x_c':>12} {'interior?':>11} {'peaked?':>9}")
    for c in (-0.62, -0.30, -0.14, -0.10, -0.05, -0.01):
        xc = residual_quad_vertex(c)
        grid = [i / 500 for i in range(501)]
        vals = [residual_quad(c, x) for x in grid]
        peaked = max(vals) > max(vals[0], vals[-1]) + 1e-12
        print(f"{c:10.3f} {xc:12.6f} {str(0.0 < xc < 1.0):>11} {str(peaked):>9}")

    print()
    print(f"Every curvature in the reported interval [{C_LO}, {C_HI}] is below -0.1;")
    print(f"margin to the threshold: {abs(C_HI - (-0.1)):.2f}")
    print("So the PEAKED verdict is invariant across the reported uncertainty.")

    print()
    print("A peaked residual cannot be a power law, since power laws are monotone:")
    grid = [i / 200 for i in range(201)]
    best_err = float("inf")
    best: Tuple[float, float] = (0.0, 0.0)
    for a_i in range(1, 200):
        amp = 0.8 + a_i * 0.002
        for b_i in range(-200, 201):
            b = b_i * 0.01
            err = max(abs(residual_quad(c_fit, x) - power_profile(amp, b, x))
                      for x in grid)
            if err < best_err:
                best_err, best = err, (amp, b)
    print(f"  best sup-norm power-law approximation on [0,1]: error {best_err:.4f}"
          f" at A = {best[0]:.3f}, b = {best[1]:.2f}")
    print("  (bounded away from zero: the two layers are genuinely different objects)")


# ----------------------------------------------------------------------
# 8.  Counterexamples
# ----------------------------------------------------------------------


def demo_counterexamples() -> None:
    banner("8. Two corrections: humps are cheap, and window-relative")

    print("(a) A genuine positive two-atom mixture whose residual peaks on [0,1].")
    print("    M2(x) = (1/2) e^{-x/20} + (1/2) e^{-8x},  b = 1.1")
    for x in (0.0, 0.1, 0.3, 0.5, 1.0):
        rho = power_profile(1.0, 1.1, x) / two_atom_baseline(x)
        print(f"    x = {x:4.2f}:  T/M2 = {rho:.6f}")
    grid = [i / 1000 for i in range(1001)]
    vals = [power_profile(1.0, 1.1, x) / two_atom_baseline(x) for x in grid]
    arg = grid[max(range(len(vals)), key=lambda i: vals[i])]
    print(f"    interior maximum at x = {arg:.3f}, height {max(vals):.6f}")
    print("    => an interior peak is NOT evidence against a mixture background.")

    print()
    print("(b) The uniform mixture itself humps -- at x near 10, outside the window.")
    for x in (1.0, 3.0, 5.0, 10.0, 20.0, 100.0):
        print(f"    x = {x:6.1f}:  T/M = {uniform_residual(1.1, x):.6f}")
    grid2 = [3.0 + i * 0.01 for i in range(9701)]
    vals2 = [uniform_residual(1.1, x) for x in grid2]
    arg2 = grid2[max(range(len(vals2)), key=lambda i: vals2[i])]
    print(f"    interior maximum on [3,100] at x = {arg2:.2f}"
          f" (law predicts 1/(b-1) = {hump_location(1.1):.2f})")
    print("    => peakedness is a window-relative statement.")


# ----------------------------------------------------------------------
# 9.  The hump-location law and the critical exponent
# ----------------------------------------------------------------------


def numeric_argmax(f: Callable[[float], float], lo: float, hi: float,
                   samples: int = 20000) -> float:
    """Grid + golden-section refinement of the maximiser of f on [lo, hi]."""
    step = (hi - lo) / samples
    best_x, best_v = lo, f(lo)
    for i in range(1, samples + 1):
        x = lo + i * step
        v = f(x)
        if v > best_v:
            best_x, best_v = x, v
    a, b = max(lo, best_x - step), min(hi, best_x + step)
    phi = (math.sqrt(5.0) - 1.0) / 2.0
    for _ in range(200):
        c1, c2 = b - phi * (b - a), a + phi * (b - a)
        if f(c1) < f(c2):
            a = c1
        else:
            b = c2
    return 0.5 * (a + b)


def demo_hump_law() -> None:
    banner("9. The hump-location law x* = 1/(b-1), and the critical exponent")

    print("Unique maximiser of the elementary factor tau_b(x) = x (1+x)^{-b}:")
    print(f"{'b':>8} {'1/(b-1)':>12} {'numeric argmax':>16}")
    for b in (1.05, 1.1, 1.25, 1.5, 2.0, 3.0):
        print(f"{b:8.3f} {hump_location(b):12.4f}"
              f" {numeric_argmax(lambda x: tail_residual(b, x), 1e-6, 500.0):16.4f}")
    print()
    print("For b <= 1, tau_b is increasing throughout and has no maximiser:")
    for b in (0.8, 0.95, 1.0):
        vals = [tail_residual(b, x) for x in (1.0, 10.0, 100.0, 1000.0, 1e5)]
        print(f"  b = {b:4.2f}:  " + "  ".join(f"{v:.4f}" for v in vals) + "   (rising)")

    print()
    print("The TRUE residual T/M tends to 1 as x -> 0, so the hump is a LOCAL")
    print("maximum away from the origin; we search for it on [3, 300].")
    print(f"{'b':>8} {'argmax on [3,300]':>20} {'humped?':>9}")

    def humped(b: float) -> bool:
        # a hump exists iff the log-derivative 1/x - b/(1+x) - 1/(e^x - 1)
        # is positive somewhere
        for i in range(1, 4001):
            x = i * 0.05
            if 1.0 / x - b / (1.0 + x) - 1.0 / math.expm1(x) > 0.0:
                return True
        return False

    for b in (1.05, 1.1, 1.15, 1.16, 1.17, 1.25, 1.5):
        arg = numeric_argmax(lambda x: uniform_residual(b, x), 3.0, 300.0)
        print(f"{b:8.3f} {arg:20.4f} {str(humped(b)):>9}")

    lo, hi = 1.1, 1.5
    for _ in range(60):
        mid = 0.5 * (lo + hi)
        if humped(mid):
            lo = mid
        else:
            hi = mid
    print()
    print(f"bisection for the critical exponent: b_c ~ {0.5 * (lo + hi):.6f}")
    print("proved bracket: humped at b = 1.1, strictly decreasing for all b >= 1.5")
    print(f"reported bootstrap interval [{B_LO}, {B_HI}] straddles b_c as well.")


# ----------------------------------------------------------------------
# 10.  A synthetic end-to-end pipeline
# ----------------------------------------------------------------------


def fit_pinned_curvature(xs: Sequence[float], rs: Sequence[float]) -> float:
    """Least-squares curvature of the endpoint-pinned family R_c."""
    num = sum((r - 0.8 - x / 10.0) * (x * x - x) for x, r in zip(xs, rs))
    den = sum((x * x - x) ** 2 for x in xs)
    return num / den


def fit_exponent_loglog(xs: Sequence[float], ts: Sequence[float]) -> float:
    """Slope of log T against log(1+x), negated: the profile exponent."""
    us = [math.log1p(x) for x in xs]
    vs = [math.log(t) for t in ts]
    ubar, vbar = mean(us), mean(vs)
    cov = sum((u - ubar) * (v - vbar) for u, v in zip(us, vs))
    var = sum((u - ubar) ** 2 for u in us)
    return -cov / var


def demo_pipeline() -> None:
    banner("10. Synthetic end-to-end pipeline: recover b and the curvature")

    rng = random.Random(20260831)
    xs = [i / 40.0 for i in range(81)]  # window [0,2]
    truth_b = B_FIT
    ts = [power_profile(A_FIT, truth_b, x) * math.exp(rng.gauss(0.0, 0.03)) for x in xs]
    b_hat = fit_exponent_loglog(xs, ts)
    print(f"exponent recovered from a noisy synthetic profile: {b_hat:.4f}"
          f"  (truth {truth_b})")

    print()
    print("Cluster bootstrap over 128 synthetic source objects (400 replicates):")
    clusters: List[Tuple[List[float], List[float]]] = []
    for _ in range(128):
        offset = rng.gauss(0.0, 0.02)
        cx = [x for x in xs]
        ct = [power_profile(A_FIT, truth_b + offset, x) * math.exp(rng.gauss(0, 0.05))
              for x in xs]
        clusters.append((cx, ct))
    boots: List[float] = []
    for _ in range(400):
        pick = [clusters[rng.randrange(128)] for _ in range(128)]
        bx = [x for cx, _ in pick for x in cx]
        bt = [t for _, ct in pick for t in ct]
        boots.append(fit_exponent_loglog(bx, bt))
    boots.sort()
    print(f"  95% interval: [{boots[int(0.025 * len(boots))]:.4f},"
          f" {boots[int(0.975 * len(boots)) - 1]:.4f}]")
    print(f"  reported interval for comparison: [{B_LO}, {B_HI}]")

    print()
    print("Curvature fit of a noisy residual generated from c = -0.556:")
    rxs = [i / 20.0 for i in range(21)]
    rrs = [residual_quad(-5.0 / 9.0, x) + rng.gauss(0.0, 0.01) for x in rxs]
    c_hat = fit_pinned_curvature(rxs, rrs)
    print(f"  c_hat = {c_hat:.4f};  apex at {residual_quad_vertex(c_hat):.4f};"
          f"  peaked verdict: {c_hat < -0.1}")


def main() -> None:
    demo_rigidity()
    demo_separating_invariant()
    demo_decline_factor()
    demo_akaike()
    demo_exponent_threshold()
    demo_absorption()
    demo_residual_peak()
    demo_counterexamples()
    demo_hump_law()
    demo_pipeline()
    print()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
