"""Numerical demonstrations for the algebraic core of four-dimensional geometry.

This self-contained script illustrates the main results:

  1. The sum-of-squares core identity (a+b)^2 = 4ab + (a-b)^2.
  2. The Brahmagupta-Fibonacci two-square and Euler four-square identities
     (multiplicativity of the complex and quaternion norms).
  3. The Lagrange identity and the resulting Cauchy-Schwarz inequality in R^3.
  4. The Hopf map, its landing on the two-sphere, circle invariance, and the
     division-free fibre witness lambda = conj(z) z' + conj(w) w'.
  5. The complex structure J = multiplication by i: J^2 = -I, isometry,
     and fixed-point freeness on the sphere.
  6. Balanced Clifford tori (two- and three-radius AM-GM) and quaternionic
     conjugation as an isometry.

Run with:  python demo.py
Requires only the Python standard library.
"""

from __future__ import annotations

import cmath
import math
import random
from typing import List, Tuple

Complex = complex


# --------------------------------------------------------------------------
# 1. The sum-of-squares core identity
# --------------------------------------------------------------------------
def sum_of_squares_core(a: float, b: float) -> Tuple[float, float]:
    """Return the two sides of (a+b)^2 and 4ab + (a-b)^2."""
    lhs = (a + b) ** 2
    rhs = 4 * a * b + (a - b) ** 2
    return lhs, rhs


# --------------------------------------------------------------------------
# 2. Composition identities
# --------------------------------------------------------------------------
def two_square_identity(a: float, b: float, c: float, d: float) -> Tuple[float, float]:
    """Brahmagupta-Fibonacci: (a^2+b^2)(c^2+d^2) = (ac-bd)^2 + (ad+bc)^2."""
    lhs = (a * a + b * b) * (c * c + d * d)
    rhs = (a * c - b * d) ** 2 + (a * d + b * c) ** 2
    return lhs, rhs


def four_square_identity(a: List[float], b: List[float]) -> Tuple[float, float]:
    """Euler's four-square identity via quaternion multiplication in coordinates."""
    a1, a2, a3, a4 = a
    b1, b2, b3, b4 = b
    lhs = (a1 * a1 + a2 * a2 + a3 * a3 + a4 * a4) * (
        b1 * b1 + b2 * b2 + b3 * b3 + b4 * b4
    )
    c1 = a1 * b1 - a2 * b2 - a3 * b3 - a4 * b4
    c2 = a1 * b2 + a2 * b1 + a3 * b4 - a4 * b3
    c3 = a1 * b3 - a2 * b4 + a3 * b1 + a4 * b2
    c4 = a1 * b4 + a2 * b3 - a3 * b2 + a4 * b1
    rhs = c1 * c1 + c2 * c2 + c3 * c3 + c4 * c4
    return lhs, rhs


def lagrange_and_cauchy_schwarz(
    a: List[float], b: List[float]
) -> Tuple[float, float, float]:
    """Return (Gram determinant, sum-of-squares side, dot^2) for two R^3 vectors."""
    a1, a2, a3 = a
    b1, b2, b3 = b
    gram = (a1 * a1 + a2 * a2 + a3 * a3) * (b1 * b1 + b2 * b2 + b3 * b3) - (
        a1 * b1 + a2 * b2 + a3 * b3
    ) ** 2
    cross_sq = (
        (a1 * b2 - a2 * b1) ** 2
        + (a1 * b3 - a3 * b1) ** 2
        + (a2 * b3 - a3 * b2) ** 2
    )
    dot_sq = (a1 * b1 + a2 * b2 + a3 * b3) ** 2
    return gram, cross_sq, dot_sq


# --------------------------------------------------------------------------
# 3. The Hopf map
# --------------------------------------------------------------------------
def hopf(z: Complex, w: Complex) -> Tuple[Complex, float]:
    """The Hopf map (z, w) -> (2 z conj(w), |z|^2 - |w|^2)."""
    return (2 * z * w.conjugate(), abs(z) ** 2 - abs(w) ** 2)


def random_unit_pair(rng: random.Random) -> Tuple[Complex, float]:
    """A random point of S^3 as a pair (z, w) with |z|^2 + |w|^2 = 1."""
    z = complex(rng.gauss(0, 1), rng.gauss(0, 1))
    w = complex(rng.gauss(0, 1), rng.gauss(0, 1))
    n = math.sqrt(abs(z) ** 2 + abs(w) ** 2)
    return z / n, w / n


def hopf_fibre_witness(
    z: Complex, w: Complex, zp: Complex, wp: Complex
) -> Complex:
    """The Hermitian inner-product witness lambda = conj(z) z' + conj(w) w'."""
    return z.conjugate() * zp + w.conjugate() * wp


# --------------------------------------------------------------------------
# 4. The complex structure J = multiplication by i
# --------------------------------------------------------------------------
def J(v: List[Complex]) -> List[Complex]:
    """Multiply every coordinate by i."""
    return [1j * x for x in v]


def norm_sq(v: List[Complex]) -> float:
    return sum(abs(x) ** 2 for x in v)


# --------------------------------------------------------------------------
# 5. Balanced Clifford tori
# --------------------------------------------------------------------------
def clifford_product_two(a: float) -> float:
    """4 a (1-a): the area factor of a two-radius Clifford torus with b = 1 - a."""
    return 4 * a * (1 - a)


def clifford_product_three(a: float, b: float) -> float:
    """a b c with c = 1 - a - b: the volume factor of a three-radius torus."""
    return a * b * (1 - a - b)


# --------------------------------------------------------------------------
# 6. Quaternions (as a minimal inlined type)
# --------------------------------------------------------------------------
def quat_mul(p: List[float], q: List[float]) -> List[float]:
    """Hamilton product of two quaternions (w, x, y, z)."""
    p0, p1, p2, p3 = p
    q0, q1, q2, q3 = q
    return [
        p0 * q0 - p1 * q1 - p2 * q2 - p3 * q3,
        p0 * q1 + p1 * q0 + p2 * q3 - p3 * q2,
        p0 * q2 - p1 * q3 + p2 * q0 + p3 * q1,
        p0 * q3 + p1 * q2 - p2 * q1 + p3 * q0,
    ]


def quat_norm_sq(q: List[float]) -> float:
    return sum(c * c for c in q)


def quat_inv(q: List[float]) -> List[float]:
    n = quat_norm_sq(q)
    q0, q1, q2, q3 = q
    return [q0 / n, -q1 / n, -q2 / n, -q3 / n]


def quat_conjugation(q: List[float], x: List[float]) -> List[float]:
    """The rotation x -> q x q^{-1}."""
    return quat_mul(quat_mul(q, x), quat_inv(q))


# --------------------------------------------------------------------------
# Driver
# --------------------------------------------------------------------------
def main() -> None:
    rng = random.Random(20260712)
    tol = 1e-9

    print("=" * 70)
    print("1. Sum-of-squares core identity (a+b)^2 = 4ab + (a-b)^2")
    print("=" * 70)
    for _ in range(3):
        a, b = rng.uniform(-5, 5), rng.uniform(-5, 5)
        lhs, rhs = sum_of_squares_core(a, b)
        print(f"  a={a:+.3f}, b={b:+.3f}:  lhs={lhs:.6f}  rhs={rhs:.6f}  "
              f"match={abs(lhs - rhs) < tol}")

    print("\n" + "=" * 70)
    print("2. Composition identities (norm multiplicativity)")
    print("=" * 70)
    lhs, rhs = two_square_identity(1, 2, 3, 4)
    print(f"  Two-square (1,2)*(3,4): {lhs} == {rhs}  -> {lhs == rhs}")
    lhs, rhs = four_square_identity([1, 2, 3, 4], [5, 6, 7, 8])
    print(f"  Four-square (Euler):    {lhs} == {rhs}  -> {lhs == rhs}")

    print("\n" + "=" * 70)
    print("3. Lagrange identity and Cauchy-Schwarz in R^3")
    print("=" * 70)
    for _ in range(3):
        a = [rng.uniform(-3, 3) for _ in range(3)]
        b = [rng.uniform(-3, 3) for _ in range(3)]
        gram, cross_sq, dot_sq = lagrange_and_cauchy_schwarz(a, b)
        prod = (a[0]**2 + a[1]**2 + a[2]**2) * (b[0]**2 + b[1]**2 + b[2]**2)
        print(f"  Gram={gram:.4f}  ||axb||^2={cross_sq:.4f}  "
              f"(match={abs(gram - cross_sq) < 1e-6})  "
              f"dot^2 <= |a|^2|b|^2: {dot_sq:.4f} <= {prod:.4f}  "
              f"-> {dot_sq <= prod + 1e-9}")

    print("\n" + "=" * 70)
    print("4. Hopf map: lands on S^2, circle invariance, fibre witness")
    print("=" * 70)
    z, w = random_unit_pair(rng)
    zeta, t = hopf(z, w)
    print(f"  |h(z,w)|^2 = |zeta|^2 + t^2 = {abs(zeta)**2 + t*t:.10f}  (should be 1)")
    lam0 = cmath.exp(1j * rng.uniform(0, 2 * math.pi))  # |lambda| = 1
    zeta2, t2 = hopf(lam0 * z, lam0 * w)
    print(f"  Circle invariance: h(lz, lw) - h(z,w) = "
          f"({abs(zeta2 - zeta):.2e}, {abs(t2 - t):.2e})")
    # Two points on the same fibre; recover the phase from the witness.
    zp, wp = lam0 * z, lam0 * w
    lam = hopf_fibre_witness(z, w, zp, wp)
    print(f"  Recovered lambda = {lam:.4f}, |lambda| = {abs(lam):.10f}")
    print(f"  z' - lambda*z = {abs(zp - lam * z):.2e}, "
          f"w' - lambda*w = {abs(wp - lam * w):.2e}")

    print("\n" + "=" * 70)
    print("5. Complex structure J = multiplication by i on C^n")
    print("=" * 70)
    v = [complex(rng.gauss(0, 1), rng.gauss(0, 1)) for _ in range(4)]
    v = [x / math.sqrt(norm_sq(v)) for x in v]  # unit vector
    JJv = J(J(v))
    print(f"  J^2 v + v = {max(abs(a + b) for a, b in zip(JJv, v)):.2e}  (J^2 = -I)")
    print(f"  ||Jv||^2 = {norm_sq(J(v)):.10f}, ||v||^2 = {norm_sq(v):.10f}  (isometry)")
    print(f"  max|Jv - v| = {max(abs(a - b) for a, b in zip(J(v), v)):.4f}  "
          f"(> 0: fixed-point free)")

    print("\n" + "=" * 70)
    print("6. Balanced Clifford tori (AM-GM extrema)")
    print("=" * 70)
    best_a = max((rng.random() for _ in range(100000)), key=clifford_product_two)
    print(f"  Two-radius: max 4ab found at a={best_a:.4f} (exact 0.5), "
          f"value={clifford_product_two(0.5):.4f} (exact 1)")
    best = 0.0
    N = 300
    for i in range(N + 1):
        for j in range(N + 1 - i):
            a = i / N
            b = j / N
            best = max(best, clifford_product_three(a, b))
    print(f"  Three-radius: sampled max abc ~ {best:.6f}, "
          f"exact at (1/3,1/3,1/3) = {clifford_product_three(1/3, 1/3):.6f} (=1/27)")

    print("\n" + "=" * 70)
    print("7. Quaternionic conjugation is an isometry")
    print("=" * 70)
    for _ in range(3):
        q = [rng.gauss(0, 1) for _ in range(4)]
        x = [rng.gauss(0, 1) for _ in range(4)]
        y = quat_conjugation(q, x)
        print(f"  N(q x q^-1) = {quat_norm_sq(y):.6f},  N(x) = {quat_norm_sq(x):.6f}  "
              f"-> match={abs(quat_norm_sq(y) - quat_norm_sq(x)) < 1e-6}")


if __name__ == "__main__":
    main()
