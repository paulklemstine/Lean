"""
Numerical demonstrations for "A Compact Algebraic Core for Four-Dimensional
Geometry".

This self-contained script verifies, on concrete numbers, the four continuous
results and the discrete companion result:

  1. The canonical complex structure J on R^4 squares to -I, preserves the
     Euclidean norm, and fixes only the origin.
  2. The Hopf map is constant on diagonal circle orbits and lands on the sphere
     of radius |z|^2 + |w|^2 (the sum-of-squares core identity).
  3. The Clifford torus balance: on r1^2 + r2^2 = 1, the product 4 r1^2 r2^2 is
     maximized uniquely at the balanced torus r1^2 = r2^2 = 1/2.
  4. The four-ball volume V(r) = (pi^2/2) r^4 has derivative 2 pi^2 r^3, the
     surface measure of the bounding three-sphere.
  5. The alternating face sum of the n-cube equals 1, giving boundary Euler
     characteristic 1 - (-1)^n.

Everything is inlined; no third-party dependencies are required.
"""

from __future__ import annotations

import cmath
import math
from math import comb, cos, sin, pi
from typing import Tuple

Vec4 = Tuple[float, float, float, float]


# --------------------------------------------------------------------------- #
# 1. The canonical complex structure J on R^4
# --------------------------------------------------------------------------- #
def J4(x: Vec4) -> Vec4:
    """Quarter-turn in each coordinate plane: (x1,x2,x3,x4) -> (-x2,x1,-x4,x3)."""
    x1, x2, x3, x4 = x
    return (-x2, x1, -x4, x3)


def norm_sq4(x: Vec4) -> float:
    """Squared Euclidean norm on R^4."""
    return sum(c * c for c in x)


def demo_complex_structure() -> None:
    print("=== 1. Canonical complex structure J on R^4 ===")
    x: Vec4 = (0.3, -1.2, 2.5, 0.7)
    jjx = J4(J4(x))
    neg_x = tuple(-c for c in x)
    print(f"  x            = {x}")
    print(f"  J(J(x))      = {jjx}")
    print(f"  -x           = {neg_x}")
    print(f"  J^2 == -I ?  {all(abs(a - b) < 1e-12 for a, b in zip(jjx, neg_x))}")
    print(f"  |J(x)|^2 = {norm_sq4(J4(x)):.6f}, |x|^2 = {norm_sq4(x):.6f} "
          f"(preserved: {abs(norm_sq4(J4(x)) - norm_sq4(x)) < 1e-12})")
    # Fixed-point freeness: J(x)=x only for x=0.
    fixed = all(abs(a - b) < 1e-12 for a, b in zip(J4(x), x))
    print(f"  J(x) == x for this nonzero x ? {fixed} (expected False)")
    print()


# --------------------------------------------------------------------------- #
# 2. The Hopf map
# --------------------------------------------------------------------------- #
def hopf(z: complex, w: complex) -> Tuple[complex, float]:
    """Hopf map C^2 -> C x R,  (z,w) |-> (2 z conj(w), |z|^2 - |w|^2)."""
    return (2 * z * w.conjugate(), abs(z) ** 2 - abs(w) ** 2)


def demo_hopf() -> None:
    print("=== 2. Hopf map: circle invariance and image sphere ===")
    z, w = complex(0.6, 0.2), complex(-0.3, 0.7)
    img = hopf(z, w)
    # Circle invariance under unit-modulus lambda.
    lam = cmath.exp(1j * 1.234)  # |lam| = 1
    img_rot = hopf(lam * z, lam * w)
    inv = (abs(img[0] - img_rot[0]) < 1e-12 and abs(img[1] - img_rot[1]) < 1e-12)
    print(f"  H(z,w)          = ({img[0]:.4f}, {img[1]:.4f})")
    print(f"  H(lam z, lam w) = ({img_rot[0]:.4f}, {img_rot[1]:.4f})")
    print(f"  circle-invariant ? {inv}")
    # Image-sphere identity  |2 z conj(w)|^2 + (|z|^2-|w|^2)^2 = (|z|^2+|w|^2)^2.
    lhs = abs(img[0]) ** 2 + img[1] ** 2
    rhs = (abs(z) ** 2 + abs(w) ** 2) ** 2
    print(f"  |first|^2 + second^2 = {lhs:.6f}")
    print(f"  (|z|^2 + |w|^2)^2    = {rhs:.6f}")
    print(f"  sum-of-squares core holds ? {abs(lhs - rhs) < 1e-12}")
    print()


# --------------------------------------------------------------------------- #
# 3. The Clifford torus balance
# --------------------------------------------------------------------------- #
def clifford_product(a: float) -> float:
    """4 a b with b = 1 - a; equals 1 - (a-b)^2 on the constraint a+b=1."""
    b = 1.0 - a
    return 4 * a * b


def demo_clifford() -> None:
    print("=== 3. Clifford torus balance (maximize 4 r1^2 r2^2, r1^2+r2^2=1) ===")
    best_a, best_val = 0.0, -1.0
    for i in range(1, 1000):
        a = i / 1000.0
        val = clifford_product(a)
        if val > best_val:
            best_val, best_a = val, a
    print(f"  numerical argmax a = r1^2 : {best_a:.3f}  (exact: 0.500)")
    print(f"  numerical max 4ab         : {best_val:.6f} (exact: 1.0)")
    a = 0.5
    print(f"  identity check at a=1/2: 4ab = {clifford_product(a):.6f}, "
          f"1-(a-(1-a))^2 = {1 - (a - (1 - a)) ** 2:.6f}")
    print()


# --------------------------------------------------------------------------- #
# 4. Volume of the four-ball and surface of the three-sphere
# --------------------------------------------------------------------------- #
def ball4_volume(r: float) -> float:
    """Volume of the four-ball of radius r."""
    return (pi ** 2 / 2) * r ** 4


def sphere3_surface(r: float) -> float:
    """Surface measure of the three-sphere of radius r."""
    return 2 * pi ** 2 * r ** 3


def demo_volume_surface() -> None:
    print("=== 4. Four-ball volume derivative equals three-sphere surface ===")
    r, h = 1.7, 1e-6
    numerical_deriv = (ball4_volume(r + h) - ball4_volume(r - h)) / (2 * h)
    analytic = sphere3_surface(r)
    print(f"  V(r) = (pi^2/2) r^4        at r={r}: {ball4_volume(r):.6f}")
    print(f"  numerical V'(r)            : {numerical_deriv:.6f}")
    print(f"  surface 2 pi^2 r^3         : {analytic:.6f}")
    print(f"  match ? {abs(numerical_deriv - analytic) < 1e-4}")
    print()


# --------------------------------------------------------------------------- #
# 5. Alternating face sum of the n-cube
# --------------------------------------------------------------------------- #
def cube_alternating_face_sum(n: int) -> int:
    """sum_k (-1)^k C(n,k) 2^(n-k)  =  (2-1)^n  =  1."""
    return sum((-1) ** k * comb(n, k) * 2 ** (n - k) for k in range(n + 1))


def cube_boundary_euler(n: int) -> int:
    """Euler characteristic of the boundary (n-1)-sphere: 1 - (-1)^n."""
    return cube_alternating_face_sum(n) - (-1) ** n


def demo_cube() -> None:
    print("=== 5. Hypercube alternating face sum and boundary Euler char. ===")
    for n in range(1, 7):
        total = cube_alternating_face_sum(n)
        chi = cube_boundary_euler(n)
        print(f"  n={n}: total face sum = {total}, "
              f"boundary chi = {chi} (expected {1 - (-1) ** n})")
    print()


def main() -> None:
    demo_complex_structure()
    demo_hopf()
    demo_clifford()
    demo_volume_surface()
    demo_cube()


if __name__ == "__main__":
    main()
