"""
demo.py — Numerical demonstrations of the Jones-braid non-abelianity certificate.

This script is fully self-contained (standard library only: `fractions`,
`cmath`, `itertools`) and demonstrates the results of the paper
"A Non-Abelianity Certificate for Jones Braid Operators":

  Jones operator:        jonesOp(u, X) = u * I + (1/u) * X
  Commutator identity:   [jonesOp(u,X), jonesOp(u,Y)] = u^(-2) * [X, Y]
  Non-abelianity:        jonesOp(u,X), jonesOp(u,Y) commute  <=>  X, Y commute

We verify these over exact rational arithmetic, over complex roots of unity
(the physically relevant regime), and on the explicit 2x2 example from the paper.

Run:  python3 demo.py
"""

from __future__ import annotations

import cmath
from fractions import Fraction
from itertools import product
from typing import List, Sequence, TypeVar

Number = TypeVar("Number", Fraction, complex)
Matrix = List[List[Number]]


# --------------------------------------------------------------------------- #
# Minimal self-contained square-matrix algebra                                #
# --------------------------------------------------------------------------- #
def identity(n: int, one: Number) -> Matrix:
    """The n x n identity matrix with the given multiplicative unit `one`."""
    zero = one - one
    return [[one if i == j else zero for j in range(n)] for i in range(n)]


def scalar_mul(c: Number, A: Matrix) -> Matrix:
    """Scalar multiple c * A."""
    return [[c * A[i][j] for j in range(len(A[0]))] for i in range(len(A))]


def mat_add(A: Matrix, B: Matrix) -> Matrix:
    """Entrywise sum A + B."""
    return [[A[i][j] + B[i][j] for j in range(len(A[0]))] for i in range(len(A))]


def mat_sub(A: Matrix, B: Matrix) -> Matrix:
    """Entrywise difference A - B."""
    return [[A[i][j] - B[i][j] for j in range(len(A[0]))] for i in range(len(A))]


def mat_mul(A: Matrix, B: Matrix) -> Matrix:
    """Matrix product A * B."""
    n, m, p = len(A), len(B), len(B[0])
    zero = A[0][0] - A[0][0]
    out: Matrix = [[zero for _ in range(p)] for _ in range(n)]
    for i in range(n):
        for k in range(m):
            aik = A[i][k]
            for j in range(p):
                out[i][j] += aik * B[k][j]
    return out


def commutator(A: Matrix, B: Matrix) -> Matrix:
    """The matrix commutator [A, B] = A B - B A."""
    return mat_sub(mat_mul(A, B), mat_mul(B, A))


def approx_zero(A: Matrix, tol: float = 1e-9) -> bool:
    """True if every entry of A is (numerically) zero."""
    return all(abs(complex(A[i][j])) <= tol for i in range(len(A)) for j in range(len(A[0])))


def mat_equal(A: Matrix, B: Matrix, tol: float = 1e-9) -> bool:
    """True if A and B agree within tolerance."""
    return approx_zero(mat_sub(A, B), tol)


# --------------------------------------------------------------------------- #
# The Jones operator and the certificate                                      #
# --------------------------------------------------------------------------- #
def jones_op(u: Number, X: Matrix) -> Matrix:
    """jonesOp(u, X) = u * I + (1/u) * X  (Definition 2.1)."""
    n = len(X)
    one = u / u  # multiplicative unit of the scalar type
    I = identity(n, one)
    return mat_add(scalar_mul(u, I), scalar_mul(one / u, X))


def commutator_identity_residual(u: Number, X: Matrix, Y: Matrix) -> Matrix:
    """LHS - RHS of Theorem 3.2; should be the zero matrix."""
    lhs = commutator(jones_op(u, X), jones_op(u, Y))
    one = u / u
    rhs = scalar_mul((one / u) * (one / u), commutator(X, Y))
    return mat_sub(lhs, rhs)


def jones_ops_commute(u: Number, X: Matrix, Y: Matrix, tol: float = 1e-9) -> bool:
    """Decide whether jonesOp(u,X) and jonesOp(u,Y) commute (direct test)."""
    return approx_zero(commutator(jones_op(u, X), jones_op(u, Y)), tol)


def generators_commute(X: Matrix, Y: Matrix, tol: float = 1e-9) -> bool:
    """The u-independent oracle of Theorem 3.3: commute iff [X, Y] = 0."""
    return approx_zero(commutator(X, Y), tol)


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_exact_commutator_identity() -> None:
    """Verify Theorem 3.2 exactly over Fraction arithmetic."""
    print("=" * 70)
    print("DEMO 1 — Exact commutator identity over the rationals (Theorem 3.2)")
    print("=" * 70)
    X: Matrix = [[Fraction(0), Fraction(2)], [Fraction(-1), Fraction(3)]]
    Y: Matrix = [[Fraction(1), Fraction(0)], [Fraction(4), Fraction(-2)]]
    for u in (Fraction(1), Fraction(3), Fraction(-5, 2), Fraction(7, 3)):
        residual = commutator_identity_residual(u, X, Y)
        ok = approx_zero(residual)
        print(f"  u = {str(u):>6} :  [jonesOp X, jonesOp Y] - u^-2 [X,Y] = 0  ->  {ok}")
    print("  All residuals are exactly the zero matrix.\n")


def demo_roots_of_unity() -> None:
    """Verify the identity at complex roots of unity (the physical regime)."""
    print("=" * 70)
    print("DEMO 2 — Identity at roots of unity exp(2*pi*i/k)  (k = 3, 4, 5, 6)")
    print("=" * 70)
    # A small non-commuting pair of complex matrices.
    X: Matrix = [[0j, 1j], [0j, 0j]]
    Y: Matrix = [[0j, 0j], [1 + 0j, 0j]]
    for k in (3, 4, 5, 6):
        u = cmath.exp(2j * cmath.pi / k)
        ok = approx_zero(commutator_identity_residual(u, X, Y))
        nc = not jones_ops_commute(u, X, Y)
        tag = " (Fibonacci k=5)" if k == 5 else ""
        print(f"  k = {k}{tag:>17} :  identity holds = {ok},  gates non-commuting = {nc}")
    print()


def demo_equivalence_both_directions() -> None:
    """Verify Theorem 3.3 in both directions: a commuting pair and a non-commuting pair."""
    print("=" * 70)
    print("DEMO 3 — Non-abelianity equivalence, both directions (Theorem 3.3)")
    print("=" * 70)
    u = cmath.exp(2j * cmath.pi / 5)  # Fibonacci weight

    # (a) A commuting pair: two diagonal matrices.
    Xc: Matrix = [[2 + 0j, 0j], [0j, 5 + 0j]]
    Yc: Matrix = [[7 + 0j, 0j], [0j, 1 + 0j]]
    print("  Commuting generators (diagonal):")
    print(f"    [X,Y] = 0 : {generators_commute(Xc, Yc)};  "
          f"gates commute : {jones_ops_commute(u, Xc, Yc)}  (both True expected)")

    # (b) A non-commuting pair: the nilpotent generators of the paper.
    Xn: Matrix = [[0j, 1 + 0j], [0j, 0j]]
    Yn: Matrix = [[0j, 0j], [1 + 0j, 0j]]
    print("  Non-commuting generators (nilpotent):")
    print(f"    [X,Y] = 0 : {generators_commute(Xn, Yn)};  "
          f"gates commute : {jones_ops_commute(u, Xn, Yn)}  (both False expected)")
    print()


def demo_paper_example() -> None:
    """The explicit rational example of Section 5 (Theorems 5.1, 5.2)."""
    print("=" * 70)
    print("DEMO 4 — Explicit 2x2 rational certificate (Section 5)")
    print("=" * 70)
    X: Matrix = [[Fraction(0), Fraction(1)], [Fraction(0), Fraction(0)]]
    Y: Matrix = [[Fraction(0), Fraction(0)], [Fraction(1), Fraction(0)]]
    XY, YX = mat_mul(X, Y), mat_mul(Y, X)
    print(f"  X*Y = {XY}")
    print(f"  Y*X = {YX}")
    print(f"  X*Y != Y*X  ->  {XY != YX}   (Theorem 5.1)")
    print("  For every rational unit u, jonesOp(u,X) and jonesOp(u,Y) fail to commute")
    print("  (Theorem 5.2). Checking a sample of units:")
    for u in (Fraction(1), Fraction(-1), Fraction(2), Fraction(3, 5), Fraction(-11, 4)):
        nc = not jones_ops_commute(u, X, Y)
        print(f"    u = {str(u):>7} :  non-commuting = {nc}")
    print()


def demo_u_independent_oracle() -> None:
    """Illustrate that commutativity of the gates does not depend on the weight u."""
    print("=" * 70)
    print("DEMO 5 — The weight u is irrelevant to commutativity (Theorem 3.3)")
    print("=" * 70)
    pairs = {
        "nilpotent (non-commuting)": ([[0j, 1 + 0j], [0j, 0j]], [[0j, 0j], [1 + 0j, 0j]]),
        "diagonal  (commuting)    ": ([[3 + 0j, 0j], [0j, 1 + 0j]], [[2 + 0j, 0j], [0j, 9 + 0j]]),
    }
    weights = [cmath.exp(2j * cmath.pi / k) for k in (3, 4, 5, 7)]
    for label, (X, Y) in pairs.items():
        oracle = generators_commute(X, Y)
        results = [jones_ops_commute(u, X, Y) for u in weights]
        consistent = all(r == oracle for r in results)
        print(f"  {label}: oracle says commute={oracle}; "
              f"all weights agree -> {consistent}")
    print()


def main() -> None:
    print("\nJONES-BRAID NON-ABELIANITY CERTIFICATE — NUMERICAL DEMONSTRATIONS\n")
    demo_exact_commutator_identity()
    demo_roots_of_unity()
    demo_equivalence_both_directions()
    demo_paper_example()
    demo_u_independent_oracle()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
