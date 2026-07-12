"""
The Fourth Dimension as a Mathematical Playground -- Numerical Demonstrations.

This self-contained script verifies, numerically, the central results of the
accompanying paper:

  1. The volume of a 4-ball of radius r equals (pi^2 / 2) * r^4.
  2. The rotation R(x0,x1,x2,x3) = (-x1, x0, -x3, x2) is a fixed-point-free
     isometry of the 3-sphere with R^2 = -I, realized by an SO(4) matrix.
  3. The Hopf map (z,w) -> (2 z conj(w), |z|^2 - |w|^2) sends S^3 onto S^2 and
     is constant along the circle orbits (z,w) -> (lam z, lam w), |lam| = 1.
  4. The Clifford torus C(a,b) lies on S^3 with balanced radii 1/sqrt(2).
  5. The alternating face count of the n-cube is 1, giving boundary Euler
     characteristics 2 (cube surface, S^2) and 0 (tesseract boundary, S^3).

Only the Python standard library is required.
"""

from __future__ import annotations

import cmath
import math
from math import comb, cos, gamma, pi, sin, sqrt
from typing import List, Tuple

Vec4 = Tuple[float, float, float, float]


# ---------------------------------------------------------------------------
# 1. Volume of the four-dimensional ball
# ---------------------------------------------------------------------------

def unit_ball_volume(n: int) -> float:
    """Volume of the unit ball in R^n: pi^(n/2) / Gamma(n/2 + 1)."""
    return pi ** (n / 2) / gamma(n / 2 + 1)


def ball_volume_dim4(r: float) -> float:
    """Closed-form volume of a radius-r ball in R^4: (pi^2 / 2) * r^4."""
    return (pi ** 2 / 2) * r ** 4


def monte_carlo_ball4(r: float, samples: int = 2_000_000, seed: int = 1) -> float:
    """Estimate the 4-ball volume by Monte Carlo over the cube [-r, r]^4."""
    import random

    rng = random.Random(seed)
    inside = 0
    for _ in range(samples):
        x = [rng.uniform(-r, r) for _ in range(4)]
        if sum(c * c for c in x) <= r * r:
            inside += 1
    cube_volume = (2 * r) ** 4
    return cube_volume * inside / samples


# ---------------------------------------------------------------------------
# 2. Fixed-point-free rotation of S^3
# ---------------------------------------------------------------------------

def rot4(x: Vec4) -> Vec4:
    """Rucker's rotation: (x0,x1,x2,x3) -> (-x1, x0, -x3, x2)."""
    x0, x1, x2, x3 = x
    return (-x1, x0, -x3, x2)


def sq_norm(x: Vec4) -> float:
    return sum(c * c for c in x)


def rot4_matrix() -> List[List[float]]:
    """Block-diagonal SO(4) matrix realizing rot4."""
    j = [[0.0, -1.0], [1.0, 0.0]]
    m = [[0.0] * 4 for _ in range(4)]
    for a in range(2):
        for b in range(2):
            m[a][b] = j[a][b]
            m[a + 2][b + 2] = j[a][b]
    return m


def matmul(a: List[List[float]], b: List[List[float]]) -> List[List[float]]:
    n = len(a)
    return [[sum(a[i][k] * b[k][j] for k in range(n)) for j in range(n)] for i in range(n)]


def transpose(a: List[List[float]]) -> List[List[float]]:
    return [list(row) for row in zip(*a)]


def det4(a: List[List[float]]) -> float:
    """Determinant of a 4x4 matrix via cofactor expansion."""
    def minor(m, i, j):
        return [[m[r][c] for c in range(len(m)) if c != j] for r in range(len(m)) if r != i]

    def det(m):
        n = len(m)
        if n == 1:
            return m[0][0]
        if n == 2:
            return m[0][0] * m[1][1] - m[0][1] * m[1][0]
        return sum((-1) ** j * m[0][j] * det(minor(m, 0, j)) for j in range(n))

    return det(a)


# ---------------------------------------------------------------------------
# 3. The Hopf fibration S^3 -> S^2
# ---------------------------------------------------------------------------

def hopf(z: complex, w: complex) -> Tuple[complex, float]:
    """Hopf map (z,w) -> (2 z conj(w), |z|^2 - |w|^2)."""
    return (2 * z * w.conjugate(), abs(z) ** 2 - abs(w) ** 2)


def hopf_image_norm_sq(z: complex, w: complex) -> float:
    c, real = hopf(z, w)
    return abs(c) ** 2 + real ** 2


# ---------------------------------------------------------------------------
# 4. The Clifford torus
# ---------------------------------------------------------------------------

def clifford(a: float, b: float) -> Vec4:
    r = 1 / sqrt(2)
    return (r * cos(a), r * sin(a), r * cos(b), r * sin(b))


# ---------------------------------------------------------------------------
# 5. The tesseract: face counts and Euler characteristics
# ---------------------------------------------------------------------------

def cube_face_counts(n: int) -> List[int]:
    """Number of k-faces of the n-cube, for k = 0..n."""
    return [comb(n, k) * 2 ** (n - k) for k in range(n + 1)]


def alternating_face_sum(n: int) -> int:
    return sum((-1) ** k * comb(n, k) * 2 ** (n - k) for k in range(n + 1))


def boundary_euler_char(n: int) -> int:
    """Euler characteristic of the boundary S^(n-1) of the n-cube: 1 - (-1)^n."""
    return 1 - (-1) ** n


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 66)
    print("The Fourth Dimension as a Mathematical Playground -- demo")
    print("=" * 66)

    print("\n[1] Volume of the 4-ball")
    for r in (1.0, 2.0, 0.5):
        print(f"    r={r}:  closed form = {ball_volume_dim4(r):.6f}, "
              f"pi^2/2 * r^4 check = {(pi**2/2)*r**4:.6f}")
    print(f"    unit-ball volume omega_4 = {unit_ball_volume(4):.6f} "
          f"(pi^2/2 = {pi**2/2:.6f})")
    mc = monte_carlo_ball4(1.0, samples=400_000)
    print(f"    Monte Carlo (r=1) = {mc:.4f}  vs  {ball_volume_dim4(1.0):.4f}")

    print("\n[2] Fixed-point-free rotation of S^3")
    pts = [(1.0, 0.0, 0.0, 0.0), (0.5, 0.5, 0.5, 0.5),
           (cos(0.7), sin(0.7), 0.0, 0.0)]
    for x in pts:
        rx = rot4(x)
        rrx = rot4(rx)
        iso = abs(sq_norm(rx) - sq_norm(x)) < 1e-12
        neg = all(abs(a + b) < 1e-12 for a, b in zip(rrx, x))
        fixed = all(abs(a - b) < 1e-12 for a, b in zip(rx, x))
        print(f"    x={tuple(round(c,3) for c in x)}: isometry={iso}, "
              f"R^2=-I: {neg}, has_fixed_point={fixed}")
    m = rot4_matrix()
    mtm = matmul(transpose(m), m)
    is_id = all(abs(mtm[i][j] - (1.0 if i == j else 0.0)) < 1e-12
                for i in range(4) for j in range(4))
    print(f"    M^T M = I: {is_id},  det M = {det4(m):.6f}  (SO(4))")

    print("\n[3] Hopf fibration S^3 -> S^2")
    for z, w in [(complex(0.6, 0.0), complex(0.8, 0.0)),
                 (complex(0.3, 0.4), complex(0.5, 0.5))]:
        norm = abs(z) ** 2 + abs(w) ** 2
        z, w = z / sqrt(norm), w / sqrt(norm)  # normalize onto S^3
        img = hopf_image_norm_sq(z, w)
        print(f"    |z|^2+|w|^2={abs(z)**2+abs(w)**2:.4f}  =>  "
              f"|h(z,w)|^2 = {img:.6f} (should be 1)")
        # circle invariance
        lam = cmath.exp(1j * 1.3)
        c1, r1 = hopf(z, w)
        c2, r2 = hopf(lam * z, lam * w)
        print(f"      fibre invariance: |dc|={abs(c1-c2):.2e}, "
              f"|dr|={abs(r1-r2):.2e}")

    print("\n[4] Clifford torus on S^3")
    for a, b in [(0.0, 0.0), (0.7, 2.1), (1.5, 4.0)]:
        p = clifford(a, b)
        r1sq = p[0] ** 2 + p[1] ** 2
        r2sq = p[2] ** 2 + p[3] ** 2
        print(f"    C({a},{b}): |.|^2={sq_norm(p):.6f}, "
              f"plane radii^2 = ({r1sq:.4f}, {r2sq:.4f})")

    print("\n[5] Tesseract and Euler characteristics")
    for n in range(1, 6):
        counts = cube_face_counts(n)
        print(f"    n={n}: face counts {counts}, "
              f"alt-sum={alternating_face_sum(n)}, "
              f"boundary chi = {counts_boundary_chi(counts)} "
              f"(= 1-(-1)^n = {boundary_euler_char(n)})")

    print("\nAll numerical checks completed.")


def counts_boundary_chi(counts: List[int]) -> int:
    """Alternating sum of proper faces (drop the top cell)."""
    return sum((-1) ** k * c for k, c in enumerate(counts[:-1]))


if __name__ == "__main__":
    main()
