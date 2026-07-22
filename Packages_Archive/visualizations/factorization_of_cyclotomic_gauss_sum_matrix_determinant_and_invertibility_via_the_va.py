from __future__ import annotations
import math
from typing import List


def gauss_sum_matrix_determinant(nodes: List[complex],
                                 eta: List[complex]) -> complex:
    """Return det A = (prod_{i<j}(nodes[j] - nodes[i]))^2 * prod_a eta[a].

    Here nodes[i] = omega ** i are the Fourier nodes. The Vandermonde product is
    the determinant of W; squaring it and multiplying by the product of periods
    yields det A by the factorization det A = (det W)^2 * prod eta. Cost O(n^2).
    """
    n = len(nodes)
    vander = 1 + 0j
    for i in range(n):
        for j in range(i + 1, n):
            vander *= (nodes[j] - nodes[i])
    prod_eta = math.prod(eta) if eta else 1
    return vander ** 2 * prod_eta


def is_invertible(nodes: List[complex], eta: List[complex],
                  tol: float = 1e-9) -> bool:
    """A is invertible over a field iff all nodes are distinct and all eta != 0."""
    n = len(nodes)
    distinct = all(abs(nodes[i] - nodes[j]) > tol
                   for i in range(n) for j in range(i + 1, n))
    all_nonzero = all(abs(x) > tol for x in eta)
    return distinct and all_nonzero
