from __future__ import annotations
import numpy as np

Matrix = np.ndarray


def detection_scalar(P: Matrix, A: Matrix, tol: float = 1e-10
                     ) -> complex | None:
    """Return c with P A P = c P if A is detectable on code P, else None."""
    PAP = P @ A @ P
    nz = np.argwhere(np.abs(P) > tol)
    if nz.size == 0:
        return 0.0 + 0.0j
    i, j = nz[0]
    c: complex = complex(PAP[i, j] / P[i, j])
    if np.allclose(PAP, c * P, atol=tol):
        return c
    return None
