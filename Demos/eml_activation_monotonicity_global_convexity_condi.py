"""
Numerical demonstrations for:

  Global Convexity and Sharp Monotonicity Domains for Generalized
  Exponential-Logarithmic (EML) Activations, and their Dequantization
  to Tropical Addition.

The generalized EML activation is

    E_{a,b}(x) = a * x + log(1 + exp(b * x)).

Facts demonstrated numerically here (all proved analytically in the paper):

  1.  E'_{a,b}(x)  = a + b * sigma(b x)
      E''_{a,b}(x) = b^2 * sigma(b x) * (1 - sigma(b x))       (finite differences)
  2.  E''_{a,b}(x) > 0 for every a and every b != 0            (global strict convexity)
      and E''_{a,b}(x) <= b^2 / 4, with equality exactly at x = 0.
  3.  For b > 0:  E_{a,b} strictly increasing on R  <=>  a >= 0   (sharp threshold),
      with the failure for a < 0 localized at x* = (1/b) log(-a / (a+b)).
  4.  x (+)_b y = (1/b) log(e^{bx} + e^{by}) is exactly commutative, associative
      and satisfies (x+z) (+)_b (y+z) = (x (+)_b y) + z.
  5.  Exact idempotency defect:  x (+)_b x = x + log(2)/b.
  6.  Sharp sandwich:  max(x,y) < x (+)_b y <= max(x,y) + log(2)/b,
      hence Maslov dequantization x (+)_b y -> max(x,y) as b -> infinity,
      and the min-plus mirror image -((-x) (+)_b (-y)) -> min(x,y).
  7.  Bridge theorem:  S_b(x) = (1/b) log(1 + e^{bx}) satisfies
      max(x,0) < S_b(x) <= max(x,0) + log(2)/b, uniformly in x, with
      sup-norm distance exactly log(2)/b attained at x = 0.

Run with:  python demo.py
Only the standard library is used.
"""

from __future__ import annotations

import math
import random
from typing import Callable, List, Sequence, Tuple

LOG2: float = math.log(2.0)


# ----------------------------------------------------------------------------
# Core functions
# ----------------------------------------------------------------------------


def logistic(t: float) -> float:
    """Logistic function sigma(t) = e^t / (1 + e^t), computed stably.

    For t >= 0 we use 1 / (1 + e^{-t}); for t < 0 we use e^t / (1 + e^t).
    Both branches keep every exponential argument non-positive.
    """
    if t >= 0.0:
        return 1.0 / (1.0 + math.exp(-t))
    z = math.exp(t)
    return z / (1.0 + z)


def softplus(t: float) -> float:
    """log(1 + e^t), computed stably as max(t, 0) + log1p(e^{-|t|})."""
    return max(t, 0.0) + math.log1p(math.exp(-abs(t)))


def eml_act(a: float, b: float, x: float) -> float:
    """Generalized EML activation E_{a,b}(x) = a x + log(1 + e^{bx})."""
    return a * x + softplus(b * x)


def eml_act_deriv(a: float, b: float, x: float) -> float:
    """Closed form of the first derivative: a + b * sigma(b x)."""
    return a + b * logistic(b * x)


def logistic_times_one_minus(t: float) -> float:
    """sigma(t) * (1 - sigma(t)), evaluated stably as e^{-|t|} / (1 + e^{-|t|})^2.

    The naive product s*(1-s) loses the factor entirely once sigma(t) rounds to
    1.0 (around |t| ~ 37 in double precision), even though the true value is a
    perfectly representable positive number down to |t| ~ 745.  The identity
    sigma(t)(1-sigma(t)) = e^{-|t|} / (1 + e^{-|t|})^2 is symmetric in t and
    keeps every exponential argument non-positive.
    """
    z = math.exp(-abs(t))
    return z / ((1.0 + z) * (1.0 + z))


def eml_act_deriv2(a: float, b: float, x: float) -> float:
    """Closed form of the second derivative: b^2 * sigma(bx) (1 - sigma(bx))."""
    return b * b * logistic_times_one_minus(b * x)


def lse(b: float, x: float, y: float) -> float:
    """Log-sum-exp x (+)_b y = (1/b) log(e^{bx} + e^{by}), computed stably.

    Uses the exact expansion  max(x,y) + (1/b) log(1 + e^{-b|x-y|}),
    valid for b > 0 (for b < 0 the roles of max and min swap; we handle
    the general nonzero case by factoring out e^{b * m} with m chosen so
    that the remaining exponent is non-positive).
    """
    if b == 0.0:
        raise ValueError("lse requires b != 0")
    m = max(x, y) if b > 0.0 else min(x, y)
    d = abs(x - y)
    return m + math.log1p(math.exp(-abs(b) * d)) / b


def rescaled_act(b: float, x: float) -> float:
    """S_b(x) = (1/b) log(1 + e^{bx}) = x (+)_b 0, the rescaled EML activation."""
    return softplus(b * x) / b


def relu(x: float) -> float:
    """The tropical shadow R(x) = max(x, 0)."""
    return max(x, 0.0)


def central_diff(f: Callable[[float], float], x: float, h: float = 1e-5) -> float:
    """Second-order accurate central difference approximation of f'(x)."""
    return (f(x + h) - f(x - h)) / (2.0 * h)


def central_diff2(f: Callable[[float], float], x: float, h: float = 1e-4) -> float:
    """Central difference approximation of f''(x)."""
    return (f(x + h) - 2.0 * f(x) + f(x - h)) / (h * h)


# ----------------------------------------------------------------------------
# Demonstration 1: derivative formulas
# ----------------------------------------------------------------------------


def demo_derivative_formulas() -> None:
    print("=" * 78)
    print("1.  DERIVATIVE FORMULAS:  E' = a + b*sigma(bx),  E'' = b^2 sigma(1-sigma)")
    print("=" * 78)
    params: List[Tuple[float, float]] = [(0.0, 1.0), (0.3, 2.0), (-0.5, 1.5), (2.0, -1.0)]
    xs: Sequence[float] = (-3.0, -0.7, 0.0, 0.7, 3.0)
    header = (f"{'a':>6} {'b':>6} {'x':>7} {'E1 closed':>13} {'E1 numeric':>13}"
              f" {'E2 closed':>14} {'E2 numeric':>14}")
    print(header)
    max_err = 0.0
    for a, b in params:
        for x in xs:
            d1c = eml_act_deriv(a, b, x)
            d1n = central_diff(lambda t: eml_act(a, b, t), x)
            d2c = eml_act_deriv2(a, b, x)
            d2n = central_diff2(lambda t: eml_act(a, b, t), x)
            max_err = max(max_err, abs(d1c - d1n), abs(d2c - d2n))
            print(f"{a:6.2f} {b:6.2f} {x:7.2f} {d1c:13.8f} {d1n:13.8f}"
                  f" {d2c:14.8f} {d2n:14.8f}")
    print(f"\nlargest closed-form vs finite-difference discrepancy: {max_err:.3e}")
    print("(consistent with the O(h^2) truncation error of the difference scheme)\n")


# ----------------------------------------------------------------------------
# Demonstration 2: global strict convexity, and the curvature bound b^2/4
# ----------------------------------------------------------------------------


def demo_strict_convexity(trials: int = 200_000, seed: int = 20260805) -> None:
    print("=" * 78)
    print("2.  GLOBAL STRICT CONVEXITY:  E'' > 0 for every a and every b != 0")
    print("=" * 78)
    rng = random.Random(seed)
    worst_ratio = 0.0
    min_curv = math.inf
    for _ in range(trials):
        a = rng.uniform(-50.0, 50.0)
        b = rng.uniform(-8.0, 8.0)
        if abs(b) < 1e-9:
            continue
        x = rng.uniform(-40.0, 40.0)
        c = eml_act_deriv2(a, b, x)
        # Positive for every (a, b != 0, x) by theory; the stable evaluation of
        # sigma(1-sigma) keeps this visible in floating point as well.
        assert c > 0.0, (a, b, x, c)
        min_curv = min(min_curv, c)
        worst_ratio = max(worst_ratio, c / (b * b / 4.0))
    print(f"random (a, b, x) samples tested : {trials}")
    print(f"all second derivatives positive : True")
    print(f"smallest curvature observed     : {min_curv:.6e}")
    print(f"max of E''(x) / (b^2/4)         : {worst_ratio:.12f}  (theory: <= 1)")

    print("\nThe bound b^2/4 is attained exactly at x = 0:")
    for b in (0.5, 1.0, 3.0, 7.5):
        print(f"   b = {b:4.2f} :  E''(0) = {eml_act_deriv2(0.0, b, 0.0):.10f}"
              f"   b^2/4 = {b * b / 4.0:.10f}")

    print("\nDirect chord test (strict convexity of the graph), a = 1.7, b = 2.3:")
    a, b = 1.7, 2.3
    for u, v, lam in ((-2.0, 3.0, 0.5), (0.0, 0.1, 0.25), (-9.0, -8.5, 0.9)):
        lhs = eml_act(a, b, lam * u + (1 - lam) * v)
        rhs = lam * eml_act(a, b, u) + (1 - lam) * eml_act(a, b, v)
        print(f"   u={u:5.1f} v={v:5.1f} lam={lam:4.2f}:  f(chord pt)={lhs:.10f}"
              f" < chord={rhs:.10f}   gap={rhs - lhs:.3e}")
    print()


# ----------------------------------------------------------------------------
# Demonstration 3: the sharp monotonicity threshold a >= 0
# ----------------------------------------------------------------------------


def is_increasing_on_grid(a: float, b: float,
                          lo: float = -60.0, hi: float = 20.0,
                          n: int = 4001) -> bool:
    """Empirical monotonicity check of E_{a,b} on a dense grid."""
    step = (hi - lo) / (n - 1)
    prev = eml_act(a, b, lo)
    for i in range(1, n):
        cur = eml_act(a, b, lo + i * step)
        if cur <= prev:
            return False
        prev = cur
    return True


def critical_point(a: float, b: float) -> float:
    """Unique critical point x* = (1/b) log(-a/(a+b)), defined for -b < a < 0."""
    if not (-b < a < 0.0):
        raise ValueError("critical point exists only for -b < a < 0")
    return math.log(-a / (a + b)) / b


def demo_monotonicity_threshold() -> None:
    print("=" * 78)
    print("3.  SHARP MONOTONICITY DOMAIN:  for b > 0,  E_{a,b} increasing  <=>  a >= 0")
    print("=" * 78)
    b = 1.0
    print(f"b = {b}.  Grid test on [-60, 20]:\n")
    print(f"{'a':>12} {'predicted':>12} {'observed':>12}   note")
    for a in (1.0, 0.1, 0.001, 0.0, -1e-4, -1e-2, -0.5, -1.0, -2.0):
        predicted = a >= 0.0
        observed = is_increasing_on_grid(a, b)
        note = ""
        if -b < a < 0.0:
            xs = critical_point(a, b)
            note = f"interior minimum at x* = {xs:.4f}"
        elif a <= -b:
            note = "strictly decreasing everywhere"
        print(f"{a:12.5f} {str(predicted):>12} {str(observed):>12}   {note}")

    print("\nWhy a < 0 fails: the derivative tends to a as x -> -infinity.")
    a = -1e-3
    print(f"   a = {a}, b = {b}")
    for x in (-5.0, -10.0, -15.0, -20.0, -30.0):
        print(f"      E'({x:6.1f}) = {eml_act_deriv(a, b, x): .10f}"
              f"   (sigma(bx) = {logistic(b * x):.3e})")
    print(f"   limit as x -> -inf is exactly a = {a}  < 0, so monotonicity fails.\n")

    print("Boundary case a = 0 (the softplus): increasing, derivative -> 0 but never 0.")
    for x in (-10.0, -30.0, -60.0):
        print(f"      E'({x:6.1f}) = {eml_act_deriv(0.0, 1.0, x): .6e}  > 0")
    print()


# ----------------------------------------------------------------------------
# Demonstration 4: exact algebraic laws of log-sum-exp
# ----------------------------------------------------------------------------


def demo_lse_algebra(trials: int = 50_000, seed: int = 11) -> None:
    print("=" * 78)
    print("4.  EXACT ALGEBRA OF LOG-SUM-EXP  (commutative, associative, distributive)")
    print("=" * 78)
    rng = random.Random(seed)
    e_comm = e_assoc = e_dist = e_idem = 0.0
    for _ in range(trials):
        b = rng.choice([-1.0, 1.0]) * rng.uniform(0.2, 6.0)
        x, y, z = (rng.uniform(-12.0, 12.0) for _ in range(3))
        scale = max(1.0, abs(x), abs(y), abs(z))
        e_comm = max(e_comm, abs(lse(b, x, y) - lse(b, y, x)) / scale)
        lhs = lse(b, lse(b, x, y), z)
        rhs = lse(b, x, lse(b, y, z))
        e_assoc = max(e_assoc, abs(lhs - rhs) / scale)
        e_dist = max(e_dist, abs(lse(b, x + z, y + z) - (lse(b, x, y) + z)) / scale)
        e_idem = max(e_idem, abs(lse(b, x, x) - (x + LOG2 / b)) / scale)
    print(f"random (b, x, y, z) samples tested        : {trials}")
    print(f"max relative violation of commutativity   : {e_comm:.3e}")
    print(f"max relative violation of associativity   : {e_assoc:.3e}")
    print(f"max relative violation of distributivity  : {e_dist:.3e}")
    print(f"max relative error in x (+)_b x = x+log2/b: {e_idem:.3e}")
    print("(all at the level of floating-point round-off: the laws hold exactly)\n")

    print("Idempotency defect is a constant shift, independent of x:")
    for b in (0.5, 1.0, 4.0, 20.0):
        row = [lse(b, x, x) - x for x in (-7.0, 0.0, 3.5, 100.0)]
        print(f"   b = {b:5.2f}:  defects = "
              + ", ".join(f"{d:.10f}" for d in row)
              + f"   log2/b = {LOG2 / b:.10f}")
    print()


# ----------------------------------------------------------------------------
# Demonstration 5: the sharp sandwich and Maslov dequantization
# ----------------------------------------------------------------------------


def demo_sandwich_and_dequantization() -> None:
    print("=" * 78)
    print("5.  SHARP SANDWICH  max(x,y) < x (+)_b y <= max(x,y) + log2/b")
    print("=" * 78)
    pairs = [(1.0, 1.0), (2.0, -3.0), (0.0, 0.5), (-4.0, -4.25), (10.0, 9.0)]
    print(f"{'b':>7} {'x':>7} {'y':>7} {'max':>10} {'x(+)y':>13}"
          f" {'excess':>13} {'log2/b':>11}")
    for b in (0.5, 2.0, 10.0, 100.0):
        for x, y in pairs:
            v = lse(b, x, y)
            m = max(x, y)
            # Mathematically m < v; in floating point the strict gap can round
            # away once b|x-y| is large (the true excess is then ~e^{-b|x-y|}).
            assert m <= v <= m + LOG2 / b + 1e-12
            print(f"{b:7.2f} {x:7.2f} {y:7.2f} {m:10.4f} {v:13.8f}"
                  f" {v - m:13.8f} {LOG2 / b:11.8f}")
        print()

    print("Maslov dequantization: x (+)_b y -> max(x, y) as b -> infinity")
    x, y = 1.25, -0.75
    print(f"   x = {x}, y = {y},  max = {max(x, y)}")
    print(f"{'b':>12} {'x (+)_b y':>16} {'error':>14} {'error * b':>12}")
    for b in (1.0, 10.0, 100.0, 1e3, 1e4, 1e6):
        v = lse(b, x, y)
        err = v - max(x, y)
        print(f"{b:12.0f} {v:16.10f} {err:14.3e} {err * b:12.6f}")
    print("   (error * b -> log(1 + e^{-b|x-y|}) -> 0 here because x != y)")

    print("\n   Worst case x = y, where the bound log2/b is ATTAINED:")
    x = y = 3.0
    print(f"{'b':>12} {'x (+)_b x':>16} {'error':>14} {'error * b':>12}")
    for b in (1.0, 10.0, 100.0, 1e3, 1e4, 1e6):
        err = lse(b, x, y) - max(x, y)
        print(f"{b:12.0f} {lse(b, x, y):16.10f} {err:14.6e} {err * b:12.9f}")
    print(f"   error * b == log 2 == {LOG2:.9f} exactly, for every b.")

    print("\nMin-plus (tropical) mirror image:  -((-x) (+)_b (-y)) -> min(x, y)")
    x, y = 2.5, -1.5
    print(f"   x = {x}, y = {y},  min = {min(x, y)}")
    for b in (1.0, 10.0, 100.0, 1e4):
        v = -lse(b, -x, -y)
        print(f"      b = {b:8.0f}:  value = {v:.10f}   error = {v - min(x, y):+.3e}")
    print()


# ----------------------------------------------------------------------------
# Demonstration 6: the bridge theorem
# ----------------------------------------------------------------------------


def demo_bridge_theorem() -> None:
    print("=" * 78)
    print("6.  BRIDGE THEOREM:  S_b(x) = (1/b) log(1 + e^{bx}) vs. R(x) = max(x, 0)")
    print("=" * 78)
    print("Uniform band: 0 < S_b(x) - R(x) <= log2/b for EVERY x")
    print("(the strict positivity can round to 0.0 in floating point once b|x|")
    print(" is large, where the true gap is of order e^{-b|x|}).\n")
    xs = [-20.0, -5.0, -1.0, -0.1, 0.0, 0.1, 1.0, 5.0, 20.0]
    for b in (1.0, 4.0, 25.0):
        print(f"   b = {b:5.2f}   (log2/b = {LOG2 / b:.8f})")
        print(f"      {'x':>8} {'R(x)':>10} {'S_b(x)':>14} {'S_b - R':>14}")
        for x in xs:
            d = rescaled_act(b, x) - relu(x)
            assert 0.0 <= d <= LOG2 / b + 1e-15
            print(f"      {x:8.2f} {relu(x):10.4f} {rescaled_act(b, x):14.9f} {d:14.9f}")
        print()

    print("Sup-norm distance ||S_b - R||_inf, computed on a fine grid,")
    print("compared with the exact theoretical value log2/b (attained at x = 0):")
    print(f"{'b':>8} {'grid sup':>16} {'log2/b':>16} {'argmax':>10}")
    for b in (0.5, 1.0, 2.0, 8.0, 50.0):
        best, arg = 0.0, 0.0
        n = 200_001
        for i in range(n):
            x = -30.0 / b + (60.0 / b) * i / (n - 1)
            d = rescaled_act(b, x) - relu(x)
            if d > best:
                best, arg = d, x
        print(f"{b:8.2f} {best:16.10f} {LOG2 / b:16.10f} {arg:10.2e}")

    print("\nStrictness is lost only in the limit:")
    print("   For finite b, S_b is STRICTLY convex; the limit max(x,0) is affine")
    print("   on each of the two half-lines. Curvature S_b''(x) = b*sigma(1-sigma)")
    print("   has total mass 1 for every b, concentrating at the origin:")
    print(f"{'b':>8} {'S_b curv(0)':>14} {'mass on [-1,1]':>16} {'total mass':>12}")
    for b in (1.0, 5.0, 25.0, 200.0):
        # S_b'' (x) = b * sigma(bx)(1 - sigma(bx)); its antiderivative is sigma(bx).
        mass_local = logistic(b * 1.0) - logistic(-b * 1.0)
        print(f"{b:8.1f} {b / 4.0:14.6f} {mass_local:16.10f} {1.0:12.4f}")
    print()


# ----------------------------------------------------------------------------
# Demonstration 7: choosing the sharpness from an error tolerance
# ----------------------------------------------------------------------------


def minimal_sharpness(eps: float) -> float:
    """Smallest b with ||S_b - relu||_inf <= eps, namely b* = log2 / eps."""
    if eps <= 0.0:
        raise ValueError("eps must be positive")
    return LOG2 / eps


def demo_sharpness_selection() -> None:
    print("=" * 78)
    print("7.  SHARPNESS SELECTION:  accuracy eps costs curvature ~ log2/(4 eps)")
    print("=" * 78)
    print(f"{'eps':>10} {'b* = log2/eps':>16} {'achieved error':>17} {'max curvature':>16}")
    for eps in (1e-1, 1e-2, 1e-3, 1e-4, 1e-6):
        b = minimal_sharpness(eps)
        achieved = rescaled_act(b, 0.0) - relu(0.0)
        print(f"{eps:10.0e} {b:16.4f} {achieved:17.10e} {b / 4.0:16.4f}")
    print("\nAchieved error equals eps exactly, so b* is optimal: no smaller")
    print("sharpness meets the tolerance, since the error at x = 0 is log2/b.\n")


# ----------------------------------------------------------------------------


def main() -> None:
    demo_derivative_formulas()
    demo_strict_convexity()
    demo_monotonicity_threshold()
    demo_lse_algebra()
    demo_sandwich_and_dequantization()
    demo_bridge_theorem()
    demo_sharpness_selection()
    print("=" * 78)
    print("All assertions passed: the numerics agree with the theory.")
    print("=" * 78)


if __name__ == "__main__":
    main()
