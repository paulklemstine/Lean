"""
Quantum Topological Phase Computation: The Fibonacci Anyon Model
================================================================

Numerical demonstrations of the structural identities behind the single-qubit
Fibonacci braid representation. Every function is self-contained and uses only
the Python standard library (math, cmath). Run as:

    python demo.py

The script verifies, with numerical tolerances:

  * the golden-ratio identity  phi^2 = phi + 1  and  tau*(tau+1) = 1;
  * F*F = I,  F^T = F,  det F = -1,  tr F = 0;
  * R^dagger R = I  and  |det R| = 1;
  * total quantum dimension squared  1 + phi^2 = 2 + phi;
  * the Artin braid relation  B1 B2 B1 = B2 B1 B2  for B1 = R, B2 = F R F.
"""

from __future__ import annotations

import cmath
import math
from typing import List, Tuple

# A 2x2 complex matrix is represented as a tuple of two rows, each a tuple of
# two complex numbers:  ((a, b), (c, d)).
Mat = Tuple[Tuple[complex, complex], Tuple[complex, complex]]

TOL: float = 1e-12


# --------------------------------------------------------------------------- #
# Basic 2x2 complex linear algebra (all inlined, no external dependencies).    #
# --------------------------------------------------------------------------- #
def mat(a: complex, b: complex, c: complex, d: complex) -> Mat:
    """Build the 2x2 matrix [[a, b], [c, d]]."""
    return ((a, b), (c, d))


def identity() -> Mat:
    """The 2x2 identity matrix."""
    return mat(1.0, 0.0, 0.0, 1.0)


def matmul(x: Mat, y: Mat) -> Mat:
    """Matrix product x @ y of two 2x2 matrices."""
    return mat(
        x[0][0] * y[0][0] + x[0][1] * y[1][0],
        x[0][0] * y[0][1] + x[0][1] * y[1][1],
        x[1][0] * y[0][0] + x[1][1] * y[1][0],
        x[1][0] * y[0][1] + x[1][1] * y[1][1],
    )


def conj_transpose(x: Mat) -> Mat:
    """Conjugate transpose (Hermitian adjoint) of a 2x2 matrix."""
    return mat(
        x[0][0].conjugate(), x[1][0].conjugate(),
        x[0][1].conjugate(), x[1][1].conjugate(),
    )


def transpose(x: Mat) -> Mat:
    """Plain transpose of a 2x2 matrix."""
    return mat(x[0][0], x[1][0], x[0][1], x[1][1])


def det(x: Mat) -> complex:
    """Determinant of a 2x2 matrix."""
    return x[0][0] * x[1][1] - x[0][1] * x[1][0]


def trace(x: Mat) -> complex:
    """Trace of a 2x2 matrix."""
    return x[0][0] + x[1][1]


def approx_equal(x: Mat, y: Mat, tol: float = TOL) -> bool:
    """Whether two 2x2 matrices agree entrywise to within ``tol``."""
    return all(
        abs(x[i][j] - y[i][j]) < tol
        for i in range(2)
        for j in range(2)
    )


def fmt(x: Mat) -> str:
    """Pretty-print a 2x2 complex matrix."""
    def c(z: complex) -> str:
        return f"{z.real:+.5f}{z.imag:+.5f}i"
    return (f"[ {c(x[0][0])}  {c(x[0][1])} ]\n"
            f"[ {c(x[1][0])}  {c(x[1][1])} ]")


# --------------------------------------------------------------------------- #
# Fibonacci anyon data.                                                       #
# --------------------------------------------------------------------------- #
def golden_ratio() -> float:
    """phi = (1 + sqrt 5) / 2, the quantum dimension of the tau anyon."""
    return (1.0 + math.sqrt(5.0)) / 2.0


def quantum_dim_inverse() -> float:
    """tau = 1 / phi = phi - 1, the inverse quantum dimension."""
    return 1.0 / golden_ratio()


def fib_F() -> Mat:
    """The Fibonacci F-matrix [[tau, sqrt(tau)], [sqrt(tau), -tau]] (real)."""
    t: float = quantum_dim_inverse()
    s: float = math.sqrt(t)
    return mat(complex(t), complex(s), complex(s), complex(-t))


def fib_R() -> Mat:
    """The Fibonacci R-matrix diag(e^{-4 pi i/5}, e^{3 pi i/5})."""
    theta1: float = -4.0 * math.pi / 5.0
    theta2: float = 3.0 * math.pi / 5.0
    return mat(cmath.exp(1j * theta1), 0.0, 0.0, cmath.exp(1j * theta2))


def braid_generators() -> Tuple[Mat, Mat]:
    """The single-qubit braid generators B1 = R and B2 = F R F."""
    f: Mat = fib_F()
    r: Mat = fib_R()
    b1: Mat = r
    b2: Mat = matmul(matmul(f, r), f)
    return b1, b2


# --------------------------------------------------------------------------- #
# Demonstrations.                                                             #
# --------------------------------------------------------------------------- #
def demo_golden_ratio() -> None:
    """Verify phi^2 = phi + 1 and tau*(tau+1) = 1."""
    phi: float = golden_ratio()
    tau: float = quantum_dim_inverse()
    print("== Golden ratio identities ==")
    print(f"phi               = {phi:.15f}")
    print(f"phi^2             = {phi * phi:.15f}")
    print(f"phi + 1           = {phi + 1.0:.15f}")
    print(f"tau               = {tau:.15f}")
    print(f"tau*(tau+1)       = {tau * (tau + 1.0):.15f}  (expected 1)")
    assert abs(phi * phi - (phi + 1.0)) < TOL
    assert abs(tau * (tau + 1.0) - 1.0) < TOL
    print("OK\n")


def demo_F_matrix() -> None:
    """Verify F is a traceless symmetric involution with det = -1."""
    f: Mat = fib_F()
    print("== F-matrix ==")
    print(fmt(f))
    print(f"F*F = I            : {approx_equal(matmul(f, f), identity())}")
    print(f"F^T = F (symmetric): {approx_equal(transpose(f), f)}")
    print(f"det F              = {det(f).real:+.5f}  (expected -1)")
    print(f"tr F               = {trace(f).real:+.5f}  (expected 0)")
    assert approx_equal(matmul(f, f), identity())
    assert approx_equal(transpose(f), f)
    assert abs(det(f) - (-1.0)) < TOL
    assert abs(trace(f)) < TOL
    print("OK\n")


def demo_R_matrix() -> None:
    """Verify R is unitary with unit-modulus determinant."""
    r: Mat = fib_R()
    print("== R-matrix ==")
    print(fmt(r))
    rdr: Mat = matmul(conj_transpose(r), r)
    print(f"R^dagger R = I     : {approx_equal(rdr, identity())}")
    print(f"|det R|            = {abs(det(r)):.15f}  (expected 1)")
    assert approx_equal(rdr, identity())
    assert abs(abs(det(r)) - 1.0) < TOL
    print("OK\n")


def demo_quantum_dimension() -> None:
    """Verify 1 + phi^2 = 2 + phi (total quantum dimension squared)."""
    phi: float = golden_ratio()
    lhs: float = 1.0 + phi * phi
    rhs: float = 2.0 + phi
    print("== Total quantum dimension ==")
    print(f"D^2 = 1 + phi^2    = {lhs:.15f}")
    print(f"2 + phi            = {rhs:.15f}")
    print(f"D                  = {math.sqrt(lhs):.15f}")
    assert abs(lhs - rhs) < TOL
    print("OK\n")


def demo_braid_relation() -> None:
    """Verify the Artin braid relation B1 B2 B1 = B2 B1 B2."""
    b1, b2 = braid_generators()
    lhs: Mat = matmul(matmul(b1, b2), b1)
    rhs: Mat = matmul(matmul(b2, b1), b2)
    print("== Artin braid relation  B1 B2 B1 = B2 B1 B2 ==")
    print("LHS = B1 B2 B1:")
    print(fmt(lhs))
    print("RHS = B2 B1 B2:")
    print(fmt(rhs))
    print(f"LHS = RHS          : {approx_equal(lhs, rhs, tol=1e-10)}")
    assert approx_equal(lhs, rhs, tol=1e-10)
    print("OK\n")


def compile_braid_word(word: List[int]) -> Mat:
    """Compile a braid word into its 2x2 unitary.

    The word is a list of nonzero integers: +1/-1 mean B1 / B1^{-1},
    +2/-2 mean B2 / B2^{-1}.
    """
    b1, b2 = braid_generators()
    b1_inv: Mat = conj_transpose(b1)   # unitary => inverse is adjoint
    b2_inv: Mat = conj_transpose(b2)
    table = {1: b1, -1: b1_inv, 2: b2, -2: b2_inv}
    acc: Mat = identity()
    for letter in word:
        acc = matmul(acc, table[letter])
    return acc


def demo_braid_word() -> None:
    """Show that braid words compile to unitaries and inverses cancel."""
    print("== Braid-word compilation ==")
    word: List[int] = [1, 2, 1, -2, -1, 2]
    u: Mat = compile_braid_word(word)
    print(f"word               = {word}")
    print("rho(word):")
    print(fmt(u))
    print(f"rho(word) unitary  : "
          f"{approx_equal(matmul(conj_transpose(u), u), identity(), tol=1e-10)}")
    inverse_word: List[int] = [-letter for letter in reversed(word)]
    back: Mat = matmul(u, compile_braid_word(inverse_word))
    print(f"word . word^{{-1}} = I: {approx_equal(back, identity(), tol=1e-10)}")
    assert approx_equal(matmul(conj_transpose(u), u), identity(), tol=1e-10)
    assert approx_equal(back, identity(), tol=1e-10)
    print("OK\n")


def main() -> None:
    """Run all demonstrations."""
    print("Fibonacci anyon braid representation -- numerical verification\n")
    demo_golden_ratio()
    demo_F_matrix()
    demo_R_matrix()
    demo_quantum_dimension()
    demo_braid_relation()
    demo_braid_word()
    print("All checks passed.")


if __name__ == "__main__":
    main()
