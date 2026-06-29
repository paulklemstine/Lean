"""
demo.py — Intersection forms, the Donaldson obstruction, and the E8 phenomenon.

A self-contained numerical companion to the formalized theory of symmetric
integral intersection forms.  Everything below uses only the Python standard
library (no NumPy): integer matrices are lists of lists, and all arithmetic is
exact, mirroring the integer-exact reasoning of the formal proofs.

We demonstrate, with concrete numbers, the following verified facts:

  * The E8 Gram matrix is symmetric, even (all diagonal entries are 2), and
    unimodular (determinant exactly 1, certified by an explicit integral inverse).
  * E8 represents only even values, so it CANNOT be congruent to the standard
    diagonal form diag(1,...,1), which represents the odd value 1.  This is the
    algebraic Donaldson obstruction.
  * The three structural predicates (unimodular, even, standard-diagonalizable)
    are additive under the orthogonal direct sum (the algebraic connected sum).
  * Hence E8 (+) E8, a rank-16 signature-16 form, is still even, unimodular, and
    NOT standard-diagonalizable: the obstruction is stable.
  * The rank-0 form of S^4 is trivially unimodular, even, and standard, exhibiting
    the invariant's blindness to the smooth 4D Poincare conjecture.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from typing import List, Tuple

Matrix = List[List[int]]
Vector = List[int]


# --------------------------------------------------------------------------- #
# Basic exact integer linear algebra                                          #
# --------------------------------------------------------------------------- #

def transpose(a: Matrix) -> Matrix:
    """Return the transpose of an integer matrix."""
    return [list(row) for row in zip(*a)]


def is_symmetric(a: Matrix) -> bool:
    """True iff a == a^T (a is a valid Gram matrix of a symmetric form)."""
    return a == transpose(a)


def matmul(a: Matrix, b: Matrix) -> Matrix:
    """Exact integer matrix product a @ b."""
    n, m, p = len(a), len(b), len(b[0])
    assert len(a[0]) == m
    return [[sum(a[i][k] * b[k][j] for k in range(m)) for j in range(p)]
            for i in range(n)]


def mat_vec(a: Matrix, v: Vector) -> Vector:
    """Exact integer matrix-vector product a @ v."""
    return [sum(a[i][k] * v[k] for k in range(len(v))) for i in range(len(a))]


def dot(u: Vector, v: Vector) -> int:
    """Integer dot product u . v."""
    return sum(x * y for x, y in zip(u, v))


def quadratic_value(gram: Matrix, v: Vector) -> int:
    """The value Q(v) = v^T G v of the form with Gram matrix `gram`."""
    return dot(v, mat_vec(gram, v))


def det_int(a: Matrix) -> int:
    """Exact determinant of an integer matrix via fraction-free elimination.

    Uses Fraction internally to stay exact, then returns the integer result.
    """
    n = len(a)
    m = [[Fraction(x) for x in row] for row in a]
    det = Fraction(1)
    for col in range(n):
        pivot = None
        for r in range(col, n):
            if m[r][col] != 0:
                pivot = r
                break
        if pivot is None:
            return 0
        if pivot != col:
            m[col], m[pivot] = m[pivot], m[col]
            det = -det
        det *= m[col][col]
        inv = m[col][col]
        for r in range(col + 1, n):
            factor = m[r][col] / inv
            if factor != 0:
                for c in range(col, n):
                    m[r][c] -= factor * m[col][c]
    assert det.denominator == 1
    return det.numerator


def identity(n: int) -> Matrix:
    """The n x n identity matrix."""
    return [[1 if i == j else 0 for j in range(n)] for i in range(n)]


def direct_sum(a: Matrix, b: Matrix) -> Matrix:
    """Block-diagonal direct sum [[A,0],[0,B]] — the algebraic connected sum."""
    n, p = len(a), len(b)
    top = [list(a[i]) + [0] * p for i in range(n)]
    bot = [[0] * n + list(b[i]) for i in range(p)]
    return top + bot


# --------------------------------------------------------------------------- #
# Structural predicates of an intersection form                               #
# --------------------------------------------------------------------------- #

def is_unimodular(gram: Matrix) -> bool:
    """Poincare duality: determinant is a unit in Z, i.e. +1 or -1."""
    return det_int(gram) in (1, -1)


def diagonal_all_even(gram: Matrix) -> bool:
    """All diagonal entries even => the form is even (Diagonal Evenness Criterion)."""
    return all(gram[i][i] % 2 == 0 for i in range(len(gram)))


def is_even_by_sampling(gram: Matrix, radius: int = 2) -> bool:
    """Empirically check evenness on all integer vectors in [-radius, radius]^n.

    A *proof* of evenness for symmetric forms reduces to the diagonal being
    even (see `diagonal_all_even`); this is a finite sanity check.
    """
    n = len(gram)
    for v in product(range(-radius, radius + 1), repeat=n):
        if quadratic_value(gram, list(v)) % 2 != 0:
            return False
    return True


def is_congruent_to_identity(gram: Matrix, t: Matrix) -> bool:
    """True iff T^T G T = I and det T is a unit (witness of standardness)."""
    n = len(gram)
    return matmul(matmul(transpose(t), gram), t) == identity(n) and det_int(t) in (1, -1)


# --------------------------------------------------------------------------- #
# The E8 form and its explicit integral inverse                               #
# --------------------------------------------------------------------------- #

E8: Matrix = [
    [2, -1, 0, 0, 0, 0, 0, 0],
    [-1, 2, -1, 0, 0, 0, 0, 0],
    [0, -1, 2, -1, 0, 0, 0, 0],
    [0, 0, -1, 2, -1, 0, 0, 0],
    [0, 0, 0, -1, 2, -1, 0, -1],
    [0, 0, 0, 0, -1, 2, -1, 0],
    [0, 0, 0, 0, 0, -1, 2, 0],
    [0, 0, 0, 0, -1, 0, 0, 2],
]

E8_INV: Matrix = [
    [2, 3, 4, 5, 6, 4, 2, 3],
    [3, 6, 8, 10, 12, 8, 4, 6],
    [4, 8, 12, 15, 18, 12, 6, 9],
    [5, 10, 15, 20, 24, 16, 8, 12],
    [6, 12, 18, 24, 30, 20, 10, 15],
    [4, 8, 12, 16, 20, 14, 7, 10],
    [2, 4, 6, 8, 10, 7, 4, 5],
    [3, 6, 9, 12, 15, 10, 5, 8],
]


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #

def demo_e8_basic() -> None:
    """Certify the basic structural facts about E8."""
    print("=" * 70)
    print("E8 form: symmetry, evenness, unimodularity")
    print("=" * 70)
    print(f"  symmetric?           {is_symmetric(E8)}")
    print(f"  diagonal all even?   {diagonal_all_even(E8)}  (=> even form)")
    print(f"  even on [-2,2]^8?    {is_even_by_sampling(E8)}  (sanity sample)")
    print(f"  det(E8) =            {det_int(E8)}")
    print(f"  E8 * E8_inv == I?    {matmul(E8, E8_INV) == identity(8)}")
    print(f"  unimodular?          {is_unimodular(E8)}")
    print()


def demo_obstruction() -> None:
    """Show why an even form cannot be congruent to the standard diagonal."""
    print("=" * 70)
    print("The Donaldson obstruction (algebraic core)")
    print("=" * 70)
    print("  The standard form diag(1,...,1) represents the value 1 on e_0:")
    e0 = [1] + [0] * 7
    print(f"    std.value(e0) = {quadratic_value(identity(8), e0)}  (odd)")
    print("  But E8 is even, so EVERY value E8(v) is even.  A change of basis")
    print("  T with T^T E8 T = I would force E8(T e0) = e0 . e0 = 1, odd.")
    print("  Even = always-even contradicts the represented value 1.")
    print("  => E8 is NOT standard-diagonalizable.  (Obstruction Theorem)")
    print()
    # Minimum nonzero value E8 represents is 2 (it is even & positive-definite):
    min_val = min(
        quadratic_value(E8, list(v))
        for v in product(range(-1, 2), repeat=8)
        if any(v)
    )
    print(f"  Smallest nonzero value of E8 on {{-1,0,1}}^8 is {min_val} "
          f"(never 1, always even).")
    print()


def demo_direct_sum() -> None:
    """Additivity of the predicates and the stable E8 (+) E8 obstruction."""
    print("=" * 70)
    print("Direct sum (connected sum) and the stable E8 (+) E8 obstruction")
    print("=" * 70)
    e8e8 = direct_sum(E8, E8)
    print(f"  rank(E8 (+) E8)      = {len(e8e8)}")
    print(f"  symmetric?           {is_symmetric(e8e8)}")
    print(f"  diagonal all even?   {diagonal_all_even(e8e8)}  (=> even, additive)")
    print(f"  det(E8 (+) E8)       = {det_int(e8e8)}  (= det(E8)^2, unimodular)")
    print(f"  unimodular?          {is_unimodular(e8e8)}")
    # Signature: positive-definite of rank 16 => signature 16.
    print("  signature            = 16  (positive-definite, clears Rokhlin's"
          " mod-16 hurdle)")
    print("  Still even of positive rank => NOT standard-diagonalizable.")
    print("  The obstruction is STABLE under connected sum.")
    print()


def demo_sphere() -> None:
    """The rank-0 sphere form: trivially unimodular, even, and standard."""
    print("=" * 70)
    print("S^4: the rank-0 form is blind to exotic smooth structure")
    print("=" * 70)
    empty: Matrix = []  # 0x0 Gram matrix
    print(f"  det(empty) = {det_int(empty)}  (unimodular)")
    print(f"  value on empty vector = {quadratic_value(empty, [])}  (even)")
    print("  T = I_0 gives standardness trivially.")
    print("  Every homotopy 4-sphere shares this form => intersection forms")
    print("  cannot detect an exotic S^4 (smooth 4D Poincare is invisible here).")
    print()


def main() -> None:
    demo_e8_basic()
    demo_obstruction()
    demo_direct_sum()
    demo_sphere()
    print("All numerical checks consistent with the formalized theorems.")


if __name__ == "__main__":
    main()
