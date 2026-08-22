"""
Numerical demonstration of the L1 / Fisher-Rao length bounds on the probability
simplex.

The results demonstrated here are:

  (1) Infinitesimal bound.   For a strictly positive probability vector p and any
      tangent vector v,            sum_i |v_i|  <=  sqrt( sum_i v_i^2 / p_i ).

  (2) Length bound (main).   Along a smooth curve t -> p(t) of strictly positive
      probability vectors with velocity v(t),
                     ||p(b) - p(a)||_1  <=  L,      L = int_a^b sqrt(sum_i v_i^2/p_i) dt.

  (3) Total variation form.  dTV(p(a), p(b)) <= L/2, and more strongly no event's
      probability moves by more than L/2.

  (4) Sharpness.  For the two-point family p(t) = ((1+r sin t)/2, (1-r sin t)/2)
      on [0, pi/2]:   ||p(pi/2) - p(0)||_1 = r  exactly, and  L = arcsin(r) exactly.
      Hence the inequality is strict for r in (0,1) but the constant 1 is optimal
      since arcsin(r)/r -> 1 as r -> 0.

  (5) Chord bound.   ||sqrt(p(b)) - sqrt(p(a))||_2 <= L/2  (strictly stronger).

  (6) Quadratic overlap bound.   1 - BC(p(a),p(b)) <= L^2 / 8,
      where BC(p,q) = sum_i sqrt(p_i q_i) is the Bhattacharyya coefficient.

  (7) Pythagorean tensorization.  Squared Fisher-Rao speeds add over independent
      factors.

  (8) Discrete, smoothness-free bound.  For an arbitrary finite path of
      probability vectors,  ||p^(N) - p^(0)||_1 <= sum_k 2 arccos BC(p^(k), p^(k+1)).

Pure standard library: no third-party dependencies.
"""

from __future__ import annotations

import math
from typing import Callable, List, Sequence, Tuple

Vector = List[float]
Curve = Callable[[float], Vector]


# ----------------------------------------------------------------------------
# Core quantities
# ----------------------------------------------------------------------------

def l1_distance(p: Sequence[float], q: Sequence[float]) -> float:
    """L1 distance sum_i |p_i - q_i| (twice the total variation distance)."""
    return sum(abs(pi - qi) for pi, qi in zip(p, q))


def total_variation(p: Sequence[float], q: Sequence[float]) -> float:
    """Total variation distance, i.e. half the L1 distance."""
    return 0.5 * l1_distance(p, q)


def fisher_rao_speed(p: Sequence[float], v: Sequence[float]) -> float:
    """Fisher-Rao norm sqrt(sum_i v_i^2 / p_i) of the tangent vector v at p."""
    if any(pi <= 0.0 for pi in p):
        raise ValueError("Fisher-Rao speed requires a strictly positive point.")
    return math.sqrt(sum(vi * vi / pi for pi, vi in zip(p, v)))


def l1_speed(v: Sequence[float]) -> float:
    """L1 norm sum_i |v_i| of the tangent vector."""
    return sum(abs(vi) for vi in v)


def fisher_rao_length(p: Curve, v: Curve, a: float, b: float, n: int = 200_000) -> float:
    """Fisher-Rao length of the curve on [a, b] by the midpoint rule.

    Error is O(n^-2) for a C^2 integrand; the integrand is smooth as long as the
    curve stays strictly inside the simplex.
    """
    h = (b - a) / n
    total = 0.0
    for k in range(n):
        t = a + (k + 0.5) * h
        total += fisher_rao_speed(p(t), v(t))
    return total * h


def bhattacharyya(p: Sequence[float], q: Sequence[float]) -> float:
    """Bhattacharyya coefficient BC(p,q) = sum_i sqrt(p_i q_i)."""
    return sum(math.sqrt(max(pi, 0.0) * max(qi, 0.0)) for pi, qi in zip(p, q))


def sqrt_chord(p: Sequence[float], q: Sequence[float]) -> float:
    """Euclidean chord ||sqrt(p) - sqrt(q)||_2 of the square-root embedding."""
    return math.sqrt(sum((math.sqrt(pi) - math.sqrt(qi)) ** 2 for pi, qi in zip(p, q)))


def bhattacharyya_angle(p: Sequence[float], q: Sequence[float]) -> float:
    """Spherical distance arccos BC(p,q), computed stably via the chord.

    For nearly coincident distributions arccos loses precision, so we use
    2*arcsin(chord/2), which is well-conditioned there.
    """
    c = sqrt_chord(p, q)
    return 2.0 * math.asin(min(1.0, c / 2.0))


def discrete_length(path: Sequence[Sequence[float]]) -> float:
    """Discrete Fisher-Rao length: sum of 2 * Bhattacharyya angle over steps."""
    return sum(2.0 * bhattacharyya_angle(path[k], path[k + 1]) for k in range(len(path) - 1))


# ----------------------------------------------------------------------------
# Example curves
# ----------------------------------------------------------------------------

def three_point_curve(t: float) -> Vector:
    """A three-outcome curve staying strictly inside the simplex."""
    return [0.5 + 0.2 * math.sin(t), 0.3 - 0.05 * math.sin(t), 0.2 - 0.15 * math.sin(t)]


def three_point_velocity(t: float) -> Vector:
    """Velocity field of `three_point_curve`."""
    return [0.2 * math.cos(t), -0.05 * math.cos(t), -0.15 * math.cos(t)]


def two_point_curve(r: float) -> Curve:
    """The exactly solvable family t -> ((1 + r sin t)/2, (1 - r sin t)/2)."""
    def p(t: float) -> Vector:
        return [(1.0 + r * math.sin(t)) / 2.0, (1.0 - r * math.sin(t)) / 2.0]
    return p


def two_point_velocity(r: float) -> Curve:
    """Velocity field of the two-point family."""
    def v(t: float) -> Vector:
        return [r * math.cos(t) / 2.0, -r * math.cos(t) / 2.0]
    return v


def tensor_point(p: Sequence[float], q: Sequence[float]) -> Vector:
    """Product distribution p (x) q, flattened."""
    return [pi * qj for pi in p for qj in q]


def tensor_velocity(p: Sequence[float], v: Sequence[float],
                    q: Sequence[float], w: Sequence[float]) -> Vector:
    """Velocity of the product curve: v (x) q + p (x) w, flattened."""
    return [vi * qj + pi * wj
            for pi, vi in zip(p, v)
            for qj, wj in zip(q, w)]


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def demo_infinitesimal() -> None:
    print("=" * 74)
    print("(1) INFINITESIMAL BOUND:  sum_i |v_i|  <=  sqrt(sum_i v_i^2 / p_i)")
    print("=" * 74)
    cases: List[Tuple[Vector, Vector]] = [
        ([1 / 3, 1 / 3, 1 / 3], [0.10, -0.04, -0.06]),
        ([0.90, 0.05, 0.05], [0.10, -0.04, -0.06]),
        ([0.98, 0.01, 0.01], [0.00, 0.01, -0.01]),
        ([0.50, 0.50], [0.30, -0.30]),
    ]
    print(f"{'p':<26}{'v':<26}{'L1 speed':>11}{'FR speed':>11}")
    for p, v in cases:
        ps = "[" + ", ".join(f"{x:.2f}" for x in p) + "]"
        vs = "[" + ", ".join(f"{x:+.2f}" for x in v) + "]"
        a, b = l1_speed(v), fisher_rao_speed(p, v)
        assert a <= b + 1e-12
        print(f"{ps:<26}{vs:<26}{a:>11.6f}{b:>11.6f}")
    print("Note how the same v costs far more Fisher-Rao speed near the boundary.\n")


def demo_length_bound() -> None:
    print("=" * 74)
    print("(2,3,5,6) LENGTH BOUND AND ITS REFINEMENTS on a three-outcome curve")
    print("=" * 74)
    intervals = [(0.0, 0.5), (0.0, 1.5), (0.3, 1.2), (0.0, 3.0)]
    header = f"{'[a,b]':<14}{'L1':>10}{'length L':>11}{'chord':>10}{'L/2':>10}{'1-BC':>10}{'L^2/8':>10}"
    print(header)
    for a, b in intervals:
        pa, pb = three_point_curve(a), three_point_curve(b)
        length = fisher_rao_length(three_point_curve, three_point_velocity, a, b, n=40_000)
        l1 = l1_distance(pb, pa)
        chord = sqrt_chord(pb, pa)
        deficit = 1.0 - bhattacharyya(pa, pb)
        assert l1 <= length + 1e-9
        assert chord <= length / 2 + 1e-9
        assert deficit <= length ** 2 / 8 + 1e-9
        print(f"[{a:.1f},{b:.1f}]      {l1:>10.6f}{length:>11.6f}{chord:>10.6f}"
              f"{length / 2:>10.6f}{deficit:>10.6f}{length ** 2 / 8:>10.6f}")
    print("All three inequalities L1 <= L, chord <= L/2, 1-BC <= L^2/8 hold.\n")


def demo_event_bound() -> None:
    print("=" * 74)
    print("(3) NO EVENT MOVES BY MORE THAN L/2")
    print("=" * 74)
    a, b = 0.0, 1.2
    pa, pb = three_point_curve(a), three_point_curve(b)
    length = fisher_rao_length(three_point_curve, three_point_velocity, a, b, n=40_000)
    print(f"Fisher-Rao length L = {length:.6f},  half-length = {length / 2:.6f}")
    subsets = [(0,), (1,), (2,), (0, 1), (0, 2), (1, 2)]
    worst = 0.0
    for S in subsets:
        shift = abs(sum(pb[i] for i in S) - sum(pa[i] for i in S))
        worst = max(worst, shift)
        assert shift <= length / 2 + 1e-9
        print(f"  event {str(set(S)):<10} probability shift = {shift:.6f}")
    print(f"Worst-case shift = {worst:.6f} = total variation distance "
          f"<= {length / 2:.6f}\n")


def demo_sharpness() -> None:
    print("=" * 74)
    print("(4) SHARPNESS: the two-point family has L1 = r and length = arcsin(r)")
    print("=" * 74)
    print(f"{'r':>8}{'L1 (exact)':>14}{'L numeric':>14}{'arcsin r':>14}{'ratio L/L1':>13}")
    for r in (0.001, 0.01, 0.1, 0.3, 0.5, 0.8, 0.9, 0.99):
        p, v = two_point_curve(r), two_point_velocity(r)
        length = fisher_rao_length(p, v, 0.0, math.pi / 2, n=200_000)
        l1 = l1_distance(p(math.pi / 2), p(0.0))
        exact = math.asin(r)
        assert abs(length - exact) < 1e-6 * max(1.0, exact) + 1e-6
        assert l1 < length + 1e-12
        print(f"{r:>8.3f}{l1:>14.8f}{length:>14.8f}{exact:>14.8f}{length / l1:>13.6f}")
    print("The ratio tends to 1 as r -> 0 (constant 1 optimal) and to pi/2 ~ 1.5708")
    print("as r -> 1, while remaining > 1 throughout (the inequality is strict).\n")


def demo_boundary_blowup() -> None:
    print("=" * 74)
    print("STRICT POSITIVITY IS NECESSARY: the length diverges at the boundary")
    print("=" * 74)
    print(f"{'r':>10}{'min prob':>12}{'L = arcsin r':>15}{'L1 = r':>10}")
    for r in (0.9, 0.99, 0.999, 0.999999):
        p = two_point_curve(r)
        print(f"{r:>10.6f}{min(p(math.pi / 2)):>12.3e}{math.asin(r):>15.8f}{r:>10.6f}")
    print("As the endpoint approaches the boundary the L1 displacement saturates at 1,")
    print("but the Fisher-Rao length climbs to pi/2; pushing past the boundary makes")
    print("the integrand v_i^2/p_i non-integrable and the length infinite.\n")


def demo_tensorization() -> None:
    print("=" * 74)
    print("(7) PYTHAGOREAN TENSORIZATION of squared Fisher-Rao speeds")
    print("=" * 74)
    p: Vector = [0.5, 0.3, 0.2]
    v: Vector = [0.10, -0.04, -0.06]
    q: Vector = [0.7, 0.3]
    w: Vector = [-0.15, 0.15]
    joint_p = tensor_point(p, q)
    joint_v = tensor_velocity(p, v, q, w)
    s1 = fisher_rao_speed(p, v)
    s2 = fisher_rao_speed(q, w)
    sj = fisher_rao_speed(joint_p, joint_v)
    print(f"  speed of factor 1        = {s1:.10f}")
    print(f"  speed of factor 2        = {s2:.10f}")
    print(f"  speed of product curve   = {sj:.10f}")
    print(f"  sqrt(s1^2 + s2^2)        = {math.hypot(s1, s2):.10f}")
    assert abs(sj - math.hypot(s1, s2)) < 1e-12
    print("  -> exact Pythagorean identity (cross term vanishes since sum_i v_i = 0).\n")


def demo_discrete() -> None:
    print("=" * 74)
    print("(8) DISCRETE BOUND: no smoothness required")
    print("=" * 74)
    # An arbitrary, deliberately non-smooth path of distributions.
    path: List[Vector] = [
        [0.50, 0.30, 0.20],
        [0.20, 0.55, 0.25],
        [0.60, 0.10, 0.30],
        [0.15, 0.15, 0.70],
        [0.34, 0.33, 0.33],
    ]
    dl = discrete_length(path)
    l1 = l1_distance(path[-1], path[0])
    print("  path of 5 distributions (no continuity, no derivatives)")
    for k, pt in enumerate(path):
        print(f"    p^({k}) = [" + ", ".join(f"{x:.2f}" for x in pt) + "]")
    print(f"  L1 displacement of endpoints            = {l1:.6f}")
    print(f"  sum of 2 * Bhattacharyya angles         = {dl:.6f}")
    assert l1 <= dl + 1e-12
    print("  -> the discrete length bound holds.\n")

    # Refining a smooth curve: the discrete length converges to the true length.
    print("  Refining the three-outcome smooth curve on [0, 1.5]:")
    exact = fisher_rao_length(three_point_curve, three_point_velocity, 0.0, 1.5, n=200_000)
    print(f"{'steps N':>10}{'discrete length':>20}{'true length':>16}")
    for N in (1, 2, 4, 8, 32, 256):
        pts = [three_point_curve(1.5 * k / N) for k in range(N + 1)]
        print(f"{N:>10}{discrete_length(pts):>20.8f}{exact:>16.8f}")
    print("  -> the discrete length increases to the Fisher-Rao length.\n")


def main() -> None:
    print()
    print("#" * 74)
    print("#  L1 DISPLACEMENT vs FISHER-RAO LENGTH ON THE PROBABILITY SIMPLEX")
    print("#" * 74)
    print()
    demo_infinitesimal()
    demo_length_bound()
    demo_event_bound()
    demo_sharpness()
    demo_boundary_blowup()
    demo_tensorization()
    demo_discrete()
    print("All demonstrated inequalities were checked numerically and held.")


if __name__ == "__main__":
    main()
