"""
Fisher-Rao curvature of finite-support statistical models
=========================================================

Numerical companion to the paper
"Test curvature only after identifiability:
 the Levi-Civita connection and Gauss curvature of concrete finite-support models".

Everything below is self-contained (standard library only).  We build one generic
Riemannian engine that, given a 2x2 metric field g(x, y) on an open set of the
plane, produces

    * the Christoffel symbols of the first kind   Gamma_{ij,l} = (d_i g_jl + d_j g_il - d_l g_ij)/2,
    * the Christoffel symbols of the second kind  Gamma^k_{ij} = g^{kl} Gamma_{ij,l},
    * the Riemann tensor                          R^l_{kij} = d_i G^l_{jk} - d_j G^l_{ik}
                                                              + G^l_{im} G^m_{jk} - G^l_{jm} G^m_{ik},
    * the Gauss curvature                         K = (sum_l R^l_{101} g_{l0}) / det(g),

and then runs four models through it:

    1. the open trinomial simplex   p = (x, y, 1-x-y)          ->  K = +1/4
    2. the Poincare half-plane      g = y^{-2}(dx^2 + dy^2)    ->  K = -1   (sign calibration)
    3. the 2x2 independence model   p = (uv, u(1-v), (1-u)v, (1-u)(1-v))  ->  K = 0
    4. the tied two-group model     p = ((1-s)t, (1-s)(1-t), s t^2, s(1-t^2))
                                                                ->  K changes sign

It also demonstrates the two statistical companions:

    * the Fisher metric really is E[s_i s_j] for the score functions s_i = d_i log p;
    * the Hellinger affinity of the n-fold product model is exactly rho^n, so distinct
      parameters separate exponentially fast -- while the curvature stays +1/4.
"""

from __future__ import annotations

import math
from typing import Callable, List, Sequence, Tuple

Metric = Callable[[float, float], List[List[float]]]
Prob = Callable[[float, float], List[float]]

H: float = 1e-5  # finite-difference step


# ----------------------------------------------------------------------------- #
# 1.  Generic Riemannian engine for a 2-dimensional coordinate chart
# ----------------------------------------------------------------------------- #
def partial(f: Callable[[float, float], float], k: int, x: float, y: float,
            h: float = H) -> float:
    """Central-difference partial derivative of f in direction k (0 = x, 1 = y)."""
    if k == 0:
        return (f(x + h, y) - f(x - h, y)) / (2.0 * h)
    return (f(x, y + h) - f(x, y - h)) / (2.0 * h)


def dmetric(g: Metric, k: int, i: int, j: int, x: float, y: float) -> float:
    """The partial derivative d_k g_ij."""
    return partial(lambda a, b: g(a, b)[i][j], k, x, y)


def inverse2(m: Sequence[Sequence[float]]) -> List[List[float]]:
    """Inverse of a 2x2 matrix."""
    det = m[0][0] * m[1][1] - m[0][1] * m[1][0]
    return [[m[1][1] / det, -m[0][1] / det], [-m[1][0] / det, m[0][0] / det]]


def christoffel_first(g: Metric, x: float, y: float) -> List[List[List[float]]]:
    """Gamma_{ij,l} = (d_i g_jl + d_j g_il - d_l g_ij) / 2  (Koszul formula)."""
    return [[[0.5 * (dmetric(g, i, j, l, x, y)
                     + dmetric(g, j, i, l, x, y)
                     - dmetric(g, l, i, j, x, y))
              for l in range(2)] for j in range(2)] for i in range(2)]


def christoffel_second(g: Metric, x: float, y: float) -> List[List[List[float]]]:
    """Gamma^k_{ij} = g^{kl} Gamma_{ij,l}, indexed [k][i][j]."""
    low = christoffel_first(g, x, y)
    ginv = inverse2(g(x, y))
    return [[[sum(ginv[k][l] * low[i][j][l] for l in range(2))
              for j in range(2)] for i in range(2)] for k in range(2)]


def gauss_curvature(g: Metric, x: float, y: float) -> float:
    """Gauss curvature K = <R(d_0, d_1) d_1, d_0> / det(g)."""
    gam = christoffel_second(g, x, y)

    def gamma_at(k: int, i: int, j: int) -> Callable[[float, float], float]:
        return lambda a, b: christoffel_second(g, a, b)[k][i][j]

    total = 0.0
    gm = g(x, y)
    for l in range(2):
        k, i, j = 1, 0, 1
        riem = (partial(gamma_at(l, j, k), i, x, y, h=1e-4)
                - partial(gamma_at(l, i, k), j, x, y, h=1e-4))
        riem += sum(gam[l][i][m] * gam[m][j][k] - gam[l][j][m] * gam[m][i][k]
                    for m in range(2))
        total += riem * gm[l][0]
    return total / (gm[0][0] * gm[1][1] - gm[0][1] * gm[1][0])


# ----------------------------------------------------------------------------- #
# 2.  Fisher information from scores (metric derived, not postulated)
# ----------------------------------------------------------------------------- #
def fisher_metric(p: Prob, x: float, y: float, h: float = H) -> List[List[float]]:
    """g_ij = E[s_i s_j] with s_i = d_i log p, computed by finite differences."""
    px = p(x, y)
    n = len(px)
    scores = [[0.0] * n, [0.0] * n]
    for a in range(n):
        scores[0][a] = (math.log(p(x + h, y)[a]) - math.log(p(x - h, y)[a])) / (2 * h)
        scores[1][a] = (math.log(p(x, y + h)[a]) - math.log(p(x, y - h)[a])) / (2 * h)
    return [[sum(px[a] * scores[i][a] * scores[j][a] for a in range(n))
             for j in range(2)] for i in range(2)]


def amari_tensor(p: Prob, x: float, y: float, h: float = H) -> List[List[List[float]]]:
    """The Amari-Chentsov skewness tensor C_ijk = E[s_i s_j s_k]."""
    px = p(x, y)
    n = len(px)
    scores = [[0.0] * n, [0.0] * n]
    for a in range(n):
        scores[0][a] = (math.log(p(x + h, y)[a]) - math.log(p(x - h, y)[a])) / (2 * h)
        scores[1][a] = (math.log(p(x, y + h)[a]) - math.log(p(x, y - h)[a])) / (2 * h)
    return [[[sum(px[a] * scores[i][a] * scores[j][a] * scores[k][a] for a in range(n))
              for k in range(2)] for j in range(2)] for i in range(2)]


# ----------------------------------------------------------------------------- #
# 3.  The four models
# ----------------------------------------------------------------------------- #
def prob_simplex(x: float, y: float) -> List[float]:
    """Trinomial model p = (x, y, 1-x-y) on a three-point sample space."""
    return [x, y, 1.0 - x - y]


def metric_simplex(x: float, y: float) -> List[List[float]]:
    """Closed-form Fisher metric of the trinomial simplex."""
    z = 1.0 - x - y
    return [[1.0 / x + 1.0 / z, 1.0 / z], [1.0 / z, 1.0 / y + 1.0 / z]]


def metric_hyperbolic(x: float, y: float) -> List[List[float]]:
    """Poincare half-plane metric y^{-2}(dx^2 + dy^2): the negatively curved control."""
    return [[1.0 / y ** 2, 0.0], [0.0, 1.0 / y ** 2]]


def prob_independence(u: float, v: float) -> List[float]:
    """2x2 independence model: two independent Bernoulli coordinates."""
    return [u * v, u * (1 - v), (1 - u) * v, (1 - u) * (1 - v)]


def metric_independence(u: float, v: float) -> List[List[float]]:
    """Fisher metric diag(1/(u-u^2), 1/(v-v^2)): a product of 1-dimensional metrics."""
    return [[1.0 / (u - u ** 2), 0.0], [0.0, 1.0 / (v - v ** 2)]]


def prob_tied(s: float, t: float) -> List[float]:
    """Tied two-group Bernoulli model p = ((1-s)t, (1-s)(1-t), s t^2, s(1-t^2))."""
    return [(1 - s) * t, (1 - s) * (1 - t), s * t ** 2, s * (1 - t ** 2)]


def metric_tied(s: float, t: float) -> List[List[float]]:
    """Fisher metric of the tied model: diag(1/(s-s^2), N/(t-t^3)), N = (1-s)+(1+3s)t."""
    n = (1 - s) + (1 + 3 * s) * t
    return [[1.0 / (s - s ** 2), 0.0], [0.0, n / (t - t ** 3)]]


# ----------------------------------------------------------------------------- #
# 4.  Hellinger affinity and exponential identifiability
# ----------------------------------------------------------------------------- #
def hellinger_affinity(p: Sequence[float], q: Sequence[float]) -> float:
    """rho = sum_a sqrt(p_a q_a); equals 1 - (1/2) sum_a (sqrt p_a - sqrt q_a)^2."""
    return sum(math.sqrt(pa * qa) for pa, qa in zip(p, q))


def product_affinity(p: Sequence[float], q: Sequence[float], n: int) -> float:
    """Affinity of the n-fold i.i.d. product model: exactly rho^n (tensorisation)."""
    return hellinger_affinity(p, q) ** n


def spherical_distance(p: Sequence[float], q: Sequence[float]) -> float:
    """Fisher-Rao geodesic distance = 2 * arccos(rho): a spherical angle on S^2_2."""
    return 2.0 * math.acos(min(1.0, max(-1.0, hellinger_affinity(p, q))))


def alpha_curvature(alpha: float) -> float:
    """Curvature scalar of Amari's alpha-connection on the trinomial simplex."""
    return (1.0 - alpha ** 2) / 4.0


# ----------------------------------------------------------------------------- #
# 5.  Demonstrations
# ----------------------------------------------------------------------------- #
def demo_metric_is_derived() -> None:
    print("=" * 74)
    print("1.  The Fisher metric is DERIVED from the scores, not postulated")
    print("=" * 74)
    for (x, y) in [(0.2, 0.3), (1 / 3, 1 / 3), (0.5, 0.25)]:
        fm = fisher_metric(prob_simplex, x, y)
        cf = metric_simplex(x, y)
        err = max(abs(fm[i][j] - cf[i][j]) for i in range(2) for j in range(2))
        print(f"  (x,y)=({x:.4f},{y:.4f})   E[s_i s_j] vs closed form: max error {err:.2e}")
    print("  closed form:  g = [[1/x + 1/z, 1/z], [1/z, 1/y + 1/z]],  z = 1-x-y\n")

    print("  Mixture-coordinate identity  d_k g_ij = -C_ijk  (C = Amari skewness tensor):")
    x, y = 0.25, 0.35
    c = amari_tensor(prob_simplex, x, y)
    for k in range(2):
        for i in range(2):
            for j in range(2):
                lhs = dmetric(metric_simplex, k, i, j, x, y)
                print(f"    d_{k} g_{i}{j} = {lhs:12.6f}   -C_{i}{j}{k} = {-c[i][j][k]:12.6f}")
    print()


def demo_curvatures() -> None:
    print("=" * 74)
    print("2.  Gauss curvature of four models, one and the same engine")
    print("=" * 74)
    print("  Trinomial simplex   p = (x, y, 1-x-y):        exact value K = +1/4")
    for (x, y) in [(0.2, 0.3), (1 / 3, 1 / 3), (0.6, 0.2), (0.05, 0.05)]:
        print(f"    K({x:.3f},{y:.3f}) = {gauss_curvature(metric_simplex, x, y): .8f}")
    print()
    print("  Poincare half-plane (sign calibration):        exact value K = -1")
    for (x, y) in [(0.0, 1.0), (2.0, 0.5), (-1.0, 3.0)]:
        print(f"    K({x:.3f},{y:.3f}) = {gauss_curvature(metric_hyperbolic, x, y): .8f}")
    print()
    print("  2x2 independence model:                        exact value K = 0")
    for (u, v) in [(0.3, 0.7), (0.5, 0.5), (0.12, 0.88)]:
        print(f"    K({u:.3f},{v:.3f}) = {gauss_curvature(metric_independence, u, v): .8f}")
    print()
    print("  Tied two-group model:  curvature CHANGES SIGN")
    exact_neg = -239 / 3844
    exact_pos = 6209 / 42436
    k1 = gauss_curvature(metric_tied, 0.1, 0.5)
    k2 = gauss_curvature(metric_tied, 0.1, 0.1)
    print(f"    K(0.1,0.5) = {k1: .8f}   exact -239/3844  = {exact_neg: .8f}")
    print(f"    K(0.1,0.1) = {k2: .8f}   exact 6209/42436 = {exact_pos: .8f}")
    print("    => a finite-support model can be negatively curved at one point")
    print("       and positively curved at another: no constant, not even a sign.\n")


def demo_alpha_family() -> None:
    print("=" * 74)
    print("3.  Amari's alpha-connections on the simplex:  K_alpha = (1 - alpha^2)/4")
    print("=" * 74)
    print("   alpha      K_alpha        comment")
    for a in [-2.0, -1.0, -0.5, 0.0, 0.5, 1.0, 2.0]:
        note = ""
        if abs(a) == 1.0:
            note = "dually flat endpoint (m- or e-connection)"
        elif a == 0.0:
            note = "Levi-Civita: the Fisher-Rao curvature +1/4"
        elif abs(a) > 1.0:
            note = "outside the statistically meaningful range"
        print(f"  {a: 6.2f}   {alpha_curvature(a): 10.6f}    {note}")
    print("  K_alpha >= 0 for |alpha| <= 1, and K_alpha < 0 only for |alpha| > 1.\n")


def demo_identifiability() -> None:
    print("=" * 74)
    print("4.  Exponential identifiability coexists with POSITIVE curvature")
    print("=" * 74)
    p = prob_simplex(0.20, 0.30)
    q = prob_simplex(0.35, 0.25)
    rho = hellinger_affinity(p, q)
    print(f"  p = {tuple(round(v, 4) for v in p)},  q = {tuple(round(v, 4) for v in q)}")
    print(f"  Hellinger affinity  rho = {rho:.8f}  (< 1, strictly)")
    print(f"  Fisher-Rao distance = 2 arccos(rho) = {spherical_distance(p, q):.6f}")
    print("  affinity of the n-fold product model (exactly rho^n):")
    for n in [1, 5, 10, 50, 100, 500]:
        print(f"    n = {n:4d}   affinity = {product_affinity(p, q, n):.3e}")
    print("  -> the two hypotheses separate at a geometric rate, yet")
    print(f"     K = {gauss_curvature(metric_simplex, 0.20, 0.30):.6f} > 0 at both points.")
    print("     Exponential sensitivity does NOT imply negative curvature.\n")


def demo_sphere_embedding() -> None:
    print("=" * 74)
    print("5.  Why +1/4: the model is a piece of the round sphere of radius 2")
    print("=" * 74)
    print("  The map  p |-> 2(sqrt p_1, sqrt p_2, sqrt p_3)  sends the open simplex")
    print("  into the Euclidean sphere of radius 2, and pulls the Euclidean metric")
    print("  back to the Fisher metric.  A sphere of radius r has K = 1/r^2 = 1/4.")
    for (x, y) in [(0.2, 0.3), (1 / 3, 1 / 3)]:
        p = prob_simplex(x, y)
        emb = [2 * math.sqrt(v) for v in p]
        nrm = math.sqrt(sum(e ** 2 for e in emb))
        print(f"    (x,y)=({x:.4f},{y:.4f}) -> ({emb[0]:.4f}, {emb[1]:.4f}, {emb[2]:.4f}),"
              f"  norm = {nrm:.8f}")
    p, q = prob_simplex(0.2, 0.3), prob_simplex(0.35, 0.25)
    ep = [2 * math.sqrt(v) for v in p]
    eq = [2 * math.sqrt(v) for v in q]
    inner = sum(a * b for a, b in zip(ep, eq))
    print(f"  <2sqrt p, 2sqrt q>/4 = {inner / 4:.8f}   =   rho = "
          f"{hellinger_affinity(p, q):.8f}")
    print("  So the exponential rate rho is literally the cosine of a spherical angle:")
    print("  a positively curved quantity all along.\n")


def main() -> None:
    demo_metric_is_derived()
    demo_curvatures()
    demo_alpha_family()
    demo_identifiability()
    demo_sphere_embedding()
    print("=" * 74)
    print("Summary:  K(simplex) = +1/4,  K(independence) = 0,  K(tied) changes sign,")
    print("          K(hyperbolic control) = -1,  K_alpha(simplex) = (1-alpha^2)/4.")
    print("=" * 74)


if __name__ == "__main__":
    main()
