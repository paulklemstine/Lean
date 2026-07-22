from typing import List

Matrix = List[List[float]]


def weak_gershgorin_bound(matrix: Matrix) -> float:
    """Weak Gershgorin (absolute row-sum) eigenvalue bound.

    Implements the certificate eigenvalue_rowsum_bound: every eigenvalue lambda
    of a real square matrix satisfies |lambda| <= B, where B is the maximum
    absolute row sum max_i sum_j |M[i][j]|. Complexity: O(n^2).
    """
    return max(sum(abs(entry) for entry in row) for row in matrix)


def eigenvalue_interval(matrix: Matrix) -> tuple[float, float]:
    """Symmetric interval [-B, B] trapping every real eigenvalue (corollary
    eigenvalue_interval)."""
    b = weak_gershgorin_bound(matrix)
    return (-b, b)
