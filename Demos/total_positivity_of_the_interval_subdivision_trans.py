"""
Numerical demonstrations for:

    Total Nonnegativity of the Interval Subdivision Transformation Matrix

A real matrix is *totally nonnegative* (TN) when every minor -- the determinant
of any square submatrix chosen along strictly increasing rows and columns -- is
nonnegative.  This script demonstrates, entirely from first principles and
without external dependencies:

  1. Brute-force verification that a matrix is TN, by enumerating every minor.
  2. The three-dimensional interval subdivision transformation matrix
         H = [[1,1,1],[0,1,2],[0,0,1]]
     is TN.
  3. The bidiagonal certificate: H is obtained from the identity by a sequence
     of valid adjacent column operations, and each intermediate matrix is TN.
  4. The Preservation Lemma in action: a single adjacent nonnegative column
     operation keeps a TN matrix TN.
  5. The vertex count of the interval subdivision of the (d-1)-simplex: 3^d - 2^d.

Everything is implemented with exact integer / fraction arithmetic so the sign
tests are unambiguous.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations
from typing import List, Sequence, Tuple

Matrix = List[List[Fraction]]


# --------------------------------------------------------------------------- #
# Basic exact linear algebra                                                   #
# --------------------------------------------------------------------------- #
def to_matrix(rows: Sequence[Sequence[float]]) -> Matrix:
    """Convert a nested list of numbers into an exact Fraction matrix."""
    return [[Fraction(x) for x in row] for row in rows]


def determinant(mat: Matrix) -> Fraction:
    """Exact determinant via fraction-free-ish Gaussian elimination."""
    n = len(mat)
    a = [row[:] for row in mat]  # working copy
    det = Fraction(1)
    for col in range(n):
        # find a pivot
        pivot = None
        for r in range(col, n):
            if a[r][col] != 0:
                pivot = r
                break
        if pivot is None:
            return Fraction(0)
        if pivot != col:
            a[col], a[pivot] = a[pivot], a[col]
            det = -det
        det *= a[col][col]
        inv = a[col][col]
        for r in range(col + 1, n):
            factor = a[r][col] / inv
            if factor != 0:
                for c in range(col, n):
                    a[r][c] -= factor * a[col][c]
    return det


def submatrix(mat: Matrix, rows: Sequence[int], cols: Sequence[int]) -> Matrix:
    """Select the submatrix on the given (strictly increasing) rows and columns."""
    return [[mat[r][c] for c in cols] for r in rows]


# --------------------------------------------------------------------------- #
# Total nonnegativity                                                          #
# --------------------------------------------------------------------------- #
def all_minors(mat: Matrix) -> List[Tuple[Tuple[int, ...], Tuple[int, ...], Fraction]]:
    """Every minor of the matrix, as (row selection, column selection, value)."""
    m = len(mat)
    n = len(mat[0]) if m else 0
    out: List[Tuple[Tuple[int, ...], Tuple[int, ...], Fraction]] = []
    for k in range(1, min(m, n) + 1):
        for rows in combinations(range(m), k):
            for cols in combinations(range(n), k):
                out.append((rows, cols, determinant(submatrix(mat, rows, cols))))
    return out


def is_totally_nonnegative(mat: Matrix) -> bool:
    """True iff every minor of the matrix is >= 0."""
    return all(value >= 0 for _, _, value in all_minors(mat))


# --------------------------------------------------------------------------- #
# Adjacent column operations and bidiagonal construction                       #
# --------------------------------------------------------------------------- #
def apply_col_op(mat: Matrix, alpha: Fraction, src: int, tgt: int) -> Matrix:
    """Return a copy of `mat` with column `tgt` replaced by column tgt + alpha*column src.

    A *valid* operation requires alpha >= 0 and tgt == src + 1 (adjacent columns).
    """
    result = [row[:] for row in mat]
    for i in range(len(mat)):
        result[i][tgt] = mat[i][tgt] + alpha * mat[i][src]
    return result


def identity(n: int) -> Matrix:
    return [[Fraction(1) if i == j else Fraction(0) for j in range(n)] for i in range(n)]


def build_H3_from_identity() -> Tuple[Matrix, List[Matrix]]:
    """Build the 3x3 interval matrix H from the identity by valid adjacent ops.

    Steps (columns indexed 0,1,2):
        1. add 1 * column 1 to column 2
        2. add 1 * column 0 to column 1
        3. add 1 * column 1 to column 2
    Returns (final matrix, list of intermediate matrices including the seed).
    """
    m = identity(3)
    history = [m]
    for alpha, src, tgt in [(Fraction(1), 1, 2), (Fraction(1), 0, 1), (Fraction(1), 1, 2)]:
        m = apply_col_op(m, alpha, src, tgt)
        history.append(m)
    return m, history


# --------------------------------------------------------------------------- #
# Combinatorics of the interval subdivision                                    #
# --------------------------------------------------------------------------- #
def interval_subdivision_vertex_count(d: int) -> int:
    """Number of vertices of the interval subdivision of the (d-1)-simplex."""
    return 3 ** d - 2 ** d


def brute_force_interval_vertices(d: int) -> int:
    """Directly count nonempty intervals [F, G] with F subset G among faces of the
    simplex on d vertices, by assigning each vertex one of three states."""
    count = 0
    for assignment in range(3 ** d):
        states = []
        x = assignment
        for _ in range(d):
            states.append(x % 3)
            x //= 3
        # state 0: outside G, state 1: in G but not F, state 2: in F (hence in G)
        # A vertex of Int(simplex) is a nonempty interval [F, G] with F subset G
        # and F nonempty; F nonempty means at least one vertex is in state 2.
        f_nonempty = any(s == 2 for s in states)
        if f_nonempty:
            count += 1
    return count


def fmt(mat: Matrix) -> str:
    return "\n".join("  [" + ", ".join(str(x) for x in row) + "]" for row in mat)


def main() -> None:
    print("=" * 70)
    print("Total Nonnegativity of the Interval Subdivision Transformation Matrix")
    print("=" * 70)

    # -- 1. The 3x3 interval matrix and its total nonnegativity ---------------
    H = to_matrix([[1, 1, 1], [0, 1, 2], [0, 0, 1]])
    print("\n[1] The 3-dimensional interval subdivision matrix H:")
    print(fmt(H))
    minors = all_minors(H)
    print(f"\n    Number of minors examined: {len(minors)}")
    print(f"    All minors >= 0 ?  {is_totally_nonnegative(H)}")
    print("    Sample minors:")
    for rows, cols, val in minors:
        if len(rows) >= 2:
            print(f"      rows {rows}, cols {cols}:  det = {val}")

    # -- 2. Bidiagonal certificate --------------------------------------------
    print("\n[2] Building H from the identity by valid adjacent column operations:")
    built, history = build_H3_from_identity()
    for step, mat in enumerate(history):
        print(f"\n    After step {step} (TN = {is_totally_nonnegative(mat)}):")
        print(fmt(mat))
    print(f"\n    Construction reproduces H exactly ?  {built == H}")

    # -- 3. Preservation Lemma in action --------------------------------------
    print("\n[3] Preservation Lemma: a valid adjacent op keeps a TN matrix TN.")
    base = to_matrix([[2, 1, 0], [1, 3, 1], [0, 1, 2]])
    print(f"    Base matrix TN ?  {is_totally_nonnegative(base)}")
    for alpha in [Fraction(0), Fraction(1, 2), Fraction(3)]:
        out = apply_col_op(base, alpha, 1, 2)  # adjacent: tgt = src + 1
        print(f"    add {alpha} * col 1 to col 2  ->  TN = {is_totally_nonnegative(out)}")

    # A NON-adjacent, or negative, operation can break TN:
    bad = apply_col_op(base, Fraction(-1), 1, 2)
    print(f"    add -1 * col 1 to col 2 (invalid, alpha<0)  ->  TN = "
          f"{is_totally_nonnegative(bad)}")

    # -- 4. Vertex count 3^d - 2^d --------------------------------------------
    print("\n[4] Vertices of the interval subdivision of the (d-1)-simplex:")
    print(f"    {'d':>3} | {'3^d - 2^d':>10} | {'brute force':>12} | match")
    print("    " + "-" * 44)
    for d in range(1, 8):
        formula = interval_subdivision_vertex_count(d)
        brute = brute_force_interval_vertices(d)
        print(f"    {d:>3} | {formula:>10} | {brute:>12} | {formula == brute}")

    print("\nDone.")


if __name__ == "__main__":
    main()
