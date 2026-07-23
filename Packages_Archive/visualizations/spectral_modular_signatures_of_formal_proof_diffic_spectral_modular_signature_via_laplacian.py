from fractions import Fraction
from typing import Iterable, List, Tuple

def laplacian_nullity(n: int, edges: Iterable[Tuple[int, int]]) -> int:
    """Compute specModSig(G) as the nullity of the Laplacian L = D - A.

    Builds L over the rationals and returns n - rank(L) via exact Gaussian
    elimination. By the identity ker L = harmonicKernel G (the Dirichlet form
    f^T L f = sum_{u~v} (f u - f v)^2 vanishes iff f is edge-constant), this
    equals the number of connected components -- the spectral modular signature.

    Args:
        n: number of vertices.
        edges: undirected edges (u, v), u != v.

    Returns:
        The nullity of L (= dim harmonic kernel = #components).

    Complexity:
        O(n^3) field operations for the elimination.
    """
    if n == 0:
        return 0
    A: List[List[int]] = [[0] * n for _ in range(n)]
    for u, v in edges:
        A[u][v] += 1
        A[v][u] += 1
    deg = [sum(A[i]) for i in range(n)]
    L: List[List[Fraction]] = [
        [Fraction(deg[i] if i == j else -A[i][j]) for j in range(n)]
        for i in range(n)
    ]
    # Gauss-Jordan elimination to compute the rank.
    rank = 0
    col = 0
    for _ in range(n):
        if col >= n:
            break
        piv = next((r for r in range(rank, n) if L[r][col] != 0), None)
        if piv is None:
            col += 1
            continue
        L[rank], L[piv] = L[piv], L[rank]
        inv = L[rank][col]
        L[rank] = [x / inv for x in L[rank]]
        for r in range(n):
            if r != rank and L[r][col] != 0:
                f = L[r][col]
                L[r] = [a - f * b for a, b in zip(L[r], L[rank])]
        rank += 1
        col += 1
    return n - rank
