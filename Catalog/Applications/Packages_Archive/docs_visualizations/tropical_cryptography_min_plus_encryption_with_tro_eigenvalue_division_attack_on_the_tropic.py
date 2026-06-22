from typing import List, Optional

Matrix = List[List[float]]
Vector = List[float]

def trop_matvec(A: Matrix, v: Vector) -> Vector:
    n = len(v)
    return [min(A[i][k] + v[k] for k in range(n)) for i in range(n)]

def residual(A: Matrix, v: Vector) -> Vector:
    """tropResidual(A, v)_i = (A (x) v)_i - v_i."""
    Av = trop_matvec(A, v)
    return [Av[i] - v[i] for i in range(len(v))]

def eigenvalue_on_eigvec(A: Matrix, v: Vector) -> float:
    """On an eigenvector the eigenvalue is any residual coordinate (Theorem 1)."""
    return residual(A, v)[0]

def tdlp_attack(A: Matrix, B: Matrix, v: Vector,
                tol: float = 1e-9) -> Optional[int]:
    """Recover k from B = A^{(x)k} using lambda(A^k) = k * lambda(A).

    Returns None at the boundary lambda(A) = 0, where eigenzero_no_leak
    guarantees the residual channel is silent and the exponent is
    unrecoverable by this method.
    """
    lamA = eigenvalue_on_eigvec(A, v)
    lamB = eigenvalue_on_eigvec(B, v)
    if abs(lamA) <= tol:
        return None                      # boundary: no leak
    return round(lamB / lamA)
