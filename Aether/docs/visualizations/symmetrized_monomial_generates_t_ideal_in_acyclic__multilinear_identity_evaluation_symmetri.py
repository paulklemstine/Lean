from itertools import permutations
from typing import List, Tuple

Matrix = List[List[int]]


def _matmul(a: Matrix, b: Matrix) -> Matrix:
    n = len(a)
    out = [[0] * n for _ in range(n)]
    for i in range(n):
        for k in range(n):
            if a[i][k]:
                for j in range(n):
                    out[i][j] += a[i][k] * b[k][j]
    return out


def _sign(perm: Tuple[int, ...]) -> int:
    n = len(perm)
    seen = [False] * n
    s = 1
    for i in range(n):
        if seen[i]:
            continue
        length = 0
        j = i
        while not seen[j]:
            seen[j] = True
            j = perm[j]
            length += 1
        if length % 2 == 0:
            s = -s
    return s


def evaluate_identities(mats: List[Matrix]) -> Tuple[Matrix, Matrix]:
    """Return (S, S_n): the unsigned symmetrized monomial and the signed
    standard polynomial evaluated at the given n matrices.

    S   = sum over sigma of   a_{sigma(1)} ... a_{sigma(n)}
    S_n = sum over sigma of   sgn(sigma) * a_{sigma(1)} ... a_{sigma(n)}

    For strictly upper triangular n x n matrices both are the zero matrix.
    Complexity O(n! * n * n^3).
    """
    n = len(mats)
    S = [[0] * n for _ in range(n)]
    Sn = [[0] * n for _ in range(n)]
    for sigma in permutations(range(n)):
        prod = mats[sigma[0]]
        for i in range(1, n):
            prod = _matmul(prod, mats[sigma[i]])
        sg = _sign(sigma)
        for i in range(n):
            for j in range(n):
                S[i][j] += prod[i][j]
                Sn[i][j] += sg * prod[i][j]
    return S, Sn
