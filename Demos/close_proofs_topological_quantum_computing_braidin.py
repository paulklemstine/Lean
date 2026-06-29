"""
demo.py — Numerical demonstrations of the braiding-universality kernel.

This script reproduces, with plain Python (only the standard library), every
computational claim in the accompanying article and research paper for the
three-strand braid group B3 and its reduced Burau representation:

  * The Yang-Baxter / braid relation  B1 B2 B1 = B2 B1 B2  (for all t).
  * Determinants  det B1 = det B2 = -t.
  * The explicit two-sided inverse of B1.
  * The full twist  (B1 B2)^3 = t^3 * I,  with trace  2 t^3.
  * The sharp torus dichotomy:  the orbit  { n*alpha mod 1 }  is dense iff
    alpha is irrational; rational alpha = p/q has finite order q.
  * The Fibonacci  4/5  obstruction (order dividing 5, non-dense).
  * The irrational  sqrt(2)  phase (dense orbit).

Run:  python3 demo.py
"""

from __future__ import annotations

import cmath
import math
from fractions import Fraction
from typing import List, Tuple

Complex = complex
Matrix2 = Tuple[Tuple[Complex, Complex], Tuple[Complex, Complex]]


# --------------------------------------------------------------------------
# 2x2 complex matrix utilities
# --------------------------------------------------------------------------
def mat(a: Complex, b: Complex, c: Complex, d: Complex) -> Matrix2:
    """Build the 2x2 matrix [[a, b], [c, d]]."""
    return ((a, b), (c, d))


def mat_mul(M: Matrix2, N: Matrix2) -> Matrix2:
    """Multiply two 2x2 matrices."""
    return (
        (M[0][0] * N[0][0] + M[0][1] * N[1][0], M[0][0] * N[0][1] + M[0][1] * N[1][1]),
        (M[1][0] * N[0][0] + M[1][1] * N[1][0], M[1][0] * N[0][1] + M[1][1] * N[1][1]),
    )


def mat_pow(M: Matrix2, n: int) -> Matrix2:
    """Raise a 2x2 matrix to a non-negative integer power."""
    result: Matrix2 = mat(1, 0, 0, 1)
    for _ in range(n):
        result = mat_mul(result, M)
    return result


def det(M: Matrix2) -> Complex:
    """Determinant of a 2x2 matrix."""
    return M[0][0] * M[1][1] - M[0][1] * M[1][0]


def trace(M: Matrix2) -> Complex:
    """Trace (sum of diagonal) of a 2x2 matrix."""
    return M[0][0] + M[1][1]


def approx_eq(M: Matrix2, N: Matrix2, tol: float = 1e-9) -> bool:
    """Entrywise approximate equality of two 2x2 matrices."""
    return all(
        abs(M[i][j] - N[i][j]) < tol for i in range(2) for j in range(2)
    )


# --------------------------------------------------------------------------
# Reduced Burau representation of B3
# --------------------------------------------------------------------------
def burau_sigma1(t: Complex) -> Matrix2:
    """Reduced Burau matrix of sigma_1:  [[-t, 1], [0, 1]]."""
    return mat(-t, 1, 0, 1)


def burau_sigma2(t: Complex) -> Matrix2:
    """Reduced Burau matrix of sigma_2:  [[1, 0], [t, -t]]."""
    return mat(1, 0, t, -t)


def burau_sigma1_inv(t: Complex) -> Matrix2:
    """Explicit inverse of sigma_1 (valid for t != 0): [[-1/t, 1/t], [0, 1]]."""
    return mat(-1 / t, 1 / t, 0, 1)


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------
def demo_braid_relation(ts: List[Complex]) -> None:
    """Verify B1 B2 B1 = B2 B1 B2 over several t (Theorem: braid relation)."""
    print("=== Yang-Baxter / braid relation:  B1 B2 B1 = B2 B1 B2 ===")
    for t in ts:
        B1, B2 = burau_sigma1(t), burau_sigma2(t)
        lhs = mat_mul(mat_mul(B1, B2), B1)
        rhs = mat_mul(mat_mul(B2, B1), B2)
        ok = approx_eq(lhs, rhs)
        print(f"  t = {t!s:>12}:  holds = {ok};  both sides = {lhs}")
    print()


def demo_determinants(ts: List[Complex]) -> None:
    """Verify det B1 = det B2 = -t."""
    print("=== Determinants:  det B1 = det B2 = -t ===")
    for t in ts:
        d1, d2 = det(burau_sigma1(t)), det(burau_sigma2(t))
        print(f"  t = {t!s:>12}:  det B1 = {d1},  det B2 = {d2},  -t = {-t}")
    print()


def demo_inverse(ts: List[Complex]) -> None:
    """Verify the explicit two-sided inverse of B1 (Theorem 3.3)."""
    print("=== Explicit two-sided inverse of sigma_1 ===")
    I = mat(1, 0, 0, 1)
    for t in ts:
        if t == 0:
            continue
        B1, B1i = burau_sigma1(t), burau_sigma1_inv(t)
        left = approx_eq(mat_mul(B1, B1i), I)
        right = approx_eq(mat_mul(B1i, B1), I)
        print(f"  t = {t!s:>12}:  B1 B1^-1 = I: {left};  B1^-1 B1 = I: {right}")
    print()


def demo_full_twist(ts: List[Complex]) -> None:
    """Verify (B1 B2)^3 = t^3 I  and  trace = 2 t^3 (Theorems 3.5-3.7)."""
    print("=== Full twist:  (B1 B2)^3 = t^3 * I,  trace = 2 t^3 ===")
    for t in ts:
        B1, B2 = burau_sigma1(t), burau_sigma2(t)
        FT = mat_pow(mat_mul(B1, B2), 3)
        scalar = mat(t ** 3, 0, 0, t ** 3)
        ok = approx_eq(FT, scalar)
        tr = trace(FT)
        print(
            f"  t = {t!s:>12}:  = t^3 I: {ok};  trace = {tr};  2 t^3 = {2 * t ** 3}"
        )
    print()


def orbit(alpha: float, n: int) -> List[float]:
    """The phase-gate orbit  { k*alpha mod 1 : k = 0..n-1 }."""
    return [(k * alpha) % 1.0 for k in range(n)]


def discrepancy(points: List[float], bins: int = 20) -> float:
    """A crude equidistribution measure: max bin deviation from uniform."""
    counts = [0] * bins
    for p in points:
        counts[min(int(p * bins), bins - 1)] += 1
    expected = len(points) / bins
    return max(abs(c - expected) for c in counts) / len(points)


def demo_density_dichotomy() -> None:
    """Density dichotomy: irrational => dense, rational => finite/non-dense."""
    print("=== Density / order dichotomy on the torus R/Z ===")
    n = 5000

    # Irrational phase sqrt(2): orbit equidistributes (discrepancy -> 0).
    a_irr = math.sqrt(2)
    pts = orbit(a_irr, n)
    distinct = len(set(round(p, 9) for p in pts))
    print(
        f"  alpha = sqrt(2) (irrational): {distinct} distinct points / {n}, "
        f"discrepancy = {discrepancy(pts):.4f}  -> dense, infinite order"
    )

    # Rational phase 4/5 (Fibonacci): only 5 distinct points, order 5.
    a_fib = 4 / 5
    pts = orbit(a_fib, n)
    distinct = len(set(round(p, 9) for p in pts))
    print(
        f"  alpha = 4/5 (Fibonacci, rational): {distinct} distinct points / {n} "
        f"-> NOT dense; finite order"
    )
    print()


def phase_order(alpha: Fraction) -> int:
    """Order of a rational phase gate p/q in lowest terms: the denominator q."""
    return alpha.denominator


def demo_orders() -> None:
    """Finite-order computation for rational phases (Theorem 4.3)."""
    print("=== Orders of rational phase gates (order = denominator) ===")
    for frac in [Fraction(4, 5), Fraction(1, 2), Fraction(2, 3), Fraction(3, 8)]:
        print(f"  alpha = {frac}:  order = {phase_order(frac)}")
    print("  (4/5 -> order 5: the sharp Fibonacci obstruction)")
    print()


def fibonacci_r_phase() -> None:
    """Show the Fibonacci R-matrix eigenphase as exp(2*pi*i*4/5)."""
    print("=== Fibonacci R-matrix eigenphase  exp(2*pi*i*4/5) ===")
    z = cmath.exp(2j * math.pi * 4 / 5)
    print(f"  exp(2*pi*i*4/5) = {z:.6f},  |.| = {abs(z):.6f}")
    print(f"  z^5 = {z ** 5:.6f}  (returns to 1: order 5)")
    print()


def main() -> None:
    sample_t = [1 + 0j, 2 + 0j, 1j, 0.5 + 0.5j, -1 + 0j,
                cmath.exp(2j * math.pi / 5)]
    demo_braid_relation(sample_t)
    demo_determinants(sample_t)
    demo_inverse(sample_t)
    demo_full_twist(sample_t)
    demo_density_dichotomy()
    demo_orders()
    fibonacci_r_phase()


if __name__ == "__main__":
    main()
