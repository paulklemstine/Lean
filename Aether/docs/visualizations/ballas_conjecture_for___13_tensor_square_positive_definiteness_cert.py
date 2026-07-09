from typing import List, Sequence, Tuple
import math, random

Vector = List[float]
Matrix = List[List[float]]

def dot(u: Sequence[float], v: Sequence[float]) -> float:
    return sum(a * b for a, b in zip(u, v))

def norm(v: Sequence[float]) -> float:
    return math.sqrt(dot(v, v))

def normalize(v: Sequence[float]) -> Vector:
    n = norm(v)
    return [x / n for x in v]

def tensor_square(v: Sequence[float]) -> Vector:
    """Lift v |-> v (x) v in R^{d^2}; satisfies <u@u, v@v> = <u,v>^2."""
    return [v[a] * v[b] for a in range(len(v)) for b in range(len(v))]

def gram_matrix(vectors: Sequence[Sequence[float]]) -> Matrix:
    return [[dot(a, b) for b in vectors] for a in vectors]

def smallest_eigenvalue(matrix: Matrix, iters: int = 2000) -> float:
    """Estimate lambda_min of a symmetric matrix; positive => positive definite."""
    n = len(matrix)
    x = normalize([random.gauss(0, 1) for _ in range(n)])
    lam_max = 0.0
    for _ in range(iters):
        y = [dot(matrix[i], x) for i in range(n)]
        ny = norm(y)
        if ny == 0.0:
            break
        x = [yi / ny for yi in y]
        lam_max = dot(x, [dot(matrix[i], x) for i in range(n)])
    shifted = [[(lam_max if i == j else 0.0) - matrix[i][j] for j in range(n)]
               for i in range(n)]
    z = normalize([random.gauss(0, 1) for _ in range(n)])
    mu = 0.0
    for _ in range(iters):
        y = [dot(shifted[i], z) for i in range(n)]
        ny = norm(y)
        if ny == 0.0:
            break
        z = [yi / ny for yi in y]
        mu = dot(z, [dot(shifted[i], z) for i in range(n)])
    return lam_max - mu

def certify_bound(vectors: Sequence[Sequence[float]], alpha: float,
                  d: int) -> Tuple[bool, int, int]:
    """Certify N <= d^2 by lifting and confirming the constant-pattern lifted
    Gram matrix is positive definite. Returns (certified, N, d^2).

    Complexity: O(N^2 d^2) to build the lifted Gram matrix, O(N^3) to estimate
    its smallest eigenvalue.
    """
    lifted = [tensor_square(v) for v in vectors]
    H = gram_matrix(lifted)
    n = len(vectors)
    diag_ok = all(abs(H[i][i] - 1.0) < 1e-9 for i in range(n))
    off_ok = all(abs(H[i][j] - alpha ** 2) < 1e-9
                 for i in range(n) for j in range(n) if i != j)
    pos_def = smallest_eigenvalue(H) > 1e-6
    return (diag_ok and off_ok and pos_def and n <= d * d, n, d * d)
