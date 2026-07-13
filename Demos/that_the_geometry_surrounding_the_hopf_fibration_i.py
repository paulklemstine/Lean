"""
The Fourth Dimension as a Composition-Algebra Playground
========================================================

Self-contained numerical demonstrations of five results about the geometry
surrounding the Hopf fibration, all organised by the composition (normed
division) algebras: the real numbers, complex numbers, quaternions and
octonions.

Each function is inlined and depends only on the Python standard library
(plus `cmath`/`math`). Run `python demo.py` to see every demonstration.
"""

from __future__ import annotations

import cmath
import math
import random
from typing import Sequence, Tuple


# ---------------------------------------------------------------------------
# 1. The Hermitian inner-product witness reconstructs the complex Hopf fibre
# ---------------------------------------------------------------------------

def hopf_witness(a: Tuple[complex, complex], b: Tuple[complex, complex]) -> complex:
    """Hermitian inner-product witness lambda = conj(z) z' + conj(w) w'."""
    (z, w), (z2, w2) = a, b
    return z.conjugate() * z2 + w.conjugate() * w2


def unit_norm_sq(a: Tuple[complex, complex]) -> float:
    """Squared Euclidean norm |z|^2 + |w|^2."""
    z, w = a
    return abs(z) ** 2 + abs(w) ** 2


def random_unit_c2(rng: random.Random) -> Tuple[complex, complex]:
    """A uniformly-ish random unit vector in C^2 (a point of S^3)."""
    z = complex(rng.gauss(0, 1), rng.gauss(0, 1))
    w = complex(rng.gauss(0, 1), rng.gauss(0, 1))
    n = math.sqrt(abs(z) ** 2 + abs(w) ** 2)
    return (z / n, w / n)


def demo_hopf_witness() -> None:
    print("=" * 70)
    print("1. Hermitian witness reconstructs the complex Hopf fibre  (S^3 -> S^2)")
    print("=" * 70)
    rng = random.Random(1)
    a = random_unit_c2(rng)

    # Same fibre: b = mu * a with |mu| = 1.  Witness must recover mu, |mu| = 1.
    mu = cmath.exp(1j * 1.2345)
    b = (mu * a[0], mu * a[1])
    lam = hopf_witness(a, b)
    print(f"  Same fibre:   mu           = {mu:.4f}")
    print(f"                witness lam  = {lam:.4f}   |lam| = {abs(lam):.6f}")
    # Squared-distance identity: ||z'-lam z||^2 + ||w'-lam w||^2 = 1 - |lam|^2
    resid = abs(b[0] - lam * a[0]) ** 2 + abs(b[1] - lam * a[1]) ** 2
    print(f"                residual     = {resid:.2e}  (== 1 - |lam|^2 = "
          f"{1 - abs(lam) ** 2:.2e})")

    # Different fibre: witness strictly inside the unit disc (Cauchy-Schwarz).
    c = random_unit_c2(random.Random(2))
    lam2 = hopf_witness(a, c)
    resid2 = abs(c[0] - lam2 * a[0]) ** 2 + abs(c[1] - lam2 * a[1]) ** 2
    print(f"  Off fibre:    |witness|    = {abs(lam2):.6f}  (< 1)")
    print(f"                residual     = {resid2:.6f}  (== 1 - |lam|^2 = "
          f"{1 - abs(lam2) ** 2:.6f})")
    print()


# ---------------------------------------------------------------------------
# 2. Balanced flat tori maximise volume on odd spheres
# ---------------------------------------------------------------------------

def torus_volume_factor(radii: Sequence[float]) -> float:
    """Volume factor of a flat torus in S^{2m-1}: the product of the radii."""
    prod = 1.0
    for r in radii:
        prod *= r
    return prod


def demo_balanced_torus() -> None:
    print("=" * 70)
    print("2. Balanced flat tori are the unique volume maximisers on S^{2m-1}")
    print("=" * 70)
    for m in (2, 3, 4, 6):
        balanced = [math.sqrt(1.0 / m)] * m
        vol_bal = torus_volume_factor(balanced)
        bound = m ** (-m / 2.0)
        # sample random radius vectors on the constraint sphere sum r_i^2 = 1
        rng = random.Random(7 + m)
        best = 0.0
        for _ in range(200000):
            xs = [abs(rng.gauss(0, 1)) for _ in range(m)]
            s = math.sqrt(sum(x * x for x in xs))
            radii = [x / s for x in xs]
            best = max(best, torus_volume_factor(radii))
        print(f"  m={m}: balanced vol = {vol_bal:.6e}  "
              f"m^(-m/2) = {bound:.6e}  "
              f"random max = {best:.6e}")
    print("  --> the balanced torus attains m^(-m/2) and no sample beats it.")
    print()


# ---------------------------------------------------------------------------
# 3. Multiplication by i: a fixed-point-free isometric complex structure
# ---------------------------------------------------------------------------

def J(v: Sequence[complex]) -> Tuple[complex, ...]:
    """The candidate complex structure J = multiply-by-i on C^n."""
    return tuple(1j * vi for vi in v)


def norm_sq(v: Sequence[complex]) -> float:
    return sum(abs(vi) ** 2 for vi in v)


def demo_almost_complex() -> None:
    print("=" * 70)
    print("3. J = (multiply by i) is a fixed-point-free isometry of S^{2n-1}")
    print("=" * 70)
    rng = random.Random(3)
    n = 4
    v = tuple(complex(rng.gauss(0, 1), rng.gauss(0, 1)) for _ in range(n))
    s = math.sqrt(norm_sq(v))
    v = tuple(vi / s for vi in v)  # put on unit sphere
    jjv = J(J(v))
    err_sq = max(abs(a + b) for a, b in zip(jjv, v))       # J^2 = -1
    err_norm = abs(norm_sq(J(v)) - norm_sq(v))              # isometry
    fixed_gap = math.sqrt(sum(abs(a - b) ** 2 for a, b in zip(J(v), v)))
    print(f"  ||J(J v) + v||_inf = {err_sq:.2e}   (J^2 = -1)")
    print(f"  |N(J v) - N(v)|    = {err_norm:.2e}   (norm preserved, N(v)=1)")
    print(f"  ||J v - v||        = {fixed_gap:.4f}   (> 0: no fixed point)")
    print()


# ---------------------------------------------------------------------------
# 4. The composition-identity ladder: two- and four-square identities
# ---------------------------------------------------------------------------

def two_square_product(a: Tuple[float, float],
                       b: Tuple[float, float]) -> Tuple[float, float]:
    """Brahmagupta-Fibonacci: components of the product of two 2-square sums."""
    a1, a2 = a
    b1, b2 = b
    return (a1 * b1 - a2 * b2, a1 * b2 + a2 * b1)


def four_square_product(a: Tuple[float, float, float, float],
                        b: Tuple[float, float, float, float]
                        ) -> Tuple[float, float, float, float]:
    """Euler's four-square identity (quaternion multiplication)."""
    a1, a2, a3, a4 = a
    b1, b2, b3, b4 = b
    return (
        a1 * b1 - a2 * b2 - a3 * b3 - a4 * b4,
        a1 * b2 + a2 * b1 + a3 * b4 - a4 * b3,
        a1 * b3 - a2 * b4 + a3 * b1 + a4 * b2,
        a1 * b4 + a2 * b3 - a3 * b2 + a4 * b1,
    )


def demo_square_identities() -> None:
    print("=" * 70)
    print("4. The composition-identity ladder: rungs at d = 2 and d = 4")
    print("=" * 70)
    rng = random.Random(5)
    a2 = (rng.uniform(-3, 3), rng.uniform(-3, 3))
    b2 = (rng.uniform(-3, 3), rng.uniform(-3, 3))
    lhs2 = (a2[0] ** 2 + a2[1] ** 2) * (b2[0] ** 2 + b2[1] ** 2)
    c2 = two_square_product(a2, b2)
    rhs2 = c2[0] ** 2 + c2[1] ** 2
    print(f"  two-square : LHS = {lhs2:.4f}  RHS = {rhs2:.4f}  "
          f"diff = {abs(lhs2 - rhs2):.2e}")

    a4 = tuple(rng.uniform(-3, 3) for _ in range(4))
    b4 = tuple(rng.uniform(-3, 3) for _ in range(4))
    lhs4 = sum(x * x for x in a4) * sum(x * x for x in b4)
    c4 = four_square_product(a4, b4)
    rhs4 = sum(x * x for x in c4)
    print(f"  four-square: LHS = {lhs4:.4f}  RHS = {rhs4:.4f}  "
          f"diff = {abs(lhs4 - rhs4):.2e}")
    print("  (No such bilinear identity exists for d = 3, 5, 6, 7.)")
    print()


# ---------------------------------------------------------------------------
# 5. Quaternion conjugation preserves the norm for every nonzero q
# ---------------------------------------------------------------------------

class Quat:
    """Minimal real quaternion a + b i + c j + d k."""

    __slots__ = ("a", "b", "c", "d")

    def __init__(self, a: float, b: float, c: float, d: float) -> None:
        self.a, self.b, self.c, self.d = a, b, c, d

    def __mul__(self, o: "Quat") -> "Quat":
        return Quat(
            self.a * o.a - self.b * o.b - self.c * o.c - self.d * o.d,
            self.a * o.b + self.b * o.a + self.c * o.d - self.d * o.c,
            self.a * o.c - self.b * o.d + self.c * o.a + self.d * o.b,
            self.a * o.d + self.b * o.c - self.c * o.b + self.d * o.a,
        )

    def conj(self) -> "Quat":
        return Quat(self.a, -self.b, -self.c, -self.d)

    def norm_sq(self) -> float:
        return self.a ** 2 + self.b ** 2 + self.c ** 2 + self.d ** 2

    def inv(self) -> "Quat":
        n = self.norm_sq()
        c = self.conj()
        return Quat(c.a / n, c.b / n, c.c / n, c.d / n)


def quat_conjugation(q: Quat, x: Quat) -> Quat:
    """Inner conjugation x |-> q x q^{-1}."""
    return q * x * q.inv()


def demo_quaternion_conjugation() -> None:
    print("=" * 70)
    print("5. Quaternion conjugation x -> q x q^{-1} preserves the norm")
    print("=" * 70)
    rng = random.Random(11)
    for label, scale in (("unit q", 1.0), ("non-unit q", 4.7)):
        q = Quat(*[rng.gauss(0, 1) for _ in range(4)])
        n = math.sqrt(q.norm_sq())
        q = Quat(q.a * scale / n, q.b * scale / n, q.c * scale / n, q.d * scale / n)
        x = Quat(*[rng.gauss(0, 1) for _ in range(4)])
        y = quat_conjugation(q, x)
        print(f"  {label:11s} |q| = {math.sqrt(q.norm_sq()):.3f}  "
              f"N(x) = {x.norm_sq():.4f}  N(qxq^-1) = {y.norm_sq():.4f}  "
              f"diff = {abs(x.norm_sq() - y.norm_sq()):.2e}")
    # multiplicativity: conj(x y) = conj(x) conj(y)
    q = Quat(1.0, 2.0, -1.0, 0.5)
    x = Quat(0.3, -0.7, 1.1, 2.0)
    y = Quat(-1.2, 0.4, 0.9, -0.3)
    lhs = quat_conjugation(q, x * y)
    rhs = quat_conjugation(q, x) * quat_conjugation(q, y)
    diff = math.sqrt((lhs.a - rhs.a) ** 2 + (lhs.b - rhs.b) ** 2
                     + (lhs.c - rhs.c) ** 2 + (lhs.d - rhs.d) ** 2)
    print(f"  multiplicativity  ||conj(xy) - conj(x)conj(y)|| = {diff:.2e}")
    print()


def main() -> None:
    demo_hopf_witness()
    demo_balanced_torus()
    demo_almost_complex()
    demo_square_identities()
    demo_quaternion_conjugation()


if __name__ == "__main__":
    main()
