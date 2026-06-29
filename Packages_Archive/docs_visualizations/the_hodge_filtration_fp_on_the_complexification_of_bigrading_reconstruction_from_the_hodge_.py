from __future__ import annotations
import numpy as np

def conj_map(basis: np.ndarray, Cmat: np.ndarray) -> np.ndarray:
    """Image of a subspace (columns = basis) under conj(x) = Cmat @ x.conj()."""
    return Cmat @ basis.conj()

def meet(A: np.ndarray, B: np.ndarray, tol: float = 1e-9) -> np.ndarray:
    """Basis of the intersection of column spaces A and B (Zassenhaus null space)."""
    if A.shape[1] == 0 or B.shape[1] == 0:
        return np.zeros((A.shape[0], 0), dtype=complex)
    M = np.hstack([A, -B])
    _, s, Vh = np.linalg.svd(M, full_matrices=True)
    smax = s[0] if s.size else 0.0
    k = M.shape[1] - int(np.sum(s > tol * max(1.0, smax)))
    if k == 0:
        return np.zeros((A.shape[0], 0), dtype=complex)
    ns = Vh.conj().T[:, M.shape[1] - k:]
    return A @ ns[:A.shape[1], :]

def reconstruct(F1: np.ndarray, F2: np.ndarray,
                Cmat: np.ndarray) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Recover (H20, H11, H02) from the filtration floors and conjugation."""
    H20 = F2
    CF1 = conj_map(F1, Cmat)
    H11 = meet(F1, CF1)
    H02 = conj_map(H20, Cmat)
    return H20, H11, H02
