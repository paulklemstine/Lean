"""
demo.py -- Numerical demonstrations of the exact conjugacy between the logistic
map f(x) = 4x(1-x) and the tent map T(t) = 1 - |2t-1|, implemented by the
homeomorphism h(t) = sin^2(pi t / 2) of the unit interval.

Central identity:      f(h(t)) = h(T(t))          for all t
Iterated:              f^n(h(t)) = h(T^n(t))       for all n

Every function is self-contained and type-hinted. Run:  python demo.py
"""

from __future__ import annotations

import math
from typing import Callable, List, Tuple


# --------------------------------------------------------------------------- #
# Core maps
# --------------------------------------------------------------------------- #
def logistic(x: float) -> float:
    """The logistic map at r = 4:  f(x) = 4 x (1 - x)."""
    return 4.0 * x * (1.0 - x)


def tent(t: float) -> float:
    """The tent map:  T(t) = 1 - |2 t - 1|."""
    return 1.0 - abs(2.0 * t - 1.0)


def h(t: float) -> float:
    """Change of coordinates:  h(t) = sin^2(pi t / 2)."""
    return math.sin(math.pi * t / 2.0) ** 2


def h_inverse(x: float) -> float:
    """Inverse change of coordinates:  h^{-1}(x) = (2/pi) arcsin(sqrt(x))."""
    return (2.0 / math.pi) * math.asin(math.sqrt(x))


def iterate(f: Callable[[float], float], x0: float, n: int) -> float:
    """Apply f to x0 exactly n times."""
    x = x0
    for _ in range(n):
        x = f(x)
    return x


def orbit(f: Callable[[float], float], x0: float, n: int) -> List[float]:
    """Return the list [x0, f(x0), ..., f^n(x0)]."""
    out = [x0]
    x = x0
    for _ in range(n):
        x = f(x)
        out.append(x)
    return out


# --------------------------------------------------------------------------- #
# Demonstration 1: the intertwining identity f(h(t)) = h(T(t))
# --------------------------------------------------------------------------- #
def demo_conjugacy(num_points: int = 9) -> float:
    """Verify f(h(t)) = h(T(t)) on a grid; return the maximum error."""
    print("=" * 68)
    print("Demo 1: intertwining identity   f(h(t)) = h(T(t))")
    print("=" * 68)
    print(f"{'t':>8} {'f(h(t))':>14} {'h(T(t))':>14} {'|diff|':>12}")
    max_err = 0.0
    for i in range(num_points + 1):
        t = i / num_points
        lhs = logistic(h(t))
        rhs = h(tent(t))
        err = abs(lhs - rhs)
        max_err = max(max_err, err)
        print(f"{t:>8.4f} {lhs:>14.10f} {rhs:>14.10f} {err:>12.2e}")
    print(f"\nMaximum error over grid: {max_err:.2e}\n")
    return max_err


# --------------------------------------------------------------------------- #
# Demonstration 2: iterated conjugacy f^n(h(t)) = h(T^n(t))
# --------------------------------------------------------------------------- #
def demo_iterated_conjugacy(t0: float = 0.137, n_max: int = 12) -> float:
    """Verify f^n(h(t)) = h(T^n(t)) for n = 0..n_max; return max error."""
    print("=" * 68)
    print("Demo 2: iterated conjugacy   f^n(h(t)) = h(T^n(t))")
    print("=" * 68)
    print(f"seed t0 = {t0}")
    print(f"{'n':>4} {'f^n(h(t0))':>16} {'h(T^n(t0))':>16} {'|diff|':>12}")
    max_err = 0.0
    for n in range(n_max + 1):
        lhs = iterate(logistic, h(t0), n)
        rhs = h(iterate(tent, t0, n))
        err = abs(lhs - rhs)
        max_err = max(max_err, err)
        print(f"{n:>4} {lhs:>16.10f} {rhs:>16.10f} {err:>12.2e}")
    print(f"\nMaximum error: {max_err:.2e}\n")
    return max_err


# --------------------------------------------------------------------------- #
# Demonstration 3: transfer of fixed points
# --------------------------------------------------------------------------- #
def demo_fixed_points() -> None:
    """Tent fixed points {0, 2/3} map to logistic fixed points {0, 3/4}."""
    print("=" * 68)
    print("Demo 3: fixed-point transfer via h")
    print("=" * 68)
    for t in (0.0, 2.0 / 3.0):
        x = h(t)
        print(
            f"tent: T({t:.4f}) = {tent(t):.4f}   -->   "
            f"h({t:.4f}) = {x:.6f},   f(h) = {logistic(x):.6f}"
        )
    print("  (tent fixed 2/3 lands on logistic fixed 3/4 = 0.75)\n")


# --------------------------------------------------------------------------- #
# Demonstration 4: a genuine period-two logistic orbit
# --------------------------------------------------------------------------- #
def demo_period_two() -> Tuple[float, float]:
    """Transport the tent 2-cycle 2/5 <-> 4/5 to a logistic 2-cycle."""
    print("=" * 68)
    print("Demo 4: period-two orbit  (tent 2/5 <-> 4/5)")
    print("=" * 68)
    x = h(2.0 / 5.0)
    fx = logistic(x)
    ffx = logistic(fx)
    print(f"x        = h(2/5)      = {x:.10f}")
    print(f"f(x)     = h(4/5)      = {fx:.10f}")
    print(f"f(f(x))  =             = {ffx:.10f}")
    print(f"exact 2-cycle?  f^2(x) == x : {math.isclose(ffx, x, abs_tol=1e-12)}")
    print(f"not a fixed pt? f(x) != x   : {not math.isclose(fx, x, abs_tol=1e-9)}")
    print(f"closed forms:  sin^2(pi/5) = {math.sin(math.pi/5)**2:.10f}, "
          f"sin^2(2pi/5) = {math.sin(2*math.pi/5)**2:.10f}\n")
    return x, fx


# --------------------------------------------------------------------------- #
# Demonstration 5: cryptographic fragility -- break a "chaos cipher"
# --------------------------------------------------------------------------- #
def demo_cipher_break(secret_seed: float = 0.7182818, m: int = 20) -> float:
    """
    An attacker who observes a logistic keystream x_k = f^k(x0) recovers the
    tent orbit t_k = h^{-1}(x_k) and thereby the seed, since t_{k+1} = T(t_k).
    Return the recovery error |t0_recovered - h^{-1}(x0)|.
    """
    print("=" * 68)
    print("Demo 5: cryptographic fragility -- recover the tent shadow")
    print("=" * 68)
    keystream = orbit(logistic, secret_seed, m)
    tent_shadow = [h_inverse(x) for x in keystream]
    # Confirm the shadow is a genuine tent orbit: t_{k+1} = T(t_k).
    max_step_err = 0.0
    for k in range(m):
        pred = tent(tent_shadow[k])
        max_step_err = max(max_step_err, abs(pred - tent_shadow[k + 1]))
    print(f"secret seed x0            = {secret_seed}")
    print(f"h^{{-1}}(x0) (tent seed t0) = {tent_shadow[0]:.10f}")
    print(f"max |T(t_k) - t_{{k+1}}|     = {max_step_err:.2e}")
    print("  The smooth logistic keystream is, coordinate-for-coordinate,")
    print("  a tent keystream: the 'chaos cipher' has no hidden strength.\n")
    return max_step_err


# --------------------------------------------------------------------------- #
# Demonstration 6: the arcsine invariant density
# --------------------------------------------------------------------------- #
def demo_arcsine_density(n: int = 200_000, bins: int = 10) -> None:
    """
    A long logistic orbit is distributed by the arcsine law
    rho(x) = 1 / (pi sqrt(x(1-x))), the pushforward of the tent's uniform law.
    """
    print("=" * 68)
    print("Demo 6: empirical arcsine invariant density")
    print("=" * 68)
    x = 0.31415926535  # generic seed (avoid exact dyadic / periodic seeds)
    counts = [0] * bins
    for _ in range(n):
        x = logistic(x)
        idx = min(int(x * bins), bins - 1)
        counts[idx] += 1
    print(f"{'bin':>14} {'empirical':>12} {'arcsine':>12}")
    for b in range(bins):
        lo, hi = b / bins, (b + 1) / bins
        emp = counts[b] / n / (hi - lo)
        mid = (lo + hi) / 2.0
        theo = 1.0 / (math.pi * math.sqrt(mid * (1.0 - mid)))
        print(f"[{lo:4.2f},{hi:4.2f}) {emp:>12.4f} {theo:>12.4f}")
    print("  Orbits linger near the endpoints exactly as the arcsine law predicts.\n")


def main() -> None:
    demo_conjugacy()
    demo_iterated_conjugacy()
    demo_fixed_points()
    demo_period_two()
    demo_cipher_break()
    demo_arcsine_density()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
