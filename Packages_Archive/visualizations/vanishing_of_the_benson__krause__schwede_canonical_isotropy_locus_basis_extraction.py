from itertools import product
from typing import List

Matrix = List[List[int]]
Vector = List[int]


def isotropy_locus_basis(gram: Matrix) -> List[Vector]:
    """Return a basis of the isotropy locus { x : q(x) = 0 } over F_2.

    Since q(x) = d^T x with d = diag(M), the locus is the kernel of the linear
    functional d. If d = 0 the locus is all of F_2^n (return the standard
    basis); otherwise it is a hyperplane of codimension one.
    """
    n = len(gram)
    d: Vector = [gram[i][i] & 1 for i in range(n)]
    if all(v == 0 for v in d):
        return [[1 if i == j else 0 for j in range(n)] for i in range(n)]
    pivot: int = next(i for i in range(n) if d[i] == 1)
    basis: List[Vector] = []
    for j in range(n):
        if j == pivot:
            continue
        vec: Vector = [0] * n
        vec[j] = 1
        vec[pivot] = d[j]  # ensures d^T vec = 0 over F_2
        basis.append(vec)
    return basis
