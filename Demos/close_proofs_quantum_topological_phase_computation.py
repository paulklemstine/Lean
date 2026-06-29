"""
Numerical demonstrations of the algebraic and number-theoretic kernel of
anyon-braiding universality.

This script mirrors, numerically, the theorems established symbolically:

  * The reduced Burau representation of the 3-strand braid group B3:
      - the braid (Yang-Baxter) relation   B1 B2 B1 = B2 B1 B2
      - determinants                        det B1 = det B2 = -t
      - explicit inverse of B1
      - the scalar central full twist       (B1 B2)^3 = t^3 * I,  trace = 2 t^3
  * The density / order dichotomy on the maximal torus (R / Z):
      - irrational phase  => dense orbit
      - rational phase    => finite order (Fibonacci 4/5 has order 5)
  * The Fibonacci anyon gate set:
      - golden ratio identity              phi^2 = phi + 1
      - F-matrix is a symmetric, traceless, det(-1) involution (F F = I)
      - R-matrix is unitary                R^dagger R = I
      - the Artin relation                 B1 B2 B1 = B2 B1 B2  with B1=R, B2=FRF

Self-contained: standard library + a tiny hand-rolled 2x2 complex-matrix layer
(no external dependencies).
"""

from __future__ import annotations

import cmath
import math
from fractions import Fraction
from typing import List, Tuple

# ---------------------------------------------------------------------------
# Minimal 2x2 complex matrix utilities (no numpy dependency)
# ---------------------------------------------------------------------------

Complex = complex
Mat = Tuple[Tuple[Complex, Complex], Tuple[Complex, Complex]]

I2: Mat = ((1 + 0j, 0 + 0j), (0 + 0j, 1 + 0j))


def mat(a: Complex, b: Complex, c: Complex, d: Complex) -> Mat:
    """Build the 2x2 matrix [[a, b], [c, d]]."""
    return ((a, b), (c, d))


def mul(X: Mat, Y: Mat) -> Mat:
    """Matrix product of two 2x2 matrices."""
    return (
        (X[0][0] * Y[0][0] + X[0][1] * Y[1][0], X[0][0] * Y[0][1] + X[0][1] * Y[1][1]),
        (X[1][0] * Y[0][0] + X[1][1] * Y[1][0], X[1][0] * Y[0][1] + X[1][1] * Y[1][1]),
    )


def matpow(X: Mat, n: int) -> Mat:
    """n-th power of a 2x2 matrix (n >= 0)."""
    result: Mat = I2
    for _ in range(n):
        result = mul(result, X)
    return result


def det(X: Mat) -> Complex:
    """Determinant of a 2x2 matrix."""
    return X[0][0] * X[1][1] - X[0][1] * X[1][0]


def trace(X: Mat) -> Complex:
    """Trace of a 2x2 matrix."""
    return X[0][0] + X[1][1]


def transpose(X: Mat) -> Mat:
    """Transpose of a 2x2 matrix."""
    return ((X[0][0], X[1][0]), (X[0][1], X[1][1]))


def conj_transpose(X: Mat) -> Mat:
    """Hermitian conjugate (conjugate transpose) of a 2x2 matrix."""
    return (
        (X[0][0].conjugate(), X[1][0].conjugate()),
        (X[0][1].conjugate(), X[1][1].conjugate()),
    )


def scalar(s: Complex) -> Mat:
    """The scalar matrix s * I."""
    return ((s, 0 + 0j), (0 + 0j, s))


def approx_eq(X: Mat, Y: Mat, tol: float = 1e-9) -> bool:
    """Entrywise approximate equality of two 2x2 matrices."""
    return all(abs(X[i][j] - Y[i][j]) < tol for i in range(2) for j in range(2))


# ---------------------------------------------------------------------------
# Part I: Reduced Burau representation of B3
# ---------------------------------------------------------------------------

def burau_sigma1(t: Complex) -> Mat:
    """Reduced Burau matrix of sigma_1:  [[-t, 1], [0, 1]]."""
    return mat(-t, 1 + 0j, 0 + 0j, 1 + 0j)


def burau_sigma2(t: Complex) -> Mat:
    """Reduced Burau matrix of sigma_2:  [[1, 0], [t, -t]]."""
    return mat(1 + 0j, 0 + 0j, t, -t)


def burau_sigma1_inv(t: Complex) -> Mat:
    """Explicit inverse of sigma_1 (valid for t != 0): [[-1/t, 1/t], [0, 1]]."""
    return mat(-1 / t, 1 / t, 0 + 0j, 1 + 0j)


def demo_burau(t: Complex) -> None:
    """Demonstrate the Burau-representation theorems at a given t."""
    s1, s2 = burau_sigma1(t), burau_sigma2(t)
    print(f"  t = {t}")

    lhs = mul(mul(s1, s2), s1)
    rhs = mul(mul(s2, s1), s2)
    print(f"    braid relation  s1 s2 s1 == s2 s1 s2 : {approx_eq(lhs, rhs)}")
    print(f"      common value  = {lhs}  (theory: [[0,-t],[-t^2,0]])")

    print(f"    det s1 = {det(s1)}  (theory: -t = {-t}) : {abs(det(s1) + t) < 1e-9}")
    print(f"    det s2 = {det(s2)}  (theory: -t = {-t}) : {abs(det(s2) + t) < 1e-9}")

    if t != 0:
        inv = burau_sigma1_inv(t)
        print(f"    s1 * s1^-1 == I : {approx_eq(mul(s1, inv), I2)}")
        print(f"    s1^-1 * s1 == I : {approx_eq(mul(inv, s1), I2)}")

    twist = matpow(mul(s1, s2), 3)
    print(f"    full twist (s1 s2)^3 == t^3 * I : {approx_eq(twist, scalar(t ** 3))}")
    print(f"      trace = {trace(twist)}  (theory: 2 t^3 = {2 * t ** 3})")


# ---------------------------------------------------------------------------
# Part II: Density / order dichotomy on the torus R / Z
# ---------------------------------------------------------------------------

def is_rational_phase(alpha: float, max_den: int = 10_000, tol: float = 1e-9) -> bool:
    """Heuristically decide whether alpha looks rational (for demo purposes)."""
    frac = Fraction(alpha).limit_denominator(max_den)
    return abs(float(frac) - alpha) < tol


def phase_orbit(alpha: float, steps: int) -> List[float]:
    """The first `steps` points of the orbit { n * alpha mod 1 }."""
    return [(n * alpha) % 1.0 for n in range(steps)]


def orbit_finite_order(alpha_num: int, alpha_den: int) -> int:
    """For a rational phase k/q (q > 0), return its additive order q / gcd(k, q)."""
    g = math.gcd(abs(alpha_num), alpha_den)
    return alpha_den // g


def max_gap(points: List[float]) -> float:
    """Largest gap between consecutive points of a sorted set on the circle."""
    pts = sorted(set(round(p, 12) for p in points))
    if len(pts) < 2:
        return 1.0
    gaps = [pts[i + 1] - pts[i] for i in range(len(pts) - 1)]
    gaps.append(1.0 - pts[-1] + pts[0])  # wrap-around gap
    return max(gaps)


def demo_density() -> None:
    """Demonstrate that irrational phases fill the circle, rational ones do not."""
    print("  Irrational phase alpha = sqrt(2):")
    a = math.sqrt(2)
    for steps in (10, 100, 1000, 10_000):
        gap = max_gap(phase_orbit(a, steps))
        print(f"    steps={steps:6d}  max gap = {gap:.6f}  (-> 0 means dense)")

    print("  Rational Fibonacci phase alpha = 4/5:")
    order = orbit_finite_order(4, 5)
    distinct = len(set(round(p, 12) for p in phase_orbit(4 / 5, 50)))
    print(f"    additive order = {order}  (theory: 5)")
    print(f"    distinct orbit points among 50 steps = {distinct}  (finite => not dense)")


# ---------------------------------------------------------------------------
# Part III: The Fibonacci anyon gate set
# ---------------------------------------------------------------------------

GOLD: float = (1 + math.sqrt(5)) / 2     # golden ratio phi
TAU: float = 1 / GOLD                     # inverse quantum dimension


def fib_F() -> Mat:
    """Fibonacci F-matrix: [[tau, sqrt(tau)], [sqrt(tau), -tau]] (real, as complex)."""
    s = math.sqrt(TAU)
    return mat(TAU + 0j, s + 0j, s + 0j, -TAU + 0j)


def fib_R() -> Mat:
    """Fibonacci R-matrix: diag(exp(-4 pi i / 5), exp(3 pi i / 5))."""
    p1 = -4 * math.pi / 5
    p2 = 3 * math.pi / 5
    return mat(cmath.exp(1j * p1), 0 + 0j, 0 + 0j, cmath.exp(1j * p2))


def demo_fibonacci() -> None:
    """Demonstrate the structural identities of the Fibonacci gates."""
    print(f"  golden ratio phi = {GOLD:.10f}")
    print(f"    phi^2 - (phi + 1) = {GOLD ** 2 - (GOLD + 1):.2e}  (theory: 0)")
    print(f"    tau (tau + 1)     = {TAU * (TAU + 1):.10f}  (theory: 1)")
    print(f"    1 + phi^2 = {1 + GOLD ** 2:.6f},  2 + phi = {2 + GOLD:.6f}")

    F = fib_F()
    print(f"  F-matrix:")
    print(f"    F * F == I        : {approx_eq(mul(F, F), I2)}")
    print(f"    F symmetric       : {approx_eq(transpose(F), F)}")
    print(f"    det F = {det(F).real:+.6f}  (theory: -1)")
    print(f"    trace F = {trace(F).real:+.2e}  (theory: 0)")

    R = fib_R()
    print(f"  R-matrix:")
    print(f"    R^dagger R == I   : {approx_eq(mul(conj_transpose(R), R), I2)}")
    print(f"    |det R| = {abs(det(R)):.6f}  (theory: 1)")

    B1 = R
    B2 = mul(mul(F, R), F)
    lhs = mul(mul(B1, B2), B1)
    rhs = mul(mul(B2, B1), B2)
    print(f"  Artin relation  B1 B2 B1 == B2 B1 B2  (B1=R, B2=FRF): "
          f"{approx_eq(lhs, rhs, tol=1e-8)}")


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 70)
    print("Part I  : Reduced Burau representation of B3")
    print("=" * 70)
    for t in (1 + 0j, 2 + 0j, cmath.exp(2j * math.pi / 5)):
        demo_burau(t)
        print()

    print("=" * 70)
    print("Part II : Density / order dichotomy on the torus R/Z")
    print("=" * 70)
    demo_density()
    print()

    print("=" * 70)
    print("Part III: The Fibonacci anyon gate set")
    print("=" * 70)
    demo_fibonacci()


if __name__ == "__main__":
    main()
