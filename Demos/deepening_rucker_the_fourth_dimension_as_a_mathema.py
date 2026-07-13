"""
The Fourth Dimension as a Mathematical Playground -- Numerical Demonstrations.

This self-contained script numerically verifies the five core results:

  1. The volume of the 4-ball is (pi^2 / 2) * r^4.
  2. The tesseract face vector is (16, 32, 24, 8, 1) and the alternating
     face counts give the Euler characteristics of the solid cube (1) and of
     the boundary sphere (1 - (-1)^n).
  3. The Hopf map sends the unit 3-sphere onto the unit 2-sphere and is
     invariant under the unit-scalar circle action (its fibres are circles).
  4. The Clifford torus lies on the unit 3-sphere and splits it symmetrically.
  5. Rotations through the fourth dimension are isometries and compose by
     adding angles.

Run with:  python3 demo.py
Requires only the Python standard library.
"""

from __future__ import annotations

import cmath
import math
import random
from math import comb, cos, gamma, pi, sin, sqrt
from typing import List, Tuple

Complex = complex


# ---------------------------------------------------------------------------
# 1. Volume of the four-dimensional ball
# ---------------------------------------------------------------------------

def unit_ball_volume(n: int) -> float:
    """Volume of the unit ball in R^n via the gamma-function formula."""
    return pi ** (n / 2) / gamma(n / 2 + 1)


def ball_volume(n: int, r: float) -> float:
    """Volume of a radius-r ball in R^n."""
    return unit_ball_volume(n) * r ** n


def volume_4ball_closed_form(r: float) -> float:
    """The claimed closed form for the 4-ball volume: (pi^2 / 2) * r^4."""
    return (pi ** 2 / 2) * r ** 4


def demo_ball_volume() -> None:
    print("=" * 68)
    print("1. VOLUME OF THE 4-BALL:  vol = (pi^2 / 2) * r^4")
    print("=" * 68)
    for r in (1.0, 2.0, 0.5, 3.7):
        v_general = ball_volume(4, r)
        v_closed = volume_4ball_closed_form(r)
        print(f"  r = {r:>4}:  general = {v_general:.10f}   "
              f"closed = {v_closed:.10f}   match = {math.isclose(v_general, v_closed)}")
    print(f"\n  Unit-ball volumes across dimensions (peak at n = 5):")
    for n in range(1, 9):
        marker = "  <-- 4D" if n == 4 else ("  <-- peak" if n == 5 else "")
        print(f"    omega_{n} = {unit_ball_volume(n):.6f}{marker}")
    print()


# ---------------------------------------------------------------------------
# 2. Tesseract combinatorics and Euler characteristics
# ---------------------------------------------------------------------------

def face_count(n: int, k: int) -> int:
    """Number of k-faces of the n-cube:  2^(n-k) * C(n, k)."""
    return 2 ** (n - k) * comb(n, k)


def cube_euler(n: int) -> int:
    """Alternating face count of the solid n-cube (should be 1)."""
    return sum((-1) ** k * face_count(n, k) for k in range(n + 1))


def boundary_euler(n: int) -> int:
    """Alternating face count of the boundary (n-1)-sphere (should be 1-(-1)^n)."""
    return sum((-1) ** k * face_count(n, k) for k in range(n))


def demo_tesseract() -> None:
    print("=" * 68)
    print("2. TESSERACT COMBINATORICS AND EULER CHARACTERISTICS")
    print("=" * 68)
    vector = [face_count(4, k) for k in range(5)]
    labels = ["vertices", "edges", "squares", "cubes", "cell"]
    print("  Tesseract face vector:")
    for lab, v in zip(labels, vector):
        print(f"    {lab:>9}: {v}")
    print(f"  (expected (16, 32, 24, 8, 1); got {tuple(vector)})")
    print("\n  Solid-cube Euler characteristic (should be 1):")
    for n in range(1, 7):
        print(f"    n = {n}: chi(solid) = {cube_euler(n)}")
    print("\n  Boundary-sphere Euler characteristic (should be 1 - (-1)^n):")
    for n in range(1, 7):
        got = boundary_euler(n)
        want = 1 - (-1) ** n
        print(f"    n = {n}: chi(S^{n-1}) = {got:>2}   1-(-1)^n = {want:>2}   "
              f"match = {got == want}")
    print()


# ---------------------------------------------------------------------------
# 3. The Hopf map
# ---------------------------------------------------------------------------

def hopf(z: Complex, w: Complex) -> Tuple[Complex, float]:
    """Hopf map: (z, w) -> (2 z conj(w), |z|^2 - |w|^2)."""
    return (2 * z * w.conjugate(), abs(z) ** 2 - abs(w) ** 2)


def random_point_on_S3() -> Tuple[Complex, float, Complex]:
    """Return a random (z, w) on the unit 3-sphere plus a random unit scalar."""
    z = complex(random.gauss(0, 1), random.gauss(0, 1))
    w = complex(random.gauss(0, 1), random.gauss(0, 1))
    norm = sqrt(abs(z) ** 2 + abs(w) ** 2)
    z, w = z / norm, w / norm
    lam = cmath.exp(1j * random.uniform(0, 2 * pi))  # |lam| = 1
    return z, w, lam


def demo_hopf() -> None:
    print("=" * 68)
    print("3. THE HOPF MAP  S^3 -> S^2")
    print("=" * 68)
    random.seed(4)
    print("  Checking image lands on unit 2-sphere and fibre invariance:")
    for _ in range(4):
        z, w, lam = random_point_on_S3()
        zeta, u = hopf(z, w)
        image_norm = abs(zeta) ** 2 + u ** 2
        # fibre invariance: h(lam z, lam w) == h(z, w)
        zeta2, u2 = hopf(lam * z, lam * w)
        drift = abs(zeta2 - zeta) + abs(u2 - u)
        print(f"    |h(z,w)|^2 = {image_norm:.10f}   fibre drift = {drift:.2e}")
    print()


# ---------------------------------------------------------------------------
# 4. The Clifford torus
# ---------------------------------------------------------------------------

def clifford(s: float, t: float) -> Tuple[float, float, float, float]:
    """Clifford torus point (cos s, sin s, cos t, sin t) / sqrt(2)."""
    c = 1 / sqrt(2)
    return (c * cos(s), c * sin(s), c * cos(t), c * sin(t))


def demo_clifford() -> None:
    print("=" * 68)
    print("4. THE CLIFFORD TORUS INSIDE S^3")
    print("=" * 68)
    random.seed(7)
    print("  Checking every point lies on S^3 and each plane carries 1/2:")
    for _ in range(4):
        s = random.uniform(0, 2 * pi)
        t = random.uniform(0, 2 * pi)
        x1, x2, x3, x4 = clifford(s, t)
        total = x1 ** 2 + x2 ** 2 + x3 ** 2 + x4 ** 2
        plane1 = x1 ** 2 + x2 ** 2
        plane2 = x3 ** 2 + x4 ** 2
        print(f"    total = {total:.10f}   plane1 = {plane1:.6f}   "
              f"plane2 = {plane2:.6f}")
    print()


# ---------------------------------------------------------------------------
# 5. Rotation through the fourth dimension
# ---------------------------------------------------------------------------

def rot4(theta: float, p: Tuple[float, float, float, float]
         ) -> Tuple[float, float, float, float]:
    """Rotate the (axis 1, axis 4) plane by angle theta."""
    a, b, c, d = p
    return (a * cos(theta) - d * sin(theta), b, c, a * sin(theta) + d * cos(theta))


def norm_sq(p: Tuple[float, float, float, float]) -> float:
    return sum(x ** 2 for x in p)


def demo_rotation() -> None:
    print("=" * 68)
    print("5. ROTATION THROUGH THE FOURTH DIMENSION")
    print("=" * 68)
    random.seed(11)
    p = (1.0, 2.0, -0.5, 3.0)
    print(f"  Base point p = {p},  |p|^2 = {norm_sq(p):.6f}")
    for theta in (0.3, 1.2, 2.7):
        q = rot4(theta, p)
        print(f"    theta = {theta}:  |R_theta p|^2 = {norm_sq(q):.10f}  "
              f"(isometry: {math.isclose(norm_sq(q), norm_sq(p))})")
    print("\n  One-parameter group:  R_phi(R_theta(p)) == R_(theta+phi)(p)")
    for _ in range(3):
        theta = random.uniform(0, 2 * pi)
        phi = random.uniform(0, 2 * pi)
        lhs = rot4(phi, rot4(theta, p))
        rhs = rot4(theta + phi, p)
        drift = max(abs(a - b) for a, b in zip(lhs, rhs))
        print(f"    theta = {theta:.3f}, phi = {phi:.3f}:  max drift = {drift:.2e}")
    print()


def main() -> None:
    demo_ball_volume()
    demo_tesseract()
    demo_hopf()
    demo_clifford()
    demo_rotation()
    print("All numerical demonstrations completed.")


if __name__ == "__main__":
    main()
