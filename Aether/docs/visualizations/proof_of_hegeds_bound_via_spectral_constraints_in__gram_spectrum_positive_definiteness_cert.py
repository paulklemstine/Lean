from typing import List, Sequence, Set, Tuple
import math

Matrix = List[List[float]]

def incidence_rows(family: Sequence[Set[int]], n: int) -> Matrix:
    """0/1 incidence matrix V (rows = incidence vectors of the sets)."""
    return [[1.0 if t in A else 0.0 for t in range(n)] for A in family]

def gram(V: Matrix) -> Matrix:
    """Gram matrix G = V V^T."""
    m = len(V)
    return [[sum(V[i][t] * V[j][t] for t in range(len(V[i]))) for j in range(m)]
            for i in range(m)]

def jacobi_eigenvalues(M: Matrix, iters: int = 2000) -> List[float]:
    """Eigenvalues of a small symmetric matrix via cyclic Jacobi rotations."""
    n = len(M)
    A = [row[:] for row in M]
    for _ in range(iters):
        p, q, off = 0, 1, 0.0
        for i in range(n):
            for j in range(i + 1, n):
                if abs(A[i][j]) > off:
                    off, p, q = abs(A[i][j]), i, j
        if off < 1e-12:
            break
        app, aqq, apq = A[p][p], A[q][q], A[p][q]
        theta = 0.5 * math.atan2(2 * apq, aqq - app) if (aqq - app) else math.pi / 4
        c, s = math.cos(theta), math.sin(theta)
        for i in range(n):
            aip, aiq = A[i][p], A[i][q]
            A[i][p], A[i][q] = c * aip - s * aiq, s * aip + c * aiq
        for i in range(n):
            api, aqi = A[p][i], A[q][i]
            A[p][i], A[q][i] = c * api - s * aqi, s * api + c * aqi
    return sorted(A[i][i] for i in range(n))

def gram_spectrum_certify(
    family: Sequence[Set[int]], n: int
) -> Tuple[float, bool, int]:
    """
    Build the Gram matrix of the incidence vectors and certify positive
    definiteness via its smallest eigenvalue. Returns
    (min_eigenvalue, is_positive_definite, dimension_bound = n).
    Positive definiteness certifies linear independence, hence len(family) <= n.
    """
    V = incidence_rows(family, n)
    eigs = jacobi_eigenvalues(gram(V))
    return (min(eigs), min(eigs) > 1e-9, n)
