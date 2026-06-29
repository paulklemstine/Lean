from __future__ import annotations
import numpy as np

def hodge_decomposition(d: np.ndarray, e: np.ndarray, x: np.ndarray
                        ) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Split an edge-signal x into (coexact, exact, harmonic) parts.

    Inputs d (dimW x dimV), e (dimV x dimU) with d @ e == 0, and x in R^{dimV}.
    Returns (c, a, h) with x = c + a + h, the three parts mutually orthogonal,
    realizing  P_coexact x + P_exact x + P_harmonic x = x.
    """
    delta = d.T @ d + e @ e.T
    # orthonormal basis of ker(delta) via SVD null space
    _, s, vh = np.linalg.svd(delta)
    rank = int(np.sum(s > 1e-9))
    H = vh[rank:].T
    def proj(cols: np.ndarray) -> np.ndarray:
        if cols.size == 0 or np.linalg.matrix_rank(cols) == 0:
            return np.zeros((delta.shape[0], delta.shape[0]))
        return cols @ np.linalg.pinv(cols)
    c = proj(d.T) @ x
    a = proj(e) @ x
    h = proj(H) @ x
    return c, a, h
