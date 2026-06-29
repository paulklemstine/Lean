from __future__ import annotations
import numpy as np

def hodge_decompose(
    D: np.ndarray, E: np.ndarray, x: np.ndarray, tol: float = 1e-9
) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Split x into (coexact, exact, harmonic) orthogonal components."""
    Delta = D.T @ D + E @ E.T
    def colspace(A: np.ndarray) -> np.ndarray:
        if A.size == 0:
            return np.zeros((Delta.shape[0], 0))
        u, s, _ = np.linalg.svd(A, full_matrices=False)
        r = int(np.sum(s > tol))
        return u[:, :r]
    def nullspace(A: np.ndarray) -> np.ndarray:
        _, s, vh = np.linalg.svd(A)
        n = A.shape[1]
        padded = np.zeros(n); padded[: s.shape[0]] = s
        return vh[padded <= tol].conj().T
    B_co, B_ex, B_h = colspace(D.T), colspace(E), nullspace(Delta)
    def proj(B: np.ndarray) -> np.ndarray:
        return B @ (B.conj().T @ x) if B.shape[1] else np.zeros_like(x)
    return proj(B_co), proj(B_ex), proj(B_h)
