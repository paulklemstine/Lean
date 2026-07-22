import numpy as np

def seidel_reduction(B: np.ndarray, tol: float = 1e-6) -> np.ndarray:
    """Return the 0/+-1 Seidel matrix S = 3 B B^T - 3 I of an
    equiangular 1/3 configuration, verifying the angle conditions."""
    m, _ = B.shape
    G = B @ B.T
    if not np.allclose(np.diag(G), 1.0, atol=tol):
        raise ValueError('rows are not unit vectors')
    for i in range(m):
        for j in range(i + 1, m):
            if abs(abs(G[i, j]) - 1.0 / 3.0) > tol:
                raise ValueError('pairwise angle is not arccos(1/3)')
    S = 3.0 * G - 3.0 * np.eye(m)
    return S
