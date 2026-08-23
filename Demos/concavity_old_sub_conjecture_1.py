"""
Numerical demonstration of the sharp curvature of the Lagrange exponent.

The Lagrange exponent is the global inverse of the *critical cubic*

    h(y) = y^3 - y^2 + y/3 = ((3y - 1)^3 + 1) / 27,

whose derivative h'(y) = 3 (y - 1/3)^2 is a perfect square: its two critical
points have coalesced into the single degenerate critical point y = 1/3.  Hence
h is a strictly increasing bijection of R and its inverse has the closed form

    sigma(t) = (1 + cbrt(27 t - 1)) / 3,

with the sign-aware real cube root.  The critical mass is t_c = h(1/3) = 1/27.

This script verifies numerically, with no external dependencies:

  1. Inversion:  h(sigma(t)) = t  and  sigma(h(y)) = y.
  2. Main theorem: strict concavity on [1/27, infinity) -- averaging masses
     never decreases the growth rate.
  3. Mirror regime: strict convexity on (-infinity, 1/27].
  4. Sharpness: for any a < 1/27 the pair (a, 1/27) violates concavity on
     [a, infinity), so 1/27 is the exact threshold.
  5. Jensen's inequality for arbitrary weighted averages of admissible masses.
  6. The cube-root sandwich  cbrt(t) <= sigma(t) <= cbrt(t) + 1/3, with the gap
     running from 0 at t = 1/27 up to 1/3 at infinity.
  7. The derivative sigma'(t) = 3 (27 t - 1)^(-2/3) and its antitonicity.
  8. The merging law and its n-fold iterate.
  9. The AM-GM bridge: pqr <= 1/27 for a probability vector, with equality only
     at the uniform distribution, so sigma(pqr) <= 1/3.

Run:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Callable, Iterable, List, Sequence, Tuple

CRITICAL_MASS: float = 1.0 / 27.0
CRITICAL_EXPONENT: float = 1.0 / 3.0
TOL: float = 1e-9


# ----------------------------------------------------------------------------
# Core functions
# ----------------------------------------------------------------------------
def cbrt(x: float) -> float:
    """Sign-aware real cube root: the unique real u with u**3 == x."""
    if x >= 0.0:
        return x ** (1.0 / 3.0)
    return -((-x) ** (1.0 / 3.0))


def lagrange_cubic(y: float) -> float:
    """The critical cubic h(y) = y^3 - y^2 + y/3."""
    return y ** 3 - y ** 2 + y / 3.0


def lagrange_cubic_shift(y: float) -> float:
    """The pure-cube form of h: ((3y - 1)^3 + 1) / 27."""
    return ((3.0 * y - 1.0) ** 3 + 1.0) / 27.0


def sigma(t: float) -> float:
    """The Lagrange exponent sigma(t) = (1 + cbrt(27 t - 1)) / 3."""
    return (1.0 + cbrt(27.0 * t - 1.0)) / 3.0


def sigma_prime(t: float) -> float:
    """sigma'(t) = 3 (27 t - 1)^(-2/3), valid for t > 1/27."""
    return 3.0 * (27.0 * t - 1.0) ** (-2.0 / 3.0)


def midpoint_gap(s: float, t: float) -> float:
    """G(s, t) = sigma((s+t)/2) - (sigma(s) + sigma(t)) / 2.

    Positive means averaging helps (concave regime); negative means averaging
    hurts (convex regime).
    """
    return sigma((s + t) / 2.0) - (sigma(s) + sigma(t)) / 2.0


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


# ----------------------------------------------------------------------------
# 1. Inversion
# ----------------------------------------------------------------------------
def demo_inversion() -> None:
    banner("1.  sigma is the global inverse of the critical cubic")
    print(f"{'t':>12} {'sigma(t)':>14} {'h(sigma(t))':>14} {'error':>12}")
    for t in [-2.0, -0.5, 0.0, CRITICAL_MASS, 1.0 / 3.0, 28.0 / 27.0, 5.0, 100.0]:
        y = sigma(t)
        err = abs(lagrange_cubic(y) - t)
        print(f"{t:12.6f} {y:14.9f} {lagrange_cubic(y):14.9f} {err:12.2e}")
        assert err < 1e-9

    print("\nAnd in the other direction, sigma(h(y)) = y:")
    print(f"{'y':>12} {'h(y)':>14} {'sigma(h(y))':>14} {'error':>12}")
    for y in [-1.5, -0.25, 0.0, 1.0 / 3.0, 1.0, 2.5]:
        t = lagrange_cubic(y)
        err = abs(sigma(t) - y)
        print(f"{y:12.6f} {t:14.9f} {sigma(t):14.9f} {err:12.2e}")
        assert err < 1e-9

    print("\nDegeneracy check: h(y) == ((3y-1)^3 + 1)/27 and h'(y) == 3(y-1/3)^2")
    for y in [-1.0, 0.0, 1.0 / 3.0, 2.0]:
        assert abs(lagrange_cubic(y) - lagrange_cubic_shift(y)) < 1e-12
        deriv = (lagrange_cubic(y + 1e-6) - lagrange_cubic(y - 1e-6)) / 2e-6
        assert abs(deriv - 3.0 * (y - 1.0 / 3.0) ** 2) < 1e-6
    print("   verified at sample points.")
    print(f"\nCritical point: h(1/3) = {lagrange_cubic(1/3):.9f}  (= 1/27)")
    print(f"Critical mass : sigma(1/27) = {sigma(CRITICAL_MASS):.9f}  (= 1/3)")


# ----------------------------------------------------------------------------
# 2-3. Concavity above, convexity below
# ----------------------------------------------------------------------------
def demo_curvature() -> None:
    banner("2.  Strict concavity on [1/27, oo): averaging masses always helps")
    print(f"{'s':>10} {'t':>10} {'avg of sigma':>16} {'sigma of avg':>16} {'gain':>14}")
    concave_pairs: List[Tuple[float, float]] = [
        (CRITICAL_MASS, 1.0),
        (0.05, 0.5),
        (0.2, 20.0),
        (1.0, 1.000001),
        (3.0, 300.0),
    ]
    for s, t in concave_pairs:
        avg_sig = (sigma(s) + sigma(t)) / 2.0
        sig_avg = sigma((s + t) / 2.0)
        print(f"{s:10.6f} {t:10.4f} {avg_sig:16.9f} {sig_avg:16.9f} {sig_avg - avg_sig:14.3e}")
        assert sig_avg > avg_sig - TOL
        if abs(s - t) > 1e-12:
            assert sig_avg > avg_sig

    banner("3.  Strict convexity on (-oo, 1/27]: averaging masses always hurts")
    print(f"{'s':>10} {'t':>10} {'avg of sigma':>16} {'sigma of avg':>16} {'loss':>14}")
    convex_pairs: List[Tuple[float, float]] = [
        (-5.0, 0.0),
        (-1.0, CRITICAL_MASS),
        (0.0, 0.03),
        (-0.2, -0.1),
    ]
    for s, t in convex_pairs:
        avg_sig = (sigma(s) + sigma(t)) / 2.0
        sig_avg = sigma((s + t) / 2.0)
        print(f"{s:10.6f} {t:10.4f} {avg_sig:16.9f} {sig_avg:16.9f} {sig_avg - avg_sig:14.3e}")
        assert sig_avg < avg_sig

    print("\nGeneral convex combinations (weights a, b = 1 - a) on the physical range:")
    random.seed(20260823)
    worst = math.inf
    for _ in range(20000):
        s = CRITICAL_MASS + random.random() * 50.0
        t = CRITICAL_MASS + random.random() * 50.0
        a = random.random()
        lhs = a * sigma(s) + (1.0 - a) * sigma(t)
        rhs = sigma(a * s + (1.0 - a) * t)
        worst = min(worst, rhs - lhs)
        assert rhs >= lhs - 1e-12
    print(f"   20000 random triples (s, t, a): min of sigma(as+bt) - a sigma(s) - b sigma(t)"
          f" = {worst:.3e} >= 0")


# ----------------------------------------------------------------------------
# 4. Sharpness of the threshold
# ----------------------------------------------------------------------------
def demo_sharpness() -> None:
    banner("4.  Sharpness: 1/27 is the EXACT left endpoint of the concavity ray")
    print("For each a < 1/27 the pair (a, 1/27) already breaks concavity on [a, oo):")
    print(f"{'a':>14} {'1/27 - a':>14} {'midpoint gap G(a, 1/27)':>28}")
    for a in [-1.0, -0.1, 0.0, 0.02, 0.036, CRITICAL_MASS - 1e-3, CRITICAL_MASS - 1e-6]:
        gap = midpoint_gap(a, CRITICAL_MASS)
        print(f"{a:14.9f} {CRITICAL_MASS - a:14.3e} {gap:28.6e}")
        assert gap < 0.0, "gap must be strictly negative: concavity fails"
    print("\nEvery gap is strictly negative, so concavity fails on [a, oo) for every")
    print("a < 1/27.  Combined with the main theorem: sigma is concave on [c, oo)")
    print("if and only if c >= 1/27.")


# ----------------------------------------------------------------------------
# 5. Jensen
# ----------------------------------------------------------------------------
def demo_jensen() -> None:
    banner("5.  Jensen form: any weighted blend of admissible masses")
    masses: List[float] = [CRITICAL_MASS, 0.1, 0.75, 4.0, 31.5]
    weights: List[float] = [0.30, 0.10, 0.25, 0.20, 0.15]
    assert abs(sum(weights) - 1.0) < 1e-12
    lhs = sum(w * sigma(m) for w, m in zip(weights, masses))
    blended = sum(w * m for w, m in zip(weights, masses))
    rhs = sigma(blended)
    print(f"   masses  : {masses}")
    print(f"   weights : {weights}")
    print(f"   sum w_i sigma(m_i)      = {lhs:.12f}")
    print(f"   sigma(sum w_i m_i)      = {rhs:.12f}   (blended mass {blended:.6f})")
    print(f"   Jensen gain             = {rhs - lhs:.12f} > 0")
    assert rhs > lhs

    print("\n   Randomised check over 5000 weighted families of 6 admissible masses:")
    random.seed(7)
    worst = math.inf
    for _ in range(5000):
        ms = [CRITICAL_MASS + random.random() * 10.0 for _ in range(6)]
        raw = [random.random() for _ in range(6)]
        tot = sum(raw)
        ws = [w / tot for w in raw]
        gain = sigma(sum(w * m for w, m in zip(ws, ms))) - sum(w * sigma(m) for w, m in zip(ws, ms))
        worst = min(worst, gain)
        assert gain > -1e-12
    print(f"   minimum Jensen gain observed = {worst:.3e} >= 0")


# ----------------------------------------------------------------------------
# 6. Cube-root sandwich
# ----------------------------------------------------------------------------
def demo_sandwich() -> None:
    banner("6.  The cube-root sandwich  cbrt(t) <= sigma(t) <= cbrt(t) + 1/3")
    print(f"{'t':>14} {'cbrt(t)':>14} {'sigma(t)':>14} {'gap':>14} {'1/3 - gap':>14}")
    for t in [CRITICAL_MASS, 0.05, 0.2, 1.0, 10.0, 1e2, 1e4, 1e8]:
        c = cbrt(t)
        s = sigma(t)
        gap = s - c
        print(f"{t:14.6g} {c:14.9f} {s:14.9f} {gap:14.9f} {1/3 - gap:14.3e}")
        assert c - TOL <= s <= c + 1.0 / 3.0 + TOL
    print("\nThe gap is exactly 0 at the critical mass 1/27 and increases to 1/3;")
    print("the upper bound sigma(t) <= cbrt(t) + 1/3 in fact holds for ALL real t:")
    for t in [-1e6, -3.0, -0.1, 0.0]:
        assert sigma(t) <= cbrt(t) + 1.0 / 3.0 + TOL
        print(f"   t = {t:>10.4g}:  sigma(t) = {sigma(t):12.6f} <= "
              f"{cbrt(t) + 1/3:12.6f} = cbrt(t) + 1/3")


# ----------------------------------------------------------------------------
# 7. Derivative
# ----------------------------------------------------------------------------
def demo_derivative() -> None:
    banner("7.  sigma'(t) = 3 (27 t - 1)^(-2/3), decreasing on (1/27, oo)")
    print(f"{'t':>14} {'numerical d/dt':>18} {'formula':>18} {'error':>12}")
    prev = math.inf
    for t in [0.04, 0.05, 0.1, 0.5, 2.0, 10.0, 1000.0]:
        h = 1e-6 * max(1.0, abs(t))
        numeric = (sigma(t + h) - sigma(t - h)) / (2.0 * h)
        exact = sigma_prime(t)
        print(f"{t:14.6g} {numeric:18.9f} {exact:18.9f} {abs(numeric - exact):12.2e}")
        assert abs(numeric - exact) < 1e-4 * max(1.0, exact)
        assert exact < prev
        prev = exact
    print("\nThe derivative is strictly decreasing (antitone) -- the analytic shadow of")
    print("concavity -- and blows up as t decreases to the critical mass 1/27:")
    for t in [CRITICAL_MASS + 1e-3, CRITICAL_MASS + 1e-6, CRITICAL_MASS + 1e-9]:
        print(f"   sigma'({t:.12f}) = {sigma_prime(t):.6e}")


# ----------------------------------------------------------------------------
# 8. Merging laws
# ----------------------------------------------------------------------------
def demo_merging() -> None:
    banner("8.  Merging: the critical overhead 1/27 is paid exactly once")
    print("Pairwise law:  sigma(s + t - 1/27) + 1/3 <= sigma(s) + sigma(t)")
    print(f"{'s':>10} {'t':>10} {'separate':>16} {'merged bound':>16} {'slack':>14}")
    for s, t in [(CRITICAL_MASS, CRITICAL_MASS), (0.1, 0.2), (1.0, 1.0), (0.04, 50.0)]:
        separate = sigma(s) + sigma(t)
        bound = sigma(s + t - CRITICAL_MASS) + CRITICAL_EXPONENT
        print(f"{s:10.5f} {t:10.5f} {separate:16.9f} {bound:16.9f} {separate - bound:14.3e}")
        assert bound <= separate + TOL

    print("\nn-fold law:  sigma(sum m_i - (n-1)/27) + (n-1)/3 <= sum sigma(m_i)")
    families: List[List[float]] = [
        [CRITICAL_MASS] * 4,
        [0.05, 0.1, 0.4],
        [1.0, 2.0, 3.0, 4.0, 5.0],
        [CRITICAL_MASS, 0.5, 12.0, 100.0, 0.04, 7.0],
    ]
    print(f"{'n':>4} {'sum sigma(m_i)':>18} {'merged bound':>18} {'slack':>14}")
    for fam in families:
        n = len(fam)
        separate = sum(sigma(m) for m in fam)
        merged_mass = sum(fam) - (n - 1) * CRITICAL_MASS
        bound = sigma(merged_mass) + (n - 1) * CRITICAL_EXPONENT
        print(f"{n:4d} {separate:18.9f} {bound:18.9f} {separate - bound:14.3e}")
        assert bound <= separate + TOL


# ----------------------------------------------------------------------------
# 9. AM-GM bridge
# ----------------------------------------------------------------------------
def demo_amgm_bridge() -> None:
    banner("9.  Why 1/27?  The AM-GM bridge for three-point distributions")
    print(f"{'(p, q, r)':>34} {'p q r':>14} {'sigma(pqr)':>14} {'1/3 - sigma':>14}")
    dists: List[Tuple[float, float, float]] = [
        (1 / 3, 1 / 3, 1 / 3),
        (0.34, 0.33, 0.33),
        (0.5, 0.3, 0.2),
        (0.8, 0.1, 0.1),
        (1.0, 0.0, 0.0),
    ]
    for p, q, r in dists:
        prod = p * q * r
        s = sigma(prod)
        label = f"({p:.4f}, {q:.4f}, {r:.4f})"
        print(f"{label:>34} {prod:14.9f} {s:14.9f} {1/3 - s:14.3e}")
        assert prod <= CRITICAL_MASS + 1e-12
        assert s <= CRITICAL_EXPONENT + 1e-12

    print("\n   Only the uniform distribution attains the critical mass 1/27:")
    random.seed(1234)
    best = 0.0
    argbest: Tuple[float, float, float] = (0.0, 0.0, 0.0)
    for _ in range(200000):
        a, b = sorted((random.random(), random.random()))
        p, q, r = a, b - a, 1.0 - b
        prod = p * q * r
        if prod > best:
            best, argbest = prod, (p, q, r)
    print(f"   best product over 200000 random distributions = {best:.12f}")
    print(f"   attained near p = ({argbest[0]:.6f}, {argbest[1]:.6f}, {argbest[2]:.6f})")
    print(f"   theoretical maximum 1/27                      = {CRITICAL_MASS:.12f}")
    assert best <= CRITICAL_MASS + 1e-12


# ----------------------------------------------------------------------------
# Curvature-regime classifier (the algorithm of the paper)
# ----------------------------------------------------------------------------
def classify_regime(masses: Sequence[float]) -> Tuple[str, List[Tuple[float, float, float]]]:
    """Classify a finite mass family and certify with all pairwise midpoint gaps."""
    if min(masses) >= CRITICAL_MASS:
        regime = "concave  (mixing helps: every pairwise gap is > 0)"
    elif max(masses) <= CRITICAL_MASS:
        regime = "convex   (mixing hurts: every pairwise gap is < 0)"
    else:
        regime = "straddles the critical mass 1/27 (no uniform verdict)"
    gaps = [(s, t, midpoint_gap(s, t)) for s, t in itertools.combinations(sorted(masses), 2)]
    return regime, gaps


def demo_classifier() -> None:
    banner("10. The curvature-regime classifier")
    families: List[List[float]] = [
        [0.05, 0.3, 2.0],
        [-1.0, 0.0, 0.03],
        [0.0, 0.05, 1.0],
    ]
    for fam in families:
        regime, gaps = classify_regime(fam)
        print(f"\n   masses {fam}  ->  {regime}")
        for s, t, g in gaps:
            verdict = "helps" if g > 0 else "hurts"
            print(f"      G({s:8.4f}, {t:8.4f}) = {g:+.9f}   mixing {verdict}")


def main() -> None:
    print("Sharp curvature of the Lagrange exponent  sigma(t) = (1 + cbrt(27t - 1))/3")
    print("Critical mass t_c = 1/27 = " + f"{CRITICAL_MASS:.12f}")
    demo_inversion()
    demo_curvature()
    demo_sharpness()
    demo_jensen()
    demo_sandwich()
    demo_derivative()
    demo_merging()
    demo_amgm_bridge()
    demo_classifier()
    print()
    print("=" * 78)
    print("All numerical checks passed.")
    print("=" * 78)


if __name__ == "__main__":
    main()
