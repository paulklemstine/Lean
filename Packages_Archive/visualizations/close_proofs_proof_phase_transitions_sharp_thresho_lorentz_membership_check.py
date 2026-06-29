from typing import List, Tuple

Mat3 = List[List[int]]

METRIC_Q: Mat3 = [[1, 0, 0], [0, 1, 0], [0, 0, -1]]


def mat_mul(m: Mat3, n: Mat3) -> Mat3:
    return [[sum(m[i][k] * n[k][j] for k in range(3)) for j in range(3)]
            for i in range(3)]


def transpose(m: Mat3) -> Mat3:
    return [[m[j][i] for j in range(3)] for i in range(3)]


def preserves_lorentz(m: Mat3) -> bool:
    """True iff  M^T diag(1,1,-1) M = diag(1,1,-1), i.e. M in O(2,1;Z)."""
    return mat_mul(mat_mul(transpose(m), METRIC_Q), m) == METRIC_Q
