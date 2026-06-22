from __future__ import annotations
import numpy as np

def numerical_rank(M: np.ndarray, tol: float = 1e-9) -> int:
    if M.size == 0:
        return 0
    return int(np.sum(np.linalg.svd(M, compute_uv=False) > tol))

def betti_via_harmonic_kernel(D: np.ndarray, E: np.ndarray,
                              tol: float = 1e-9) -> int:
    """k-th Betti number b_k = dim ker D - rank E, with chain check D@E=0."""
    assert np.allclose(D @ E, 0.0, atol=1e-8), 'chain condition d.e = 0 fails'
    n = D.shape[1]
    b_k = (n - numerical_rank(D, tol)) - numerical_rank(E, tol)
    Delta = D.T @ D + E @ E.T
    harmonic_dim = n - numerical_rank(Delta, tol)
    assert harmonic_dim == b_k, 'discrete Hodge theorem cross-check failed'
    return b_k
