from __future__ import annotations
import numpy as np

def harmonic_representative(
    D: np.ndarray, E: np.ndarray, x: np.ndarray, tol: float = 1e-9
) -> np.ndarray:
    """Minimal-norm harmonic representative of the class of a closed cochain x."""
    Delta = D.T @ D + E @ E.T
    _, s, vh = np.linalg.svd(Delta)
    n = Delta.shape[1]
    padded = np.zeros(n); padded[: s.shape[0]] = s
    B = vh[padded <= tol].conj().T              # basis of ker Delta
    return B @ (B.conj().T @ x) if B.shape[1] else np.zeros_like(x)
