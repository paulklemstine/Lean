from __future__ import annotations
import numpy as np

def hodge_betti(D: np.ndarray, E: np.ndarray, tol: float = 1e-9) -> int:
    """Compute the k-th Betti number b_k = dim(ker D) - rank(E) = dim(ker L).

    By the orthogonal Hodge decomposition (range E) (+) harmonic (+) (range D^T),
    the harmonic dimension equals the rank-nullity prediction on the boundary maps.
    """
    n: int = D.shape[1]
    rank_D: int = int(np.linalg.matrix_rank(D, tol=tol))
    rank_E: int = int(np.linalg.matrix_rank(E, tol=tol)) if E.shape[1] > 0 else 0
    return (n - rank_D) - rank_E
