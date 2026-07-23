from __future__ import annotations
import numpy as np

def harmonic_subspace(delta: np.ndarray, tol: float = 1e-9) -> np.ndarray:
    """Orthonormal basis (columns) of the harmonic space ker(Delta).

    Delta is symmetric PSD, so eigh gives an orthonormal eigenbasis with real
    non-negative eigenvalues.  The harmonic space is spanned by eigenvectors
    whose eigenvalue is (numerically) zero -- exactly the closed-and-co-closed
    cochains, and its dimension is the relevant Betti number.
    """
    eigenvalues, eigenvectors = np.linalg.eigh(delta)
    harmonic_cols = [eigenvectors[:, i]
                     for i in range(len(eigenvalues))
                     if abs(eigenvalues[i]) < tol]
    if not harmonic_cols:
        return np.zeros((delta.shape[0], 0))
    return np.column_stack(harmonic_cols)

def harmonic_projection(delta: np.ndarray, x: np.ndarray,
                        tol: float = 1e-9) -> np.ndarray:
    """Orthogonal projection P x of x onto ker(Delta) (the topological fingerprint)."""
    basis = harmonic_subspace(delta, tol)
    if basis.shape[1] == 0:
        return np.zeros_like(x)
    return basis @ (basis.T @ x)
