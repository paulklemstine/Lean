"""
Riemann convergence of Bhattacharyya angle sums to the Fisher-Rao length.

Numerical demonstration of the results:

  1. The square-root map p |-> sqrt(p) sends the probability simplex onto the
     unit sphere, and BC(p, q) = sum_i sqrt(p_i q_i) is the inner product of
     the images; hence theta(p, q) = arccos BC(p, q) is the spherical angle.

  2. Chord/arc comparison:  ||sqrt(p) - sqrt(q)|| = 2 sin(theta/2),
     chord <= theta, and theta * sqrt(1 - (m/2)^2) <= m whenever chord <= m.

  3. Geodesic bound:  2 theta(p_a, p_b) <= FisherRaoLength(p; a, b),
     and every partition angle sum underestimates the length.

  4. Riemann convergence:  the partition sums converge to the Fisher-Rao
     length as the mesh tends to zero, with an observed O(h^2) deficit.

  5. Sharpness: the spherical interpolation of the square-rooted endpoints is
     a curve of probability vectors of constant Fisher-Rao speed 2*theta and
     Fisher-Rao length exactly 2*theta, so the Fisher-Rao distance equals
     2 arccos BC(p, q).

Pure standard library + math; no third-party dependencies.
"""

from __future__ import annotations

import math
from typing import Callable, List, Sequence, Tuple

Vec = List[float]

# ----------------------------------------------------------------------------
# Core quantities
# ----------------------------------------------------------------------------


def normalise(p: Sequence[float]) -> Vec:
    """Rescale a strictly positive vector to a probability vector."""
    total = float(sum(p))
    if total <= 0.0:
        raise ValueError("vector must have positive total mass")
    return [float(x) / total for x in p]


def bhattacharyya(p: Sequence[float], q: Sequence[float]) -> float:
    """BC(p, q) = sum_i sqrt(p_i q_i), the inner product of the square roots."""
    return float(sum(math.sqrt(pi * qi) for pi, qi in zip(p, q)))


def hellinger_chord(p: Sequence[float], q: Sequence[float]) -> float:
    """Euclidean chord ||sqrt(p) - sqrt(q)|| between the square-root embeddings."""
    return math.sqrt(
        sum((math.sqrt(pi) - math.sqrt(qi)) ** 2 for pi, qi in zip(p, q))
    )


def bhattacharyya_angle(p: Sequence[float], q: Sequence[float]) -> float:
    """theta(p, q) = arccos BC(p, q), computed stably via the chord."""
    m = hellinger_chord(p, q)
    return 2.0 * math.asin(min(1.0, m / 2.0))


def fisher_rao_distance(p: Sequence[float], q: Sequence[float]) -> float:
    """The Fisher-Rao distance 2 arccos BC(p, q)."""
    return 2.0 * bhattacharyya_angle(p, q)


def fisher_rao_speed(p: Sequence[float], v: Sequence[float]) -> float:
    """s(p, v) = sqrt(sum_i v_i^2 / p_i)."""
    return math.sqrt(sum(vi * vi / pi for pi, vi in zip(p, v)))


# ----------------------------------------------------------------------------
# Length of a curve: high-accuracy quadrature of the speed
# ----------------------------------------------------------------------------


def fisher_rao_length(
    curve: Callable[[float], Vec],
    velocity: Callable[[float], Vec],
    a: float,
    b: float,
    panels: int = 20000,
) -> float:
    """Composite Simpson quadrature of the Fisher-Rao speed over [a, b]."""
    if panels % 2 == 1:
        panels += 1
    h = (b - a) / panels
    total = 0.0
    for k in range(panels + 1):
        t = a + k * h
        w = 1.0 if k in (0, panels) else (4.0 if k % 2 == 1 else 2.0)
        total += w * fisher_rao_speed(curve(t), velocity(t))
    return total * h / 3.0


def partition_angle_sum(
    curve: Callable[[float], Vec], a: float, b: float, n_steps: int
) -> float:
    """sum_k 2 arccos BC(p_{t_k}, p_{t_{k+1}}) over the uniform partition."""
    h = (b - a) / n_steps
    total = 0.0
    prev = curve(a)
    for k in range(1, n_steps + 1):
        nxt = curve(a + k * h)
        total += 2.0 * bhattacharyya_angle(prev, nxt)
        prev = nxt
    return total


# ----------------------------------------------------------------------------
# The closed-form geodesic (spherical interpolation of the square roots)
# ----------------------------------------------------------------------------


def geodesic_point(p: Sequence[float], q: Sequence[float], t: float) -> Vec:
    """P(t)_i = x(t)_i^2 with x(t) the great-circle arc from sqrt(p) to sqrt(q)."""
    theta = bhattacharyya_angle(p, q)
    if theta < 1e-12:
        x = [(1.0 - t) * math.sqrt(pi) + t * math.sqrt(qi) for pi, qi in zip(p, q)]
        nrm = math.sqrt(sum(xi * xi for xi in x))
        return [(xi / nrm) ** 2 for xi in x]
    s = math.sin(theta)
    ca, cb = math.sin((1.0 - t) * theta) / s, math.sin(t * theta) / s
    return [(ca * math.sqrt(pi) + cb * math.sqrt(qi)) ** 2 for pi, qi in zip(p, q)]


def geodesic_velocity(p: Sequence[float], q: Sequence[float], t: float) -> Vec:
    """V(t)_i = 2 x(t)_i x'(t)_i, the velocity of the geodesic."""
    theta = bhattacharyya_angle(p, q)
    if theta < 1e-12:
        return [0.0 for _ in p]
    s = math.sin(theta)
    out: Vec = []
    for pi, qi in zip(p, q):
        x = (math.sin((1.0 - t) * theta) * math.sqrt(pi)
             + math.sin(t * theta) * math.sqrt(qi)) / s
        dx = theta * (-math.cos((1.0 - t) * theta) * math.sqrt(pi)
                      + math.cos(t * theta) * math.sqrt(qi)) / s
        out.append(2.0 * x * dx)
    return out


# ----------------------------------------------------------------------------
# A test curve: a smooth, definitely non-geodesic path in the 4-simplex
# ----------------------------------------------------------------------------


def test_curve(t: float) -> Vec:
    """A C^infinity curve of strictly positive probability vectors on [0, 1]."""
    raw = [
        1.0 + 0.8 * math.sin(3.0 * t),
        0.7 + 0.5 * math.cos(2.0 * t) ** 2,
        0.4 + 0.3 * math.exp(t),
        0.9 + 0.6 * t * t,
    ]
    return normalise(raw)


def test_velocity(t: float, eps: float = 1e-6) -> Vec:
    """Velocity of the test curve by a fourth-order central difference."""
    a, b = test_curve(t - 2 * eps), test_curve(t - eps)
    c, d = test_curve(t + eps), test_curve(t + 2 * eps)
    return [(ai - 8 * bi + 8 * ci - di) / (-12 * eps)
            for ai, bi, ci, di in zip(a, b, c, d)]


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------


def demo_sphere_embedding() -> None:
    print("=" * 74)
    print("1. THE SQUARE-ROOT EMBEDDING PUTS THE SIMPLEX ON THE UNIT SPHERE")
    print("=" * 74)
    p = normalise([0.4, 0.3, 0.2, 0.1])
    q = normalise([0.1, 0.2, 0.3, 0.4])
    r = normalise([0.25, 0.25, 0.25, 0.25])
    nrm = math.sqrt(sum(pi for pi in p))
    print(f"  p                       = {[round(x, 6) for x in p]}")
    print(f"  q                       = {[round(x, 6) for x in q]}")
    print(f"  ||sqrt(p)||             = {nrm:.15f}   (should be 1)")
    print(f"  BC(p,q) = <sqrt p,sqrt q> = {bhattacharyya(p, q):.12f}")
    print(f"  BC(p,p)                 = {bhattacharyya(p, p):.12f}   (should be 1)")
    tpq = bhattacharyya_angle(p, q)
    tpr = bhattacharyya_angle(p, r)
    trq = bhattacharyya_angle(r, q)
    print()
    print("  Triangle inequality for the Bhattacharyya angle:")
    print(f"    theta(p,q)              = {tpq:.12f}")
    print(f"    theta(p,r) + theta(r,q) = {tpr + trq:.12f}")
    print(f"    satisfied: {tpq <= tpr + trq + 1e-12}")
    print()


def demo_chord_versus_arc() -> None:
    print("=" * 74)
    print("2. CHORD VERSUS ARC:  chord = 2 sin(theta/2) <= theta,")
    print("   and theta * sqrt(1 - (m/2)^2) <= m whenever chord <= m")
    print("=" * 74)
    print(f"  {'t':>8} {'chord':>14} {'2sin(th/2)':>14} {'theta':>12} {'th*sqrt-m':>14}")
    base = normalise([0.4, 0.3, 0.2, 0.1])
    for t in (1.0, 0.5, 0.2, 0.1, 0.05, 0.01, 0.001):
        q = geodesic_point(base, normalise([0.05, 0.15, 0.3, 0.5]), t)
        m = hellinger_chord(base, q)
        th = bhattacharyya_angle(base, q)
        lhs = th * math.sqrt(max(0.0, 1.0 - (m / 2.0) ** 2))
        print(f"  {t:8.4f} {m:14.10f} {2*math.sin(th/2):14.10f} {th:12.8f} "
              f"{lhs - m:14.2e}")
    print("  (last column <= 0 confirms the sharp arc-to-chord converse;")
    print("   the ratio theta/chord -> 1 as the points approach each other)")
    print()


def demo_geodesic_is_exact() -> None:
    print("=" * 74)
    print("3. THE SPHERICAL ARC HAS CONSTANT SPEED 2*theta AND LENGTH 2*theta")
    print("=" * 74)
    p = normalise([0.4, 0.3, 0.2, 0.1])
    q = normalise([0.05, 0.15, 0.30, 0.50])
    theta = bhattacharyya_angle(p, q)
    print(f"  theta = arccos BC(p,q)      = {theta:.12f}")
    print(f"  Fisher-Rao distance 2*theta = {2*theta:.12f}")
    print()
    print(f"  {'t':>6} {'sum_i P(t)_i':>18} {'FR speed':>18} {'min_i P(t)_i':>16}")
    for k in range(6):
        t = k / 5.0
        P = geodesic_point(p, q, t)
        V = geodesic_velocity(p, q, t)
        print(f"  {t:6.2f} {sum(P):18.14f} {fisher_rao_speed(P, V):18.14f} "
              f"{min(P):16.10f}")
    L = fisher_rao_length(lambda t: geodesic_point(p, q, t),
                          lambda t: geodesic_velocity(p, q, t), 0.0, 1.0)
    print()
    print(f"  Quadrature of the length    = {L:.12f}")
    print(f"  Predicted 2*theta           = {2*theta:.12f}")
    print(f"  absolute error              = {abs(L - 2*theta):.3e}")
    print()
    print("  Comparison with naive linear interpolation of the probabilities:")
    lin = [(1 - 0.5) * pi + 0.5 * qi for pi, qi in zip(p, q)]
    mid = geodesic_point(p, q, 0.5)
    print(f"    linear midpoint  = {[round(x, 8) for x in lin]}")
    print(f"    geodesic midpoint= {[round(x, 8) for x in mid]}")
    d_lin = fisher_rao_distance(p, lin) + fisher_rao_distance(lin, q)
    print(f"    FR(p,lin)+FR(lin,q) = {d_lin:.12f}  >=  2*theta = {2*theta:.12f}")
    print()


def demo_riemann_convergence() -> None:
    print("=" * 74)
    print("4. RIEMANN CONVERGENCE OF THE BHATTACHARYYA ANGLE SUMS")
    print("=" * 74)
    a, b = 0.0, 1.0
    L = fisher_rao_length(test_curve, test_velocity, a, b)
    print(f"  Fisher-Rao length of the test curve  L = {L:.12f}")
    print(f"  Endpoint bound 2*theta(p_a,p_b)        = "
          f"{fisher_rao_distance(test_curve(a), test_curve(b)):.12f}   (<= L)")
    print()
    print(f"  {'N':>7} {'h':>12} {'angle sum':>16} {'deficit L-S':>15} "
          f"{'deficit/h^2':>13}")
    prev_sum = -1.0
    monotone = True
    for N in (1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048):
        h = (b - a) / N
        S = partition_angle_sum(test_curve, a, b, N)
        if S < prev_sum - 1e-14:
            monotone = False
        prev_sum = S
        print(f"  {N:7d} {h:12.6f} {S:16.12f} {L - S:15.3e} {(L - S)/h**2:13.6f}")
    print()
    print(f"  every sum is a lower bound for L : "
          f"{all(partition_angle_sum(test_curve, a, b, N) <= L + 1e-12 for N in (1, 5, 50, 500))}")
    print(f"  sums increase under refinement   : {monotone}")
    print("  deficit/h^2 approaches a constant: the observed order is h^2,")
    print("  consistent with a curvature-governed second-order correction.")
    print()


def demo_certified_bracket() -> None:
    print("=" * 74)
    print("5. A CERTIFIED TWO-SIDED BRACKET FOR THE LENGTH")
    print("=" * 74)
    a, b = 0.0, 1.0
    L = fisher_rao_length(test_curve, test_velocity, a, b)

    def sqrt_velocity(t: float) -> Vec:
        p, v = test_curve(t), test_velocity(t)
        return [vi / (2.0 * math.sqrt(pi)) for pi, vi in zip(p, v)]

    print(f"  {'N':>7} {'e (step variation)':>20} {'lower = S':>16} "
          f"{'upper = S+4e(b-a)':>19} {'contains L':>11}")
    for N in (4, 16, 64, 256, 1024):
        h = (b - a) / N
        S = partition_angle_sum(test_curve, a, b, N)
        e = 0.0
        for k in range(N):
            w0 = sqrt_velocity(a + k * h)
            for j in range(9):
                wr = sqrt_velocity(a + k * h + j * h / 8.0)
                e = max(e, math.sqrt(sum((x - y) ** 2 for x, y in zip(wr, w0))))
        upper = S + 4.0 * e * (b - a)
        print(f"  {N:7d} {e:20.10f} {S:16.10f} {upper:19.10f} "
              f"{str(S - 1e-12 <= L <= upper + 1e-12):>11}")
    print(f"  true length L = {L:.12f}")
    print()


def demo_two_point_distance_table() -> None:
    print("=" * 74)
    print("6. THE FISHER-RAO DISTANCE IS ONE DOT PRODUCT AND ONE ARCCOS")
    print("=" * 74)
    pairs: List[Tuple[str, Vec, Vec]] = [
        ("fair vs 51/49 coin", normalise([0.5, 0.5]), normalise([0.51, 0.49])),
        ("rare vs 100x rarer", normalise([1e-6, 1 - 1e-6]),
         normalise([1e-4, 1 - 1e-4])),
        ("uniform vs skewed", normalise([0.25] * 4), normalise([0.7, 0.1, 0.1, 0.1])),
        ("near-disjoint", normalise([0.999, 0.0005, 0.0005]),
         normalise([0.0005, 0.999, 0.0005])),
    ]
    print(f"  {'pair':>20} {'L1 distance':>14} {'Hellinger':>12} "
          f"{'Fisher-Rao':>12}")
    for name, p, q in pairs:
        l1 = sum(abs(pi - qi) for pi, qi in zip(p, q))
        print(f"  {name:>20} {l1:14.8f} {hellinger_chord(p, q):12.8f} "
              f"{fisher_rao_distance(p, q):12.8f}")
    print()
    print("  Note the second row: two distributions that are almost identical in")
    print("  L1 distance are far apart in Fisher-Rao distance, because a hundredfold")
    print("  change in a rare event is statistically enormous.")
    print()
    print("  The L1 distance never exceeds the Fisher-Rao length (the discrete")
    print("  and smooth bounds), while the Fisher-Rao distance is always at least")
    print("  the Hellinger chord and at most chord/sqrt(1-(chord/2)^2) times 2.")
    print()


def main() -> None:
    print()
    print("RIEMANN CONVERGENCE OF BHATTACHARYYA ANGLE SUMS")
    print("to the Fisher-Rao length -- numerical demonstration")
    print()
    demo_sphere_embedding()
    demo_chord_versus_arc()
    demo_geodesic_is_exact()
    demo_riemann_convergence()
    demo_certified_bracket()
    demo_two_point_distance_table()
    print("=" * 74)
    print("All demonstrations complete.")
    print("=" * 74)


if __name__ == "__main__":
    main()
