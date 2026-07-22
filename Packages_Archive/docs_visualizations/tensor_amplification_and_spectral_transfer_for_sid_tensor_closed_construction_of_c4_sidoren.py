from typing import List
Matrix = List[List[float]]

def kron(A: Matrix, B: Matrix) -> Matrix:
    """Kronecker (tensor) product of two square matrices."""
    na, nb = len(A), len(B)
    n = na * nb
    C: Matrix = [[0.0] * n for _ in range(n)]
    for i in range(na):
        for j in range(na):
            for ip in range(nb):
                for jp in range(nb):
                    C[i * nb + ip][j * nb + jp] = A[i][j] * B[ip][jp]
    return C

def is_symmetric(A: Matrix, tol: float = 1e-9) -> bool:
    n = len(A)
    return all(abs(A[i][j] - A[j][i]) <= tol for i in range(n) for j in range(n))

def tensor_closed_c4(seeds: List[Matrix]) -> Matrix:
    """Fold a list of symmetric seeds under the tensor product.

    Each seed satisfies C4-Sidorenko (Cauchy-Schwarz base case), and since 4 is even
    the class is closed under tensor products with no positivity hypothesis; hence the
    returned product still satisfies t(C4, .) >= t(K2, .)^4.
    """
    assert seeds, "need at least one seed"
    assert all(is_symmetric(A) for A in seeds), "seeds must be symmetric"
    result = seeds[0]
    for A in seeds[1:]:
        result = kron(result, A)
    return result
