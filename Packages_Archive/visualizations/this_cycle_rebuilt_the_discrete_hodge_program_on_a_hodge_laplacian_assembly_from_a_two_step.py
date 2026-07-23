from __future__ import annotations
import numpy as np

def adjoint(matrix: np.ndarray) -> np.ndarray:
    """Adjoint of a real linear map = transpose under the Euclidean inner product."""
    return matrix.T

def hodge_laplacian(e: np.ndarray, d: np.ndarray) -> np.ndarray:
    """Assemble the Hodge Laplacian Delta = d* d + e e* on the middle space V.

    e : V x U  (maps U -> V),   d : W x V  (maps V -> W).
    Returns the V x V symmetric positive-semidefinite matrix Delta.
    """
    up_laplacian = adjoint(d) @ d      # d* d : sees the level above (W)
    down_laplacian = e @ adjoint(e)    # e e* : sees the level below (U)
    return up_laplacian + down_laplacian
