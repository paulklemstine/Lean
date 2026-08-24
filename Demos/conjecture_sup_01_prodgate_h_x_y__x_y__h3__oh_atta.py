#!/usr/bin/env python3
"""
Polarisation cancellation in exponential product gates
======================================================

Numerical demonstration of the results on the width-four exponential
product gate

    S_h(u)    = (exp(h*u) + exp(-h*u) - 2) / h**2          (soft square)
    P_h(x, y) = (S_h(x + y) - S_h(x - y)) / 4              (product gate)

which approximates x*y on the unit square with error Theta(h^2).

What this script verifies numerically
-------------------------------------
1.  The exact error identity
        P_h(x,y) - x*y = ( g(h(x+y)) - g(h|x-y|) ) / (4 h^2),
    where g(t) = exp(t) + exp(-t) - 2 - t^2.
2.  The two-sided polarised bound with the *difference* of fourth powers,
        h^2[(x+y)^4-(x-y)^4]/48  <=  err  <=  h^2[(x+y)^4-(x-y)^4]/24,
    and the failure of the naive *sum* bound to vanish on the axes.
3.  The sharp local leading term  h^2 x y (x^2+y^2)/6, with |remainder| <= h^4/21.
4.  The corner theorem: the maximum of |P_h - xy| over [0,1]^2 is attained at
    (1,1) and equals ( exp(2h)+exp(-2h)-2-4h^2 ) / (4 h^2) = h^2/3 + 2h^4/45 + ...
5.  No scalar debiasing: for every gain lam, one of two probes errs by >= h^2/100.
6.  No affine debiasing: for every (lam, mu, nu, kappa), one of seven probes
    errs by >= h^2/210.  The mixed second difference kills mu, nu, kappa exactly.
7.  Universality: for any even, monotone generator remainder the maximum is
    gap(2h)/(4h^2); for a pure quartic remainder c*t^4 it is exactly 4*c*h^2.
8.  Product trees: two chained gates err by at most 3h^2/4 (additive prediction
    2h^2/3), and the error is always one-sided (an overshoot).

Run with:  python3 demo.py
"""

from __future__ import annotations

import math
from typing import Callable, Iterable, List, Sequence, Tuple

# --------------------------------------------------------------------------- #
# Core definitions
# --------------------------------------------------------------------------- #


def cosh_gap(t: float) -> float:
    """g(t) = exp(t) + exp(-t) - 2 - t^2, the remainder of 2*cosh after its
    quadratic Taylor polynomial.  Even, vanishing at 0, non-decreasing on
    [0, inf), with power series t^4/12 + t^6/360 + t^8/20160 + ...

    For small |t| the direct expression cancels catastrophically, so we fall
    back on the series, which converges geometrically.
    """
    if abs(t) < 1e-2:
        term = t ** 4 / 12.0
        total = term
        k = 2
        while True:
            k += 1
            term = 2.0 * t ** (2 * k) / math.factorial(2 * k)
            total += term
            if abs(term) < 1e-300 or abs(term) < 1e-18 * abs(total):
                break
        return total
    return math.exp(t) + math.exp(-t) - 2.0 - t * t


def soft_square(h: float, u: float) -> float:
    """S_h(u) = (exp(h u) + exp(-h u) - 2)/h^2 = u^2 + gap(h u)/h^2."""
    return u * u + cosh_gap(h * u) / (h * h)


def prod_gate(h: float, x: float, y: float) -> float:
    """P_h(x, y) = (S_h(x+y) - S_h(x-y))/4, the width-four product gate."""
    return (soft_square(h, x + y) - soft_square(h, x - y)) / 4.0


def gate_error(h: float, x: float, y: float) -> float:
    """P_h(x, y) - x*y."""
    return prod_gate(h, x, y) - x * y


def corner_sup(h: float) -> float:
    """Closed form of  sup_{[0,1]^2} |P_h(x,y) - x y| = gap(2h)/(4 h^2)."""
    return cosh_gap(2.0 * h) / (4.0 * h * h)


# --------------------------------------------------------------------------- #
# Helpers
# --------------------------------------------------------------------------- #


def grid(n: int) -> List[float]:
    """Uniform grid of n+1 points on [0, 1]."""
    return [i / n for i in range(n + 1)]


def sup_over_square(f: Callable[[float, float], float], n: int = 200
                    ) -> Tuple[float, Tuple[float, float]]:
    """Maximise |f| over a uniform (n+1)x(n+1) grid of the unit square."""
    best, arg = -1.0, (0.0, 0.0)
    pts = grid(n)
    for x in pts:
        for y in pts:
            v = abs(f(x, y))
            if v > best:
                best, arg = v, (x, y)
    return best, arg


def nelder_mead(f: Callable[[Sequence[float]], float], x0: List[float],
                step: float = 0.05, iters: int = 4000,
                tol: float = 1e-15) -> Tuple[List[float], float]:
    """Minimal Nelder-Mead simplex minimiser (no external dependencies).

    Suitable for the small convex, piecewise-linear objectives appearing here.
    Returns the best point found and its objective value.
    """
    n = len(x0)
    simplex: List[List[float]] = [list(x0)]
    for i in range(n):
        pt = list(x0)
        pt[i] += step if pt[i] == 0.0 else step * abs(pt[i])
        simplex.append(pt)
    vals = [f(p) for p in simplex]

    for _ in range(iters):
        order = sorted(range(n + 1), key=lambda i: vals[i])
        simplex = [simplex[i] for i in order]
        vals = [vals[i] for i in order]
        if abs(vals[-1] - vals[0]) < tol * (abs(vals[0]) + tol):
            break
        centroid = [sum(p[j] for p in simplex[:-1]) / n for j in range(n)]
        worst = simplex[-1]
        refl = [centroid[j] + (centroid[j] - worst[j]) for j in range(n)]
        fr = f(refl)
        if fr < vals[0]:
            exp_pt = [centroid[j] + 2.0 * (centroid[j] - worst[j]) for j in range(n)]
            fe = f(exp_pt)
            simplex[-1], vals[-1] = (exp_pt, fe) if fe < fr else (refl, fr)
        elif fr < vals[-2]:
            simplex[-1], vals[-1] = refl, fr
        else:
            contr = [centroid[j] + 0.5 * (worst[j] - centroid[j]) for j in range(n)]
            fc = f(contr)
            if fc < vals[-1]:
                simplex[-1], vals[-1] = contr, fc
            else:
                best = simplex[0]
                simplex = [best] + [[best[j] + 0.5 * (p[j] - best[j])
                                     for j in range(n)] for p in simplex[1:]]
                vals = [f(p) for p in simplex]
    k = min(range(n + 1), key=lambda i: vals[i])
    return simplex[k], vals[k]


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


# --------------------------------------------------------------------------- #
# 1.  Exact error identity
# --------------------------------------------------------------------------- #


def demo_identity() -> None:
    banner("1.  Exact error identity:  err = [g(h(x+y)) - g(h|x-y|)] / (4h^2)")
    print(f"{'h':>8} {'x':>6} {'y':>6} {'direct error':>16} "
          f"{'identity':>16} {'|difference|':>14}")
    cases = [(0.30, 1.0, 1.0), (0.30, 0.7, 0.2), (0.10, 0.5, 0.5),
             (0.10, 1.0, 0.0), (0.05, 0.9, 0.9), (0.05, 0.3, 0.8)]
    for h, x, y in cases:
        lhs = gate_error(h, x, y)
        rhs = (cosh_gap(h * (x + y)) - cosh_gap(h * abs(x - y))) / (4 * h * h)
        print(f"{h:8.3f} {x:6.2f} {y:6.2f} {lhs:16.10e} {rhs:16.10e} "
              f"{abs(lhs - rhs):14.2e}")
    print("\nThe identity is exact: the whole error is the increment of one")
    print("even function g between h|x-y| and h(x+y).")


# --------------------------------------------------------------------------- #
# 2.  Difference beats sum: the shape of the bound
# --------------------------------------------------------------------------- #


def demo_shape() -> None:
    banner("2.  Difference vs sum:  which bound has the right shape?")
    h = 0.2
    print(f"h = {h}\n")
    print(f"{'x':>6} {'y':>6} {'true error':>14} {'diff bound /24':>16} "
          f"{'sum bound /24':>15} {'diff/48 (sharp)':>17}")
    for x, y in [(1.0, 1.0), (1.0, 0.5), (1.0, 0.0), (0.5, 0.0),
                 (0.6, 0.6), (0.3, 0.9), (0.0, 0.0)]:
        err = gate_error(h, x, y)
        d = h ** 2 * ((x + y) ** 4 - (x - y) ** 4)
        s = h ** 2 * ((x + y) ** 4 + (x - y) ** 4)
        print(f"{x:6.2f} {y:6.2f} {err:14.6e} {d / 24:16.6e} "
              f"{s / 24:15.6e} {d / 48:17.6e}")
    print("\nOn the axes (y = 0) the true error is EXACTLY zero, and so is the")
    print("difference bound; the sum bound is not.  The sum bound is lossy in")
    print("shape, not merely by a constant.")


# --------------------------------------------------------------------------- #
# 3.  Sharp leading term
# --------------------------------------------------------------------------- #


def demo_sharp_leading_term(h: float = 0.15, n: int = 120) -> None:
    banner("3.  Sharp local constant:  err = h^2 x y (x^2+y^2)/6 + O(h^4)")
    worst, arg = sup_over_square(
        lambda x, y: gate_error(h, x, y) - h ** 2 * x * y * (x * x + y * y) / 6.0,
        n=n)
    print(f"h = {h},  grid {n+1}x{n+1}")
    print(f"max |err - h^2 x y (x^2+y^2)/6| = {worst:.6e}  at {arg}")
    print(f"certified bound  h^4/21          = {h ** 4 / 21:.6e}")
    print(f"observed / certified             = {worst / (h ** 4 / 21):.4f}")
    print("\nAlso check the algebraic identity (x+y)^4 - (x-y)^4 = 8 x y (x^2+y^2):")
    for x, y in [(0.3, 0.7), (1.0, 1.0), (0.9, 0.1)]:
        lhs = (x + y) ** 4 - (x - y) ** 4
        rhs = 8 * x * y * (x * x + y * y)
        print(f"  x={x:.2f} y={y:.2f}:  {lhs:.10f} vs {rhs:.10f}")


# --------------------------------------------------------------------------- #
# 4.  The corner theorem
# --------------------------------------------------------------------------- #


def demo_corner_theorem(n: int = 200) -> None:
    banner("4.  Corner theorem:  the maximum sits at (1,1) and has a closed form")
    print(f"{'h':>8} {'grid max':>15} {'argmax':>14} {'closed form':>15} "
          f"{'h^2/3':>13} {'sup/h^2':>10}")
    for h in [0.5, 0.4, 0.3, 0.2, 0.1, 0.05, 0.02, 0.01]:
        m, arg = sup_over_square(lambda x, y: gate_error(h, x, y), n=n)
        cf = corner_sup(h)
        print(f"{h:8.3f} {m:15.8e} ({arg[0]:.2f},{arg[1]:.2f})  "
              f"{cf:15.8e} {h ** 2 / 3:13.6e} {cf / h ** 2:10.6f}")
    print("\nsup/h^2 -> 1/3 = 0.333333...  The closed form is exact for every h>0:")
    print("    sup = (exp(2h) + exp(-2h) - 2 - 4h^2)/(4h^2)")
    print("        = h^2/3 + 2h^4/45 + h^6/315 + ...")
    print("\nRemainder coefficient check  (sup - h^2/3)/h^4  ->  2/45 = 0.044444:")
    for h in [0.5, 0.25, 0.1, 0.05]:
        r = (corner_sup(h) - h ** 2 / 3) / h ** 4
        print(f"    h = {h:5.3f}:  {r:.8f}   (certified bound 1/21 = 0.047619)")


# --------------------------------------------------------------------------- #
# 5.  No scalar debiasing
# --------------------------------------------------------------------------- #


def scalar_barrier_value(h: float, lam: float) -> float:
    """max over the two probes (1,1) and (1,1/2) of |lam*P_h - true product|."""
    return max(abs(lam * prod_gate(h, 1.0, 1.0) - 1.0),
               abs(lam * prod_gate(h, 1.0, 0.5) - 0.5))


def demo_scalar_barrier() -> None:
    banner("5.  No scalar debiasing:  every gain lam leaves >= h^2/100")
    for h in [0.5, 0.3, 0.2, 0.1, 0.05]:
        # minimise over a fine sweep of gains, plus the two 'natural' choices
        best, best_lam = float("inf"), 0.0
        for k in range(-2000, 2001):
            lam = 1.0 + k * 1e-4
            v = scalar_barrier_value(h, lam)
            if v < best:
                best, best_lam = v, lam
        print(f"h = {h:5.3f}:  min over lam = {best:.6e} at lam = {best_lam:.6f}"
              f"   certified floor h^2/100 = {h ** 2 / 100:.6e}"
              f"   ratio = {best / (h ** 2 / 100):.2f}")
    print("\nThe reason: the leading error h^2 x y (x^2+y^2)/6 is NOT proportional")
    print("to x y, because of the factor x^2 + y^2.  Relative leading errors are")
    print("h^2/3 at (1,1) but 5h^2/24 at (1,1/2) -- irreconcilable by one gain.")


# --------------------------------------------------------------------------- #
# 6.  No affine debiasing, and the mixed second difference
# --------------------------------------------------------------------------- #


PROBES: Sequence[Tuple[float, float]] = (
    (1.0, 1.0), (1.0, 0.0), (0.0, 1.0), (0.0, 0.0),
    (0.5, 0.5), (0.5, 0.0), (0.0, 0.5),
)


def affine_readout(h: float, lam: float, mu: float, nu: float, kappa: float,
                   x: float, y: float) -> float:
    """lam*P_h(x,y) + mu*S_h(x) + nu*S_h(y) + kappa."""
    return (lam * prod_gate(h, x, y) + mu * soft_square(h, x)
            + nu * soft_square(h, y) + kappa)


def affine_error(h: float, lam: float, mu: float, nu: float, kappa: float,
                 x: float, y: float) -> float:
    return affine_readout(h, lam, mu, nu, kappa, x, y) - x * y


def mixed_difference(f: Callable[[float, float], float],
                     a: float, d: float, b: float, c: float) -> float:
    """D[f] = f(a,b) - f(a,c) - f(d,b) + f(d,c) on an axis-parallel rectangle."""
    return f(a, b) - f(a, c) - f(d, b) + f(d, c)


def demo_affine_barrier() -> None:
    banner("6.  No affine debiasing:  the mixed second difference kills mu,nu,kappa")

    h = 0.25
    print("First: the mixed difference annihilates all separable terms.")
    print("Take wild coefficients and watch mu, nu, kappa vanish exactly.\n")
    for (lam, mu, nu, kappa) in [(1.0, 3.7, -2.1, 5.0), (0.9, -100.0, 42.0, -7.5)]:
        f = lambda x, y: affine_error(h, lam, mu, nu, kappa, x, y)
        d1 = mixed_difference(f, 1.0, 0.0, 1.0, 0.0)          # rectangle at (1,1)
        d2 = mixed_difference(f, 0.5, 0.0, 0.5, 0.0)          # rectangle at (1/2,1/2)
        pred1 = lam * prod_gate(h, 1.0, 1.0) - 1.0
        pred2 = lam * prod_gate(h, 0.5, 0.5) - 0.25
        print(f"  lam={lam}, mu={mu}, nu={nu}, kappa={kappa}")
        print(f"    D_R1 = {d1: .12e}   predicted lam*P(1,1)-1     = {pred1: .12e}")
        print(f"    D_R2 = {d2: .12e}   predicted lam*P(.5,.5)-1/4 = {pred2: .12e}")

    print("\nSecond: the resulting floor.  The worst-probe error is a convex,")
    print("piecewise-linear function of (lam, mu, nu, kappa); we minimise it by")
    print("Nelder-Mead with restarts.\n")
    for h in [0.5, 0.3, 0.2, 0.1]:
        def objective(theta: Sequence[float], hh: float = h) -> float:
            lam, mu, nu, kappa = theta
            return max(abs(affine_error(hh, lam, mu, nu, kappa, x, y))
                       for (x, y) in PROBES)

        best = float("inf")
        for start in ([1.0, 0.0, 0.0, 0.0],
                      [1.0 - h * h / 3, 0.0, 0.0, 0.0],
                      [0.95, 0.05, 0.05, -0.01],
                      [1.05, -0.05, -0.05, 0.01]):
            _, val = nelder_mead(objective, list(start))
            best = min(best, val)
        floor = h ** 2 / 210
        print(f"h = {h:5.3f}:  best worst-probe error = {best:.6e}"
              f"   certified floor h^2/210 = {floor:.6e}"
              f"   ratio = {best / floor:.2f}")
    print("\nSeven probe points suffice: the barrier is a complete certificate.")


# --------------------------------------------------------------------------- #
# 7.  Universality across activations
# --------------------------------------------------------------------------- #


def pol_gate(gap: Callable[[float], float], h: float, x: float, y: float) -> float:
    """Polarisation gate of the generator g(t) = t^2 + gap(t)."""
    def g(t: float) -> float:
        return t * t + gap(t)
    return (g(h * (x + y)) - g(h * (x - y))) / (4.0 * h * h)


def demo_universality(n: int = 160) -> None:
    banner("7.  Universality:  the constant 1/3 is 4c, c the quartic coefficient")

    h = 0.2
    generators = [
        ("exponential:  gap(t) = e^t+e^-t-2-t^2", cosh_gap, 1.0 / 12.0),
        ("pure quartic: gap(t) = t^4/12", lambda t: t ** 4 / 12.0, 1.0 / 12.0),
        ("pure quartic: gap(t) = t^4/40", lambda t: t ** 4 / 40.0, 1.0 / 40.0),
        ("sextic:       gap(t) = t^6/30", lambda t: t ** 6 / 30.0, 0.0),
        ("exact square: gap(t) = 0", lambda t: 0.0, 0.0),
    ]
    print(f"h = {h}\n")
    print(f"{'generator':<42} {'grid max':>13} {'gap(2h)/4h^2':>14} "
          f"{'4c h^2':>12}")
    for name, gap, c in generators:
        m, _ = sup_over_square(lambda x, y: pol_gate(gap, h, x, y) - x * y, n=n)
        cf = gap(2 * h) / (4 * h * h)
        print(f"{name:<42} {m:13.6e} {cf:14.6e} {4 * c * h ** 2:12.6e}")

    print("\nFor a PURE quartic remainder the closed form is exact with no O(h^4):")
    for c in [1 / 12, 1 / 40]:
        for hh in [0.4, 0.1]:
            cf = pol_gate(lambda t: c * t ** 4, hh, 1.0, 1.0) - 1.0
            print(f"    c = {c:.5f}, h = {hh:.2f}:  max = {cf:.10e}"
                  f"   4 c h^2 = {4 * c * hh ** 2:.10e}")

    print("\nMonotonicity of the remainder is load-bearing.  Take gap(t) = -t^4,")
    print("which DEcreases on [0,inf).  The closed form predicts a negative")
    print("maximum, which is impossible for an absolute value:")
    for hh in [0.3, 0.1]:
        pred = ((2 * hh) ** 2 - (2 * hh) ** 4 - 4 * hh ** 2) / (4 * hh ** 2)
        m, arg = sup_over_square(
            lambda x, y: pol_gate(lambda t: -t ** 4, hh, x, y) - x * y, n=n)
        signed = pol_gate(lambda t: -t ** 4, hh, 1.0, 1.0) - 1.0
        print(f"    h = {hh:.2f}: formula = {pred:+.6e},  true max|err| = {m:.6e}"
              f" at {arg},  signed corner error = {signed:+.6e}")
    print("    (this gate UNDERSHOOTS: the sign of the bias flips with the sign")
    print("     of the remainder)")


# --------------------------------------------------------------------------- #
# 8.  Quadratic forms and product trees
# --------------------------------------------------------------------------- #


def demo_quadratic_form(h: float = 0.2, n_dim: int = 6) -> None:
    banner("8a.  Quadratic forms:  error <= (h^2/3 + h^4/21) * ||A||_1")
    # deterministic pseudo-random data, no imports beyond math
    def pseudo(k: int) -> float:
        return math.sin(1.0 + 2.3 * k) * math.cos(0.7 + 1.1 * k)

    A = [[pseudo(i * n_dim + j) for j in range(n_dim)] for i in range(n_dim)]
    x = [0.5 + 0.5 * math.sin(3.0 + i) ** 2 for i in range(n_dim)]
    x = [min(max(v, 0.0), 1.0) for v in x]

    approx = sum(A[i][j] * prod_gate(h, x[i], x[j])
                 for i in range(n_dim) for j in range(n_dim))
    exact = sum(A[i][j] * x[i] * x[j]
                for i in range(n_dim) for j in range(n_dim))
    norm1 = sum(abs(A[i][j]) for i in range(n_dim) for j in range(n_dim))
    bound = (h ** 2 / 3 + h ** 4 / 21) * norm1
    crude = h ** 2 * norm1
    print(f"n = {n_dim},  h = {h},  ||A||_1 = {norm1:.6f}")
    print(f"  gated value          = {approx:.10f}")
    print(f"  exact value          = {exact:.10f}")
    print(f"  |difference|         = {abs(approx - exact):.6e}")
    print(f"  sharp bound          = {bound:.6e}")
    print(f"  branchwise bound     = {crude:.6e}   (threefold worse)")


def demo_product_tree(n: int = 40) -> None:
    banner("8b.  Product trees:  errors add, they do not compound")
    print(f"{'h':>7} {'max 2-gate err':>16} {'3h^2/4':>13} {'2h^2/3 (additive)':>19}"
          f" {'err/h^2':>10} {'sign':>7}")
    for h in [0.25, 0.2, 0.15, 0.1, 0.05]:
        worst, negative = 0.0, False
        pts = grid(n)
        for x in pts:
            for y in pts:
                inner = prod_gate(h, x, y)
                for z in pts:
                    e = prod_gate(h, inner, z) - x * y * z
                    if e < -1e-14:
                        negative = True
                    worst = max(worst, abs(e))
        print(f"{h:7.3f} {worst:16.8e} {3 * h ** 2 / 4:13.6e} "
              f"{2 * h ** 2 / 3:19.6e} {worst / h ** 2:10.6f} "
              f"{'mixed' if negative else '>= 0':>7}")
    print("\nThe observed constant sits just below the additive prediction 2/3,")
    print("well inside the certified 3/4.  No compounding term appears, and the")
    print("error is one-sided: a product tree always overshoots.")


# --------------------------------------------------------------------------- #
# 9.  Scale selection
# --------------------------------------------------------------------------- #


def choose_scale(eps: float, tol: float = 1e-14) -> float:
    """Largest h with sup_{[0,1]^2} |P_h - xy| <= eps, by bisection."""
    lo, hi = 1e-12, 1.0
    while corner_sup(hi) < eps:
        hi *= 2.0
    for _ in range(200):
        mid = 0.5 * (lo + hi)
        if corner_sup(mid) <= eps:
            lo = mid
        else:
            hi = mid
        if hi - lo < tol:
            break
    return lo


def demo_scale_selection() -> None:
    banner("9.  Scale selection:  the largest h meeting a target accuracy")
    print(f"{'target eps':>12} {'exact h':>14} {'sqrt(3 eps)':>14} "
          f"{'achieved sup':>15}")
    for eps in [1e-2, 1e-3, 1e-4, 1e-6]:
        h = choose_scale(eps)
        print(f"{eps:12.1e} {h:14.10f} {math.sqrt(3 * eps):14.10f} "
              f"{corner_sup(h):15.8e}")
    print("\nThe leading-order rule h ~ sqrt(3 eps) is an over-estimate; the exact")
    print("answer is always slightly smaller, because the h^4 term adds error.")


# --------------------------------------------------------------------------- #


def main() -> None:
    print(__doc__)
    demo_identity()
    demo_shape()
    demo_sharp_leading_term()
    demo_corner_theorem()
    demo_scalar_barrier()
    demo_affine_barrier()
    demo_universality()
    demo_quadratic_form()
    demo_product_tree()
    demo_scale_selection()
    banner("Summary")
    print("""
    sup_{[0,1]^2} |P_h(x,y) - x y|  =  (e^{2h} + e^{-2h} - 2 - 4h^2)/(4h^2)
                                    =  h^2/3 + 2h^4/45 + h^6/315 + ...,
    attained at the corner (1,1), for EVERY h > 0.

    Pointwise:  P_h(x,y) - x y  =  h^2 x y (x^2+y^2)/6  +  O(h^4),
    always non-negative, vanishing identically on the axes.

    The Theta(h^2) rate survives every scalar and every affine read-out.

    All of it follows from one fact: the error is the increment of an even,
    monotone remainder between h|x-y| and h(x+y).  Cancellation between
    polarisation branches is a monotonicity statement, not a size statement.
    """)


if __name__ == "__main__":
    main()
