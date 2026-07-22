from __future__ import annotations
import cmath, math
from typing import List

Matrix = List[List[complex]]


def assemble_gauss_sum_matrix(eta: List[complex], omega: complex) -> Matrix:
    """Build A[i][j] = sum_a eta[a] * omega ** (a * (i + j)).

    Powers omega^0, ..., omega^(2n-2) are precomputed once, so each of the n^2
    entries is a length-n dot product. Total cost O(n^2) power lookups plus
    O(n^3) multiply-adds (naive); the Hankel structure permits an O(n^2 log n)
    FFT-based variant.
    """
    n = len(eta)
    powers = [omega ** t for t in range(2 * n - 1)]
    A: Matrix = [[0j] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            s = 0j
            for a in range(n):
                s += eta[a] * powers[a * (i + j) % (2 * n - 1)] \
                    if a * (i + j) < 2 * n - 1 else eta[a] * omega ** (a * (i + j))
            A[i][j] = sum(eta[a] * omega ** (a * (i + j)) for a in range(n))
    return A
