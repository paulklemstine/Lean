from itertools import product
from typing import List

Matrix = List[List[int]]
Vector = List[int]


def quadratic_value(gram: Matrix, v: Vector) -> int:
    """Q(v) = v^T G v for the form with Gram matrix `gram`."""
    n = len(gram)
    return sum(v[i] * gram[i][j] * v[j] for i in range(n) for j in range(n))


def diagonal_all_even(gram: Matrix) -> bool:
    """A symmetric integral form is even iff its diagonal is all even."""
    return all(gram[i][i] % 2 == 0 for i in range(len(gram)))


def donaldson_obstruction(gram: Matrix) -> bool:
    """Return True iff the symmetric form is provably NOT standard-diagonalizable
    by the parity (Donaldson) obstruction: an even form of positive rank can
    never be congruent over Z to diag(1,...,1), because the standard form
    represents the odd value 1 while an even form represents only even values.
    """
    n = len(gram)
    if n == 0:
        return False  # rank 0: trivially standard, no obstruction
    return diagonal_all_even(gram)  # even + positive rank => obstructed
