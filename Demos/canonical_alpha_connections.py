"""
Canonical alpha-connections of finite exponential families: numerical demonstrations.

This script is fully self-contained (standard library only) and verifies, on
explicit finite models, every quantitative claim of the accompanying theory:

  1. The cumulant hierarchy: the first three directional derivatives of the
     log-partition function are the mean, the Fisher variance and the third
     cumulant of the directional score.
  2. The metric derivative law:  d g_ij / d theta^k  =  C_ijk.
  3. Codazzi duality of the alpha-pencil:
     d g_ij / d theta^k = Gamma^{(alpha)}_{ij,k} + Gamma^{(-alpha)}_{ij,k}
     for every alpha, with Gamma^{(alpha)}_{ij,k} = ((1-alpha)/2) C_ijk.
  4. e-flatness at alpha = 1 and the sharp flatness criterion for alpha != 1.
  5. Rigidity: the unique continuous coefficient function satisfying
     F(1) = 0, F(a) + F(-a) = 1 and F(a+b) = F(a)+F(b)-F(0) is (1-a)/2.
  6. Involution collapse: a weight-preserving sign-reversing involution of the
     sample space forces C = 0 at the origin, so the whole pencil is flat.
  7. The skewness law of a binary feature: kappa_3(f,f,f) = p(1-p)(1-2p).
  8. Block diagonality of the Amari-Chentsov tensor under independence.

Run:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
from typing import Callable, List, Sequence, Tuple

Vector = List[float]
Matrix = List[List[float]]
Tensor3 = List[List[List[float]]]


# ---------------------------------------------------------------------------
# Core exponential-family machinery
# ---------------------------------------------------------------------------


def tilted_distribution(
    weights: Sequence[float], features: Sequence[Sequence[float]], theta: Sequence[float]
) -> Vector:
    """Return p_theta(x) = w(x) exp(<theta, T(x)>) / Z(theta).

    Uses the log-sum-exp shift for numerical stability; the shift cancels in the
    normalisation and therefore leaves p_theta, the Fisher metric and the cubic
    tensor exactly invariant.
    """
    scores = [sum(t * tx for t, tx in zip(theta, row)) for row in features]
    shift = max(scores)
    unnorm = [w * math.exp(s - shift) for w, s in zip(weights, scores)]
    total = sum(unnorm)
    return [u / total for u in unnorm]


def log_partition(
    weights: Sequence[float], features: Sequence[Sequence[float]], theta: Sequence[float]
) -> float:
    """psi(theta) = log sum_x w(x) exp(<theta, T(x)>)."""
    scores = [sum(t * tx for t, tx in zip(theta, row)) for row in features]
    shift = max(scores)
    return shift + math.log(sum(w * math.exp(s - shift) for w, s in zip(weights, scores)))


def expectation(p: Sequence[float], f: Sequence[float]) -> float:
    """E_p[f] for an observable given as a vector of its values."""
    return sum(pi * fi for pi, fi in zip(p, f))


def covariance(p: Sequence[float], f: Sequence[float], g: Sequence[float]) -> float:
    """Cov_p(f, g)."""
    return expectation(p, [fi * gi for fi, gi in zip(f, g)]) - expectation(p, f) * expectation(p, g)


def third_cumulant(
    p: Sequence[float], f: Sequence[float], g: Sequence[float], h: Sequence[float]
) -> float:
    """kappa_3(f, g, h) = E[(f - Ef)(g - Eg)(h - Eh)]."""
    ef, eg, eh = expectation(p, f), expectation(p, g), expectation(p, h)
    return sum(
        pi * (fi - ef) * (gi - eg) * (hi - eh) for pi, fi, gi, hi in zip(p, f, g, h)
    )


def fisher_metric(
    weights: Sequence[float], features: Sequence[Sequence[float]], theta: Sequence[float]
) -> Matrix:
    """g_ij(theta) = Cov_{p_theta}(T_i, T_j)."""
    p = tilted_distribution(weights, features, theta)
    d = len(features[0])
    cols = [[row[i] for row in features] for i in range(d)]
    return [[covariance(p, cols[i], cols[j]) for j in range(d)] for i in range(d)]


def amari_chentsov(
    weights: Sequence[float], features: Sequence[Sequence[float]], theta: Sequence[float]
) -> Tensor3:
    """C_ijk(theta) = kappa_3(T_i, T_j, T_k) under p_theta."""
    p = tilted_distribution(weights, features, theta)
    d = len(features[0])
    cols = [[row[i] for row in features] for i in range(d)]
    return [
        [[third_cumulant(p, cols[i], cols[j], cols[k]) for k in range(d)] for j in range(d)]
        for i in range(d)
    ]


def alpha_christoffel(cubic: Tensor3, alpha: float) -> Tensor3:
    """Lower-index natural-coordinate coefficients Gamma^{(alpha)}_{ij,k}."""
    c = (1.0 - alpha) / 2.0
    return [[[c * cubic[i][j][k] for k in range(len(cubic))] for j in range(len(cubic))]
            for i in range(len(cubic))]


def numeric_derivative(f: Callable[[float], float], t: float = 0.0, eps: float = 1e-4) -> float:
    """Central difference approximation to f'(t)."""
    return (f(t + eps) - f(t - eps)) / (2.0 * eps)


def numeric_third_derivative(f: Callable[[float], float], t: float = 0.0, eps: float = 1e-2) -> float:
    """Central difference approximation to f'''(t)."""
    return (f(t + 2 * eps) - 2 * f(t + eps) + 2 * f(t - eps) - f(t - 2 * eps)) / (2 * eps ** 3)


def shifted(theta: Sequence[float], direction: Sequence[float], t: float) -> Vector:
    return [th + t * u for th, u in zip(theta, direction)]


def basis(d: int, k: int) -> Vector:
    return [1.0 if i == k else 0.0 for i in range(d)]


def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


# ---------------------------------------------------------------------------
# Example models
# ---------------------------------------------------------------------------


def rademacher_model() -> Tuple[Vector, List[Vector]]:
    """Symmetric two-point family: S = {0,1}, uniform weights, T(0) = -1, T(1) = +1."""
    return [1.0, 1.0], [[-1.0], [1.0]]


def biased_bernoulli_model(weight_one: float) -> Tuple[Vector, List[Vector]]:
    """Bernoulli family with an indicator feature T(0) = 0, T(1) = 1 and skewed weights."""
    return [1.0, weight_one], [[0.0], [1.0]]


def asymmetric_three_point_model() -> Tuple[Vector, List[Vector]]:
    """A generic two-feature model on three points, with no symmetry at all."""
    weights = [0.7, 1.3, 2.1]
    features = [[-1.0, 0.5], [0.3, -1.7], [2.0, 1.1]]
    return weights, features


def product_model() -> Tuple[Vector, List[Vector]]:
    """Independent product of two binary blocks; features 0,1 in block A, feature 2 in block B."""
    weights: Vector = []
    features: List[Vector] = []
    for a in (0, 1):
        for b in (0, 1):
            # Weight factorises as W1(a) * W2(b); at theta = 0 the model is a product measure.
            weights.append((1.0 + 2.0 * a) * (1.0 + 0.5 * b))
            features.append([float(a), float(a) * float(a) + 0.4 * a, float(b)])
    return weights, features


def odd_spin_model() -> Tuple[Vector, List[Vector]]:
    """Three spins with odd features: the three single spins and the triple product.

    Every feature changes sign under the global spin flip, and the (uniform)
    weights are invariant, so the flip is a weight-preserving sign reversal.
    """
    weights: Vector = []
    features: List[Vector] = []
    for s in itertools.product((-1.0, 1.0), repeat=3):
        weights.append(1.0)
        features.append([s[0], s[1], s[2], s[0] * s[1] * s[2]])
    return weights, features


def even_edge_model() -> Tuple[Vector, List[Vector]]:
    """Three spins on a triangle with the three edge products as features.

    The edge products are *even* under the global spin flip, so no
    sign-reversing involution is available and the cubic tensor need not vanish.
    """
    weights: Vector = []
    features: List[Vector] = []
    for s in itertools.product((-1.0, 1.0), repeat=3):
        weights.append(1.0)
        features.append([s[0] * s[1], s[1] * s[2], s[0] * s[2]])
    return weights, features


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def demo_cumulant_hierarchy() -> None:
    banner("1. The log-partition function is a cumulant generating function")
    weights, features = asymmetric_three_point_model()
    theta = [0.35, -0.2]
    u = [0.8, -0.6]
    p = tilted_distribution(weights, features, theta)
    score = [sum(ui * tx for ui, tx in zip(u, row)) for row in features]

    psi = lambda t: log_partition(weights, features, shifted(theta, u, t))
    d1 = numeric_derivative(psi)
    d2 = numeric_derivative(lambda t: numeric_derivative(psi, t), 0.0, 1e-3)
    d3 = numeric_third_derivative(psi)

    print(f"  first  derivative of psi : {d1:+.10f}   mean of score      : {expectation(p, score):+.10f}")
    print(f"  second derivative of psi : {d2:+.10f}   variance of score  : {covariance(p, score, score):+.10f}")
    print(f"  third  derivative of psi : {d3:+.8f}     third cumulant     : "
          f"{third_cumulant(p, score, score, score):+.8f}")


def demo_metric_derivative_law() -> None:
    banner("2. Metric derivative law:  d g_ij / d theta^k = C_ijk")
    weights, features = asymmetric_three_point_model()
    theta = [0.35, -0.2]
    d = len(features[0])
    cubic = amari_chentsov(weights, features, theta)

    worst = 0.0
    for i, j, k in itertools.product(range(d), repeat=3):
        numeric = numeric_derivative(
            lambda t: fisher_metric(weights, features, shifted(theta, basis(d, k), t))[i][j]
        )
        exact = cubic[i][j][k]
        worst = max(worst, abs(numeric - exact))
        print(f"  (i,j,k) = ({i},{j},{k})   finite difference {numeric:+.9f}   C_ijk {exact:+.9f}")
    print(f"  maximum discrepancy: {worst:.3e}")


def demo_total_symmetry() -> None:
    banner("3. The Amari-Chentsov tensor is totally symmetric")
    weights, features = asymmetric_three_point_model()
    cubic = amari_chentsov(weights, features, [0.35, -0.2])
    d = len(cubic)
    worst = 0.0
    for i, j, k in itertools.product(range(d), repeat=3):
        for perm in itertools.permutations((i, j, k)):
            worst = max(worst, abs(cubic[i][j][k] - cubic[perm[0]][perm[1]][perm[2]]))
    print(f"  maximum deviation over all index permutations: {worst:.3e}")


def demo_codazzi_duality() -> None:
    banner("4. Codazzi duality: d g_ij = Gamma^(alpha) + Gamma^(-alpha), for every alpha")
    weights, features = asymmetric_three_point_model()
    theta = [0.35, -0.2]
    d = len(features[0])
    cubic = amari_chentsov(weights, features, theta)
    i, j, k = 0, 1, 1
    metric_derivative = numeric_derivative(
        lambda t: fisher_metric(weights, features, shifted(theta, basis(d, k), t))[i][j]
    )
    print(f"  component (i,j,k) = ({i},{j},{k});   d g_ij / d theta^k = {metric_derivative:+.9f}")
    print(f"  {'alpha':>8} {'Gamma^(alpha)':>16} {'Gamma^(-alpha)':>16} {'sum':>16}")
    for alpha in (-2.0, -1.0, -0.5, 0.0, 0.5, 1.0, 2.0):
        g_pos = alpha_christoffel(cubic, alpha)[i][j][k]
        g_neg = alpha_christoffel(cubic, -alpha)[i][j][k]
        print(f"  {alpha:8.2f} {g_pos:16.9f} {g_neg:16.9f} {g_pos + g_neg:16.9f}")
    print("  the exponential connection (alpha = 1) contributes nothing;")
    print("  the mixture connection (alpha = -1) carries the entire metric derivative.")


def demo_sharp_flatness() -> None:
    banner("5. Sharp flatness criterion (alpha != 1) and the Levi-Civita midpoint")
    weights, features = asymmetric_three_point_model()
    cubic = amari_chentsov(weights, features, [0.35, -0.2])
    i, j, k = 0, 0, 0
    print(f"  C_000 = {cubic[i][j][k]:+.9f}  (nonzero, so the pencil is nondegenerate)")
    for alpha in (1.0, 0.0, -1.0):
        print(f"  alpha = {alpha:+.1f}:  Gamma = {alpha_christoffel(cubic, alpha)[i][j][k]:+.9f}")
    lc = alpha_christoffel(cubic, 0.0)[i][j][k]
    print(f"  Levi-Civita value equals half the metric derivative: {lc:+.9f} = "
          f"{0.5 * cubic[i][j][k]:+.9f}")
    print("  self-duality Gamma^(alpha) = Gamma^(-alpha) holds only at alpha = 0:")
    for alpha in (0.0, 0.25, 1.0):
        diff = alpha_christoffel(cubic, alpha)[i][j][k] - alpha_christoffel(cubic, -alpha)[i][j][k]
        print(f"    alpha = {alpha:+.2f}:  difference = {diff:+.9f}")


def demo_rigidity() -> None:
    banner("6. Rigidity of the coefficient function alpha -> (1 - alpha)/2")

    def canonical(a: float) -> float:
        return (1.0 - a) / 2.0

    samples = [-3.0, -1.0, -0.4, 0.0, 0.7, 1.0, 2.5]
    print(f"  e-flatness  F(1) = {canonical(1.0):+.6f}")
    print(f"  midpoint    F(0) = {canonical(0.0):+.6f}   (forced by duality alone)")
    print("  duality  F(a) + F(-a) = 1 :")
    for a in samples:
        print(f"    a = {a:+.2f}:  {canonical(a) + canonical(-a):.6f}")
    print("  affine increments  F(a+b) - F(a) - F(b) + F(0) = 0 :")
    for a, b in ((0.3, 1.1), (-2.0, 0.5), (1.4, -1.4)):
        resid = canonical(a + b) - canonical(a) - canonical(b) + canonical(0.0)
        print(f"    (a,b) = ({a:+.2f},{b:+.2f}):  residual {resid:+.3e}")
    print("  a non-affine candidate satisfying only e-flatness and duality:")

    def impostor(a: float) -> float:
        # F(a) = (1 - a^3)/2 is e-flat and dual but violates affine increments.
        return (1.0 - a ** 3) / 2.0

    a, b = 0.7, 1.3
    print(f"    F(a) = (1 - a^3)/2 :  F(1) = {impostor(1.0):+.3f}, "
          f"F(a)+F(-a) = {impostor(a) + impostor(-a):+.3f},"
          f"  affine residual = "
          f"{impostor(a + b) - impostor(a) - impostor(b) + impostor(0.0):+.3f}")
    print("    the nonzero affine residual is exactly what rigidity rules out.")


def demo_involution_collapse() -> None:
    banner("7. Involution collapse: symmetry flattens the entire alpha-pencil")
    for name, (weights, features) in (
        ("symmetric two-point (Rademacher)", rademacher_model()),
        ("three spins, odd features (single spins + triple product)", odd_spin_model()),
    ):
        d = len(features[0])
        theta = [0.0] * d
        g = fisher_metric(weights, features, theta)
        cubic = amari_chentsov(weights, features, theta)
        max_c = max(abs(cubic[i][j][k]) for i, j, k in itertools.product(range(d), repeat=3))
        print(f"  {name}:")
        print(f"    Fisher metric diagonal at the origin: "
              f"{[round(g[i][i], 9) for i in range(d)]}")
        print(f"    max |C_ijk| at the origin           : {max_c:.3e}")
        for alpha in (-1.0, 0.0, 1.0, 3.7):
            gam = alpha_christoffel(cubic, alpha)
            m = max(abs(gam[i][j][k]) for i, j, k in itertools.product(range(d), repeat=3))
            print(f"    alpha = {alpha:+.2f}:  max |Gamma^(alpha)| = {m:.3e}")
    print("  in both models every alpha-connection is flat at the symmetric point.")
    print()
    print("  Contrast: the hypothesis is genuinely needed. With EVEN features the")
    print("  global spin flip is no longer a sign reversal and the tensor survives:")
    weights, features = even_edge_model()
    d = len(features[0])
    cubic = amari_chentsov(weights, features, [0.0] * d)
    max_c = max(abs(cubic[i][j][k]) for i, j, k in itertools.product(range(d), repeat=3))
    print(f"    triangle with edge-product features:  max |C_ijk| = {max_c:.3e}"
          f"   (C_012 = {cubic[0][1][2]:+.3f})")


def demo_binary_skewness_law() -> None:
    banner("8. Skewness law of a binary feature:  kappa_3(f,f,f) = p(1-p)(1-2p)")
    print(f"  {'weight':>8} {'p':>12} {'kappa_3':>16} {'p(1-p)(1-2p)':>16} {'Fisher p(1-p)':>16}")
    for weight_one in (0.2, 0.5, 1.0, 2.0, 9.0):
        weights, features = biased_bernoulli_model(weight_one)
        theta = [0.0]
        p_dist = tilted_distribution(weights, features, theta)
        f = [row[0] for row in features]
        p = expectation(p_dist, f)
        k3 = third_cumulant(p_dist, f, f, f)
        print(f"  {weight_one:8.2f} {p:12.8f} {k3:16.9f} {p * (1 - p) * (1 - 2 * p):16.9f} "
              f"{p * (1 - p):16.9f}")
    print("  the cubic tensor vanishes exactly at the unbiased point p = 1/2,")
    print("  giving the dichotomy: flat  <=>  alpha = 1  or  p = 1/2.")


def demo_independence_block_structure() -> None:
    banner("9. Independence: the Amari-Chentsov tensor is block diagonal")
    weights, features = product_model()
    theta = [0.0, 0.0, 0.0]
    cubic = amari_chentsov(weights, features, theta)
    block_of = {0: "A", 1: "A", 2: "B"}
    mixed_max = 0.0
    print("  index triple    block pattern    C_ijk")
    for i, j, k in itertools.product(range(3), repeat=3):
        pattern = block_of[i] + block_of[j] + block_of[k]
        mixed = len(set(pattern)) > 1
        if mixed:
            mixed_max = max(mixed_max, abs(cubic[i][j][k]))
        if i <= j <= k:
            tag = "mixed" if mixed else "pure "
            print(f"    ({i},{j},{k})          {pattern}  {tag}    {cubic[i][j][k]:+.9f}")
    print(f"  maximum |C_ijk| over mixed triples: {mixed_max:.3e}")
    print("  independence annihilates every mixed third cumulant.")


def demo_alpha_geodesic_interpolation() -> None:
    banner("10. Two ways to walk between two coins: e-geodesic vs m-geodesic")
    p_a, p_b = 0.1, 0.5
    print(f"  endpoints: p = {p_a}, q = {p_b}")
    print(f"  {'t':>6} {'mixture (m-geodesic)':>24} {'exponential (e-geodesic)':>26}")
    for step in range(6):
        t = step / 5.0
        mixture = (1 - t) * p_a + t * p_b
        logit_a = math.log(p_a / (1 - p_a))
        logit_b = math.log(p_b / (1 - p_b))
        z = (1 - t) * logit_a + t * logit_b
        expo = 1.0 / (1.0 + math.exp(-z))
        print(f"  {t:6.2f} {mixture:24.8f} {expo:26.8f}")
    print("  the two straight lines differ; they coincide only when the")
    print("  cubic tensor vanishes along the path (e.g. the symmetric case).")


def main() -> None:
    print("Canonical alpha-connections of finite exponential families")
    print("Numerical demonstrations of the metric derivative law, Codazzi duality,")
    print("coefficient rigidity, and the three combinatorial collapse mechanisms.")
    demo_cumulant_hierarchy()
    demo_metric_derivative_law()
    demo_total_symmetry()
    demo_codazzi_duality()
    demo_sharp_flatness()
    demo_rigidity()
    demo_involution_collapse()
    demo_binary_skewness_law()
    demo_independence_block_structure()
    demo_alpha_geodesic_interpolation()
    print()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
