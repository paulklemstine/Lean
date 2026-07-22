from typing import List

Matrix = List[List[int]]

def det(M: Matrix) -> int:
    n = len(M)
    if n == 1:
        return M[0][0]
    if n == 2:
        return M[0][0] * M[1][1] - M[0][1] * M[1][0]
    total = 0
    for j in range(n):
        minor = [row[:j] + row[j + 1:] for row in M[1:]]
        total += ((-1) ** j) * M[0][j] * det(minor)
    return total

def transpose(M: Matrix) -> Matrix:
    return [list(r) for r in zip(*M)]

def matmul(A: Matrix, B: Matrix) -> Matrix:
    n, m, p = len(A), len(B), len(B[0])
    return [[sum(A[i][k] * B[k][j] for k in range(m)) for j in range(p)] for i in range(n)]

def invariance_certificate(H: Matrix, S: Matrix) -> bool:
    """Verify disc(S^T H S) = disc H, guaranteed when det S = +/-1."""
    assert det(S) in (1, -1), "S must be unimodular (det = +/-1)"
    Hc = matmul(matmul(transpose(S), H), S)
    return det(Hc) == det(H)
