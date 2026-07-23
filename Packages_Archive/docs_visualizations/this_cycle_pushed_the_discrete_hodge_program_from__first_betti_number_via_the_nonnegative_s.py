from __future__ import annotations
import numpy as np

def hodge_betti(d: np.ndarray, e: np.ndarray, tol: float = 1e-9) -> int:
    """First Betti number = dim ker(Delta), via the nonnegative spectrum of Delta.

    By symmetry and eigenvalue-nonnegativity the spectrum of Delta is real and >= 0;
    the multiplicity of eigenvalue 0 is the harmonic dimension = number of independent
    cycles of the complex.
    """
    delta = d.T @ d + e @ e.T
    eig = np.linalg.eigvalsh(delta)
    return int(np.sum(np.abs(eig) < tol))
