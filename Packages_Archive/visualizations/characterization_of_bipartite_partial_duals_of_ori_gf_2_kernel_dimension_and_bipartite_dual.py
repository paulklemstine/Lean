from __future__ import annotations
from typing import List

Matrix = List[List[int]]

def gf2_kernel_dimension(J: Matrix) -> int:
    """Dimension of the GF(2) kernel of the symmetric crossing operator J,
    via Gaussian elimination. The number of bipartite partial duals is
    2 ** gf2_kernel_dimension(J)."""
    n = len(J)
    M = [row[:] for row in J]
    rank = 0
    pivot_col = 0
    for col in range(n):
        pivot = None
        for r in range(rank, n):
            if M[r][col] == 1:
                pivot = r
                break
        if pivot is None:
            continue
        M[rank], M[pivot] = M[pivot], M[rank]
        for r in range(n):
            if r != rank and M[r][col] == 1:
                M[r] = [(a ^ b) for a, b in zip(M[r], M[rank])]
        rank += 1
    return n - rank

def number_of_bipartite_duals(J: Matrix) -> int:
    return 2 ** gf2_kernel_dimension(J)
