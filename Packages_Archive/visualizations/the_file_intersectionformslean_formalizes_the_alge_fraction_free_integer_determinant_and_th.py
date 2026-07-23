from fractions import Fraction
from typing import List

Matrix = List[List[int]]


def det_int(a: Matrix) -> int:
    """Exact determinant of an integer matrix via fraction-free elimination.

    Returns the integer determinant of a square integer matrix.  A symmetric
    integral intersection form is *unimodular* (Poincare duality) exactly when
    this determinant is +1 or -1.
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


def is_unimodular(gram: Matrix) -> bool:
    """Poincare duality test: determinant is a unit in Z."""
    return det_int(gram) in (1, -1)
