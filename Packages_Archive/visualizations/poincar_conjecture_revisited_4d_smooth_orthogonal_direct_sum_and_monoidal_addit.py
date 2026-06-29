from typing import List

Matrix = List[List[int]]

def direct_sum(G: Matrix, H: Matrix) -> Matrix:
    """Block-diagonal direct sum [[G,0],[0,H]] modeling connected sum."""
    n, m = len(G), len(H)
    out = [[0] * (n + m) for _ in range(n + m)]
    for i in range(n):
        for j in range(n):
            out[i][j] = G[i][j]
    for i in range(m):
        for j in range(m):
            out[n + i][n + j] = H[i][j]
    return out
