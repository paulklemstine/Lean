from __future__ import annotations
import numpy as np


def unipotent_power(N: np.ndarray, n: int) -> np.ndarray:
    """Return (I + N)^n for a nilpotent N with N^2 = 0, in O(1) matrix ops.

    Uses the closed form (I + N)^n = I + n N, valid exactly when N^2 = 0.
    Raises if N is not nilpotent of index <= 2.
    """
    if not np.allclose(N @ N, 0):
        raise ValueError("N must satisfy N^2 = 0")
    d = N.shape[0]
    return np.eye(d, dtype=complex) + n * N
