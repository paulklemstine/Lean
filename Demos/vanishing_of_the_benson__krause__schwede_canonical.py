"""
Numerical demonstrations for:

    The Canonical Class of a Pro-2 Demushkin Group and the
    Characteristic-Two Linearization of the Cup Product.

All arithmetic is over the two-element field F_2 = {0, 1}, represented by
Python ints reduced mod 2. A cup-product form B on V = F_2^n is given by its
symmetric Gram matrix M in {0,1}^{n x n}, so that

    B(x, y) = sum_{i,j} x_i * M[i][j] * y_j   (mod 2).

We verify, on explicit examples, the results of the paper:

  * Theorem (char-2 linearity): x -> B(x, x) is F_2-linear, represented by the
    diagonal d = diag(M): B(x, x) = sum_i M[i][i] * x_i  (mod 2).
  * Definition/Theorem (Kummer class): the unique chi with B(chi, x) = B(x, x)
    for all x is the solution of M chi = d over F_2.
  * Theorem (type dichotomy): B is alternating  <=>  chi = 0  <=>  d = 0.
  * Realizations: the dot product (odd type, chi = all-ones, isotropy locus =
    even-weight hyperplane) and the hyperbolic plane (even type, chi = 0).
"""

from __future__ import annotations

from itertools import product
from typing import List, Optional, Tuple

Vector = List[int]
Matrix = List[List[int]]


# --------------------------------------------------------------------------- #
#  Basic F_2 linear algebra                                                    #
# --------------------------------------------------------------------------- #
def bilinear(M: Matrix, x: Vector, y: Vector) -> int:
    """Evaluate B(x, y) = x^T M y over F_2."""
    n = len(M)
    total = 0
    for i in range(n):
        for j in range(n):
            total ^= (x[i] & M[i][j] & y[j])
    return total & 1


def self_cup(M: Matrix, x: Vector) -> int:
    """The squaring functional q(x) = B(x, x) over F_2."""
    return bilinear(M, x, x)


def all_vectors(n: int) -> List[Vector]:
    """Enumerate every vector of F_2^n."""
    return [list(bits) for bits in product((0, 1), repeat=n)]


def is_symmetric(M: Matrix) -> bool:
    n = len(M)
    return all(M[i][j] == M[j][i] for i in range(n) for j in range(n))


def is_nondegenerate(M: Matrix) -> bool:
    """B is nondegenerate iff its Gram matrix is invertible over F_2."""
    return _det_f2(M) == 1


def is_alternating(M: Matrix) -> bool:
    """B is alternating iff B(x, x) = 0 for all x, i.e. diag(M) = 0 over F_2."""
    return all(M[i][i] % 2 == 0 for i in range(len(M)))


def _det_f2(M: Matrix) -> int:
    """Determinant over F_2 via Gaussian elimination (0 or 1)."""
    n = len(M)
    A = [[M[i][j] & 1 for j in range(n)] for i in range(n)]
    det = 1
    for col in range(n):
        pivot = next((r for r in range(col, n) if A[r][col] == 1), None)
        if pivot is None:
            return 0
        if pivot != col:
            A[col], A[pivot] = A[pivot], A[col]
        for r in range(n):
            if r != col and A[r][col] == 1:
                A[r] = [(A[r][k] ^ A[col][k]) for k in range(n)]
    return det


def solve_f2(M: Matrix, b: Vector) -> Optional[Vector]:
    """Solve M x = b over F_2 (returns a solution, or None if inconsistent)."""
    n = len(M)
    A = [[M[i][j] & 1 for j in range(n)] + [b[i] & 1] for i in range(n)]
    where: List[int] = [-1] * n
    row = 0
    for col in range(n):
        piv = next((r for r in range(row, n) if A[r][col] == 1), None)
        if piv is None:
            continue
        A[row], A[piv] = A[piv], A[row]
        for r in range(n):
            if r != row and A[r][col] == 1:
                A[r] = [(A[r][k] ^ A[row][k]) for k in range(n + 1)]
        where[col] = row
        row += 1
    x = [0] * n
    for col in range(n):
        if where[col] != -1:
            x[col] = A[where[col]][n]
    # consistency check
    for i in range(n):
        acc = 0
        for j in range(n):
            acc ^= (M[i][j] & x[j])
        if (acc & 1) != (b[i] & 1):
            return None
    return x


# --------------------------------------------------------------------------- #
#  Paper-level invariants                                                      #
# --------------------------------------------------------------------------- #
def diagonal(M: Matrix) -> Vector:
    """The vector d = diag(M) representing the squaring functional."""
    return [M[i][i] & 1 for i in range(len(M))]


def kummer_class(M: Matrix) -> Vector:
    """
    The Kummer / orientation class chi: unique solution of M chi = diag(M)
    over F_2 (exists uniquely because M is nondegenerate).
    """
    d = diagonal(M)
    chi = solve_f2(M, d)
    assert chi is not None, "nondegenerate form must have a Kummer class"
    return chi


def demushkin_type(M: Matrix) -> str:
    return "even (alternating)" if all(c == 0 for c in kummer_class(M)) else "odd"


def isotropy_locus(M: Matrix) -> List[Vector]:
    """{ x : B(x, x) = 0 }."""
    return [x for x in all_vectors(len(M)) if self_cup(M, x) == 0]


# --------------------------------------------------------------------------- #
#  Verification routines                                                       #
# --------------------------------------------------------------------------- #
def verify_squaring_is_linear(M: Matrix) -> bool:
    """Theorem 2.2: q(x+y) = q(x) + q(y) and q(x) = sum_i M_ii x_i."""
    n = len(M)
    d = diagonal(M)
    for x in all_vectors(n):
        if self_cup(M, x) != sum(d[i] & x[i] for i in range(n)) & 1:
            return False
    for x in all_vectors(n):
        for y in all_vectors(n):
            xy = [(x[i] ^ y[i]) for i in range(n)]
            if self_cup(M, xy) != (self_cup(M, x) ^ self_cup(M, y)):
                return False
    return True


def verify_kummer_spec(M: Matrix) -> bool:
    """Theorem 3.2: B(chi, x) = B(x, x) for all x."""
    chi = kummer_class(M)
    return all(bilinear(M, chi, x) == self_cup(M, x) for x in all_vectors(len(M)))


def verify_dichotomy(M: Matrix) -> bool:
    """Theorem 4.2: alternating  <=>  chi = 0."""
    chi_zero = all(c == 0 for c in kummer_class(M))
    return is_alternating(M) == chi_zero


# --------------------------------------------------------------------------- #
#  Example forms                                                               #
# --------------------------------------------------------------------------- #
def dot_form(n: int) -> Matrix:
    """Standard dot product on F_2^n (odd type for n >= 1)."""
    return [[1 if i == j else 0 for j in range(n)] for i in range(n)]


def hyperbolic_plane() -> Matrix:
    """Hyperbolic plane on F_2^2 (even type)."""
    return [[0, 1], [1, 0]]


def _fmt(v: Vector) -> str:
    return "(" + ",".join(str(b) for b in v) + ")"


def report(name: str, M: Matrix) -> None:
    print(f"=== {name} ===")
    print("  Gram matrix:", M)
    print("  symmetric      :", is_symmetric(M))
    print("  nondegenerate  :", is_nondegenerate(M))
    print("  alternating    :", is_alternating(M))
    print("  Kummer class χ :", _fmt(kummer_class(M)))
    print("  Demushkin type :", demushkin_type(M))
    locus = isotropy_locus(M)
    print(f"  isotropy locus : {len(locus)} of {2 ** len(M)} vectors")
    print("  squaring linear:", verify_squaring_is_linear(M))
    print("  Kummer spec ok :", verify_kummer_spec(M))
    print("  dichotomy ok   :", verify_dichotomy(M))
    print()


def main() -> None:
    print("Demushkin cup-product forms over F_2\n")

    for n in (1, 2, 3, 4):
        report(f"Dot product on F_2^{n} (odd type)", dot_form(n))

    report("Hyperbolic plane on F_2^2 (even type)", hyperbolic_plane())

    # Direct sum of two hyperbolic planes: even type, even rank 4.
    H2 = [
        [0, 1, 0, 0],
        [1, 0, 0, 0],
        [0, 0, 0, 1],
        [0, 0, 1, 0],
    ]
    report("Hyperbolic ⊕ hyperbolic on F_2^4 (even type)", H2)

    # A mixed odd-type form: hyperbolic plane ⊕ one-dim dot line, rank 3 (odd).
    mixed = [
        [0, 1, 0],
        [1, 0, 0],
        [0, 0, 1],
    ]
    report("Mixed form on F_2^3 (odd type, odd rank)", mixed)

    print("All theorems verified on every example above.")


if __name__ == "__main__":
    main()
