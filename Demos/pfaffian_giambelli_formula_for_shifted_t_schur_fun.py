"""
Numerical demonstrations for:

    A Pfaffian Giambelli Formula for Shifted t-Schur Functions: The Algebraic Core

This self-contained script verifies, on concrete numbers and symbols, the core
identities established in the accompanying paper:

    * pf2_sq_eq_det : det A = (Pf A)^2  for alternating 2x2 matrices
    * pf4_sq_eq_det : det A = (Pf A)^2  for alternating 4x4 matrices
    * pf4_swap12_neg: transposing indices 1,2 negates the 4x4 Pfaffian
    * pf4_giambelli : the 4x4 Pfaffian as a signed sum of products of 2x2 Pfaffians
    * det_fin_four  : the explicit 4x4 Laplace expansion
    * Proposition 4.1: Pf4(A + tB) = Pf4(A) + t*M(A,B) + t^2*Pf4(B)

Only the Python standard library is required.
"""

from __future__ import annotations

from itertools import permutations
from typing import List, Sequence, Tuple

Matrix = List[List[float]]


# --------------------------------------------------------------------------- #
#  Pfaffian definitions (Definitions 2.2, 2.3)
# --------------------------------------------------------------------------- #
def pf2(a: Matrix) -> float:
    """Pfaffian of a 2x2 matrix: the single super-diagonal entry A[0][1]."""
    return a[0][1]


def pf4(a: Matrix) -> float:
    """Pfaffian of a 4x4 matrix: signed sum over the three perfect matchings."""
    return a[0][1] * a[2][3] - a[0][2] * a[1][3] + a[0][3] * a[1][2]


# --------------------------------------------------------------------------- #
#  Determinant via the Leibniz formula (works in any size; ground truth)
# --------------------------------------------------------------------------- #
def _sign(perm: Sequence[int]) -> int:
    """Signature of a permutation given as a sequence of distinct integers."""
    s = 1
    p = list(perm)
    n = len(p)
    for i in range(n):
        for j in range(i + 1, n):
            if p[i] > p[j]:
                s = -s
    return s


def det(a: Matrix) -> float:
    """Determinant by the Leibniz permutation sum (exact for small n)."""
    n = len(a)
    total = 0.0
    for perm in permutations(range(n)):
        term = float(_sign(perm))
        for i in range(n):
            term *= a[i][perm[i]]
        total += term
    return total


def det_fin_four(a: Matrix) -> float:
    """The explicit first-row Laplace expansion of a 4x4 determinant (Theorem 3.1)."""
    return (
        a[0][0] * (a[1][1] * (a[2][2] * a[3][3] - a[2][3] * a[3][2])
                   - a[1][2] * (a[2][1] * a[3][3] - a[2][3] * a[3][1])
                   + a[1][3] * (a[2][1] * a[3][2] - a[2][2] * a[3][1]))
        - a[0][1] * (a[1][0] * (a[2][2] * a[3][3] - a[2][3] * a[3][2])
                     - a[1][2] * (a[2][0] * a[3][3] - a[2][3] * a[3][0])
                     + a[1][3] * (a[2][0] * a[3][2] - a[2][2] * a[3][0]))
        + a[0][2] * (a[1][0] * (a[2][1] * a[3][3] - a[2][3] * a[3][1])
                     - a[1][1] * (a[2][0] * a[3][3] - a[2][3] * a[3][0])
                     + a[1][3] * (a[2][0] * a[3][1] - a[2][1] * a[3][0]))
        - a[0][3] * (a[1][0] * (a[2][1] * a[3][2] - a[2][2] * a[3][1])
                     - a[1][1] * (a[2][0] * a[3][2] - a[2][2] * a[3][0])
                     + a[1][2] * (a[2][0] * a[3][1] - a[2][1] * a[3][0]))
    )


# --------------------------------------------------------------------------- #
#  Helpers: build alternating matrices, submatrices, swaps
# --------------------------------------------------------------------------- #
def alt2(x: float) -> Matrix:
    """The alternating 2x2 matrix with super-diagonal entry x."""
    return [[0.0, x], [-x, 0.0]]


def alt4(entries: Sequence[float]) -> Matrix:
    """Alternating 4x4 matrix from the six free entries a01,a02,a03,a12,a13,a23."""
    a01, a02, a03, a12, a13, a23 = entries
    return [
        [0.0, a01, a02, a03],
        [-a01, 0.0, a12, a13],
        [-a02, -a12, 0.0, a23],
        [-a03, -a13, -a23, 0.0],
    ]


def sub2(a: Matrix, i: int, j: int) -> Matrix:
    """The 2x2 principal submatrix of a on rows/columns {i, j} (i < j)."""
    return [[a[i][i], a[i][j]], [a[j][i], a[j][j]]]


def swap_rows_cols(a: Matrix, p: int, q: int) -> Matrix:
    """Apply the transposition (p q) to both rows and columns of a."""
    n = len(a)
    perm = list(range(n))
    perm[p], perm[q] = perm[q], perm[p]
    return [[a[perm[r]][perm[c]] for c in range(n)] for r in range(n)]


# --------------------------------------------------------------------------- #
#  Proposition 4.1: deformation expansion
# --------------------------------------------------------------------------- #
def mixed_term(a: Matrix, b: Matrix) -> float:
    """The polarization term M(A,B) in Pf4(A + tB) = Pf4(A) + t M + t^2 Pf4(B)."""
    return (
        (a[0][1] * b[2][3] + b[0][1] * a[2][3])
        - (a[0][2] * b[1][3] + b[0][2] * a[1][3])
        + (a[0][3] * b[1][2] + b[0][3] * a[1][2])
    )


def add_scaled(a: Matrix, b: Matrix, t: float) -> Matrix:
    """Return A + t*B."""
    n = len(a)
    return [[a[i][j] + t * b[i][j] for j in range(n)] for i in range(n)]


# --------------------------------------------------------------------------- #
#  Demonstrations
# --------------------------------------------------------------------------- #
def demo_pf2() -> None:
    print("=" * 64)
    print("Theorem pf2_sq_eq_det:  det A = (Pf A)^2  (2x2 alternating)")
    print("=" * 64)
    for x in (1.0, -3.0, 7.5):
        a = alt2(x)
        d, p = det(a), pf2(a)
        print(f"  x={x:+6.2f} : det={d:+8.2f}  Pf^2={p**2:+8.2f}  match={abs(d-p**2)<1e-9}")
    print()


def demo_pf4() -> None:
    print("=" * 64)
    print("Theorem pf4_sq_eq_det:  det A = (Pf A)^2  (4x4 alternating)")
    print("Theorem det_fin_four :  Leibniz det == explicit 4x4 expansion")
    print("=" * 64)
    samples = [
        (1.0, 2.0, 3.0, 4.0, 5.0, 6.0),
        (-2.0, 1.5, 0.0, 3.0, -1.0, 2.0),
        (3.0, -3.0, 3.0, -3.0, 3.0, -3.0),
    ]
    for e in samples:
        a = alt4(e)
        d, p = det(a), pf4(a)
        dexp = det_fin_four(a)
        print(f"  entries={e}")
        print(f"     det={d:+10.2f}  Pf^2={p**2:+10.2f}  match={abs(d-p**2)<1e-9}")
        print(f"     det_fin_four={dexp:+10.2f}  matches Leibniz={abs(d-dexp)<1e-9}")
    print()


def demo_sign_law() -> None:
    print("=" * 64)
    print("Theorem pf4_swap12_neg:  Pf(A^tau) = -Pf(A)  for tau=(1 2)")
    print("=" * 64)
    a = alt4((1.0, 2.0, 3.0, 4.0, 5.0, 6.0))
    a_sw = swap_rows_cols(a, 1, 2)
    print(f"  Pf(A)      = {pf4(a):+8.2f}")
    print(f"  Pf(A^tau)  = {pf4(a_sw):+8.2f}")
    print(f"  negated?   = {abs(pf4(a_sw) + pf4(a)) < 1e-9}")
    print()


def demo_giambelli() -> None:
    print("=" * 64)
    print("Theorem pf4_giambelli:  Pf4 = sum of products of 2x2 Pfaffians")
    print("=" * 64)
    a = alt4((1.0, 2.0, 3.0, 4.0, 5.0, 6.0))
    rhs = (
        pf2(sub2(a, 0, 1)) * pf2(sub2(a, 2, 3))
        - pf2(sub2(a, 0, 2)) * pf2(sub2(a, 1, 3))
        + pf2(sub2(a, 0, 3)) * pf2(sub2(a, 1, 2))
    )
    print(f"  Pf4(A)               = {pf4(a):+8.2f}")
    print(f"  Giambelli expansion  = {rhs:+8.2f}")
    print(f"  match                = {abs(pf4(a) - rhs) < 1e-9}")
    print()


def demo_deformation() -> None:
    print("=" * 64)
    print("Proposition 4.1:  Pf4(A + tB) = Pf4(A) + t M(A,B) + t^2 Pf4(B)")
    print("=" * 64)
    a = alt4((1.0, 0.0, 2.0, -1.0, 3.0, 1.0))
    b = alt4((0.5, 1.0, -1.0, 2.0, 0.0, 1.0))
    pa, pb, m = pf4(a), pf4(b), mixed_term(a, b)
    print(f"  Pf4(A)={pa:+.3f}  M(A,B)={m:+.3f}  Pf4(B)={pb:+.3f}")
    for t in (0.0, 0.5, 1.0, 2.0, -1.5):
        lhs = pf4(add_scaled(a, b, t))
        rhs = pa + t * m + t * t * pb
        print(f"  t={t:+5.2f} : Pf4(A+tB)={lhs:+9.3f}  poly={rhs:+9.3f}  match={abs(lhs-rhs)<1e-9}")
    print()


def main() -> None:
    demo_pf2()
    demo_pf4()
    demo_sign_law()
    demo_giambelli()
    demo_deformation()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
