from typing import List

Matrix = List[List[float]]
Vector = List[float]

def trop_mat_vec(A: Matrix, v: Vector) -> Vector:
    n = len(A)
    return [min(A[i][k] + v[k] for k in range(n)) for i in range(n)]

def trop_residual(A: Matrix, v: Vector) -> Vector:
    Av = trop_mat_vec(A, v)
    return [Av[i] - v[i] for i in range(len(v))]

def spectral_tdlp_attack(A: Matrix, B: Matrix, v: Vector, lam: float) -> int:
    """Recover the secret genuine exponent t from public (A, B = A^{(x)t}),
    given an eigenpair (lam, v) of A with lam != 0.

    Mechanism: res(B, v)_i = t * lam at every coordinate (eigenvalue additivity),
    so t = res / lam. Cost: one matrix-vector product, O(n^2)."""
    if lam == 0:
        raise ValueError("eigenvalue 0: silent regime, no leak")
    r = trop_residual(B, v)[0]
    return round(r / lam)
