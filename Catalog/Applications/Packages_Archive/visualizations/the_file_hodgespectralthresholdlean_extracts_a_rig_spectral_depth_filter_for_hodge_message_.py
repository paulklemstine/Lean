from __future__ import annotations
from typing import Tuple
import numpy as np


def spectral_depth_filter(
    delta: np.ndarray, t: float, L: int, x: np.ndarray
) -> Tuple[np.ndarray, np.ndarray]:
    """Apply depth-L Hodge message passing T^L x with T = I - t*Delta.

    Diagonalizes the symmetric PSD Hodge Laplacian Delta = U diag(lam) U^T,
    transports x to the eigenbasis, scales each mode by (1 - t*lam)^L
    (harmonic modes lam=0 are fixed at amplitude 1), and reassembles.

    Returns (T^L x, per-mode amplitude profile (1 - t*lam)^L).
    Complexity: O(n^3) eigendecomposition, then O(n^2) per application.
    """
    lam, U = np.linalg.eigh(delta)          # Delta = U diag(lam) U^T
    coords: np.ndarray = U.T @ x            # coordinates in eigenbasis
    factor: np.ndarray = (1.0 - t * lam) ** L
    y: np.ndarray = U @ (factor * coords)   # reassemble
    return y, factor
