#!/usr/bin/env python3
"""
Footprint-scale transfer: numerical companion.

This script illustrates, with plain Python (standard library only), the exact
finite-sample identities behind the transfer of a fitted "yield dial" across
scales:

  1. Covariance algebra, OLS slope and R^2; affine invariance of R^2.
  2. The attenuation (errors-in-variables) law  slope = c V / (V + E).
  3. Stable slope across relation counts  =>  no relation-count noise.
  4. The Frisch-Waugh-Lovell identity for two regressors.
  5. The t-statistic / partial-R^2 dictionary (min |t| = 3.92).
  6. The relation-count reliability curve R^2(m) = V / (V + F + sigma/m):
     Spearman-Brown upper bound, forced structural floor, two-point
     ceiling 82/105, and the 626-relation threshold for R^2 >= 0.70.
  7. The slope-R^2 factorisation  R^2 = slope * V / (V + H).
  8. The tropical limit  (1/alpha) log sum l^{-alpha}  ->  -log min l.

Every identity in sections 1, 2, 4 and 7 is an exact algebraic statement about
finite data, so the script checks them on random data to machine precision.
"""
from __future__ import annotations

import math
import random
from fractions import Fraction
from typing import Callable, Sequence

Vec = list[float]


# ---------------------------------------------------------------------------
# 1. Covariance algebra
# ---------------------------------------------------------------------------
def mean(x: Sequence[float]) -> float:
    return sum(x) / len(x)


def cov(x: Sequence[float], y: Sequence[float]) -> float:
    """Centred cross-product sum  sum_i (x_i - xbar)(y_i - ybar)."""
    mx, my = mean(x), mean(y)
    return sum((a - mx) * (b - my) for a, b in zip(x, y))


def slope(x: Sequence[float], y: Sequence[float]) -> float:
    """OLS slope of y on x (the calibration slope when x is a prediction)."""
    return cov(x, y) / cov(x, x)


def rsq(x: Sequence[float], y: Sequence[float]) -> float:
    """Coefficient of determination of the simple regression of y on x."""
    return cov(x, y) ** 2 / (cov(x, x) * cov(y, y))


def add(x: Sequence[float], y: Sequence[float]) -> Vec:
    return [a + b for a, b in zip(x, y)]


def scale(c: float, x: Sequence[float]) -> Vec:
    return [c * a for a in x]


def orthogonalise(cols: list[Vec]) -> list[Vec]:
    """Gram-Schmidt on centred columns, so that the returned columns are
    mutually *exactly* uncorrelated in the sample sense (cov = 0)."""
    out: list[Vec] = []
    for v in cols:
        mv = mean(v)
        w = [a - mv for a in v]
        for u in out:
            w = add(w, scale(-cov(u, w) / cov(u, u), u))
        out.append(w)
    return out


def close(a: float, b: float, tol: float = 1e-9) -> bool:
    return abs(a - b) <= tol * max(1.0, abs(a), abs(b))


def section(title: str) -> None:
    print("\n" + "=" * 72 + f"\n{title}\n" + "=" * 72)


def demo_affine_invariance(rng: random.Random) -> None:
    section("1. Affine reparametrisation: slope rescales, R^2 does not")
    n = 80
    x = [rng.gauss(0, 1) for _ in range(n)]
    y = [0.9 * a + rng.gauss(0, 1) for a in x]
    for a, b in [(0.0, 1.0), (3.0, 2.0), (-1.0, 0.5), (10.0, -4.0)]:
        xt = [a + b * v for v in x]
        print(f"  x -> {a:+5.1f} + {b:+4.1f} x :  slope = {slope(xt, y):+.5f}"
              f"  (slope/b = {slope(x, y) / b:+.5f}),  R^2 = {rsq(xt, y):.5f}")
        assert close(slope(xt, y), slope(x, y) / b)
        assert close(rsq(xt, y), rsq(x, y))
    print("  Cauchy-Schwarz: 0 <= R^2 <= 1  ->", 0 <= rsq(x, y) <= 1)


# ---------------------------------------------------------------------------
# 2-3. Attenuation law
# ---------------------------------------------------------------------------
def att_slope(c: float, V: float, E0: float, sigma: float, m: float) -> float:
    """Attenuated slope c V / (V + E0 + sigma/m) as a function of relation count m."""
    return c * V / (V + E0 + sigma / m)


def demo_attenuation(rng: random.Random) -> None:
    section("2. The attenuation law  slope = c V / (V + E)  (exact on finite data)")
    n = 240
    s, e, eta = orthogonalise([[rng.gauss(0, 1) for _ in range(n)] for _ in range(3)])
    e = scale(0.35, e)
    for c in [1.0, 0.9, 0.834]:
        x = add(s, e)
        y = add(scale(c, s), eta)
        V, E = cov(s, s), cov(e, e)
        lhs, rhs = slope(x, y), c * V / (V + E)
        print(f"  c = {c:5.3f}:  observed slope = {lhs:.6f},  c V/(V+E) = {rhs:.6f}")
        assert close(lhs, rhs)
    print("  With c = 1 the slope lies in (0, 1]; it equals 1 iff E = 0.")

    section("3. Stable slope across relation counts forces sigma = 0")
    V, E0 = 1.0, 0.12
    for sigma in [0.0, 5.0, 20.0]:
        s80 = att_slope(0.95, V, E0, sigma, 80)
        s240 = att_slope(0.95, V, E0, sigma, 240)
        print(f"  sigma = {sigma:5.1f}:  slope(80) = {s80:.4f},  slope(240) = {s240:.4f}"
              f"  {'(equal)' if close(s80, s240) else '(moves with m)'}")
    print("  Bit length 52 reported 0.834 at both 80 and 240 values/N: under the law,\n"
          "  the deficit 1 - 0.834 is scale drift (c < 1) plus fixed noise, not\n"
          "  relation-count noise.")


# ---------------------------------------------------------------------------
# 4. Frisch-Waugh-Lovell
# ---------------------------------------------------------------------------
def partial_coefs(x1: Sequence[float], x2: Sequence[float],
                  y: Sequence[float]) -> tuple[float, float]:
    a, b, d = cov(x1, x1), cov(x1, x2), cov(x2, x2)
    det = a * d - b * b
    beta1 = (d * cov(x1, y) - b * cov(x2, y)) / det
    beta2 = (a * cov(x2, y) - b * cov(x1, y)) / det
    return beta1, beta2


def resid(x1: Sequence[float], x2: Sequence[float]) -> Vec:
    return add(x2, scale(-slope(x1, x2), x1))


def demo_fwl(rng: random.Random) -> None:
    section("4. Frisch-Waugh-Lovell: partial coefficient of d(N) = slope on residual")
    n = 80
    dial = [rng.gauss(0, 1) for _ in range(n)]
    dN = [0.6 * a + rng.gauss(0, 1) for a in dial]   # d(N) correlated with the dial
    y = [0.8 * a + 0.3 * b + rng.gauss(0, 0.7) for a, b in zip(dial, dN)]
    b1, b2 = partial_coefs(dial, dN, y)
    r = resid(dial, dN)
    print(f"  multiple-regression coefficient of d(N): {b2:.6f}")
    print(f"  slope of y on residual(d(N) | dial)  : {slope(r, y):.6f}")
    print(f"  cov(dial, residual)                   : {cov(dial, r):.2e}  (orthogonal)")
    assert close(b2, slope(r, y))
    assert abs(cov(dial, r)) < 1e-9
    a, b, d = cov(dial, dial), cov(dial, dN), cov(dN, dN)
    assert close(a * b1 + b * b2, cov(dial, y)) and close(b * b1 + d * b2, cov(dN, y))
    print("  normal equations verified.")


# ---------------------------------------------------------------------------
# 5. t-statistic <-> partial R^2
# ---------------------------------------------------------------------------
def partial_rsq_threshold(t: float, df: float) -> float:
    """|t| >= t  <=>  partial R^2 >= t^2 / (t^2 + df)."""
    return t * t / (t * t + df)


def demo_t_dictionary() -> None:
    section("5. What min |t| = 3.92 says about effect size")
    for m in (80, 240):
        df = m - 3
        thr = partial_rsq_threshold(3.92, df)
        print(f"  {m:3d} values/N, df = {df:3d}:  partial R^2 of d(N) >= {thr:.5f}")
    exact = Fraction(392, 100) ** 2 / (Fraction(392, 100) ** 2 + 77)
    print(f"  exact threshold at df=77 : {exact} = {float(exact):.6f}"
          f"  (< 1/6 = {1/6:.6f}: the tempting claim '> 1/6' is FALSE)")
    print("  The same |t| at larger df is a weaker effect-size statement.")


# ---------------------------------------------------------------------------
# 6. Relation-count reliability curve
# ---------------------------------------------------------------------------
def rel_r2(V: float, F: float, sigma: float, m: float) -> float:
    return V / (V + F + sigma / m)


def spearman_brown(k: float, R: float) -> float:
    return k * R / (1 + (k - 1) * R)


def two_point_fit(m1: Fraction, R1: Fraction, m2: Fraction,
                  R2: Fraction) -> tuple[Fraction, Fraction]:
    """Return (ceiling, sigma/V) from two cells, using that 1/R^2 is affine in 1/m:
    1/R^2 = 1/ceiling + (sigma/V)(1/m)."""
    inv_ceiling = (m2 / R2 - m1 / R1) / (m2 - m1)
    noise_ratio = (1 / R1 - inv_ceiling) * m1
    return 1 / inv_ceiling, noise_ratio


def min_relations(ceiling: Fraction, noise_ratio: Fraction, target: Fraction) -> int:
    """Smallest integer m with R^2(m) >= target (requires target < ceiling)."""
    gap = 1 / target - 1 / ceiling
    return math.ceil(noise_ratio / gap)


def demo_reliability() -> None:
    section("6. R^2 versus relation count at u = 2.5, bit length 48")
    R80, R240 = Fraction(41, 100), Fraction(3, 5)
    sb = spearman_brown(3, float(R80))
    print(f"  Spearman-Brown prediction from R^2(80) = 0.41 at 240: {sb:.4f}")
    print(f"  observed 0.60 < {sb:.4f}  =>  a structural floor F > 0 is forced")
    ceil, ratio = two_point_fit(Fraction(80), R80, Fraction(240), R240)
    print(f"  two-point ceiling  V/(V+F) = {ceil} = {float(ceil):.4f}")
    print(f"  noise ratio sigma/V        = {ratio} = {float(ratio):.3f}")
    F_over_V = 1 / ceil - 1
    V = 1.0
    F, sigma = float(F_over_V), float(ratio)
    for m in (80, 240, 600, 625, 626, 1000, 10 ** 6):
        print(f"    m = {m:>7d}:  R^2 = {rel_r2(V, F, sigma, m):.5f}")
    print(f"  smallest m with R^2 >= 0.70 : {min_relations(ceil, ratio, Fraction(7, 10))}"
          f"  (exact threshold 53200/85 = {53200 / 85:.3f})")
    print(f"  0.79 > ceiling {float(ceil):.4f}: no relation count ever reaches 0.79")


# ---------------------------------------------------------------------------
# 7. Slope-R^2 factorisation
# ---------------------------------------------------------------------------
def demo_factorisation(rng: random.Random) -> None:
    section("7. R^2 = slope * V/(V+H): the gap between columns is yield noise")
    n = 240
    s, e, eta = orthogonalise([[rng.gauss(0, 1) for _ in range(n)] for _ in range(3)])
    e, eta = scale(0.3, e), scale(1.0, eta)
    x, y = add(s, e), add(s, eta)
    V, H = cov(s, s), cov(eta, eta)
    print(f"  slope = {slope(x, y):.4f},  V/(V+H) = {V / (V + H):.4f},"
          f"  product = {slope(x, y) * V / (V + H):.4f},  R^2 = {rsq(x, y):.4f}")
    assert close(rsq(x, y), slope(x, y) * V / (V + H))
    x0 = add(s, e)
    assert close(slope(x0, s), rsq(x0, s))
    print(f"  noiseless yield: slope = R^2 = {slope(x0, s):.4f}")


# ---------------------------------------------------------------------------
# 8. Tropical limit of the dial
# ---------------------------------------------------------------------------
def log_dial(support: Sequence[int], alpha: float) -> float:
    """(1/alpha) log sum_{l in support} l^{-alpha}, computed stably (log-sum-exp)."""
    logs = [-alpha * math.log(l) for l in support]
    mx = max(logs)
    return (mx + math.log(sum(math.exp(v - mx) for v in logs))) / alpha


def demo_tropical(rng: random.Random) -> None:
    section("8. Tropical limit: (1/alpha) log S_alpha(N)  ->  -log min supp(N)")
    support = [3, 5, 7, 11, 13]
    for alpha in (0.5, 1, 2, 5, 20, 100):
        print(f"  alpha = {alpha:6.1f}:  {log_dial(support, alpha):+.6f}"
              f"   target -log 3 = {-math.log(3):+.6f}")
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
    supports = [sorted(rng.sample(primes, rng.randint(1, 5))) for _ in range(120)]
    y = [-math.log(min(S)) + 0.3 * math.log(len(S)) + rng.gauss(0, 0.4) for S in supports]
    t = [-math.log(min(S)) for S in supports]
    print(f"  R^2 of min-plus statistic         : {rsq(t, y):.5f}")
    for alpha in (1, 3, 10, 30, 100):
        xa = [log_dial(S, alpha) for S in supports]
        print(f"  R^2 of normalised log-dial a={alpha:<4d}: {rsq(xa, y):.5f}")


def main() -> None:
    rng = random.Random(20260830)
    demo_affine_invariance(rng)
    demo_attenuation(rng)
    demo_fwl(rng)
    demo_t_dictionary()
    demo_reliability()
    demo_factorisation(rng)
    demo_tropical(rng)
    print("\nAll exact identities checked.")


if __name__ == "__main__":
    main()
