from typing import List

Poly = List[int]; Matrix = List[List[int]]

def char_poly(A: Matrix, p: int) -> Poly:
    """det(tI - A) over F_p via division-free Laplace expansion."""
    n = len(A)
    B = [[[(-A[i][j]) % p, 1] if i == j else [(-A[i][j]) % p]
          for j in range(n)] for i in range(n)]
    def det(M: List[List[Poly]]) -> Poly:
        if len(M) == 1:
            return M[0][0]
        acc = [0]
        for j in range(len(M)):
            minor = [[M[r][k] for k in range(len(M)) if k != j]
                     for r in range(1, len(M))]
            t = _mul(M[0][j], det(minor), p)
            t = t if j % 2 == 0 else [(-c) % p for c in t]
            acc = _add(acc, t, p)
        return acc
    return det(B)

def is_certificate(A: Matrix, p: int) -> bool:
    """A is a linear generation certificate: invertible & charpoly irreducible."""
    return is_irreducible(char_poly(A, p), p)  # irreducible deg-n => det != 0
