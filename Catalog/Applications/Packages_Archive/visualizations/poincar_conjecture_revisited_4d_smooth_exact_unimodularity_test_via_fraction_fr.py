from fractions import Fraction
from typing import List

Matrix = List[List[int]]

def integer_determinant(G: Matrix) -> int:
    n = len(G)
    A = [[Fraction(x) for x in row] for row in G]
    det = Fraction(1)
    for col in range(n):
        pr = next((r for r in range(col, n) if A[r][col] != 0), None)
        if pr is None:
            return 0
        if pr != col:
            A[col], A[pr] = A[pr], A[col]; det = -det
        det *= A[col][col]
        for r in range(col + 1, n):
            f = A[r][col] / A[col][col]
            for c in range(col, n):
                A[r][c] -= f * A[col][c]
    return int(det)

def is_unimodular(G: Matrix) -> bool:
    return integer_determinant(G) in (1, -1)
