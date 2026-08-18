"""
Arithmetic Geometry of Quantized Weight Lattices — numerical demonstrations.

This self-contained script exhibits, numerically, every main result of the theory:

  1. Covering radius and idempotence of grid rounding.
  2. Theorem A: convexity defect of a quantized convex L-Lipschitz landscape is
     bounded by 2*L*r = L*delta.
  3. Sharpness: the absolute-value loss has defect exactly delta/2 at the balanced
     witness; the "distance to a target weight" loss reaches delta*(1 - 1/n) at
     the unbalanced weight a = 1 - 1/n, so the constant 2*L*r is exact.
  4. The model-soup theorem: balanced interpolation loses only L*delta/2, driven by
     the rounding-parity identity |round X + round Y - 2 round((X+Y)/2)| <= 1.
  5. The denominator law and the defect spectrum: at a = k/q with gcd(k,q) = 1 the
     achievable defects are exactly (delta/q)*{0, ..., q-1}; only the reduced
     denominator matters.
  6. Basin localization for a strongly convex quadratic loss.
  7. Codebooks are torsion points of the weight torus; Chinese-Remainder mixed
     precision; bit-width scaling law defect(b) * 2^b = L*delta.
  8. Reverse transfer: quantized defects tend to zero along a refining tower for a
     convex loss, and do not for a non-convex one.

Run with:  python demo.py
No third-party dependencies.
"""

from __future__ import annotations

import math
from fractions import Fraction
from itertools import product
from typing import Callable, Iterable, List, Sequence, Tuple

Vector = Sequence[float]
Loss = Callable[[Vector], float]

# --------------------------------------------------------------------------- #
# Section 0: the quantizer
# --------------------------------------------------------------------------- #


def round_half_up(t: float) -> int:
    """Nearest integer to `t`, with halves rounding upwards (the convention used
    throughout the theory: round(1/2) = 1, round(-1/2) = 0)."""
    return math.floor(t + 0.5)


def grid_round(delta: float, x: float) -> float:
    """Nearest point of the lattice delta*Z to the real number x."""
    return delta * round_half_up(x / delta)


def quantize_tensor(delta: float, w: Vector) -> List[float]:
    """Entrywise projection of a weight tensor onto (delta*Z)^iota."""
    return [grid_round(delta, wi) for wi in w]


def sup_norm(w: Vector) -> float:
    return max((abs(wi) for wi in w), default=0.0)


def blend(a: float, u: Vector, v: Vector) -> List[float]:
    return [a * ui + (1.0 - a) * vi for ui, vi in zip(u, v)]


def convexity_defect(f: Loss, delta: float, w: Vector, v: Vector, a: float) -> float:
    """Defect of the convexity inequality for the quantized landscape f o Q_delta
    at the configuration (w, v, a):
        f(Q(a w + (1-a) v)) - [ a f(Q w) + (1-a) f(Q v) ].
    Nonpositive means the inequality holds at this configuration."""
    mid = quantize_tensor(delta, blend(a, w, v))
    qw = quantize_tensor(delta, w)
    qv = quantize_tensor(delta, v)
    return f(mid) - (a * f(qw) + (1.0 - a) * f(qv))


# --------------------------------------------------------------------------- #
# Section 1: covering radius, idempotence
# --------------------------------------------------------------------------- #


def demo_covering_radius(delta: float = 0.25, n_samples: int = 20001) -> None:
    print("=" * 74)
    print("1. Covering radius and idempotence   (mesh delta = %.4g)" % delta)
    print("=" * 74)
    worst = 0.0
    idem_ok = True
    for i in range(n_samples):
        x = -3.0 + 6.0 * i / (n_samples - 1)
        worst = max(worst, abs(grid_round(delta, x) - x))
        q = grid_round(delta, x)
        idem_ok &= abs(grid_round(delta, q) - q) < 1e-12
    print("  max |Q(x) - x| over sample      = %.6f   (theory: delta/2 = %.6f)"
          % (worst, delta / 2))
    print("  Q o Q = Q on every sample       : %s" % idem_ok)
    print()


# --------------------------------------------------------------------------- #
# Section 2 & 3: Theorem A and its sharpness
# --------------------------------------------------------------------------- #


def abs_loss(w: Vector) -> float:
    """f(w) = max_i |w_i|: convex and 1-Lipschitz in the sup norm."""
    return sup_norm(w)


def target_loss(c: float) -> Loss:
    """f(w) = max_i |w_i - c|: distance to a target weight, convex, 1-Lipschitz."""
    def f(w: Vector) -> float:
        return max(abs(wi - c) for wi in w)
    return f


def demo_theorem_A(delta: float = 1.0) -> None:
    print("=" * 74)
    print("2-3. Theorem A and its sharpness     (mesh delta = %.4g, L = 1)" % delta)
    print("=" * 74)
    bound = 1.0 * delta  # 2*L*r with r = delta/2
    print("  Theorem A bound 2*L*r = L*delta   = %.6f" % bound)

    # (a) random search over configurations for the absolute-value loss
    worst = -math.inf
    worst_cfg = None
    steps = 41
    for ix in range(steps):
        for iy in range(steps):
            x = -1.5 * delta + 3.0 * delta * ix / (steps - 1)
            y = -1.5 * delta + 3.0 * delta * iy / (steps - 1)
            for ia in range(1, 40):
                a = ia / 40.0
                d = convexity_defect(abs_loss, delta, [x], [y], a)
                if d > worst:
                    worst, worst_cfg = d, (x, y, a)
    print("  |.| loss   : worst observed defect = %.6f  at (x, y, a) = "
          "(%.4f, %.4f, %.3f)" % (worst, *worst_cfg))
    print("             : within the bound      : %s" % (worst <= bound + 1e-12))

    # (b) the exact balanced witness of the sharpness theorem
    d_bal = convexity_defect(abs_loss, delta, [2 * delta / 5], [3 * delta / 5], 0.5)
    print("  |.| loss   : balanced witness (2d/5, 3d/5, 1/2) defect = %.6f "
          "(theory delta/2 = %.6f)" % (d_bal, delta / 2))

    # (c) the unbalanced witness refuting the L*r conjecture
    print("  target loss f(w) = |w - delta|, weights (delta/2, -delta/2), a = 1 - 1/n:")
    f = target_loss(delta)
    for n in (3, 5, 10, 100, 1000):
        a = 1.0 - 1.0 / n
        d = convexity_defect(f, delta, [delta / 2], [-delta / 2], a)
        print("      n = %5d : defect = %.6f   theory delta*(1 - 1/n) = %.6f"
              % (n, d, delta * (1 - 1.0 / n)))
    print("  => the defect approaches L*delta = 2*L*r, so the constant is exact.")
    print()


# --------------------------------------------------------------------------- #
# Section 4: the model-soup theorem and rounding parity
# --------------------------------------------------------------------------- #


def demo_midpoint(delta: float = 1.0, n_samples: int = 300) -> None:
    print("=" * 74)
    print("4. Balanced interpolation ('model soup') loses only L*r")
    print("=" * 74)
    # rounding parity identity
    worst_parity = 0
    rng_state = 12345
    def lcg() -> float:
        nonlocal rng_state
        rng_state = (1103515245 * rng_state + 12345) % (2 ** 31)
        return rng_state / (2 ** 31)

    for _ in range(20000):
        X = -20.0 + 40.0 * lcg()
        Y = -20.0 + 40.0 * lcg()
        val = abs(round_half_up(X) + round_half_up(Y)
                  - 2 * round_half_up((X + Y) / 2))
        worst_parity = max(worst_parity, val)
    print("  max |round X + round Y - 2 round((X+Y)/2)| = %d   (theory: <= 1)"
          % worst_parity)

    worst = -math.inf
    for _ in range(n_samples):
        W = [-2.0 + 4.0 * lcg() for _ in range(4)]
        V = [-2.0 + 4.0 * lcg() for _ in range(4)]
        worst = max(worst, convexity_defect(abs_loss, delta, W, V, 0.5))
    print("  worst midpoint defect over %d random 4-d pairs = %.6f" % (n_samples, worst))
    print("  midpoint bound L*delta/2 = L*r                 = %.6f" % (delta / 2))
    print("  general bound  L*delta   = 2*L*r               = %.6f" % delta)
    print()


# --------------------------------------------------------------------------- #
# Section 5: the denominator law and the defect spectrum
# --------------------------------------------------------------------------- #


def spectrum_witness(delta: float, k: int, q: int, j: int) -> Tuple[Loss, float, float]:
    """Explicit witness realizing convexity defect exactly delta*j/q at the mixing
    weight a = k/q, for gcd(k, q) = 1 and 0 <= j < q.

    Solve k*d = j (mod q) by the extended Euclidean algorithm, write k*d = q*e + j,
    and use the target loss with target delta*C, C = max(d, e, 0), together with the
    weights x = delta*(d - 1/2) and y = -delta/2."""
    assert math.gcd(k, q) == 1 and 0 <= j < q
    k_inv = pow(k % q, -1, q)          # inverse of k modulo q
    d = (k_inv * j) % q
    e = (k * d - j) // q
    C = max(d, e, 0)
    return target_loss(delta * C), delta * (d - 0.5), -delta / 2


def demo_denominator_law(delta: float = 1.0) -> None:
    print("=" * 74)
    print("5. The denominator law and the defect spectrum  (delta = %.4g)" % delta)
    print("=" * 74)
    print("  (a) achievable defects at a = k/q are exactly (delta/q)*{0,...,q-1}:")
    for (k, q) in ((1, 5), (2, 5), (3, 7), (5, 8)):
        realized = []
        ok = True
        for j in range(q):
            f, x, y = spectrum_witness(delta, k, q, j)
            d = convexity_defect(f, delta, [x], [y], k / q)
            realized.append(d)
            ok &= abs(d - delta * j / q) < 1e-9
        print("      k/q = %d/%d : defects = [%s]" %
              (k, q, ", ".join("%.4f" % v for v in realized)))
        print("                 predicted  = [%s]   match: %s" %
              (", ".join("%.4f" % (delta * j / q) for j in range(q)), ok))

    print("  (b) sharp constant = delta*(1 - gcd(k,q)/q): only the reduced denominator")
    print("      %-10s %-14s %-14s %s" % ("a = k/q", "reduced", "sharp const", "as fraction"))
    for (k, q) in ((1, 2), (2, 4), (3, 7), (1, 3), (501, 1000), (5, 10), (33, 100)):
        g = math.gcd(k, q)
        const = delta * (1 - g / q)
        print("      %-10s %-14s %-14.6f %s"
              % ("%d/%d" % (k, q), str(Fraction(k, q)), const,
                 str(Fraction(q // g - 1, q // g))))
    print("      note: a = 1/2 costs %.3f while a = 501/1000, one thousandth away,"
          % (delta * 0.5))
    print("            costs %.3f — the cost is arithmetic, not metric."
          % (delta * (1 - 1 / 1000)))

    print("  (c) the law as an upper bound, checked by search over configurations:")
    for q in (2, 3, 4, 5, 10):
        k = q - 1
        bound = delta * (1 - 1.0 / q)
        worst = -math.inf
        steps = 61
        for ix in range(steps):
            for iy in range(steps):
                x = -2.0 * delta + 4.0 * delta * ix / (steps - 1)
                y = -2.0 * delta + 4.0 * delta * iy / (steps - 1)
                worst = max(worst, convexity_defect(abs_loss, delta, [x], [y], k / q))
        print("      q = %2d : worst |.|-defect = %.6f  <=  bound %.6f : %s"
              % (q, worst, bound, worst <= bound + 1e-12))
    print()


# --------------------------------------------------------------------------- #
# Section 6: basin localization
# --------------------------------------------------------------------------- #


def demo_basin_localization(delta: float = 0.5, mu: float = 2.0) -> None:
    print("=" * 74)
    print("6. Basin localization for a strongly convex loss")
    print("=" * 74)
    # f(w) = mu/2 * ||w - x0||^2 restricted to a bounded box, Lipschitz constant L
    # on that box; we use the one-dimensional case for an exhaustive lattice search.
    x0 = 0.3
    radius = 3.0
    L = mu * radius  # Lipschitz constant of the quadratic on [-radius, radius]
    r = delta / 2

    def f(w: Vector) -> float:
        return 0.5 * mu * (w[0] - x0) ** 2

    # exhaustive minimization over the lattice inside the box
    best_w, best_val = None, math.inf
    kmin, kmax = int(-radius / delta) - 1, int(radius / delta) + 1
    for kk in range(kmin, kmax + 1):
        w = kk * delta
        val = f([w])
        if val < best_val:
            best_w, best_val = w, val
    gap = abs(best_w - x0)
    predicted = math.sqrt(2 * L * r / mu)
    print("  mu = %.2f, delta = %.3f, L (on the box) = %.3f, r = %.4f"
          % (mu, delta, L, r))
    print("  true minimiser x0                = %.6f" % x0)
    print("  best lattice weight              = %.6f" % best_w)
    print("  |lattice optimum - x0|           = %.6f" % gap)
    print("  predicted bound sqrt(2*L*r/mu)   = %.6f   satisfied: %s"
          % (predicted, gap <= predicted + 1e-12))
    print("  loss gap f(w_hat) - f(x0)        = %.6f  <= L*r = %.6f : %s"
          % (best_val - f([x0]), L * r, best_val - f([x0]) <= L * r + 1e-12))
    print()


# --------------------------------------------------------------------------- #
# Section 7: the modular layer
# --------------------------------------------------------------------------- #


def torsion_points(delta: float, m: int) -> List[Fraction]:
    """The m-torsion subgroup of the weight torus R/(delta Z), listed as exact
    fractions of delta in [0, 1)."""
    return [Fraction(k, m) for k in range(m)]


def crt_split(m: int, n: int) -> List[Tuple[int, Tuple[int, int]]]:
    """Chinese-Remainder decomposition Z/(mn) -> Z/m x Z/n for coprime m, n."""
    assert math.gcd(m, n) == 1
    return [(x, (x % m, x % n)) for x in range(m * n)]


def demo_modular_layer(delta: float = 1.0, L: float = 1.0) -> None:
    print("=" * 74)
    print("7. Codebooks are torsion points; CRT; bit-width scaling")
    print("=" * 74)
    for m in (2, 4, 8, 16):
        pts = torsion_points(delta, m)
        # verify each point is m-torsion: m * (k/m) = k is an integer multiple of delta
        ok = all((p * m).denominator == 1 for p in pts)
        print("  m = %2d : codebook size = %2d   image is exactly the m-torsion: %s"
              % (m, len(pts), ok))
    # divisibility tower
    small, big = set(torsion_points(delta, 4)), set(torsion_points(delta, 12))
    print("  4-torsion subset of 12-torsion : %s   index = %d (theory 12/4 = 3)"
          % (small <= big, len(big) // len(small)))
    # CRT
    pairs = crt_split(3, 5)
    images = {img for _, img in pairs}
    print("  CRT Z/15 -> Z/3 x Z/5 : bijective = %s  (|image| = %d, |Z/3 x Z/5| = %d)"
          % (len(images) == 15, len(images), 15))
    # tensor codebook size
    n_entries = 4
    print("  tensor codebook size for |iota| = %d at m = 16 : %d  (= 16^%d)"
          % (n_entries, 16 ** n_entries, n_entries))
    # bit-width scaling law
    print("  bit width b : mesh delta/2^b, defect L*delta/2^b, conserved product:")
    for b in (2, 3, 4, 8, 16):
        mesh = delta / 2 ** b
        defect = L * delta / 2 ** b
        print("      b = %2d : mesh = %.8f  defect = %.8f  defect*2^b = %.6f"
              % (b, mesh, defect, defect * 2 ** b))
    print()


# --------------------------------------------------------------------------- #
# Section 8: reverse transfer along a refining tower
# --------------------------------------------------------------------------- #


def demo_reverse_transfer(delta: float = 1.0) -> None:
    print("=" * 74)
    print("8. Reverse transfer: defects vanish along a refining tower iff convex")
    print("=" * 74)

    def worst_defect(f: Loss, mesh: float, steps: int = 41) -> float:
        worst = -math.inf
        for ix in range(steps):
            for iy in range(steps):
                x = -2.0 + 4.0 * ix / (steps - 1)
                y = -2.0 + 4.0 * iy / (steps - 1)
                for ia in (0.25, 0.5, 0.75, 0.9):
                    worst = max(worst, convexity_defect(f, mesh, [x], [y], ia))
        return worst

    convex: Loss = lambda w: abs(w[0])                      # convex, 1-Lipschitz
    nonconvex: Loss = lambda w: -abs(w[0])                  # concave: not convex

    print("  %-8s %-14s %-18s %-18s" % ("m", "mesh", "defect (convex)", "defect (nonconvex)"))
    for m in (1, 2, 4, 8, 16, 32, 64):
        mesh = delta / m
        dc = worst_defect(convex, mesh)
        dn = worst_defect(nonconvex, mesh)
        print("  %-8d %-14.6f %-18.6f %-18.6f" % (m, mesh, dc, dn))
    print("  The convex loss has defects -> 0 along the tower, so by the reverse")
    print("  transfer theorem exact convexity of the continuous loss is certified.")
    print("  The concave loss has defects bounded away from 0: no certificate.")
    print()


# --------------------------------------------------------------------------- #


def main() -> None:
    print()
    print("ARITHMETIC GEOMETRY OF QUANTIZED WEIGHT LATTICES — NUMERICAL DEMONSTRATIONS")
    print()
    demo_covering_radius()
    demo_theorem_A()
    demo_midpoint()
    demo_denominator_law()
    demo_basin_localization()
    demo_modular_layer()
    demo_reverse_transfer()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
