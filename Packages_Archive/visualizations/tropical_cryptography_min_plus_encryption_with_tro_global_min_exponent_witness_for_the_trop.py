from typing import List, Tuple

Matrix = List[List[float]]
INF = float("inf")


def gmin(a: Matrix) -> float:
    """Global minimum entry: the lightest single edge weight (O(n^2))."""
    return min(a[i][j] for i in range(len(a)) for j in range(len(a)))


def tdlp_gmin_witness(a: Matrix, b: Matrix) -> Tuple[float, str]:
    """Global-min exponent witness for the tropical discrete logarithm.

    Given public (A, B) with B = A^{(k+1)}, returns an upper bound on the secret
    exponent k+1 via the linear lower bound (k+1)*gmin(A) <= gmin(A^{(k+1)}) = gmin(B),
    so k+1 <= gmin(B)/gmin(A) when gmin(A) > 0.
    """
    ga, gb = gmin(a), gmin(b)
    if ga <= 0:
        return INF, "no leak: gmin(A) <= 0 (degenerate boundary)"
    return gb / ga, "k + 1 <= gmin(B) / gmin(A)"
