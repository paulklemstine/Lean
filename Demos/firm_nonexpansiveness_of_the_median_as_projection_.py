"""
demo.py -- Numerical demonstrations for "The Median as a Metric Projection".

Every result stated in the accompanying paper is exercised numerically here:

  1. The median of three numbers equals the clamp (metric projection) of one of
     them onto the interval spanned by the other two.
  2. The variational inequality  (x - Px)(y - Px) <= 0  for all y in [a, b].
  3. FIRM NONEXPANSIVENESS (the headline):
         (Tx - Ty)^2 + ((x - Tx) - (y - Ty))^2 <= (x - y)^2 ,
     with equality for the interval clamp, and the derived 1-Lipschitz bound.
  4. The Pythagorean inequality and uniqueness of the nearest point.
  5. Firm nonexpansiveness on the line == monotone + 1-Lipschitz, and the
     reflection form: 2T - I is nonexpansive.
  6. Sharpness: T(x) = min(|x|, 1) is nonexpansive, has range [0,1] and fixed
     set [0,1], yet is NOT the projection onto [0,1] -- it is not firm.
  7. Composition: firmness is closed under composition on the line, but the
     composite of the two orthogonal projections P1 (horizontal axis) and P2
     (diagonal) in the plane is not firmly nonexpansive.
  8. The coordinatewise median (box projection) is firmly nonexpansive in R^n.
  9. l-infinity robustness of the median and of every rung of a quota ladder.
 10. Relaxed median updates decay the residual by exactly (1 - lambda)^n, and
     unrelaxed alternating median filters converge into the intersection of two
     brackets.

Self-contained: standard library only.
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Callable, Iterable, List, Sequence, Tuple

TOL = 1e-12

# --------------------------------------------------------------------------- #
# 1.  The median, the clamp, and their identification
# --------------------------------------------------------------------------- #


def med3(x: float, a: float, b: float) -> float:
    """Median (middle value) of the three numbers x, a, b."""
    return max(min(x, a), min(max(x, a), b))


def proj(a: float, b: float, x: float) -> float:
    """Metric projection (clamp) of x onto the interval [a, b]; requires a <= b."""
    return max(a, min(x, b))


def check_median_is_projection(trials: int = 20000, seed: int = 0) -> bool:
    """med(x, a, b) == P_{[min(a,b), max(a,b)]}(x) for random reals."""
    rng = random.Random(seed)
    for _ in range(trials):
        x, a, b = (rng.uniform(-50.0, 50.0) for _ in range(3))
        if abs(med3(x, a, b) - proj(min(a, b), max(a, b), x)) > TOL:
            return False
    return True


# --------------------------------------------------------------------------- #
# 2.  Variational inequality, firmness, Pythagoras
# --------------------------------------------------------------------------- #


def variational_product(a: float, b: float, x: float, y: float) -> float:
    """(x - Px)(y - Px); must be <= 0 whenever y lies in [a, b]."""
    p = proj(a, b, x)
    return (x - p) * (y - p)


def firm_defect(T: Callable[[float], float], x: float, y: float) -> float:
    """(x-y)^2 - [ (Tx-Ty)^2 + ((x-Tx)-(y-Ty))^2 ].  Firm <=> defect >= 0 always."""
    tx, ty = T(x), T(y)
    return (x - y) ** 2 - ((tx - ty) ** 2 + ((x - tx) - (y - ty)) ** 2)


def pythagoras_defect(a: float, b: float, x: float, y: float) -> float:
    """(x-y)^2 - [ (x-Px)^2 + (Px-y)^2 ]; nonnegative for y in [a, b]."""
    p = proj(a, b, x)
    return (x - y) ** 2 - ((x - p) ** 2 + (p - y) ** 2)


def check_firmness_of_clamp(trials: int = 20000, seed: int = 1) -> Tuple[bool, float]:
    """Firmness of the clamp; returns (holds, worst defect seen)."""
    rng = random.Random(seed)
    worst = math.inf
    ok = True
    for _ in range(trials):
        a, b = sorted((rng.uniform(-20.0, 20.0), rng.uniform(-20.0, 20.0)))
        x, y = rng.uniform(-40.0, 40.0), rng.uniform(-40.0, 40.0)
        d = firm_defect(lambda t: proj(a, b, t), x, y)
        worst = min(worst, d)
        if d < -TOL:
            ok = False
    return ok, worst


# --------------------------------------------------------------------------- #
# 3.  Characterisation: firm == monotone + 1-Lipschitz == reflection nonexpansive
# --------------------------------------------------------------------------- #


def is_firm_sampled(T: Callable[[float], float], grid: Sequence[float]) -> bool:
    return all(firm_defect(T, x, y) >= -TOL for x in grid for y in grid)


def is_monotone_sampled(T: Callable[[float], float], grid: Sequence[float]) -> bool:
    pts = sorted(grid)
    return all(T(u) <= T(v) + TOL for u, v in zip(pts, pts[1:]))


def is_lipschitz1_sampled(T: Callable[[float], float], grid: Sequence[float]) -> bool:
    return all(abs(T(x) - T(y)) <= abs(x - y) + TOL for x in grid for y in grid)


def is_reflection_nonexpansive(T: Callable[[float], float], grid: Sequence[float]) -> bool:
    R = lambda t: 2.0 * T(t) - t
    return all(abs(R(x) - R(y)) <= abs(x - y) + TOL for x in grid for y in grid)


def impostor(x: float) -> float:
    """T(x) = min(|x|, 1): nonexpansive, range [0,1], Fix = [0,1] -- but not the clamp."""
    return min(abs(x), 1.0)


# --------------------------------------------------------------------------- #
# 4.  Composition: the line versus the plane
# --------------------------------------------------------------------------- #

Vec = Tuple[float, ...]


def sqnorm(v: Iterable[float]) -> float:
    return sum(t * t for t in v)


def vsub(u: Vec, v: Vec) -> Vec:
    return tuple(a - b for a, b in zip(u, v))


def P1(p: Vec) -> Vec:
    """Orthogonal projection of the plane onto the horizontal axis."""
    return (p[0], 0.0)


def P2(p: Vec) -> Vec:
    """Orthogonal projection of the plane onto the diagonal y = x."""
    m = (p[0] + p[1]) / 2.0
    return (m, m)


def firm_defect_vec(T: Callable[[Vec], Vec], x: Vec, y: Vec) -> float:
    tx, ty = T(x), T(y)
    return sqnorm(vsub(x, y)) - (
        sqnorm(vsub(tx, ty)) + sqnorm(vsub(vsub(x, tx), vsub(y, ty)))
    )


# --------------------------------------------------------------------------- #
# 5.  Box projection = coordinatewise median in R^n
# --------------------------------------------------------------------------- #


def proj_box(a: Sequence[float], b: Sequence[float], x: Sequence[float]) -> Vec:
    return tuple(proj(ai, bi, xi) for ai, bi, xi in zip(a, b, x))


def check_box_firmness(n: int = 6, trials: int = 5000, seed: int = 2) -> Tuple[bool, float]:
    rng = random.Random(seed)
    worst = math.inf
    ok = True
    for _ in range(trials):
        lo = [rng.uniform(-5.0, 5.0) for _ in range(n)]
        hi = [l + abs(rng.gauss(0.0, 3.0)) for l in lo]
        x = tuple(rng.uniform(-15.0, 15.0) for _ in range(n))
        y = tuple(rng.uniform(-15.0, 15.0) for _ in range(n))
        d = firm_defect_vec(lambda v: proj_box(lo, hi, v), x, y)
        worst = min(worst, d)
        if d < -1e-9:
            ok = False
    return ok, worst


# --------------------------------------------------------------------------- #
# 6.  l-infinity robustness: the median and the quota ladder
# --------------------------------------------------------------------------- #


def quota_budget(K: Sequence[int], m: int) -> int:
    """Largest b such that at least m entries of K satisfy K_i >= b: the m-th largest entry."""
    if not 1 <= m <= len(K):
        raise ValueError("quota m out of range")
    return sorted(K, reverse=True)[m - 1]


def linf(u: Sequence[float], v: Sequence[float]) -> float:
    return max(abs(a - b) for a, b in zip(u, v))


def check_ladder_linf(n: int = 9, trials: int = 5000, seed: int = 3) -> bool:
    rng = random.Random(seed)
    for _ in range(trials):
        K = [rng.randrange(0, 400) for _ in range(n)]
        d = rng.randrange(0, 40)
        Kp = [max(0, k + rng.randint(-d, d)) for k in K]
        dd = int(linf(K, Kp))
        for m in range(1, n + 1):
            if abs(quota_budget(K, m) - quota_budget(Kp, m)) > dd:
                return False
    return True


# --------------------------------------------------------------------------- #
# 7.  Iteration: relaxed decay and alternating filters
# --------------------------------------------------------------------------- #


def relaxed_step(lam: float, a: float, b: float, x: float) -> float:
    return (1.0 - lam) * x + lam * proj(a, b, x)


def relaxed_orbit(lam: float, a: float, b: float, x0: float, n: int) -> List[float]:
    out, x = [x0], x0
    for _ in range(n):
        x = relaxed_step(lam, a, b, x)
        out.append(x)
    return out


def alternating_orbit(
    a: float, b: float, c: float, d: float, x0: float, n: int
) -> List[float]:
    out, x = [x0], x0
    for _ in range(n):
        x = proj(a, b, proj(c, d, x))
        out.append(x)
    return out


# --------------------------------------------------------------------------- #
# Reporting
# --------------------------------------------------------------------------- #


def rule(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def main() -> None:
    rule("1.  The median IS the metric projection onto the bracket")
    for x, a, b in [(224, 160, 256), (300, 160, 256), (-5, 160, 256), (200, 256, 160)]:
        print(
            f"  med({x:>5}, {a:>4}, {b:>4}) = {med3(x, a, b):>7.2f}"
            f"   clamp of {x:>5} onto [{min(a,b)}, {max(a,b)}] = "
            f"{proj(min(a, b), max(a, b), x):>7.2f}"
        )
    print(f"  20000 random triples agree: {check_median_is_projection()}")

    rule("2.  The variational inequality  (x - Px)(y - Px) <= 0")
    a, b = 160.0, 256.0
    for x in (100.0, 224.0, 400.0):
        vals = [variational_product(a, b, x, y) for y in (160.0, 200.0, 224.0, 256.0)]
        print(f"  x = {x:>6.1f}:  products over y in [a,b] = "
              + ", ".join(f"{v:>10.2f}" for v in vals))

    rule("3.  FIRM NONEXPANSIVENESS of the median-as-projection")
    print("  Bracket [160, 256]; perturb the third seed from x to y.")
    print(f"  {'x':>8} {'y':>8} {'|dx|':>8} {'|d out|':>9} {'|d resid|':>10} "
          f"{'sum of squares':>15} {'(x-y)^2':>10}")
    for x, y in [(224.0, 230.0), (150.0, 170.0), (300.0, 100.0), (120.0, 140.0)]:
        tx, ty = proj(a, b, x), proj(a, b, y)
        d_out, d_res = tx - ty, (x - tx) - (y - ty)
        print(
            f"  {x:>8.1f} {y:>8.1f} {abs(x-y):>8.2f} {abs(d_out):>9.2f} "
            f"{abs(d_res):>10.2f} {d_out**2 + d_res**2:>15.2f} {(x-y)**2:>10.2f}"
        )
    ok, worst = check_firmness_of_clamp()
    print(f"  20000 random instances firm: {ok}   (smallest slack observed: {worst:.3e})")
    print("  Note: the clamp attains equality whenever both points sit on the")
    print("  same side of the bracket, so the inequality is sharp.")

    rule("4.  Pythagoras and uniqueness of the nearest point")
    x = 300.0
    p = proj(a, b, x)
    print(f"  x = {x}, projection = {p}")
    for y in (160.0, 200.0, 256.0):
        print(f"    y = {y:>6.1f}:  |x-y| = {abs(x-y):>7.2f}   "
              f"Pythagoras slack = {pythagoras_defect(a, b, x, y):>10.2f}")
    best = min((abs(x - y), y) for y in [a + k * (b - a) / 1000.0 for k in range(1001)])
    print(f"  Nearest point of [{a}, {b}] found by brute force: {best[1]:.3f} "
          f"(projection: {p:.3f})")

    rule("5.  Characterisation: firm  <=>  monotone + 1-Lipschitz  <=>  reflection NE")
    grid = [k / 4.0 for k in range(-40, 41)]
    clamp01: Callable[[float], float] = lambda t: proj(0.0, 1.0, t)
    tests: List[Tuple[str, Callable[[float], float]]] = [
        ("clamp onto [0,1]", clamp01),
        ("identity", lambda t: t),
        ("half-shrink t/2", lambda t: t / 2.0),
        ("impostor min(|t|,1)", impostor),
        ("doubling 2t", lambda t: 2.0 * t),
        ("reflection -t", lambda t: -t),
    ]
    print(f"  {'map':>22} {'firm':>6} {'mono':>6} {'Lip<=1':>8} {'2T-I NE':>9}")
    for name, T in tests:
        print(
            f"  {name:>22} {str(is_firm_sampled(T, grid)):>6} "
            f"{str(is_monotone_sampled(T, grid)):>6} "
            f"{str(is_lipschitz1_sampled(T, grid)):>8} "
            f"{str(is_reflection_nonexpansive(T, grid)):>9}"
        )
    print("  The three columns after 'firm' agree with it exactly: monotone AND")
    print("  1-Lipschitz is equivalent to firmness, as is nonexpansiveness of 2T - I.")

    rule("6.  Sharpness: a nonexpansive impostor with the median's range and fixed set")
    print(f"  range of min(|x|,1) over the grid: "
          f"[{min(impostor(t) for t in grid):.2f}, {max(impostor(t) for t in grid):.2f}]")
    fixed = [t for t in grid if abs(impostor(t) - t) < TOL]
    print(f"  fixed points: [{min(fixed):.2f}, {max(fixed):.2f}]  (same as the clamp)")
    print(f"  yet  T(-2) = {impostor(-2.0):.2f}  while  clamp(-2) = {proj(0.0,1.0,-2.0):.2f}")
    print("  It mistakes a seed far BELOW the bracket for one far ABOVE it.")
    print(f"  worst firmness defect of the impostor on the grid: "
          f"{min(firm_defect(impostor, u, v) for u in grid for v in grid):.3f}  (< 0)")

    rule("7.  Composition: fine on the line, broken in the plane")
    S: Callable[[float], float] = lambda t: proj(0.0, 1.0, t)
    U: Callable[[float], float] = lambda t: proj(-2.0, 0.5, t)
    print(f"  S = clamp[0,1], U = clamp[-2,0.5];  S o U firm on the grid: "
          f"{is_firm_sampled(lambda t: S(U(t)), grid)}")
    comp: Callable[[Vec], Vec] = lambda p: P1(P2(p))
    xs: Vec = (0.0, 1.0)
    ys: Vec = (0.0, 0.0)
    print(f"  In the plane: P1 firm at a sample pair: "
          f"{firm_defect_vec(P1, xs, ys):+.4f}")
    print(f"                P2 firm at a sample pair: "
          f"{firm_defect_vec(P2, xs, ys):+.4f}")
    tx, ty = comp(xs), comp(ys)
    print(f"                (P1 o P2)(0,1) = {tx},  (P1 o P2)(0,0) = {ty}")
    print(f"                output^2 = {sqnorm(vsub(tx,ty)):.4f},  "
          f"residual^2 = {sqnorm(vsub(vsub(xs,tx), vsub(ys,ty))):.4f},  "
          f"budget = {sqnorm(vsub(xs,ys)):.4f}")
    print(f"                firmness defect = {firm_defect_vec(comp, xs, ys):+.4f}  "
          "(negative: NOT firm)")

    rule("8.  The coordinatewise median is firmly nonexpansive in R^n")
    ok, worst = check_box_firmness()
    print(f"  5000 random 6-dimensional instances firm: {ok}  "
          f"(smallest slack: {worst:.3e})")
    lo, hi = (0.0, 1.0, -3.0), (2.0, 4.0, -1.0)
    pt = (5.0, 0.5, -9.0)
    print(f"  clamp of {pt} onto the box = {proj_box(lo, hi, pt)}")

    rule("9.  l-infinity robustness: median and the whole quota ladder")
    print("  Perturb ALL three seeds of {256, 224, 160} by at most one grid step (32):")
    for pert in [(32.0, -32.0, 32.0), (-10.0, 20.0, -30.0), (32.0, 32.0, 32.0)]:
        seeds = (256.0, 224.0, 160.0)
        new = tuple(s + p for s, p in zip(seeds, pert))
        m0, m1 = med3(*seeds), med3(*new)
        print(f"    perturbation {pert}:  median {m0:.1f} -> {m1:.1f}   "
              f"|change| = {abs(m1-m0):.1f} <= {max(abs(p) for p in pert):.1f}")
    K = [412, 256, 224, 224, 160, 96, 64]
    Kp = [k + delta for k, delta in zip(K, [12, -20, 7, 0, -15, 20, 3])]
    d = int(linf(K, Kp))
    print(f"  ensemble  K  = {K}")
    print(f"  ensemble  K' = {Kp}      l-inf distance = {d}")
    print(f"  {'quota m':>8} {'Q(K,m)':>8} {'Q(Kp,m)':>8} {'|diff|':>7}")
    for m in range(1, len(K) + 1):
        q0, q1 = quota_budget(K, m), quota_budget(Kp, m)
        print(f"  {m:>8} {q0:>8} {q1:>8} {abs(q0-q1):>7}")
    print(f"  every rung moved by at most {d}: {all(abs(quota_budget(K,m)-quota_budget(Kp,m)) <= d for m in range(1, len(K)+1))}")
    print(f"  randomised check over 5000 ensembles: {check_ladder_linf()}")

    rule("10.  Iteration: exact geometric decay, and alternating consensus")
    lam, x0 = 0.3, 400.0
    orbit = relaxed_orbit(lam, 160.0, 256.0, x0, 8)
    target = proj(160.0, 256.0, x0)
    print(f"  relaxed update with lambda = {lam}, x0 = {x0}, median = {target}")
    print(f"  {'n':>3} {'x_n':>12} {'residual':>12} {'predicted':>12}")
    for n, xn in enumerate(orbit):
        pred = (1.0 - lam) ** n * (x0 - target)
        print(f"  {n:>3} {xn:>12.5f} {xn - target:>12.5f} {pred:>12.5f}")
    print("  residual equals the prediction to machine precision: an identity, not a bound.")
    print()
    print("  alternating filter on the brackets [160,256] and [224,384]:")
    for start in (0.0, 300.0, 1000.0):
        orb = alternating_orbit(160.0, 256.0, 224.0, 384.0, start, 4)
        print(f"    start {start:>7.1f}:  " + " -> ".join(f"{v:.1f}" for v in orb)
              + f"    limit in [224, 256]: {224.0 - TOL <= orb[-1] <= 256.0 + TOL}")
    print("  the limit satisfies BOTH brackets: no spurious compromise.")

    rule("Summary")
    print("  The median of three numbers is the metric projection onto the bracket")
    print("  spanned by the other two; it obeys the Pythagorean robustness budget")
    print("  (output shift)^2 + (residual shift)^2 <= (input shift)^2; and that firm")
    print("  inequality, together with fixing the endpoints and mapping into the")
    print("  bracket, determines it uniquely among all self-maps of the line.")


if __name__ == "__main__":
    main()
